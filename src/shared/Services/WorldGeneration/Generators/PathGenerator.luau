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
			StartPosition = startPos,  -- Store for building geometry
			EndPosition = endPos,      -- Store for building geometry
		}
	}
end

--[[
	Calculate total distance needed and pick segments to fill it
	The last segment will be adjusted to perfectly reach the target distance
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
	
	-- Keep adding segments until we're close to target distance
	local maxSegments = 50 -- Safety limit
	local segmentCount = 0
	
	while currentDistance < targetDistance and segmentCount < maxSegments do
		-- Pick random segment type
		local segmentType = weightedList[rng:NextInteger(1, #weightedList)]
		local segmentLength = segmentTypes[segmentType].Length
		
		-- Check if adding this segment would overshoot
		local remaining = targetDistance - currentDistance
		
		-- If this segment would overshoot by more than 20% of target distance, stop
		if remaining < segmentLength and remaining < targetDistance * 0.2 and #segments > 0 then
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
		
		-- STRAIGHT LINE: Calculate direction directly to end checkpoint
		local toTarget = (endPos - currentPos)
		local horizontalToTarget = Vector3.new(toTarget.X, 0, toTarget.Z)
		local targetYaw = math.atan2(horizontalToTarget.X, horizontalToTarget.Z)
		
		-- Use the target yaw directly (no steering, no random variation)
		currentYaw = targetYaw
		
		-- Calculate actual segment length (adjust last segment to reach target exactly)
		local segmentLength = segmentDef.Length
		if i == #segmentNames then
			-- Last segment: adjust length to reach the target checkpoint exactly
			local remainingDistance = (endPos - currentPos).Magnitude
			segmentLength = remainingDistance
		end
		
		-- Calculate segment center position (move forward by half length)
		local halfLength = segmentLength / 2
		local forwardOffset = CFrame.Angles(0, currentYaw, 0) * Vector3.new(0, 0, halfLength)
		local segmentCenter = currentPos + forwardOffset + Vector3.new(0, currentHeight - startPos.Y, 0)
		
		-- For the first segment, ensure it starts exactly at the checkpoint
		if i == 1 then
			-- Position first segment so its START edge aligns with checkpoint
			segmentCenter = startPos + Vector3.new(0, currentHeight - startPos.Y, 0) + forwardOffset
		end
		
		-- Create segment element (transparent bounding box)
		table.insert(elements, {
			Type = "PathSegment",
			Position = segmentCenter,
			Scale = Vector3.new(segmentDef.Width, segmentDef.Height, segmentLength), -- Use adjusted length
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
		
		-- FLAT: No connectors needed since all segments are at the same height
		-- (Connectors were only for height differences)
		
		-- Move to end of this segment
		local fullForwardOffset = CFrame.Angles(0, currentYaw, 0) * Vector3.new(0, 0, segmentLength)
		currentPos = currentPos + fullForwardOffset
		
		-- For the last segment, ensure it ends exactly at the target checkpoint
		if i == #segmentNames then
			-- Adjust currentPos to align with end checkpoint
			currentPos = endPos
		end
		
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
		
		-- FLAT: Keep all segments at the same height as start checkpoint
		-- No height changes between segments
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
	
	-- Find checkpoint start/end nodes
	local checkpointStarts = {}
	local checkpointEnds = {}
	
	for _, element in ipairs(checkpointElements) do
		if element.Type == "CheckpointStart" then
			checkpointStarts[element.Properties.CheckpointNumber] = element.Position
		elseif element.Type == "CheckpointEnd" then
			checkpointEnds[element.Properties.CheckpointNumber] = element.Position
		end
	end
	
	-- Generate segments between each checkpoint pair
	for i = 1, #checkpointElements - 1 do
		-- Find the end node of current checkpoint and start node of next checkpoint
		local startPos = checkpointEnds[i] -- End of current checkpoint
		local endPos = checkpointStarts[i + 1] -- Start of next checkpoint
		
		if startPos and endPos then
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
		else
			warn(string.format("[PathGenerator] Missing checkpoint nodes for path %d", i))
		end
	end
	
	print(string.format("[PathGenerator] Generated %d modular segments", totalSegments))
	
	return elements
end

return PathGenerator
