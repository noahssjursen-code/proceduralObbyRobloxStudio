--[[
	Connector Builder
	
	Generates walkable ladders and stairs between segments based on height difference.
	Creates proper geometry instead of visual guide lines.
]]

local ConnectorBuilder = {}

--[[
	Build a flat connector (simple platform bridge)
]]
function ConnectorBuilder.BuildFlat(
	startPos: Vector3,
	endPos: Vector3,
	width: number
): Model
	local model = Instance.new("Model")
	model.Name = "FlatConnector"
	
	local midpoint = (startPos + endPos) / 2
	local offset = endPos - startPos
	local distance = offset.Magnitude
	
	-- Calculate rotation
	local direction = offset.Unit
	local yaw = math.atan2(direction.X, direction.Z)
	local pitch = math.asin(-direction.Y)
	
	-- Create flat bridge platform
	local platform = Instance.new("Part")
	platform.Name = "ConnectorPlatform"
	platform.Size = Vector3.new(width, 1, distance)
	platform.Material = Enum.Material.Neon
	platform.Color = Color3.fromRGB(200, 0, 255)  -- Purple
	platform.Anchored = true
	platform.CanCollide = true
	platform.CFrame = CFrame.new(midpoint) 
		* CFrame.Angles(pitch, yaw, 0)
	platform.Parent = model
	
	return model
end

--[[
	Build a ladder connector (vertical rungs)
]]
function ConnectorBuilder.BuildLadder(
	startPos: Vector3,
	endPos: Vector3,
	width: number
): Model
	local model = Instance.new("Model")
	model.Name = "LadderConnector"
	
	local midpoint = (startPos + endPos) / 2
	local offset = endPos - startPos
	local distance = offset.Magnitude
	local heightDiff = endPos.Y - startPos.Y
	
	-- Calculate rotation
	local direction = offset.Unit
	local yaw = math.atan2(direction.X, direction.Z)
	local pitch = math.asin(-direction.Y)
	
	-- Create ladder rail (central beam aligned with climb direction)
	local rail = Instance.new("Part")
	rail.Name = "LadderRail"
	rail.Size = Vector3.new(0.8, 0.8, distance)
	rail.Material = Enum.Material.Wood
	rail.Color = Color3.fromRGB(139, 90, 43)  -- Brown
	rail.Anchored = true
	rail.CanCollide = false
	
	-- Orient rail from start to end (pitch controls the climb angle)
	rail.CFrame = CFrame.new(midpoint) 
		* CFrame.Angles(pitch, yaw, 0)
	rail.Parent = model
	
	-- Create rungs (horizontal platforms for player to stand on)
	local rungSpacing = 2  -- Player-scale spacing between rungs
	local rungCount = math.max(2, math.floor(distance / rungSpacing))
	
	for i = 0, rungCount do
		local t = i / rungCount  -- 0 to 1
		local rungPos = startPos:Lerp(endPos, t)
		
		local rung = Instance.new("Part")
		rung.Name = "LadderRung" .. i
		rung.Size = Vector3.new(width, 0.8, 2)  -- Wide platform for standing
		rung.Material = Enum.Material.Wood
		rung.Color = Color3.fromRGB(120, 80, 40)  -- Darker brown
		rung.Anchored = true
		rung.CanCollide = true  -- Walkable rungs
		
		-- Rungs stay HORIZONTAL (only yaw rotation, no pitch)
		-- This makes them flat platforms you can stand on
		rung.CFrame = CFrame.new(rungPos) * CFrame.Angles(0, yaw, 0)
		rung.Parent = model
	end
	
	return model
end

