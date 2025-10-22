--[[
	PurpleObstacleGenerator
	
	Generates DARK PURPLE dynamic obstacles.
	Moving platforms, rotating hazards, patrolling obstacles.
]]

local PurpleObstacleGenerator = {}

--[[
	Generate purple dynamic obstacles on paths
]]
function PurpleObstacleGenerator.Generate(rng: Random, pathElements: {any}, config: any): {any}
	local elements = {}
	
	local frequency = config.Frequency
	local dotSize = config.Size
	local color = config.Color
	
	for _, pathDot in pathElements do
		-- Skip checkpoint positions to avoid creating gaps
		if pathDot.Type == "CheckpointOrb" or pathDot.Type == "CheckpointStart" or pathDot.Type == "CheckpointEnd" then
			continue
		end
		
		if rng:NextNumber() < frequency then
			-- Random dynamic behavior type
			local behaviors = {"Moving", "Rotating", "Patrolling"}
			local behavior = behaviors[rng:NextInteger(1, #behaviors)]
			
		table.insert(elements, {
			Type = "PurpleObstacleDynamic",
			Position = pathDot.Position,
			Forward = pathDot.Forward, -- Inherit path direction
			Scale = Vector3.new(dotSize, dotSize, dotSize),
			Properties = {
				Material = Enum.Material.Neon,
				Color = color,
				PathIndex = pathDot.Properties.PathIndex,
				DynamicType = behavior,
				}
			})
		end
	end
	
	print(string.format("[PurpleObstacleGenerator] Generated %d dynamic obstacles", #elements))
	return elements
end

return PurpleObstacleGenerator

