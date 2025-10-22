--[[
	Wide Segment Fillers
	
	Links fittings to Wide segments (15 studs length, 12 studs width at 1x scale).
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

-- Import fittings
local ScatteredPlatforms = require(script.Parent.Fittings.ScatteredPlatforms)

local WideSegmentFillers = {}

WideSegmentFillers.ScatteredPlatforms = {
	ID = ScatteredPlatforms.ID .. "_Wide",
	DisplayName = ScatteredPlatforms.DisplayName,
	CompatibleSegmentTypes = {"Wide"},
	SpawnWeight = 100,
	Fitting = ScatteredPlatforms,
	BuilderFunction = ScatteredPlatforms.Build,
}

function WideSegmentFillers.GetAll(): {FillerDefinition}
	return {
		WideSegmentFillers.ScatteredPlatforms,
	}
end

function WideSegmentFillers.SelectRandom(rng: Random, currentScale: number): FillerDefinition?
	local allFillers = WideSegmentFillers.GetAll()
	
	if #allFillers == 0 then
		return nil
	end
	
	return allFillers[rng:NextInteger(1, #allFillers)]
end

return WideSegmentFillers
