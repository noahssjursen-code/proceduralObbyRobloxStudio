--[[
	Kill Bricks Attribute
	
	Lines of kill bricks placed on the floor that players must jump over.
	Creates a simple but effective obstacle that requires timing and precision.
	
	Difficulty: Easy to Medium
	Compatible: All fittings (works best with longer segments)
]]

local KillBricks = {}

KillBricks.ID = "KillBricks"
KillBricks.DisplayName = "Kill Bricks"
KillBricks.CompatibleFittings = {"all"}

function KillBricks.BuildInSlot(
	slotPosition: Vector3,
	slotScale: Vector3,
	slotRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "KillBricks"
	
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
	
	-- Kill brick parameters
	local brickHeight = 1  -- Height of kill bricks (shorter)
	local brickWidth = width * 0.9  -- Width covers 90% of slot width
	local brickLength = 1.5  -- Length of each individual brick
	local brickSpacing = 5  -- Gap between bricks for jumping (more space)
	
	-- Calculate number of bricks based on slot length
	local totalBrickSpace = length * 0.8  -- Use 80% of slot length
	local numBricks = math.max(1, math.floor(totalBrickSpace / (brickLength + brickSpacing)))
	
	-- Position bricks in a line along the slot
	for i = 1, numBricks do
		local brick = Instance.new("Part")
		brick.Name = "KillBrick_" .. i
		brick.Size = Vector3.new(brickWidth, brickHeight, brickLength)  -- Individual brick size
		brick.Material = Enum.Material.Neon
		brick.Color = Color3.fromRGB(255, 0, 0)  -- Bright red for danger
		brick.Anchored = true
		brick.CanCollide = true
		
		-- Position brick along the slot length
		local forwardOffset = (i - 1) * (brickLength + brickSpacing) - (totalBrickSpace * 0.5)
		brick.CFrame = getWorldPosition(0, brickHeight / 2, forwardOffset)
		
		-- Mark as deadly (for damage systems)
		brick:SetAttribute("Deadly", true)
		brick:SetAttribute("DamageType", "KillBrick")
		
		-- Add glow effect
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 1
		pointLight.Color = brick.Color
		pointLight.Range = 10
		pointLight.Parent = brick
		
		brick.Parent = model
	end
	
	return model
end

return KillBricks
