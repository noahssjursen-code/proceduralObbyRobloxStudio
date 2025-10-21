--[[
	Obstacle Spawnable Definitions (PinkObstacle, RedDanger, PurpleObstacle)
	
	Loads obstacle models from ReplicatedStorage/Assets/Spawnables/
	
	Pink = On-path obstacles
	Red = External dangers
	Purple = Dynamic obstacles
]]

local SpawnableTypes = require(script.Parent.SpawnableTypes)
local ModelLoader = require(script.Parent.ModelLoader)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

local ObstacleSpawnables = {}

-- Caches
local cachedPinkObstacles: { SpawnableDefinition }? = nil
local cachedRedDangers: { SpawnableDefinition }? = nil
local cachedPurpleObstacles: { SpawnableDefinition }? = nil
local isInitialized = false

--[[
	Initialize all obstacle caches
]]
function ObstacleSpawnables.Initialize()
	if isInitialized then
		return
	end
	
	cachedPinkObstacles = ModelLoader.LoadPinkObstacleModels()
	cachedRedDangers = ModelLoader.LoadRedDangerModels()
	cachedPurpleObstacles = ModelLoader.LoadPurpleObstacleModels()
	isInitialized = true
end

--[[
	Get all Pink Obstacles (on-path)
]]
function ObstacleSpawnables.GetPinkObstacles(): { SpawnableDefinition }
	if not isInitialized then
		ObstacleSpawnables.Initialize()
	end
	return cachedPinkObstacles or {}
end

--[[
	Get all Red Dangers (external)
]]
function ObstacleSpawnables.GetRedDangers(): { SpawnableDefinition }
	if not isInitialized then
		ObstacleSpawnables.Initialize()
	end
	return cachedRedDangers or {}
end

--[[
	Get all Purple Dynamic Obstacles
]]
function ObstacleSpawnables.GetPurpleObstacles(): { SpawnableDefinition }
	if not isInitialized then
		ObstacleSpawnables.Initialize()
	end
	return cachedPurpleObstacles or {}
end

--[[
	Select random Pink Obstacle
]]
function ObstacleSpawnables.SelectRandomPink(rng: Random, currentScale: number): SpawnableDefinition?
	local obstacles = ObstacleSpawnables.GetPinkObstacles()
	if #obstacles == 0 then
		return nil
	end
	
	-- Simple random selection (can add weighted later)
	return obstacles[rng:NextInteger(1, #obstacles)]
end

--[[
	Select random Red Danger
]]
function ObstacleSpawnables.SelectRandomRed(rng: Random, currentScale: number): SpawnableDefinition?
	local dangers = ObstacleSpawnables.GetRedDangers()
	if #dangers == 0 then
		return nil
	end
	
	return dangers[rng:NextInteger(1, #dangers)]
end

--[[
	Select random Purple Obstacle
]]
function ObstacleSpawnables.SelectRandomPurple(rng: Random, currentScale: number): SpawnableDefinition?
	local obstacles = ObstacleSpawnables.GetPurpleObstacles()
	if #obstacles == 0 then
		return nil
	end
	
	return obstacles[rng:NextInteger(1, #obstacles)]
end

return ObstacleSpawnables

