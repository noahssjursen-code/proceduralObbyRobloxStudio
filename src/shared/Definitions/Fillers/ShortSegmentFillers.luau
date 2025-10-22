--[[
	Short Segment Fillers
	
	Links fittings to Short segments (10 studs length at 1x scale).
	Just references fittings from the repository.
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

-- Import fittings from repository (uncomment as you add them)
-- local MyFitting = require(script.Parent.Fittings.MyFitting)

local ShortSegmentFillers = {}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- FILLER DEFINITIONS (Link fittings here)
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Example:
-- ShortSegmentFillers.MyFitting = {
--     ID = MyFitting.ID .. "_Short",
--     DisplayName = MyFitting.DisplayName,
--     CompatibleSegmentTypes = {"Short"},
--     SpawnWeight = 50,
--     BuilderFunction = MyFitting.Build,
-- }

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- REGISTRY
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function ShortSegmentFillers.GetAll(): {FillerDefinition}
	return {
		-- Add your fillers here
	}
end

--[[
	Select a random filler for this segment type
]]
function ShortSegmentFillers.SelectRandom(rng: Random, currentScale: number): FillerDefinition?
	local allFillers = ShortSegmentFillers.GetAll()
	
	if #allFillers == 0 then
		return nil -- No fillers available yet
	end
	
	local validFillers = {}
	local totalWeight = 0
	
	-- Filter by scale constraints
	for _, filler in allFillers do
		local minScale = filler.MinScale or 0
		local maxScale = filler.MaxScale or math.huge
		
		if currentScale >= minScale and currentScale <= maxScale then
			table.insert(validFillers, filler)
			totalWeight += filler.SpawnWeight
		end
	end
	
	if #validFillers == 0 then
		return nil
	end
	
	-- Weighted random selection
	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	
	for _, filler in validFillers do
		cumulative += filler.SpawnWeight
		if roll <= cumulative then
			return filler
		end
	end
	
	return validFillers[1]
end

return ShortSegmentFillers
