local gmd = require("src.gmd")

local ORIGIN_X = 15
local ORIGIN_Y = 15
local BUILDS_DIR = "builds"

local function parse_args(args)
  local opts = {
    file = nil,
    output_dir = BUILDS_DIR,
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
    error("usage: lua main.lua <file.lua> [--output DIR]")
  end

  if not opts.name then
    opts.name = tostring(os.time(os.date("!*t")))
  end

  return opts
end

local function ensure_dir(path)
  os.execute(string.format('mkdir -p "%s"', path))
end

local function output_path(dir, name)
  local safe = name:gsub("[^%w%-_]", "_")
  return string.format("%s/%s.gmd", dir, safe)
end

local function dda(x0, y0, x1, y1)
  return coroutine.wrap(function()
    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)

    local steps = math.max(dx, dy)
    local x_inc = steps > 0 and (dx / steps) or 0
    local y_inc = steps > 0 and (dy / steps) or 0

    local x = x0
    local y = y0

    for i = 0, steps do
      local gd_x = math.floor(x + 0.5) * 30 + ORIGIN_X
      local gd_y = math.floor(y + 0.5) * 30 + ORIGIN_Y
      coroutine.yield(gd_x, gd_y)
      x = x + x_inc
      y = y + y_inc
    end
  end)
end

local BLOCK_IDS = {
  block                  = 1,
  spike                  = 8,
  high_jump_pad          = 35,
  low_jump_pad           = 140,
  very_high_jump_pad     = 1332,
  gravity_pad            = 67,
  teleport_pad           = 3005,
  high_jump_orb          = 36,
  low_jump_orb           = 141,
  very_high_jump_orb     = 1333,
  gravity_orb            = 84,
  gravity_jump_orb       = 1022,
  drop_orb               = 1330,
  dash_orb               = 1704,
  gravity_dash_orb       = 1751,
  teleport_orb           = 3004,
  normal_gravity_portal  = 10,
  inverse_gravity_portal = 11,
  flip_gravity_portal    = 2926,
  cube_portal            = 12,
  ship_portal            = 13,
  gravity_ball_portal    = 47,
  ufo_portal             = 111,
  wave_portal            = 660,
  robot_portal           = 745,
  spider_portal          = 1331,
  swing_portal           = 1933,
  regular_size_portal    = 99,
  mini_size_portal       = 101,
  dual_portal            = 286,
  solo_portal            = 287,
  slow_speed             = 200,
  base_speed             = 201,
  fast_speed             = 202,
  faster_speed           = 203,
  fastest_speed          = 1334,
}

local SONG_IDS = {
  ["stereo madness"]         = 0,
  ["back on track"]          = 1,
  ["polargeist"]             = 2,
  ["dry out"]                = 3,
  ["base after base"]        = 4,
  ["cant let go"]            = 5,
  ["jumper"]                 = 6,
  ["time machine"]           = 7,
  ["cycles"]                 = 8,
  ["xstep"]                  = 9,
  ["clutterfunk"]            = 10,
  ["theory of everything"]   = 11,
  ["electroman adventures"]  = 12,
  ["clubstep"]               = 13,
  ["electrodynamix"]         = 14,
  ["hexagon force"]          = 15,
  ["blast processing"]       = 16,
  ["theory of everything 2"] = 17,
  ["geometrical dominator"]  = 18,
  ["deadlocked"]             = 19,
  ["fingerdash"]             = 20,
  ["dash"]                   = 21,
}

local function resolve_object(name)
  local id = BLOCK_IDS[name]
  if not id then
    io.stderr:write(string.format("warn: unknown block type '%s', falling back to 'block'\n", name))
    return BLOCK_IDS.block
  end
  return id
end

local function resolve_song(song)
  if song == nil then return "0" end
  local as_num = tonumber(song)
  if as_num then return tostring(as_num) end
  local id = SONG_IDS[song:lower():gsub("%s+", " "):match("^%s*(.-)%s*$")]
  if not id then
    io.stderr:write(string.format("warn: unknown song '%s', falling back to 0\n", s))
    return "0"
  end
  return tostring(id)
end

local Structure = {}
Structure.__index = Structure

function Structure.new(block_type, history)
  local self = setmetatable({
    block_type = block_type or "block",
    start_x = nil,
    start_y = nil,
    end_x = nil,
    end_y = nil,
    rotation = 0,
    mode = "line",
    _history = history
  }, Structure)
  return self
end