--[[
	Build a stairs connector (stepped platforms)
]]
function ConnectorBuilder.BuildStairs(
	startPos: Vector3,
	endPos: Vector3,
	width: number
): Model
	local model = Instance.new("Model")
	model.Name = "StairsConnector"
	
	local offset = endPos - startPos
	local distance = offset.Magnitude
	local heightDiff = endPos.Y - startPos.Y
	
	-- Calculate rotation
	local direction = offset.Unit
	local yaw = math.atan2(direction.X, direction.Z)
	
	-- Calculate number of steps based on height difference
	local stepHeight = 2  -- Player-scale comfortable step height
	local stepCount = math.max(3, math.ceil(math.abs(heightDiff) / stepHeight))
	
	-- Calculate step dimensions
	local horizontalDistance = math.sqrt(offset.X * offset.X + offset.Z * offset.Z)
	local stepDepth = horizontalDistance / stepCount
	local actualStepHeight = heightDiff / stepCount
	
	-- Create steps
	for i = 0, stepCount - 1 do
		local t = i / stepCount
		local stepStartPos = startPos:Lerp(endPos, t)
		
		-- Calculate step center (halfway through this step)
		local stepCenterT = (i + 0.5) / stepCount
		local stepCenterPos = startPos:Lerp(endPos, stepCenterT)
		
		local step = Instance.new("Part")
		step.Name = "Step" .. (i + 1)
		step.Size = Vector3.new(width, 1, stepDepth)
		step.Material = Enum.Material.Wood
		step.Color = Color3.fromRGB(139, 90, 43)  -- Brown
		step.Anchored = true
		step.CanCollide = true
		step.CFrame = CFrame.new(stepCenterPos) 
			* CFrame.Angles(0, yaw, 0)
		step.Parent = model
		
		-- Add side support beams for visual interest
		if i % 2 == 0 then
			local support = Instance.new("Part")
			support.Name = "Support" .. (i + 1)
			support.Size = Vector3.new(0.5, math.abs(actualStepHeight) * (i + 1), 0.5)
			support.Material = Enum.Material.Wood
			support.Color = Color3.fromRGB(100, 70, 40)  -- Darker brown
			support.Anchored = true
			support.CanCollide = false
			
			-- Position support below step
			local supportOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(width * 0.4, -support.Size.Y / 2, 0)
			support.CFrame = CFrame.new(stepCenterPos + supportOffset)
			support.Parent = model
		end
	end
	
	-- Add final landing platform at end
	local landing = Instance.new("Part")
	landing.Name = "Landing"
	landing.Size = Vector3.new(width, 1, stepDepth * 1.5)
	landing.Material = Enum.Material.Wood
	landing.Color = Color3.fromRGB(139, 90, 43)
	landing.Anchored = true
	landing.CanCollide = true
	
	-- Position landing at the end
	local landingOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(0, 0, stepDepth * 0.75)
	landing.CFrame = CFrame.new(endPos + landingOffset) 
		* CFrame.Angles(0, yaw, 0)
	landing.Parent = model
	
	return model
end

--[[
	Main build function - creates appropriate connector based on type
	
	@param connectorType - "Flat", "Ladder", or "Stairs"
	@param startPos - Starting position (Vector3)
	@param endPos - Ending position (Vector3)
	@param width - Width of connector (optional, defaults to 4 studs)
	@return Model containing connector geometry
]]
function ConnectorBuilder.Build(
	connectorType: string,
	startPos: Vector3,
	endPos: Vector3,
	width: number?
): Model
	local connectorWidth = width or 4  -- Default 4 studs wide (player-scale)
	
	if connectorType == "Flat" then
		return ConnectorBuilder.BuildFlat(startPos, endPos, connectorWidth)
	elseif connectorType == "Ladder" then
		return ConnectorBuilder.BuildLadder(startPos, endPos, connectorWidth)
	elseif connectorType == "Stairs" then
		return ConnectorBuilder.BuildStairs(startPos, endPos, connectorWidth)
	else
		warn("Unknown connector type:", connectorType)
		return ConnectorBuilder.BuildFlat(startPos, endPos, connectorWidth)
	end
end

return ConnectorBuilder

