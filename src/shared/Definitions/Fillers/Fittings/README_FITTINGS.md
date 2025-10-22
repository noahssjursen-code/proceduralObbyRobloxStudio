# Fittings System - Blueprint & Guidelines

## What is a Fitting?

A **fitting** is a reusable, procedurally-generated obstacle or path design that fills a segment's bounding box. Each fitting is self-contained and creates a complete, traversable challenge from the segment's start to end.

---

## Standardized Pattern

### File Structure
```
src/shared/Definitions/Fillers/Fittings/
├── README_FITTINGS.md          (this file)
├── _TEMPLATE.luau              (copy this to start new fittings)
├── LavaJump.luau
├── ZigzagBridge.luau
└── [YourNewFitting].luau
```

### Module Structure (Required)

```lua
--[[
	[Fitting Name] Fitting
	
	[Brief description of what this fitting does]
	[Any special notes about difficulty, requirements, etc.]
]]

local FittingName = {}

FittingName.ID = "FittingName"  -- Must be unique
FittingName.DisplayName = "Fitting Name"  -- Human-readable

function FittingName.Build(
	segmentPosition: Vector3,   -- Center of the segment
	segmentScale: Vector3,      -- X=width, Y=height, Z=length (ALREADY SCALED)
	segmentRotation: Vector3,   -- Euler angles (Y=yaw is most important)
	worldScale: number,         -- Global scale multiplier (usually 10)
	rng: Random                 -- Seeded RNG for deterministic generation
): Instance
	local model = Instance.new("Model")
	model.Name = "FittingName"
	
	-- Extract segment dimensions (these are ALREADY scaled by worldScale!)
	local width = segmentScale.X
	local length = segmentScale.Z
	local height = segmentScale.Y
	local yaw = math.rad(segmentRotation.Y)  -- Convert to radians
	
	-- YOUR CODE HERE
	-- Build your obstacle/path inside the segment bounds
	
	return model
end

return FittingName
```

---

## Critical Rules

### 1. **Start & End Connection Points**
✅ **MUST** have clear entry at segment start (`-length * 0.5`)  
✅ **MUST** have clear exit at segment end (`length * 0.5`)  
✅ Players should be able to traverse from start to end

**Example:**
```lua
-- Always create start platform
local startPlatform = Instance.new("Part")
-- Position at segment entrance
local startOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(0, 0, -length * 0.5)
startPlatform.CFrame = CFrame.new(segmentPosition + startOffset) * CFrame.Angles(0, yaw, 0)
```

### 2. **Player-Scale Values**
⚠️ **DO NOT** multiply player-comfort dimensions by `worldScale`!

The segment's `segmentScale` is **already scaled**. Any new values you create that relate to player size should use absolute values:

```lua
-- ✅ CORRECT - Player-scale constants
local jumpDistance = 6           -- Comfortable jump for player
local platformRadius = 2.5       -- Platform size relative to player
local bridgeWidth = 2            -- Width player can walk on

-- ❌ WRONG - Don't do this!
local jumpDistance = 6 * worldScale    -- NO! This double-scales
```

### 3. **Use the Segment Bounds**
Your fitting should respect the segment's bounding box:
- Width: `-width/2` to `width/2`
- Length: `-length/2` to `length/2`
- Height: Available vertical space

### 4. **Coordinate System**
- **Forward/Backward** = Z-axis (length)
- **Left/Right** = X-axis (width)
- **Up/Down** = Y-axis (height)
- **Rotation** = Apply `yaw` to align with segment direction

**Positioning helper:**
```lua
-- Convert local offset to world position
local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
local worldPosition = segmentPosition + localOffset

-- Create part at world position with proper rotation
part.CFrame = CFrame.new(worldPosition) * CFrame.Angles(0, yaw, 0)
```

### 5. **Use RNG for Variation**
Always use the provided `rng` parameter (never `math.random()`) for deterministic, seeded generation:

```lua
local randomLength = rng:NextNumber(5, 9)        -- Random float
local randomCount = rng:NextInteger(3, 7)        -- Random integer
local randomChoice = rng:NextInteger(1, #choices)  -- Pick from array
```

---

