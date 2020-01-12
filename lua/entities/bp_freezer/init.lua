AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/blues_pharm/freezer.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
		physics:SetMass(114)
	end

	self:SetHealth(300)
	self.angleResetCooldown = 0
	self:SetUseType(SIMPLE_USE)

	--A table of positions relative to the entity
	self.beakersPositions = {}

	--A list of beakers stored in the freezer
	self.beakers = {}

	--Calculate the beaker positions
	local startX = 5
	local startY = 13.7

	for y = 1, 3 do
		table.insert(self.beakersPositions, Vector(-1, startX, startY + ((y-1) * 12)))
		table.insert(self.beakersPositions, Vector(-1, -startX, startY + ((y-1) * 12)))
	end
end	

--Adds a beaker to the freezer
function ENT:AddBeaker(beaker, slot)
	local pos = self:LocalToWorld(self.beakersPositions[slot])

	--Set up physics
	beaker:SetMoveType(MOVETYPE_NONE)
	beaker:SetPos(pos)
	beaker:SetAngles(self:GetAngles())
	beaker:SetParent(self)

	beaker:SetBeakerState(beaker.States.FREEZING)

	local recipe = BLUES_PHARMA.Medicines[beaker.recipe]

	--Set up freezing timers
	beaker:SetFreezeStartTime(CurTime())
	beaker:SetFreezeTime(recipe.freezeTime)

	self.beakers[slot] = beaker
end

--Removes this beaker from the freezer and changes it's state ready for the next stage
function ENT:EjectBeaker(beaker)
	table.RemoveByValue(self.beakers, beaker)

	--Update beaker state
	beaker:SetBeakerState(beaker.States.READY_TO_PRESS)

	--Set up physics
	beaker:SetParent()
	beaker:SetMoveType(MOVETYPE_VPHYSICS)
	beaker:PhysicsInit(SOLID_VPHYSICS)

	local pos = beaker:GetAngles():Forward()
	pos.z = 0
	pos:Normalize()

	beaker:SetPos(beaker:GetPos() + (pos * 25))
	beaker:GetPhysicsObject():Wake()

	--Update the texture to the frozen one
	net.Start("BLUES_PHARMA_UPDATE_MAT")
	net.WriteBool(true)
	net.WriteEntity(beaker)
	net.Broadcast()
end

function ENT:StartTouch(e)
	if e:GetClass() == "bp_beaker" and e:GetBeakerState() == e.States.WAITING_FOR_FREEZING then
		--Check there is a space
		local count = table.Count(self.beakers)

		--No room
		if count >= 6 then return end

		--Place it somehwere between 1 and 6.
		local empty = {}
		for i = 1, 6 do
			if self.beakers[i] == nil then
				empty[#empty + 1] = i
			end
		end

		--Get a random slot
		local slot = table.Random(empty)

		self:AddBeaker(e, slot)
	end
end

function ENT:Use(act, caller)
	--Shift + E = Upright
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y + 180,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	elseif self.playerWhoSelected == nil then
		--When they use this, check to see if they are looking at any beakers inside this freeze
		--If so then eject that beaker if its ready.
		local tr = util.TraceLine( {
			start = caller:EyePos(),
			endpos = caller:EyePos() + caller:EyeAngles():Forward() * 1000,
			filter = {self, caller} --Filter the freezer out
		} )

		if IsValid(tr.Entity) and tr.Entity:GetClass() == "bp_beaker" then
			--Make sure this is a beaker in the freezer and not outside
			if not table.HasValue(self.beakers, tr.Entity) then
				return
			end

			local beaker = tr.Entity

			--Check if the beaker is frozen
			if CurTime() - (beaker:GetFreezeStartTime() + beaker:GetFreezeTime()) > 0 then

				--last thing to check is that the door is open, do this by doing the same calc as the client
				local playerPos = (caller:GetPos() - self:GetPos()):GetNormalized()
				local ourPos = self:GetAngles():Forward()
				local dot = playerPos:Dot(ourPos)
				
				if dot > 0.7 then
					self:EjectBeaker(beaker)
				end
			end
		end
	end
end