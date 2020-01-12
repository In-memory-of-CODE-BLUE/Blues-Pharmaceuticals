include("blues_pharm_config.lua")
include("blues_pharm_translation.lua")

BLUES_PHARMA = BLUES_PHARMA or {}

--Contains a list of all pooled color materials (prevent refresh)
BLUES_PHARMA.PooledMaterials = BLUES_PHARMA.PooledMaterials or {}

--This is the chemical this player has selected if any
BLUES_PHARMA.SelectedChemical = BLUES_PHARMA.SelectedChemical  or nil

--The table used to generate the liquid material
BLUES_PHARMA.LiquidMaterialTable = {
	["$basetexture"] = "blues_pharm/beaker_liquid_color",
	["$envmap"] = "env_cubemap",
	["$envmaptint"] = Vector(255 * 0.2, 255 * 0.2, 255 * 0.2),
	["$envmapcontrast"] = 0.5,
	["$envmapsaturation"] = 0,
	["$envmapfresnel"] = 1,
	["$color2"] = Vector(1,1,1)
}

hook.Add( "PreDrawHalos", "BLUES_PHARMA_HOLOS", function()
	if IsValid(BLUES_PHARMA.SelectedChemical) then
		local rate = (math.sin(CurTime() * 8) + 1) / 2
		halo.Add({BLUES_PHARMA.SelectedChemical}, BLUES_PHARMA:LerpColor(Color(0, 0, 0), Color(255, 255, 255), rate), 10, 10, 3, true)
	end
end)

local UIOffset = -30

hook.Add("HUDPaint", "BLUES_PHARMA_DRAW_CHEMICAL", function()
	if IsValid(BLUES_PHARMA.SelectedChemical) then
		UIOffset = Lerp(10 * FrameTime(), UIOffset, -40)

		--Get legnth of text
		surface.SetFont("BP_Chemical_UI_Name")
		local str = "'"..string.upper(BLUES_PHARMA.Chemicals[BLUES_PHARMA.SelectedChemical.ChemicalID].name).."' "..BLUES_PHARMA.TRANS.Selected
		local lenX, lenY = surface.GetTextSize(str) 
		lenX = math.Clamp(lenX, 400, 1920)

		--drawing a box with rounded ended or not gives different round results???
		local round = math.floor(UIOffset)

		local backgroundXPos = math.floor(ScrW()/2 - ((lenX/2) + 10))

		--Draw background box
		draw.RoundedBoxEx(8, backgroundXPos, ScrH() - 155 - round, lenX + 20, 60, Color(45, 52, 54, 240), true, true, false, false)
		draw.RoundedBox(0, backgroundXPos, ScrH() - 95 - round, lenX + 20, 110, Color(45, 52, 54, 200))

		draw.SimpleText(str, "BP_Chemical_UI_Name", ScrW()/2  + 3, ScrH() - 123 - round, Color(0,0, 0,255), 1, 1)
		draw.SimpleText(str, "BP_Chemical_UI_Name", ScrW()/2, ScrH() - 126 - round, BLUES_PHARMA.Chemicals[BLUES_PHARMA.SelectedChemical.ChemicalID].color, 1, 1)

		draw.SimpleText(BLUES_PHARMA.TRANS.Pour, "BP_Chemical_UI_Name2", ScrW()/2 + 1, ScrH() - 78 - round, Color(0,0, 0,255), 1, 1)
		draw.SimpleText(BLUES_PHARMA.TRANS.Pour, "BP_Chemical_UI_Name2", ScrW()/2, ScrH() - 80 - round, Color(223, 230, 233), 1, 1)

		draw.SimpleText(BLUES_PHARMA.TRANS.Cancel, "BP_Chemical_UI_Name2", ScrW()/2 + 1, ScrH() - 55 - round, Color(0,0, 0,255), 1, 1)
		draw.SimpleText(BLUES_PHARMA.TRANS.Cancel, "BP_Chemical_UI_Name2", ScrW()/2, ScrH() - 57 - round, Color(223, 230, 233), 1, 1)
	else
		UIOffset = -200
	end
end)

