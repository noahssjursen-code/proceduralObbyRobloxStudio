--[[
	Gray Node Spawnable Definitions
	
	Loads walkable platform models from ReplicatedStorage/Assets/Spawnables/GrayNode.
	
	If no models are found, gray nodes will use simple placeholder dots instead.
	Drop models in the folder to replace the placeholders!
]]

local SpawnableTypes = require(script.Parent.SpawnableTypes)
local ModelLoader = require(script.Parent.ModelLoader)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

local GrayNodeSpawnables = {}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- CACHE
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Cache loaded models (only scan once!)
local cachedSpawnables: { SpawnableDefinition }? = nil
local isInitialized = false

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INITIALIZATION
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

--[[
	Initialize the cache at startup (call this ONCE before world generation)
]]
function GrayNodeSpawnables.Initialize()
	if isInitialized then
		return
	end
	
	-- Load models once
	cachedSpawnables = ModelLoader.LoadGrayNodeModels()
	isInitialized = true
	
	if #cachedSpawnables > 0 then
		print(string.format("[GrayNodeSpawnables] Loaded %d model(s) from Assets/Spawnables/GrayNode", #cachedSpawnables))
	else
		print("[GrayNodeSpawnables] No models found - using placeholder dots")
	end
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- UTILITIES
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

--[[
	Get all available spawnable models.
	
	CACHED: Returns the pre-loaded models (Initialize() must be called first!)
]]
function GrayNodeSpawnables.GetAll(): { SpawnableDefinition }
	-- Lazy initialize if not already done
	if not isInitialized then
		GrayNodeSpawnables.Initialize()
	end
	
	return cachedSpawnables or {}
end

--[[
	Select a random spawnable based on weights and scale constraints.
	
	Returns nil if no models are available (will use placeholder dots).
]]
function GrayNodeSpawnables.SelectRandom(rng: Random, currentScale: number): SpawnableDefinition?
	local allSpawnables = GrayNodeSpawnables.GetAll()
	
	-- No models available - return nil (will use placeholder)
	if #allSpawnables == 0 then
		return nil
	end
	
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
	
	-- No valid spawnables for this scale - return nil
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
	
	-- Fallback to first valid spawnable
	return validSpawnables[1]
end

return GrayNodeSpawnables

