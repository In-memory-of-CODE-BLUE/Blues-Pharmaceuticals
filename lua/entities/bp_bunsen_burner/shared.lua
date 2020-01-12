ENT.Type = "anim"
ENT.Base = "bp_base"

ENT.PrintName = "Bunsen Burner"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "ConnectedBeaker")
	self:NetworkVar("Float", 0, "BurnCookTime")
	self:NetworkVar("Float", 1, "BurnStartTime")
	self:NetworkVar("Float", 2, "MixAmount")
	self:NetworkVar("Entity", 1, "owning_ent")
end