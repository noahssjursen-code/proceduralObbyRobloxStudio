# Segment Filler System

A repository-based system for filling PathSegments with procedural content.

---

## **📋 How It Works**

```
PathSegment (Bounding Box) → Select Random Filler → Build Content Inside
```

### Flow:
1. **World generates PathSegments** (transparent bounding boxes)
2. **Server looks at segment type** (Short, Medium, Long, Wide, Narrow)
3. **Picks random filler** from the repository for that type
4. **Builds content** inside the segment bounds

---

## **📁 Repository Structure**

```
shared/Definitions/Fillers/
  FillerTypes.luau              ← Type definitions
  FillerBuilder.luau            ← Builds fillers inside segments
  ShortSegmentFillers.luau      ← Fillers for Short segments
  MediumSegmentFillers.luau     ← Fillers for Medium segments
  LongSegmentFillers.luau       ← Fillers for Long segments
  WideSegmentFillers.luau       ← Fillers for Wide segments
  NarrowSegmentFillers.luau     ← Fillers for Narrow segments
```

Each file contains **multiple filler options** for that segment type.

---

## **🏗️ Creating a Filler**

### 1. Define the Builder Function

```lua
local function BuildMyObby(
    segmentPosition: Vector3,    -- Center of segment
    segmentScale: Vector3,        -- Width x Height x Length
    segmentRotation: Vector3,     -- Rotation in degrees
    worldScale: number,           -- Current world scale
    rng: Random                   -- Deterministic RNG
): Instance
    local model = Instance.new("Model")
    model.Name = "MyObby"
    
    -- Example: Create platforms along segment length
    local width = segmentScale.X
    local length = segmentScale.Z
    local yaw = math.rad(segmentRotation.Y)
    
    for i = 1, 5 do
        local platform = Instance.new("Part")
        platform.Size = Vector3.new(width * 0.8, 2, length / 6)
        platform.Anchored = true
        platform.CanCollide = true
        
        -- Position along segment
        local t = (i - 1) / 4  -- 0 to 1
        local offset = (t - 0.5) * length * 0.8
        local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(0, 0, offset)
        
        platform.CFrame = CFrame.new(segmentPosition + localOffset) * CFrame.Angles(0, yaw, 0)
        platform.Parent = model
    end
    
    return model
end
```

### 2. Create the Filler Definition

```lua
-- In ShortSegmentFillers.luau

ShortSegmentFillers.MyObby = {
    ID = "MyObby_Short",
    DisplayName = "My Custom Obby",
    CompatibleSegmentTypes = {"Short"},  -- What segments this works with
    
    SpawnWeight = 25,  -- Higher = more common (0-100)
    MinScale = 5,      -- Optional: only spawn at scale 5+
    MaxScale = 50,     -- Optional: only spawn below scale 50
    
    BuilderFunction = BuildMyObby,
}
```

### 3. Add to Registry

```lua
function ShortSegmentFillers.GetAll(): {FillerDefinition}
    return {
        ShortSegmentFillers.SimplePlatform,
        ShortSegmentFillers.TripleJump,
        ShortSegmentFillers.MyObby,  -- ADD HERE
    }
end
```

**That's it!** Your obby will now randomly spawn in Short segments.

---

## **🎲 Selection Logic**

Fillers are chosen using **weighted random selection**:

```lua
SimplePlatform: SpawnWeight = 50  →  50% chance
TripleJump:     SpawnWeight = 30  →  30% chance
MyObby:         SpawnWeight = 20  →  20% chance
```

**Scale Constraints:**
- Only fillers within `MinScale` to `MaxScale` are considered
- Useful for ensuring small obbies don't spawn at huge scales

---

## **🔧 Available Segment Types**

| Segment Type | Default Length | Default Width | Best For |
|--------------|---------------|---------------|----------|
| **Short**    | 10 studs      | 8 studs       | Quick jumps, simple obstacles |
| **Medium**   | 20 studs      | 8 studs       | Multi-platform challenges |
| **Long**     | 40 studs      | 8 studs       | Running gauntlets, races |
| **Wide**     | 15 studs      | 12 studs      | Wide platforms, free movement |
| **Narrow**   | 12 studs      | 5 studs       | Tightropes, precision jumps |

*(Lengths scale with WorldScale)*

---

## **📦 Using Segment Bounds**

The filler receives the segment's bounding box:

```lua
segmentScale = Vector3.new(width, height, length)
```

**Tips:**
- Use **90% of width/length** to leave gaps at edges
- Use **segmentRotation** to orient parts correctly
- **Height** is mostly for visualization (actual platforms can be any height)

### Rotation Example:

```lua
local yaw = math.rad(segmentRotation.Y)

-- Create a platform facing the correct direction
platform.CFrame = CFrame.new(position) * CFrame.Angles(0, yaw, 0)

-- Offset along the segment's forward direction
local forwardOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(0, 0, distance)
local newPosition = position + forwardOffset
```

---

## **✨ Examples Included**

### Short Segments:
1. **SimplePlatform** - Single flat platform (50% spawn rate)
2. **TripleJump** - Three platforms with gaps (30% spawn rate)
3. **ZigzagPath** - Alternating left/right platforms (20% spawn rate)

### Medium Segments:
1. **SimplePlatform** - Single flat platform (100% spawn rate)

---

## **🚀 Adding New Segment Types**

Create `LongSegmentFillers.luau`:

```lua
local LongSegmentFillers = {}

local function BuildSpeedRun(segmentPosition, segmentScale, segmentRotation, worldScale, rng)
    -- Build a long gauntlet with speed boosts
end

LongSegmentFillers.SpeedRun = {
    ID = "SpeedRun_Long",
    DisplayName = "Speed Run",
    CompatibleSegmentTypes = {"Long"},
    SpawnWeight = 50,
    BuilderFunction = BuildSpeedRun,
}

function LongSegmentFillers.GetAll()
    return { LongSegmentFillers.SpeedRun }
end

function LongSegmentFillers.SelectRandom(rng, currentScale)
    -- Selection logic
end

return LongSegmentFillers
```

Then import and use in `WorldGenerationServer.luau`.

---

## **💡 Future: Parameter-Based Selection**

Currently: Random selection by weight.

**Later you can add:**
```lua
function SelectByDifficulty(difficulty: number)
    -- Pick harder obbies at higher difficulty
end

function SelectByBiome(biome: string)
    -- Ice biome = slippery platforms
    -- Lava biome = moving platforms
end
```

---

## **🎮 Design Tips**

1. **Always use the segment bounds** - Don't hardcode sizes
2. **Respect rotation** - Use `segmentRotation.Y` to orient parts
3. **Scale awareness** - Everything auto-scales with WorldScale
4. **Deterministic** - Use provided `rng`, not `math.random()`
5. **Test at multiple scales** - Your obby should work at 1x and 30x
6. **Leave edge gaps** - Use 80-90% of width/length for visual separation

---

**This system is plug-and-play!** Add as many fillers as you want, and they'll automatically integrate into the world generation.

