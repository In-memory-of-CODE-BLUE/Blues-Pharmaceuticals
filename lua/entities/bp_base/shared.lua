ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "bp_base"
ENT.Spawnable = false
ENT.Category = "Blue's Pharmaceuticals"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 1, "owning_ent")
end