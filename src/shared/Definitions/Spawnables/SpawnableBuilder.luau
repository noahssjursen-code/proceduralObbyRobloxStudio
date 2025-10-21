--[[
	Spawnable Builder
	
	Takes SpawnableDefinitions and builds actual Roblox instances from them.
	This is the bridge between data (definitions) and instances (the actual world).
	
	Supports 3 build modes:
	1. SimplePart - Single procedural part
	2. ModelReference - Clone from ReplicatedStorage
	3. CustomBuilder - Call a custom function
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnableTypes = require(script.Parent.SpawnableTypes)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

local SpawnableBuilder = {}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- BUILD MODE 1: Simple Part
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

--[[
	Builds a basic part from a spawnable definition.
	This handles the common case - special behaviors are added separately.
]]
function SpawnableBuilder.BuildSimplePart(
	definition: SpawnableDefinition,
	position: Vector3,
	worldScale: number,
	forward: Vector3?
): Instance
	-- Validate required fields for SimplePart mode
	if not definition.Shape then
		error(string.format("[SpawnableBuilder] Shape required for SimplePart: %s", definition.ID))
	end
	if not definition.Size then
		error(string.format("[SpawnableBuilder] Size required for SimplePart: %s", definition.ID))
	end
	if not definition.Color then
		error(string.format("[SpawnableBuilder] Color required for SimplePart: %s", definition.ID))
	end
	if not definition.Material then
		error(string.format("[SpawnableBuilder] Material required for SimplePart: %s", definition.ID))
	end
	
	local part = Instance.new("Part")
	
	-- Basic properties
	part.Name = definition.ID
	part.Shape = definition.Shape
	part.Size = definition.Size * worldScale
	part.Color = definition.Color
	part.Material = definition.Material
	part.Transparency = definition.Transparency or 0
	
	-- Calculate orientation CFrame
	if forward and forward.Magnitude > 0 then
		-- Orient part to face the forward direction
		part.CFrame = CFrame.lookAt(position, position + forward)
	else
		-- No forward direction specified, just position
		part.Position = position
	end
	
	-- Physics
	part.CanCollide = definition.CanCollide
	part.Anchored = definition.Anchored
	part.Massless = definition.Massless or false
	
	-- Optimization
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	
	return part
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- BUILD MODE 2: Model Reference
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

--[[
	Clones a pre-made model from ReplicatedStorage.
	ModelPath format: "Assets.Platforms.WoodenBench"
]]
function SpawnableBuilder.BuildFromModel(
	definition: SpawnableDefinition,
	position: Vector3,
	worldScale: number,
	forward: Vector3?
): Instance
	local modelPath = definition.ModelPath
	if not modelPath then
		error(string.format("[SpawnableBuilder] ModelPath required for ModelReference mode: %s", definition.ID))
	end
	
	-- Navigate to the model using dot notation
	local pathParts = string.split(modelPath, ".")
	local current = ReplicatedStorage
	
	for _, part in pathParts do
		current = current:FindFirstChild(part)
		if not current then
			error(string.format("[SpawnableBuilder] Model not found: %s", modelPath))
		end
	end
	
	-- Clone the model
	local model = current:Clone()
	model.Name = definition.ID
	
	-- Calculate final scale factor (worldScale * modelScale)
	local modelScaleFactor = definition.ModelScale or 1.0
	local finalScale = worldScale * modelScaleFactor
	
	-- Calculate orientation CFrame
	local cframe
	if forward and forward.Magnitude > 0 then
		-- Orient model to face the forward direction
		-- Models are built facing -Z by default in Roblox
		cframe = CFrame.lookAt(position, position + forward)
	else
		-- No forward direction specified, just position
		cframe = CFrame.new(position)
	end
	
	-- Scale the model efficiently
	if model:IsA("Model") then
		-- Verify PrimaryPart is set
		if not model.PrimaryPart then
			error(string.format(
				"[SpawnableBuilder] Model '%s' has no PrimaryPart set! Right-click model → Properties → PrimaryPart",
				definition.ID
			))
		end
		
		-- Use Roblox's built-in ScaleTo (much faster than manual scaling!)
		model:ScaleTo(finalScale)
		
		-- Position and orient the model
		model:PivotTo(cframe)
	elseif model:IsA("BasePart") then
		-- Single part - scale directly
		model.Size = model.Size * finalScale
		model.CFrame = cframe
	end
	
	return model
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- BUILD MODE 3: Custom Builder
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

--[[
	Calls a custom builder function to create complex procedural objects.
]]
function SpawnableBuilder.BuildFromFunction(
	definition: SpawnableDefinition,
	position: Vector3,
	worldScale: number,
	rng: Random
): Instance
	if not definition.BuilderFunction then
		error(string.format("[SpawnableBuilder] BuilderFunction required for CustomBuilder mode: %s", definition.ID))
	end
	
	return definition.BuilderFunction(position, worldScale, rng)
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SPECIAL BEHAVIORS
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

--[[
	Adds jump pad behavior to a part.
	When touched, launches the player upward.
]]
function SpawnableBuilder.AddJumpPadBehavior(part: BasePart, bouncePower: number, worldScale: number)
	-- Scale bounce power with world scale
	local scaledPower = bouncePower * worldScale
	
	-- Store in an attribute for easy debugging
	part:SetAttribute("BouncePower", scaledPower)
	
	-- TODO: This should be handled by a client-side script that reads attributes
	-- For now, we'll just store the data - actual behavior will be added later
end

--[[
	Adds disappearing platform behavior.
	Platform disappears after being stepped on, then respawns.
]]
function SpawnableBuilder.AddDisappearingBehavior(
	part: BasePart,
	disappearTime: number,
	respawnTime: number
)
	-- Store timing in attributes
	part:SetAttribute("DisappearTime", disappearTime)
	part:SetAttribute("RespawnTime", respawnTime)
	part:SetAttribute("IsDisappearing", true)
	
	-- TODO: Client-side script will handle the actual disappearing logic
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- MAIN BUILD FUNCTION
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

--[[
	Main entry point: Builds a complete spawnable from a definition.
	Routes to the appropriate builder based on BuildMode.
]]
function SpawnableBuilder.Build(
	definition: SpawnableDefinition,
	position: Vector3,
	worldScale: number,
	rng: Random,
	parent: Instance?,
	forward: Vector3? -- Optional direction the element should face
): Instance
	-- Build the instance based on mode
	local instance: Instance
	
	if definition.BuildMode == "SimplePart" then
		instance = SpawnableBuilder.BuildSimplePart(definition, position, worldScale, forward)
	elseif definition.BuildMode == "ModelReference" then
		instance = SpawnableBuilder.BuildFromModel(definition, position, worldScale, forward)
	elseif definition.BuildMode == "CustomBuilder" then
		instance = SpawnableBuilder.BuildFromFunction(definition, position, worldScale, rng)
	else
		error(string.format("[SpawnableBuilder] Unknown BuildMode: %s for %s", definition.BuildMode, definition.ID))
	end
	
	-- Add special behaviors if defined (only for SimplePart/CustomBuilder)
	if definition.Properties and instance:IsA("BasePart") then
		local props = definition.Properties
		
		-- Jump Pad
		if props.BouncePower then
			SpawnableBuilder.AddJumpPadBehavior(instance, props.BouncePower, worldScale)
		end
		
		-- Disappearing Platform
		if props.DisappearTime and props.RespawnTime then
			SpawnableBuilder.AddDisappearingBehavior(
				instance,
				props.DisappearTime,
				props.RespawnTime
			)
		end
		
		-- Add more behavior handlers here as needed
	end
	
	-- Parent last for performance
	if parent then
		instance.Parent = parent
	end
	
	return instance
end

return SpawnableBuilder

