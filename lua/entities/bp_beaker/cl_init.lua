include("shared.lua")

function ENT:Initialize()
	self.ang = 0

	--Genereate and set our material to the liquid color
	self.liquidMat = BLUES_PHARMA:GetPooledMaterial()
	self:SetSubMaterial(1, self.liquidMat.materialName)

	BLUES_PHARMA:SetMaterialColor(self.liquidMat.index, Color(255,255,255))

	self.lerpedLiquidAmount = 0

	self.prevStirAngle = 0

	--List of chemicals and there amount
	self.BPContents = {}

	self.targetColor = Color(255,255,255)
	self.lerpedColor = Color(255,255,255)
end

--Credit to the wiki
function ENT:DrawCircle( x, y, radius, seg, percent)
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad(180 + ( i / seg ) * (-360 * percent))
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad(-360 * percent)
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end
 
--Sets the rotation of the stirrer
function ENT:SetStirRotation(ang)
	self:ManipulateBoneAngles(2, Angle(ang,0,0))

	self:ManipulateBoneAngles(1, Angle(ang / 3,0,0))
	self:ManipulateBoneAngles(3, Angle(ang / 3,0,0))
end

--Sets the rotation of the liquid
function ENT:SetLiquidRotation(ang)
	self:ManipulateBoneAngles(1, Angle(ang,0,0))
	self:ManipulateBoneAngles(3, Angle(ang,0,0))
end

--Sets how much liquid is in the beaker (0-1)
--Makes liquid visible/invisible based on amount
function ENT:SetLiquidLevel(level)
	if level <= 0.01 then
		self:ManipulateBoneScale(1, Vector(0,0,0))
		self:ManipulateBoneScale(3, Vector(0,0,0))
	else
		self:ManipulateBoneScale(1, Vector(1,1,1))
		self:ManipulateBoneScale(3, Vector(1,1,1))
		self:ManipulateBonePosition(1, Vector(0, 0, Lerp(level, -11.8, 0)))
	end
end

--Recalculates the color for the liquid
function ENT:UpdateColor()
	local colorTable = {}
	local count = table.Count(self.BPContents)

	if count > 1 then
		for k, v in pairs(self.BPContents) do
			for i = 1, v / 50 do
				table.insert(colorTable, BLUES_PHARMA.Chemicals[k].color)
			end
		end
		self.targetColor = BLUES_PHARMA:MixColors(colorTable)
	elseif count == 1 then
		--Find starting key
		for k, v in pairs(self.BPContents) do
			self.targetColor =  BLUES_PHARMA.Chemicals[k].color
			self.lerpedColor = self.targetColor
		end
	end
end

local levelIcon = Material("blues_pharm/ui/level.png", "smooth")
local titleIcon = Material("blues_pharm/ui/title.png", "smooth")

--Draws the UI for the chemical list
function ENT:DrawChemicalList(pos, ang, titleHeaderDistance)
	cam.Start3D2D(pos, ang, 0.05)
		surface.SetMaterial(titleIcon)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(-140, -270, 280, 65 + titleHeaderDistance)

		draw.RoundedBox(0, -140, -270, 20, 275 + titleHeaderDistance, Color(43, 43, 43))

		draw.SimpleText(string.upper(BLUES_PHARMA.TRANS.Beaker), "BP_Chemical_Title",  -115, -270, Color(255, 255, 255), 0, 0)
		draw.SimpleText(BLUES_PHARMA.TRANS.Contents..":", "BP_Chemical_Amount",  -115, -240, Color(255, 255, 255, 180), 0, 0)

		local y = 30

		for k, v in pairs(self.BPContents) do
			draw.SimpleText(BLUES_PHARMA.Chemicals[k].name.." ("..v.."ml)", "BP_Chemical_Amount2",  -115, -240 + y, Color(255, 255, 255, 180), 0, 0)
		
			y = y + 30
		end

	cam.End3D2D()
end

--Draws the UI for waiting to mix and burn
function ENT:DrawWaitingMessage(pos, ang, str)
	cam.Start3D2D(pos, ang, 0.05)
		surface.SetMaterial(titleIcon)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(-140, -270, 280, 65)

		draw.RoundedBox(0, -140, -270, 20, 275, Color(43, 43, 43))

		draw.SimpleText(string.upper(BLUES_PHARMA.TRANS.Beaker).." ("..BLUES_PHARMA.Medicines[self:GetRecipe()].name..")", "BP_Chemical_Title",  -115, -270, Color(255, 255, 255), 0, 0)
		draw.SimpleText(str, "BP_Chemical_Amount",  -115, -240, Color(255, 255, 255, 180), 0, 0)
	cam.End3D2D()
