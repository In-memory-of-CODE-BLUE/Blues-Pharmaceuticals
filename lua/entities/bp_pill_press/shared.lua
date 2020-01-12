ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Pill Press"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "RecipeID")
	self:NetworkVar("Float", 1, "PressedAmount")
	self:NetworkVar("Int", 1, "AnimationAngle")
	self:NetworkVar("Entity", 1, "owning_ent")
end