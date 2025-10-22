--[[
	Wall Pushers Attribute
	
	Large barriers that slide back and forth laterally across the path.
	They try to push the player off the edge or into other hazards.
	Player must time their movement or get pushed along with the wall.
	
	Difficulty: Medium
	Compatible: All fittings (works best with narrow paths)
]]

local TweenService = game:GetService("TweenService")

local WallPushers = {}

WallPushers.ID = "WallPushers"
WallPushers.DisplayName = "Wall Pushers"
WallPushers.CompatibleFittings = {"all"}

function WallPushers.BuildInSlot(
	slotPosition: Vector3,
	slotScale: Vector3,
	slotRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "WallPushers"
	
	-- Extract slot dimensions (ALREADY SCALED!)
	local width = slotScale.X   -- Lateral (left/right) dimension
	local height = slotScale.Y  -- Vertical dimension
	local length = slotScale.Z  -- Forward (start/end) dimension
	local yaw = math.rad(slotRotation.Y)  -- Slot direction in radians
	
	-- Helper function to convert local offset to world position
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(slotPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- Player-scale constants
	local wallDepth = length * 0.6  -- How far the wall extends along path (120% of slot length - extends beyond)
	local wallHeight = height * 0.8  -- 80% of slot height
	local wallWidth = 4  -- Width of the wall face (lateral)
	
	-- Movement parameters
	local slideDistance = width * 0.7  -- How far the wall travels (70% of slot width)
	local slideDuration = rng:NextNumber(3, 5)  -- Time for one complete slide (seconds)
	
	-- Determine number of walls based on slot length
	local wallCount = 1
	if length > 40 then
		wallCount = 2  -- Two walls for longer slots
	end
	
	for i = 1, wallCount do
		-- Position walls evenly along the slot length
		local forwardOffset = 0
		if wallCount > 1 then
			local spacing = length * 0.6
			forwardOffset = (i - 1.5) * spacing / (wallCount - 1)
		end
		
		-- Create the main wall barrier
		local wall = Instance.new("Part")
		wall.Name = "Wall" .. i
		wall.Size = Vector3.new(wallWidth, wallHeight, wallDepth)
		wall.Material = Enum.Material.Concrete
		wall.Color = Color3.fromRGB(100, 100, 110)  -- Gray concrete
		wall.Anchored = true
		wall.CanCollide = true
		
		-- Start position (offset to one side)
		local startLateralOffset = -slideDistance / 2
		wall.CFrame = getWorldPosition(startLateralOffset, wallHeight / 2, forwardOffset)
		
		wall.Parent = model
		
		-- Set up sliding animation
		local baseCFrame = wall.CFrame
		local startCFrame = getWorldPosition(-slideDistance / 2, wallHeight / 2, forwardOffset)
		local endCFrame = getWorldPosition(slideDistance / 2, wallHeight / 2, forwardOffset)
		
		-- Create tween for smooth sliding
		local tweenInfo = TweenInfo.new(
			slideDuration,
			Enum.EasingStyle.Sine,  -- Smooth easing
			Enum.EasingDirection.InOut,
			-1,  -- Infinite repeat
			true,  -- Reverse (go back and forth)
			0  -- No delay
		)
		
		local slideTween = TweenService:Create(wall, tweenInfo, {
			CFrame = endCFrame
		})
		
		-- Offset the start time for multiple walls to create variety
		if i > 1 then
			task.delay(slideDuration / wallCount * (i - 1), function()
				slideTween:Play()
			end)
		else
			slideTween:Play()
		end
	end
	
	return model
end

return WallPushers

