--[[
	Medium Segment Fillers
	
	Links fittings to Medium segments (20 studs length at 1x scale).
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

-- Import fittings
local LavaJump = require(script.Parent.Fittings.LavaJump)

local MediumSegmentFillers = {}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- DEFINITIONS
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MediumSegmentFillers.LavaJump = {
	ID = LavaJump.ID .. "_Medium",
	DisplayName = LavaJump.DisplayName,
	CompatibleSegmentTypes = {"Medium"},
	SpawnWeight = 100,
	Fitting = LavaJump, -- Reference to fitting module for metadata
	BuilderFunction = LavaJump.Build,
}

function MediumSegmentFillers.GetAll(): {FillerDefinition}
	return {
		MediumSegmentFillers.LavaJump,
	}
end

function MediumSegmentFillers.SelectRandom(rng: Random, currentScale: number): FillerDefinition?
	local allFillers = MediumSegmentFillers.GetAll()
	
	if #allFillers == 0 then
		return nil
	end
	
	local validFillers = {}
	local totalWeight = 0
	
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

return MediumSegmentFillers
