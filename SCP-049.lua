-- Script for SCP-049, a humanoid that can pathfind to players using a custom framework and can also be neutralized with lavender.
-- https://www.youtube.com/watch?v=NNle7z-FeIY

--// Services
local Nexus = require(game:GetService("ReplicatedStorage").Nexus.NexusInit):Init()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Chat = game:GetService('Chat')
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Pathfinding = Nexus:Require('PathfindingMain')
local CoreModule = Nexus:Require('CoreModule');
local Zombie = require(script.Parent.Zombie)
local SCP_Utils = Nexus:Require('SCP_Utils')

--// Events
local Events = ReplicatedStorage.Events
local Binds = Events.Binds

--// Initiation
local SCP = {}
SCP.__index = SCP

function SCP.new(Model)
	local self = setmetatable({}, SCP)

	self.Source = Model
	self.Contained = false
	self.Lavender = false
	self.LavenderExpire = 0
	
	self.Humanoid = self.Source:WaitForChild('Humanoid')

	self.Path = nil
	self.Reached = true
	self.TrackedPlayer = nil

	self.LastScan = 0
	self.ScanPer = .25
	self.Radius = 200;
	
	self.Maid:GiveTask(script.Parent.PathfindingMain:WaitForChild('Event').Event:Connect(function(SCP, Action, Values)
		if SCP ~= self.Source then return end		

		if Action == 'Attack' then
			local Player = Values[1]

			if Player and not Player.Character:GetAttribute("Zombie") then
				if (Player.Team == game.Teams["Ethics Committee"]) or (Player.Team == game.Teams["Scientific Department"]) then return end
				if Player.Character:GetAttribute('TestedBy') then
					game.ReplicatedStorage.Events.Binds.Infected:Fire(Player)

					if Player.Character and Player.Character:FindFirstChild('Head') then
						Player.Character.Head.Nametag.Terminate.Visible = true
					end
				end

				Zombie.new(Player)
			end
		end
	end))
	
	Binds.SpraySuccess.Event:Connect(function()
		self.LavenderExpire = tick() + 7
	end)
	
	self.Source:WaitForChild('Humanoid'):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	
	for _, Part in pairs(self.Source:GetChildren()) do
		if Part:IsA("BasePart") then
			Part:SetNetworkOwner(nil)
		end
	end

	spawn(function()
		self:Scan()
		Pathfinding:AddEntity(self.Source, 200, .1, 5)
	end)
	
	Chat.BubbleChatEnabled = true
	
	return self
end

function SCP:Scan()
	RunService.Heartbeat:Connect(function(dt)
		if self.LavenderExpire > tick() then
			self.Lavender = true
			self.Source.Head.LavenderEffect.Enabled = true
			self.Source.LavenderHighlight.Enabled = true
		else
			self.Lavender = false
			self.Source.Head.LavenderEffect.Enabled = false
			self.Source.LavenderHighlight.Enabled = false
		end
		
		if tick() - self.LastScan <= self.ScanPer then return end
		self.LastScan = tick()
	end)
end

return SCP
