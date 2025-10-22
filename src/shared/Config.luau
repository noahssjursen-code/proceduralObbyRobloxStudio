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
-- 8.0 = Player comfortable scale (baseline) ← CURRENT
-- 5.0 = Half size (smaller, tighter gameplay)
-- 10.0 = Slightly bigger (more spacious)
-- 20.0 = 2.5x bigger (epic scale)
Config.WorldScale = 8.0

-- Player scale reference (WorldScale at which obstacles are built at 1:1 size)
-- At WorldScale=8, a 6-stud jump is comfortable for players
-- At WorldScale=30, everything is 3.75x bigger (truly colossal)
Config.PlayerScaleReference = 8

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
	CheckpointCount = 4, -- Testing: reduced from 20
	CheckpointSize = 8,
	SpawnCheckpointSize = 4, -- Small spawn (at 30x = 120 studs, reasonable)
	CheckpointMinDistance = 160, -- 2x original (was 80)
	CheckpointMaxDistance = 300, -- 2x original (was 150)
	CheckpointSpreadAngle = 60, -- Degrees (horizontal spread only)
	CheckpointHeightIncreaseMin = 5, -- Minimum height gain per checkpoint
	CheckpointHeightIncreaseMax = 15, -- Maximum height gain per checkpoint
	
	-- Path Segments (modular platform pieces like toy railway)
	PathSegments = {
		Short = {Length = 10, Width = 8, Height = 2},
		Medium = {Length = 20, Width = 8, Height = 2},
		Long = {Length = 40, Width = 8, Height = 2},
		Wide = {Length = 15, Width = 12, Height = 2},
		Narrow = {Length = 12, Width = 5, Height = 2},
	},
	SegmentTurnAngleMin = -60, -- Degrees
	SegmentTurnAngleMax = 60,
	SegmentHeightVariation = 3, -- Height offset between segments
	
	-- Segment Visual Debug
	ShowSegmentBoxes = false,  -- Show transparent bounding boxes for segments
	SegmentBoxTransparency = 0.7,  -- How transparent segment boxes are
	ShowSegmentMarkers = false,  -- Show green/red start/end markers
	
	-- Connectors (between segments)
	ConnectorMaxFlatHeight = 2, -- Below this = flat connector (purple)
	ConnectorLadderHeight = 8, -- Above flat, below this = ladder (brown)
	ConnectorStairHeight = 20, -- Above ladder = stairs (brown)
	
	-- Attribute Slots (for modular obstacle system)
	AttributeSlots = {
		SlotMargin = 0.15, -- 15% margin between slots (as % of slot length)
		
		-- Default slot counts per segment type
		DefaultSlotCounts = {
			Short = 2,   -- Short segments have 2 attribute slots
			Medium = 4,  -- Medium segments have 4 attribute slots
			Long = 6,    -- Long segments have 6 attribute slots
			Wide = 3,    -- Wide segments have 3 attribute slots
			Narrow = 5,  -- Narrow segments have 5 attribute slots (more frequent, smaller)
		},
		
		-- Visual debug
		ShowSlotBoxes = true, -- Show transparent boxes for each slot
		SlotBoxTransparency = 1, -- How transparent the slot boxes are (higher = more transparent)
		SlotBoxColor = Color3.fromRGB(200, 160, 0), -- Muted yellow/orange
	},
	
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
		
		-- Scale segment dimensions
		PathSegments = {
			Short = {
				Length = wg.PathSegments.Short.Length * scale,
				Width = wg.PathSegments.Short.Width * scale,
				Height = wg.PathSegments.Short.Height * scale,
			},
			Medium = {
				Length = wg.PathSegments.Medium.Length * scale,
				Width = wg.PathSegments.Medium.Width * scale,
				Height = wg.PathSegments.Medium.Height * scale,
			},
			Long = {
				Length = wg.PathSegments.Long.Length * scale,
				Width = wg.PathSegments.Long.Width * scale,
				Height = wg.PathSegments.Long.Height * scale,
			},
			Wide = {
				Length = wg.PathSegments.Wide.Length * scale,
				Width = wg.PathSegments.Wide.Width * scale,
				Height = wg.PathSegments.Wide.Height * scale,
			},
			Narrow = {
				Length = wg.PathSegments.Narrow.Length * scale,
				Width = wg.PathSegments.Narrow.Width * scale,
				Height = wg.PathSegments.Narrow.Height * scale,
			},
		},
		SegmentTurnAngleMin = wg.SegmentTurnAngleMin,
		SegmentTurnAngleMax = wg.SegmentTurnAngleMax,
		SegmentHeightVariation = wg.SegmentHeightVariation * scale,
		
		-- Segment visual debug (don't scale these)
		ShowSegmentBoxes = wg.ShowSegmentBoxes,
		SegmentBoxTransparency = wg.SegmentBoxTransparency,
		ShowSegmentMarkers = wg.ShowSegmentMarkers,
		
		ConnectorMaxFlatHeight = wg.ConnectorMaxFlatHeight * scale,
		ConnectorLadderHeight = wg.ConnectorLadderHeight * scale,
		ConnectorStairHeight = wg.ConnectorStairHeight * scale,
		
		-- Attribute slots (don't scale counts, margins, or visual settings)
		AttributeSlots = {
			SlotMargin = wg.AttributeSlots.SlotMargin,
			DefaultSlotCounts = wg.AttributeSlots.DefaultSlotCounts,
			ShowSlotBoxes = wg.AttributeSlots.ShowSlotBoxes,
			SlotBoxTransparency = wg.AttributeSlots.SlotBoxTransparency,
			SlotBoxColor = wg.AttributeSlots.SlotBoxColor,
		},
		
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