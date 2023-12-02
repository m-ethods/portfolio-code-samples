-- LocalScript with a custom module that allows your character to have realistic gravity around a sphere (similar to Outer Wilds)

local CHARACTERS = game.Workspace.CHARACTERS
while game.Players.LocalPlayer.Character.Parent ~= CHARACTERS do wait() end
local controller = require(game.ReplicatedStorage.Controller).new(game.Players.LocalPlayer)

-- checkpoint system
local player = game.Players.LocalPlayer
-- custom controller

local Planets = workspace.Planets
local PlanetCores = {}

for _,PlanetFolder in next, Planets:GetChildren() do 
	table.insert(PlanetCores, PlanetFolder.Core)
end

controller.Ignore = CHARACTERS
controller.Cast.Ignore = CHARACTERS
controller.CustomCameraEnabled = true
controller.CustomCameraSpinWithrParts = true

controller:SetEnabled(true)

function GetClosestCore()
	local Position = player.Character.HumanoidRootPart.Position
	local Closest = nil
	local ClosestMagnitude = nil
	
	for _, Core in next, PlanetCores do 
		if not Closest then 
			Closest = Core 
			ClosestMagnitude = (Position - Core.Position).magnitude
			continue 
		end
		
		local CalculatedMagnitude = (Position - Core.Position).magnitude
		if CalculatedMagnitude < ClosestMagnitude then
			Closest = Core
			ClosestMagnitude = CalculatedMagnitude
		end
	end
	
	return Closest, ClosestMagnitude
end

function CastRay(Origin, Target, Length, Ignore, IgnoreWater)
	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Whitelist

	if typeof(Origin) == "Ray" then
		if type(Target) == "table" then
			RayParams.FilterDescendantsInstances = Target
			RayParams.IgnoreWater = Length
		else
			RayParams.IgnoreWater = Target
		end

		return workspace:Raycast(Origin.Origin, Origin.Direction, RayParams)
	else
		if type(Ignore) == "table" then
			RayParams.FilterDescendantsInstances = Ignore
			RayParams.IgnoreWater = IgnoreWater
		else
			RayParams.IgnoreWater = Ignore
		end

		return workspace:Raycast(Origin, Length == false and Target or (Target - Origin).Unit * Length, RayParams)
	end
end

game:GetService("RunService"):BindToRenderStep("After Camera", Enum.RenderPriority.Last.Value + 1, function(dt)
	local ClosestCore, Magnitude = GetClosestCore()
	local Position = player.Character.HumanoidRootPart.Position
		
	local RaycastResult = CastRay(Position, ClosestCore.Position, Magnitude + 1000, PlanetCores, true)
	print(RaycastResult)
	
	controller:SetNormal(RaycastResult.Normal, ClosestCore)
	controller:Update(dt)
end)
