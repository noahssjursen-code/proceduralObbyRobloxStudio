--[[
	Zigzag Bridge Fitting
	
	A narrow bridge that weaves left and right with gaps for jumping.
	Procedurally generated with random variation.
]]

local ZigzagBridge = {}

ZigzagBridge.ID = "ZigzagBridge"
ZigzagBridge.DisplayName = "Zigzag Bridge"

-- Slot configuration for attributes
ZigzagBridge.AllowAttributes = true  -- Can have attributes added on top
ZigzagBridge.SlotCount = nil  -- Use default from Config (5 for Narrow)

function ZigzagBridge.Build(
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "ZigzagBridge"
	
	local width = segmentScale.X
	local length = segmentScale.Z
	local yaw = math.rad(segmentRotation.Y)
	
	-- Bridge configuration (player-scale)
	local bridgeWidth = 2 -- Very narrow bridge width
	local zigzagAmount = width * 0.35 -- How far left/right to zigzag (increased)
	
	-- Random number of sections for variety
	local minSections = 3
	local maxSections = math.floor(length / 5)
	local sectionCount = rng:NextInteger(minSections, math.max(minSections, maxSections))
	
	-- Define absolute start and end positions (at segment boundaries)
	local absoluteStart = -length * 0.5
	local absoluteEnd = length * 0.5
	local totalDistance = absoluteEnd - absoluteStart
	
	-- Track positions for connecting sections
	local previousEndForward = absoluteStart
	local previousLateralOffset = 0
	
	-- Create zigzagging bridge sections (they connect!)
	local zigzagDirection = 1 -- Start going right
	
	for i = 1, sectionCount do
		-- Calculate zigzag offset for this section (MORE RANDOM)
		local randomVariation = rng:NextNumber(-0.4, 0.4) -- Increased variation
		local zigzagIntensity = rng:NextNumber(0.5, 1.0) -- Random intensity per section
		
		-- First and last sections should not zigzag (for clean connections)
		local isStartSection = (i == 1)
		local isEndSection = (i == sectionCount)
		local targetLateralOffset
		
		if isStartSection then
			targetLateralOffset = 0 -- Start centered
		elseif isEndSection then
			targetLateralOffset = 0 -- End centered
		else
			targetLateralOffset = zigzagDirection * zigzagAmount * zigzagIntensity * (0.8 + randomVariation)
		end
		
		-- Calculate section length
		local thisSectionLength
		if isEndSection then
			-- Last section extends exactly to the end
			thisSectionLength = absoluteEnd - previousEndForward
		else
			-- Divide remaining distance evenly (with some randomness)
			local remainingSections = sectionCount - i + 1
			local remainingDistance = absoluteEnd - previousEndForward
			local avgLength = remainingDistance / remainingSections
			thisSectionLength = rng:NextNumber(avgLength * 0.8, avgLength * 1.2)
		end
		
		-- Calculate start and end positions
		local startForward = previousEndForward
		local endForward = startForward + thisSectionLength
		
		-- Start lateral position (connect to previous section)
		local startLateral = previousLateralOffset
		local endLateral = targetLateralOffset
		
		-- Calculate center position and size
		local centerForward = (startForward + endForward) / 2
		local centerLateral = (startLateral + endLateral) / 2
		
		-- Calculate the actual length of this section (including diagonal)
		local deltaForward = endForward - startForward
		local deltaLateral = endLateral - startLateral
		local actualLength = math.sqrt(deltaForward * deltaForward + deltaLateral * deltaLateral)
		
		-- Create bridge platform
		local platform = Instance.new("Part")
		platform.Name = "BridgeSection" .. i
		platform.Size = Vector3.new(bridgeWidth, 1, actualLength)
		platform.Material = Enum.Material.Wood
		platform.Color = Color3.fromRGB(139, 90, 43) -- Brown wood
		platform.Anchored = true
		platform.CanCollide = true
		
		-- Calculate rotation to connect start to end
		local sectionYaw = math.atan2(deltaLateral, deltaForward)
		
		-- Position in world space
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(centerLateral, 0, centerForward)
		platform.CFrame = CFrame.new(segmentPosition + localOffset) 
			* CFrame.Angles(0, yaw + sectionYaw, 0)
		
		platform.Parent = model
		
		-- Store for next section to connect
		previousEndForward = endForward
		previousLateralOffset = endLateral
		zigzagDirection = zigzagDirection * -1
	end
	
	return model
end

return ZigzagBridge