--Handle deselecting
hook.Add("Think","BLUES_PHARMA_DESELECT", function()
	if IsValid(BLUES_PHARMA.SelectedChemical) then
		if input.IsButtonDown(KEY_X) then
			BLUES_PHARMA:DeselectChemical()
		else
			--Check out distance to the jar
			if LocalPlayer():GetPos():Distance(BLUES_PHARMA.SelectedChemical:GetPos()) > 250 then
				BLUES_PHARMA:DeselectChemical()
			end
		end
	end
end)

--Lerps a color
function BLUES_PHARMA:LerpColor(a, b, t)
	local vec = LerpVector(t, Vector(a.r, a.g, a.b), Vector(b.r, b.g, b.b))
	return Color(vec.x, vec.y, vec.z)
end 

--Boing-like interpolation
function BLUES_PHARMA:Berp(t, s, e)
	t = math.Clamp(t, 0, 1)
	t = (math.sin(t * math.pi * (2.7 * t * t * t)) * math.pow(1 - t, 2.2) + t) * (1 + (1.2 * (1 - t)))
	return s + (e - s) * t
end
 
--Sinusoidal interpolation
function BLUES_PHARMA:Sinerp(t, s, e)
	return Lerp(math.sin(t * math.pi * 0.5), s, e)
end

--Calculates a point along a cubic spline and returns it
function BLUES_PHARMA:CalcCubicSpline(p0, p1, p2, t)
	return LerpVector(t, LerpVector(t, p0, p1), LerpVector(t, p1, p2))
end

--Deselects a chemical and notifies the server
function BLUES_PHARMA:DeselectChemical()
	BLUES_PHARMA.SelectedChemical = nil
	net.Start("BLUES_PHARMA_SELECT")
	net.SendToServer()
end

--Tries to get a free pooled material, if it fails it will generate a new one
function BLUES_PHARMA:GetPooledMaterial()
	for k, v in pairs(BLUES_PHARMA.PooledMaterials) do
		if not v.inUse then
			v.inUse = true
			return v
		end
	end

	--We failed to find one so lets generate one
	local id = #BLUES_PHARMA.PooledMaterials + 1
	local mat = CreateMaterial("bp_liquid_"..id, "VertexLitGeneric", BLUES_PHARMA.LiquidMaterialTable)
	local pooledTable = {
		inUse = true,
		material = mat,
		materialName = "!bp_liquid_"..id,
		index = id
	} 

	--Pool it
	BLUES_PHARMA.PooledMaterials[id] = pooledTable

	return BLUES_PHARMA.PooledMaterials[id]
end

--Updates the material to reflect the liquid color
function BLUES_PHARMA:SetMaterialColor(pooledID, color)
	BLUES_PHARMA.PooledMaterials[pooledID].material:SetVector("$color2", Vector(color.r / 255, color.g /255, color.b / 255))
end

--Gets the average color of all of them
function BLUES_PHARMA:MixColors(colorTables)
	local newCol = Color(0,0,0)

	local r = 0
	local g = 0
	local b = 0

	for i = 1 , #colorTables do
		r = r + colorTables[i].r
		g = g + colorTables[i].g
		b = b + colorTables[i].b
	end

	local count = table.Count(colorTables)

	newCol = Color(r / count, g / count , b / count , 255)

	return newCol
end

--The materials for the measuring tool
local measure_overlay = Material("blues_pharm/ui/measure_overlay.png", "smooth")
local measure_liquid = Material("blues_pharm/ui/measure_liquid.png", "smooth")
local measure_bottom_mask = Material("blues_pharm/ui/measure_bottom_mask.png", "smooth")

BLUES_PHARMA.MeasureWindowOpen = false

