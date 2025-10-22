--[[
	Gray Node Spawnable Definitions
	
	Walkable platform definitions (purely procedural - no models).
]]

local SpawnableTypes = require(script.Parent.SpawnableTypes)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

local GrayNodeSpawnables = {}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- DEFINITIONS
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GrayNodeSpawnables.StandardPlatform = {
	ID = "StandardPlatform",
	DisplayName = "Standard Platform",
	Category = "GrayNode",
	
	BuildMode = "SimplePart",
	Shape = Enum.PartType.Ball,
	Size = Vector3.new(1, 1, 1),
	Color = Color3.fromRGB(150, 150, 150),
	Material = Enum.Material.SmoothPlastic,
	
	CanCollide = true,
	Anchored = true,
	Massless = true,
	
	SpawnWeight = 100,
}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- REGISTRY
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function GrayNodeSpawnables.GetAll(): { SpawnableDefinition }
	return {
		GrayNodeSpawnables.StandardPlatform,
	}
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SELECTION
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function GrayNodeSpawnables.SelectRandom(rng: Random, currentScale: number): SpawnableDefinition?
	local allSpawnables = GrayNodeSpawnables.GetAll()
	local validSpawnables = {}
	local totalWeight = 0
	
	-- Filter by scale constraints
	for _, spawnable in allSpawnables do
		local minScale = spawnable.MinScale or 0
		local maxScale = spawnable.MaxScale or math.huge
		
		if currentScale >= minScale and currentScale <= maxScale then
			table.insert(validSpawnables, spawnable)
			totalWeight += spawnable.SpawnWeight
		end
	end
	
	if #validSpawnables == 0 then
		return nil
	end
	
	-- Weighted random selection
	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	
	for _, spawnable in validSpawnables do
		cumulative += spawnable.SpawnWeight
		if roll <= cumulative then
			return spawnable
		end
	end
	
	return validSpawnables[1]
end

return GrayNodeSpawnables
