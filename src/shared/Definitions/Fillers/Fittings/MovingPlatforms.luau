--[[
	Moving Platforms Fitting
	
	Platforms that slide back and forth (laterally or vertically).
	Player must time jumps to land on moving platforms.
	Creates dynamic timing challenges across longer distances.
	
	Difficulty: Medium
	Best for: Long segments
]]

local TweenService = game:GetService("TweenService")

local MovingPlatforms = {}

MovingPlatforms.ID = "MovingPlatforms"
MovingPlatforms.DisplayName = "Moving Platforms"

-- Slot configuration for attributes
MovingPlatforms.AllowAttributes = true
MovingPlatforms.SlotCount = nil

function MovingPlatforms.Build(
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "MovingPlatforms"
	
	local width = segmentScale.X
	local length = segmentScale.Z
	local yaw = math.rad(segmentRotation.Y)
	
	-- Player-scale constants
	local platformSize = 5  -- Platform size
	local jumpDistance = 7  -- Comfortable jump distance
	
	-- Helper function for world positioning
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(segmentPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- Calculate number of platforms based on length
	local platformCount = math.floor(length / jumpDistance)
	platformCount = math.max(3, platformCount)  -- At least 3 platforms
	
	-- Create platforms with varied movement patterns
	for i = 1, platformCount do
		-- Position along length
		local t = (i - 1) / (platformCount - 1)  -- 0 to 1
		local forwardOffset = (t - 0.5) * length * 0.9
		
		-- Randomly choose movement type for this platform
		local movementType = rng:NextInteger(1, 3)
		-- 1 = horizontal slide (left/right)
		-- 2 = vertical bob (up/down)
		-- 3 = circular motion
		
		-- Random movement parameters
		local moveDistance = rng:NextNumber(width * 0.15, width * 0.25)  -- How far it moves
		local moveDuration = rng:NextNumber(3, 5)  -- How long one cycle takes
		
		-- Create platform anchor (invisible part that moves, platform is welded to it)
		local anchor = Instance.new("Part")
		anchor.Name = "Anchor" .. i
		anchor.Size = Vector3.new(1, 1, 1)
		anchor.Anchored = true
		anchor.CanCollide = false
		anchor.Transparency = 1
		anchor.CFrame = getWorldPosition(0, 0, forwardOffset)
		anchor.Parent = model
		
		-- Create the actual platform
		local platform = Instance.new("Part")
		platform.Name = "Platform" .. i
		platform.Size = Vector3.new(platformSize, 1.5, platformSize)
		platform.Material = Enum.Material.Metal
		platform.Color = Color3.fromRGB(100, 150, 200)  -- Blue-gray metal
		platform.Anchored = false  -- Will be welded to anchor
		platform.CanCollide = true
		platform.CFrame = anchor.CFrame
		platform.Parent = model
		
		-- Add visual accent
		local accent = Instance.new("Part")
		accent.Name = "Accent" .. i
		accent.Size = Vector3.new(platformSize * 0.8, 1.6, platformSize * 0.8)
		accent.Material = Enum.Material.Neon
		accent.Color = Color3.fromRGB(50, 150, 255)  -- Bright blue
		accent.Anchored = false
		accent.CanCollide = false
		accent.Transparency = 0.5
		accent.CFrame = platform.CFrame
		accent.Parent = model
		
		-- Weld platform to anchor
		local weldPlatform = Instance.new("WeldConstraint")
		weldPlatform.Part0 = anchor
		weldPlatform.Part1 = platform
		weldPlatform.Parent = anchor
		
		-- Weld accent to platform
		local weldAccent = Instance.new("WeldConstraint")
		weldAccent.Part0 = platform
		weldAccent.Part1 = accent
		weldAccent.Parent = platform
		
		-- Create movement animation based on type
		local baseCFrame = anchor.CFrame
		local positionValue = Instance.new("CFrameValue")
		positionValue.Name = "PositionValue"
		positionValue.Value = baseCFrame
		positionValue.Parent = anchor
		
		local tween
		
		if movementType == 1 then
			-- Horizontal slide (left/right)
			local endCFrame = baseCFrame * CFrame.new(moveDistance, 0, 0)
			
			local tweenInfo = TweenInfo.new(
				moveDuration,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut,
				-1,  -- Infinite
				true  -- Reverse
			)
			
			tween = TweenService:Create(positionValue, tweenInfo, {Value = endCFrame})
			
		elseif movementType == 2 then
			-- Vertical bob (up/down)
			local bobHeight = rng:NextNumber(3, 5)  -- Bob 3-5 studs
			local endCFrame = baseCFrame * CFrame.new(0, bobHeight, 0)
			
			local tweenInfo = TweenInfo.new(
				moveDuration,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut,
				-1,
				true
			)
			
			tween = TweenService:Create(positionValue, tweenInfo, {Value = endCFrame})
			
		else
			-- Circular motion
			-- This is trickier - we'll do a figure-8 with two tweens
			local radius = moveDistance / 2
			
			-- Just do simple back-forth for now (circular is complex with single tween)
			local endCFrame = baseCFrame * CFrame.new(moveDistance, 0, moveDistance * 0.3)
			
			local tweenInfo = TweenInfo.new(
				moveDuration,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut,
				-1,
				true
			)
			
			tween = TweenService:Create(positionValue, tweenInfo, {Value = endCFrame})
		end
		
		-- Update anchor position when value changes
		positionValue:GetPropertyChangedSignal("Value"):Connect(function()
			if anchor.Parent then
				anchor.CFrame = positionValue.Value
			end
		end)
		
		-- Start with slight delay between platforms for variety
		task.delay(i * 0.3, function()
			tween:Play()
		end)
	end
	
	return model
end

return MovingPlatforms

