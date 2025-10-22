--[[
	Narrow Segment Fillers
	
	Links fittings to Narrow segments (12 studs length, 5 studs width at 1x scale).
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

-- Import fittings
local ZigzagBridge = require(script.Parent.Fittings.ZigzagBridge)

local NarrowSegmentFillers = {}

NarrowSegmentFillers.ZigzagBridge = {
	ID = ZigzagBridge.ID .. "_Narrow",
	DisplayName = ZigzagBridge.DisplayName,
	CompatibleSegmentTypes = {"Narrow"},
	SpawnWeight = 100,
	Fitting = ZigzagBridge, -- Reference to fitting module for metadata
	BuilderFunction = ZigzagBridge.Build,
}

function NarrowSegmentFillers.GetAll(): {FillerDefinition}
	return {
		NarrowSegmentFillers.ZigzagBridge,
	}
end

function NarrowSegmentFillers.SelectRandom(rng: Random, currentScale: number): FillerDefinition?
	local allFillers = NarrowSegmentFillers.GetAll()
	
	if #allFillers == 0 then
		return nil
	end
	
	return allFillers[rng:NextInteger(1, #allFillers)]
end

return NarrowSegmentFillers
