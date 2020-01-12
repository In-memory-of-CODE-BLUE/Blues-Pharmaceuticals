AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/blues_pharm/bunsen_burner.mdl")

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

	self.mixTimer = 0

	self.stirCooldown = 0

	--Allow destuction
	self:SetHealth(100)

	self:SetAngles(self:GetAngles() + Angle(0,180,0))

	self:SetTrigger(true)
end	

function ENT:StartTouch(e)
	if self.attachedBeaker == nil and e:GetClass() == "bp_beaker" and e:GetBeakerState() == e.States.WAITING_FOR_MIX_AND_BURN then
		self.attachedBeaker = e
		e.attachedBurner = self
		e:SetMoveType(MOVETYPE_NONE)
		e:SetPos(self:GetPos() + (self:GetAngles():Up() * 16.2))
		e:SetAngles(self:GetAngles())
		e:SetParent(self)

		self:SetConnectedBeaker(e)
		self.recipeTable = BLUES_PHARMA.Medicines[e.recipe]

		--Set up timing
		self:SetBurnStartTime(CurTime())
		self:SetBurnCookTime(self.recipeTable.cookTime)
		self.endTime = CurTime() + self.recipeTable.cookTime

		--Update the state
		e:SetBeakerState(e.States.MIXING_AND_BURNING)

		e:EmitSound("bp_boiling")

		--Reset amount
		self:SetMixAmount(0)
		e:SetStirAngle(0)
	end
end

--Tries to detach the beaker from the burner
function ENT:EjectBeaker()
	if IsValid(self.attachedBeaker) then
		local b = self.attachedBeaker
		b:SetParent()
		b:SetMoveType(MOVETYPE_VPHYSICS)
		b:PhysicsInit(SOLID_VPHYSICS)

		local pos = self:GetAngles():Forward()
		pos.z = 0
		pos:Normalize()

		b:SetPos(self:GetPos() + (pos * -15))
		b:GetPhysicsObject():Wake()

		--Ejected
		b:StopSound("bp_boiling")
		self.attachedBeaker = nil

		self:SetConnectedBeaker(nil)
		self:SetMixAmount(0)
	end
end

function ENT:Think()
	if IsValid(self.attachedBeaker) and self.mixTimer < CurTime() then
		self.mixTimer = CurTime() + 0.35
		self:SetMixAmount(math.Clamp(self:GetMixAmount() + (self.recipeTable.mixIncrement / 1000), 0, 1))

		if self:GetMixAmount() >= 1 then
			local b = self.attachedBeaker
			self:EjectBeaker()
			b:BurnLiquid()
			return
		end

		--We are done, eject the beaker
		if CurTime() >= self.endTime then 
			self.attachedBeaker:SetBeakerState(self.attachedBeaker.States.WAITING_FOR_FREEZING)
			self:EjectBeaker()
		end
	end
end

function ENT:Use(act, caller)

	--Shift + E = Upright
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	else
		if self.stirCooldown < CurTime() and IsValid(self.attachedBeaker) then
			self.stirCooldown = CurTime() + 0.5
			self:SetMixAmount(math.Clamp(self:GetMixAmount() - 0.10, 0, 1))
			self.attachedBeaker:SetStirAngle(self.attachedBeaker:GetStirAngle() + 243)
		end
	end
end

function ENT:OnRemove()
	if IsValid(self.attachedBeaker) then
		self.attachedBeaker:StopSound("bp_boiling")
	end
end