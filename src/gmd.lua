local gmd = {}
-- local zlib = require("zlib")
-- local base64 = require("src.base64")

-- local function encode_level(level_string, is_official_level)
--   local stream = zlib.deflate(9, 31)
--   local compressed, eof, bytes_in, bytes_out = stream(level_string, "finish")

--   local base64_encoded = base64.url_safe_base64_encode(compressed)

--   if is_official_level then
--     base64_encoded = base64_encoded:sub(14)
--   end
--   return base64_encoded
-- end

local function encode_k4_string(raw_str)
    local handle = io.popen(string.format(
        "python3 src/convert.py encode \"%s\"",
        raw_str
    ))
    if handle == nil then
        error("could not execute python script")
    end
    local encoded = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    -- local encoded = encode_level(raw_str, false)
    return encoded
end

function gmd.decode_k4_string(encoded)
    -- local tmp = os.tmpname()
    -- local f = io.open(tmp, "w")
    -- if not f then error("could not create temp file") end
    -- f:write(encoded)
    -- f:close()

    local handle = io.popen(string.format(
        "python3 src/convert.py decode \"%s\"",
        encoded
    ))
    if handle == nil then
        error("could not execute python script")
    end
    local decoded = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    -- os.remove(tmp)
    return decoded
end

local function extract_xml_field(xml, key)
    local val = xml:match("<k>" .. key .. "</k><s>(.-)</s>")
        or xml:match("<k>" .. key .. "</k><i>(.-)</i>")
    return val
end

function gmd.parse_gmd(path)
    local f = io.open(path, "r")
    if not f then error("file not found: " .. path) end
    local xml = f:read("*a")
    f:close()

    local name = extract_xml_field(xml, "k2") or "unnamed"
    local creator = extract_xml_field(xml, "k5") or "player"
    local song = extract_xml_field(xml, "k8") or "stereo madness"
    local encoded = extract_xml_field(xml, "k4")
    if not encoded then
        error("could not find k4 (level data) in " .. path)
    end
    return {
        name = name,
        creator = creator,
        song = song,
        encoded = encoded
    }
end

function gmd.export_to_gmd(level_name, creator_name, song_id, raw_data, object_count, output_filename)
    local encoded_k4 = encode_k4_string(raw_data)
    local template_file = io.input("src/gmd_template.xml")
    if template_file == nil then
        error("GMD template file not found")
    end
    local gmd_template = template_file:read('a')
    local final_xml = string.format(gmd_template, level_name, encoded_k4, creator_name, song_id, object_count)
    local file = io.open(output_filename, "w")
    if file then
        file:write(final_xml)
        file:close()
    else
        error("failed to write to the file")
    end
end

return gmd
