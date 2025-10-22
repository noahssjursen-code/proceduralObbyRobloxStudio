--[[
	Attribute Types
	
	Type definitions for the attribute slot system.
	Attributes are modular obstacles/challenges that can be added to fittings.
]]

--[[
	SlotBox represents a single "slot" within a segment where an attribute can be placed.
	The slot is a 3D bounding box with position, scale, and rotation.
]]
export type SlotBox = {
	Position: Vector3,    -- Center position of the slot in world space
	Scale: Vector3,       -- Dimensions: X=width, Y=height, Z=length
	Rotation: Vector3,    -- Euler angles (Y=yaw is segment direction)
	Index: number,        -- Which slot in the sequence (1, 2, 3...)
	SegmentType: string,  -- "Short", "Medium", "Long", "Wide", "Narrow"
}

--[[
	AttributeDefinition defines a modular obstacle/challenge.
	Each attribute knows how to build itself within a single slot box.
]]
export type AttributeDefinition = {
	ID: string,                    -- Unique identifier (e.g., "SwingingHammers")
	DisplayName: string,           -- Human-readable name
	CompatibleFittings: {string},  -- List of fitting IDs this works with, or {"all"}
	
	-- Build function: Creates the attribute inside one slot
	BuildInSlot: (
		slotPosition: Vector3,    -- Center of the slot
		slotScale: Vector3,       -- Dimensions of the slot (already scaled!)
		slotRotation: Vector3,    -- Rotation of the slot
		worldScale: number,       -- Global scale (for reference, slot is already scaled)
		rng: Random               -- Seeded RNG for deterministic generation
	) -> Instance,
}

--[[
	AttributeSpawnEntry defines how often an attribute should spawn.
	Used in attribute registries and pools.
]]
export type AttributeSpawnEntry = {
	Attribute: AttributeDefinition,
	SpawnWeight: number,   -- Relative weight for weighted random selection
	SpawnChance: number,   -- 0.0 to 1.0, chance this attribute spawns in a slot
}

return {}

