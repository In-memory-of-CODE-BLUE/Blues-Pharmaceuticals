ENT.Type = "anim"
ENT.Base = "bp_base"

ENT.PrintName = "Keto Acid"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.ChemicalID = 1


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "LiquidAmount")
end