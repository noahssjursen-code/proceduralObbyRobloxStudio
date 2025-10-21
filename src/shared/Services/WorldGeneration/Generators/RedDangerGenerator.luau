--[[
	RedDangerGenerator
	
	Generates RED external dangers.
	These are off the path - turrets, lasers, environmental hazards.
	Unreachable but still threatening.
]]

local RedDangerGenerator = {}

--[[
	Generate red external dangers around checkpoints
]]
function RedDangerGenerator.Generate(rng: Random, checkpointElements: {any}, config: any): {any}
	local elements = {}
	
	local dangersPerCheckpoint = config.DangersPerCheckpoint
	local spreadDistance = config.SpreadDistance
	local dotSize = config.Size
	local color = config.Color
	
	for _, checkpoint in checkpointElements do
		local basePos = checkpoint.Position
		
		for i = 1, dangersPerCheckpoint do
			-- Place at a distance from path (unreachable)
			local angle = rng:NextNumber() * math.pi * 2
			local distance = rng:NextNumber(spreadDistance * 0.7, spreadDistance)
			local heightOffset = rng:NextNumber(-20, 20)
			
			local offset = Vector3.new(
				math.cos(angle) * distance,
				heightOffset,
				math.sin(angle) * distance
			)
			
			table.insert(elements, {
				Type = "RedDanger",
				Position = basePos + offset,
				Scale = Vector3.new(dotSize, dotSize, dotSize),
				Properties = {
					Material = Enum.Material.Neon,
					Color = color,
					DangerType = "External", -- Could be "Turret", "Laser", etc.
				}
			})
		end
	end
	
	print(string.format("[RedDangerGenerator] Generated %d external dangers", #elements))
	return elements
end

return RedDangerGenerator

