# shipped

A Lua-based DSL for procedural Geometry Dash level generation.

## Usage
Create a script (e.g., `code/my_level.lua`) using the `struct` DSL. Define level metadata directly within your script using the `config` function:

```lua
-- my_level.lua
config {
  name = "My Awesome Level",
  creator = "MyName",
  song = "Cycles" -- Supports official song names
}

struct("block"):place_at(0, 0):rect_to(10, 10)
struct("spike"):place_at(5, 5)
