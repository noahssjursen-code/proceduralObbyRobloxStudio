--[[
	PathGenerator
	
	3-TIER HIERARCHICAL PATH SYSTEM:
	- Tier 1 (Blue): Strategic nodes - major waypoints, large challenge zones
	- Tier 2 (Green): Control nodes - define curves between blue nodes
	- Tier 3 (Gray): Walkable nodes - dense surface for walking, obstacle placement
	
	Blue → Green → Gray (increasingly dense)
]]

local PathGenerator = {}

-- Path type functions
local PathTypes = {}

--[[
	Straight line (linear interpolation)
]]
function PathTypes.Straight(startPos: Vector3, endPos: Vector3, t: number): Vector3
	return startPos:Lerp(endPos, t)
end

--[[
	Quadratic Bezier curve (one control point)
]]
function PathTypes.QuadraticBezier(startPos: Vector3, endPos: Vector3, controlPoint: Vector3, t: number): Vector3
	local a = startPos:Lerp(controlPoint, t)
	local b = controlPoint:Lerp(endPos, t)
	return a:Lerp(b, t)
end

--[[
	Cubic Bezier curve (two control points)
]]
function PathTypes.CubicBezier(startPos: Vector3, endPos: Vector3, cp1: Vector3, cp2: Vector3, t: number): Vector3
	local a = startPos:Lerp(cp1, t)
	local b = cp1:Lerp(cp2, t)
	local c = cp2:Lerp(endPos, t)
	
	local d = a:Lerp(b, t)
	local e = b:Lerp(c, t)
	
	return d:Lerp(e, t)
end

--[[
	Wave pattern (sine wave perpendicular to path direction)
]]
function PathTypes.Wave(startPos: Vector3, endPos: Vector3, t: number, waveAmplitude: number, waveFrequency: number): Vector3
	local linearPos = startPos:Lerp(endPos, t)
	
	-- Calculate perpendicular direction
	local direction = (endPos - startPos).Unit
	local up = Vector3.new(0, 1, 0)
	local perpendicular = direction:Cross(up).Unit
	
	-- Add wave offset
	local waveOffset = math.sin(t * math.pi * waveFrequency) * waveAmplitude
	return linearPos + (perpendicular * waveOffset)
end

--[[
	Arc path (circular arc)
]]
function PathTypes.Arc(startPos: Vector3, endPos: Vector3, center: Vector3, t: number): Vector3
	local startOffset = startPos - center
	local endOffset = endPos - center
	
	-- Spherical interpolation around center
	local angle = math.acos(startOffset.Unit:Dot(endOffset.Unit))
	local axis = startOffset:Cross(endOffset).Unit
	
	local currentAngle = angle * t
	local rotatedOffset = CFrame.fromAxisAngle(axis, currentAngle) * startOffset
	
	return center + rotatedOffset
end

