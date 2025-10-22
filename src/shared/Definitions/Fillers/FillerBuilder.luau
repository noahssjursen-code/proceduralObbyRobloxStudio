--[[
	Filler Builder
	
	Builds filler content inside PathSegments.
	Also handles attribute slot calculation and visualization.
]]

local FillerTypes = require(script.Parent.FillerTypes)
type FillerDefinition = FillerTypes.FillerDefinition

local AttributeBuilder = require(script.Parent.Attributes.AttributeBuilder)
local AttributeRegistry = require(script.Parent.Attributes.AttributeRegistry)
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
		
		-- Populate slots with attributes first (so we know which slots are filled)
		local compatibleAttributes = AttributeRegistry.GetCompatibleAttributes(fitting.ID)
		local filledSlots = {} -- Track which slots have attributes
		
		if #compatibleAttributes > 0 then
			for slotIndex, slot in slots do
				-- Randomly decide if this slot gets an attribute
				-- Use weighted selection based on all compatible attributes
				local selectedEntry = nil
				local totalWeight = 0
				
				for _, entry in compatibleAttributes do
					totalWeight += entry.SpawnWeight
				end
				
				if totalWeight > 0 then
					-- Roll to see if we spawn an attribute at all
					local spawnRoll = rng:NextNumber(0, 1)
					local maxSpawnChance = 0
					
					-- Find highest spawn chance among compatible attributes
					for _, entry in compatibleAttributes do
						if entry.SpawnChance > maxSpawnChance then
							maxSpawnChance = entry.SpawnChance
						end
					end
					
					-- If we pass the spawn chance check, select an attribute
					if spawnRoll <= maxSpawnChance then
						-- Weighted random selection
						local roll = rng:NextNumber(0, totalWeight)
						local cumulative = 0
						
						for _, entry in compatibleAttributes do
							cumulative += entry.SpawnWeight
							if roll <= cumulative then
								selectedEntry = entry
								break
							end
						end
					end
				end
				
				-- Build the attribute if one was selected
				if selectedEntry then
					local attributeModel = selectedEntry.Attribute.BuildInSlot(
						slot.Position,
						slot.Scale,
						slot.Rotation,
						worldScale,
						rng
					)
					
					attributeModel.Parent = instance
					filledSlots[slotIndex] = true -- Mark this slot as filled
				end
			end
		end
		
		-- Create visual debug boxes ONLY for empty slots
		if slotConfig.ShowSlotBoxes then
			for slotIndex, slot in slots do
				if not filledSlots[slotIndex] then
					-- Only show box if slot is empty
					AttributeBuilder.CreateVisualSlotBoxes(
						{slot}, -- Pass single slot as array
						instance,
						slotConfig.SlotBoxTransparency,
						slotConfig.SlotBoxColor
					)
				end
			end
		end
	end
	
	-- Parent last for performance
	if parent then
		instance.Parent = parent
	end
	
	return instance
end

return FillerBuilder

