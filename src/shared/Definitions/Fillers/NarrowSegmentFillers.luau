--[[
	Narrow Segment Fillers
	
	Links fittings to Narrow segments (12 studs length, 5 studs width at 1x scale).
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

-- Import fittings
local ZigzagBridge = require(script.Parent.Fittings.ZigzagBridge)
local WallClimb = require(script.Parent.Fittings.WallClimb)

local NarrowSegmentFillers = {}

NarrowSegmentFillers.ZigzagBridge = {
	ID = ZigzagBridge.ID .. "_Narrow",
	DisplayName = ZigzagBridge.DisplayName,
	CompatibleSegmentTypes = {"Narrow"},
	SpawnWeight = 50,  -- Reduced weight to make room for WallClimb
	Fitting = ZigzagBridge, -- Reference to fitting module for metadata
	BuilderFunction = ZigzagBridge.Build,
}

NarrowSegmentFillers.WallClimb = {
	ID = WallClimb.ID .. "_Narrow",
	DisplayName = WallClimb.DisplayName,
	CompatibleSegmentTypes = {"Narrow"},
	SpawnWeight = 50,  -- Equal weight with ZigzagBridge
	Fitting = WallClimb, -- Reference to fitting module for metadata
	BuilderFunction = WallClimb.Build,
}

function NarrowSegmentFillers.GetAll(): {FillerDefinition}
	return {
		NarrowSegmentFillers.ZigzagBridge,
		NarrowSegmentFillers.WallClimb,
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
