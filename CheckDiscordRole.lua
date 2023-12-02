-- If you are verified with Bloxlink, it is possible to check if you have a role in a "guild" (server) if you inputed your Discord ID. From there we could check if the Discord ID was really yours.
-- This was made a long time ago, when bloxlink's api was in V1, so it doesn't work anymore. Also, the new Bloxlink API now allows you to do the same thing seamlessly: you can cast someone's Roblox ID into a Discord ID and do the same thing without any player input
-- https://www.youtube.com/watch?v=GRZaAtb_N14

local http = game:GetService("HttpService")

local guildId = "" -- String
local BoosterRoleId = "" -- String 

--Metatables
local BoostMetatables = {}
BoostMetatables.__index = BoostMetatables

function BoostMetatables:IsBooster(BotToken)
	local DiscordRequest = http:RequestAsync( --We send an HTTP request to discord
		{
			Url = "https://discord.com/api/v9/guilds/"..guildId.."/members/"..self.Id,
			Method = "GET",
			Headers = {
				["Authorization"] = "Bot "..BotToken --Auth header with bot token should start with "Bot"
			}
		}
	)
	local DiscordBody = http:JSONDecode(DiscordRequest.Body)
	
	for _,ResponseBody in pairs(DiscordBody) do 
		if type(ResponseBody) == "table" then --We search for arrays since one of them is the roles of an user
			if table.find(ResponseBody, BoosterRoleId) then
				return true --We found the booster role
			end
		end
	end
end

local Boost = {}
Boost.__index = Boost

function Boost.GetUserData(id: string, player: Player)
	local response = http:RequestAsync({
		Url = "https://api.blox.link/v1/user/".. id,
		Method = "GET"
	})
	
	local Body = http:JSONDecode(response.Body)
	for _,arrayItem in pairs(Body) do
		if arrayItem == tostring(player.UserId) then
			
			local NewDiscordUser = {}
			setmetatable(NewDiscordUser, BoostMetatables)
			
			NewDiscordUser.Id = id
			return NewDiscordUser
		end
	end
end
return Boost
