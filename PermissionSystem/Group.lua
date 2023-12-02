return function(player:Player, args)

	local groupId = require(game:GetService("ReplicatedStorage").SharedDictionnaries.AbbreviationToGroup)[args[1]]
	
	if args then
		if player:IsInGroup(tonumber(groupId)) then
			if args[2] then
				if player:GetRankInGroup(tonumber(groupId)) >= tonumber(args[2]) then
					return true
				else
					return false
				end
			else
				return true
			end
		else
			return false
		end
	else
		print("Permission group takes one mandatory argument (Group Abbreviation)")
		return false
	end
end