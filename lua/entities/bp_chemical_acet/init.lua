AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/blues_pharm/jar_4.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
	end

	self:SetUseType(SIMPLE_USE)

	--Stores the next CurTime that they can reset angles to prevent spam
	self.angleResetCooldown = 0

	--Allow destuction
	self:SetHealth(25)

	--Set liquid anount (ml)
	self:SetLiquidAmount(1500)

	--Stores who currently has this jar selected
	self.playerWhoSelected = nil

	self:SetSubMaterial(0, "blues_pharm/jar_4_plastic_acet")
	self:SetSubMaterial(2, "blues_pharm/jar_4_label_acet")

	self:SetAngles(self:GetAngles() + Angle(0,50,0))
end	


function ENT:Use(act, caller)
	--Shift + E = Upright
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y + 180 + 50,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	elseif self.playerWhoSelected == nil and caller.BPSelectedChemical == nil then
		--Select this
		BLUES_PHARMA:SetSelectedChemical(self, caller)
	end
end

function ENT:OnRemove()
	if self.playerWhoSelected then
		self.playerWhoSelected.BPSelectedChemical = nil
	end
end