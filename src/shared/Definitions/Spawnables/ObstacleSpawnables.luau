--[[
	Obstacle Spawnable Definitions (PinkObstacle, RedDanger, PurpleObstacle)
	
	Pink = On-path obstacles
	Red = External dangers
	Purple = Dynamic obstacles
]]

local SpawnableTypes = require(script.Parent.SpawnableTypes)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

local ObstacleSpawnables = {}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- PINK OBSTACLES (On-Path)
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local PinkObstacleDot = {
	ID = "PinkObstacleDot",
	DisplayName = "Pink Obstacle",
	Category = "PinkObstacle",
	
	BuildMode = "SimplePart",
	Shape = Enum.PartType.Ball,
	Size = Vector3.new(1, 1, 1),
	Color = Color3.fromRGB(255, 100, 200),
	Material = Enum.Material.Neon,
	
	CanCollide = true,
	Anchored = true,
	Massless = true,
	
	SpawnWeight = 100,
}

function ObstacleSpawnables.GetPinkObstacles(): { SpawnableDefinition }
	return { PinkObstacleDot }
end

function ObstacleSpawnables.SelectRandomPink(rng: Random, currentScale: number): SpawnableDefinition?
	local obstacles = ObstacleSpawnables.GetPinkObstacles()
	if #obstacles == 0 then
		return nil
	end
	return obstacles[rng:NextInteger(1, #obstacles)]
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- RED DANGERS (External)
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local RedDangerDot = {
	ID = "RedDangerDot",
	DisplayName = "Red Danger",
	Category = "RedDanger",
	
	BuildMode = "SimplePart",
	Shape = Enum.PartType.Ball,
	Size = Vector3.new(1, 1, 1),
	Color = Color3.fromRGB(255, 0, 0),
	Material = Enum.Material.Neon,
	
	CanCollide = true,
	Anchored = true,
	Massless = true,
	
	SpawnWeight = 100,
}

function ObstacleSpawnables.GetRedDangers(): { SpawnableDefinition }
	return { RedDangerDot }
end

function ObstacleSpawnables.SelectRandomRed(rng: Random, currentScale: number): SpawnableDefinition?
	local dangers = ObstacleSpawnables.GetRedDangers()
	if #dangers == 0 then
		return nil
	end
	return dangers[rng:NextInteger(1, #dangers)]
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- PURPLE OBSTACLES (Dynamic)
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local PurpleObstacleDot = {
	ID = "PurpleObstacleDot",
	DisplayName = "Purple Dynamic Obstacle",
	Category = "PurpleObstacle",
	
	BuildMode = "SimplePart",
	Shape = Enum.PartType.Ball,
	Size = Vector3.new(1, 1, 1),
	Color = Color3.fromRGB(180, 0, 200),
	Material = Enum.Material.Neon,
	
	CanCollide = true,
	Anchored = true,
	Massless = true,
	
	SpawnWeight = 100,
}

function ObstacleSpawnables.GetPurpleObstacles(): { SpawnableDefinition }
	return { PurpleObstacleDot }
end

function ObstacleSpawnables.SelectRandomPurple(rng: Random, currentScale: number): SpawnableDefinition?
	local obstacles = ObstacleSpawnables.GetPurpleObstacles()
	if #obstacles == 0 then
		return nil
	end
	return obstacles[rng:NextInteger(1, #obstacles)]
end

return ObstacleSpawnables
