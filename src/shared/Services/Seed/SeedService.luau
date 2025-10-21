--[[
	SeedService
	
	Defines the seed structure and configuration for world generation.
	The seed determines the entire world layout - same seed = same world.
]]

local SeedService = {}

-- Seed configuration
SeedService.Config = {
	-- For now, generate random seeds each server start
	-- Later: weekly seed system with rotation
	UseWeeklySeed = false,
	
	-- Seed value range
	MinSeed = 1,
	MaxSeed = 999999999,
}

-- Seed data structure
export type SeedData = {
	Value: number,
	GeneratedAt: number, -- Unix timestamp
	WeekNumber: number?, -- For future weekly system
}

return SeedService

