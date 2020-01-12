include("shared.lua")

local flame = Material("blues_pharm/flame")
local timeLeft = Material("blues_pharm/ui/time.png", "smooth")
local mix = Material("blues_pharm/ui/mix.png", "smooth")

function ENT:Initialize()
	self.lerpedMixAmount = 0

	self:EmitSound("bp_burner")
end

function ENT:DrawFlame()
	local ang = self:GetAngles()
	local pos2 = self:GetPos() + (ang:Up() * 16.3)
	local ang1 = self:WorldToLocalAngles((LocalPlayer():EyePos() - pos2):Angle())
	local ang2 = self:LocalToWorldAngles(Angle(0, ang1.y + 90, 90))

	--Flame
	cam.Start3D2D(pos2, ang2, 0.03)
		surface.SetMaterial(flame)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(-32, -128, 64, 256)
	cam.End3D2D()
end

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	local pos = self:GetPos() + (ang:Up() * 27.7) + (ang:Forward() * 9.5)
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), -90)

	--Get the dot of the player, don't render if there behind
	local playerPos = LocalPlayer():GetPos() - self:GetPos()
	local ourPos = self:GetAngles():Forward()
	local dot = playerPos:Dot(ourPos:GetNormalized())

	if dot < 9.4 and not (self:GetPos():DistToSqr(LocalPlayer():GetPos()) > BLUES_PHARMA.CONFIG.Cam3D2DRenderDist ) then

		local beaker = self:GetConnectedBeaker()

		if IsValid(beaker) then

			local recipe = BLUES_PHARMA.Medicines[beaker:GetRecipe()]

			--Backdrop
			cam.Start3D2D(pos, ang, 0.03)
				draw.RoundedBoxEx(32, -180, -280, 370, 260, Color(43, 43, 43, 255), true, true, false, false)

				local percent = math.Clamp((CurTime() - self:GetBurnStartTime()) / self:GetBurnCookTime(), 0, 1)
				local color = BLUES_PHARMA:LerpColor(Color(255,50,30, 80), Color(50,205,50, 80), percent)

				self.lerpedMixAmount = Lerp(2 * FrameTime(), self.lerpedMixAmount, 1 - self:GetMixAmount())

				local color2 = BLUES_PHARMA:LerpColor(Color(50,205,50), Color(255,99,71), 1 - self.lerpedMixAmount)

				--Time bar
				draw.RoundedBox(0, -180, -130, 150, 880 + 128, Color(43, 43, 43, 255))
				draw.RoundedBox(0, -180 + 8, 8, 150 - 16, 880 - 16, Color(64,64,64, 255))
				draw.RoundedBox(0, -180 + 12, 12, 150 - 24, 880 - 24, Color(32,32,32, 255))

				--Draw icon
				surface.SetMaterial(timeLeft)
				surface.SetDrawColor(Color(255,255,255,90))
				surface.DrawTexturedRect(-155, -110, 100, 100)

				draw.RoundedBox(0, -180 + 12, 12 + ((880 - 24) -  (880 - 24) * percent), 150 - 24, (880 - 24) * percent, color)

				--Time bar
				draw.RoundedBox(0, 40, -130, 150, 880 + 128, Color(43, 43, 43, 255))
				draw.RoundedBox(0, 40 + 8, 8, 150 - 16, 880 - 16, Color(64,64,64, 255))
				draw.RoundedBox(0, 40 + 12, 12, 150 - 24, 880 - 24, Color(32,32,32, 255))

				--Draw icon
				surface.SetMaterial(mix)
				surface.SetDrawColor(Color(255,255,255,90))
				surface.DrawTexturedRect(70, -110, 100, 100)

				draw.RoundedBox(0, 40 + 12, 12 + ((880 - 24) -  (880 - 24) * self.lerpedMixAmount), 150 - 24, (880 - 24) * self.lerpedMixAmount, color2)

				--Draw recipe name

				draw.SimpleText(recipe.name, "BP_Chemical_UI_Name3", 0, -235, Color(255,255,255,90), 1, 1)
				draw.SimpleText("Press 'E' to mix", "BP_Chemical_UI_Name", 0, -175, Color(255,255,255,90), 1, 1)
				draw.SimpleText("Don't let it burn!", "BP_Chemical_UI_Name2", 0, -140, Color(255,255,255,90), 1, 1)
			cam.End3D2D()
		end
	end


	--Always draw flame
	self:DrawFlame()
end

function ENT:OnRemove()
	self:StopSound("bp_burner")
end