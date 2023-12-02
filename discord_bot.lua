-- Code for a Discord Bot able to exile/rank users in a ROBLOX group. Library used : Discordia

local function rankUser(robloxId, rank, xcsrf)
	local url = "https://groups.roblox.com/v1/groups/12530867/users/"..robloxId

	local data = {
		["roleId"] = rank
	}

	local encodedData = json.stringify(data)
	local Request, Body = http.request("PATCH", url, {{"Content-Type", "application/json"}, {"X-CSRF-TOKEN", xcsrf}, {"Cookie", ".ROBLOSECURITY="..token}}, encodedData, {token})

	if Request.reason == "Token Validation Failed" then
		local X_CSRF_TOKEN = Request[6][2] -- Request, along with some other information, returns a series of arrays with two elements, a returned header name and its associated value. Roblox returns the X-CSRF-TOKEN as the sixth value.
		rankUser(robloxId, rank, X_CSRF_TOKEN)
	end
end

local function exileUser(groupid, userid, xcsrf)
	print("'"..userid.."'")
	local url = "https://groups.roblox.com/v1/groups/".. groupid .."/users/" .. userid

	local Request, Body = http.request("DELETE", url, {{"Content-Type", "application/json"}, {"X-CSRF-TOKEN", xcsrf}, {"Cookie", ".ROBLOSECURITY="..token}}, nil, {token})

	if Request.reason == "Token Validation Failed" then
		local X_CSRF_TOKEN = Request[6][2] -- Request, along with some other information, returns a series of arrays with two elements, a returned header name and its associated value. Roblox returns the X-CSRF-TOKEN as the sixth value.
		exileUser(groupid, userid, X_CSRF_TOKEN)
	elseif Request.reason == "OK" then
		return true
	end 
end

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	if message.member:hasRole('1009847249691496518') and not message.author.bot then
		if message.content:sub(1, 6) == '.exile' then
			local arguments = split(message.content, " ")
			local userId = arguments[2]
			local group = arguments[3]
	
			if not userId then
				message:reply("<@".. message.author.id .. ">" .. ", please specify who you wish to exile.")
			elseif not group then
				message:reply("<@".. message.author.id .. ">" .. ", please specify the group you wish to exile from.")
			end
			
			if Group[group] then
				local result = exileUser(Group[group], userId) 
				local logChannel = client:getChannel("1007584182236610614")
				logChannel:send("<@" .. message.author.id .. ">" .. " used command .exile: `".. message.content .."`")
				if result then
					message:reply(result)
				end
			else
				message:reply("<@".. message.author.id .. ">" .. ", group '".. group .."' does not exist.")
			end
		end	
	end
end)

client:run('Bot '.. DiscordToken)