## Deadly Parts

To make parts that kill the player on contact:

```lua
part:SetAttribute("Deadly", true)
part:SetAttribute("DamageType", "Lava")  -- or "Void", "Spike", etc.
```

The `DamageManagerServer` will automatically handle player deaths.

---

## Best Practices

### Visual Clarity
- Use distinct colors for different part types
- Deadly parts should be RED or obviously dangerous
- Safe platforms should be GRAY or clearly walkable
- Use materials that make sense (`Enum.Material.Wood`, `SmoothPlastic`, etc.)

### Difficulty Balance
- Consider the segment type (Short/Medium/Long/Wide/Narrow)
- Longer segments = more challenge/variation
- Narrow segments = precision-based
- Wide segments = more freedom/options

### Performance
- Anchor all parts (`part.Anchored = true`)
- Use simple shapes when possible
- Avoid excessive part counts (aim for <50 parts per fitting)

### Naming
- Name your model and parts clearly
- Use descriptive names: `"StartPlatform"`, `"BridgeSection1"`, `"Lava"`

---

## Template Checklist

When creating a new fitting:

- [ ] Copy `_TEMPLATE.luau` and rename it
- [ ] Update `ID` and `DisplayName`
- [ ] Write description comment
- [ ] Implement `Build()` function
- [ ] Create START connection point
- [ ] Create END connection point
- [ ] Use player-scale values correctly
- [ ] Use `rng` for all randomness
- [ ] Test with different segment sizes
- [ ] Register in appropriate `SegmentFillers` file
- [ ] Set appropriate `SpawnWeight`

---

## Segment Types Reference

Fittings are registered to specific segment types in `SegmentFillers` files:

| Segment Type | Dimensions | Best For |
|-------------|------------|----------|
| **Short** | Brief segments | Quick challenges, simple jumps |
| **Medium** | Standard length | Balanced obstacles, multiple platforms |
| **Long** | Extended segments | Complex challenges, rhythm sections |
| **Wide** | Extra width | Multiple paths, freedom of movement |
| **Narrow** | Constrained width | Precision, tight paths, balance |

---

## Example Fittings

### Simple (Good for learning)
- **SimplePlatform**: Single wide platform (deleted, but was basic)
- Basic bridge
- Staircase

### Medium Complexity
- **ZigzagBridge**: Connected sections with lateral movement
- **LavaJump**: Death floor + safe platforms

### Complex (Advanced)
- Moving obstacles
- Timed challenges
- Multi-path systems

---

## Registering Your Fitting

After creating your fitting, register it in the appropriate segment filler:

```lua
-- In MediumSegmentFillers.luau
local LavaJump = require(script.Parent.Fittings.LavaJump)
local YourNewFitting = require(script.Parent.Fittings.YourNewFitting)

local FILLERS: { FillerDefinition } = {
	{ Fitting = LavaJump, SpawnWeight = 100 },
	{ Fitting = YourNewFitting, SpawnWeight = 50 },  -- Lower weight = less common
}
```

---

## Common Pitfalls

### ❌ Double-scaling player values
```lua
-- WRONG
local jumpDist = 6 * worldScale  -- Segment is already scaled!
```

### ❌ Using math.random()
```lua
-- WRONG
local random = math.random(1, 10)  -- Not deterministic!

-- CORRECT
local random = rng:NextInteger(1, 10)
```

### ❌ Forgetting rotation
```lua
-- WRONG
part.Position = segmentPosition + Vector3.new(x, y, z)  -- Doesn't respect segment direction!

-- CORRECT
local offset = CFrame.Angles(0, yaw, 0) * Vector3.new(x, y, z)
part.CFrame = CFrame.new(segmentPosition + offset) * CFrame.Angles(0, yaw, 0)
```

### ❌ No start/end connection
```lua
-- WRONG - Platforms only in middle, player can't enter/exit!

-- CORRECT - Always create entry and exit points
```

---

## Need Help?

- Look at existing fittings (`LavaJump.luau`, `ZigzagBridge.luau`)
- Copy the `_TEMPLATE.luau` file
- Follow the checklist above
- Test with different segment types

Happy fitting! 🎮
