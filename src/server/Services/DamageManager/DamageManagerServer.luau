--[[
	DamageManager Server
	
	Handles all damage/death logic in one centralized service.
	Scans world after generation and hooks up deadly parts.
	
	Uses CollectionService tags for performance.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local DamageManagerServer = {}

-- Tag for deadly parts
local DEADLY_TAG = "Deadly"

-- Debounce table to prevent spam killing
local killingDebounce = {}
local DEBOUNCE_TIME = 0.5 -- Seconds

--[[
	Kill a player
]]
local function KillPlayer(player: Player, damageType: string)
	-- Check debounce
	if killingDebounce[player] then
		return
	end
	
	killingDebounce[player] = true
	
	-- Get humanoid
	local character = player.Character
	if not character then
		killingDebounce[player] = nil
		return
	end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		killingDebounce[player] = nil
		return
	end
	
	-- Kill player
	print(string.format("[DamageManager] %s killed by %s", player.Name, damageType or "Unknown"))
	humanoid.Health = 0
	
	-- Clear debounce after time
	task.delay(DEBOUNCE_TIME, function()
		killingDebounce[player] = nil
	end)
end

--[[
	Hook up a deadly part
]]
local function HookupDeadlyPart(part: BasePart)
	-- Get damage type from attribute
	local damageType = part:GetAttribute("DamageType") or "Deadly"
	
	-- Connect touched event
	part.Touched:Connect(function(hit)
		-- Check if hit is a player character
		local character = hit.Parent
		if not character then return end
		
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		
		-- Kill player
		KillPlayer(player, damageType)
	end)
	
	print(string.format("[DamageManager] Hooked up deadly part: %s (Type: %s)", part.Name, damageType))
end

--[[
	Initialize damage system
	Call this AFTER world generation is complete
]]
function DamageManagerServer.Initialize()
	print("[DamageManagerServer] Initializing...")
	
	-- Find all parts with Deadly attribute and tag them
	local deadlyCount = 0
	
	for _, descendant in workspace:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute("Deadly") then
			-- Add tag for CollectionService
			CollectionService:AddTag(descendant, DEADLY_TAG)
			deadlyCount += 1
		end
	end
	
	print(string.format("[DamageManagerServer] Found %d deadly parts", deadlyCount))
	
	-- Hook up all existing deadly parts
	for _, part in CollectionService:GetTagged(DEADLY_TAG) do
		if part:IsA("BasePart") then
			HookupDeadlyPart(part)
		end
	end
	
	-- Listen for new deadly parts (in case they're added later)
	CollectionService:GetInstanceAddedSignal(DEADLY_TAG):Connect(function(instance)
		if instance:IsA("BasePart") then
			HookupDeadlyPart(instance)
		end
	end)
	
	print("[DamageManagerServer] Ready!")
end

return DamageManagerServer

