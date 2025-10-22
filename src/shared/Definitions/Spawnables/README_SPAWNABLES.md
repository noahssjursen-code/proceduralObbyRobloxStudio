# Spawnable System

A fully procedural, code-based system for defining and building objects in the world.

---

## **📋 Overview**

The spawnable system supports **2 build modes**:

1. **SimplePart** - Single procedural part (fast, common objects)
2. **CustomBuilder** - Programmatic multi-part structures (procedural complexity)

**Everything is code. No models in ReplicatedStorage.**

---

## **🏗️ Build Modes Explained**

### **1. SimplePart** (Easiest)
Use for simple, single-part objects.

```lua
local StandardPlatform = {
    ID = "StandardPlatform",
    BuildMode = "SimplePart",
    
    Shape = Enum.PartType.Block,
    Size = Vector3.new(1, 0.2, 1),
    Color = Color3.fromRGB(180, 180, 180),
    Material = Enum.Material.SmoothPlastic,
    
    CanCollide = true,
    Anchored = true,
    SpawnWeight = 50,
}
```

**When to use:**
- Platforms, blocks, spheres
- Single-color, single-material objects
- Most common case (~80% of objects)

---

### **2. CustomBuilder** (Procedural Code)
Use for dynamic, code-generated structures.

```lua
local function BuildLadder(position: Vector3, worldScale: number, rng: Random): Instance
    local model = Instance.new("Model")
    
    -- Create side rails
    local leftSide = Instance.new("Part")
    leftSide.Size = Vector3.new(0.15, 1.5, 0.15) * worldScale
    leftSide.Position = position + Vector3.new(-0.4 * worldScale, 0, 0)
    leftSide.Anchored = true
    leftSide.Parent = model
    
    -- Create rungs
    for i = 0, 4 do
        local rung = Instance.new("Part")
        rung.Size = Vector3.new(0.8, 0.1, 0.15) * worldScale
        rung.Position = position + Vector3.new(0, i * 0.3 * worldScale, 0)
        rung.Anchored = true
        rung.Parent = model
    end
    
    return model
end

local ProceduralLadder = {
    ID = "ProceduralLadder",
    BuildMode = "CustomBuilder",
    BuilderFunction = BuildLadder, -- Your function
    
    CanCollide = true,
    Anchored = true,
    SpawnWeight = 15,
}
```

**When to use:**
- Ladders, bridges, arches, towers, pillars
- Objects with repeating elements
- Random variations (use `rng` parameter)
- Complex multi-part structures

**Function Signature:**
```lua
function BuilderFunction(position: Vector3, worldScale: number, rng: Random): Instance
```

**Important:**
- Always multiply sizes/positions by `worldScale`
- Use `rng` for randomness (keeps world deterministic)
- Return a Model or Part

---

## **⚙️ How It Works**

### **1. Define Spawnables**
Create definitions in `GrayNodeSpawnables.luau`:

```lua
local MyPlatform = {
    ID = "MyPlatform",
    DisplayName = "My Cool Platform",
    Category = "GrayNode",
    
    BuildMode = "SimplePart", -- or "CustomBuilder"
    -- ... build mode specific fields ...
    
    CanCollide = true,
    Anchored = true,
    SpawnWeight = 25,
    MinScale = 5, -- Only spawn at scale 5+
}
```

### **2. Add to Registry**
Add to `GetAll()` function:

```lua
function GrayNodeSpawnables.GetAll()
    return {
        GrayNodeSpawnables.StandardPlatform,
        GrayNodeSpawnables.MyPlatform, -- Your new one
    }
end
```

### **3. Automatic Spawning**
The system automatically:
- Selects spawnable based on `SpawnWeight` and scale constraints
- Builds it using the appropriate builder
- Positions it correctly
- Parents it to the world container

---

## **🎲 Weighted Random Selection**

Spawnables are selected randomly based on `SpawnWeight`:

