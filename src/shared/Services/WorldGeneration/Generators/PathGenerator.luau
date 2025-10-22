--[[
	PathGenerator (Modular Segment System)
	
	Creates paths as DISCRETE PLATFORM SEGMENTS (like toy railway pieces)
	Each segment is a transparent bounding box that defines:
	- Where platforms can spawn
	- Where obstacles can be placed
	- The playable area
	
	Segments chain together with rotations between checkpoints.
]]

local PathGenerator = {}

-- Segment type weights (for random selection)
local SEGMENT_WEIGHTS = {
	Short = 20,
	Medium = 30,
	Long = 15,
	Wide = 10,
	Narrow = 10,
}

-- Connector types based on height difference
local function GetConnectorType(heightDiff: number, config: any): string
	local absHeight = math.abs(heightDiff)
	
	if absHeight <= config.ConnectorMaxFlatHeight then
		return "Flat"
	elseif absHeight <= config.ConnectorLadderHeight then
		return "Ladder"
	else
		return "Stairs"
	end
end

-- Create a connector between two positions
local function CreateConnector(
	startPos: Vector3,
	endPos: Vector3,
	segmentIndex: number,
	pathIndex: number,
	config: any
): any
	local heightDiff = endPos.Y - startPos.Y
	local connectorType = GetConnectorType(heightDiff, config)
	
	-- Calculate midpoint and dimensions
	local midpoint = (startPos + endPos) / 2
	local offset = endPos - startPos
	local distance = offset.Magnitude
	
	-- Determine color based on type
	local color, material
	if connectorType == "Flat" then
		color = Color3.fromRGB(200, 0, 255) -- Purple
		material = Enum.Material.Neon
	else
		color = Color3.fromRGB(139, 90, 43) -- Brown
		material = Enum.Material.Wood
	end
	
	-- Calculate rotation to point from start to end
	local direction = offset.Unit
	local yaw = math.atan2(direction.X, direction.Z)
	local pitch = math.asin(-direction.Y)
	
	return {
		Type = "SegmentConnector",
		Position = midpoint,
		Scale = Vector3.new(2, 2, distance), -- Thin line along distance
		Rotation = Vector3.new(math.deg(pitch), math.deg(yaw), 0),
		Properties = {
			ConnectorType = connectorType,
			SegmentIndex = segmentIndex,
			PathIndex = pathIndex,
			Material = material,
			Color = color,
			Transparency = 0.5,
			HeightDiff = heightDiff,
		}
	}
end