end

local timerIcon = Material("blues_pharm/ui/timer_face.png", "smooth")
local timerHand = Material("blues_pharm/ui/timer_hand.png", "smooth")

--Draws the timer to show how long left while freezing
function ENT:DrawFreezingTimer()
	local ang = self:GetAngles()
	local pos = self:GetPos() + (ang:Forward() * 4) + (ang:Up() * 2)

	ang:RotateAroundAxis(ang:Right(), -90)
	ang:RotateAroundAxis(ang:Up(), 90)
	cam.Start3D2D(pos, ang, 0.03)
		surface.SetMaterial(titleIcon)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRectRotated(0, -75, 270, 200, -90)

		local p = math.Clamp((CurTime() - self:GetFreezeStartTime()) / self:GetFreezeTime(), 0, 1)
		local color = BLUES_PHARMA:LerpColor(Color(249, 66, 58), Color(135,206,250), p)
		color.a = 80
		surface.SetDrawColor(color)
		draw.NoTexture()
		self:DrawCircle(0, -80, 75, 32, p)

		surface.SetMaterial(timerIcon)
		surface.SetDrawColor(Color(255, 255, 255, 200))
		surface.DrawTexturedRectRotated(0,-80,150,150, 0)

		surface.SetMaterial(timerHand)
		surface.DrawTexturedRectRotated(0,-80,150,150, p * -360)

		draw.SimpleText(BLUES_PHARMA.Medicines[self:GetRecipe()].name, "BP_Chemical_Title",  0, -203, Color(255, 255, 255), 1, 0)

	cam.End3D2D()
end

function ENT:DrawTranslucent()
	self:SetSubMaterial(1, self.liquidMat.materialName)
	self:DrawModel()

	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > BLUES_PHARMA.CONFIG.Cam3D2DRenderDist  then return end

	local titleHeaderDistance = 30 * table.Count(self.BPContents)

	local ang = self:GetAngles()
	local pos = self:GetPos() + (ang:Up() * (titleHeaderDistance / 20))
	local pos2 = self:GetPos() + ang:Up()

	local ang1 = self:WorldToLocalAngles((LocalPlayer():EyePos() - pos):Angle())
	local ang2 = self:LocalToWorldAngles(Angle(0, ang1.y + 90, 90))

	--Decide what to draw
	if self:GetBeakerState() == self.States.CREATING then
		self:DrawChemicalList(pos, ang2, titleHeaderDistance)
	elseif self:GetBeakerState() == self.States.WAITING_FOR_MIX_AND_BURN then
		self:DrawWaitingMessage(pos2, ang2, BLUES_PHARMA.TRANS.RequiresCooking)
	elseif self:GetBeakerState() == self.States.WAITING_FOR_FREEZING then
		self:DrawWaitingMessage(pos2, ang2, BLUES_PHARMA.TRANS.RequiresFreezing )
	elseif self:GetBeakerState() == self.States.FREEZING then
		self:DrawFreezingTimer()
	elseif self:GetBeakerState() == self.States.READY_TO_PRESS then
		self:DrawWaitingMessage(pos2, ang2, BLUES_PHARMA.TRANS.ReadyForPressing)
	end
end

function ENT:Think() 
	--set liquid level
	self.lerpedLiquidAmount = Lerp(4 * FrameTime(), self.lerpedLiquidAmount, self:GetLiquidAmount() / 500)
	self.lerpedColor = BLUES_PHARMA:LerpColor(self.lerpedColor, self.targetColor, 4 * FrameTime())

	--Update color and liquid level
	BLUES_PHARMA:SetMaterialColor(self.liquidMat.index, self.lerpedColor)
 	self:SetLiquidLevel(self.lerpedLiquidAmount)

 	--Stiring
 	if self.ang > self:GetStirAngle() then
 		self.ang = self:GetStirAngle()
 	end
	self.ang = Lerp(1 * FrameTime(), self.ang, self:GetStirAngle())
	self:SetStirRotation(self.ang)
end

--Free up the pooled material and remove from render list
function ENT:OnRemove()
	--Reset the materials
	BLUES_PHARMA.PooledMaterials[self.liquidMat.index].material:SetTexture("$basetexture", "blues_pharm/beaker_liquid_color")
	BLUES_PHARMA.PooledMaterials[self.liquidMat.index].inUse = false
end