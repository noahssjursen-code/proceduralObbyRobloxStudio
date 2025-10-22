--[[
	Filler Type Definitions
	
	Fillers are procedural content that fills PathSegments.
	Each filler knows how to build itself inside a segment's bounding box.
]]

export type FillerDefinition = {
	-- Identity
	ID: string,
	DisplayName: string,
	CompatibleSegmentTypes: {string}, -- ["Short", "Medium", etc.]
	
	-- Selection
	SpawnWeight: number, -- Higher = more common
	MinScale: number?, -- Minimum world scale to spawn at
	MaxScale: number?, -- Maximum world scale to spawn at
	
	-- Fitting reference (for accessing metadata like AllowAttributes, SlotCount)
	Fitting: any?, -- Reference to the fitting module
	
	-- Builder function
	-- Takes segment bounds and creates content inside
	BuilderFunction: (
		segmentPosition: Vector3,
		segmentScale: Vector3, -- Width x Height x Length
		segmentRotation: Vector3, -- Euler angles (degrees)
		worldScale: number,
		rng: Random
	) -> Instance,
}

return {}

