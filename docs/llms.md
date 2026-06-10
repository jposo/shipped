# Geometry Dash Editor Reference Guide (DSL Real-World Coordinates)

This document serves as an exhaustive reference blueprint for runtime AI agents interacting with the `shipped` Geometry Dash Domain-Specific Language (DSL) execution environment. 

To bypass the game's arbitrary grid system and align seamlessly with absolute Cartesian environments, all physical dimensions, layout metrics, travel rates, and jump heights below are expressed in **Real-World Units**. The conversion follows a strict linear scale factor of **30** (i.e., $1 \\text{ game grid unit} = 30 \\text{ real-world coordinate units}$).

---

## 1. Core Core DSL Interface & Lifecycle

The DSL interpreter operates via sandboxed global environment functions. Level construction scripts chain modification properties against mutable structure objects before a final serializing commit loop.

### `config(table)`
Defines global metadata fields parsed directly by the file header generation pass.

```lua
config {
  name    = "Geometric Core",   -- The final string name of the exported level file
  creator = "DSL_Agent_v1",     -- Registered author metadata name
  song    = "deadlocked",       -- Decoded string name or an absolute numeric ID string
}
```

#### Song Metadata Reference Matrix

If an arbitrary string key is supplied, the compiler checks the internal lookup registry. Unregistered tracks fallback automatically to ID `"0"`.

| Song String Key | Mapped Track ID |  | Song String Key | Mapped Track ID |
| --- | --- | --- | --- | --- |
| `"stereo madness"` | `0` |  | `"electroman adventures"` | `12` |
| `"back on track"` | `1` |  | `"clubstep"` | `13` |
| `"polargeist"` | `2` |  | `"electrodynamix"` | `14` |
| `"dry out"` | `3` |  | `"hexagon force"` | `15` |
| `"base after base"` | `4` |  | `"blast processing"` | `16` |
| `"cant let go"` | `5` |  | `"theory of everything 2"` | `17` |
| `"jumper"` | `6` |  | `"geometrical dominator"` | `18` |
| `"time machine"` | `7` |  | `"deadlocked"` | `19` |
| `"cycles"` | `8` |  | `"fingerdash"` | `20` |
| `"xstep"` | `9` |  | `"dash"` | `21` |
| `"clutterfunk"` | `10` |  |  |  |
| `"theory of everything"` | `11` |  |  |  |

### `struct(block_type)`

Instantiates a new geometric structure entity inside the global history collector tracking a single underlying target block ID.

* **Supported Block Elements (`block_type`):**
* *Standard Solids:* `"block"`, `"half_size_block"`, `"grid_block_top_edge"`, `"grid_block_top_left_corner"`, `"grid_block_inside_corner"`, `"grid_block_top_left_right_edges"`, `"grid_block_left_right_edges"`
* *Hazards:* `"spike"`, `"flat_spike"`, `"small_spike"`, `"ground_spikes"`
* *Jump Pads:* `"low_jump_pad"`, `"high_jump_pad"`, `"very_high_jump_pad"`, `"gravity_pad"`, `"teleport_pad"`
* *Jump Orbs:* `"low_jump_orb"`, `"high_jump_orb"`, `"very_high_jump_orb"`, `"gravity_orb"`, `"gravity_jump_orb"`, `"drop_orb"`, `"dash_orb"`, `"gravity_dash_orb"`, `"teleport_orb"`
* *Portals:* `"normal_gravity_portal"`, `"inverse_gravity_portal"`, `"flip_gravity_portal"`, `"cube_portal"`, `"ship_portal"`, `"gravity_ball_portal"`, `"ufo_portal"`, `"wave_portal"`, `"robot_portal"`, `"spider_portal"`, `"swing_portal"`
* *Speed Portals:* `"slow_speed"`, `"base_speed"`, `"fast_speed"`, `"faster_speed"`, `"fastest_speed"`


#### Method Chaining Chains

Every method call on a structure mutates internal properties and returns `self` for continuous, fluent API scripting:

```lua
-- Single coordinate point placement
struct("block"):place_at(150, 90)

-- Linear sequence generation utilizing line interpolation
struct("spike"):place_at(300, 0):swipe_to(600, 0)

-- Perimeter boundary line frame generation
struct("grid_block_top_edge"):place_at(0, 0):rect_to(90, 90)

-- Transform state attributes applied on interpolation steps
struct("high_jump_pad"):place_at(450, 30):rotate(90):flip_horizontally():flip_vertically()

```

