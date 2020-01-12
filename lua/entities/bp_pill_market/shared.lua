ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Pill Market"
ENT.Author = "<CODE BLUE>"
ENT.Contact = "Via Steam"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetAutomaticFrameAdvance( anim )
	self.AutomaticFrameAdvance = anim
end 