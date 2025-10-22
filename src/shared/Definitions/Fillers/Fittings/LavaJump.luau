--[[
	Lava Jump Fitting
	
	A dangerous lava floor with elevated platforms rising from pedestals.
	Glowing hot lava with safe stone platforms for the player to hop across.
	
	Difficulty: Easy-Medium
	Best for: Medium, Short segments
]]

local LavaJump = {}

LavaJump.ID = "LavaJump"
LavaJump.DisplayName = "Lava Jump"

-- Slot configuration for attributes
LavaJump.AllowAttributes = true
LavaJump.SlotCount = nil

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
	
	-- Player-scale constants
	local platformRadius = 3  -- Platform size (player-scale)
	local platformHeight = 4  -- Height above lava surface (player-scale)
	local lavaDepth = 4  -- Depth of lava (player-scale)
	
	-- Helper function for world positioning
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(segmentPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- Create layered lava floor for depth
	-- Base layer (dark)
	local lavaBase = Instance.new("Part")
	lavaBase.Name = "LavaBase"
	lavaBase.Size = Vector3.new(width * 0.95, lavaDepth, length * 0.95)
	lavaBase.Material = Enum.Material.Cobblestone
	lavaBase.Color = Color3.fromRGB(80, 20, 20)  -- Dark red/brown
	lavaBase.Anchored = true
	lavaBase.CanCollide = true
	lavaBase.CFrame = getWorldPosition(0, -lavaDepth / 2, 0)
	lavaBase:SetAttribute("Deadly", true)
	lavaBase:SetAttribute("DamageType", "Lava")
	lavaBase.Parent = model
	
	-- Surface layer (glowing)
	local lavaSurface = Instance.new("Part")
	lavaSurface.Name = "LavaSurface"
	lavaSurface.Size = Vector3.new(width * 0.93, 0.5, length * 0.93)
	lavaSurface.Material = Enum.Material.Neon
	lavaSurface.Color = Color3.fromRGB(255, 100, 50)  -- Bright orange-red
	lavaSurface.Anchored = true
	lavaSurface.CanCollide = false  -- Don't need collision, base has it
	lavaSurface.CFrame = getWorldPosition(0, 0.25, 0)
	lavaSurface.Parent = model
	
	-- Add point light for glow effect
	local lavaLight = Instance.new("PointLight")
	lavaLight.Brightness = 2
	lavaLight.Color = Color3.fromRGB(255, 100, 50)
	lavaLight.Range = 20
	lavaLight.Parent = lavaSurface
	
	-- Helper function to create a platform with pedestal
	local function createPlatform(name: string, forwardOffset: number, lateralOffset: number, heightVariation: number?)
		heightVariation = heightVariation or 0
		local actualHeight = platformHeight + heightVariation
		
		-- Create pedestal/pillar rising from lava
		local pedestal = Instance.new("Part")
		pedestal.Name = name .. "_Pedestal"
		pedestal.Size = Vector3.new(platformRadius * 1.2, actualHeight + lavaDepth, platformRadius * 1.2)
		pedestal.Material = Enum.Material.Cobblestone
		pedestal.Color = Color3.fromRGB(70, 70, 70)  -- Dark gray stone
		pedestal.Anchored = true
		pedestal.CanCollide = false  -- Don't collide with sides
		pedestal.CFrame = getWorldPosition(lateralOffset, -lavaDepth / 2 + actualHeight / 2, forwardOffset)
		pedestal.Parent = model
		
		-- Create platform on top of pedestal
		local platform = Instance.new("Part")
		platform.Name = name
		platform.Shape = Enum.PartType.Cylinder
		platform.Size = Vector3.new(1.5, platformRadius * 2, platformRadius * 2)
		platform.Material = Enum.Material.Slate
		platform.Color = Color3.fromRGB(180, 180, 180)  -- Light gray stone
		platform.Anchored = true
		platform.CanCollide = true
		
		-- Position on top of pedestal, rotated to lay flat
		platform.CFrame = getWorldPosition(lateralOffset, actualHeight, forwardOffset)
			* CFrame.Angles(0, 0, math.rad(90))
		platform.Parent = model
		
		-- Add accent ring
		local ring = Instance.new("Part")
		ring.Name = name .. "_Ring"
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(1.6, platformRadius * 2 + 0.4, platformRadius * 2 + 0.4)
		ring.Material = Enum.Material.Metal
		ring.Color = Color3.fromRGB(120, 120, 120)
		ring.Anchored = true
		ring.CanCollide = false
		ring.Transparency = 0.3
		ring.CFrame = platform.CFrame
		ring.Parent = model
	end
	
	-- Calculate platform layout
	local jumpDistance = 6.5  -- Comfortable jump distance (player-scale)
	local totalPlatforms = math.max(3, math.floor(length / jumpDistance))
	
	-- Create platforms along the path
	for i = 1, totalPlatforms do
		-- Position evenly along segment
		local t = (i - 1) / (totalPlatforms - 1)  -- 0 to 1
		local forwardOffset = (t - 0.5) * length * 0.9
		
		-- Name based on position
		local platformName
		if i == 1 then
			platformName = "StartPlatform"
		elseif i == totalPlatforms then
			platformName = "EndPlatform"
		else
			platformName = "Platform" .. i
		end
		
		-- Add variety to middle platforms
		local lateralOffset = 0
		local heightVariation = 0
		
		if i > 1 and i < totalPlatforms then
			-- Zigzag pattern for middle platforms
			local zigzag = math.sin(i * 1.3)  -- Sine wave for smooth path
			lateralOffset = zigzag * width * 0.18  -- Stay within bounds
			
			-- Random slight height variation for visual interest
			heightVariation = rng:NextNumber(-0.5, 1.0)
		end
		
		createPlatform(platformName, forwardOffset, lateralOffset, heightVariation)
	end
	
	return model
end

return LavaJump

