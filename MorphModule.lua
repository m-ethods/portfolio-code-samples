-- An now obsolete morph module that uses metatables and allows you to have many useful functions, such as only morphing specific body parts or even removing morphs from specific body parts.

-- // FileName: MorphModule
-- // Written by: Liyud "liyuudd"
-- // Functions regarding the morph system using a metatable

local Morph = {}
Morph.__index = Morph

function Morph.New(Player, MorphName)
	
	if shared.Morph[Player.Name] then
		shared.Morph[Player.Name]:UnequipMorph()
	end
	
	local newMorph = {}
	setmetatable(newMorph, Morph)
	
	newMorph.Player = Player
	newMorph.MorphName = MorphName
	newMorph.MorphItems = {}
	
	local SelectedMorph = game.ServerStorage.Morphs:FindFirstChild(MorphName):Clone()
	
	if SelectedMorph:FindFirstChild("Head") then
		for _,v in pairs(Player.Character:GetChildren()) do
			if v:IsA("Accessory") then
				v:Destroy()
			end
		end
	end
	
	for _,v in pairs(SelectedMorph:GetChildren()) do
		if v:IsA("Model") then
			v.Parent = Player.Character
			newMorph.MorphItems[v.Name] = {}
			for _,morphPart in pairs(v:GetChildren()) do
				if morphPart:IsA("BasePart") then 
					local weld = Instance.new("Motor6D", morphPart)	
					weld.Part0 = v.Middle
					weld.Part1 = morphPart

					local CJ = CFrame.new(v.Middle.Position)
					weld.C0 = v.Middle.CFrame:inverse() * CJ
					weld.C1 = morphPart.CFrame:inverse() * CJ

					weld.Parent = v.Middle
					table.insert(newMorph.MorphItems[v.Name], morphPart)
				end
			end
			local FinalWeld = Instance.new("Motor6D")
			FinalWeld.Part0 = Player.Character:FindFirstChild(v.Name)
			FinalWeld.Part1 = v.Middle
			FinalWeld.C0 = CFrame.new(0,0,0)
			FinalWeld.Parent = FinalWeld.Part0
			v.Middle.CFrame = CFrame.new(Player.Character:FindFirstChild(v.Name).Position,Player.Character:FindFirstChild(v.Name).Position)
		end
	end
	
	if SelectedMorph:FindFirstChild("Shirt") then
		if Player.Character:FindFirstChildWhichIsA("Shirt") then
			Player.Character:FindFirstChildWhichIsA("Shirt"):Destroy()
			SelectedMorph:FindFirstChild("Shirt").Parent = Player.Character
		end
	end
	
	if SelectedMorph:FindFirstChild("Pants") then
		if Player.Character:FindFirstChildWhichIsA("Pants") then
			Player.Character:FindFirstChildWhichIsA("Pants"):Destroy()
			SelectedMorph:FindFirstChild("Pants").Parent = Player.Character
		end
	end
	
	SelectedMorph:Destroy()
	
	shared.Morph[Player.Name] = newMorph
	return newMorph
end

function Morph:MorphBodyPart(BodyPart, Morph)
	local body = self.Player.Character:FindFirstChild(BodyPart)
	local selectedMorphPart = game.ServerStorage.Morphs:FindFirstChild(Morph)
	:FindFirstChild(BodyPart)
	:Clone()
	selectedMorphPart.Parent = self.Player.Character
	for _,morphPart in pairs(selectedMorphPart:GetChildren()) do
		if morphPart:IsA("BasePart") then 
			local weld = Instance.new("Motor6D", morphPart)	
			weld.Part0 = selectedMorphPart.Middle
			weld.Part1 = morphPart

			local CJ = CFrame.new(selectedMorphPart.Middle.Position)
			weld.C0 = selectedMorphPart.Middle.CFrame:inverse() * CJ
			weld.C1 = morphPart.CFrame:inverse() * CJ

			weld.Parent = selectedMorphPart.Middle
			table.insert(self.MorphItems[selectedMorphPart.Name], morphPart)
		end
	end
	local FinalWeld = Instance.new("Motor6D")
	FinalWeld.Part0 = self.Player.Character:FindFirstChild(selectedMorphPart.Name)
	FinalWeld.Part1 = selectedMorphPart.Middle
	local MorphPartOrientation = self.Player.Character:FindFirstChild(selectedMorphPart.Name).Orientation
	FinalWeld.C0 = CFrame.new(0,0,0)
	FinalWeld.Parent = FinalWeld.Part0
	selectedMorphPart.Middle.CFrame = self.Player.Character:FindFirstChild(BodyPart).CFrame
end

function Morph:UnequipMorphBodyPart(BodyPart)
	for _,v in pairs(self.Player.Character:GetChildren()) do
		if v:IsA("Model") and v.Name == BodyPart then
			v:Destroy()
		end
	end
end

function Morph:UnequipMorph()
	for _,v in pairs(self.MorphItems) do
		for _,item in pairs(v) do
			item:Destroy()
		end
	end
	shared.Morph[self.Player.Name] = {}
	self = {}
end

return Morph
