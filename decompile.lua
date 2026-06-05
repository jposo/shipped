local gmd = require("src.gmd")
local data = require("src.data")
local utils = require("src.utils")

local OUTPUT_DIR = "decompiled"

local function parse_args(args)
    local opts = {
        file = nil,
        output_dir = OUTPUT_DIR,
    }

    local i = 1
    while i <= #args do
        local a = args[i]
        if a == "--output" or a == "-o" then
            i = i + 1
            opts.output_dir = args[i]
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

    if not opts.name then
        opts.name = tostring(os.time(os.date("!*t")))
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
            local flip_x = tonumber(kv[4]) or false
            local flip_y = tonumber(kv[5]) or false
            local rotation = tonumber(kv[6]) or 0

            if block_id and gd_x and gd_y then
                local grid_x = math.floor(gd_x)
                local grid_y = math.floor(gd_y)
                table.insert(objects, {
                    block_id = block_id,
                    gd_x = gd_x,
                    gd_y = gd_y,
                    grid_x = grid_x,
                    grid_y = grid_y,
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

local function generate_dsl(meta, objects)
    local lines = {}
    local function emit(s) table.insert(lines, s) end

    emit("config {")
    emit('  name = "' .. meta.name .. '",')
    emit('  creator = "' .. meta.creator .. '",')
    emit('  song = "' .. resolve_song_id(meta.song) .. '",')
    emit("}")
    emit("")

    for _, obj in ipairs(objects) do
        local name = resolve_block_id(obj.block_id)
        local rot = obj.rotation ~= 0 and (":rotate(" .. obj.rotation .. ")") or ""
        local flip_x = obj.flip_x and (":flip_horizontally()") or ""
        local flip_y = obj.flip_y and (":flip_vertically()") or ""
        emit(string.format(
            'struct("%s"):place_at(%d, %d)%s%s%s',
            name, obj.grid_x, obj.grid_y, flip_x, flip_y, rot
        ))
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

local dsl_code = generate_dsl(meta, objects)

utils.ensure_dir(opts.output_dir)
local out_path = utils.output_path(opts.output_dir, meta.name, "lua")
local f = io.open(out_path, "w")
if not f then error("could not write to " .. out_path) end
f:write(dsl_code)
f:close()

print("objects parsed: " .. #objects)
print("output: " .. out_path)
