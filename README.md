# Roblox Procedural Obby - "Colossal"

A procedurally generated obby with a **colossal, epic scale**. Each week, a new seed generates a shared world that all players experience together. Navigate treacherous paths suspended high above the void, dodge obstacles, and climb toward massive ancient pillars in the distance.

## 🌍 Core Concept

**Global Weekly Seed**: Every week, a new seed generates the world. All players experience the same map, creating shared experiences and competitive leaderboards.

**Colossal Scale**: Everything is MASSIVE. You're a tiny adventurer traversing paths between enormous mossy cobblestone pillars that stretch into the sky. The scale creates a sense of awe and vertigo.

**High-Stakes Platforming**: Narrow paths suspended over the void. One wrong move means a long fall back to your last checkpoint.

## 🏗️ World Structure

### Core Components

1. **Spawn Platform**
   - Safe starting area where players spawn
   - Shows weekly seed number and leaderboard
   - Tutorial signs explaining controls

2. **Checkpoint Platforms** 
   - Safe zones scattered throughout the world
   - Save your progress (respawn here on death)
   - Larger platform with barriers to prevent accidental falls
   - Glowing effect to make them visible from distance

3. **Paths**
   - Connect checkpoints and platforms
   - Vary in width (narrow bridges, wide walkways, stepping stones)
   - Can be straight, curved, spiraling
   - Made of ancient stone, worn wood planks, or crystal
   - Some paths slowly crumble behind you

4. **Obstacles**
   - Dynamic challenges that push, block, or knock players off
   - Become more complex the further you progress
   - Types: Sweeping hammers, moving blocks, rotating hazards, timed lasers, etc.

5. **Colossal Pillars**
   - Massive structures in the background (and as destinations)
   - Made of mossy cobblestone, weathered and ancient
   - Some have ruins, vines, waterfalls cascading down
   - Create sense of scale and direction
   - You physically travel to and up these pillars

## 🎨 Biomes & Themes

Each section of the world transitions through different biomes, all maintaining the "colossal" theme:

### 1. **Ancient Ruins** (Early Game)
- Mossy cobblestone pillars
- Weathered stone paths
- Overgrown with vines and vegetation
- Warm, earthy colors
- Fireflies/particle effects

### 2. **Crystal Caverns** (Mid Game)
- Giant crystal formations
- Glowing paths made of crystal
- Blue/purple color palette
- Ambient magical particles
- Echoing sound design

### 3. **Sky Temples** (Late Game)
- Floating temple ruins
- Clouds below and around you
- Golden/white architecture
- Celestial lighting
- Wind effects, cloth banners flowing

### 4. **Void Realm** (Endgame)
- Dark, ominous atmosphere
- Floating islands of obsidian
- Purple/black void below
- Lightning in the distance
- Reality-bending architecture

### 5. **The Summit** (Victory)
- The top of the colossal pillar
- Panoramic view of entire world
- Hall of champions
- Special effects for completers

## 🎮 Gameplay Features

### Progression
- **Checkpoint System**: Respawn at last checkpoint touched
- **Progressive Difficulty**: Obstacles and path complexity increase
- **Distance Counter**: Track how far you've traveled
- **Time Tracking**: Your completion time for the weekly seed