--Opens a window that allows to the user to input an amount they want to pour
function BLUES_PHARMA:ShowMeasurmentUI()
	if BLUES_PHARMA.MeasureWindowOpen then return end
	BLUES_PHARMA.MeasureWindowOpen = true

	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrW(), ScrH())
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame.Close = function(s) 
		BLUES_PHARMA.MeasureWindowOpen = false 
		s:Remove() 
		if IsValid(BLUES_PHARMA.SelectedChemical) then 
			BLUES_PHARMA:DeselectChemical() 
		end 
	end

	frame.Paint = function() end

	local mesurePanel = vgui.Create("DPanel", frame)
	mesurePanel:SetSize(ScrW(), 614)
	mesurePanel:Center()
	mesurePanel.lerpPos = 0
	mesurePanel.truePos = 0
	mesurePanel.yPos = 0
	mesurePanel.Paint = function(s, w, h)
		if not IsValid(BLUES_PHARMA.SelectedChemical) then return end

		local mouseY = gui.MouseY()
		local x, _y = s:ScreenToLocal(0, mouseY)
		--Get Y relative to the panel
		local y = (math.Round(((math.Clamp((_y - (210 * 0.6)) * 2, 0, h) / h) * 300) / 60) * 60) / 300

		local liquid = math.Clamp(BLUES_PHARMA.SelectedChemical:GetLiquidAmount(), 0, 300)

		s.lerpPos = Lerp(15 * FrameTime(), s.lerpPos, y)
		s.truePos = y
		s.yVal = y

		render.SetScissorRect(0, 0, ScrW(), (ScrH()/2) + 150, true)

		surface.SetMaterial(measure_liquid) 
		surface.SetDrawColor(BLUES_PHARMA.Chemicals[BLUES_PHARMA.SelectedChemical.ChemicalID].color)
		surface.DrawTexturedRectRotated(w/2, (h/2) + Lerp(s.lerpPos, 0, 315), 488 * 0.6, 1023 * 0.6, 0)

		render.SetScissorRect(0,0,0,0,false)

		surface.SetMaterial(measure_bottom_mask)
		surface.DrawTexturedRectRotated(w/2, h/2, 488 * 0.6, 1023 * 0.6, 0)

		surface.SetMaterial(measure_overlay)
		surface.SetDrawColor(Color(255,255,255,255))
		surface.DrawTexturedRectRotated(w/2, h/2, 488 * 0.6, 1023 * 0.6, 0)
	end

	--Handles closing and auto deselect when quiting it
	mesurePanel.Think = function(s)
		if input.IsButtonDown(KEY_ESCAPE) or
			input.IsButtonDown(KEY_X) or
			 input.IsButtonDown(MOUSE_RIGHT) then
			frame:Close()
			BLUES_PHARMA:DeselectChemical()
		elseif input.IsButtonDown(MOUSE_LEFT) then
			net.Start("BLUES_PHARMA_POUR")
			net.WriteFloat(s.yVal or 0)
			net.SendToServer() 
			BLUES_PHARMA.SelectedChemical = nil
			frame:Close()
		end
	end
end

--Returns the time from seconds to minute:secodns
function BLUES_PHARMA:FormatTime(seconds)
	local seconds = tonumber(seconds)

	hours = string.format("%02.f", math.floor(seconds/3600))
	mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
	secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))

	return mins..":"..secs
end

--The last page they were on
BLUES_PHARMA.BookPage = 1
BLUES_PHARMA.BookIsOpen = false

local bookMat = Material("blues_pharm/ui/book.png", "noclamp smooth")
local arrowMat = Material("blues_pharm/ui/arrow_right.png", "noclamp smooth")
local minPage = 1
local maxPage = #BLUES_PHARMA.Pages

--Keys that close 
local escapeKeys = {
	KEY_W,
	KEY_A,
	KEY_S,
	KEY_D,
	KEY_X,
	KEY_ESCAPE,
	MOUSE_RIGHT,
	KEY_E
}

