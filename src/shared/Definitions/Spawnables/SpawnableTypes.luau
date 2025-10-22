--[[
	Spawnable Type Definitions
	
	Defines the data structure for all spawnable objects in the world.
	These are pure data - no building logic here.
]]

export type BuildMode = "SimplePart" | "CustomBuilder"

export type SpawnableDefinition = {
	-- Identity
	ID: string,
	DisplayName: string,
	Category: string, -- "GrayNode", "Obstacle", etc.
	
	--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	-- BUILD MODE (choose one)
	--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	BuildMode: BuildMode,
	
	-- For "SimplePart" mode - single procedural part
	Shape: Enum.PartType?,
	Size: Vector3?,
	Color: Color3?,
	Material: Enum.Material?,
	Transparency: number?,
	
	-- For "CustomBuilder" mode - call a custom function
	BuilderFunction: ((position: Vector3, worldScale: number, rng: Random) -> Instance)?,
	
	--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	-- PHYSICS (all modes)
	--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	CanCollide: boolean,
	Anchored: boolean,
	Massless: boolean?,
	
	--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	-- GAMEPLAY (all modes)
	--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	SpawnWeight: number, -- Higher = more common (0-100)
	MinScale: number?, -- Minimum world scale to spawn at
	MaxScale: number?, -- Maximum world scale to spawn at
	
	-- Special Properties (optional)
	Properties: {
		-- For disappearing platforms
		DisappearTime: number?,
		RespawnTime: number?,
		
		-- For jump pads
		BouncePower: number?,
		
		-- For moving platforms
		MoveDistance: number?,
		MoveSpeed: number?,
		
		-- Add more as needed
		[string]: any,
	}?,
}

return {}

