ENT.Type = "anim"
ENT.Base = "bp_base"

ENT.PrintName = "Propionic Acid"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.ChemicalID = 3


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "LiquidAmount")
end