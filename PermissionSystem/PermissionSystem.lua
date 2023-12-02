-- This is a pretty complex permission system but I will try to break it down.
-- This system makes it so if you call a function with a permission argument and a player, you can check if a player respects the permission argument.
-- For example, let's say I want to make a door that opens if you have the rank 5 or higher in a group that has an ID of 88. We can call PermissionsService.HasPermissions(player, {"Group:88:5"})
-- The module should return "true" if you scripted correctly the "Group" module.
-- The group module is displayed in the same folder this script is parented to.

--------------
--m_ethodss 
--20/4/2022
--------------

--------------
--|Dependencies
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------
--|Module
--------------
local PermissionsService = {}

--------------
--|Functions
--------------

-- Private

function checkPermissionString(player, permissionTable)
	local splitPerms = string.split(permissionTable, ":")
	local permissiontype = splitPerms[1]

	local permissionarg = splitPerms
	table.remove(permissionarg, 1)

	local permissionmodule = require(script:FindFirstChild(permissiontype))
	if permissionmodule(player, permissionarg) then
		return true
	elseif permissionTable.RequireAll then
		return false
	end
end

function checkPermissionTable(player, permissionTable)
	for _,permission in next, permissionTable do
		if typeof(permission) == "string" then
			local splitPerms = string.split(permission, ":")
			local permissiontype = splitPerms[1]

			local permissionarg = splitPerms
			table.remove(permissionarg, 1)

			local permissionmodule = require(script:FindFirstChild(permissiontype))
			if permissionmodule(player, permissionarg) then
				return true
			elseif permissionTable.RequireAll then
				return false
			end
		end
	end
end

-- Public
function PermissionsService.HasPermissions(player, permissionTable)
	for _,permission in next, permissionTable do
		if typeof(permission) == "string" then
			local splitPerms = string.split(permission, ":")
			local permissiontype = splitPerms[1]
			
			if permissiontype == "PermissionsGroup" then
				local group = splitPerms[2]
				local permissiongroup = require(script.PermissionsGroup)
				local PermissionsGroupTable = permissiongroup[group]
				
				for _,perm in next, permissiongroup do
					if typeof(perm) == "string" then
						local result = checkPermissionString(player, perm)

						if result then
							return true
						end
					end
					
					if type(perm) == "table" then
						local result = checkPermissionTable(player, perm)

						if result then
							return true
						elseif perm.RequireAll then
							return false
						end
					end
				end
				continue
			end
			
			local result = checkPermissionString(player, permission)
			if result then
				return true
			end
		end
		
		if typeof(permission) == "table" then
			local result = checkPermissionTable(player, permission)
			if result then
				return true
			elseif permission.RequireAll then
				return false
			end
		end
	end
	return false
end


return PermissionsService