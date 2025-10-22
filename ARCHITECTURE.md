# Project Architecture Schema

This document defines the **architectural pattern** for organizing code in this project. This is a **schema/template**, not a definitive file list.

## Core Principles

1. **Fully Procedural**: No manual workspace editing. Everything generated via code.
2. **100% Code-Based**: No models in ReplicatedStorage. All parts created programmatically.
3. **Service-Based Architecture**: Each major feature is a "service" with clear responsibilities.
4. **Shared Definitions**: Common types, definitions, and utilities in ReplicatedStorage.
5. **Server Authority**: Actual world generation happens server-side.
6. **Module Scripts**: Everything is a module script (no loose scripts except entry points).

## File Structure Pattern

```
src/
├── client/
│   └── init.client.luau              # ONLY entry point
│
├── server/
│   ├── init.server.luau              # ONLY entry point
│   └── Services/
│       └── {ServiceName}/
│           └── {ServiceName}Server.luau
│
└── shared/
    ├── Config.luau                   # Global configuration
    └── Services/
        └── {ServiceName}/
            ├── {ServiceName}Service.luau
            └── {ServiceName}ServiceUtils.luau
```

## Service Pattern

For any feature/system in the game, follow this pattern:

### Shared Layer (ReplicatedStorage)
**Location**: `src/shared/Services/{ServiceName}/`

**Files**:
- `{ServiceName}Service.luau` - Defines types, structures, data, configurations
- `{ServiceName}ServiceUtils.luau` - Pure functions, helpers, utilities, math

**Purpose**:
- Type definitions (what IS this thing?)
- Data structures and configurations
- Helper functions that don't need server authority
- Can be required by both client and server

**Examples**:
- `PillarService` - Defines pillar types, variants, dimensions
- `BiomeService` - Defines biome data, color palettes, materials
- `PathService` - Defines path types, width ranges, materials

### Server Layer (ServerScriptService)
**Location**: `src/server/Services/{ServiceName}/`

**Files**:
- `{ServiceName}Server.luau` - Server authority for creating/managing the feature

**Purpose**:
- Actually creates instances in the workspace
- Manages server-side state
- Has authority over game logic
- Requires the shared service for definitions

**Examples**:
- `PillarServiceServer` - Spawns and positions actual pillar parts
- `CheckpointManagerServer` - Creates checkpoints, handles player touches
- `WorldGenerationServer` - Orchestrates entire world creation

## Example: Pillar Service

### Shared: `PillarService.luau`
```lua
-- Defines WHAT a pillar is
local PillarService = {}

PillarService.PillarTypes = {
    Ancient = { Material = "Cobblestone", Color = Color3.fromRGB(80, 80, 70) },
    Crystal = { Material = "Glass", Color = Color3.fromRGB(100, 150, 255) },
    -- ...
}

PillarService.DefaultDimensions = {
    Width = 200,
    Height = 500,
    Depth = 200
}

return PillarService
```

### Shared: `PillarServiceUtils.luau`
```lua
-- Helper functions for pillars
local PillarServiceUtils = {}

function PillarServiceUtils.CalculatePillarPosition(seed, index)
    -- Math for positioning
end

function PillarServiceUtils.GetPillarScale(difficulty)
    -- Calculate size variation
end

return PillarServiceUtils
```

### Server: `PillarServiceServer.luau`
```lua
-- Creates actual pillars in workspace
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PillarService = require(ReplicatedStorage.Shared.Services.Buildings.PillarService)
local PillarServiceUtils = require(ReplicatedStorage.Shared.Services.Buildings.PillarServiceUtils)

local PillarServiceServer = {}

function PillarServiceServer.SpawnPillar(position, pillarType)
    local definition = PillarService.PillarTypes[pillarType]
    -- Create parts, set properties, parent to workspace
end

return PillarServiceServer
```

## Directory Categories

Services are grouped by category in subdirectories:

- **Buildings/** - Structures (pillars, platforms, ruins)
- **Paths/** - Path generation and types
- **Obstacles/** - Obstacle definitions and spawning
- **Checkpoints/** - Checkpoint system
- **Biomes/** - Biome theming and atmosphere
- **UI/** - User interface
- **Camera/** - Camera controls
- **Effects/** - Visual/particle effects
- **Utils/** - General utilities (math, validation, etc.)

## Special Files

### `Config.luau`
**Location**: `src/shared/Config.luau`

Global configuration values used throughout the project:
- World generation parameters
- Gameplay settings
- Difficulty curves
- Visual settings

### Entry Points
- `src/client/init.client.luau` - Initializes client services
- `src/server/init.server.luau` - Kicks off world generation, initializes server services

## Benefits of This Pattern

1. **Clear Separation**: Shared definitions vs. server authority
2. **Reusability**: Utils can be used anywhere
3. **Testability**: Pure functions in utils are easy to test
4. **Scalability**: Add new services without touching existing ones
5. **Readability**: Consistent structure across all features
6. **Collaboration**: Easy for multiple developers (or agents) to work simultaneously

## Adding a New Feature

1. Create shared service folder: `src/shared/Services/{FeatureName}/`
2. Create service definition: `{FeatureName}Service.luau`
3. Create utilities if needed: `{FeatureName}ServiceUtils.luau`
4. Create server implementation: `src/server/Services/{FeatureName}/{FeatureName}Server.luau`
5. Require and use in appropriate entry point or other services

---

**This is the schema. Actual implementation may have more or fewer services depending on needs.**

