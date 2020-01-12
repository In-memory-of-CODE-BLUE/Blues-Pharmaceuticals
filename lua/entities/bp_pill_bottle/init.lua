AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/blues_pharm/pill_bottle.mdl")

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
	self:SetHealth(50)
end	

function ENT:Use(act, caller)
	--Shift + E = Upright
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y + 180,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	else
		if not BLUES_PHARMA.CONFIG.CanConsumePills  then return end
		self:SetUsesLeft(self:GetUsesLeft() - 1)

		--Call use func
		local useFunc = BLUES_PHARMA.Medicines[self:GetRecipeID()].onConsumed
		useFunc(BLUES_PHARMA.Medicines[self:GetRecipeID()], caller)

		caller:BPAddOverdose(BLUES_PHARMA.Medicines[self:GetRecipeID()].overdoseRate)

		if self:GetUsesLeft() <= 0 then
			self:Remove()
		end
	end
end