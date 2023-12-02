-- This is the serverside script for an elevator service.
-- For every function in ElevatorFunctions, a RemoteFunction is created for the client to call said function.
-- Elevators also use physics: the PrismaticConstraint.

local ElevatorFunctions = {
	Call = function(Player, Model, Floor)
		if not Model.Configuration.inMotion.Value then
			if Model.Configuration.CurrentFloor.Value == Floor then
				return false,"currentFloor"
			end
			
			Model.Configuration.inMotion.Value = true
			
			local TargetFloor = Model.Configuration:FindFirstChild(tostring(Floor)).Value.Value
			Model.Shaft.PrismaticConstraint.TargetPosition = TargetFloor
			
			repeat task.wait() until math.floor(Model.Shaft.PrismaticConstraint.CurrentPosition) == math.floor(Model.Shaft.PrismaticConstraint.TargetPosition)
			
			Model.Configuration.CurrentFloor.Value = tonumber(Floor)
			Model.Configuration.inMotion.Value = false
			
			return true
		else return false,"motion" end
	end,

	Goto = function(Player, Model, Floor)
		if not Model.Configuration.inMotion.Value then
			if Model.Configuration.CurrentFloor.Value == Floor then
				return false,"currentFloor"
			end
			
			Model.Configuration.inMotion.Value = true

			local TargetFloor = Model.Configuration:FindFirstChild(tostring(Floor)).Value.Value
			Model.Shaft.PrismaticConstraint.TargetPosition = TargetFloor

			repeat task.wait() until math.floor(Model.Shaft.PrismaticConstraint.CurrentPosition) == math.floor(Model.Shaft.PrismaticConstraint.TargetPosition)

			Model.Configuration.CurrentFloor.Value = tonumber(Floor)
			Model.Configuration.inMotion.Value = false

			return true
		else return false,"motion" end
	end,
}


for _,Elevator in next, workspace.Elevators.Vehicle:GetChildren() do
	local FunctionFolder = Instance.new("Folder")
	FunctionFolder.Name = Elevator.Name
	FunctionFolder.Parent = game.ReplicatedStorage.Functions.Elevators
	
	for Name,Function in next, ElevatorFunctions do 
		local ReFu = Instance.new("RemoteFunction", FunctionFolder)
		
		ReFu.Name = Name
		ReFu.OnServerInvoke = Function
	end
end
