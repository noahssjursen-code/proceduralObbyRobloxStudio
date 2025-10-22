--[[
	Lava Jump Fitting
	
	A red death floor with circular platforms scattered on top.
	Player must jump between safe platforms to avoid touching the lava.
]]

local LavaJump = {}

LavaJump.ID = "LavaJump"
LavaJump.DisplayName = "Lava Jump"

-- Slot configuration for attributes
LavaJump.AllowAttributes = true  -- Can have attributes added on top
LavaJump.SlotCount = nil  -- Use default from Config (4 for Medium, 6 for Long)

function LavaJump.Build(
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "LavaJump"
	
	local width = segmentScale.X
	local length = segmentScale.Z
	local yaw = math.rad(segmentRotation.Y)
	
	-- Create red death floor (lava)
	local lavaFloor = Instance.new("Part")
	lavaFloor.Name = "Lava"
	lavaFloor.Size = Vector3.new(width * 0.95, 2, length * 0.95)
	lavaFloor.Material = Enum.Material.SmoothPlastic
	lavaFloor.Color = Color3.fromRGB(220, 50, 50) -- Bright red
	lavaFloor.Anchored = true
	lavaFloor.CanCollide = true
	
	-- Position and rotate the floor
	lavaFloor.CFrame = CFrame.new(segmentPosition) * CFrame.Angles(0, yaw, 0)
	
	-- Add a killing script (using attributes for now)
	lavaFloor:SetAttribute("Deadly", true)
	lavaFloor:SetAttribute("DamageType", "Lava")
	
	lavaFloor.Parent = model
	
	-- Create circular safe platforms on top - forming a jumpable path
	-- These values are in PLAYER scale - don't multiply by worldScale!
	-- The segment is already scaled, these are gameplay constants
	local platformRadius = 2.5 -- Consistent platform size (player-scale)
	local platformHeight = 3 -- Height above lava (player-scale)
	
	-- Helper function to create a platform
	local function createPlatform(name: string, forwardOffset: number, lateralOffset: number)
		local platform = Instance.new("Part")
		platform.Name = name
		platform.Shape = Enum.PartType.Cylinder
		platform.Size = Vector3.new(platformRadius * 2, platformRadius * 2, 2) -- Cylinder dimensions
		platform.Material = Enum.Material.SmoothPlastic
		platform.Color = Color3.fromRGB(200, 200, 200) -- Gray
		platform.Anchored = true
		platform.CanCollide = true
		
		-- Calculate position in world space
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, platformHeight, forwardOffset)
		local platformPos = segmentPosition + localOffset
		
		-- Rotate cylinder to lay flat (cylinders point along their X axis by default)
		platform.CFrame = CFrame.new(platformPos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(0, 0, math.rad(90))
		
		platform.Parent = model
	end
	
	-- ALWAYS create START platform (at segment entrance)
	createPlatform("StartPlatform", -length * 0.45, 0)
	
	-- ALWAYS create END platform (at segment exit)
	createPlatform("EndPlatform", length * 0.45, 0)
	
	-- Create middle platforms with zigzag pattern
	local jumpDistance = 6 -- Maximum comfortable jump distance for player (player-scale)
	local middlePlatformCount = math.max(math.floor(length / jumpDistance) - 1, 1) -- Subtract 2 for start/end
	
	for i = 1, middlePlatformCount do
		-- Position evenly between start and end
		local t = i / (middlePlatformCount + 1) -- 0 to 1, evenly spaced between start/end
		local forwardOffset = (t - 0.5) * length * 0.9 -- Spread along 90% of length
		
		-- Add controlled zigzag (not too random, forms a clear path)
		local zigzag = math.sin(i * 1.2) -- Sine wave for smooth zigzag
		local lateralOffset = zigzag * width * 0.15 -- 15% of width max deviation
		
		createPlatform("MiddlePlatform" .. i, forwardOffset, lateralOffset)
	end
	
	return model
end

return LavaJump

