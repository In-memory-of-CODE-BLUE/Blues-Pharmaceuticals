ENT.Type = "anim"
ENT.Base = "bp_base"

ENT.PrintName = "Beaker"
ENT.Spawnable = true
ENT.Category = "Blue's Pharmaceuticals"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.States = {
	CREATING = 1,
	WAITING_FOR_MIX_AND_BURN = 2,
	MIXING_AND_BURNING = 3,
	WAITING_FOR_FREEZING = 4,
	FREEZING = 5,
	READY_TO_PRESS = 6,
	RUINED = 7
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "LiquidAmount")
	self:NetworkVar("Int", 1, "BeakerState")
	self:NetworkVar("Int", 2, "Recipe")
	self:NetworkVar("Int", 3, "StirAngle")
	self:NetworkVar("Float", 0, "FreezeStartTime")
	self:NetworkVar("Float", 1, "FreezeTime")
	self:NetworkVar("Entity", 0, "owning_ent")
end