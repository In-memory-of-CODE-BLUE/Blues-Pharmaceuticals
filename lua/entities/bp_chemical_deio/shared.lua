ENT.Type = "anim"
ENT.Base = "bp_base"

ENT.PrintName = "Deionized water"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.ChemicalID = 10


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "LiquidAmount")
end