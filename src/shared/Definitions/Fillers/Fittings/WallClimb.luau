--[[
	Wall Climb Fitting
	
	Creates a tall wall that players must climb by jumping up it.
	Simple wall with ledges for jumping up, then a path across the top.
	
	Perfect for narrow segments - vertical challenge.
]]

local WallClimb = {}

WallClimb.ID = "WallClimb"
WallClimb.DisplayName = "Wall Climb"
WallClimb.AllowAttributes = true
WallClimb.SlotCount = 2  -- 2 attribute slots for this fitting

function WallClimb.Build(
	segmentPosition: Vector3,
	segmentScale: Vector3,
	segmentRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "WallClimb"
	
	-- Extract segment dimensions (ALREADY SCALED!)
	local width = segmentScale.X   -- Lateral (left/right) dimension
	local height = segmentScale.Y  -- Vertical dimension
	local length = segmentScale.Z  -- Forward (start/end) dimension
	local yaw = math.rad(segmentRotation.Y)  -- Segment direction in radians
	
	-- Helper function to convert local offset to world position
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(segmentPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- Wall parameters - MASSIVE FUCKING WALL
	local wallHeight = 50  -- TALL AS HELL
	local wallWidth = width * 0.8  -- 80% of segment width
	local wallDepth = 2  -- Thickness of wall
	local wallPosition = -length * 0.4  -- Position wall at START of segment
	
	-- Create the MASSIVE wall at START
	local wall = Instance.new("Part")
	wall.Name = "MassiveWall"
	wall.Size = Vector3.new(wallWidth, wallHeight, wallDepth)
	wall.Material = Enum.Material.Concrete
	wall.Color = Color3.fromRGB(80, 80, 80)  -- Dark gray concrete
	wall.Anchored = true
	wall.CanCollide = true
	wall.CFrame = getWorldPosition(0, wallHeight / 2, wallPosition)
	wall.Parent = model
	
	-- Create DIVING BOARDS sticking out from the wall ON THE PLAYER SIDE
	local divingBoardCount = 15  -- MANY MORE fucking diving boards
	local boardWidth = 2  -- Width of each diving board
	local boardLength = 4  -- Length sticking out from wall
	local boardThickness = 0.5  -- Height of each board
	
	-- DENSE spacing - boards every 3 studs up the wall
	local boardSpacing = 3  -- 3 studs between boards
	local maxLateralOffset = width * 0.3  -- More lateral variation
	
	for i = 1, divingBoardCount do
		local divingBoard = Instance.new("Part")
		divingBoard.Name = "DivingBoard_" .. i
		divingBoard.Size = Vector3.new(boardWidth, boardThickness, boardLength)
		divingBoard.Material = Enum.Material.Wood
		divingBoard.Color = Color3.fromRGB(200, 100, 50)  -- Orange wood
		divingBoard.Anchored = true
		divingBoard.CanCollide = true
		
		-- DENSE positioning - boards every 3 studs from bottom to top
		local boardY = (i * boardSpacing) + 2  -- Start at 2 studs, then every 3 studs
		local heightVariation = rng:NextNumber(-1, 1)  -- Small height variation
		local lateralVariation = rng:NextNumber(-maxLateralOffset, maxLateralOffset)  -- Lateral variation
		
		-- Position diving board sticking out from wall ON THE PLAYER SIDE
		local boardZ = wallPosition - wallDepth/2 - boardLength/2  -- ON THE PLAYER SIDE
		divingBoard.CFrame = getWorldPosition(lateralVariation, boardY + heightVariation, boardZ)
		divingBoard.Parent = model
	end
	
	-- Create top platform (where players cross over) - spans from wall to end
	local topPlatformWidth = width * 0.9
	local topPlatformDepth = length * 0.8  -- Most of segment length
	local topPlatformHeight = 1
	local topPlatformPosition = 0  -- Center of segment
	
	local topPlatform = Instance.new("Part")
	topPlatform.Name = "TopPlatform"
	topPlatform.Size = Vector3.new(topPlatformWidth, topPlatformHeight, topPlatformDepth)
	topPlatform.Material = Enum.Material.Wood
	topPlatform.Color = Color3.fromRGB(139, 90, 43)  -- Brown wood
	topPlatform.Anchored = true
	topPlatform.CanCollide = true
	topPlatform.CFrame = getWorldPosition(0, wallHeight + topPlatformHeight/2, topPlatformPosition)
	topPlatform.Parent = model
	
	-- Create exit platform (where players land) - at END of segment
	local exitPlatformWidth = width * 0.8
	local exitPlatformDepth = 3
	local exitPlatformHeight = 1
	local exitPlatformPosition = length * 0.4  -- At END of segment
	
	local exitPlatform = Instance.new("Part")
	exitPlatform.Name = "ExitPlatform"
	exitPlatform.Size = Vector3.new(exitPlatformWidth, exitPlatformHeight, exitPlatformDepth)
	exitPlatform.Material = Enum.Material.Wood
	exitPlatform.Color = Color3.fromRGB(139, 90, 43)  -- Brown wood
	exitPlatform.Anchored = true
	exitPlatform.CanCollide = true
	exitPlatform.CFrame = getWorldPosition(0, exitPlatformHeight/2, exitPlatformPosition)
	exitPlatform.Parent = model
	
	return model
end

return WallClimb
