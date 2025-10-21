# Orange Wall Models

Drop **wall and barrier models** here in Roblox Studio.

## 📍 Location in Studio
`ReplicatedStorage > Assets > Spawnables > OrangeWall`

## 🎨 What to Put Here
Walls and barriers that spawn **around the path** to guide or block players:
- Fences
- Stone walls
- Barriers
- Rails
- Hedges
- Force fields
- Anything that creates boundaries!

## 📐 Sizing

Orange walls **scale with WorldScale** (like gray nodes, not like obstacles):

- Build your wall at **player scale** in workspace (normal Roblox size)
- Example: A fence at 4 studs tall
- **At WorldScale=1**: Auto-scaled to 1.2 studs (base size)
- **At WorldScale=10**: 12 studs (10x the base)
- **At WorldScale=30**: 36 studs (30x the base)

The system automatically scales walls from your player-sized model down to the base `WallDotSize` (1.2 studs), then multiplies by `WorldScale`.

## ⚙️ Model Setup
1. Build your model in Studio at **player scale**
2. **IMPORTANT:** Set a **PrimaryPart** (required for scaling!)
   - Right-click model → Properties → PrimaryPart → Select main part
3. Make sure all parts are **welded** or **unioned** together
4. Name it descriptively (e.g., "StoneWall", "IronFence", "HedgeBarrier")
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
- Example: `ModelScale = 0.3` for a taller wall

## ✨ Example Structure
```
OrangeWall/
  StoneWall (Model, 4×4×1 studs)
    - PrimaryPart (Part)
    - Wall1 (Part)
    - Wall2 (Part)
    - SpawnWeight (NumberValue) = 20
  
  IronFence (Model, 4×3×0.2 studs)
    - PrimaryPart (Part)
    - Post1 (Part)
    - Post2 (Part)
    - Rail (Part)
    - SpawnWeight (NumberValue) = 15
```

## 🎮 Gameplay Notes
- Walls are **collidable** - they block players
- Walls spawn along paths based on `WallChance` in Config (default 30%)
- They're positioned at `WallOffset` distance from the path (default 4 studs at base scale)

**Built at player scale → Auto-scaled to game scale!** 🧱