--[[
	Generate path between two points with curves
	Returns array of path segment elements (green dots)
]]
function PathGenerator.GeneratePathBetween(startPos: Vector3, endPos: Vector3, pathIndex: number, config: any, rng: Random): {any}
	local elements = {}
	
	local distance = (endPos - startPos).Magnitude
	local segmentCount = math.floor(distance / config.DotSpacing)
	
	-- Choose path type randomly (no sine waves)
	local pathTypeRoll = rng:NextNumber()
	local pathType = "QuadraticBezier" -- Default
	
	if pathTypeRoll < 0.15 then
		pathType = "Straight"
	elseif pathTypeRoll < 0.6 then
		pathType = "QuadraticBezier"
	elseif pathTypeRoll < 0.85 then
		pathType = "CubicBezier"
	else
		pathType = "Arc"
	end
	
	-- Generate control points for curves with 3D variation
	local midpoint = (startPos + endPos) / 2
	local direction = (endPos - startPos)
	
	-- Calculate perpendicular direction (horizontal)
	local perpendicular = Vector3.new(-direction.Z, 0, direction.X).Unit
	
	-- Add vertical component for more mystical, terrain-like paths
	local verticalOffset = rng:NextNumber(-distance * 0.15, distance * 0.15)
	
	-- Control point offset (perpendicular to path with vertical variation)
	local controlOffset = rng:NextNumber(distance * 0.15, distance * 0.35)
	local controlDirection = rng:NextNumber() > 0.5 and 1 or -1
	
	-- First control point (with vertical offset)
	local cp1 = midpoint + (perpendicular * controlOffset * controlDirection) + Vector3.new(0, verticalOffset, 0)
	
	-- Second control point (opposite side, different height)
	local verticalOffset2 = rng:NextNumber(-distance * 0.1, distance * 0.1)
	local cp2 = midpoint + (perpendicular * controlOffset * -controlDirection * 0.6) + Vector3.new(0, verticalOffset2, 0)
	
	-- Arc center (also with vertical variation)
	local arcCenter = midpoint + (perpendicular * controlOffset * controlDirection) + Vector3.new(0, verticalOffset * 0.5, 0)
	
	-- Generate dots along the path with terrain-like noise
	for i = 0, segmentCount do
		local t = i / segmentCount
		local position
		
		if pathType == "Straight" then
			position = PathTypes.Straight(startPos, endPos, t)
		elseif pathType == "QuadraticBezier" then
			position = PathTypes.QuadraticBezier(startPos, endPos, cp1, t)
		elseif pathType == "CubicBezier" then
			position = PathTypes.CubicBezier(startPos, endPos, cp1, cp2, t)
		elseif pathType == "Arc" then
			position = PathTypes.Arc(startPos, endPos, arcCenter, t)
		end
		
		-- Add subtle noise for terrain-like feel (controlled randomness)
		local noiseScale = distance * 0.02 -- Small variation
		local noise = Vector3.new(
			(rng:NextNumber() - 0.5) * noiseScale,
			(rng:NextNumber() - 0.5) * noiseScale,
			(rng:NextNumber() - 0.5) * noiseScale
		)
		position = position + noise
		
		local size = config.DotSize
		table.insert(elements, {
			Type = "PathDot",
			Position = position,
			Scale = Vector3.new(size, size, size),
			Properties = {
				Material = Enum.Material.Neon,
				Color = config.Color,
				PathIndex = pathIndex,
				PathType = pathType,
			}
		})
	end
	
	return elements
end

--[[
	TIER 1: Generate Blue Strategic Nodes between checkpoints
	Returns major waypoints (furthest apart)
]]
function PathGenerator.GenerateBlueNodes(startPos: Vector3, endPos: Vector3, rng: Random, spacing: number): {Vector3}
	local blueNodes = {startPos}
	
	local distance = (endPos - startPos).Magnitude
	local nodeCount = math.floor(distance / (distance * spacing))
	
	if nodeCount < 1 then
		nodeCount = 1
	end
	
	-- Generate intermediate blue nodes with major variation
	local direction = (endPos - startPos)
	local perpendicular = Vector3.new(-direction.Z, 0, direction.X).Unit
	
	for i = 1, nodeCount do
		local t = i / (nodeCount + 1)
		local linearPos = startPos:Lerp(endPos, t)
		
		-- Large curve variation for strategic nodes
		local curveOffset = rng:NextNumber(-distance * 0.2, distance * 0.2)
		local heightOffset = rng:NextNumber(-distance * 0.1, distance * 0.1)
		
		local node = linearPos + (perpendicular * curveOffset) + Vector3.new(0, heightOffset, 0)
		table.insert(blueNodes, node)
	end
	
	table.insert(blueNodes, endPos)
	
	return blueNodes
end

--[[
	TIER 2: Generate Green Control Nodes between blue nodes
	Returns curve control points (medium spacing)
]]
function PathGenerator.GenerateGreenNodes(startPos: Vector3, endPos: Vector3, rng: Random, spacing: number): {Vector3}
	local greenNodes = {startPos}
	
	local distance = (endPos - startPos).Magnitude
	local nodeCount = math.floor(distance / (distance * spacing))
	
	if nodeCount < 1 then
		nodeCount = 1
	end
	
	local direction = (endPos - startPos)
	local perpendicular = Vector3.new(-direction.Z, 0, direction.X).Unit
	
	for i = 1, nodeCount do
		local t = i / (nodeCount + 1)
		local linearPos = startPos:Lerp(endPos, t)
		
		-- Medium curve variation for control nodes
		local curveOffset = rng:NextNumber(-distance * 0.1, distance * 0.1)
		local heightOffset = rng:NextNumber(-distance * 0.05, distance * 0.05)
		
		local node = linearPos + (perpendicular * curveOffset) + Vector3.new(0, heightOffset, 0)
		table.insert(greenNodes, node)
	end
	
	table.insert(greenNodes, endPos)
	
	return greenNodes
end

