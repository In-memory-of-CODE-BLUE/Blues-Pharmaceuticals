ENT.Type = "anim"
ENT.Base = "bp_base"

ENT.PrintName = "Pill Bottle"
ENT.Spawnable = false
ENT.Category = "Blue's Pharmaceuticals"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "RecipeID")
	self:NetworkVar("Int", 1, "UsesLeft")
end