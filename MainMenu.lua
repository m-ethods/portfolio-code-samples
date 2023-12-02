-- Simple main menu script that uses a Maid for optimization.
-- Also sets a random images as a background.

local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Teams = require(game.ReplicatedStorage.SharedDictionnaries.Teams)
local Maid = require(game.ReplicatedStorage.SharedModules.Maid).new()
local PermissionService = require(game.ReplicatedStorage.SharedModules.PermissionsService)

-- Events / Functions
local SwitchTeam = ReplicatedStorage.Functions.Menu.SwitchTeam

module.Images = {
	"rbxassetid://13775237028",
	"rbxassetid://13775236687",
	"rbxassetid://13775236448",
	"rbxassetid://13775236244"
}

function module.LaunchMenu()
	Maid:DoCleaning()
	
	game.Lighting.MenuBlur.Enabled = true
	local RandomImage = module.Images[math.random(1, #module.Images)]
	
	Player.PlayerGui:WaitForChild("MainMenu"):WaitForChild("Background").Image = RandomImage
	Player.PlayerGui:WaitForChild("MainMenu"):WaitForChild("Background").Visible = true
	
	local Permissions = {}
	
	for _,Team in next, require(game.ReplicatedStorage.SharedDictionnaries.Teams) do
		Permissions[Team.Name] = PermissionService.HasPermissions(Player, Team.PermissionArgs)
	end
	
	Player.PlayerGui:WaitForChild("MainMenu"):WaitForChild("Main").Visible = true
	--Player.PlayerGui.MainMenu:WaitForChild("Music"):Play()
	
	Maid:GiveTask(Player.PlayerGui.MainMenu.Main.Buttons.Universe.Button.MouseButton1Up:Connect(function()
		Maid:DoCleaning()
		
		Player.PlayerGui.MainMenu.Teams.Visible = true
		Player.PlayerGui.MainMenu.Main.Visible = false
		
		for _,Frame in next,Player.PlayerGui.MainMenu.Teams.Teams:GetChildren() do
			if Frame:IsA("Frame") and Frame.Name ~= "Sample" then
				Frame:Destroy()
			end
		end
		
		for TeamName,Permission in next,Permissions do 
			if Permission then
				local Frame = Player.PlayerGui.MainMenu.Teams.Teams.Sample:Clone()
				Frame.Parent = Player.PlayerGui.MainMenu.Teams.Teams
				Frame.Name = TeamName
				Frame.TextLabel.Text = string.upper(TeamName)
				
				local TeamTable = Teams[TeamName]
				Frame.UIGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(1, TeamTable.Detail.Color)}
					
				Frame.Visible = true
				
				Maid:GiveTask(Frame.Button.MouseButton1Up:Connect(function()
					Player.PlayerGui.MainMenu.Teams.TeamError.Visible = false
					if SwitchTeam:InvokeServer(TeamName) then
						Maid:DoCleaning()
						game.Lighting.MenuBlur.Enabled = false
						Player.PlayerGui.MainMenu.Teams.Visible = false
						Player.PlayerGui.MainMenu.Background.Visible = false
						
						local lastXpress = 0
						Maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObject, processed)
							if inputObject.KeyCode == Enum.KeyCode.X and not processed then
								if tick() - lastXpress <= .5 then
									module.LaunchMenu()
								end
								lastXpress = tick()
							end
						end))
					else
						task.wait(.5)
						Player.PlayerGui.MainMenu.Teams.TeamError.Text = "Couldn't get teamed to : " .. TeamName
						Player.PlayerGui.MainMenu.Teams.TeamError.Visible = true
					end
				end))
			end
		end
	end))
end


return module
