--[[
	StructureGenerator
	
	Generates BROWN structures - the colossal architecture!
	- Massive pillars
	- Ancient ruins
	- Platforms
	- Background structures for scale
	
	PATH-AWARE: Pillars are placed perpendicular to the path direction
	to frame the path like a corridor, not block it.
]]

local StructureGenerator = {}

--[[
	Generate colossal pillars that frame the path
]]
function StructureGenerator.GeneratePillars(rng: Random, checkpointElements: {any}, config: any): {any}
	local elements = {}
	
	local pillarsPerCheckpoint = config.PillarsPerCheckpoint
	local minDistance = config.MinDistance
	local maxDistance = config.MaxDistance
	local minSize = config.MinSize
	local maxSize = config.MaxSize
	local color = config.Color
	
	for checkpointIndex = 1, #checkpointElements do
		local checkpoint = checkpointElements[checkpointIndex]
		local currentPos = checkpoint.Position
		
		-- Calculate path direction (from previous checkpoint or to next)
		local pathDirection = Vector3.new(0, 0, 1) -- Default forward
		
		if checkpointIndex > 1 and checkpointIndex < #checkpointElements then
			-- Mid-path: average direction from previous and to next
			local prevPos = checkpointElements[checkpointIndex - 1].Position
			local nextPos = checkpointElements[checkpointIndex + 1].Position
			
			local dirFromPrev = (currentPos - prevPos).Unit
			local dirToNext = (nextPos - currentPos).Unit
			pathDirection = (dirFromPrev + dirToNext).Unit
			
		elseif checkpointIndex == 1 then
			-- First checkpoint: direction to next
			if #checkpointElements > 1 then
				local nextPos = checkpointElements[2].Position
				pathDirection = (nextPos - currentPos).Unit
			end
			
		elseif checkpointIndex == #checkpointElements then
			-- Last checkpoint: direction from previous
			local prevPos = checkpointElements[checkpointIndex - 1].Position
			pathDirection = (currentPos - prevPos).Unit
		end
		
		-- Calculate perpendicular direction (to the sides of the path)
		local perpendicular = Vector3.new(-pathDirection.Z, 0, pathDirection.X).Unit
		
		-- Place pillars on BOTH SIDES of the path (perpendicular)
		for i = 1, pillarsPerCheckpoint do
			-- Alternate sides, or randomize
			local side = (i % 2 == 0) and 1 or -1
			local distance = rng:NextNumber(minDistance, maxDistance)
			
			-- Add some forward/backward variation along the path
			local alongPathOffset = rng:NextNumber(-20, 20)
			
			local offset = (perpendicular * side * distance) + (pathDirection * alongPathOffset)
			offset = offset + Vector3.new(0, rng:NextNumber(-30, -10), 0) -- Vertical offset
			
			-- Random pillar size (width and height)
			local width = rng:NextNumber(minSize, maxSize)
			local height = rng:NextNumber(minSize * 3, maxSize * 4)
			
			table.insert(elements, {
				Type = "BrownPillar",
				Position = currentPos + offset,
				Scale = Vector3.new(width, height, width),
				Properties = {
					Material = Enum.Material.Cobblestone,
					Color = color,
					StructureType = "Pillar",
					CheckpointIndex = checkpointIndex,
					Side = side, -- Left (-1) or Right (1)
				}
			})
		end
	end
	
	print(string.format("[StructureGenerator] Generated %d colossal pillars", #elements))
	return elements
end

return StructureGenerator