--[[
	Calculate total distance needed and pick segments to fill it
]]
local function PickSegmentsForDistance(targetDistance: number, segmentTypes: any, rng: Random): {string}
	local segments = {}
	local currentDistance = 0
	
	-- Build weighted list
	local weightedList = {}
	for segmentName, weight in pairs(SEGMENT_WEIGHTS) do
		for i = 1, weight do
			table.insert(weightedList, segmentName)
		end
	end
	
	-- Keep adding segments until we reach target distance
	local maxSegments = 50 -- Safety limit
	local segmentCount = 0
	
	while currentDistance < targetDistance and segmentCount < maxSegments do
		-- Pick random segment type
		local segmentType = weightedList[rng:NextInteger(1, #weightedList)]
		local segmentLength = segmentTypes[segmentType].Length
		
		-- Check if adding this segment overshoots too much
		local remaining = targetDistance - currentDistance
		
		if remaining < segmentLength * 0.5 and #segments > 0 then
			-- Too close, we're done
			break
		end
		
		table.insert(segments, segmentType)
		currentDistance = currentDistance + segmentLength
		segmentCount = segmentCount + 1
	end
	
	-- Ensure at least one segment
	if #segments == 0 then
		table.insert(segments, "Medium")
	end
	
	return segments
end

--[[
	Generate path segments between two checkpoints
	Returns array of PathSegment elements
]]
local function GenerateSegmentsBetween(
	startPos: Vector3,
	endPos: Vector3,
	pathIndex: number,
	segmentTypes: any,
	config: any,
	rng: Random
): {any}
	local elements = {}
	
	-- Calculate target distance
	local targetDistance = (endPos - startPos).Magnitude
	
	-- Pick segments to fill this distance
	local segmentNames = PickSegmentsForDistance(targetDistance, segmentTypes, rng)
	
	-- Starting orientation (point toward end checkpoint)
	local initialDirection = (endPos - startPos).Unit
	local currentYaw = math.atan2(initialDirection.X, initialDirection.Z)
	
	local currentPos = startPos
	local currentHeight = startPos.Y
	
	-- Track last segment end position for connectors
	local lastSegmentEnd = nil
	
	-- Place each segment
	for i, segmentName in ipairs(segmentNames) do
		local segmentDef = segmentTypes[segmentName]
		
		-- Steer toward target: Calculate direction to end checkpoint
		local toTarget = (endPos - currentPos)
		local horizontalToTarget = Vector3.new(toTarget.X, 0, toTarget.Z)
		local targetYaw = math.atan2(horizontalToTarget.X, horizontalToTarget.Z)
		
		-- Blend current yaw with target yaw (steering behavior)
		-- Last few segments: lock onto target more strongly
		local isNearEnd = i > (#segmentNames - 3)
		local steeringStrength = if isNearEnd then 0.8 else 0.3
		
		-- Interpolate toward target yaw
		local yawDiff = targetYaw - currentYaw
		-- Normalize angle difference to -pi to pi
		while yawDiff > math.pi do yawDiff = yawDiff - 2*math.pi end
		while yawDiff < -math.pi do yawDiff = yawDiff + 2*math.pi end
		
		currentYaw = currentYaw + (yawDiff * steeringStrength)
		
		-- Add small random variation (less aggressive now that we're steering)
		if not isNearEnd then
			local turnVariation = math.rad(rng:NextNumber(-20, 20))
			currentYaw = currentYaw + turnVariation
		end
		
		-- Calculate segment center position (move forward by half length)
		local halfLength = segmentDef.Length / 2
		local forwardOffset = CFrame.Angles(0, currentYaw, 0) * Vector3.new(0, 0, halfLength)
		local segmentCenter = currentPos + forwardOffset + Vector3.new(0, currentHeight - startPos.Y, 0)
		
		-- Create segment element (transparent bounding box)
		table.insert(elements, {
			Type = "PathSegment",
			Position = segmentCenter,
			Scale = Vector3.new(segmentDef.Width, segmentDef.Height, segmentDef.Length),
			Rotation = Vector3.new(0, math.deg(currentYaw), 0),
			Properties = {
				SegmentType = segmentName,
				SegmentIndex = i,
				PathIndex = pathIndex,
				Material = Enum.Material.ForceField,
				Color = Color3.fromRGB(150, 150, 255),
				Transparency = 0.3,
			}
		})
		
		-- Add START marker (green sphere at segment start)
		local startMarkerPos = currentPos + Vector3.new(0, currentHeight - startPos.Y, 0)
		table.insert(elements, {
			Type = "SegmentMarker",
			Position = startMarkerPos,
			Scale = Vector3.new(2, 2, 2),
			Properties = {
				MarkerType = "Start",
				SegmentIndex = i,
				PathIndex = pathIndex,
				Material = Enum.Material.Neon,
				Color = Color3.fromRGB(0, 255, 0), -- Green
			}
		})
		
		-- Create connector from last segment end to this segment start
		if lastSegmentEnd then
			local connector = CreateConnector(
				lastSegmentEnd,
				startMarkerPos,
				i,
				pathIndex,
				config
			)
			table.insert(elements, connector)
		end
		
		-- Move to end of this segment
		local fullForwardOffset = CFrame.Angles(0, currentYaw, 0) * Vector3.new(0, 0, segmentDef.Length)
		currentPos = currentPos + fullForwardOffset
		
		-- Add END marker (red sphere at segment end)
		local endMarkerPos = currentPos + Vector3.new(0, currentHeight - startPos.Y, 0)
		table.insert(elements, {
			Type = "SegmentMarker",
			Position = endMarkerPos,
			Scale = Vector3.new(2, 2, 2),
			Properties = {
				MarkerType = "End",
				SegmentIndex = i,
				PathIndex = pathIndex,
				Material = Enum.Material.Neon,
				Color = Color3.fromRGB(255, 0, 0), -- Red
			}
		})
		
		-- Store for next connector
		lastSegmentEnd = endMarkerPos
		
		-- Add height variation (steer toward target height too)
		if i < #segmentNames then
			local targetHeightDiff = endPos.Y - currentHeight
			local heightSteering = targetHeightDiff * 0.2 -- Gradual approach to target height
			local heightVariation = rng:NextNumber(-config.SegmentHeightVariation, config.SegmentHeightVariation)
			currentHeight = currentHeight + heightSteering + heightVariation
		end
	end
	
	return elements
end

--[[
	Main entry point: Generate all path segments for checkpoint pairs
]]
function PathGenerator.Generate(checkpointElements: {any}, config: any, rng: Random): {any}
	local elements = {}
	local totalSegments = 0
	
	local segmentTypes = config.PathSegments
	
	-- Generate segments between each checkpoint pair
	for i = 1, #checkpointElements - 1 do
		local startPos = checkpointElements[i].Position
		local endPos = checkpointElements[i + 1].Position
		
		local segmentElements = GenerateSegmentsBetween(
			startPos,
			endPos,
			i,
			segmentTypes,
			config,
			rng
		)
		
		for _, element in ipairs(segmentElements) do
			table.insert(elements, element)
			totalSegments = totalSegments + 1
		end
	end
	
	print(string.format("[PathGenerator] Generated %d modular segments", totalSegments))
	
	return elements
end

return PathGenerator
