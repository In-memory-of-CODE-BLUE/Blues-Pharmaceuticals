AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/blues_pharm/pill_presser.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
	end
	
	self:SetHealth(150)

	--Stores the next CurTime that they can reset angles to prevent spam
	self.angleResetCooldown = 0
	self.pressCooldown = 0

	self:SetTrigger(true)

	self:SetRecipeID(-1)
	self:SetPressedAmount(0)
end	

function ENT:StartTouch(e)
	--No recipe
	if e:GetClass() == "bp_beaker" and self:GetRecipeID() < 0 then
		local beaker = e
		local beakerRecipe = beaker.recipe
		--We are ready to press
		if beaker:GetBeakerState() == beaker.States.READY_TO_PRESS then
			--Empty the liquid out of the beaker, reset its state
			beaker:ResetBeaker()
			self:SetRecipeID(beakerRecipe)
			self:SetPressedAmount(0)
		end
	end
end

function ENT:Use(act, caller)
	--Shift + E = Upright
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y + 180,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	else
		if self:GetRecipeID() >= 0 then
			if CurTime() >= self.pressCooldown then
				self.pressCooldown = CurTime() + 1.8
				self:SetPressedAmount(math.Clamp(self:GetPressedAmount() + 5, 0, 100))
				self:SetAnimationAngle(self:GetAnimationAngle() + 1)

				if self:GetPressedAmount() >= 100 then
					local ang = self:GetAngles()

					--We are done pressing
					local pillBottle = ents.Create("bp_pill_bottle")
					pillBottle:SetPos(self:GetPos() + (ang:Forward() * 6) + (ang:Right() * 6) + (ang:Up() * 3.6))
					pillBottle:SetAngles(self:GetAngles())
					pillBottle:Spawn()
					pillBottle:SetRecipeID(self:GetRecipeID())
					pillBottle:SetUsesLeft(5)

					self:SetRecipeID(-1)
					self:SetPressedAmount(0)
				end
			end
		end
	end
end