function Structure:_commit()
  if self.start_x == nil or self.start_y == nil then return end

  local ex = self.end_x or self.start_x
  local ey = self.end_y or self.start_y
  local block_id = resolve_object(self.block_type)

  local first = true
  local function append_line(x0, y0, x1, y1)
    for x, y in dda(x0, y0, x1, y1) do
      local color_pair = ",21,1004"
      if first then
        color_pair = ""
        first = false
      end

      local obj = string.format("1,%s,2,%s,3,%s,6,%s,155,1%s;", block_id, x, y, self.rotation, color_pair)
      if self._history then
        table.insert(self._history, obj)
      end
    end
  end

  if self.mode == "rect" then
    append_line(self.start_x, self.start_y, ex, self.start_y) -- top
    append_line(self.start_x, ey, self.start_x, self.start_y) -- left
    append_line(ex, self.start_y, ex, ey)                     -- right
    append_line(ex, ey, self.start_x, ey)                     -- bottom
  else
    append_line(self.start_x, self.start_y, ex, ey)
  end
end

function Structure:place_at(x, y)
  self.start_x = x
  self.start_y = y
  return self
end

function Structure:swipe_to(x, y)
  if self.start_x == nil or self.start_y == nil then
    error("can not swipe without a starting point")
  end
  self.end_x = x
  self.end_y = y
  self.mode = "line"
  return self
end

function Structure:rect_to(x, y)
  if self.start_x == nil or self.start_y == nil then
    error("can not swipe without a starting point")
  end
  self.end_x = x
  self.end_y = y
  self.mode = "rect"
  return self
end

function Structure:rotate(degrees)
  -- top = 0, positive for clock-wise
  self.rotation = degrees
  return self
end

local history = {}
local structures = {}

local config = {
  name = "unnamed " .. tostring(os.time(os.date("!*t"))),
  creator = "player",
  song = nil,
}

local dsl_env = {
  struct = function(block_type)
    local s = Structure.new(block_type, history)
    table.insert(structures, s)
    return s
  end,
  config = function(t)
    if t.name then config.name = t.name end
    if t.creator then config.creator = t.creator end
    if t.song then config.song = t.song end
  end
}

local opts = parse_args(arg)
local file = io.open(opts.file, "r")
if file == nil then
  error("file not found: " .. opts.file)
end
local code = file:read('a')
file:close()

local chunk, err = load(code, "@" .. opts.file, "t", dsl_env)
if not chunk then
  error("syntax error in" .. opts.file .. ": " .. err)
end

chunk()

for _, s in ipairs(structures) do
  s:_commit()
end

local GD_HEADER =
"kS38,1_40_2_125_3_255_11_255_12_255_13_255_4_-1_6_1000_7_1_15_1_18_0_8_1|1_0_2_102_3_255_11_255_12_255_13_255_4_-1_6_1001_7_1_15_1_18_0_8_1|1_0_2_102_3_255_11_255_12_255_13_255_4_-1_6_1009_7_1_15_1_18_0_8_1|1_255_2_255_3_255_11_255_12_255_13_255_4_-1_6_1002_5_1_7_1_15_1_18_0_8_1|1_40_2_125_3_255_11_255_12_255_13_255_4_-1_6_1013_7_1_15_1_18_0_8_1|1_40_2_125_3_255_11_255_12_255_13_255_4_-1_6_1014_7_1_15_1_18_0_8_1|1_255_2_0_3_109_11_255_12_255_13_255_4_-1_6_1005_5_1_7_1_15_1_18_0_8_1|1_0_2_255_3_255_11_255_12_255_13_255_4_-1_6_1006_5_1_7_1_15_1_18_0_8_1|1_255_2_255_3_255_11_255_12_255_13_255_4_-1_6_1004_7_1_15_1_18_0_8_1|,kA13,0,kA15,0,kA16,0,kA14,,kA6,0,kA7,0,kA25,0,kA17,0,kA18,0,kS39,0,kA2,0,kA3,0,kA8,0,kA4,0,kA9,0,kA10,0,kA22,0,kA23,0,kA24,0,kA27,1,kA40,1,kA48,1,kA41,1,kA42,1,kA28,0,kA29,0,kA31,1,kA32,1,kA36,0,kA43,0,kA44,0,kA45,1,kA46,0,kA47,0,kA33,1,kA34,1,kA35,0,kA37,1,kA38,1,kA39,1,kA19,0,kA26,0,kA20,0,kA21,0,kA11,0;"

ensure_dir(opts.output_dir)
local out_path = output_path(opts.output_dir, config.name)
local song_id = resolve_song(config.song)
local inner = GD_HEADER .. table.concat(history)

print("total objects: " .. #history)
print("output: " .. out_path)
-- print("inner string: " .. inner)
gmd:export_to_gmd(config.name, config.creator, song_id, inner, #history, out_path)
