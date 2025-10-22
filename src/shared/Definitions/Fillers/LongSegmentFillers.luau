--[[
	Long Segment Fillers
	
	Links fittings to Long segments (40 studs length at 1x scale).
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

-- Import fittings
local LavaJump = require(script.Parent.Fittings.LavaJump)

local LongSegmentFillers = {}

LongSegmentFillers.LavaJump = {
	ID = LavaJump.ID .. "_Long",
	DisplayName = LavaJump.DisplayName,
	CompatibleSegmentTypes = {"Long"},
	SpawnWeight = 100,
	Fitting = LavaJump, -- Reference to fitting module for metadata
	BuilderFunction = LavaJump.Build,
}

function LongSegmentFillers.GetAll(): {FillerDefinition}
	return {
		LongSegmentFillers.LavaJump,
	}
end

function LongSegmentFillers.SelectRandom(rng: Random, currentScale: number): FillerDefinition?
	local allFillers = LongSegmentFillers.GetAll()
	
	if #allFillers == 0 then
		return nil
	end
	
	return allFillers[rng:NextInteger(1, #allFillers)]
end

return LongSegmentFillers
