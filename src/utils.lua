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

function utils.interpolate_line(x0, y0, x1, y1)
    return coroutine.wrap(function()
        local steps = math.max(
            math.abs(math.floor(x1 / data.CELL_SIZE) - math.floor(x0 / data.CELL_SIZE)),
            math.abs(math.floor(y1 / data.CELL_SIZE) - math.floor(y0 / data.CELL_SIZE))
        )

        if steps == 0 then
            coroutine.yield(x0, y0)
            return
        end

        local x_inc = (x1 - x0) / steps
        local y_inc = (y1 - y0) / steps

        for i = 0, steps do
            coroutine.yield(
                x0 + x_inc * i,
                y0 + y_inc * i
            )
        end
    end)
end

function utils.basename(path)
    return path:match("([^/\\]+)$") or path
end

return utils
