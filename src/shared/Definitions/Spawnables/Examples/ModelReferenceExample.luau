--[[
	Example: Model Reference Spawnable
	
	This shows how to use pre-made models from ReplicatedStorage.
	
	SETUP:
	1. Create your model in Roblox Studio
	2. Place it in ReplicatedStorage > Assets > Platforms > WoodenBench
	3. Reference it using dot notation in ModelPath
]]

local SpawnableTypes = require(script.Parent.Parent.SpawnableTypes)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

--[[
	Example: A pre-made wooden bench model
	
	File structure in ReplicatedStorage:
	ReplicatedStorage/
	  Assets/
	    Platforms/
	      WoodenBench  ← Your model here
]]
local WoodenBench = {
	ID = "WoodenBench",
	DisplayName = "Wooden Bench",
	Category = "GrayNode",
	
	BuildMode = "ModelReference",
	ModelPath = "Assets.Platforms.WoodenBench", -- Dot notation path
	
	CanCollide = true,
	Anchored = true,
	Massless = true,
	
	SpawnWeight = 10,
	MinScale = 5,
} :: SpawnableDefinition

--[[
	The system will:
	1. Navigate to ReplicatedStorage.Assets.Platforms.WoodenBench
	2. Clone the model
	3. Scale it by WorldScale
	4. Position it at the gray node location
	
	Your model can be:
	- A single Part
	- A Model with multiple parts
	- Any hierarchy of objects
]]

return {
	WoodenBench = WoodenBench,
}

