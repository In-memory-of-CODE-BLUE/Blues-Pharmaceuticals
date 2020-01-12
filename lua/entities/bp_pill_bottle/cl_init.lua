include("shared.lua")

local pillIcon = Material("blues_pharm/ui/pill.png", "smooth")
local titleIcon = Material("blues_pharm/ui/title.png", "smooth")

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > BLUES_PHARMA.CONFIG.Cam3D2DRenderDist  then return end

	local ang = self:GetAngles()
	local pos = self:GetPos() + (ang:Up() * 2)

	local ang1 = self:WorldToLocalAngles((LocalPlayer():EyePos() - pos):Angle())
	local ang2 = self:LocalToWorldAngles(Angle(0, ang1.y + 90, 90))

	cam.Start3D2D(pos, ang2, 0.038)
		surface.SetMaterial(titleIcon)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(-100, -270, 230, 65)

		draw.RoundedBox(0, -100, -270, 20, 320, Color(43, 43, 43))
 
		draw.SimpleText(BLUES_PHARMA.Medicines[self:GetRecipeID()].name, "BP_Chemical_Title",  -70, -272, Color(255, 255, 255), 0, 0)

		surface.SetMaterial(pillIcon)
		surface.SetDrawColor(Color(255, 255, 255, 60))
		surface.DrawTexturedRect(-75, -240, 32, 32)

		draw.SimpleText(self:GetUsesLeft().." Uses left", "BP_Chemical_Amount",  -35, -238, Color(255, 255, 255, 60), 0, 0)
	cam.End3D2D()
end