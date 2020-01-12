include("shared.lua")

function ENT:Initialize()
	-- 0-1 of animation
	self.animationProgress = 0
	self.currentAngle = 0
	self.animating = false
	self.lerpedPercent = 0

	self.csModel = ClientsideModel("models/blues_pharm/pill_bottle.mdl")
	self.csModel:SetNoDraw(true)

	self.pillCSModel = ClientsideModel("models/blues_pharm/pill.mdl")
	self.pillCSModel:SetColor(Color(255,120,50))
	self.pillCSModel:SetNoDraw(true)
end 


--2 = WHEEL
function ENT:SetAnimationAng(ang)
	self:ManipulateBoneAngles(2, Angle(-ang,0,0))

	self:ManipulateBonePosition(1, LerpVector((math.sin(math.rad(ang - 90))+ 1) / 2,Vector(0,0,0), Vector(0,0,-7.9)))
	--self:ManipulateBoneAngles(3, Angle(ang,0,0))
end

function ENT:Think()
	--When changing settings
	if not IsValid(self.csModel) then
		self.csModel = ClientsideModel("models/blues_pharm/pill_bottle.mdl")
		self.pillCSModel = ClientsideModel("models/blues_pharm/pill.mdl")
	end

	if self.currentAngle < (self:GetAnimationAngle() * 360) then
		self.animationProgress = (self.currentAngle % 360) / 360
		self.currentAngle = math.Clamp(self.currentAngle + ( 200 * FrameTime()), 0, self:GetAnimationAngle() * 360)
		self:SetAnimationAng(self.currentAngle)
	else
		self.animationProgress = 0
	end
end
 
function ENT:Draw()
	self:DrawModel()
	--self:SetAnimationAng(CurTime() * 100)

	if self:GetRecipeID() >= 0 then
		
		local ang = self:GetAngles()
		local pos = self:GetPos() + (ang:Up() * 38) + (ang:Forward() * -15.8)
		
		self.csModel:SetPos(self:GetPos() + (ang:Forward() * 6) + (ang:Right() * 6) + (ang:Up() * 3.2))
		self.csModel:SetAngles(ang)
		self.csModel:DrawModel()


		local vec1 = self:GetPos() + (ang:Up() * 3) + (ang:Forward() * -0.1) + (ang:Up() * -0.1)
		local vec2 = self:LocalToWorld(Vector(6, -6, 10))
		local vec3 = BLUES_PHARMA:CalcCubicSpline(vec1, LerpVector(0.5, vec1, vec2) + (ang:Up() * 10), vec2, math.Clamp((self.animationProgress-0.75) * 4, 0, 1))

		self.pillCSModel:SetPos(vec3)
		self.pillCSModel:SetAngles(ang + Angle(-90,0,0))

		if self.animationProgress > 0.5 then
			self.pillCSModel:DrawModel()
		end

		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 90)

		--Get the dot of the player, don't render if there behind
		local playerPos = LocalPlayer():GetPos() - self:GetPos()
		local ourPos = self:GetAngles():Forward()
		local dot = playerPos:Dot(ourPos:GetNormalized())

		if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > BLUES_PHARMA.CONFIG.Cam3D2DRenderDist  then return end

		if dot > -13.6 then
			--Backdrop
			cam.Start3D2D(pos, ang, 0.03)
				draw.RoundedBox(0, -280, 0, 60, 1180, Color(43, 43, 43))
				draw.RoundedBox(0, 280 - 60, 0, 60, 1180, Color(43, 43, 43))	

				draw.RoundedBoxEx(32, -280, -100, 560, 200, Color(43, 43, 43), true, true, false, false)

				draw.SimpleText(BLUES_PHARMA.Medicines[self:GetRecipeID()].name, "BP_Chemical_UI_Name3",  0, -100, Color(255, 255, 255), 1, 0)
				draw.SimpleText("Press 'E' to press pills", "BP_Chemical_UI_Name",  0, -25, Color(255, 255, 255, 25), 1, 0)

				draw.RoundedBox(0, -220, 30, 440, 50, Color(255,255,255, 10))
				draw.RoundedBox(0, -220 + 4, 30 + 4, 440 - 8, 50 - 8, Color(20,20,20))

				self.lerpedPercent = Lerp(5 * FrameTime(), self.lerpedPercent, self:GetPressedAmount() / 100)
				local color = BLUES_PHARMA:LerpColor(Color(255,50,30, 80), Color(50,205,50, 80), self.lerpedPercent)

				draw.RoundedBox(0, -220 + 4, 30 + 4, (440 - 8) * self.lerpedPercent, 50 - 8, color)
			cam.End3D2D()
		end	
	end
end

function ENT:OnRemove()
	self.csModel:Remove()
	self.pillCSModel:Remove()
end