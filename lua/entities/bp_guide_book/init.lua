AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/blues_pharm/book.mdl")

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
end	

function ENT:Use(act, caller)
	--Shift + E = Upright
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y + 180,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	else
		net.Start("BLUES_PHARMA_OPEN_BOOK")
		net.Send(caller)
	end
end