--Opens the recipe book
function BLUES_PHARMA:OpenGuideBook()
	if BLUES_PHARMA.BookIsOpen then return end

	BLUES_PHARMA.BookIsOpen = true

	local frame = vgui.Create("DFrame")

	frame:SetSize(1024, 768)
	frame:Center()
	frame:SetTitle("")
	frame.openTime = CurTime() + 0.5 --Add .5 second cooldown after open to prevent acidental closing
	frame:ShowCloseButton(false)
	frame.Paint = function(s, w, h)
		surface.SetDrawColor(Color(255,255,255,255))
		surface.SetMaterial(bookMat)
		surface.DrawTexturedRect(0,0, w, h)
	end
	frame.Close = function(s)
		BLUES_PHARMA.BookIsOpen = false
		frame:Remove()
	end
	frame.Think = function(s)
		if CurTime() > frame.openTime then
			for i = 1 , 7 do
				if input.IsButtonDown(escapeKeys[i]) then
					frame:Close()
					break
				end 
			end

			if input.IsButtonDown(MOUSE_LEFT) then
				local p = vgui.GetHoveredPanel()
				if not IsValid(p) then frame:Close() end
				if not (p == s or p:HasParent(s)) then frame:Close() end
			end
		end
	end
 
	frame.RenderPage = function(self, pageID)
		if IsValid(self.contentPanel) then
			self.contentPanel:Remove()
		end

		self.contentPanel = vgui.Create("DPanel", self)
		self.contentPanel:SetSize(self:GetWide(), self:GetTall())
		self.contentPanel.Paint = function() end

		local page = BLUES_PHARMA.Pages[BLUES_PHARMA.BookPage]

		--Check the page type
		if page.type == "header" then
			local title = vgui.Create("DLabel", self.contentPanel)
			title:SetPos(40, 80)
			title:SetSize((self:GetWide() / 2) - 45, 90)
			title:SetFont("BP_BOOK_TITLE")
			title:SetText(page.title)
			title:SetTextColor(Color(0,0,0)) 
			title:SetContentAlignment(5)

			--contents
			local contents = vgui.Create("RichText", self.contentPanel)
			contents:SetPos(80, 275)
			contents:SetSize((self:GetWide() / 2) - 85 - 40, 300)
			contents:AppendText(page.contents)
			contents:SetVerticalScrollbarEnabled(false)
			contents:SetContentAlignment(5)
			function contents:PerformLayout()
				self:SetFontInternal( "BP_BOOK_CONTENTS" )
				self:SetFGColor( Color( 0, 0, 0 ) )
			end

			local contentsRight = vgui.Create("RichText", self.contentPanel)
			contentsRight:SetPos((self:GetWide() / 2) + 40 , 150)
			contentsRight:SetSize((self:GetWide() / 2) - 85 - 40, 500)
			contentsRight:AppendText(page.contentsRight)
			contentsRight:SetVerticalScrollbarEnabled(false)
			contentsRight:SetContentAlignment(5)
			function contentsRight:PerformLayout()
				self:SetFontInternal( "BP_BOOK_CONTENTS" )
				self:SetFGColor( Color( 0, 0, 0 ) )
			end

			--Page numbers
			local pageNumber = vgui.Create("DLabel", self.contentPanel)
			pageNumber:SetPos(40, self:GetTall() - 100)
			pageNumber:SetSize((self:GetWide() / 2) - 45, 30)
			pageNumber:SetFont("BP_BOOK_PAGE")
			pageNumber:SetText(((BLUES_PHARMA.BookPage - 1) * 2) + 1)
			pageNumber:SetTextColor(Color(0,0,0)) 
			pageNumber:SetContentAlignment(5)

			pageNumber = vgui.Create("DLabel", self.contentPanel)
			pageNumber:SetPos((self:GetWide()/2), self:GetTall() - 100)
			pageNumber:SetSize((self:GetWide() / 2) - 45, 30)
			pageNumber:SetFont("BP_BOOK_PAGE")
			pageNumber:SetText(((BLUES_PHARMA.BookPage - 1) * 2) + 2)
			pageNumber:SetTextColor(Color(0,0,0)) 
			pageNumber:SetContentAlignment(5)
		elseif page.type == "recipe" then
			local recipe = BLUES_PHARMA.Medicines[page.recipeID]

			local title = vgui.Create("DLabel", self.contentPanel)
			title:SetPos(40, 80)
			title:SetSize((self:GetWide() / 2) - 45, 90)
			title:SetFont("BP_BOOK_TITLE")
			title:SetText(recipe.name)
			title:SetTextColor(Color(0,0,0)) 
			title:SetContentAlignment(5)

			--contents
			local contents = vgui.Create("RichText", self.contentPanel)
			contents:SetPos(80, 170)
			contents:SetSize((self:GetWide() / 2) - 85 - 40, 300)
			contents:AppendText(page.desc)
			contents:SetVerticalScrollbarEnabled(false)
			contents:SetContentAlignment(5)
			function contents:PerformLayout()
				self:SetFontInternal( "BP_BOOK_CONTENTS" )
				self:SetFGColor( Color( 0, 0, 0 ) )
			end

			local title2 = vgui.Create("DLabel", self.contentPanel)
			title2:SetPos(40, 360)
			title2:SetSize((self:GetWide() / 2) - 45, 90)
			title2:SetFont("BP_BOOK_TITLE")
			title2:SetText("Effects")
			title2:SetTextColor(Color(0,0,0)) 
			title2:SetContentAlignment(5)

			local contents2 = vgui.Create("RichText", self.contentPanel)
			contents2:SetPos(80, 450)
			contents2:SetSize((self:GetWide() / 2) - 85 - 40, 300)
			contents2:AppendText(page.effects)
			contents2:SetVerticalScrollbarEnabled(false)
			contents2:SetContentAlignment(5)
			function contents2:PerformLayout()
				self:SetFontInternal( "BP_BOOK_CONTENTS" )
				self:SetFGColor( Color( 0, 0, 0 ) )
			end

			--Right page			
			local recipeTitle = vgui.Create("DLabel", self.contentPanel)
			recipeTitle:SetPos((self:GetWide() / 2) + 5, 90)
			recipeTitle:SetSize((self:GetWide() / 2) - 45, 90)
			recipeTitle:SetFont("BP_BOOK_TITLE")
			recipeTitle:SetText("Recipe")
			recipeTitle:SetTextColor(Color(0,0,0)) 
			recipeTitle:SetContentAlignment(5)

			local contentsRight = vgui.Create("RichText", self.contentPanel)
			contentsRight:SetPos((self:GetWide() / 2) + 40 , 170)
			contentsRight:SetSize((self:GetWide() / 2) - 85 - 40, 500)
			contentsRight:AppendText(BLUES_PHARMA.TRANS.BOOK.Pour.."\n\n")
			contentsRight:SetVerticalScrollbarEnabled(false)
			contentsRight:SetContentAlignment(5)
			function contentsRight:PerformLayout()
				self:SetFontInternal( "BP_BOOK_CONTENTS" )
				self:SetFGColor( Color( 0, 0, 0 ) )
			end

			--Chemical panel
			local chemicalPanel = vgui.Create("DPanel", self.contentPanel)
			chemicalPanel:SetPos((self:GetWide() / 2) + 40 , 200)
			chemicalPanel:SetSize((self:GetWide() / 2) - 85 - 40, 100)

			chemicalPanel.Paint = function(s, w, h)
				local y = 10
				--Add pouring list
				for k, v in pairs(recipe.recipe) do
					draw.SimpleText(BLUES_PHARMA.Chemicals[k].name, "BP_BOOK_CONTENTS", 30, y, Color(0,0,0), 0, 0)
					draw.SimpleText(v.."ml", "BP_BOOK_CONTENTS", w - 40, y, Color(0,0,0), 2, 0)
					y = y + 28
				end
			end

			local timeToBurn = BLUES_PHARMA:FormatTime(recipe.cookTime)
			local timeToFreze = BLUES_PHARMA:FormatTime(recipe.freezeTime)

			contentsRight:AppendText("\n\n\n\n"..string.format(BLUES_PHARMA.TRANS.BOOK.PourComplete, timeToBurn).."\n\n")
			contentsRight:AppendText(string.format(BLUES_PHARMA.TRANS.BOOK.CookComplete, timeToFreze).."\n\n")
			contentsRight:AppendText(BLUES_PHARMA.TRANS.BOOK.FreezeComplete.."\n\n")

			--Page numbers
			local pageNumber = vgui.Create("DLabel", self.contentPanel)
			pageNumber:SetPos(40, self:GetTall() - 100)
			pageNumber:SetSize((self:GetWide() / 2) - 45, 30)
			pageNumber:SetFont("BP_BOOK_PAGE")
			pageNumber:SetText(((BLUES_PHARMA.BookPage - 1) * 2) + 1)
			pageNumber:SetTextColor(Color(0,0,0)) 
			pageNumber:SetContentAlignment(5)

			pageNumber = vgui.Create("DLabel", self.contentPanel)
			pageNumber:SetPos((self:GetWide()/2), self:GetTall() - 100)
			pageNumber:SetSize((self:GetWide() / 2) - 45, 30)
			pageNumber:SetFont("BP_BOOK_PAGE")
			pageNumber:SetText(((BLUES_PHARMA.BookPage - 1) * 2) + 2)
			pageNumber:SetTextColor(Color(0,0,0)) 
			pageNumber:SetContentAlignment(5)
		end

		--Turn pages buttons
		local turnRight = vgui.Create("DButton", self.contentPanel)
		turnRight:SetPos(self:GetWide() - 120, self:GetTall() - 120)
		turnRight:SetSize(64, 64)
		turnRight.lerp = 0.8
		turnRight:SetText("")
		turnRight.Paint = function(s, w, h)
			if s:IsHovered() then
				s.lerp = Lerp(10 * FrameTime(), s.lerp, 1)
			else
				s.lerp = Lerp(10 * FrameTime(), s.lerp, 0.8)
			end

			surface.SetMaterial(arrowMat)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.DrawTexturedRectRotated(w/2, h/2, 64 * s.lerp, 64 * s.lerp, 0)
		end
		turnRight.DoClick = function(s)
			if BLUES_PHARMA.BookPage < maxPage then
				BLUES_PHARMA.BookPage = BLUES_PHARMA.BookPage + 1
				self:RenderPage(BLUES_PHARMA.BookPage)
			end
		end

		local turnLeft = vgui.Create("DButton", self.contentPanel)
		turnLeft:SetPos(56, self:GetTall() - 120)
		turnLeft:SetSize(64, 64)
		turnLeft.lerp = 0.8
		turnLeft:SetText("")
		turnLeft.Paint = function(s, w, h)
			if s:IsHovered() then
				s.lerp = Lerp(10 * FrameTime(), s.lerp, 1)
			else
				s.lerp = Lerp(10 * FrameTime(), s.lerp, 0.8)
			end

			surface.SetMaterial(arrowMat)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.DrawTexturedRectRotated(w/2, h/2, 64 * s.lerp, 64 * s.lerp, 180)
		end
		turnLeft.DoClick = function(s)
			if BLUES_PHARMA.BookPage > minPage then
				BLUES_PHARMA.BookPage = BLUES_PHARMA.BookPage - 1
				self:RenderPage(BLUES_PHARMA.BookPage)
			end
		end
	end

	frame:RenderPage(1)
	frame:MakePopup()
