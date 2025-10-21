# Pink Obstacle Models

Drop **obstacle models** here in Roblox Studio.

## 📍 Location in Studio
`ReplicatedStorage > Assets > Spawnables > PinkObstacle`

## 🎨 What to Put Here
Obstacles that spawn **ON the path** and challenge players:
- Spinning blades
- Moving walls
- Swinging axes
- Fire pillars
- Anything that blocks or damages!

## 📐 Build at PLAYER SCALE

**IMPORTANT:** Obstacles are normalized to `WorldScale=30`!

- Build your obstacle at the size it should be **for a player** (normal Roblox scale)
- Example: A 10-stud wide spinning blade
- **At WorldScale=30**: Spawns at exactly 10 studs (1:1 with your model)
- **At WorldScale=15**: Spawns at 5 studs (half size)
- **At WorldScale=60**: Spawns at 20 studs (double size)

Formula: `obstacleSize = yourModelSize × (WorldScale / 30)`

This keeps obstacles appropriately sized relative to the player at any world scale!

This is different from gray nodes (which DO scale with the world).

## ⚙️ Model Setup
- Add `PrimaryPart` (required for positioning/scaling)
- Optional: Add `SpawnWeight` NumberValue (default: 10, higher = more common)
- Optional: Add `ModelScale` NumberValue to manually adjust size (e.g., 0.5 = half size, 2.0 = double size)

## 🔴 Damage Handling
For obstacles that should damage players, add:
- **NumberValue** named `Damage` (amount of damage)
- **StringValue** named `DamageType` ("instant", "continuous", etc.)

Client scripts will handle the actual damage logic.

The system will automatically find and use these models! 🎮