---

## 2. Technical Map Dimensions & Boundaries

Spatial constraints map directly to real-world Cartesian units across all structural placement routines.

* **Bounding Box Asset Size:** A standard 1×1 tile entity possesses precise spatial dimensions of **30 × 30 units**.
* **Red Jump Pad Collision Footprint:** The asset boundary slightly expands past its localized ground placement matrix, cutting marginally below its nominal vertical **30-unit** limit.
* **Camera Viewport Workspace Constraints:** Certain game modes enforce absolute vertical clipping ceilings. Layout positioning data outside these thresholds will result in broken gameplay mechanics or camera failures:
* *Ball Mode:* Active layout boundary matches a vertical channel height of **240 units**.
* *Spider Mode:* Active layout boundary matches a vertical channel height of **270 units**.
* *Ship, UFO, Wave, Swing Modes:* Active layout boundary matches a vertical channel height of **300 units**.
* *Dual Mode Layout Matrix:* If any active duplicate icon is running a Ship, UFO, Wave, or Swing asset, the level workspace ceiling is locked to **300 units**. If neither active icon uses those flying variants, the grid shifts downward and locks to a strict **270 units**.
* *Cube & Robot Modes:* Carry no structural vertical limits, allowing infinite vertical extensions without grid lock corrections.

---

## 3. Horizontal Travel Rates & Speed Vectors

Horizontal displacement depends explicitly on active speed portal states. When planning structural intervals, spatial distance between layout elements must scale based on these absolute execution velocities:

| Speed Mapped Item | Scale Factor | Real-World Horizontal Velocity (Units / Second) |
| --- | --- | --- |
| **Slow Speed Portal** (`-`) | ~0.807× | 251.16 units/sec |
| **Normal Speed Portal** (`+`) | 1.000× | 311.58 units/sec |
| **Fast Speed Portal** (`++`) | ~1.243× | 387.42 units/sec |
| **Very Fast Speed Portal** (`+++`) | ~1.502× | 468.00 units/sec |
| **Extremely Fast Speed Portal** (`++++`) | ~1.849× | 576.00 units/sec |

---

## 4. Transporter Trajectory & Jump Mechanics

Transporters manipulate internal physics vectors upon collision or click confirmation inputs.

* **Jump Pads:** Trigger automation instantaneously the moment the icon's collision mask intersects the asset boundary.
* **Jump Orbs:** Remain dormant upon collision until explicit player input is validated while intersecting the interaction radius.

### Mapped Jump Heights Matrix (Absolute Real-World Units)

The values listed below document the precise vertical displacement trajectories achieved by the icon from the baseline floor plane. Variance thresholds dictated by momentum entry states are supplied within parentheses.

#### Jump Pads (Contact-Driven Translation)

| Mapped Name | Cube | Ship | Ball | UFO | Robot | Spider | Swing |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **`low_jump_pad`** | 57.99 *(34.98)* | 34.98 *(19.50)* | 38.50 *(54.50)* | 36.00 *(19.50)* | 64.10 *(39.00)* | 35.50 *(22.50)* | 47.70 *(21.00)* |
| **`high_jump_pad`** | 135.99 *(93.99)* | 78.50 *(94.98)* | 85.50 *(49.80)* | 60.00 *(75.50)* | 135.99 *(108.50)* | 82.50 *(48.50)* | 85.50 *(78.51)* |
| **`very_high_jump_pad`** | 195.99 *(135.99)* | 126.99 *(68.50)* | 135.99 *(87.00)* | 88.50 *(43.98)* | 222.99 *(135.99)* | 135.99 *(84.99)* | 187.50 |

* **`gravity_pad` (Cyan Gravity):** Instantly flips the current gravity direction vector upon physical contact.
* **`teleport_pad` (Spider Pad):** Instantly translates the player icon to the nearest valid collision surface lying directly along its path line, applying spatial orientation flipping if necessary.

#### Jump Orbs (Input-Driven Translation)

| Mapped Name | Cube | Ship | Ball | UFO | Robot | Spider | Swing |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **`low_jump_orb`** | 32.50 *(20.50)* | 27.00 *(16.98)* | 30.50 *(19.50)* | 19.80 *(10.98)* | 36.50 *(22.98)* | 23.50 *(15.00)* | 30.00 *(12.60)* |
| **`high_jump_orb`** | 71.50 *(40.50)* | 85.50 *(105.0)* | 51.99 *(33.00)* | 63.00 *(66.00)* | 63.00 *(36.50)* | 48.99 *(31.50)* | 58.50 *(27.30)* |
| **`very_high_jump_orb`** | 135.99 *(85.98)* | 135.99 *(105.0)* | 109.80 *(67.98)* | 129.00 *(69.50)* | 132.99 *(82.50)* | 106.98 *(63.99)* | 108.60 *(46.50)* |

