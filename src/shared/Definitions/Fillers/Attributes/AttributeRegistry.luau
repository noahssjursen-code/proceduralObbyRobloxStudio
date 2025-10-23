--[[
	Attribute Registry
	
	Central registry for all available attributes.
	Manages which attributes can spawn and their weights/chances.
]]

local AttributeTypes = require(script.Parent.AttributeTypes)
type AttributeDefinition = AttributeTypes.AttributeDefinition
type AttributeSpawnEntry = AttributeTypes.AttributeSpawnEntry

-- Import all attributes
local SpinningBlades = require(script.Parent.SpinningBlades)
local WallPushers = require(script.Parent.WallPushers)
local LaserGrid = require(script.Parent.LaserGrid)
local KillBricks = require(script.Parent.KillBricks)

local AttributeRegistry = {}

--[[
	Global pool of available attributes.
	Each entry defines spawn weight and chance.
]]
local ATTRIBUTE_POOL: {AttributeSpawnEntry} = {
	{
		Attribute = SpinningBlades,
		SpawnWeight = 100,
		SpawnChance = 0.4,  -- 40% chance to spawn in a slot
	},
	{
		Attribute = WallPushers,
		SpawnWeight = 100,
		SpawnChance = 0.35,  -- 35% chance to spawn in a slot
	},
	{
		Attribute = LaserGrid,
		SpawnWeight = 100,
		SpawnChance = 0.3,  -- 30% chance to spawn in a slot
	},
	{
		Attribute = KillBricks,
		SpawnWeight = 100,
		SpawnChance = 0.4,  -- 40% chance to spawn in a slot
	},
	
	-- Add more attributes here as you create them:
	-- {
	--     Attribute = NextAttribute,
	--     SpawnWeight = 80,
	--     SpawnChance = 0.3,
	-- },
}

--[[
	Get all registered attributes.
]]
function AttributeRegistry.GetAll(): {AttributeSpawnEntry}
	return ATTRIBUTE_POOL
end

--[[
	Get attributes compatible with a specific fitting.
	
	@param fittingID - ID of the fitting to check compatibility with
	@return Array of compatible AttributeSpawnEntry
]]
function AttributeRegistry.GetCompatibleAttributes(fittingID: string): {AttributeSpawnEntry}
	local compatible = {}
	
	for _, entry in ATTRIBUTE_POOL do
		local attr = entry.Attribute
		
		-- Check if attribute is compatible
		if attr.CompatibleFittings then
			-- Check for "all" or specific fitting ID
			local isCompatible = false
			for _, compatibleID in attr.CompatibleFittings do
				if compatibleID == "all" or compatibleID == fittingID then
					isCompatible = true
					break
				end
			end
			
			if isCompatible then
				table.insert(compatible, entry)
			end
		end
	end
	
	return compatible
end

--[[
	Select a random attribute from compatible pool using weighted random.
	
	@param fittingID - ID of the fitting
	@param rng - Seeded Random object
	@return AttributeDefinition or nil
]]
function AttributeRegistry.SelectRandom(fittingID: string, rng: Random): AttributeDefinition?
	local compatible = AttributeRegistry.GetCompatibleAttributes(fittingID)
	
	if #compatible == 0 then
		return nil
	end
	
	-- Calculate total weight
	local totalWeight = 0
	for _, entry in compatible do
		totalWeight += entry.SpawnWeight
	end
	
	if totalWeight == 0 then
		return nil
	end
	
	-- Weighted random selection
	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	
	for _, entry in compatible do
		cumulative += entry.SpawnWeight
		if roll <= cumulative then
			return entry.Attribute
		end
	end
	
	return compatible[1].Attribute -- Fallback
end

--[[
	Check if a slot should spawn an attribute.
	Uses the SpawnChance from the entry.
	
	@param entry - AttributeSpawnEntry
	@param rng - Seeded Random object
	@return boolean
]]
function AttributeRegistry.ShouldSpawnAttribute(entry: AttributeSpawnEntry, rng: Random): boolean
	return rng:NextNumber(0, 1) <= entry.SpawnChance
end

return AttributeRegistry

