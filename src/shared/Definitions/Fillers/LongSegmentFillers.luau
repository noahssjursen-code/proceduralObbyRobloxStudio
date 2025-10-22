--[[
	Long Segment Fillers
	
	Links fittings to Long segments (40 studs length at 1x scale).
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

-- Import fittings
local MovingPlatforms = require(script.Parent.Fittings.MovingPlatforms)
local StraightBridge = require(script.Parent.Fittings.StraightBridge)

local LongSegmentFillers = {}

LongSegmentFillers.MovingPlatforms = {
	ID = MovingPlatforms.ID .. "_Long",
	DisplayName = MovingPlatforms.DisplayName,
	CompatibleSegmentTypes = {"Long"},
	SpawnWeight = 50,
	Fitting = MovingPlatforms,
	BuilderFunction = MovingPlatforms.Build,
}

LongSegmentFillers.StraightBridge = {
	ID = StraightBridge.ID .. "_Long",
	DisplayName = StraightBridge.DisplayName,
	CompatibleSegmentTypes = {"Long"},
	SpawnWeight = 50,
	Fitting = StraightBridge,
	BuilderFunction = StraightBridge.Build,
}

function LongSegmentFillers.GetAll(): {FillerDefinition}
	return {
		LongSegmentFillers.MovingPlatforms,
		LongSegmentFillers.StraightBridge,
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
