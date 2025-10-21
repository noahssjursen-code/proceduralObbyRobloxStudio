# Purple Dynamic Obstacle Models

Drop **dynamic/moving obstacle models** here in Roblox Studio.

## 📍 Location in Studio
`ReplicatedStorage > Assets > Spawnables > PurpleObstacle`

## 🎨 What to Put Here
Obstacles that **move or change** over time:
- Moving platforms
- Rotating blades
- Oscillating walls
- Appearing/disappearing hazards
- Anything animated!

## 📐 Build at PLAYER SCALE

**IMPORTANT:** Purple obstacles are normalized to `WorldScale=30`!

- Build at the size appropriate **for a player** (normal Roblox scale)
- Example: An 8-stud wide rotating blade
- **At WorldScale=30**: Spawns at exactly 8 studs (1:1 with your model)
- **At WorldScale=15**: Spawns at 4 studs (half size)
- **At WorldScale=60**: Spawns at 16 studs (double size)

Formula: `obstacleSize = yourModelSize × (WorldScale / 30)`

This keeps obstacles appropriately sized relative to the player at any world scale!

## ⚙️ Model Setup
- Add `PrimaryPart` (required for positioning/scaling)
- Optional: Add `SpawnWeight` NumberValue (default: 10, higher = more common)
- Optional: Add `ModelScale` NumberValue to manually adjust size (e.g., 0.5 = half size, 2.0 = double size)

## 🎬 Animation Setup
For moving/animated obstacles, add:
- **NumberValue** named `MoveSpeed` (studs per second)
- **NumberValue** named `MoveDistance` (how far it moves)
- **StringValue** named `MovementType` ("linear", "rotate", "oscillate", etc.)

Client scripts will handle the actual animation.

The system will automatically find and use these models! 🎮

