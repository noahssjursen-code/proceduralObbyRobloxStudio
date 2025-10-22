--[[
	Scattered Platforms Fitting
	
	Multiple small platforms scattered across the width of the segment.
	Player must jump between platforms, choosing their own path.
	Takes advantage of wide segments' extra lateral space.
	
	Difficulty: Easy-Medium
	Best for: Wide segments
]]

local ScatteredPlatforms = {}

ScatteredPlatforms.ID = "ScatteredPlatforms"
ScatteredPlatforms.DisplayName = "Scattered Platforms"

-- Slot configuration for attributes
ScatteredPlatforms.AllowAttributes = true  -- Can have attributes added on top
ScatteredPlatforms.SlotCount = nil  -- Use default from Config

function ScatteredPlatforms.Build(
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "ScatteredPlatforms"
	
	local width = segmentScale.X
	local length = segmentScale.Z
	local yaw = math.rad(segmentRotation.Y)
	
	-- Player-scale constants
	local platformSize = 4  -- Size of each platform (player-scale)
	local maxJumpDistance = 6  -- Maximum comfortable jump (player-scale)
	
	-- Helper function for world positioning
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(segmentPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- Calculate how many rows of platforms we need along the length
	local rowSpacing = maxJumpDistance * 0.7  -- Space rows closer than max jump
	local rowCount = math.max(3, math.floor(length / rowSpacing))
	
	-- Platforms per row (2-3 depending on width)
	local platformsPerRow = (width > 80) and 3 or 2  -- More platforms if wider segment
	
	-- Create scattered platforms
	for row = 1, rowCount do
		-- Calculate forward position for this row
		local t = (row - 1) / (rowCount - 1)  -- 0 to 1
		local forwardOffset = (t - 0.5) * length * 0.9  -- Use 90% of length
		
		-- Randomly decide which lateral positions to use for this row
		-- This creates variety and multiple path choices
		local useLateralPositions = {}
		
		if platformsPerRow == 2 then
			-- Two platforms: left and right, with random variation
			useLateralPositions = {
				rng:NextNumber(-width * 0.35, -width * 0.25),  -- Left side
				rng:NextNumber(width * 0.25, width * 0.35),     -- Right side
			}
		else
			-- Three platforms: left, center, right with variation
			useLateralPositions = {
				rng:NextNumber(-width * 0.35, -width * 0.25),  -- Left
				rng:NextNumber(-width * 0.08, width * 0.08),   -- Center (slight variation)
				rng:NextNumber(width * 0.25, width * 0.35),    -- Right
			}
		end
		
		-- Randomly skip one platform per row (but always keep start and end rows full)
		local skipIndex = nil
		if row ~= 1 and row ~= rowCount then
			skipIndex = rng:NextInteger(1, platformsPerRow)
		end
		
		-- Create platforms for this row
		for i, lateralOffset in useLateralPositions do
			-- Skip this platform if randomly selected (creates gaps)
			if i == skipIndex then
				continue
			end
			
			-- Random slight height variation for visual interest
			local heightVariation = rng:NextNumber(-0.5, 0.5)
			
			local platform = Instance.new("Part")
			platform.Name = "Platform_Row" .. row .. "_" .. i
			platform.Shape = Enum.PartType.Cylinder
			platform.Size = Vector3.new(1.5, platformSize, platformSize)
			platform.Material = Enum.Material.Concrete
			platform.Color = Color3.fromRGB(150, 150, 150)  -- Gray concrete
			platform.Anchored = true
			platform.CanCollide = true
			
			-- Position and rotate cylinder to lay flat
			platform.CFrame = getWorldPosition(lateralOffset, heightVariation, forwardOffset)
				* CFrame.Angles(0, 0, math.rad(90))
			
			platform.Parent = model
			
			-- Add decorative ring
			local ring = Instance.new("Part")
			ring.Name = "Ring_Row" .. row .. "_" .. i
			ring.Shape = Enum.PartType.Cylinder
			ring.Size = Vector3.new(1.6, platformSize + 0.3, platformSize + 0.3)
			ring.Material = Enum.Material.Metal
			ring.Color = Color3.fromRGB(120, 120, 120)  -- Darker gray
			ring.Anchored = true
			ring.CanCollide = false
			ring.Transparency = 0.3
			ring.CFrame = platform.CFrame
			ring.Parent = model
		end
	end
	
	return model
end

return ScatteredPlatforms

