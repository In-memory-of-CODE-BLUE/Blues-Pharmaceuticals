include("shared.lua")

function ENT:Initialize()
	self.csModel = ClientsideModel("models/blues_pharm/freezer_door.mdl", RENDERGROUP_VIEWMODEL_TRANSLUCENT)

	self.isOpen = false
	self.previousOpenState = false
	self.animationTime = 0
	self.soundCooldown = 0
end

--Sets the rotation of the stirrer
function ENT:SetDoorRotation()
	self:ManipulateBoneAngles(1, Angle(ang,0,0))
end

--Handle sounds

function ENT:Think()
	--When changing settings
	if not IsValid(self.csModel) then
		self.csModel = ClientsideModel("models/blues_pharm/freezer_door.mdl", RENDERGROUP_VIEWMODEL_TRANSLUCENT)
	end

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 90)

	if self.playerClose then 
		if self.animationTime < 1 then
			self.animationTime = math.Clamp(self.animationTime + (FrameTime() * 1), 0, 1)
		end
		ang:RotateAroundAxis(ang:Forward(), BLUES_PHARMA:Berp(self.animationTime, 0, 110))
		self.isOpen = true
	else
		if self.animationTime > 0 then
			self.animationTime = math.Clamp(self.animationTime - (FrameTime() * 2), 0, 1)
		end
		ang:RotateAroundAxis(ang:Forward(), BLUES_PHARMA:Sinerp(self.animationTime, 0, 110))
		self.isOpen = false
	end

	self.csModel:SetPos(self:GetBonePosition(2))
	self.csModel:SetAngles(LerpAngle(30 * FrameTime(),self.csModel:GetAngles(), ang))

	if self.previousOpenState ~= self.isOpen then
		if self.isOpen then
			--Play open sounds
			if CurTime() > self.soundCooldown then
				self.soundCooldown = CurTime() + 0.3
				self:EmitSound("blues_pharm/freezer_open.wav", 75, math.random(90, 110), 0.5)
			end

			self.previousOpenState = self.isOpen
		else
			--Play close sound
			if self.animationTime < 0.1 then
				self:EmitSound("blues_pharm/freezer_close.wav", 75, math.random(99, 101), 0.5)
				self.previousOpenState = self.isOpen
			end
		end
	end
end

function ENT:Draw()
	self:DrawModel()
 
	local playerClose = false
	for k, v in pairs(player.GetAll()) do
		if v:GetPos():DistToSqr(self:GetPos()) < 15000 then
			--Get the dot of the player, don't open if there behind
			local playerPos = (v:GetPos() - self:GetPos()):GetNormalized()
			local ourPos = self:GetAngles():Forward()
			local dot = playerPos:Dot(ourPos:GetNormalized())
			
			if dot > 0.7 then
				playerClose = true
				break
			end
		end
	end
	self.playerClose = playerClose
end  

--Free up the pooled material and remove from render list
function ENT:OnRemove()
	self.csModel:Remove()
end