--[[
	TIER 3: Generate Gray Walkable Nodes between green nodes
	Returns dense surface dots (closest together)
]]
function PathGenerator.GenerateGrayNodes(startPos: Vector3, endPos: Vector3, rng: Random, spacing: number): {Vector3}
	local grayNodes = {}
	
	local distance = (endPos - startPos).Magnitude
	local nodeCount = math.floor(distance / spacing)
	
	if nodeCount < 1 then
		nodeCount = 1
	end
	
	for i = 0, nodeCount do
		local t = i / nodeCount
		local position = startPos:Lerp(endPos, t)
		
		-- Tiny variation for natural feel
		local noise = Vector3.new(
			(rng:NextNumber() - 0.5) * spacing * 0.3,
			(rng:NextNumber() - 0.5) * spacing * 0.3,
			(rng:NextNumber() - 0.5) * spacing * 0.3
		)
		
		table.insert(grayNodes, position + noise)
	end
	
	return grayNodes
end

--[[
	Generate all paths for a list of checkpoints
	Creates 3-TIER system: Blue → Green → Gray
]]
function PathGenerator.Generate(checkpointElements: {any}, config: any, rng: Random): {any}
	local elements = {}
	local blueCount = 0
	local greenCount = 0
	local grayCount = 0
	
	for i = 1, #checkpointElements - 1 do
		local startPos = checkpointElements[i].Position
		local endPos = checkpointElements[i + 1].Position
		
		-- TIER 1: Generate Blue Strategic Nodes
		local blueNodes = PathGenerator.GenerateBlueNodes(startPos, endPos, rng, config.BlueNodeSpacing)
		
		-- Spawn blue nodes (skip first/last - they're checkpoints)
		for j = 2, #blueNodes - 1 do
			table.insert(elements, {
				Type = "BlueNode",
				Position = blueNodes[j],
				Scale = Vector3.new(config.BlueNodeSize, config.BlueNodeSize, config.BlueNodeSize),
				Properties = {
					Material = Enum.Material.Neon,
					Color = config.BlueNodeColor,
					PathIndex = i,
					NodeIndex = j,
				}
			})
			blueCount = blueCount + 1
		end
		
		-- TIER 2: Generate Green Control Nodes between each pair of blue nodes
		for j = 1, #blueNodes - 1 do
			local greenNodes = PathGenerator.GenerateGreenNodes(blueNodes[j], blueNodes[j + 1], rng, config.GreenNodeSpacing)
			
			-- Spawn green nodes (skip first/last - they're blue nodes)
			for k = 2, #greenNodes - 1 do
				table.insert(elements, {
					Type = "GreenNode",
					Position = greenNodes[k],
					Scale = Vector3.new(config.GreenNodeSize, config.GreenNodeSize, config.GreenNodeSize),
					Properties = {
						Material = Enum.Material.Neon,
						Color = config.GreenNodeColor,
						PathIndex = i,
					}
				})
				greenCount = greenCount + 1
			end
			
			-- TIER 3: Generate Gray Walkable Nodes between each pair of green nodes
			for k = 1, #greenNodes - 1 do
				local grayNodes = PathGenerator.GenerateGrayNodes(greenNodes[k], greenNodes[k + 1], rng, config.GrayNodeSpacing)
				
				for m = 1, #grayNodes do
					local grayPos = grayNodes[m]
					
					-- Calculate forward direction (toward next node, or maintain direction if last)
					local forward = Vector3.new(0, 0, -1) -- Default forward
					if m < #grayNodes then
						-- Point toward next gray node
						forward = (grayNodes[m + 1] - grayPos).Unit
					elseif k < #greenNodes - 1 then
						-- Last gray node in segment, point toward next green node
						forward = (greenNodes[k + 1] - grayPos).Unit
					end
					
					table.insert(elements, {
						Type = "GrayNode",
						Position = grayPos,
						Forward = forward,
						Scale = Vector3.new(config.GrayNodeSize, config.GrayNodeSize, config.GrayNodeSize),
						Properties = {
							Material = Enum.Material.SmoothPlastic,
							Color = config.GrayNodeColor,
							PathIndex = i,
							IsWalkable = true, -- Obstacles spawn on these!
						}
					})
					grayCount = grayCount + 1
				end
			end
		end
	end
	
	print(string.format("[PathGenerator] 3-Tier System: %d blue + %d green + %d gray nodes", 
		blueCount, greenCount, grayCount))
	
	return elements
end

return PathGenerator