end

net.Receive("BLUES_PHARMA_OPEN_MEASURE", function() BLUES_PHARMA:ShowMeasurmentUI() end)

local beamMat = Material("blues_pharm/ui/beam")
 
--Draws the selection beam from the selected entity to the cursor/pour position
hook.Add("PostDrawTranslucentRenderables", "BLUES_PHARMA_POUR_BEAM", function(sky)
	if sky then return end

	if IsValid(BLUES_PHARMA.SelectedChemical) then
		local origin = BLUES_PHARMA.SelectedChemical:GetPos()
		local hitPos = LocalPlayer():GetEyeTrace().HitPos
		local texturePos = 0

		local p0 = origin + Vector(0,0,17)
		local p1 = Lerp(0.5, hitPos, origin) + Vector(0,0,Lerp(math.Clamp(origin:Distance(hitPos) / 750, 0, 1), 40, 250))
		local p2 = hitPos + Vector(0,0,2)

		local steps = 32
 

		render.SetMaterial(beamMat)  

		render.StartBeam(steps + 1)
 
		--Precalculate the distance to save perfomance, not acurate but eh
		local _point =  1/steps
		local _point2 =  0
		local _vec1 = BLUES_PHARMA:CalcCubicSpline(p0, p1, p2, _point)
		local _vec2 = BLUES_PHARMA:CalcCubicSpline(p0, p1, p2, _point2)

		local dist = _vec2:Distance(_vec1) / 25

		for i = 0, steps do
			local point =  i/steps
			local vec1 = BLUES_PHARMA:CalcCubicSpline(p0, p1, p2, point)

			texturePos = texturePos + dist

			render.AddBeam(vec1, 8, texturePos, Color(255,255,255), true, true)
		end

		cam.IgnoreZ(true)
		render.SetColorModulation(0.1,0,0) 
		render.EndBeam()
		cam.IgnoreZ(false)
	end
end) 

