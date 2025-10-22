--[[
	Filler Builder
	
	Builds filler content inside PathSegments.
	Also handles attribute slot calculation and visualization.
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

local AttributeBuilder = require(script.Parent.Attributes.AttributeBuilder)
local Config = require(script.Parent.Parent.Parent.Config)

local FillerBuilder = {}

--[[
	Build a filler inside a segment, including attribute slots if enabled.
	
	@param filler - FillerDefinition to build
	@param segmentPosition - Center position of segment
	@param segmentScale - Dimensions of segment (already scaled)
	@param segmentRotation - Euler angles for segment direction
	@param segmentType - Type of segment ("Short", "Medium", "Long", "Wide", "Narrow")
	@param worldScale - Global scale multiplier
	@param rng - Seeded random for deterministic generation
	@param parent - Parent instance for the filler
	@return Instance - The built filler model
]]
function FillerBuilder.Build(
	filler: FillerDefinition,
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	segmentType: string,
	worldScale: number,
	rng: Random,
	parent: Instance?
): Instance
	-- Call the builder function to create base filler
	local instance = filler.BuilderFunction(
		segmentPosition,
		segmentScale,
		segmentRotation,
		worldScale,
		rng
	)
	
	-- Set name
	instance.Name = filler.ID
	
	-- Check if this fitting allows attributes
	local fitting = filler.Fitting
	if fitting and fitting.AllowAttributes then
		-- Get slot configuration
		local slotConfig = Config.WorldGeneration.AttributeSlots
		local slotCount = fitting.SlotCount or slotConfig.DefaultSlotCounts[segmentType] or 3
		
		-- Calculate slot boxes
		local slots = AttributeBuilder.CalculateSlotBoxes(
			segmentPosition,
			segmentScale,
			segmentRotation,
			segmentType,
			slotCount,
			slotConfig.SlotMargin
		)
		
		-- Create visual debug boxes if enabled
		if slotConfig.ShowSlotBoxes then
			AttributeBuilder.CreateVisualSlotBoxes(
				slots,
				instance,
				slotConfig.SlotBoxTransparency,
				slotConfig.SlotBoxColor
			)
		end
		
		-- TODO: Populate slots with actual attributes (future step)
		-- For now, we're just visualizing the slot system
	end
	
	-- Parent last for performance
	if parent then
		instance.Parent = parent
	end
	
	return instance
end

return FillerBuilder

