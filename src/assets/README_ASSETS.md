# Assets Folder - Model Library System

This folder structure allows you to **drop models directly in Roblox Studio** and have them automatically appear in the game!

---

## 📁 Folder Structure

```
ReplicatedStorage/
  Assets/
    Spawnables/
      GrayNode/          ← Walkable platforms
      PinkObstacle/      ← Path obstacles (Small & Large)
      RedDanger/         ← External dangers
      PurpleObstacle/    ← Dynamic/moving obstacles
      Decoration/        ← Atmospheric decorations
```

---

## 🚀 Quick Start

### **1. Open Roblox Studio**
Navigate to:
```
ReplicatedStorage > Assets > Spawnables > GrayNode
```

### **2. Build Your Model**
- Create a model with a PrimaryPart
- Weld all parts together
- Name it descriptively

### **3. Add Spawn Weight (Optional)**
Add a `NumberValue` named `SpawnWeight` as a child:
- 50 = Very common
- 25 = Common
- 10 = Default
- 5 = Rare

### **4. Drop It In**
Place your model in the appropriate folder.

### **5. Done!**
The system automatically detects and uses your model! 🎉

---

## 📊 How It Works

### **Automatic Model Loading**

When the game starts, the `ModelLoader` scans these folders and:
1. Finds all Models and Parts
2. Reads their `SpawnWeight` values
3. Creates spawnable definitions automatically
4. Merges them with procedural definitions

### **Example: Adding a Wooden Platform**

```
1. Create a wooden platform model in Studio
2. Set PrimaryPart
3. Add NumberValue "SpawnWeight" = 30
4. Name it "WoodenPlatform"
5. Drop in: Assets/Spawnables/GrayNode/
```

Console output:
```
[ModelLoader] Loaded: WoodenPlatform (weight=30, scale=any-any)
[GrayNodeSpawnables] Total: 6 procedural + 1 models = 7 spawnables
```

---

## ⚙️ Advanced Features

### **Scale Constraints**

Add `NumberValue` children to limit when a model spawns:

```lua
MinScale = 5   -- Only spawn at WorldScale 5+
MaxScale = 20  -- Only spawn up to WorldScale 20
```

Example: Small details only at low scales, massive structures only at high scales.

### **Custom Properties**

Add values to enable special behaviors:

```lua
-- For obstacles
Damage (NumberValue) = 10
DamageType (StringValue) = "instant"

-- For moving platforms
MoveSpeed (NumberValue) = 5
MoveDistance (NumberValue) = 10
MovementType (StringValue) = "oscillate"

-- For disappearing platforms
DisappearTime (NumberValue) = 2
RespawnTime (NumberValue) = 3
```

Client scripts read these and implement behaviors.

---

## 🎨 Category Guidelines

### **GrayNode (Walkable Platforms)**
- ✅ Should be walkable
- ✅ Collision enabled
- 📏 Base size: ~0.5 studs
- 🎲 Common (high spawn weight)

### **PinkObstacle (Path Obstacles)**
- ✅ Blocks or damages players
- ✅ Spawns ON the path
- 📏 Base size: 0.5-2 studs
- 🎲 Moderate spawn weight

### **RedDanger (External Dangers)**
- ✅ Visual threat, far from path
- ✅ Unreachable but dramatic
- 📏 Base size: 1-2 studs
- 🎲 Lower spawn weight

### **PurpleObstacle (Dynamic)**
- ✅ Moves, rotates, or animates
- ✅ More complex challenges
- 📏 Base size: ~1 stud
- 🎲 Rare spawn weight

### **Decoration (Atmosphere)**
- ✅ Non-collidable
- ✅ Purely visual
- 📏 Base size: 0.5-1 stud
- 🎲 Common (ambient detail)

---

## 🔄 Mixing Procedural & Models

The system supports **both**:

1. **Procedural** (code-generated) - Always available
2. **Models** (dropped in folders) - Artist-created

They work together! The game randomly picks from both based on spawn weights.

Example:
- 6 procedural platforms (code)
- 4 custom platforms (your models)
- Total: 10 different platform types!

---

## 📝 Model Checklist

Before dropping a model:
- [ ] Model has a PrimaryPart set
- [ ] All parts are welded/connected
- [ ] Named descriptively
- [ ] SpawnWeight added (if custom)
- [ ] MinScale/MaxScale added (if needed)
- [ ] Special properties added (if applicable)
- [ ] Placed in correct category folder

---

## 🐛 Troubleshooting

### **Model not appearing?**
Check console for:
```
[ModelLoader] Loaded: YourModel (weight=X, scale=Y-Z)
```

If missing:
- Is it in the right folder?
- Is it a Model or Part (not Folder)?
- Does it have a valid name?

### **Model spawning at wrong times?**
Add `MinScale` and `MaxScale` NumberValues to control when it appears.

### **Model is too big/small?**
The system automatically scales by `WorldScale`. If still wrong, adjust the base model size in Studio.

---

## 🎮 Testing

1. Drop a test model in `GrayNode` folder
2. Set `SpawnWeight = 100` (guarantees spawning)
3. Run the game
4. Check console for load confirmation
5. Walk the path and find your model!

---

**Happy building!** 🚀

Drop any model in the appropriate folder and watch it appear in your procedural world! ✨

