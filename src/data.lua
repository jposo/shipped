local data = {}

data.ORIGIN_X = 15
data.ORIGIN_Y = 15

data.BLOCK_IDS = {
    block                           = 1,
    grid_block_top_edge             = 2,
    grid_block_top_left_corner      = 3,
    grid_block_inside_corner        = 4,
    grid_block_top_left_right_edges = 6,
    grid_block_left_right_edges     = 7,
    half_size_block                 = 40,
    ground_spikes                   = 1715,
    spike                           = 8,
    flat_spike                      = 39,
    small_spike                     = 103,
    high_jump_pad                   = 35,
    low_jump_pad                    = 140,
    very_high_jump_pad              = 1332,
    gravity_pad                     = 67,
    teleport_pad                    = 3005,
    high_jump_orb                   = 36,
    low_jump_orb                    = 141,
    very_high_jump_orb              = 1333,
    gravity_orb                     = 84,
    gravity_jump_orb                = 1022,
    drop_orb                        = 1330,
    dash_orb                        = 1704,
    gravity_dash_orb                = 1751,
    teleport_orb                    = 3004,
    normal_gravity_portal           = 10,
    inverse_gravity_portal          = 11,
    flip_gravity_portal             = 2926,
    cube_portal                     = 12,
    ship_portal                     = 13,
    gravity_ball_portal             = 47,
    ufo_portal                      = 111,
    wave_portal                     = 660,
    robot_portal                    = 745,
    spider_portal                   = 1331,
    swing_portal                    = 1933,
    regular_size_portal             = 99,
    mini_size_portal                = 101,
    dual_portal                     = 286,
    solo_portal                     = 287,
    slow_speed                      = 200,
    base_speed                      = 201,
    fast_speed                      = 202,
    faster_speed                    = 203,
    fastest_speed                   = 1334,
}

data.SONG_IDS = {
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


-- block reverse lookup
data.BLOCK_NAMES = {}
for name, id in pairs(data.BLOCK_IDS) do
    data.BLOCK_NAMES[id] = name
end

-- song reverse lookup
data.SONG_NAMES = {}
for name, id in pairs(data.SONG_IDS) do
    data.SONG_NAMES[tostring(id)] = name
end

return data
