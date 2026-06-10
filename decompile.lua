local gmd = require("src.gmd")
local data = require("src.data")
local utils = require("src.utils")

local OUTPUT_DIR = "decompiled"

local function parse_args(args)
    local opts = {
        file = nil,
        output_dir = OUTPUT_DIR,
        collapse = false,
    }

    local i = 1
    while i <= #args do
        local a = args[i]
        if a == "--output" or a == "-o" then
            i = i + 1
            opts.output_dir = args[i]
        elseif a == "--collapse" then
            opts.collapse = true
        elseif not a:match("^%-") then
            opts.file = a
        else
            io.stderr:write("warn: unknown flag '" .. a .. "'\n")
        end
        i = i + 1
    end

    if not opts.file then
        error("usage: lua decompile.lua <file.gmd> [--output DIR]")
    end

    return opts
end

local function parse_objects(inner)
    local body = inner:match(";kA[^;]*;(.+)$")
        or inner:match(";kS[^;]*;(.+)$")
    if not body then
        body = inner:match("kA19,0,kA26,0,kA20,0,kA21,0,kA11,0;(.*)") or inner
    end

    local objects = {}
    for obj_str in body:gmatch("([^;]+);?") do
        if obj_str ~= "" then
            local kv = {}
            local keys = {}
            for k, v in obj_str:gmatch("(%d+),([^,]+)") do
                kv[tonumber(k)] = v
                table.insert(keys, tonumber(k))
            end

            local block_id = tonumber(kv[1])
            local gd_x = tonumber(kv[2])
            local gd_y = tonumber(kv[3])
            local flip_x = kv[4] == "1"
            local flip_y = kv[5] == "1"
            local rotation = tonumber(kv[6]) or 0

            if block_id and gd_x and gd_y then
                table.insert(objects, {
                    block_id = block_id,
                    x = gd_x,
                    y = gd_y,
                    flip_x = flip_x,
                    flip_y = flip_y,
                    rotation = rotation,
                })
            end
        end
    end
    return objects
end

local function resolve_block_id(id)
    return data.BLOCK_NAMES[id] or ("block --[[unknown id " .. id .. "]]")
end

local function resolve_song_id(song_id)
    local name = data.SONG_NAMES[song_id]
    if name then
        return name
    end
    return song_id
end

local function same_struct(a, b)
    return a.block_id == b.block_id
        and a.rotation == b.rotation
        and a.flip_x == b.flip_x
        and a.flip_y == b.flip_y
        and math.abs(a.x - b.x) <= data.CELL_SIZE
        and math.abs(a.y - b.y) <= data.CELL_SIZE
end

local function group_into_structs(objects)
    local structs = {}
    if #objects == 0 then return structs end
    local current = {objects[1]}
    for i = 2, #objects do
        if same_struct(objects[i - 1], objects[i]) then
            table.insert(current, objects[i])
        else
            table.insert(structs, current)
            current = {objects[i]}
        end
    end
    table.insert(structs, current)
    return structs
end

local function try_as_rect(points)
    if #points < 4 then return nil end
    local min_x, max_x = points[1].x, points[1].x
    local min_y, max_y = points[1].y, points[1].y
    for _, p in ipairs(points) do
        if p.x < min_x then min_x = p.x end
        if p.x > max_x then max_x = p.x end
        if p.y < min_y then min_y = p.y end
        if p.y > max_y then max_y = p.y end
    end
    if min_x == max_x or min_y == max_y then return nil end
    for _, p in ipairs(points) do
        if not (p.x == min_x or p.x == max_x or p.y == min_y or p.y == max_y) then
            return nil
        end
    end
    return {
        x0 = min_x,
        y0 = min_y,
        x1 = max_x,
        y1 = max_y,
    }
end

local function try_as_line(points)
    if #points == 1 then
        return {
            x0 = points[1].x,
            y0 = points[1].y,
            x1 = points[1].x,
            y1 = points[1].y,
        }
    end
    local dx = points[2].x - points[1].x
    local dy = points[2].y - points[1].y
    for i = 3, #points do
        local ex = points[i].x - points[i-1].x
        local ey = points[i].y - points[i-1].y
        if math.abs(ex - dx) > 1 or math.abs(ey - dy) > 1 then
            return nil
        end
    end
    return {
        x0 = points[1].x,
        y0 = points[1].y,
        x1 = points[#points].x,
        y1 = points[#points].y,
    }
end

local function attributes(obj_or_struct_head)
    local o = obj_or_struct_head
    local s = ""
    if o.flip_x    then s = s .. ":flip_horizontally()" end
    if o.flip_y    then s = s .. ":flip_vertically()" end
    if o.rotation ~= 0 then s = s .. ":rotate(" .. o.rotation .. ")" end
    return s
end

local function generate_dsl(meta, objects, collapse)
    local lines = {}
    local function emit(s) table.insert(lines, s) end

    emit("config {")
    emit('  name = "' .. meta.name .. '",')
    emit('  creator = "' .. meta.creator .. '",')
    emit('  song = "' .. resolve_song_id(meta.song) .. '",')
    emit("}")
    emit("")

    if not collapse then
        for _, obj in ipairs(objects) do
            local name = resolve_block_id(obj.block_id)
            emit(string.format(
                'struct("%s"):place_at(%d, %d)%s',
                name, obj.x, obj.y, attributes(obj)
            ))
        end
        return table.concat(lines, "\n")
    end

    local structs = group_into_structs(objects)

    for _, struct in ipairs(structs) do
        local name = resolve_block_id(struct[1].block_id)
        local attrs = attributes(struct[1])

        local rect = try_as_rect(struct)
        if rect then
            emit(string.format(
                'struct("%s"):place_at(%d, %d):rect_to(%d, %d)%s',
                name, rect.x0, rect.y0, rect.x1, rect.y1, attrs
            ))
        else
            local line = try_as_line(struct)
            if line and (line.x0 ~= line.x1 or line.y0 ~= line.y1) then
                emit(string.format(
                    'struct("%s"):place_at(%d, %d):swipe_to(%d, %d)%s',
                    name, line.x0, line.y0, line.x1, line.y1, attrs
                ))
            else
                for _, obj in ipairs(struct) do
                    emit(string.format(
                        'struct("%s"):place_at(%d, %d)%s',
                        resolve_block_id(obj.block_id),
                        obj.x, obj.y,
                        attributes(obj)
                    ))
                end
            end
        end
    end
    return table.concat(lines, "\n")
end

local opts = parse_args(arg)

local meta = gmd.parse_gmd(opts.file)
meta.source_file = utils.basename(opts.file)

local inner = gmd.decode_k4_string(meta.encoded)
local objects = parse_objects(inner)

if #objects == 0 then
    io.stderr:write("warn: no objects parsed\n")
end

local dsl_code = generate_dsl(meta, objects, opts.collapse)

utils.ensure_dir(opts.output_dir)
local out_path = utils.output_path(opts.output_dir, meta.name, "lua")
local f = io.open(out_path, "w")
if not f then error("could not write to " .. out_path) end
f:write(dsl_code)
f:close()

print("objects parsed: " .. #objects)
print("output: " .. out_path)
