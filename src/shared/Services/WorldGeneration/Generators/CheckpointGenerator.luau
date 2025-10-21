--[[
	CheckpointGenerator
	
	Generates checkpoint positions in 3D space.
	"Shotgun spread" pattern - spreading out from spawn.
	
	UPWARD TRENDING: Each checkpoint is progressively higher to prevent
	players from skipping checkpoints by falling.
]]

local CheckpointGenerator = {}

--[[
	Generate checkpoint positions
	Returns array of checkpoint elements
]]
function CheckpointGenerator.Generate(rng: Random, spawnPos: Vector3, config: any): {any}
	local elements = {}
	
	local checkpointCount = config.CheckpointCount
	local checkpointSize = config.CheckpointSize
	local spawnCheckpointSize = config.SpawnCheckpointSize or checkpointSize
	local minDistance = config.MinDistance
	local maxDistance = config.MaxDistance
	local spreadAngle = config.SpreadAngle
	local color = config.Color
	
	-- First checkpoint IS the spawn (checkpoint 1) - slightly larger than regular checkpoints
	table.insert(elements, {
		Type = "CheckpointOrb",
		Position = spawnPos,
		Scale = Vector3.new(spawnCheckpointSize, spawnCheckpointSize, spawnCheckpointSize),
		Properties = {
			Material = Enum.Material.Neon,
			Color = color,
			CheckpointNumber = 1,
			Brightness = 2,
			IsSpawn = true,
		}
	})
	
	local currentPosition = spawnPos
	local currentDirection = Vector3.new(0, 0, 1) -- Start pointing forward
	local currentHeight = spawnPos.Y -- Track height progression
	
	-- Generate remaining checkpoints (2 through checkpointCount)
	for i = 2, checkpointCount do
		-- Random distance
		local distance = rng:NextNumber(minDistance, maxDistance)
		
		-- Add random spread to HORIZONTAL direction only (shotgun effect in X/Z)
		local spreadX = math.rad(rng:NextNumber(-spreadAngle, spreadAngle))
		-- No spreadY - we'll control vertical separately
		
		-- Rotate direction vector (only horizontal rotation)
		local newDirection = CFrame.Angles(0, spreadX, 0) * currentDirection
		
		-- Calculate next position (horizontal only)
		local horizontalMovement = newDirection * distance
		
		-- Progressive height increase (trending upward)
		local heightIncreaseMin = config.HeightIncreaseMin or 5
		local heightIncreaseMax = config.HeightIncreaseMax or 15
		local heightIncrease = rng:NextNumber(heightIncreaseMin, heightIncreaseMax)
		currentHeight = currentHeight + heightIncrease
		
		-- Update current position with horizontal movement + upward trend
		currentPosition = Vector3.new(
			currentPosition.X + horizontalMovement.X,
			currentHeight,
			currentPosition.Z + horizontalMovement.Z
		)
		
		-- Update direction for next iteration
		currentDirection = newDirection
		
		-- Create checkpoint element
		table.insert(elements, {
			Type = "CheckpointOrb",
			Position = currentPosition,
			Scale = Vector3.new(checkpointSize, checkpointSize, checkpointSize),
			Properties = {
				Material = Enum.Material.Neon,
				Color = color,
				CheckpointNumber = i,
				Brightness = 2,
			}
		})
	end
	
	print(string.format("[CheckpointGenerator] Generated %d checkpoints", #elements))
	
	return elements
end

return CheckpointGenerator

