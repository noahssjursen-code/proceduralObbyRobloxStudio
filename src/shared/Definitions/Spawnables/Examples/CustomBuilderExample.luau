--[[
	Example: Custom Builder Spawnable
	
	This shows how to programmatically build complex multi-part structures.
	Use this for procedurally generated objects like ladders, bridges, arches, etc.
]]

local SpawnableTypes = require(script.Parent.Parent.SpawnableTypes)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- BUILDER FUNCTIONS
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

--[[
	Example: Build a procedural ladder
	
	Parameters:
	- position: Where to place the ladder
	- worldScale: Current world scale multiplier
	- rng: Random number generator (for variety)
]]
local function BuildLadder(position: Vector3, worldScale: number, rng: Random): Instance
	local model = Instance.new("Model")
	model.Name = "ProceduralLadder"
	
	-- Scale all measurements
	local rungCount = 5
	local rungSpacing = 0.3 * worldScale
	local rungWidth = 0.8 * worldScale
	local rungThickness = 0.1 * worldScale
	local sideWidth = 0.15 * worldScale
	local height = rungCount * rungSpacing
	
	-- Left side rail
	local leftSide = Instance.new("Part")
	leftSide.Name = "LeftSide"
	leftSide.Size = Vector3.new(sideWidth, height, sideWidth)
	leftSide.Position = position + Vector3.new(-rungWidth / 2, 0, 0)
	leftSide.Anchored = true
	leftSide.Material = Enum.Material.Wood
	leftSide.BrickColor = BrickColor.new("Brown")
	leftSide.Parent = model
	
	-- Right side rail
	local rightSide = Instance.new("Part")
	rightSide.Name = "RightSide"
	rightSide.Size = Vector3.new(sideWidth, height, sideWidth)
	rightSide.Position = position + Vector3.new(rungWidth / 2, 0, 0)
	rightSide.Anchored = true
	rightSide.Material = Enum.Material.Wood
	rightSide.BrickColor = BrickColor.new("Brown")
	rightSide.Parent = model
	
	-- Create rungs (the steps you climb on)
	for i = 0, rungCount - 1 do
		local rung = Instance.new("Part")
		rung.Name = "Rung_" .. i
		rung.Size = Vector3.new(rungWidth, rungThickness, sideWidth)
		rung.Position = position + Vector3.new(0, (-height / 2) + (i * rungSpacing), 0)
		rung.Anchored = true
		rung.Material = Enum.Material.Wood
		rung.BrickColor = BrickColor.new("Brown")
		rung.CanCollide = true -- You can stand on rungs
		rung.Parent = model
		
		-- Add slight random rotation for variety
		local randomTilt = rng:NextNumber(-2, 2) -- +/- 2 degrees
		rung.CFrame = rung.CFrame * CFrame.Angles(0, 0, math.rad(randomTilt))
	end
	
	-- Set the primary part for easy positioning
	model.PrimaryPart = leftSide
	
	return model
end

--[[
	Example: Build a procedural stone arch
]]
local function BuildStoneArch(position: Vector3, worldScale: number, rng: Random): Instance
	local model = Instance.new("Model")
	model.Name = "ProceduralArch"
	
	-- Scale measurements
	local pillarWidth = 0.5 * worldScale
	local pillarHeight = 2 * worldScale
	local archWidth = 2.5 * worldScale
	local archThickness = 0.4 * worldScale
	
	-- Left pillar
	local leftPillar = Instance.new("Part")
	leftPillar.Name = "LeftPillar"
	leftPillar.Size = Vector3.new(pillarWidth, pillarHeight, pillarWidth)
	leftPillar.Position = position + Vector3.new(-archWidth / 2, 0, 0)
	leftPillar.Anchored = true
	leftPillar.Material = Enum.Material.Slate
	leftPillar.Color = Color3.fromRGB(100, 100, 100)
	leftPillar.CanCollide = true
	leftPillar.Parent = model
	
	-- Right pillar
	local rightPillar = Instance.new("Part")
	rightPillar.Name = "RightPillar"
	rightPillar.Size = Vector3.new(pillarWidth, pillarHeight, pillarWidth)
	rightPillar.Position = position + Vector3.new(archWidth / 2, 0, 0)
	rightPillar.Anchored = true
	rightPillar.Material = Enum.Material.Slate
	rightPillar.Color = Color3.fromRGB(100, 100, 100)
	rightPillar.CanCollide = true
	rightPillar.Parent = model
	
	-- Top arch (curved with multiple segments)
	local archSegments = 5
	for i = 0, archSegments do
		local t = i / archSegments -- 0 to 1
		local angle = math.pi * t -- 0 to 180 degrees
		
		-- Calculate position along arc
		local arcX = math.cos(angle) * (archWidth / 2)
		local arcY = math.sin(angle) * (pillarHeight / 2) + (pillarHeight / 2)
		
		local segment = Instance.new("Part")
		segment.Name = "ArchSegment_" .. i
		segment.Size = Vector3.new(archThickness, archThickness, pillarWidth)
		segment.Position = position + Vector3.new(arcX, arcY, 0)
		segment.Anchored = true
		segment.Material = Enum.Material.Slate
		segment.Color = Color3.fromRGB(110, 110, 110)
		segment.CanCollide = true
		segment.Parent = model
	end
	
	model.PrimaryPart = leftPillar
	return model
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SPAWNABLE DEFINITIONS
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local ProceduralLadder = {
	ID = "ProceduralLadder",
	DisplayName = "Procedural Ladder",
	Category = "GrayNode",
	
	BuildMode = "CustomBuilder",
	BuilderFunction = BuildLadder, -- Reference the function
	
	CanCollide = true,
	Anchored = true,
	Massless = true,
	
	SpawnWeight = 15,
	MinScale = 10,
} :: SpawnableDefinition

local ProceduralArch = {
	ID = "ProceduralArch",
	DisplayName = "Procedural Arch",
	Category = "GrayNode",
	
	BuildMode = "CustomBuilder",
	BuilderFunction = BuildStoneArch,
	
	CanCollide = true,
	Anchored = true,
	Massless = true,
	
	SpawnWeight = 10,
	MinScale = 15,
} :: SpawnableDefinition

--[[
	To use these:
	1. Add them to GrayNodeSpawnables.GetAll()
	2. They'll automatically be included in the random selection
	3. The builder function will be called when spawned
	
	Builder functions receive:
	- position: Where to build
	- worldScale: Scale multiplier for ALL measurements
	- rng: Use this for random variations (keeps it deterministic)
]]

return {
	ProceduralLadder = ProceduralLadder,
	ProceduralArch = ProceduralArch,
}

