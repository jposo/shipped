# AI Guide for **shipped** DSL

## `config(t)`
Call `config` once (at the top of the script) to set level metadata.

```lua
config {
  name    = "My Level",   -- level name shown in-game (string, default: "unnamed <timestamp>")
  creator = "RobTop",     -- creator name (string, default: "player")
  song    = "deadlocked", -- background music (string name or numeric ID, default: 0)
}
```

### `song` values
String based on one of these built-in official songs.

| Name | ID |
|---|---|
| `stereo madness` | 0 |
| `back on track` | 1 |
| `polargeist` | 2 |
| `dry out` | 3 |
| `base after base` | 4 |
| `cant let go` | 5 |
| `jumper` | 6 |
| `time machine` | 7 |
| `cycles` | 8 |
| `xstep` | 9 |
| `clutterfunk` | 10 |
| `theory of everything` | 11 |
| `electroman adventures` | 12 |
| `clubstep` | 13 |
| `electrodynamix` | 14 |
| `hexagon force` | 15 |
| `blast processing` | 16 |
| `theory of everything 2` | 17 |
| `geometrical dominator` | 18 |
| `deadlocked` | 19 |
| `fingerdash` | 20 |
| `dash` | 21 |

## `struct(block_type)`
Creates a new structure. `block_type` is a string identifying the tile.

**Blocks**
| Name | Description |
|---|---|
| `block` | Standard solid 1×1 block |
| `half_size_block` | Half-size solid block |
| `grid_block_top_edge` | Grid block with top edge detail |
| `grid_block_top_left_corner` | Grid block with top-left corner detail |
| `grid_block_inside_corner` | Grid block with inside corner detail |
| `grid_block_top_left_right_edges` | Grid block with top, left, and right edge details |
| `grid_block_left_right_edges` | Grid block with left and right edge details |

**Hazards**
| Name | Description |
|---|---|
| `spike` | Standard spike, kills on contact |
| `flat_spike` | Flat/low-profile spike |
| `small_spike` | Small spike |
| `ground_spikes` | Ground spike strip |

**Jump Pads** *(activate on contact)*
| Name | Description |
|---|---|
| `low_jump_pad` | Small hop |
| `high_jump_pad` | Standard jump pad |
| `very_high_jump_pad` | Large hop |
| `gravity_pad` | Flips gravity on touch |
| `teleport_pad` | Teleports player |

**Jump Orbs** *(activate on player input while touching)*
| Name | Description |
|---|---|
| `low_jump_orb` | Small hop orb |
| `high_jump_orb` | Standard jump orb |
| `very_high_jump_orb` | Large hop orb |
| `gravity_orb` | Gravity flip orb |
| `gravity_jump_orb` | Jump + gravity flip |
| `drop_orb` | Drops the player |
| `dash_orb` | Dash orb |
| `gravity_dash_orb` | Dash + gravity flip |
| `teleport_orb` | Teleport orb |

**Portals** *(trigger automatically when the player passes through)*
| Name | Description |
|---|---|
| `normal_gravity_portal` | Resets to normal gravity |
| `inverse_gravity_portal` | Inverts gravity |
| `flip_gravity_portal` | Flips gravity |
| `cube_portal` | Switches to cube mode |
| `ship_portal` | Switches to ship mode |
| `gravity_ball_portal` | Switches to ball mode |
| `ufo_portal` | Switches to UFO mode |
| `wave_portal` | Switches to wave mode |
| `robot_portal` | Switches to robot mode |
| `spider_portal` | Switches to spider mode |
| `swing_portal` | Switches to swing mode |
| `regular_size_portal` | Sets player to normal size |
| `mini_size_portal` | Sets player to mini size |
| `dual_portal` | Enables dual mode |
| `solo_portal` | Disables dual mode |

**Speed Portals** *(change the player's horizontal speed)*
| Name | Description |
|---|---|
| `slow_speed` | Slowest speed |
| `base_speed` | Default speed |
| `fast_speed` | Fast |
| `faster_speed` | Faster |
| `fastest_speed` | Maximum speed |

Returns a `Structure` object for chaining.

---

## `:place_at(x, y)`
Sets the starting grid position of the structure. **Required** before any other operation.

---

## `:swipe_to(x, y)`
Draws a straight line from the starting point to `(x, y)` using DDA rasterization. Produces a diagonal, horizontal, or vertical line of tiles.

---

## `:rect_to(x, y)`
Draws the **outline** of a rectangle from the starting point to `(x, y)`. Only the four edges are filled — the interior is empty.

---

## `:rotate(degrees)`
Rotates each tile in the structure by the given number of `degrees`. Default is `0` (upright). Use positive values for clockwise rotation.

> **Note:** Blocks must be rotated in 90° steps (`0`, `90`, `180`, `270`). Spikes accept any degree value.

---

## `:flip_horizontally()` and `:flip_vertically()`
Flips the object on its x-axis or y-axis, respectively.

---

# Coordinate System
Coordinates are exactly how Geometry Dash represents them internally. Each coordinate given is the center of said block. Each block size in the creator grid is 30 units; exactly why most blocks are divisible by `(15, 15)`.

Positive X moves right; positive Y moves up.

Important to leave a couple of blocks between the start of the level, and the start of the gameplay. For example, beginning at `x=195`. You can of course go below this size if you know what you are doing, or are creating some overhead structuring.

---

# Examples

## Three spikes in a horizontal row
```lua
struct("spike")
  :place_at(195, 15)
  :swipe_to(255, 15)
```
Places spikes at grid positions `(75,15)`, `(225,15)`, and `(255,15)`.

---

## A single block
```lua
struct("block")
  :place_at(105, 75)
```
Places one block at `(105, 75)`.

---

## A diagonal line of blocks
```lua
struct("block")
  :place_at(285, 15)
  :swipe_to(405, 135)
```

---

## A rectangular border
```lua
struct("block")
  :place_at(225, 45)
  :rect_to(405, 15)
```
Draws the four edges of a rectangle with corners at `(225,45)`, `(405,45)`, `(405,15)`, and `(225,15)`.

---

## Multiple structures
```lua
-- Floor
struct("block")
  :place_at(195, 15)
  :swipe_to(375, 15)

-- Spike trap on the floor
struct("spike")
  :place_at(315, 45)
  :swipe_to(375, 45)

-- Rotated (ceiling) spikes
struct("spike")
  :place_at(315, 135)
  :swipe_to(375, 135)
  :rotate(180)
  -- could also call :flip_vertically() in this scenario

-- Wall
struct("block")
  :place_at(465, 75)
  :rect_to(465, 225)
```

---

## Using a jump pad and speed portal
```lua
-- Speed up the player
struct("fast_speed")
  :place_at(585, 15)

-- Jump over a 5 spike jump with fast speed (impossible without jump pad)
struct("high_jump_pad")
  :place_at(645, 2) -- placed a little bit above the ground level since pads are short in height
```

---

# Important Considerations

**Player & world:**
- The player spawns at grid coordinates `(0, 15)`.
- The game automatically generates a static, permanent, solid ground across the entire level. The walking surface sits exactly at `y = 0`. You do not need to build a base floor.
- Gameplay is linear — the player continuously moves to the right at a fixed speed.

**Hazard placement:**
- Since the player walks along the top of blocks at `y = 0`, all hazards (spikes, walls, etc.) must be placed starting at `y = 0` so they sit directly on the floor.
- Ceiling hazards should be placed at a height the player can actually reach for blocking purposes.

**Jump & movement limits (at base speed, cube gamemode):**
- The player can realistically jump over 3 spikes horizontally at base speed, 2 spikes on slow speed, 4 spikes at fast speed, 5 spikes at faster speed, and 6 spikes at fastest speed.
- The player can jump 2 blocks high.
- Orbs are activated by player input, not automatically — they must be reachable and timed to feel fair.

**Portals:**
- Gamemode portals (cube, ship, wave, etc.) should be given ample horizontal space before the next obstacle so the player can adjust.
- Size portals (`mini_size_portal`, `regular_size_portal`) affect the player's hitbox — mini is more forgiving in tight spaces.
- Gravity portals (`normal_gravity_portal`, `inverse_gravity_portal`, `flip_gravity_portal`) should be paired with appropriate ceiling/floor geometry on the inverted side.
- Speed portals affect how far the player travels per jump — adjust obstacle spacing accordingly when changing speed.
- Dual portal splits the player into two icons; both must survive, so obstacles must be passable by both simultaneously.

**Rotation:**
- Blocks must be rotated at a 90-step degree angle (`0`, `90`, `180`, `270`).
- Spikes are unlocked and can be rotated to any degree.

**General:**
- All structures are accumulated and written into the same level file.
- Each `struct()` call produces an independent chain; order matters for visual layering but not for collision.
