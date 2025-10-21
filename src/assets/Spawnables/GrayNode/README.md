# Gray Node Models

Drop **walkable platform models** here in Roblox Studio.

## 📍 Location in Studio
`ReplicatedStorage > Assets > Spawnables > GrayNode`

## 🎨 What to Put Here
Any model or part that can be used as a walkable gray node platform:
- Wooden platforms
- Stone slabs
- Metal grates
- Rope bridges
- Anything players can walk on!

## 📐 Sizing Guidelines

### **✨ AUTO-SCALING (Recommended)**
Build your models at **player scale** in workspace (normal Roblox size):
- Typical platform: **4×1×4 studs** (player-sized)
- The system **automatically scales it down** to 0.4 studs at base scale
- Then scales up by `WorldScale` when spawned

**You don't need to do anything!** Just build at normal scale.

### **Final Sizes:**
Your 4-stud platform becomes:
- At WorldScale 1: 0.4 studs (auto-scaled)
- At WorldScale 10: 4 studs (your original size!)
- At WorldScale 30: 12 studs (3x your original)

### 🔑 **Gray Nodes vs Obstacles**
- **Gray nodes** (walkable paths) **DO** scale with `WorldScale` - they grow with the world!
- **Obstacles** (Pink/Red/Purple) **DO NOT** scale - they stay player-sized for consistent challenge!

## ⚙️ Model Setup
1. Build your model in Studio
2. **IMPORTANT:** Set a **PrimaryPart** (required for scaling!)
   - Right-click model → Properties → PrimaryPart → Select main part
3. Make sure all parts are **welded** or **unioned** together
4. Name it descriptively (e.g., "WoodenPlatform", "MetalGrate")
5. Drop it in this folder

⚠️ **Without PrimaryPart set, the model won't spawn correctly!**

## 🎲 Spawn Weighting
Add a **NumberValue** named `SpawnWeight` as a child of the model:
- 50 = Very common
- 25 = Common
- 10 = Uncommon (default)
- 5 = Rare

## 📏 Manual Scale Override (Optional)
Want to override auto-scaling? Add a **NumberValue** named `ModelScale`:
- System will use your value instead of auto-calculating
- Useful for intentionally oversized/undersized platforms

**Example:** Make a platform 2x bigger than normal:
- Add `ModelScale = 0.2` (instead of auto 0.1)

**Most users won't need this!** Auto-scaling handles it.

## ✨ Example Structure
```
GrayNode/
  WoodenPlatform (Model, 4×1×4 studs)
    - PrimaryPart (Part)
    - Support1 (Part)
    - Support2 (Part)
    - SpawnWeight (NumberValue) = 30
  
  StoneSlat (Model, 4×0.5×4 studs)
    - PrimaryPart (Part)
    - SpawnWeight (NumberValue) = 20
```

**Built at player scale → Auto-scaled to game scale!** 🎮

