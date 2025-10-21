--[[
	Wall Spawnables
	
	Manages spawnable definitions for orange walls (barriers, fences, etc.)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelLoader = require(script.Parent.ModelLoader)

local WallSpawnables = {}

-- Cache loaded models (loaded once at server startup)
local cachedWalls = nil

-- Initialize: Load all wall models once at startup
function WallSpawnables.Initialize()
	if cachedWalls then
		return -- Already loaded
	end
	
	cachedWalls = ModelLoader.LoadOrangeWallModels()
end

-- Get all wall spawnables
function WallSpawnables.GetAll()
	if not cachedWalls then
		WallSpawnables.Initialize()
	end
	
	return cachedWalls
end

-- Select a random wall spawnable
function WallSpawnables.SelectRandom(rng: Random, currentWorldScale: number)
	local walls = WallSpawnables.GetAll()
	
	if #walls == 0 then
		return nil -- Fallback to placeholder
	end
	
	-- Filter by scale constraints
	local validWalls = {}
	for _, wall in walls do
		local minScale = wall.MinScale or 0
		local maxScale = wall.MaxScale or math.huge
		if currentWorldScale >= minScale and currentWorldScale <= maxScale then
			table.insert(validWalls, wall)
		end
	end
	
	if #validWalls == 0 then
		return nil -- No walls valid at this scale
	end
	
	-- Weighted random selection
	local totalWeight = 0
	for _, wall in validWalls do
		totalWeight += wall.SpawnWeight or 10
	end
	
	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	
	for _, wall in validWalls do
		cumulative += wall.SpawnWeight or 10
		if roll <= cumulative then
			return wall
		end
	end
	
	return validWalls[1] -- Fallback
end

return WallSpawnables

