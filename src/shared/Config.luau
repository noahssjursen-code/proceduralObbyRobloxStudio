--[[
	Global Configuration
	
	All game parameters in one place.
	Adjust these to scale the entire world!
]]

local Config = {}

-- ========================================
-- WORLD SCALE
-- ========================================
-- Master scale multiplier - change this to scale EVERYTHING
-- 1.0 = Current scale (good for testing)
-- 5.0 = 5x larger (truly colossal)
-- 10.0 = 10x larger (epic scale)
Config.WorldScale = 1.0

-- Player scale reference (WorldScale at which obstacles are built at 1:1 size)
-- At WorldScale=30, a 10-stud obstacle model spawns at 10 studs
-- At other scales, obstacles scale proportionally (WorldScale/30)
Config.PlayerScaleReference = 30

-- ========================================
-- PERFORMANCE
-- ========================================
Config.Performance = {
	-- Chunk size for world spawning (elements per batch)
	-- Lower = more yields, slower but no timeout
	-- Higher = fewer yields, faster but might timeout
	-- 500 = Good balance for most worlds
	WorldSpawnChunkSize = 500,
}

-- ========================================
-- WORLD GENERATION
-- ========================================
Config.WorldGeneration = {
	-- Spawn position
	SpawnPosition = Vector3.new(0, 100, 0),
	SpawnPlatformSize = 40,
	
	-- Checkpoints
	CheckpointCount = 20,
	CheckpointSize = 8,
	SpawnCheckpointSize = 4, -- Small spawn (at 30x = 120 studs, reasonable)
	CheckpointMinDistance = 160, -- 2x original (was 80)
	CheckpointMaxDistance = 300, -- 2x original (was 150)
	CheckpointSpreadAngle = 60, -- Degrees (horizontal spread only)
	CheckpointHeightIncreaseMin = 5, -- Minimum height gain per checkpoint
	CheckpointHeightIncreaseMax = 15, -- Maximum height gain per checkpoint
	
	-- Paths (3-TIER hierarchical system)
	-- Tier 1: Blue Strategic Nodes (major waypoints, large challenges)
	BlueNodeSpacing = 1.0, -- Far apart (major sections)
	BlueNodeSize = 5,
	
	-- Tier 2: Green Control Nodes (curve control between blue nodes)
	GreenNodeSpacing = 0.25, -- Medium spacing (curve definition)
	GreenNodeSize = 2,
	
	-- Tier 3: Gray Walkable Nodes (dense surface for walking/obstacles)
	GrayNodeSpacing = 0.5, -- Close together (actual walkable surface)
	GrayNodeSize = 0.4,
	
	-- Walls
	WallChance = 0.3, -- 30% of paths get walls
	WallOffset = 4, -- Distance from path
	WallDotSize = 1.2,
	
	-- Obstacles
	PinkSmallFrequency = 0.05, -- 5% of path dots = small obstacles
	PinkSmallSize = 2.5,
	
	PinkLargeFrequency = 0.02, -- 2% of path dots = large area hazards
	PinkLargeSize = 8,
	
	RedDangerPerCheckpoint = 3, -- External dangers per checkpoint
	RedDangerSpread = 40, -- How far from path
	RedDangerSize = 4,
	
	PurpleDynamicFrequency = 0.01, -- 1% of path dots = dynamic obstacles
	PurpleDynamicSize = 6,
	
	-- Structures (Brown)
	PillarsPerCheckpoint = 2, -- Large pillars near checkpoints
	PillarMinDistance = 8, -- How far from checkpoint (at 30x = 240 studs, close!)
	PillarMaxDistance = 15, -- (at 30x = 450 studs, nearby)
	PillarMinSize = 5, -- (at 30x = 150 studs, reasonable)
	PillarMaxSize = 12, -- (at 30x = 360 studs, still impressive)
	
	-- Decorations
	DecorationsPerCheckpoint = 8,
	DecorationSpreadRadius = 50,
	DecorationDotSizeMin = 2, -- Increased for better visibility
	DecorationDotSizeMax = 4,
}

