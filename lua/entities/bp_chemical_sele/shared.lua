ENT.Type = "anim"
ENT.Base = "bp_base"

ENT.PrintName = "Selenium Dioxide"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.ChemicalID = 5


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "LiquidAmount")
end