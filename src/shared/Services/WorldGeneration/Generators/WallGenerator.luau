--[[
	WallGenerator
	
	Generates walls/barriers along paths (orange dots).
]]

local WallGenerator = {}

--[[
	Generate walls along a path segment
]]
function WallGenerator.Generate(rng: Random, pathElements: {any}, config: any): {any}
	local elements = {}
	
	local wallChance = config.WallChance
	local wallOffset = config.WallOffset
	local dotSize = config.DotSize
	local color = config.Color
	
	-- Group path elements by PathIndex
	local pathGroups = {}
	for _, pathDot in pathElements do
		local pathIndex = pathDot.Properties.PathIndex
		if not pathGroups[pathIndex] then
			pathGroups[pathIndex] = {}
		end
		table.insert(pathGroups[pathIndex], pathDot)
	end
	
	-- Add walls to some path segments
	for pathIndex, pathDots in pathGroups do
		if rng:NextNumber() < wallChance then
			-- Add walls on both sides of path
			for i = 1, #pathDots, 3 do -- Every 3rd dot gets walls
				local pathDot = pathDots[i]
				local pos = pathDot.Position
				
				-- Calculate path forward direction
				local forward = pathDot.Forward
				if not forward and i < #pathDots then
					-- Fallback: calculate from next dot
					forward = (pathDots[i + 1].Position - pos).Unit
				end
				if not forward then
					forward = Vector3.new(0, 0, -1) -- Default
				end
				
				-- Calculate perpendicular (right) direction
				local right = Vector3.new(forward.Z, 0, -forward.X).Unit
				
				-- Random side (left or right, or both)
				local side = rng:NextInteger(1, 3)
				
				if side == 1 or side == 3 then
					-- Left wall (opposite of right direction, facing path)
					local wallPos = pos + (-right * wallOffset)
					table.insert(elements, {
						Type = "WallDot",
						Position = wallPos,
						Forward = right, -- Face inward toward path
						Scale = Vector3.new(dotSize, dotSize, dotSize),
						Properties = {
							Material = Enum.Material.Neon,
							Color = color,
						}
					})
				end
				
				if side == 2 or side == 3 then
					-- Right wall (facing path)
					local wallPos = pos + (right * wallOffset)
					table.insert(elements, {
						Type = "WallDot",
						Position = wallPos,
						Forward = -right, -- Face inward toward path
						Scale = Vector3.new(dotSize, dotSize, dotSize),
						Properties = {
							Material = Enum.Material.Neon,
							Color = color,
						}
					})
				end
			end
		end
	end
	
	print(string.format("[WallGenerator] Generated %d wall dots", #elements))
	
	return elements
end

return WallGenerator

