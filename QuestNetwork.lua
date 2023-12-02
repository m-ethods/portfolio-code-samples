-- Network script for quests system.

-- Liyud
--// Services
local Nexus = require(game:GetService("ReplicatedStorage").Nexus.NexusInit):Init()

--// Directories
local Events = game.ReplicatedStorage.Events
local Remotes = Events.Remotes
local Functions = Events.Functions

--// Initiation
local Network = {}
Network.__index = Network

--// Variables
local ActiveQuests = {}
local PlayerProgress = {}

local QuestNetworks = {
	["Combat"] = {
		game.Teams["Security Department"],
		game.Teams["Rapid Response Team"],
		game.Teams["Mobile Task Forces"],
	},
	
	["Scientific"] = {
		game.Teams["Scientific Department"],
	},
	
	["Intelligence"] = {
		game.Teams["Intelligence Agency"],
		game.Teams["Ethics Committee"],
		game.Teams["Site Director"]
	},
	
	["Hostile"] = {
		game.Teams["Chaos Insurgency"],
		game.Teams["The Horizion Initiative"]
	},
	
	["Subjects"] = {
		game.Teams["Class - D"]
	}
}

--// Functions
function GetQuest(Name)
	for _, Folder in pairs(Nexus.Services('ServerScriptService').Server.Quests.Quests:GetDescendants()) do
		if Folder.Name == Name then
			return Folder
		end
	end
end

--// Methods
function Network:GetActiveQuests(Player)
	for NetworkName,NetworkTeams in QuestNetworks do 
		if table.find(NetworkTeams, Player.Team) then
			return ActiveQuests[NetworkName],NetworkName
		end
	end
end

function Network:ProgressPlayer(Player, QuestName, ProgressNumber)
	local ActivePlayerQuests,NetworkName = self:GetActiveQuests(Player)
	local CurrentPlayerProgress = self:GetPlayerProgress(Player)

	if ActivePlayerQuests[QuestName] == nil or PlayerProgress[Player.Name][NetworkName] == nil or PlayerProgress[Player.Name][NetworkName][QuestName] == nil or PlayerProgress[Player.Name][NetworkName][QuestName].Progress == ActivePlayerQuests[QuestName].ProgressInt then return end

	PlayerProgress[Player.Name][NetworkName][QuestName].Progress += ProgressNumber
		
	if PlayerProgress[Player.Name][NetworkName][QuestName].Progress == ActivePlayerQuests[QuestName].ProgressInt and not CurrentPlayerProgress[QuestName].Claimed then
		self:Reward(Player, QuestName)
	end
end

function Network:GetPlayerProgress(Player)
	local ActivePlayerQuests,NetworkName = self:GetActiveQuests(Player)
	
	if (not PlayerProgress[Player.Name]) or (not PlayerProgress[Player.Name][NetworkName])then
		if not PlayerProgress[Player.Name] then
			PlayerProgress[Player.Name] = {}
		end
		PlayerProgress[Player.Name][NetworkName] = {}
		for QName in next, ActivePlayerQuests do 
			PlayerProgress[Player.Name][NetworkName][QName] = {}
			PlayerProgress[Player.Name][NetworkName][QName].Progress = 0
			PlayerProgress[Player.Name][NetworkName][QName].Claimed = false
		end
	end
	
	return PlayerProgress[Player.Name][NetworkName]
end

function Network:Reward(Player, Quest)
	local CurrentPlayerProgress = self:GetPlayerProgress(Player)
	local CurrentActiveQuests,NetworkName = self:GetActiveQuests(Player)
	local RequestedQuest = CurrentPlayerProgress[Quest]
	
	if CurrentPlayerProgress.Progress == RequestedQuest.ProgressInt and not CurrentPlayerProgress[Quest].Claimed then
		PlayerProgress[Player.Name][NetworkName][Quest].Claimed = true
		Remotes.Quests.Claim:FireClient(Player, Quest, CurrentActiveQuests[Quest])
		--shared:Require.RewardHandler:Reward(Player, CurrentActiveQuests[Quest].Reward.Tix, CurrentActiveQuests[Quest].Reward.XP)
		--Player.PlayerData.TeamXP.Value += CurrentActiveQuests[Quest].Reward.XP
		--Player.PlayerData.Tix.Value += CurrentActiveQuests[Quest].Reward.Tix
	end
end

function Network:AssignQuests()
	PlayerProgress = {}
	
	for _,Network in next, ActiveQuests do 
		for _,OldQuest in next, Network do 
			OldQuest.Maid:DoCleaning()
			if OldQuest.CleanupZone then
				OldQuest.CleanupZone()
			end
		end
	end
	
	for Network in next, QuestNetworks do 
		local QuestDir = script.Parent.Quests:FindFirstChild(Network)
		local QuestModules = QuestDir:GetDescendants()
		
		local ChosenQuests = {}
		local QuestAmounts = 0
		local MaxQuests = math.clamp(#QuestModules, 1,3)
		
		while QuestAmounts ~= MaxQuests do 
			task.wait()
			local RandomIndex = math.random(1, #QuestModules)
			local Module = QuestModules[RandomIndex]
			
			if not ChosenQuests[Module.Name] then
				local ActivatedModule =  require(Module)
				ChosenQuests[Module.Name] = ActivatedModule
				QuestAmounts += 1

				if ActivatedModule.Method then
					ActivatedModule.Method()
				end		
			end
		end
		
		ActiveQuests[Network] = ChosenQuests
	end 
end

return Network
