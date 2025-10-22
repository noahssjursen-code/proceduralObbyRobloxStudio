--[[
	Wide Segment Fillers
	
	Links fittings to Wide segments (15 studs length, 12 studs width at 1x scale).
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

-- Import fittings (uncomment as you add them)
-- local MyFitting = require(script.Parent.Fittings.MyFitting)

local WideSegmentFillers = {}

function WideSegmentFillers.GetAll(): {FillerDefinition}
	return {
		-- Add your fillers here
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
