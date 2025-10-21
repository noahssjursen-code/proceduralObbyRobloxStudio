--[[
	Model Loader
	
	Automatically scans ReplicatedStorage/Assets/Spawnables/ folders
	and creates SpawnableDefinitions from any models found.
	
	This allows artists to just drop models in folders and have them
	automatically appear in the game!
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnableTypes = require(script.Parent.SpawnableTypes)
local Config = require(ReplicatedStorage.Shared.Config)
type SpawnableDefinition = SpawnableTypes.SpawnableDefinition

local ModelLoader = {}

-- Get target size dynamically from Config based on category
local function GetTargetSize(category: string): number
	if category == "GrayNode" then
		return Config.WorldGeneration.GrayNodeSize
	elseif category == "OrangeWall" then
		return Config.WorldGeneration.WallDotSize
	elseif category == "PinkObstacle" then
		return Config.WorldGeneration.PinkSmallSize -- Use small obstacle size as base
	elseif category == "RedDanger" then
		return Config.WorldGeneration.RedDangerSize
	elseif category == "PurpleObstacle" then
		return Config.WorldGeneration.PurpleDynamicSize
	elseif category == "Decoration" then
		return Config.WorldGeneration.DecorationDotSizeMin
	else
		return 1.0 -- Fallback
	end
end

--[[
	Scans a folder and creates spawnable definitions from models.
	
	Looks for:
	- Models or Parts in the folder
	- SpawnWeight NumberValue (optional, defaults to 10)
	- MinScale NumberValue (optional, defaults to 0)
	- MaxScale NumberValue (optional, defaults to inf)
]]
local function LoadModelsFromFolder(
	folder: Instance,
	category: string,
	canCollide: boolean
): { SpawnableDefinition }
	local spawnables = {}
	
	for _, child in folder:GetChildren() do
		-- Skip non-model/part children and README files
		if not (child:IsA("Model") or child:IsA("BasePart")) then
			continue
		end
		
		-- Get spawn weight from child attribute or default to 10
		local spawnWeight = 10
		local spawnWeightValue = child:FindFirstChild("SpawnWeight")
		if spawnWeightValue and spawnWeightValue:IsA("NumberValue") then
			spawnWeight = spawnWeightValue.Value
		end
		
		-- Get model scale factor (for normalizing different sized models)
		local modelScale = nil
		local modelScaleValue = child:FindFirstChild("ModelScale")
		if modelScaleValue and modelScaleValue:IsA("NumberValue") then
			modelScale = modelScaleValue.Value
			print(string.format("[ModelLoader] Manual scale for %s: %.3fx", child.Name, modelScale))
		else
			-- AUTO-SCALING LOGIC:
			-- Gray nodes & Walls: Auto-scale from player scale → base size (so they work with WorldScale)
			-- Obstacles: Use as-is at 1.0x (they stay player-sized regardless of WorldScale)
			if category == "GrayNode" or category == "OrangeWall" then
				-- AUTO-CALCULATE: Scale model to match target size for this category
				local targetSize = GetTargetSize(category)
				local modelSize = Vector3.zero
				local actualSize = 0
				
				if child:IsA("Model") and child.PrimaryPart then
					modelSize = child.PrimaryPart.Size
					actualSize = math.max(modelSize.X, modelSize.Z) -- Use largest horizontal dimension
				elseif child:IsA("BasePart") then
					modelSize = child.Size
					actualSize = math.max(modelSize.X, modelSize.Z)
				end
				
				if actualSize > 0 then
					-- Calculate auto-scale: target size / model size
					modelScale = targetSize / actualSize
				else
					modelScale = 1.0 -- Fallback
					warn(string.format("[ModelLoader] Could not determine size for %s, using scale=1.0", child.Name))
				end
			else
				-- Obstacles: use at the size you built them (no auto-scaling)
				modelScale = 1.0
			end
		end
		
		-- Get scale constraints
		local minScale = 0
		local minScaleValue = child:FindFirstChild("MinScale")
		if minScaleValue and minScaleValue:IsA("NumberValue") then
			minScale = minScaleValue.Value
		end
		
		local maxScale = math.huge
		local maxScaleValue = child:FindFirstChild("MaxScale")
		if maxScaleValue and maxScaleValue:IsA("NumberValue") then
			maxScale = maxScaleValue.Value
		end
		
		-- Create spawnable definition
		local spawnable: SpawnableDefinition = {
			ID = child.Name,
			DisplayName = child.Name,
			Category = category,
			
			BuildMode = "ModelReference",
			ModelPath = "Assets.Spawnables." .. folder.Name .. "." .. child.Name,
			ModelScale = modelScale,
			
			CanCollide = canCollide,
			Anchored = true,
			Massless = true,
			
			SpawnWeight = spawnWeight,
			MinScale = minScale > 0 and minScale or nil,
			MaxScale = maxScale < math.huge and maxScale or nil,
		}
		
		table.insert(spawnables, spawnable)
	end
	
	-- Summary log
	if #spawnables > 0 then
		print(string.format("[ModelLoader] %s: Loaded %d model(s)", folder.Name, #spawnables))
	end
	
	return spawnables
end

--[[
	Load all Gray Node models (walkable platforms)
]]
function ModelLoader.LoadGrayNodeModels(): { SpawnableDefinition }
	local folder = ReplicatedStorage:FindFirstChild("Assets")
	if not folder then
		warn("[ModelLoader] Assets folder not found in ReplicatedStorage")
		return {}
	end
	
	local spawnablesFolder = folder:FindFirstChild("Spawnables")
	if not spawnablesFolder then
		warn("[ModelLoader] Spawnables folder not found in Assets")
		return {}
	end
	
	local grayNodeFolder = spawnablesFolder:FindFirstChild("GrayNode")
	if not grayNodeFolder then
		warn("[ModelLoader] GrayNode folder not found in Spawnables")
		return {}
	end
	
	print("[ModelLoader] Loading Gray Node models...")
	return LoadModelsFromFolder(grayNodeFolder, "GrayNode", true)
end

--[[
	Load all Pink Obstacle models
]]
function ModelLoader.LoadPinkObstacleModels(): { SpawnableDefinition }
	local folder = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Spawnables")
		and ReplicatedStorage.Assets.Spawnables:FindFirstChild("PinkObstacle")
	
	if not folder then
		return {}
	end
	
	print("[ModelLoader] Loading Pink Obstacle models...")
	return LoadModelsFromFolder(folder, "PinkObstacle", true)
end

--[[
	Load all Red Danger models
]]
function ModelLoader.LoadRedDangerModels(): { SpawnableDefinition }
	local folder = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Spawnables")
		and ReplicatedStorage.Assets.Spawnables:FindFirstChild("RedDanger")
	
	if not folder then
		return {}
	end
	
	print("[ModelLoader] Loading Red Danger models...")
	return LoadModelsFromFolder(folder, "RedDanger", true)
end

--[[
	Load all Purple Dynamic Obstacle models
]]
function ModelLoader.LoadPurpleObstacleModels(): { SpawnableDefinition }
	local folder = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Spawnables")
		and ReplicatedStorage.Assets.Spawnables:FindFirstChild("PurpleObstacle")
	
	if not folder then
		return {}
	end
	
	print("[ModelLoader] Loading Purple Dynamic Obstacle models...")
	return LoadModelsFromFolder(folder, "PurpleObstacle", true)
end

--[[
	Load all Decoration models
]]
function ModelLoader.LoadDecorationModels(): { SpawnableDefinition }
	local folder = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Spawnables")
		and ReplicatedStorage.Assets.Spawnables:FindFirstChild("Decoration")
	
	if not folder then
		return {}
	end
	
	print("[ModelLoader] Loading Decoration models...")
	return LoadModelsFromFolder(folder, "Decoration", false) -- Decorations are non-collidable
end

--[[
	Load all Orange Wall models
]]
function ModelLoader.LoadOrangeWallModels(): { SpawnableDefinition }
	local folder = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Spawnables")
		and ReplicatedStorage.Assets.Spawnables:FindFirstChild("OrangeWall")
	
	if not folder then
		return {}
	end
	
	print("[ModelLoader] Loading Orange Wall models...")
	return LoadModelsFromFolder(folder, "OrangeWall", true) -- Walls are collidable
end

return ModelLoader

