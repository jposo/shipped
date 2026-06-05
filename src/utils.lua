local data = require("src.data")

local utils = {}

function utils.ensure_dir(path)
    os.execute(string.format('mkdir -p "%s"', path))
end

function utils.output_path(dir, name, file_type)
    if file_type == nil then
        file_type = "txt"
    end
    local safe = name:gsub("[^%w%-_]", "_")
    return string.format("%s/%s.%s", dir, safe, file_type)
end

function utils.dda(x0, y0, x1, y1)
    return coroutine.wrap(function()
        local CELL_SIZE = 30

        local gx0 = math.floor(x0 / CELL_SIZE)
        local gy0 = math.floor(y0 / CELL_SIZE)
        local gx1 = math.floor(x1 / CELL_SIZE)
        local gy1 = math.floor(y1 / CELL_SIZE)

        local dx = math.abs(gx1 - gx0)
        local dy = math.abs(gy1 - gy0)
        local steps = math.max(dx, dy)
        local x_inc = steps > 0 and ((gx1 - gx0) / steps) or 0
        local y_inc = steps > 0 and ((gy1 - gy0) / steps) or 0

        local x = gx0
        local y = gy0

        for i = 0, steps do
            local gd_x = math.floor(x + 0.5) * CELL_SIZE + data.ORIGIN_X
            local gd_y = math.floor(y + 0.5) * CELL_SIZE + data.ORIGIN_Y
            coroutine.yield(gd_x, gd_y)
            x = x + x_inc
            y = y + y_inc
        end
    end)
end

function utils.basename(path)
    return path:match("([^/\\]+)$") or path
end

return utils
