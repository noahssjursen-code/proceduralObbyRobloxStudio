--[[
	Wall Spawnables
	
	Orange walls (barriers, fences, etc.)
]]

local SpawnableTypes = require(script.Parent.SpawnableTypes)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

local WallSpawnables = {}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- DEFINITIONS
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local WallDot = {
	ID = "WallDot",
	DisplayName = "Wall",
	Category = "OrangeWall",
	
	BuildMode = "SimplePart",
	Shape = Enum.PartType.Ball,
	Size = Vector3.new(1, 1, 1),
	Color = Color3.fromRGB(255, 150, 0),
	Material = Enum.Material.SmoothPlastic,
	
	CanCollide = true,
	Anchored = true,
	Massless = true,
	
	SpawnWeight = 100,
}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- REGISTRY
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function WallSpawnables.GetAll(): { SpawnableDefinition }
	return { WallDot }
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SELECTION
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function WallSpawnables.SelectRandom(rng: Random, currentWorldScale: number): SpawnableDefinition?
	local walls = WallSpawnables.GetAll()
	
	if #walls == 0 then
		return nil
	end
	
	local validWalls = {}
	for _, wall in walls do
		local minScale = wall.MinScale or 0
		local maxScale = wall.MaxScale or math.huge
		if currentWorldScale >= minScale and currentWorldScale <= maxScale then
			table.insert(validWalls, wall)
		end
	end
	
	if #validWalls == 0 then
		return nil
	end
	
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
	
	return validWalls[1]
end

return WallSpawnables
