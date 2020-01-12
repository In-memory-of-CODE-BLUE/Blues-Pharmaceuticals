AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Kleiner.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetBloodColor(BLOOD_COLOR_RED)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
end 

function ENT:AcceptInput(str, act, call)
	if str == "Use" then
		if call:IsPlayer() then
			local ents = ents.FindInSphere(self:GetPos(), 150)
			local total = 0

			for k, v in pairs(ents) do
				if IsValid(v) and v:GetClass() == "bp_pill_bottle" then
					--Work out value of pill and remove it 
					local pricePerPill = BLUES_PHARMA.CONFIG.SellPrices[v:GetRecipeID()]
					pricePerPill = pricePerPill * (v:GetUsesLeft() / BLUES_PHARMA.Medicines[v:GetRecipeID()].pillCount)
					pricePerPill = math.ceil(pricePerPill)

					v:Remove()

					total = total + pricePerPill
				end
			end

			--Nothing here
			if total == 0 then
				call:ChatPrint(BLUES_PHARMA.TRANS.NPCBringPills)
			else
				BLUES_PHARMA.CONFIG.AddMoney(call, total) 
				call:ChatPrint(string.format(BLUES_PHARMA.TRANS.NPCSellPills, BLUES_PHARMA.TRANS.MoneySign..total))
			end
		end
	end
end 