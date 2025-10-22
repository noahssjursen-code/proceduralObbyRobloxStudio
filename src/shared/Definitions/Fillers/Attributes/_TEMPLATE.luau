--[[
	[ATTRIBUTE NAME] Attribute
	
	[Description: What does this attribute do? What's the challenge?]
	[Difficulty: Easy/Medium/Hard]
	[Compatible: List fitting IDs or "all"]
	
	Attributes are modular obstacles that spawn ON TOP of fittings in "slots".
	They add dynamic challenges without changing the base platform layout.
]]

local AttributeName = {}

AttributeName.ID = "AttributeName"  -- MUST BE UNIQUE - change this!
AttributeName.DisplayName = "Attribute Name"  -- Human-readable name
AttributeName.CompatibleFittings = {"all"}  -- {"all"} or {"FittingID1", "FittingID2"}

--[[
	Build the attribute within a single slot.
	A slot is a section of a segment where this attribute can be placed.
	
	@param slotPosition - Center point of the slot (Vector3)
	@param slotScale - Dimensions of slot: X=width, Y=height, Z=length (ALREADY SCALED!)
	@param slotRotation - Euler angles (Y=yaw is segment direction)
	@param worldScale - Global scale multiplier (for reference, slot is already scaled)
	@param rng - Seeded Random object for deterministic generation
	@return Model containing all parts for this attribute
]]
function AttributeName.BuildInSlot(
	slotPosition: Vector3,
	slotScale: Vector3,
	slotRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "AttributeName"  -- Change this to match your attribute
	
	-- Extract slot dimensions (ALREADY SCALED by worldScale!)
	local width = slotScale.X   -- Lateral (left/right) dimension
	local height = slotScale.Y  -- Vertical dimension
	local length = slotScale.Z  -- Forward (start/end) dimension
	local yaw = math.rad(slotRotation.Y)  -- Slot direction in radians
	
	-- Define your player-scale constants (DON'T multiply by worldScale!)
	local obstacleSize = 3  -- Example: obstacle size relative to player
	
	-- Helper function to convert local offset to world position
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(slotPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- YOUR CODE HERE: Build your attribute content
	-- Examples:
	-- - Moving obstacles (using TweenService)
	-- - Rotating hazards (like swinging hammers)
	-- - Static obstacles (spikes, barriers)
	-- - Environmental effects
	
	-- Example: Create a simple obstacle
	local obstacle = Instance.new("Part")
	obstacle.Name = "Obstacle"
	obstacle.Size = Vector3.new(obstacleSize, obstacleSize, obstacleSize)
	obstacle.Material = Enum.Material.SmoothPlastic
	obstacle.Color = Color3.fromRGB(255, 100, 100)  -- Red danger color
	obstacle.Anchored = true
	obstacle.CanCollide = true
	
	-- Position obstacle at center of slot, raised above platform
	obstacle.CFrame = getWorldPosition(0, height * 0.25, 0)
	
	-- Optional: Mark as deadly (for damage systems)
	obstacle:SetAttribute("Deadly", true)
	obstacle:SetAttribute("DamageType", "Obstacle")
	
	obstacle.Parent = model
	
	-- IMPORTANT NOTES:
	-- 1. Attributes span ONE SLOT, not the entire segment
	-- 2. Multiple instances of your attribute can spawn in different slots
	-- 3. Slot dimensions are ALREADY SCALED - use them directly
	-- 4. Use player-scale values (3-6 studs) for gameplay elements
	-- 5. Use rng for randomness (deterministic, not math.random())
	-- 6. Stay within slot bounds (use 80-90% of width/length)
	-- 7. Position above the platform (Y > 0) so players can pass under/through
	
	return model
end

return AttributeName

