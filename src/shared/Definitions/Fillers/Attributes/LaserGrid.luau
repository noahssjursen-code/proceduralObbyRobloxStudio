--[[
	Laser Grid Attribute
	
	Static laser beams arranged in a grid pattern that turn on/off in cycles.
	Players must time their movement to cross during "off" periods.
	Multiple beam heights create layered challenges.
	
	Difficulty: Medium
	Compatible: All fittings (works best with open paths)
]]

local TweenService = game:GetService("TweenService")

local LaserGrid = {}

LaserGrid.ID = "LaserGrid"
LaserGrid.DisplayName = "Laser Grid"
LaserGrid.CompatibleFittings = {"all"}

function LaserGrid.BuildInSlot(
	slotPosition: Vector3,
	slotScale: Vector3,
	slotRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "LaserGrid"
	
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
	local beamThickness = 0.2  -- Thin laser beams
	local beamLength = length * 0.9  -- 90% of slot length
	local beamWidth = width * 0.9  -- 90% of slot width
	
	-- Timing parameters
	local onDuration = rng:NextNumber(2.5, 4)  -- How long lasers stay on
	local offDuration = rng:NextNumber(1.5, 2.5)  -- How long lasers stay off
	local initialDelay = rng:NextNumber(0, 2)  -- Random start delay
	
	-- Create a rotating laser barrier across the path
	local beam = Instance.new("Part")
	beam.Name = "LaserBarrier"
	beam.Size = Vector3.new(beamLength, 3, beamThickness)  -- Long barrier, thin width
	beam.Material = Enum.Material.Neon
	beam.Color = Color3.fromRGB(255, 0, 0)  -- Bright red laser
	beam.Anchored = true
	beam.CanCollide = true
	beam.Transparency = 0.0  -- Always visible
	
	-- Position beam in center of path
	beam.CFrame = getWorldPosition(0, 1.5, 0)  -- 1.5 studs high
	
	-- Add PointLight for glow effect
	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Color = Color3.fromRGB(255, 0, 0)
	light.Range = 15
	light.Enabled = true  -- Always on
	light.Parent = beam
	
	beam.Parent = model
	
	-- Mark as always deadly (rotation creates safe periods)
	beam:SetAttribute("Deadly", true)
	beam:SetAttribute("DamageType", "Laser")
	
	-- Set up rotation animation
	local baseCFrame = beam.CFrame
	
	-- Rotate 90 degrees to create safe periods
	local rotationTween = TweenService:Create(beam, TweenInfo.new(
		onDuration + offDuration,  -- Total cycle time
		Enum.EasingStyle.Linear,   -- Constant speed
		Enum.EasingDirection.InOut,
		-1,  -- Infinite repeat
		true  -- Reverse (back and forth)
	), {
		CFrame = baseCFrame * CFrame.Angles(0, math.rad(90), 0)
	})
	
	-- Start the rotation cycle
	task.spawn(function()
		task.wait(initialDelay)
		rotationTween:Play()
	end)
	
	return model
end

return LaserGrid
