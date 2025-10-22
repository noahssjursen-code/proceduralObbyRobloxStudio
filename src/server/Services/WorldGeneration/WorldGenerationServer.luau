--[[
	WorldGenerationServer
	
	Takes a WorldLayout and builds actual instances in the workspace.
	Generic spawner system - handles any element type.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldGenerationService = require(ReplicatedStorage.Shared.Services.WorldGeneration.WorldGenerationService)
local GrayNodeSpawnables = require(ReplicatedStorage.Shared.Definitions.Spawnables.GrayNodeSpawnables)
local ObstacleSpawnables = require(ReplicatedStorage.Shared.Definitions.Spawnables.ObstacleSpawnables)
local WallSpawnables = require(ReplicatedStorage.Shared.Definitions.Spawnables.WallSpawnables)
local SpawnableBuilder = require(ReplicatedStorage.Shared.Definitions.Spawnables.SpawnableBuilder)
local FillerBuilder = require(ReplicatedStorage.Shared.Definitions.Fillers.FillerBuilder)
local ShortSegmentFillers = require(ReplicatedStorage.Shared.Definitions.Fillers.ShortSegmentFillers)
local MediumSegmentFillers = require(ReplicatedStorage.Shared.Definitions.Fillers.MediumSegmentFillers)
local LongSegmentFillers = require(ReplicatedStorage.Shared.Definitions.Fillers.LongSegmentFillers)
local WideSegmentFillers = require(ReplicatedStorage.Shared.Definitions.Fillers.WideSegmentFillers)
local NarrowSegmentFillers = require(ReplicatedStorage.Shared.Definitions.Fillers.NarrowSegmentFillers)
local ConnectorBuilder = require(ReplicatedStorage.Shared.Services.WorldGeneration.Generators.ConnectorBuilder)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldGenerationServer = {}

-- Container for all generated world parts
local WorldContainer: Folder = nil

-- Store spawn position for player spawning
local SpawnPosition: Vector3? = nil

-- Store current world scale for spawnable system
local CurrentWorldScale: number = 1.0

--[[
	Generic spawner functions for each element type
]]
local Spawners = {}

-- Spawn a checkpoint orb (floating sphere or spawn platform)
function Spawners.SpawnCheckpointOrb(element: WorldGenerationService.WorldElement)
	-- If this is the spawn checkpoint, make it a PLATFORM not an orb
	local checkpoint
	if element.Properties.IsSpawn then
		checkpoint = Instance.new("SpawnLocation")
		checkpoint.Name = "Checkpoint_1_Spawn"
		checkpoint.Duration = 0 -- Respawn immediately
		checkpoint.Neutral = true -- All teams can spawn here
		checkpoint.Shape = Enum.PartType.Block -- FLAT PLATFORM
		
		-- Make it a wide, flat platform (not a sphere)
		local width = element.Scale.X
		checkpoint.Size = Vector3.new(width, width * 0.2, width) -- Flat: 5:1 ratio
	else
		checkpoint = Instance.new("Part")
		checkpoint.Name = "CheckpointOrb_" .. (element.Properties.CheckpointNumber or "Unknown")
		checkpoint.Shape = Enum.PartType.Ball -- Regular checkpoints stay as orbs
		checkpoint.Size = element.Scale or Vector3.new(8, 8, 8)
	end
	
	checkpoint.Position = element.Position
	checkpoint.Anchored = true
	checkpoint.Material = element.Properties.Material or Enum.Material.Neon
	checkpoint.Color = element.Properties.Color or Color3.fromRGB(200, 0, 255)
	checkpoint.CanCollide = true -- Players can stand on checkpoints
	
	-- Add glow effect
	local light = Instance.new("PointLight")
	light.Brightness = element.Properties.Brightness or 2
	light.Color = checkpoint.Color
	light.Range = 60
	light.Parent = checkpoint
	
	-- Add checkpoint number label
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 5, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = checkpoint
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.Text = tostring(element.Properties.CheckpointNumber)
	text.TextScaled = true
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Font = Enum.Font.GothamBold
	text.TextStrokeTransparency = 0.5
	text.Parent = billboardGui
	
	checkpoint.Parent = WorldContainer
	return checkpoint
end

-- Spawn a simple dot (generic for paths, walls, obstacles, decorations)
function Spawners.SpawnDot(element: WorldGenerationService.WorldElement, dotType: string)
	-- Skip segment markers if disabled in config
	if dotType == "SegmentMarker" then
		local scaledConfig = Config.GetScaledWorldConfig()
		if not scaledConfig.ShowSegmentMarkers then
			return nil
		end
	end
	
	local dot = Instance.new("Part")
	dot.Name = dotType
	dot.Shape = Enum.PartType.Ball
	dot.Size = element.Scale or Vector3.new(1, 1, 1)
	dot.Position = element.Position
	dot.Anchored = true
	dot.Material = element.Properties.Material or Enum.Material.Neon
	dot.Color = element.Properties.Color or Color3.new(1, 1, 1)
	
	-- Collision and transparency based on type
	if dotType == "BlueNode" then
		dot.CanCollide = true -- Strategic nodes are walkable
		dot.Transparency = 0
	elseif dotType == "GreenNode" then
		dot.CanCollide = true -- Control nodes are walkable
		dot.Transparency = 0
	elseif dotType == "GrayNode" then
		dot.CanCollide = true -- Walkable surface (main gameplay layer)
		dot.Transparency = 0
	elseif dotType == "WallDot" then
		dot.CanCollide = true -- Walls block players
		dot.Transparency = 0
	elseif dotType == "PinkObstacleSmall" or dotType == "PinkObstacleLarge" then
		-- PLACEHOLDERS: Translucent and non-collidable (until actual obstacles are built)
		dot.CanCollide = false
		dot.Transparency = 0.7
	elseif dotType == "RedDanger" then
		-- PLACEHOLDERS: Translucent and non-collidable
		dot.CanCollide = false
		dot.Transparency = 0.7
	elseif dotType == "PurpleObstacleDynamic" then
		-- PLACEHOLDERS: Translucent and non-collidable
		dot.CanCollide = false
		dot.Transparency = 0.7
	elseif dotType == "DecorationDot" then
		dot.CanCollide = false -- Decorations are non-solid (cosmetic)
		dot.Transparency = 0.2 -- More visible for testing
		dot.Material = Enum.Material.Neon -- Make them glow!
	else
		dot.CanCollide = false -- Default: no collision
		dot.Transparency = 0
	end
	
	-- Add light for certain types
	if element.Properties.Brightness then
		local light = Instance.new("PointLight")
		light.Brightness = element.Properties.Brightness
		light.Color = dot.Color
		light.Range = 20
		light.Parent = dot
	end
	
	dot.Parent = WorldContainer
	return dot
end

-- Generic spawner for model-based or placeholder elements
local function SpawnModelOrPlaceholder(
	element: WorldGenerationService.WorldElement,
	selectFunction: (Random, number) -> any,
	placeholderType: string,
	applyWorldScale: boolean
)
	-- Create RNG from a hash of the position (for deterministic variety)
	local posHash = element.Position.X + element.Position.Y * 1000 + element.Position.Z * 1000000
	local rng = Random.new(math.floor(posHash))
	
	-- Try to select a model
	local spawnableDefinition = selectFunction(rng, CurrentWorldScale)
	
	-- If no models available, use placeholder
	if not spawnableDefinition then
		return Spawners.SpawnDot(element, placeholderType)
	end
	
	-- Calculate final scale:
	-- - Structural elements (gray nodes): scale with world (WorldScale)
	-- - Obstacles: normalize to player scale at Config.PlayerScaleReference
	local finalScale = if applyWorldScale 
		then CurrentWorldScale 
		else (CurrentWorldScale / Config.PlayerScaleReference) -- Obstacles scale proportionally
	
	-- Build from model with orientation
	return SpawnableBuilder.Build(
		spawnableDefinition,
		element.Position,
		finalScale,
		rng,
		WorldContainer,
		element.Forward -- Pass the forward direction for orientation
	)
end

-- Spawn a walkable gray node using the spawnable system
function Spawners.SpawnGrayNodeWalkable(element: WorldGenerationService.WorldElement)
	return SpawnModelOrPlaceholder(
		element,
		GrayNodeSpawnables.SelectRandom,
		"GrayNode",
		true -- Gray nodes scale with world (they're structural)
	)
end

-- Spawn an orange wall using the spawnable system
function Spawners.SpawnWall(element: WorldGenerationService.WorldElement)
	return SpawnModelOrPlaceholder(
		element,
		WallSpawnables.SelectRandom,
		"WallDot",
		true -- Walls scale with world (they're structural)
	)
end

-- Spawn a Pink Obstacle (small or large)
function Spawners.SpawnPinkObstacle(element: WorldGenerationService.WorldElement)
	return SpawnModelOrPlaceholder(
		element,
		ObstacleSpawnables.SelectRandomPink,
		"PinkObstacleSmall", -- Placeholder type
		false -- Obstacles stay at player scale (already human-sized)
	)
end

-- Spawn a Red Danger
function Spawners.SpawnRedDanger(element: WorldGenerationService.WorldElement)
	return SpawnModelOrPlaceholder(
		element,
		ObstacleSpawnables.SelectRandomRed,
		"RedDanger",
		false -- Obstacles stay at player scale (already human-sized)
	)
end

-- Spawn a Purple Dynamic Obstacle
function Spawners.SpawnPurpleObstacle(element: WorldGenerationService.WorldElement)
	return SpawnModelOrPlaceholder(
		element,
		ObstacleSpawnables.SelectRandomPurple,
		"PurpleObstacleDynamic",
		false -- Obstacles stay at player scale (already human-sized)
	)
end

-- Spawn a colossal pillar (brown structure)
function Spawners.SpawnPillar(element: WorldGenerationService.WorldElement)
	local pillar = Instance.new("Part")
	pillar.Name = "Pillar_" .. (element.Properties.CheckpointIndex or "Unknown")
	pillar.Size = element.Scale or Vector3.new(50, 100, 50)
	pillar.Position = element.Position
	pillar.Anchored = true
	pillar.Material = element.Properties.Material or Enum.Material.Cobblestone
	pillar.Color = element.Properties.Color or Color3.fromRGB(120, 90, 70)
	pillar.CanCollide = true -- Pillars are solid
	
	pillar.Parent = WorldContainer
	return pillar
end

-- Spawn a path segment (transparent bounding box) with filler content
function Spawners.SpawnPathSegment(element: WorldGenerationService.WorldElement)
	local scaledConfig = Config.GetScaledWorldConfig()
	
	-- Create segment bounding box (only if ShowSegmentBoxes is enabled)
	local segment = nil
	if scaledConfig.ShowSegmentBoxes then
		segment = Instance.new("Part")
		segment.Name = "PathSegment_" .. (element.Properties.SegmentType or "Unknown") .. "_" .. (element.Properties.SegmentIndex or 0)
		segment.Size = element.Scale -- Width x Height x Length
		segment.Position = element.Position
		segment.Anchored = true
		segment.Material = element.Properties.Material or Enum.Material.ForceField
		segment.Color = element.Properties.Color or Color3.fromRGB(150, 150, 255)
		segment.Transparency = scaledConfig.SegmentBoxTransparency or 0.7
		segment.CanCollide = false -- Segments are just bounding boxes, not walkable
		
		-- Apply rotation if specified
		if element.Rotation then
			segment.CFrame = CFrame.new(element.Position) * CFrame.Angles(
				math.rad(element.Rotation.X),
				math.rad(element.Rotation.Y),
				math.rad(element.Rotation.Z)
			)
		end
		
		segment.Parent = WorldContainer
	end
	
	-- Fill segment with content based on segment type
	local segmentType = element.Properties.SegmentType
	local filler = nil
	
	-- Create RNG from segment position (deterministic)
	local posHash = element.Position.X + element.Position.Y * 1000 + element.Position.Z * 1000000
	local rng = Random.new(math.floor(posHash))
	
	-- Select appropriate filler for segment type
	if segmentType == "Short" then
		filler = ShortSegmentFillers.SelectRandom(rng, CurrentWorldScale)
	elseif segmentType == "Medium" then
		filler = MediumSegmentFillers.SelectRandom(rng, CurrentWorldScale)
	elseif segmentType == "Long" then
		filler = LongSegmentFillers.SelectRandom(rng, CurrentWorldScale)
	elseif segmentType == "Wide" then
		filler = WideSegmentFillers.SelectRandom(rng, CurrentWorldScale)
	elseif segmentType == "Narrow" then
		filler = NarrowSegmentFillers.SelectRandom(rng, CurrentWorldScale)
	end
	
	-- Build filler content inside segment
	if filler then
		FillerBuilder.Build(
			filler,
			element.Position,
			element.Scale,
			element.Rotation,
			segmentType, -- Pass segment type for slot calculation
			CurrentWorldScale,
			rng,
			WorldContainer
		)
	end
	
	return segment
end

-- Spawn a segment connector (gap filler between segments)
function Spawners.SpawnSegmentConnector(element: WorldGenerationService.WorldElement)
	local startPos = element.Properties.StartPosition
	local endPos = element.Properties.EndPosition
	
	-- Only spawn ladder if height difference is significant (already filtered in PathGenerator)
	if startPos and endPos then
		local ladderWidth = 6  -- Player-scale comfortable ladder width
		local connectorModel = ConnectorBuilder.BuildLadder(startPos, endPos, ladderWidth)
		connectorModel.Name = "Connector_Ladder_" .. (element.Properties.SegmentIndex or 0)
		connectorModel.Parent = WorldContainer
		return connectorModel
	else
		-- Positions missing, skip
		return nil
	end
end

--[[
	Main spawner registry - maps element types to spawner functions
]]
local SpawnerRegistry = {
	["CheckpointOrb"] = function(element)
		-- Store spawn position from first checkpoint (IsSpawn property)
		if element.Properties.IsSpawn then
			SpawnPosition = element.Position
		end
		return Spawners.SpawnCheckpointOrb(element)
	end,
	
	["CheckpointStart"] = function(element)
		return Spawners.SpawnDot(element, "CheckpointStart")
	end,
	
	["CheckpointEnd"] = function(element)
		return Spawners.SpawnDot(element, "CheckpointEnd")
	end,
	
	["BlueNode"] = function(element)
		return Spawners.SpawnDot(element, "BlueNode")
	end,
	
	["GreenNode"] = function(element)
		return Spawners.SpawnDot(element, "GreenNode")
	end,
	
	["GrayNode"] = function(element)
		return Spawners.SpawnGrayNodeWalkable(element)
	end,
	
	["WallDot"] = function(element)
		return Spawners.SpawnWall(element)
	end,
	
	["PinkObstacleSmall"] = function(element)
		return Spawners.SpawnPinkObstacle(element)
	end,
	
	["PinkObstacleLarge"] = function(element)
		return Spawners.SpawnPinkObstacle(element)
	end,
	
	["RedDanger"] = function(element)
		return Spawners.SpawnRedDanger(element)
	end,
	
	["PurpleObstacleDynamic"] = function(element)
		return Spawners.SpawnPurpleObstacle(element)
	end,
	
	["BrownPillar"] = function(element)
		return Spawners.SpawnPillar(element)
	end,
	
	["DecorationDot"] = function(element)
		return Spawners.SpawnDot(element, "DecorationDot")
	end,
	
	["PathSegment"] = function(element)
		return Spawners.SpawnPathSegment(element)
	end,
	
	["SegmentMarker"] = function(element)
		return Spawners.SpawnDot(element, "SegmentMarker")
	end,
	
	["SegmentConnector"] = function(element)
		return Spawners.SpawnSegmentConnector(element)
	end,
	
	-- Add more spawners here as needed
	-- ["AncientPillar"] = function(element) ... end,
	-- ["CrystalFormation"] = function(element) ... end,
}

--[[
	Builds the world from a WorldLayout (CHUNKED for performance)
]]
function WorldGenerationServer.BuildWorld(worldLayout: WorldGenerationService.WorldLayout)
	print("[WorldGenerationServer] Building world...")
	
	-- Store current world scale for spawnable system
	CurrentWorldScale = Config.WorldScale
	
	-- Create world container
	WorldContainer = Instance.new("Folder")
	WorldContainer.Name = "GeneratedWorld"
	WorldContainer.Parent = workspace
	
	-- Chunked spawning to avoid timeout
	local CHUNK_SIZE = Config.Performance.WorldSpawnChunkSize
	local totalElements = #worldLayout.Elements
	local spawnedCount = 0
	
	print(string.format("[WorldGenerationServer] Spawning %d elements in chunks of %d...", totalElements, CHUNK_SIZE))
	
	-- Process elements in chunks
	for i = 1, totalElements, CHUNK_SIZE do
		local chunkEnd = math.min(i + CHUNK_SIZE - 1, totalElements)
		
		-- Spawn this chunk
		for j = i, chunkEnd do
			local element = worldLayout.Elements[j]
			local spawner = SpawnerRegistry[element.Type]
			
			if spawner then
				spawner(element)
				spawnedCount += 1
			else
				warn(string.format("[WorldGenerationServer] No spawner for element type: %s", element.Type))
			end
		end
		
		-- Yield to prevent timeout
		if chunkEnd < totalElements then
			local progress = math.floor((spawnedCount / totalElements) * 100)
			print(string.format("[WorldGenerationServer] Progress: %d%% (%d/%d)", progress, spawnedCount, totalElements))
			task.wait() -- Yield to next frame
		end
	end
	
	print(string.format("[WorldGenerationServer] Built %d/%d elements", spawnedCount, totalElements))
	
	return SpawnPosition
end

--[[
	Clears the generated world
]]
function WorldGenerationServer.ClearWorld()
	if WorldContainer then
		WorldContainer:Destroy()
		WorldContainer = nil
		print("[WorldGenerationServer] World cleared")
	end
end

--[[
	Initialize and generate the world
	Returns the spawn position
]]
function WorldGenerationServer.Initialize(seed: number): Vector3?
	print("[WorldGenerationServer] Initializing...")
	
	-- Clear any existing world
	WorldGenerationServer.ClearWorld()
	
	-- Plan the world
	local worldLayout = WorldGenerationService.GenerateWorldLayout(seed)
	
	-- Build the world
	local spawnPos = WorldGenerationServer.BuildWorld(worldLayout)
	
	print("[WorldGenerationServer] Ready!")
	
	return spawnPos
end

return WorldGenerationServer