* **`gravity_orb` (Cyan Gravity):** Swaps the orientation of the layout gravity vector, actively pulling the icon toward the opposing roof or floor line.
* **`gravity_jump_orb` (Green Gravity Jump):** Flips the active layout gravity vector while applying an immediate localized jump force in that new direction. Trajectory heights scale dynamically based on the vertical entry velocity vector. Average baseline readings equal **58.75 units *(36.38 units)*** inside Cube configurations, and **≤60.90 units *(≤33.50 units)*** inside flying Ship structures.
* **`drop_orb` (Black Drop):** Overrides momentum states to forcefully accelerate the player downwards. Has zero physical effect on an icon moving along solid floor points.
* **`dash_orb` (Green Dash):** Cancels all downward gravity pull and forces the player along a persistent straight coordinate ray. In standard gameplay, this ray can be oriented inside the layout definition across angles up to **±70°** while preserving underlying horizontal velocity calculations.
* **`gravity_dash_orb` (Magenta Dash):** Suspends standard physics vectors to drive the icon along a direct linear tracking ray, automatically applying a permanent gravity inversion immediately upon releasing input.
* **`teleport_orb` (Spider Orb):** Teleports the icon to the closest structural collision zone matching the target trajectory plane.

---

## 5. Gamemode Portal Trajectories

Form portals alter basic physics engines, input tracking configurations, and baseline jump trajectories.

* **`cube_portal`:** Reverts level layout tracking to the standard framework. Standard floor jump input generates a basic profile of **64.00 units**, extending to **66.99 units** with sustained input. Mini variants track an abbreviated profile height of **40.75 units** (extending up to **43.05 units**).
* **`ship_portal`:** Initializes free-flying physics vectors. Holding inputs applies a smooth upward propulsion force, and dropping the input allows gravity to smoothly drag the icon back down. Mini variants possess significantly high vertical weight characteristics, generating rapid ascent/descent cycles.
* **`gravity_ball_portal`:** Remaps input signals. Pressing input instantly alters the directional gravity state, shooting the ball straight toward the opposing roof or floor boundary.
* **`ufo_portal`:** Controls discrete multi-hop aviation increments. Standard inputs trigger air hops measuring **47.00 units**. Mini variants produce tighter vertical air arcs measuring **36.00 units** alongside high gravitational drag coefficients.
* **`wave_portal`:** Restricts motion vectors to absolute diagonal lines. Sustained input drives the wave along a strict upward vector, and releasing inputs instantly turns it along a strict downward vector:
* *Standard Wave Target Vector:* Slope = $\pm 1$ ($\pm 45^\circ$)
* *Mini Wave Target Vector:* Slope = $\pm 2$ ($\sim \pm 63.435^\circ$)


* **`robot_portal`:** Maps variable height outputs directly matching input holding thresholds. Quick taps yield minor floor micro-hops, while continuous holding drives vertical translation to a maximum peak of **105.33 units**. Mini variants track an operational ceiling capped at **83.00 units**.
* **`spider_portal`:** Instantly teleports the active icon directly onto the nearest top or bottom collision boundary plane, completely dropping standard physical transition intervals.
* **`swing_portal`:** Initializes continuous dual-state aviation mapping. Each independent input tap flips the underlying physics gravity axis back and forth across space, allowing full vertical traversal without requiring structural floor contact.

---

## 6. Layout Automation Rules & Compilation Insights

* **Wave Physics Exclusions:** Wave vectors strictly block physical translation alterations from standard `"low_jump_pad"`, `"high_jump_pad"`, `"very_high_jump_pad"`, `"low_jump_orb"`, `"high_jump_orb"`, and `"very_high_jump_orb"` assets. While passing through their intersection boxes still executes their decorative trigger pulse animations, the wave's velocity remains unchanged. However, gravity-altering objects, `"dash_orb"`, `"gravity_dash_orb"`, and all spider items operate as expected.
* **Multi-Activation Parameters:** Objects compiled with explicit multi-activation can accept inputs multiple times without requiring resetting transitions. This property is vital for structures tracking moving components or complex platformer layout paths.