-- ========================================
-- COLORS
-- ========================================
Config.Colors = {
	Checkpoint = Color3.fromRGB(200, 0, 255),      -- Purple (large checkpoints)
	
	-- 3-Tier Path System
	BlueNode = Color3.fromRGB(0, 100, 255),        -- Blue (strategic waypoints)
	GreenNode = Color3.fromRGB(0, 255, 100),       -- Green (control nodes)
	GrayNode = Color3.fromRGB(150, 150, 150),      -- Gray (walkable surface)
	
	Wall = Color3.fromRGB(255, 150, 0),            -- Orange (environment/walls)
	
	-- Obstacles
	ObstaclePinkSmall = Color3.fromRGB(255, 100, 200),  -- Pink (small path obstacles)
	ObstaclePinkLarge = Color3.fromRGB(255, 50, 150),   -- Pink Large (area hazards)
	DangerRed = Color3.fromRGB(255, 0, 0),              -- Red (external dangers)
	ObstaclePurple = Color3.fromRGB(180, 0, 200),       -- Dark Purple (dynamic obstacles)
	
	-- Environment
	Structure = Color3.fromRGB(120, 90, 70),       -- Brown (pillars, ruins)
	Decoration = Color3.fromRGB(0, 150, 255),      -- Blue (atmosphere)
	SpawnPlatform = Color3.fromRGB(100, 100, 100), -- Gray
}

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

--[[
	Get a scaled value based on WorldScale
]]
function Config.Scale(value: number): number
	return value * Config.WorldScale
end

--[[
	Get a scaled Vector3 based on WorldScale
]]
function Config.ScaleVector(vector: Vector3): Vector3
	return vector * Config.WorldScale
end

--[[
	Get scaled world generation config
	Returns a config table with all values scaled
]]
function Config.GetScaledWorldConfig(): {[string]: any}
	local wg = Config.WorldGeneration
	local scale = Config.WorldScale
	
	return {
		SpawnPosition = wg.SpawnPosition, -- Don't scale position
		SpawnPlatformSize = wg.SpawnPlatformSize * scale,
		
		CheckpointCount = wg.CheckpointCount,
		CheckpointSize = wg.CheckpointSize * scale,
		SpawnCheckpointSize = wg.SpawnCheckpointSize * scale,
		CheckpointMinDistance = wg.CheckpointMinDistance * scale,
		CheckpointMaxDistance = wg.CheckpointMaxDistance * scale,
		CheckpointSpreadAngle = wg.CheckpointSpreadAngle, -- Don't scale angles
		CheckpointHeightIncreaseMin = wg.CheckpointHeightIncreaseMin * scale,
		CheckpointHeightIncreaseMax = wg.CheckpointHeightIncreaseMax * scale,
		
		BlueNodeSpacing = wg.BlueNodeSpacing, -- Don't scale spacing ratios
		BlueNodeSize = wg.BlueNodeSize * scale,
		GreenNodeSpacing = wg.GreenNodeSpacing,
		GreenNodeSize = wg.GreenNodeSize * scale,
		GrayNodeSpacing = wg.GrayNodeSpacing * scale, -- Do scale absolute spacing
		GrayNodeSize = wg.GrayNodeSize * scale,
		
		WallChance = wg.WallChance, -- Don't scale percentages
		WallOffset = wg.WallOffset * scale,
		WallDotSize = wg.WallDotSize * scale,
		
		-- Pink obstacles
		PinkSmallFrequency = wg.PinkSmallFrequency, -- Don't scale frequencies
		PinkSmallSize = wg.PinkSmallSize * scale,
		PinkLargeFrequency = wg.PinkLargeFrequency,
		PinkLargeSize = wg.PinkLargeSize * scale,
		
		-- Red dangers
		RedDangerPerCheckpoint = wg.RedDangerPerCheckpoint,
		RedDangerSpread = wg.RedDangerSpread * scale,
		RedDangerSize = wg.RedDangerSize * scale,
		
		-- Purple dynamic obstacles
		PurpleDynamicFrequency = wg.PurpleDynamicFrequency,
		PurpleDynamicSize = wg.PurpleDynamicSize * scale,
		
		-- Brown structures (pillars)
		PillarsPerCheckpoint = wg.PillarsPerCheckpoint,
		PillarMinDistance = wg.PillarMinDistance * scale,
		PillarMaxDistance = wg.PillarMaxDistance * scale,
		PillarMinSize = wg.PillarMinSize * scale,
		PillarMaxSize = wg.PillarMaxSize * scale,
		
		-- Blue decorations
		DecorationsPerCheckpoint = wg.DecorationsPerCheckpoint,
		DecorationSpreadRadius = wg.DecorationSpreadRadius * scale,
		DecorationDotSizeMin = wg.DecorationDotSizeMin * scale,
		DecorationDotSizeMax = wg.DecorationDotSizeMax * scale,
	}
end

return Config

