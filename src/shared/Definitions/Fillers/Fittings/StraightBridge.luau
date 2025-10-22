--[[
	Straight Bridge Fitting
	
	A simple bridge that connects start to end with randomized surface properties.
	Visual style and material change based on the bridge type.
	Can be flat or sloped for variation.
	
	Difficulty: Easy-Medium (depends on attribute)
	Best for: All segment types
]]

local StraightBridge = {}

StraightBridge.ID = "StraightBridge"
StraightBridge.DisplayName = "Straight Bridge"

-- Slot configuration for attributes
StraightBridge.AllowAttributes = true  -- Can have attributes added on top
StraightBridge.SlotCount = nil  -- Use default from Config

-- Bridge type definitions (attribute, material, color, friction)
local BridgeTypes = {
	Normal = {
		Name = "Normal",
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(139, 90, 43),  -- Brown wood
		CustomPhysicalProperties = nil,  -- Default Roblox physics
	},
	Slippery = {
		Name = "Slippery Ice",
		Material = Enum.Material.Ice,
		Color = Color3.fromRGB(180, 220, 255),  -- Light blue ice
		CustomPhysicalProperties = PhysicalProperties.new(
			0.7,   -- Density
			0.05,  -- Friction (very low = slippery!)
			0.2,   -- Elasticity
			1.0,   -- FrictionWeight
			1.0    -- ElasticityWeight
		),
	},
	Sticky = {
		Name = "Sticky Tar",
		Material = Enum.Material.Asphalt,
		Color = Color3.fromRGB(40, 40, 40),  -- Dark gray/black
		CustomPhysicalProperties = PhysicalProperties.new(
			0.7,   -- Density
			1.5,   -- Friction (very high = sticky!)
			0.1,   -- Elasticity
			1.0,   -- FrictionWeight
			1.0    -- ElasticityWeight
		),
	},
	Bouncy = {
		Name = "Bouncy Rubber",
		Material = Enum.Material.ForceField,
		Color = Color3.fromRGB(255, 100, 200),  -- Pink rubber
		CustomPhysicalProperties = PhysicalProperties.new(
			0.5,   -- Density (lighter)
			0.4,   -- Friction (medium)
			0.9,   -- Elasticity (very bouncy!)
			1.0,   -- FrictionWeight
			1.0    -- ElasticityWeight
		),
	},
	Metal = {
		Name = "Metal Platform",
		Material = Enum.Material.Metal,
		Color = Color3.fromRGB(150, 150, 160),  -- Metallic gray
		CustomPhysicalProperties = PhysicalProperties.new(
			0.9,   -- Density (heavy)
			0.4,   -- Friction (medium)
			0.3,   -- Elasticity
			1.0,   -- FrictionWeight
			1.0    -- ElasticityWeight
		),
	},
}

function StraightBridge.Build(
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "StraightBridge"
	
	local width = segmentScale.X
	local length = segmentScale.Z
	local height = segmentScale.Y
	local yaw = math.rad(segmentRotation.Y)
	
	-- Randomly select bridge type
	local typeNames = {"Normal", "Slippery", "Sticky", "Bouncy", "Metal"}
	local weights = {40, 20, 15, 15, 10}  -- Normal is most common
	
	local totalWeight = 0
	for _, w in weights do
		totalWeight += w
	end
	
	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	local selectedTypeName = "Normal"
	
	for i, typeName in typeNames do
		cumulative += weights[i]
		if roll <= cumulative then
			selectedTypeName = typeName
			break
		end
	end
	
	local bridgeType = BridgeTypes[selectedTypeName]
	
	-- Player-scale constants
	local bridgeWidth = width * 0.5  -- Use 50% of segment width (more narrow)
	local bridgeThickness = 2  -- Player-scale thickness
	
	-- Helper function for world positioning
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(segmentPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- Bridge spans flat from start to end of segment
	-- Position at Y=0 (segment floor level, relative to segment center)
	local bridgeLength = length
	
	-- Create main bridge platform
	local bridge = Instance.new("Part")
	bridge.Name = "Bridge_" .. bridgeType.Name
	bridge.Size = Vector3.new(bridgeWidth, bridgeThickness, bridgeLength)
	bridge.Material = bridgeType.Material
	bridge.Color = bridgeType.Color
	bridge.Anchored = true
	bridge.CanCollide = true
	
	-- Apply custom physics
	if bridgeType.CustomPhysicalProperties then
		bridge.CustomPhysicalProperties = bridgeType.CustomPhysicalProperties
	end
	
	-- Position bridge flat at segment floor (Y=0, Z=0 centers it in the segment)
	local bridgeCFrame = getWorldPosition(0, 0, 0)
	bridge.CFrame = bridgeCFrame  -- No pitch rotation, perfectly flat
	bridge.Parent = model
	
	-- Add side rails for visual interest
	local railThickness = 0.5
	local railHeight = 2
	
	for _, side in {-1, 1} do
		local rail = Instance.new("Part")
		rail.Name = "Rail_" .. (side == 1 and "Right" or "Left")
		rail.Size = Vector3.new(railThickness, railHeight, bridgeLength)
		rail.Material = bridgeType.Material
		rail.Color = Color3.new(
			bridgeType.Color.R * 0.7,
			bridgeType.Color.G * 0.7,
			bridgeType.Color.B * 0.7
		)  -- Darker version
		rail.Anchored = true
		rail.CanCollide = false
		rail.Transparency = 0.2
		
		-- Position rail on edge of bridge, raised above bridge surface
		local railOffset = (bridgeWidth / 2 + railThickness / 2) * side
		rail.CFrame = getWorldPosition(railOffset, railHeight / 2, 0)
		rail.Parent = model
	end
	
	-- Add visual indicator for bridge type (small floating label/marker)
	if selectedTypeName ~= "Normal" then
		local marker = Instance.new("Part")
		marker.Name = "TypeMarker"
		marker.Shape = Enum.PartType.Ball
		marker.Size = Vector3.new(1.5, 1.5, 1.5)
		marker.Material = Enum.Material.Neon
		marker.Color = bridgeType.Color
		marker.Anchored = true
		marker.CanCollide = false
		marker.Transparency = 0.3
		
		-- Position above center of bridge
		marker.CFrame = getWorldPosition(0, 4, 0)
		marker.Parent = model
	end
	
	return model
end

return StraightBridge