### Competition
- **Weekly Leaderboard**: Fastest completion times for current seed
- **All-Time Leaderboard**: Best times ever recorded
- **Checkpoint Leaderboard**: Most checkpoints reached (for those who don't finish)
- **Weekly Reset**: New seed every Monday 00:00 UTC

### Movement & Feel
- **Refined Controls**: Smooth, responsive character movement
- **Camera Control**: Adjustable FOV and camera distance
- **Visual Cues**: Show landing spots, checkpoint glow, safe zones
- **Forgiveness**: Coyote time, small edge grab assists
- **No Annoying Mechanics**: No random speed boosts or loss of control

### Atmosphere
- **Dynamic Lighting**: Changes with biomes
- **Ambient Audio**: Wind, distant thunder, crumbling stone
- **Particle Effects**: Dust, mist, magic sparkles based on biome
- **Scale Indicators**: Birds flying between pillars, waterfalls showing height
- **Skybox**: Epic skies that change with progression

## 🛠️ Technical Implementation

### Procedural Generation System

```
Seed → Noise Functions → World Layout → Path Generation → Obstacle Placement
```

1. **Seed-Based Generation**
   - Weekly seed determines entire world
   - Deterministic: Same seed = same world
   - Use Perlin/Simplex noise for natural-feeling layouts

2. **World Layout**
   - Define major pillar positions using seed
   - Calculate checkpoint positions (logarithmic spacing)
   - Determine biome transitions

3. **Path Generation**
   - Connect checkpoints with curves (Bezier/Catmull-Rom splines)
   - Add variation: width, material, decoration
   - Ensure all paths are completable

4. **Obstacle Placement**
   - Place based on difficulty curve
   - Validate spacing and feasibility
   - Add variety within each section

5. **Biome Dressing**
   - Apply materials, colors, lighting per biome
   - Add decorative elements (vines, crystals, ruins)
   - Particle systems and ambient effects

### Architecture

```
src/
├── client/
│   ├── init.client.luau          # Client entry
│   ├── Controllers/
│   │   ├── CameraController.luau # Camera management
│   │   ├── UIController.luau     # HUD, leaderboards
│   │   └── EffectController.luau # Particles, visuals
│   └── Modules/
│       ├── Movement.luau          # Enhanced movement feel
│       └── Audio.luau             # Sound management
│
├── server/
│   ├── init.server.luau          # Server entry
│   ├── WorldGeneration/
│   │   ├── SeedManager.luau      # Weekly seed logic
│   │   ├── WorldGenerator.luau   # Main generation
│   │   ├── PathGenerator.luau    # Path creation
│   │   ├── ObstacleSpawner.luau  # Obstacle placement
│   │   └── BiomeManager.luau     # Biome theming
│   ├── Gameplay/
│   │   ├── CheckpointManager.luau # Checkpoint logic
│   │   ├── RespawnHandler.luau   # Death/respawn
│   │   └── ProgressTracker.luau  # Player progress
│   └── Data/
│       ├── DataStoreManager.luau # Save/load data
│       └── LeaderboardManager.luau # Leaderboard logic
│
└── shared/
    ├── Config.luau               # Game configuration
    ├── ObstacleTemplates/        # Obstacle definitions
    │   ├── Hammers.luau
    │   ├── MovingBlocks.luau
    │   ├── Lasers.luau
    │   └── ...
    ├── BiomeData.luau            # Biome definitions
    └── Utils/
        ├── Math.luau             # Noise, curves
        └── Validation.luau       # Path validation
```

### Performance Considerations

- **Streaming**: Only load world sections near player
- **Part Pooling**: Reuse parts for obstacles
- **LOD System**: Simplified geometry for distant pillars
- **Culling**: Unload checkpoints player has passed
- **Optimization**: Keep part count reasonable, use unions strategically

## 📋 Development Phases

### Phase 1: Foundation ✅ Starting Now
- [ ] Project structure setup
- [ ] Basic seed system
- [ ] Simple world generation (spawn + 3 checkpoints)
- [ ] Straight paths between checkpoints
- [ ] Basic respawn system
- [ ] Distance counter UI

### Phase 2: Core Generation
- [ ] Advanced path generation (curves, variation)
- [ ] Basic obstacle system (2-3 types)
- [ ] Checkpoint platform design
- [ ] Fall detection and respawn
- [ ] Simple leaderboard

### Phase 3: Colossal Scale
- [ ] Massive pillar generation
- [ ] Background elements and atmosphere
- [ ] Camera improvements for scale
- [ ] Particle effects
- [ ] Ambient audio

### Phase 4: Biomes
- [ ] Biome system framework
- [ ] Ancient Ruins biome (first)
- [ ] Biome transitions
- [ ] Material variations
- [ ] Lighting per biome

### Phase 5: Obstacles & Challenge
- [ ] 8-10 different obstacle types
- [ ] Difficulty scaling algorithm
- [ ] Obstacle combinations
- [ ] Testing and balancing

### Phase 6: Additional Biomes
- [ ] Crystal Caverns
- [ ] Sky Temples
- [ ] Void Realm
- [ ] Summit area

### Phase 7: Polish
- [ ] Visual effects polish
- [ ] Sound design
- [ ] UI improvements
- [ ] Performance optimization
- [ ] Mobile controls

### Phase 8: Data & Social
- [ ] DataStore integration
- [ ] Weekly seed rotation
- [ ] Comprehensive leaderboards
- [ ] Stats tracking

### Phase 9: Launch
- [ ] Final testing
- [ ] Bug fixes
- [ ] Balance tweaks
- [ ] Release!

## ⚙️ Configuration

Key parameters (will be in `Config.luau`):

```lua
-- World Generation
WEEKLY_SEED_ROTATION = true
CHECKPOINT_COUNT = 50  -- Number of checkpoints in world
WORLD_HEIGHT_RANGE = {100, 1000}  -- Min/max heights
PILLAR_SCALE = {200, 500}  -- Width/height of pillars

-- Paths
PATH_WIDTH_RANGE = {6, 16}  -- Studs
PATH_LENGTH_RANGE = {30, 100}  -- Distance between checkpoints
STEPPING_STONE_CHANCE = 0.3  -- Chance for narrow sections

-- Difficulty
DIFFICULTY_CURVE = "logarithmic"  -- How difficulty scales
OBSTACLE_DENSITY_START = 0.2
OBSTACLE_DENSITY_END = 0.8

-- Movement
WALK_SPEED = 16
JUMP_POWER = 50
COYOTE_TIME = 0.1  -- Seconds of jump grace after leaving edge
```

## 🎯 Design Pillars

1. **Awe-Inspiring Scale**: Player should feel tiny and amazed
2. **Fair Challenge**: Difficult but never cheap or unfair
3. **Shared Experience**: Weekly seed creates community
4. **Atmospheric**: Immersive audio/visual experience
5. **Replayability**: New seed each week, speedrunning potential

## 🚀 Getting Started (Development)

```bash
# Install tools
aftman install

# Build place file
rojo build -o "RobloxProceduralObby.rbxlx"

# Start dev server
rojo serve
```

Open `RobloxProceduralObby.rbxlx` in Roblox Studio and connect to Rojo.

---

**Current Status**: 🚧 Phase 1 - Foundation
**Version**: 0.1.0
**Next Up**: Seed system + basic world generation
 
 
