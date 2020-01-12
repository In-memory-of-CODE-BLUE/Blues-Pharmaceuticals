include("shared.lua")

local levelIcon = Material("blues_pharm/ui/level.png", "smooth")
local titleIcon = Material("blues_pharm/ui/title.png", "smooth")

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > BLUES_PHARMA.CONFIG.Cam3D2DRenderDist  then return end

	local ang = self:GetAngles()
	local pos = self:GetPos() + (ang:Up() * 6)

	local ang1 = self:WorldToLocalAngles((LocalPlayer():EyePos() - pos):Angle())
	local ang2 = self:LocalToWorldAngles(Angle(0, ang1.y + 90, 90))

	cam.Start3D2D(pos, ang2, 0.05)
		surface.SetMaterial(titleIcon)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(-140, -270, 280, 65)

		draw.RoundedBox(0, -140, -270, 20, 400, Color(43, 43, 43))

		draw.SimpleText(BLUES_PHARMA.Chemicals[self.ChemicalID].name, "BP_Chemical_Title",  -115, -270, Color(255, 255, 255), 0, 0)

		surface.SetMaterial(levelIcon)
		surface.SetDrawColor(Color(255, 255, 255, 60))
		surface.DrawTexturedRect(-115, -240, 32, 32)

		draw.SimpleText(self:GetLiquidAmount().."ml", "BP_Chemical_Amount",  -80, -240, Color(255, 255, 255, 60), 0, 0)
	cam.End3D2D()
end