net.Receive("BLUES_PHARMA_OPEN_BOOK", function()
	BLUES_PHARMA:OpenGuideBook()
end)

net.Receive("BLUES_PHARMA_SELECT", function()
	local ent = net.ReadEntity()
	BLUES_PHARMA.SelectedChemical = ent
end)

net.Receive("BLUES_PHARMA_BEAKER_CONTENTS", function()
	local e = net.ReadEntity()
	local contents = net.ReadTable()

	if IsValid(e) then
		e.BPContents = contents

		--Update color
		e:UpdateColor()
	end
end)

net.Receive("BLUES_PHARMA_BEAKER_CONTENTS_ALL", function()
	local data = net.ReadTable()

	for k, v in pairs(data) do
		if IsValid(v[1]) then
			v[1].BPContents = v[2] 
			v[1]:UpdateColor()
		end
	end
end)

--Changes a material from the frozen one or liquid one
net.Receive("BLUES_PHARMA_UPDATE_MAT", function()
	local state = net.ReadBool()
	local ent = net.ReadEntity()

	if not IsValid(ent) then return end

	local mat = ent.liquidMat.material

	if state then
		mat:SetTexture("$basetexture", "blues_pharm/beaker_liquid_frozen_color")
	else
		mat:SetTexture("$basetexture", "blues_pharm/beaker_liquid_color")
	end
end)

hook.Add( "InitPostEntity", "BLUES_PHARMA:RequestContents", function()
	net.Start("BLUES_PHARMA_BEAKER_CONTENTS_ALL")
	net.SendToServer()
end )

--FONTS
surface.CreateFont( "BP_BOOK_TITLE", {
	font = "Arial",
	extended = false,
	size = 50,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BP_BOOK_CONTENTS", {
	font = "Arial",
	extended = false,
	size = 23,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BP_BOOK_PAGE", {
	font = "Arial",
	extended = false,
	size = 24,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )


surface.CreateFont( "BP_Chemical_Title", {
	font = "Roboto",
	extended = false,
	size = 35,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BP_Chemical_Amount", {
	font = "Roboto",
	extended = false,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BP_Chemical_Amount2", {
	font = "Roboto",
	extended = false,
	size = 25,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )


surface.CreateFont( "BP_Chemical_UI_Name", {
	font = "Roboto Lt",
	extended = false,
	size = 50,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BP_Chemical_UI_Name2", {
	font = "Roboto Lt",
	extended = false,
	size = 25,
	weight = 200,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BP_Chemical_UI_Name3", {
	font = "Roboto Lt",
	extended = false,
	size = 80,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )