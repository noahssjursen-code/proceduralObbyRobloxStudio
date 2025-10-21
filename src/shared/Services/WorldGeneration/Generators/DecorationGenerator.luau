--[[
	DecorationGenerator
	
	Generates cosmetic decorations (blue dots) throughout the world.
]]

local DecorationGenerator = {}

--[[
	Generate decorative elements scattered around
]]
function DecorationGenerator.Generate(rng: Random, checkpointElements: {any}, config: any): {any}
	local elements = {}
	
	local decorationsPerCheckpoint = config.DecorationsPerCheckpoint
	local spreadRadius = config.DecorationSpreadRadius
	local dotSizeMin = config.DotSizeMin
	local dotSizeMax = config.DotSizeMax
	local color = config.Color
	
	for _, checkpoint in checkpointElements do
		local basePos = checkpoint.Position
		
		for i = 1, decorationsPerCheckpoint do
			-- Random position around checkpoint
			local offsetX = rng:NextNumber(-spreadRadius, spreadRadius)
			local offsetY = rng:NextNumber(-spreadRadius, spreadRadius)
			local offsetZ = rng:NextNumber(-spreadRadius, spreadRadius)
			
			-- Random size variation
			local size = rng:NextNumber(dotSizeMin, dotSizeMax)
			
			table.insert(elements, {
				Type = "DecorationDot",
				Position = basePos + Vector3.new(offsetX, offsetY, offsetZ),
				Scale = Vector3.new(size, size, size),
				Properties = {
					Material = Enum.Material.Neon,
					Color = color,
					Brightness = 1,
				}
			})
		end
	end
	
	print(string.format("[DecorationGenerator] Generated %d decorations", #elements))
	
	return elements
end

return DecorationGenerator

