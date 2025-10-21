# Red Danger Models

Drop **external danger models** here in Roblox Studio.

## 📍 Location in Studio
`ReplicatedStorage > Assets > Spawnables > RedDanger`

## 🎨 What to Put Here
Dangers **OUTSIDE the path** that are unreachable but still threatening:
- Laser turrets
- Floating cannons
- Storm clouds
- Eyes in the darkness
- Distant threats!

## 📐 Build at PLAYER SCALE

**IMPORTANT:** Red dangers are normalized to `WorldScale=30`!

- Build at the size appropriate **for a player** (normal Roblox scale)
- Example: A 5-stud tall laser turret
- **At WorldScale=30**: Spawns at exactly 5 studs (1:1 with your model)
- **At WorldScale=15**: Spawns at 2.5 studs (half size)
- **At WorldScale=60**: Spawns at 10 studs (double size)

Formula: `dangerSize = yourModelSize × (WorldScale / 30)`

This keeps dangers appropriately sized relative to the player at any world scale!

## ⚙️ Model Setup
- Add `PrimaryPart` (required for positioning/scaling)
- Optional: Add `SpawnWeight` NumberValue (default: 10, higher = more common)
- Optional: Add `ModelScale` NumberValue to manually adjust size (e.g., 0.5 = half size, 2.0 = double size)
- Optional: Add `Damage` and `DamageType` NumberValues

## 🎨 Visual Effects
These should be **visually threatening** but not directly reachable:
- Particle emitters
- Bright lights
- Projectile effects
- Sound effects

The system will automatically find and use these models! 🎮

