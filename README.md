# shipped

A Lua-based DSL for procedural Geometry Dash level generation.

## Usage

### Using DSL
Create a script (e.g., `code/my_level.lua`) using the `struct` DSL. Define level metadata directly within your script using the `config` function:

```lua
-- my_level.lua
config {
  name = "My Awesome Level",
  creator = "MyName",
  song = "Cycles" -- Supports official song names
}

struct("block"):place_at(75, 15):rect_to(105, 15)
struct("spike"):place_at(75, 45)
```
You can then run the script.
```bash
lua compile.lua code/my_level.lua
```
Can also take in `-o` flag to output to a given directory.
```bash
lua compile.lua code/my_level.lua -o path/to/builds
```

### Decompile Levels
Given a `.gmd` file, it will output a `.lua` following the DSL specifications.

```bash
lua decompile.lua builds/Stereo_Madness.gmd
```
