--[[
	Spinning Blades Attribute
	
	Large horizontal rotating blades that spin slowly like ceiling fans.
	Player must time their movement to pass through when the blade is rotated away.
	
	Difficulty: Medium
	Compatible: All fittings (works best with paths/bridges)
]]

local RunService = game:GetService("RunService")

local SpinningBlades = {}

SpinningBlades.ID = "SpinningBlades"
SpinningBlades.DisplayName = "Spinning Blades"
SpinningBlades.CompatibleFittings = {"all"}

function SpinningBlades.BuildInSlot(
	slotPosition: Vector3,
	slotScale: Vector3,
	slotRotation: Vector3,
	worldScale: number,
	rng: Random
): Instance
	local model = Instance.new("Model")
	model.Name = "SpinningBlades"
	
	local width = slotScale.X
	local height = slotScale.Y
	local length = slotScale.Z
	local yaw = math.rad(slotRotation.Y)
	
	-- Helper function for world positioning
	local function getWorldPosition(lateralOffset: number, verticalOffset: number, forwardOffset: number): CFrame
		local localOffset = CFrame.Angles(0, yaw, 0) * Vector3.new(lateralOffset, verticalOffset, forwardOffset)
		return CFrame.new(slotPosition + localOffset) * CFrame.Angles(0, yaw, 0)
	end
	
	-- Player-scale constants (these are LARGE)
	local bladeLength = 20  -- Very large blade (player-scale)
	local bladeThickness = 0.8
	local bladeWidth = 3
	local spinDuration = rng:NextNumber(6, 9)  -- Slow but visible spin (6-9 seconds per rotation)
	
	-- Determine number of blades based on slot size
	local bladeCount = 1
	if length > 60 then
		bladeCount = 2  -- Two blades for longer slots
	end
	
	-- Create blades
	for i = 1, bladeCount do
		-- Calculate position along slot
		local forwardOffset = 0
		if bladeCount == 2 then
			forwardOffset = (i == 1) and -length * 0.25 or length * 0.25
		end
		
		-- Create pivot point (center of rotation)
		local pivot = Instance.new("Part")
		pivot.Name = "BladePivot" .. i
		pivot.Size = Vector3.new(1.5, 1.5, 1.5)
		pivot.Material = Enum.Material.Metal
		pivot.Color = Color3.fromRGB(60, 60, 60)
		pivot.Anchored = true
		pivot.CanCollide = false
		pivot.Transparency = 0.5
		
		-- Position pivot in center of slot (height-wise)
		local pivotHeight = height * 0.25
		local pivotCFrame = getWorldPosition(0, pivotHeight, forwardOffset)
		
		-- Both blade types use same pivot orientation (spin around Y axis)
		pivot.CFrame = pivotCFrame
		
		pivot.Parent = model
		
		-- Create the blade (thin, long, dangerous)
		-- Horizontal blade (flat, extends left/right)
		local blade = Instance.new("Part")
		blade.Name = "Blade" .. i
		blade.Size = Vector3.new(bladeLength, bladeThickness, bladeWidth)
		
		blade.Material = Enum.Material.Metal
		blade.Color = Color3.fromRGB(150, 150, 160)  -- Gray metal
		blade.Anchored = false  -- Welded to pivot
		blade.CanCollide = true
		
		-- Mark as deadly
		blade:SetAttribute("Deadly", true)
		blade:SetAttribute("DamageType", "Blade")
		
		-- Position blade at pivot
		blade.CFrame = pivot.CFrame
		blade.Parent = model
		
		-- Add sharp edges (accent parts)
		for edgeIndex = 1, 2 do
			local edge = Instance.new("Part")
			edge.Name = "BladeEdge" .. i .. "_" .. edgeIndex
			edge.Size = Vector3.new(bladeLength * 0.95, bladeThickness * 0.3, bladeWidth * 0.8)
			
			edge.Material = Enum.Material.Neon
			edge.Color = Color3.fromRGB(255, 50, 50)  -- Red glow for danger
			edge.Anchored = false
			edge.CanCollide = false
			edge.Transparency = 0.3
			
			-- Position edge on front or back of blade
			local edgeOffset = (edgeIndex == 1) and bladeWidth * 0.35 or -bladeWidth * 0.35
			edge.CFrame = blade.CFrame * CFrame.new(0, 0, edgeOffset)
			
			edge.Parent = model
			
			-- Weld edge to blade
			local weldEdge = Instance.new("WeldConstraint")
			weldEdge.Part0 = blade
			weldEdge.Part1 = edge
			weldEdge.Parent = blade
		end
		
		-- Add center hub (cylinder on Y axis for both types)
		local hub = Instance.new("Part")
		hub.Name = "Hub" .. i
		hub.Shape = Enum.PartType.Cylinder
		hub.Size = Vector3.new(3, 3, 3)  -- Sphere-like cylinder
		hub.Material = Enum.Material.Metal
		hub.Color = Color3.fromRGB(40, 40, 40)  -- Dark metal
		hub.Anchored = false
		hub.CanCollide = false
		
		-- Cylinder needs to be rotated to align with Y axis (cylinders are X-axis by default)
		hub.CFrame = blade.CFrame * CFrame.Angles(0, 0, math.rad(90))
		
		hub.Parent = model
		
		-- Weld hub to blade
		local weldHub = Instance.new("WeldConstraint")
		weldHub.Part0 = blade
		weldHub.Part1 = hub
		weldHub.Parent = blade
		
		-- Keep pivot anchored for solid collision
		pivot.Anchored = true
		
		-- Weld blade to pivot (blade will rotate with pivot)
		local weldBlade = Instance.new("WeldConstraint")
		weldBlade.Part0 = pivot
		weldBlade.Part1 = blade
		weldBlade.Parent = pivot
		
		-- Set up continuous rotation using TweenService
		local baseCFrame = pivot.CFrame
		
		-- Spin continuously using RunService.Heartbeat
		task.spawn(function()
			local startTime = tick()
			
			-- Connect to Heartbeat for smooth rotation every frame
			local connection
			connection = RunService.Heartbeat:Connect(function()
				if not pivot.Parent then
					connection:Disconnect()
					return
				end
				
				local elapsed = tick() - startTime
				local rotationProgress = (elapsed % spinDuration) / spinDuration
				local angle = rotationProgress * math.pi * 2
				
				-- Rotate around Y axis continuously
				pivot.CFrame = baseCFrame * CFrame.Angles(0, angle, 0)
			end)
		end)
	end
	
	return model
end

return SpinningBlades

