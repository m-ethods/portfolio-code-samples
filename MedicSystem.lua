-- Medical system, allows you to have injuries with different levels, on different body parts. Was meant to be viewable on an X-Ray like machine.
-- https://www.youtube.com/watch?v=76M5deM2MbY

-- liyud 

local MedicalSystem = {}

-- Private

-- Public

local Players = game:GetService("Players")
local Network = require(game.ReplicatedStorage.network)

_G.MedicStarted = false
_G.MedicalPlayer = _G.MedicalPlayer or {}

function MedicalSystem.__init()
	if _G.MedicStarted then
		return
	end

	Players.PlayerAdded:Connect(function(Player)
		-- Set up for incoming players
		_G.MedicalPlayer[Player.Name] = {
			LimbDefinition = {
				["Head"] = {},
				["Torso"] = {},
				["LeftLeg"] = {},
				["RightLeg"] = {},
				["LeftArm"] = {},
				["RightArm"] = {}
			}
		}
	end)

	for _,Player in next, Players:GetPlayers() do
		-- Set up for existing players
		if not _G.MedicalPlayer[Player.Name] then
			_G.MedicalPlayer[Player.Name] = {
				LimbDefinition = {
					["Head"] = {},
					["Torso"] = {},
					["LeftLeg"] = {},
					["RightLeg"] = {},
					["LeftArm"] = {},
					["RightArm"] = {}
				}
			}
		end
	end

	Players.PlayerRemoving:Connect(function(Player)
		-- Clean up the player's table when he disconnect
		_G.MedicalPlayer[Player.Name] = nil
	end)

	_G.MedicStarted = true
end

function MedicalSystem.Injure(Player, Limb, Injury, Severity)
	table.insert(_G.MedicalPlayer[Player.Name].LimbDefinition[Limb], {
		Name = Injury,
		Severity = Severity or 1,
		Description = require(script:FindFirstChild(Injury))
	})
end	

function MedicalSystem.Heal(Player, Limb, Injury)
	for index,injury in next, _G.MedicalPlayer[Player.Name].LimbDefinition[Limb] do 
		if injury.Name == Injury then
			table.remove(_G.MedicalPlayer[Player.Name].LimbDefinition[Limb], index)
			return
		end
	end
end

function MedicalSystem.HealFully(Player)
	_G.MedicalPlayer[Player.Name].LimbDefinition = {
			["Head"] = {},
			["Torso"] = {},
			["LeftLeg"] = {},
			["RightLeg"] = {},
			["LeftArm"] = {},
			["RightArm"] = {}
		}
end

function MedicalSystem.GetPlayerStatus(Invoker, RequestedPlayer)
	if not RequestedPlayer then
		return _G.MedicalPlayer[Invoker]
	else
		return _G.MedicalPlayer[RequestedPlayer.Name]
	end
end

MedicalSystem.__init()
Network.bindNetworkedFunction(Network.registerNetworkedFunction('getmedicalplayerstatus'), MedicalSystem.GetPlayerStatus);

return MedicalSystem
