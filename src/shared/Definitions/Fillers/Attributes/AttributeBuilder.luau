--[[
	Attribute Builder
	
	Handles slot calculation and attribute population for fittings.
	Divides segments into "slots" where attributes can be placed.
]]

local AttributeTypes = require(script.Parent.AttributeTypes)
type SlotBox = AttributeTypes.SlotBox

local AttributeBuilder = {}

--[[
	Calculate slot boxes for a segment.
	Divides the segment into equal-sized slots with margins between them.
	
	@param segmentPosition - Center of the segment
	@param segmentScale - Dimensions of the segment (X=width, Y=height, Z=length) - ALREADY SCALED
	@param segmentRotation - Euler angles (Y=yaw for direction)
	@param segmentType - Type of segment ("Short", "Medium", "Long", "Wide", "Narrow")
	@param slotCount - How many slots to create
	@param marginPercent - Margin between slots as percentage of slot length (0.0 to 1.0)
	@return Array of SlotBox objects
]]
function AttributeBuilder.CalculateSlotBoxes(
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	segmentType: string,
	slotCount: number,
	marginPercent: number
): {SlotBox}
	local slots = {}
	
	local width = segmentScale.X
	local height = segmentScale.Y
	local length = segmentScale.Z
	local yaw = math.rad(segmentRotation.Y)
	
	-- Calculate slot dimensions
	-- Total length = N slots + (N-1) margins
	-- If each slot is L and margin is M:
	--   totalLength = N*L + (N-1)*M
	--   where M = marginPercent * L
	--   totalLength = N*L + (N-1)*marginPercent*L
	--   totalLength = L * (N + (N-1)*marginPercent)
	--   L = totalLength / (N + (N-1)*marginPercent)
	
	local denominator = slotCount + (slotCount - 1) * marginPercent
	local slotLength = length / denominator
	local marginLength = marginPercent * slotLength
	
	-- Starting position (back of segment)
	local startForward = -length * 0.5
	
	for i = 1, slotCount do
		-- Calculate this slot's center position along the segment
		-- Each slot/margin pair takes up (slotLength + marginLength)
		local slotCenterOffset = startForward + (i - 1) * (slotLength + marginLength) + slotLength * 0.5
		
		-- Convert local offset to world position (accounting for segment rotation)
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(0, 0, slotCenterOffset)
		local slotWorldPosition = segmentPosition + localOffset
		
		slots[i] = {
			Position = slotWorldPosition,
			Scale = Vector3.new(width, height, slotLength),
			Rotation = segmentRotation,
			Index = i,
			SegmentType = segmentType,
		}
	end
	
	return slots
end

--[[
	Create visual debug boxes for slots.
	Shows transparent colored boxes so we can see the slot system.
	
	@param slots - Array of SlotBox objects
	@param parentModel - Model to parent the visual boxes to
	@param transparency - How transparent the boxes should be (0-1)
	@param color - Color of the boxes
]]
function AttributeBuilder.CreateVisualSlotBoxes(
	slots: {SlotBox},
	parentModel: Instance,
	transparency: number,
	color: Color3
): ()
	for i, slot in slots do
		local box = Instance.new("Part")
		box.Name = "SlotBox_" .. i
		box.Size = slot.Scale
		box.Material = Enum.Material.Neon
		box.Color = color
		box.Transparency = transparency
		box.Anchored = true
		box.CanCollide = false
		
		-- Position and rotate the box
		local yaw = math.rad(slot.Rotation.Y)
		box.CFrame = CFrame.new(slot.Position) * CFrame.Angles(0, yaw, 0)
		
		box.Parent = parentModel
	end
end

return AttributeBuilder