```lua
StandardPlatform: SpawnWeight = 50 → 50% chance
SmallPlatform:    SpawnWeight = 20 → 20% chance
ThinPlatform:     SpawnWeight = 15 → 15% chance
JumpPad:          SpawnWeight = 5  → 5% chance
```

Higher weight = more common.

---

## **📏 Scale Constraints**

Control when objects spawn based on world scale:

```lua
StandardPlatform: MinScale = 0 → Always spawns
JumpPad:         MinScale = 10 → Only at scale 10+
DisappearingPad: MinScale = 15, MaxScale = 100 → Scale 15-100
```

---

## **🎮 Special Behaviors**

Add gameplay properties:

```lua
JumpPad = {
    Properties = {
        BouncePower = 50, -- Custom attribute
    },
}

DisappearingPlatform = {
    Properties = {
        DisappearTime = 2,
        RespawnTime = 3,
    },
}
```

These are stored as **Attributes** on the spawned part.  
Client scripts can read these and implement behaviors.

---

## **📁 File Structure**

```
shared/Definitions/Spawnables/
  SpawnableTypes.luau        ← Type definitions
  GrayNodeSpawnables.luau    ← All gray node spawnables
  SpawnableBuilder.luau      ← Builds parts from definitions
  
  Examples/
    CustomBuilderExample.luau   ← How to build procedurally
  
  README_SPAWNABLES.md       ← This file
```

---

## **✨ Adding New Spawnables**

### **Quick Start:**

1. **Choose a build mode** (SimplePart or CustomBuilder)
2. **Create definition** in `GrayNodeSpawnables.luau`
3. **Add to `GetAll()`** function
4. **Test in-game**

### **Example: Simple Platform**

```lua
-- In GrayNodeSpawnables.luau

GrayNodeSpawnables.GlassPlatform = {
    ID = "GlassPlatform",
    DisplayName = "Glass Platform",
    Category = "GrayNode",
    
    BuildMode = "SimplePart",
    Shape = Enum.PartType.Block,
    Size = Vector3.new(1, 0.1, 1),
    Color = Color3.fromRGB(200, 230, 255),
    Material = Enum.Material.Glass,
    Transparency = 0.5,
    
    CanCollide = true,
    Anchored = true,
    Massless = true,
    
    SpawnWeight = 15,
    MinScale = 5,
}

-- Add to GetAll():
function GrayNodeSpawnables.GetAll()
    return {
        GrayNodeSpawnables.StandardPlatform,
        GrayNodeSpawnables.GlassPlatform, -- NEW
        -- ... others ...
    }
end
```

Done! It will now spawn with a 15% probability at scale 5+.

---

## **🔍 Debugging**

### **Check what spawned:**
```lua
-- In Roblox Studio, select a gray node and check:
print(part.Name) -- Shows the spawnable ID
```

### **Test a specific spawnable:**
```lua
-- Temporarily set its weight very high
SpawnWeight = 100 -- Now it's almost guaranteed
```

### **Force a build mode:**
```lua
-- Comment out other spawnables in GetAll()
-- Only leave the one you want to test
```

---

## **💡 Tips & Best Practices**

1. **Always scale by `worldScale`** - Every size/position must multiply by it
2. **Use `rng` for randomness** - Never use `math.random()` directly
3. **Keep SimplePart most common** - It's fast and efficient
4. **CustomBuilder for complexity** - Procedural structures, repeated elements
5. **Test at multiple scales** - What works at scale 1 might break at scale 30
6. **Set reasonable weights** - StandardPlatform = 50, Rare obstacles = 5
7. **Use MinScale wisely** - Small objects shouldn't spawn at large scales

---

## **🚀 Future Additions**

The system is designed to be extended:

- **More categories**: Not just gray nodes - obstacles, decorations, etc.
- **Biome-specific spawnables**: Desert platforms, ice platforms, etc.
- **Dynamic behaviors**: Moving platforms, rotating objects
- **Client-side effects**: Particles, sounds, animations

All follow the same pattern: Define → Build → Spawn.

---

Happy building! 🎮
