--[[
	PlayerServiceServer
	
	Handles player spawning and teleportation.
]]

local Players = game:GetService("Players")

local PlayerServiceServer = {}

-- Store spawn position
local SpawnPosition: Vector3? = nil

--[[
	Sets the spawn position for players
]]
function PlayerServiceServer.SetSpawnPosition(position: Vector3)
	SpawnPosition = position
	print(string.format("[PlayerServiceServer] Spawn position set to: %s", tostring(position)))
end

--[[
	Teleports a player to the spawn position
]]
function PlayerServiceServer.TeleportToSpawn(player: Player)
	if not SpawnPosition then
		warn("[PlayerServiceServer] No spawn position set!")
		return
	end
	
	local character = player.Character
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			-- Teleport slightly above the spawn to avoid clipping
			humanoidRootPart.CFrame = CFrame.new(SpawnPosition + Vector3.new(0, 5, 0))
			print(string.format("[PlayerServiceServer] Teleported %s to spawn", player.Name))
		end
	end
end

--[[
	Handle player joining
]]
local function onPlayerAdded(player: Player)
	print(string.format("[PlayerServiceServer] Player joined: %s", player.Name))
	
	-- Teleport when character spawns
	player.CharacterAdded:Connect(function(character)
		-- Wait for character to load
		character:WaitForChild("HumanoidRootPart")
		wait(0.1) -- Small delay to ensure spawn is ready
		
		PlayerServiceServer.TeleportToSpawn(player)
	end)
end

--[[
	Initialize player service
]]
function PlayerServiceServer.Initialize(spawnPosition: Vector3)
	print("[PlayerServiceServer] Initializing...")
	
	PlayerServiceServer.SetSpawnPosition(spawnPosition)
	
	-- Handle existing players
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	
	-- Handle new players
	Players.PlayerAdded:Connect(onPlayerAdded)
	
	print("[PlayerServiceServer] Ready!")
end

return PlayerServiceServer

