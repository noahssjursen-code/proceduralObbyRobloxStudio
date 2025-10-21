--[[
	SeedServiceServer
	
	Generates and manages the world seed on the server.
	Other services will request the seed from this module.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SeedService = require(ReplicatedStorage.Shared.Services.Seed.SeedService)

local SeedServiceServer = {}

-- Store the current seed
local CurrentSeed: SeedService.SeedData? = nil

--[[
	Generates a new random seed for this game session.
]]
function SeedServiceServer.GenerateNewSeed(): SeedService.SeedData
	local seedValue = math.random(SeedService.Config.MinSeed, SeedService.Config.MaxSeed)
	
	local seedData: SeedService.SeedData = {
		Value = seedValue,
		GeneratedAt = os.time(),
		WeekNumber = nil, -- Will be used later for weekly system
	}
	
	CurrentSeed = seedData
	
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("🌍 WORLD SEED GENERATED")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print(string.format("   Seed Value: %d", seedData.Value))
	print(string.format("   Generated: %s", os.date("%Y-%m-%d %H:%M:%S", seedData.GeneratedAt)))
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	
	return seedData
end

--[[
	Gets the current seed. Returns nil if no seed has been generated yet.
]]
function SeedServiceServer.GetCurrentSeed(): SeedService.SeedData?
	return CurrentSeed
end

--[[
	Initializes the seed system. Call this from init.server.luau.
]]
function SeedServiceServer.Initialize()
	print("[SeedServiceServer] Initializing...")
	SeedServiceServer.GenerateNewSeed()
	print("[SeedServiceServer] Ready!")
end

return SeedServiceServer

