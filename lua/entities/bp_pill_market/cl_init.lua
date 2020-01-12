include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

local titleIcon = Material("blues_pharm/ui/title.png", "smooth")

function ENT:Draw()
	self:DrawModel()

	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > BLUES_PHARMA.CONFIG.Cam3D2DRenderDist  then return end

	local ang = self:GetAngles()
	local pos = self:GetPos() + (ang:Up() * 53)

	local ang1 = self:WorldToLocalAngles((LocalPlayer():EyePos() - pos):Angle())
	local ang2 = self:LocalToWorldAngles(Angle(0, ang1.y + 90, 90))

	cam.Start3D2D(pos, ang2, 0.1)
		surface.SetMaterial(titleIcon)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(-160, -270, 280, 65)

		draw.RoundedBox(0, -160, -270, 20, 820, Color(43, 43, 43))

		draw.SimpleText("Pill Market", "BP_Chemical_Title",  -135, -270, Color(255, 255, 255), 0, 0)
		draw.SimpleText("Sell pills here", "BP_Chemical_Amount",  - 135, -240, Color(255, 255, 255, 60), 0, 0)
	cam.End3D2D()
end

function ENT:SetRagdollBones( b )
	self.m_bRagdollSetup = b
end

function ENT:DrawTranslucent()
	self:Draw()
end


