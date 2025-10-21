--[[
	PinkObstacleGenerator
	
	Generates PINK obstacles directly ON the path.
	- Small pink: Simple blocking obstacles
	- Large pink: Area hazards (swinging axes, spinning blades, etc.)
]]

local PinkObstacleGenerator = {}

--[[
	Generate small pink obstacles on path
]]
function PinkObstacleGenerator.GenerateSmall(rng: Random, pathElements: {any}, config: any): {any}
	local elements = {}
	
	local frequency = config.Frequency
	local dotSize = config.Size
	local color = config.Color
	
	for _, pathDot in pathElements do
		if rng:NextNumber() < frequency then
			table.insert(elements, {
				Type = "PinkObstacleSmall",
				Position = pathDot.Position,
				Forward = pathDot.Forward, -- Inherit path direction
				Scale = Vector3.new(dotSize, dotSize, dotSize),
				Properties = {
					Material = Enum.Material.Neon,
					Color = color,
					PathIndex = pathDot.Properties.PathIndex,
				}
			})
		end
	end
	
	print(string.format("[PinkObstacleGenerator] Generated %d small obstacles", #elements))
	return elements
end

--[[
	Generate large pink area hazards on path
]]
function PinkObstacleGenerator.GenerateLarge(rng: Random, pathElements: {any}, config: any): {any}
	local elements = {}
	
	local frequency = config.Frequency
	local dotSize = config.Size
	local color = config.Color
	
	for _, pathDot in pathElements do
		if rng:NextNumber() < frequency then
			table.insert(elements, {
				Type = "PinkObstacleLarge",
				Position = pathDot.Position,
				Forward = pathDot.Forward, -- Inherit path direction
				Scale = Vector3.new(dotSize, dotSize, dotSize),
				Properties = {
					Material = Enum.Material.Neon,
					Color = color,
					PathIndex = pathDot.Properties.PathIndex,
					HazardType = "Area", -- Could be "Swinging", "Spinning", etc.
				}
			})
		end
	end
	
	print(string.format("[PinkObstacleGenerator] Generated %d large area hazards", #elements))
	return elements
end

return PinkObstacleGenerator

