ENT.Type = "anim"
ENT.Base = "bp_base"

ENT.PrintName = "2-Napththol"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.ChemicalID = 6


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "LiquidAmount")
end