# AI Guide: Geometry Dash Level DSL

This document describes the DSL (domain-specific language) used to build Geometry Dash levels programmatically. Use it to understand the syntax, available objects, and how to generate valid level scripts.

---

## Overview

Level scripts are Lua files executed inside a sandboxed environment. Only two globals are available: `struct` and `config`. Everything else (standard Lua libs, IO, etc.) is unavailable to the script.

The script's job is to declare structures that place blocks into the level. When the script finishes, each structure is committed and serialized into a `.gmd` file.

---

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

Either a numeric Newgrounds/custom song ID, or one of these built-in name strings (case-insensitive):

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

---

## `struct(block_type)`

Creates a new structure and returns a builder object. Methods are chainable.

```lua
struct("block")
  :place_at(0, 0)
  :swipe_to(10, 0)
```

### Coordinate system

- Coordinates are in **grid units** (integers). The origin `(0, 0)` maps to pixel position `(15, 15)`.
- Each grid unit is **30 pixels**.
- `x` increases to the right; `y` increases downward (standard GD layout).

---

## Builder Methods

All methods return `self` and are chainable.

### `:place_at(x, y)`

Sets the starting grid position of the structure. **Required** before any draw method.

```lua
struct("spike"):place_at(5, 3)
```

### `:swipe_to(x, y)`

Draws a straight line of blocks from the start point to `(x, y)` using DDA rasterization. Produces a diagonal, horizontal, or vertical line.

```lua
struct("block"):place_at(0, 5):swipe_to(20, 5)  -- horizontal floor
struct("block"):place_at(4, 0):swipe_to(4, 8)   -- vertical wall
struct("block"):place_at(0, 0):swipe_to(5, 5)   -- diagonal
```

### `:rect_to(x, y)`

Draws the four edges of a rectangle with corners at `(start_x, start_y)` and `(x, y)`. Does **not** fill the interior.

```lua
struct("block"):place_at(0, 0):rect_to(10, 6)
```

### `:rotate(degrees)`

Sets the rotation of every block in the structure. `0` is upright. Positive values rotate clockwise.

```lua
struct("spike"):place_at(3, 3):rotate(180)  -- upside-down spike
```

> **Note:** Calling `:place_at` alone (with no `:swipe_to` or `:rect_to`) places a single block at the given position.

---

## Block Types

Pass the string name to `struct(...)`. Unknown names fall back to `"block"` with a warning.

### Terrain
| Name | Description |
|---|---|
| `block` | Standard solid block |
| `spike` | Kills the player on contact |

### Jump Pads (floor triggers)
| Name | Description |
|---|---|
| `low_jump_pad` | Small hop |
| `high_jump_pad` | Standard jump pad |
| `very_high_jump_pad` | Large hop |
| `gravity_pad` | Flips gravity on touch |
| `teleport_pad` | Teleports player |

### Orbs (click triggers)
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

### Portals
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

### Speed Portals
| Name | Description |
|---|---|
| `slow_speed` | Slowest speed |
| `base_speed` | Default speed |
| `fast_speed` | Fast |
| `faster_speed` | Faster |
| `fastest_speed` | Maximum speed |

---

## Running the Compiler

```bash
lua main.lua <script.lua> [--output DIR]
```

- `<script.lua>` — path to your level script (required)
- `--output DIR` / `-o DIR` — output directory (default: `builds/`)

The output is a `.gmd` file named after `config.name`, placed in the output directory. The filename is sanitized (non-alphanumeric characters become `_`).

---

## Complete Example

```lua
config {
  name    = "Tutorial",
  creator = "MyName",
  song    = "stereo madness",
}

-- Ground floor
struct("block"):place_at(0, 8):swipe_to(40, 8)

-- A small enclosure
struct("block"):place_at(5, 4):rect_to(10, 7)

-- Some hazards
struct("spike"):place_at(12, 7)
struct("spike"):place_at(13, 7)
struct("spike"):place_at(14, 7)

-- A jump pad before the spikes
struct("high_jump_pad"):place_at(10, 8)

-- Upside-down spikes on a ceiling section
struct("block"):place_at(16, 0):swipe_to(25, 0)
struct("spike"):place_at(18, 0):rotate(180)
struct("spike"):place_at(19, 0):rotate(180)

-- Gamemode change
struct("ship_portal"):place_at(26, 7)
struct("cube_portal"):place_at(36, 7)

-- Speed change
struct("fast_speed"):place_at(0, 7)
```

---

## Tips for AI Generation

- Always call `config` before any `struct` calls.
- Place a continuous ground line first: `struct("block"):place_at(0, 8):swipe_to(N, 8)`.
- Spikes sit **on top of** the ground, so their `y` should equal `ground_y - 1`.
- Jump pads and orbs are placed **at the same y as the ground** (they sit on it).
- Portals are typically placed one unit above the ground (`ground_y - 1`) so the player walks through them.
- `:place_at(x, y)` with no follow-up method places exactly one block — useful for single objects like portals or orbs.
- Rotations for ceiling spikes: `180`. For left-facing: `270`. For right-facing: `90`.
