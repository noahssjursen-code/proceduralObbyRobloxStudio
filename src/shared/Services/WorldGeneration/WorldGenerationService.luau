--[[
	WorldGenerationService
	
	Orchestrates world generation by calling specialized generator modules.
	Returns pure data - does NOT create instances.
	
	Modular design: Each element type has its own generator.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CheckpointGenerator = require(script.Parent.Generators.CheckpointGenerator)
local PathGenerator = require(script.Parent.Generators.PathGenerator)
local WallGenerator = require(script.Parent.Generators.WallGenerator)
local PinkObstacleGenerator = require(script.Parent.Generators.PinkObstacleGenerator)
local RedDangerGenerator = require(script.Parent.Generators.RedDangerGenerator)
local PurpleObstacleGenerator = require(script.Parent.Generators.PurpleObstacleGenerator)
local StructureGenerator = require(script.Parent.Generators.StructureGenerator)
local DecorationGenerator = require(script.Parent.Generators.DecorationGenerator)

local WorldGenerationService = {}

-- Type definitions
export type WorldElement = {
	Type: string,              -- Element type identifier
	Position: Vector3,
	Forward: Vector3?,         -- Direction this element should face (unit vector)
	Rotation: Vector3?,        -- Legacy rotation (deprecated, use Forward instead)
	Scale: Vector3?,
	Properties: {[string]: any}?, -- Type-specific data
}

export type WorldLayout = {
	Seed: number,
	Elements: {WorldElement},
}

--[[
	Generates the world layout from a seed.
	Orchestrates all generator modules.
	Returns a list of elements to be spawned.
]]
function WorldGenerationService.GenerateWorldLayout(seed: number): WorldLayout
	-- Get scaled config
	local cfg = Config.GetScaledWorldConfig()
	
	print(string.format("[WorldGeneration] Planning world with seed %d...", seed))
	print(string.format("[WorldGeneration] World Scale: %.1fx", Config.WorldScale))
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	
	-- Seed the random number generator
	local rng = Random.new(seed)
	
	local elements: {WorldElement} = {}
	
	-- Generate Checkpoints (Purple dots) - Checkpoint 1 is the spawn
	local spawnPos = cfg.SpawnPosition
	local checkpointConfig = {
		CheckpointCount = cfg.CheckpointCount,
		CheckpointSize = cfg.CheckpointSize,
		SpawnCheckpointSize = cfg.SpawnCheckpointSize, -- First checkpoint (spawn) size
		MinDistance = cfg.CheckpointMinDistance,
		MaxDistance = cfg.CheckpointMaxDistance,
		SpreadAngle = cfg.CheckpointSpreadAngle,
		HeightIncreaseMin = cfg.CheckpointHeightIncreaseMin,
		HeightIncreaseMax = cfg.CheckpointHeightIncreaseMax,
		Color = Config.Colors.Checkpoint,
	}
	local checkpointElements = CheckpointGenerator.Generate(rng, spawnPos, checkpointConfig)
	for _, element in checkpointElements do
		table.insert(elements, element)
	end
	
	-- Store spawn position from first checkpoint for player spawning
	SpawnPosition = checkpointElements[1].Position
	
	-- Generate Path Segments (modular platform pieces)
	local pathConfig = {
		PathSegments = cfg.PathSegments,
		SegmentTurnAngleMin = cfg.SegmentTurnAngleMin,
		SegmentTurnAngleMax = cfg.SegmentTurnAngleMax,
		SegmentHeightVariation = cfg.SegmentHeightVariation,
		ConnectorMaxFlatHeight = cfg.ConnectorMaxFlatHeight,
		ConnectorLadderHeight = cfg.ConnectorLadderHeight,
		ConnectorStairHeight = cfg.ConnectorStairHeight,
	}
	local pathElements = PathGenerator.Generate(checkpointElements, pathConfig, rng)
	for _, element in pathElements do
		table.insert(elements, element)
	end
	
	-- 4. Generate Walls (Orange dots)
	local wallConfig = {
		WallChance = cfg.WallChance,
		WallOffset = cfg.WallOffset,
		DotSize = cfg.WallDotSize,
		Color = Config.Colors.Wall,
	}
	local wallElements = WallGenerator.Generate(rng, pathElements, wallConfig)
	for _, element in wallElements do
		table.insert(elements, element)
	end
	
	-- 5. Generate Pink Obstacles (Small) - ON the path
	local pinkSmallConfig = {
		Frequency = cfg.PinkSmallFrequency,
		Size = cfg.PinkSmallSize,
		Color = Config.Colors.ObstaclePinkSmall,
	}
	local pinkSmallElements = PinkObstacleGenerator.GenerateSmall(rng, pathElements, pinkSmallConfig)
	for _, element in pinkSmallElements do
		table.insert(elements, element)
	end
	
	-- 6. Generate Pink Obstacles (Large) - Area hazards on path
	local pinkLargeConfig = {
		Frequency = cfg.PinkLargeFrequency,
		Size = cfg.PinkLargeSize,
		Color = Config.Colors.ObstaclePinkLarge,
	}
	local pinkLargeElements = PinkObstacleGenerator.GenerateLarge(rng, pathElements, pinkLargeConfig)
	for _, element in pinkLargeElements do
		table.insert(elements, element)
	end
	
	-- 7. Generate Red Dangers - External threats
	local redDangerConfig = {
		DangersPerCheckpoint = cfg.RedDangerPerCheckpoint,
		SpreadDistance = cfg.RedDangerSpread,
		Size = cfg.RedDangerSize,
		Color = Config.Colors.DangerRed,
	}
	local redDangerElements = RedDangerGenerator.Generate(rng, checkpointElements, redDangerConfig)
	for _, element in redDangerElements do
		table.insert(elements, element)
	end
	
	-- 8. Generate Purple Dynamic Obstacles - Moving/rotating hazards
	local purpleDynamicConfig = {
		Frequency = cfg.PurpleDynamicFrequency,
		Size = cfg.PurpleDynamicSize,
		Color = Config.Colors.ObstaclePurple,
	}
	local purpleDynamicElements = PurpleObstacleGenerator.Generate(rng, pathElements, purpleDynamicConfig)
	for _, element in purpleDynamicElements do
		table.insert(elements, element)
	end
	
	-- 9. Generate Brown Structures - Colossal pillars and ruins
	local structureConfig = {
		PillarsPerCheckpoint = cfg.PillarsPerCheckpoint,
		MinDistance = cfg.PillarMinDistance,
		MaxDistance = cfg.PillarMaxDistance,
		MinSize = cfg.PillarMinSize,
		MaxSize = cfg.PillarMaxSize,
		Color = Config.Colors.Structure,
	}
	local structureElements = StructureGenerator.GeneratePillars(rng, checkpointElements, structureConfig)
	for _, element in structureElements do
		table.insert(elements, element)
	end
	
	-- 10. Generate Decorations (Blue dots)
	local decorationConfig = {
		DecorationsPerCheckpoint = cfg.DecorationsPerCheckpoint,
		DecorationSpreadRadius = cfg.DecorationSpreadRadius,
		DotSizeMin = cfg.DecorationDotSizeMin,
		DotSizeMax = cfg.DecorationDotSizeMax,
		Color = Config.Colors.Decoration,
	}
	local decorationElements = DecorationGenerator.Generate(rng, checkpointElements, decorationConfig)
	for _, element in decorationElements do
		table.insert(elements, element)
	end
	
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print(string.format("[WorldGeneration] Total elements: %d", #elements))
	
	-- Optimization: Remove gray nodes that have obstacles at the same position
	-- (Obstacles replace the gray node, no need to render both)
	local obstaclePositions = {}
	for _, element in elements do
		if element.Type == "PinkObstacleSmall" or element.Type == "PinkObstacleLarge" 
			or element.Type == "PurpleObstacleDynamic" then
			local key = string.format("%.2f,%.2f,%.2f", element.Position.X, element.Position.Y, element.Position.Z)
			obstaclePositions[key] = true
		end
	end
	
	-- Filter out gray nodes at obstacle positions
	local filteredElements = {}
	local removedCount = 0
	for _, element in elements do
		local key = string.format("%.2f,%.2f,%.2f", element.Position.X, element.Position.Y, element.Position.Z)
		if element.Type == "GrayNode" and obstaclePositions[key] then
			removedCount += 1
			-- Skip this gray node - there's an obstacle here
		else
			table.insert(filteredElements, element)
		end
	end
	
	print(string.format("[WorldGeneration] Optimized: removed %d gray nodes under obstacles", removedCount))
	print(string.format("[WorldGeneration] Final element count: %d", #filteredElements))
	print(string.format("[WorldGeneration] World height range: %.0f to %.0f studs", 
		checkpointElements[1].Position.Y, 
		checkpointElements[#checkpointElements].Position.Y))
	
	return {
		Seed = seed,
		Elements = filteredElements,
		SpawnPosition = checkpointElements[1].Position, -- Return spawn for player service
	}
end

return WorldGenerationService

