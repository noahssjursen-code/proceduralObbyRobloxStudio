--[[
	[FITTING NAME] Fitting
	
	[Description: What does this fitting do? What's the challenge?]
	[Difficulty: Easy/Medium/Hard]
	[Best for: Short/Medium/Long/Wide/Narrow segments]
]]

local FittingName = {}

FittingName.ID = "FittingName"  -- MUST BE UNIQUE - change this!
FittingName.DisplayName = "Fitting Name"  -- Human-readable name

--[[
	Build function - Creates the actual obstacle/path in the world
	
	@param segmentPosition - Center point of the segment (Vector3)
	@param segmentScale - Dimensions of segment: X=width, Y=height, Z=length (ALREADY SCALED!)
	@param segmentRotation - Euler angles (Y=yaw is most important for direction)
	@param worldScale - Global scale multiplier (usually 10) - DON'T use for player-scale values!
	@param rng - Seeded Random object for deterministic generation
	@return Model containing all parts for this fitting
]]
function FittingName.Build(
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "FittingName"  -- Change this to match your fitting
	
	-- Extract segment dimensions (ALREADY SCALED by worldScale!)
	local width = segmentScale.X   -- Lateral (left/right) dimension
	local length = segmentScale.Z  -- Forward (start/end) dimension
	local height = segmentScale.Y  -- Vertical dimension
	local yaw = math.rad(segmentRotation.Y)  -- Segment direction in radians
	
	-- Define your player-scale constants (DON'T multiply by worldScale!)
	local platformSize = 3  -- Example: platform size relative to player
	local jumpDistance = 6  -- Example: comfortable jump distance
	
	-- Helper function to convert local offset to world position
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(segmentPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- REQUIRED: Create START connection (at segment entrance)
	-- Position: -length * 0.5 (back of segment), centered (lateral = 0)
	local startPlatform = Instance.new("Part")
	startPlatform.Name = "StartPlatform"
	startPlatform.Size = Vector3.new(platformSize, 1, platformSize)
	startPlatform.Material = Enum.Material.SmoothPlastic
	startPlatform.Color = Color3.fromRGB(100, 200, 100)  -- Green for start
	startPlatform.Anchored = true
	startPlatform.CanCollide = true
	startPlatform.CFrame = getWorldPosition(0, 0, -length * 0.5)
	startPlatform.Parent = model
	
	-- YOUR CODE HERE: Build your obstacle/path content
	-- Examples:
	-- - Create platforms, walls, obstacles
	-- - Use rng for procedural variation
	-- - Position parts within segment bounds
	-- - Add deadly parts with :SetAttribute("Deadly", true)
	
	-- Example: Create a middle platform with random offset
	local middlePlatform = Instance.new("Part")
	middlePlatform.Name = "MiddlePlatform"
	middlePlatform.Size = Vector3.new(platformSize, 1, platformSize)
	middlePlatform.Material = Enum.Material.SmoothPlastic
	middlePlatform.Color = Color3.fromRGB(200, 200, 200)  -- Gray
	middlePlatform.Anchored = true
	middlePlatform.CanCollide = true
	
	-- Random lateral offset (within bounds)
	local randomLateral = rng:NextNumber(-width * 0.3, width * 0.3)
	middlePlatform.CFrame = getWorldPosition(randomLateral, 0, 0)
	middlePlatform.Parent = model
	
	-- REQUIRED: Create END connection (at segment exit)
	-- Position: length * 0.5 (front of segment), centered (lateral = 0)
	local endPlatform = Instance.new("Part")
	endPlatform.Name = "EndPlatform"
	endPlatform.Size = Vector3.new(platformSize, 1, platformSize)
	endPlatform.Material = Enum.Material.SmoothPlastic
	endPlatform.Color = Color3.fromRGB(200, 100, 100)  -- Red for end
	endPlatform.Anchored = true
	endPlatform.CanCollide = true
	endPlatform.CFrame = getWorldPosition(0, 0, length * 0.5)
	endPlatform.Parent = model
	
	return model
end

return FittingName

