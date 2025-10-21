--[[
	Server Entry Point
	
	Initializes all server-side services and kicks off world generation.
]]

print("[Server] Starting initialization...")

-- Initialize Seed System (must be first - everything depends on this)
local SeedServiceServer = require(script.Services.Seed.SeedServiceServer)
SeedServiceServer.Initialize()

-- Get the seed for potential use
local currentSeed = SeedServiceServer.GetCurrentSeed()
if currentSeed then
	print(string.format("[Server] World will be generated with seed: %d", currentSeed.Value))
end

-- Preload spawnable models (before world generation!)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GrayNodeSpawnables = require(ReplicatedStorage.Shared.Definitions.Spawnables.GrayNodeSpawnables)
local ObstacleSpawnables = require(ReplicatedStorage.Shared.Definitions.Spawnables.ObstacleSpawnables)
local WallSpawnables = require(ReplicatedStorage.Shared.Definitions.Spawnables.WallSpawnables)

print("[Server] Preloading spawnable models...")
GrayNodeSpawnables.Initialize()
ObstacleSpawnables.Initialize()
WallSpawnables.Initialize()
print("[Server] Spawnable models ready!")

-- Initialize World Generation
local WorldGenerationServer = require(script.Services.WorldGeneration.WorldGenerationServer)
local spawnPosition = WorldGenerationServer.Initialize(currentSeed.Value)

-- Initialize Player Service (handles spawning)
local PlayerServiceServer = require(script.Services.Player.PlayerServiceServer)
PlayerServiceServer.Initialize(spawnPosition)

print("[Server] Initialization complete!")

-- TODO: Initialize checkpoint manager (save progress)
-- TODO: Initialize respawn handler (respawn at last checkpoint)
