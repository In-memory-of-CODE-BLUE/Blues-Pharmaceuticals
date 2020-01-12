AddCSLuaFile("blues_pharm_config.lua")
AddCSLuaFile("blues_pharm_translation.lua")
include("blues_pharm_config.lua")
include("blues_pharm_translation.lua")
 
BLUES_PHARMA = BLUES_PHARMA or {}

resource.AddWorkshop("1688987855")

--A list of beakers
BLUES_PHARMA.Beakers = {}

--Prevent players from spamming requests.
BLUES_PHARMA.NetworkedPlayers = {}

--Net messages
util.AddNetworkString("BLUES_PHARMA_SELECT")
util.AddNetworkString("BLUES_PHARMA_OPEN_MEASURE")
util.AddNetworkString("BLUES_PHARMA_POUR")
util.AddNetworkString("BLUES_PHARMA_BEAKER_CONTENTS")
util.AddNetworkString("BLUES_PHARMA_BEAKER_CONTENTS_ALL")
util.AddNetworkString("BLUES_PHARMA_UPDATE_MAT")
util.AddNetworkString("BLUES_PHARMA_OPEN_BOOK")

--This will add a holo to the render list for the client
function BLUES_PHARMA:SetSelectedChemical(ent, ply)
	net.Start("BLUES_PHARMA_SELECT")
	net.WriteEntity(ent)
	net.Send(ply)

	ply.BPSelectedChemical = ent
	ent.playerWhoSelected = ply
end
 
function BLUES_PHARMA:GetPourAmount(ply)
	net.Start("BLUES_PHARMA_OPEN_MEASURE")
	net.Send(ply)
end

--Networks the data for the beakers if a player joins
function BLUES_PHARMA:NetworkNewClient(ply)
	local data = {}
	for k, v in pairs(BLUES_PHARMA.Beakers) do
		data[k] = {
			[1] = v,
			[2] = v.ChemicalTable
		}
	end

	--Network to the player
	net.Start("BLUES_PHARMA_BEAKER_CONTENTS_ALL")
	net.WriteTable(data)
	net.Send(ply)
end

--Will try to see if a recipe can be made from this, if so it returns the ID of that medicine, if not it returns false.
function BLUES_PHARMA:CheckRecipie(beaker)
	local chemicals = beaker.ChemicalTable

	local foundRecipe = false
	for k, v in pairs(BLUES_PHARMA.Medicines) do
		local match = true

		for a, b in pairs(chemicals) do
			if v.recipe[a] ~= b then
				match = false
				break
			end
		end

		--Perform oposite check
		if match then
			for a, b in pairs(v.recipe) do
				if chemicals[a] ~= b then
					match = false
					break
				end
			end
		end

		if match then
			foundRecipe = k
			break
		end
	end

	return foundRecipe
end

--Set up player
hook.Add("PlayerDisconnected", "BLUES_PHARMA:CleanupPlayer", function(ply)
	local id = ply:UserID()
	BLUES_PHARMA.NetworkedPlayers[id] = nil
end)

--Clean up anything left by a player
hook.Add("PlayerInitialSpawn", "BLUES_PHARMA:SetupPlayer", function(ply)
	ply.BPOverdose = 0
	ply.BPOverdoseWarning = false

	ply.BPMedicalBuffs = {
		damageResistance = {
			timeLeft = 0,
			isActive = false,
			cortUsed = false,
			amount = 0
		},
		damageBuff = {
			timeLeft = 0,
			isActive = false,
			cortUsed = false,
			amount = 0
		},
		speedJumpBoost = {
			timeLeft = 0,
			isActive = false,
			startRunSpeed = 0,
			startWalkSpeed = 0,
			startJumpHeight = 0,
			cortUsed = false,
			amount = 0
		},
		passiveHealing = {
			timeLeft = 0,
			nextTick = 0,
			timeBetweenTick = 10,
			cortUsed = false,
			isActive = false,
			amount = 0
		}
	}
end)

hook.Add("PlayerDeath", "BLUES_PHARMA:ResetBuffs", function(ply)
	ply.BPMedicalBuffs = {
		damageResistance = {
			timeLeft = 0,
			isActive = false,
			cortUsed = false,
			amount = 0
		},
		damageBuff = {
			timeLeft = 0,
			isActive = false,
			cortUsed = false,
			amount = 0
		},
		speedJumpBoost = {
			timeLeft = 0,
			isActive = false,
			startRunSpeed = 0,
			startWalkSpeed = 0,
			startJumpHeight = 0,
			cortUsed = false,
			amount = 0
		},
		passiveHealing = {
			timeLeft = 0,
			nextTick = 0,
			timeBetweenTick = 10,
			cortUsed = false,
			isActive = false,
			amount = 0
		}
	}
	ply.BPOverdose = 0
	ply.BPOverdoseWarning = false
end)

--Disable pocketing if enabled
hook.Add("PostGamemodeLoaded", "BLUES_PHARMA:DisablePocketItems", function()
	local GM = gamemode.Get("darkrp")
	if GM ~= nil and GM.Config ~= nil and GM.Config.PocketBlacklist ~= nil then
		--Disable chemicals from pocketing
		GM.Config.PocketBlacklist["bp_chemical_17alph"] = true
		GM.Config.PocketBlacklist["bp_chemical_2nap"] = true
		GM.Config.PocketBlacklist["bp_chemical_acet"] = true
		GM.Config.PocketBlacklist["bp_chemical_acet2"] = true
		GM.Config.PocketBlacklist["bp_chemical_deio"] = true
		GM.Config.PocketBlacklist["bp_chemical_keto_acid"] = true
		GM.Config.PocketBlacklist["bp_chemical_prog"] = true
		GM.Config.PocketBlacklist["bp_chemical_prop_acid"] = true
		GM.Config.PocketBlacklist["bp_chemical_sali_acid"] = true
		GM.Config.PocketBlacklist["bp_chemical_sele"] = true
		GM.Config.PocketBlacklist["bp_chemical_sali_acid"] = true
		GM.Config.PocketBlacklist["bp_beaker"] = true
		GM.Config.PocketBlacklist["bp_freezer"] = true
		GM.Config.PocketBlacklist["bp_pill_bottle"] = true
		GM.Config.PocketBlacklist["bp_pill_press"] = true
		GM.Config.PocketBlacklist["bp_bunsen_burner"] = true
	end
end)

local PLY = FindMetaTable("Player")

function PLY:BPAddOverdose(amount)
	self.BPOverdose = self.BPOverdose + amount

	if self.BPOverdose >= 100 then
		self:Kill()
		self:ChatPrint("[BP] "..BLUES_PHARMA.TRANS.Overdosed)
		self.BPOverdoseWarning = false
		self.BPOverdose = 0
		return
	end

	if self.BPOverdose >= 75 and self.BPOverdoseWarning == false then
		self.BPOverdoseWarning = true
		self:ChatPrint("[BP] "..BLUES_PHARMA.TRANS.OverdoseWarning)
	end
end

--Add resistane
function PLY:BPAddDamageResistance(amount, time)
	if self.BPMedicalBuffs.damageResistance.amount > amount then
		return
	end

	--Update time to new time
	self.BPMedicalBuffs.damageResistance.timeLeft = CurTime() + time
	self.BPMedicalBuffs.damageResistance.amount = amount
	self.BPMedicalBuffs.damageResistance.isActive = true

	self:ChatPrint(BLUES_PHARMA.TRANS.DamageResistanceStart)
end

--Add buff
function PLY:BPAddDamageBuff(amount, time)
	if self.BPMedicalBuffs.damageBuff.amount > amount then
		return
	end

	--Update time to new time
	self.BPMedicalBuffs.damageBuff.timeLeft = CurTime() + time
	self.BPMedicalBuffs.damageBuff.amount = amount
	self.BPMedicalBuffs.damageBuff.isActive = true

	self:ChatPrint(BLUES_PHARMA.TRANS.DamageBuffStart)
end

--Add passive healing
function PLY:BPAddPassiveHealth(amount, timeBetweenTick, time)
	if self.BPMedicalBuffs.passiveHealing.amount > amount then
		return
	end

	--Update time to new time
	self.BPMedicalBuffs.passiveHealing.timeLeft = CurTime() + time
	self.BPMedicalBuffs.passiveHealing.timeBetweenTick = timeBetweenTick
	self.BPMedicalBuffs.passiveHealing.amount = amount
	self.BPMedicalBuffs.passiveHealing.isActive = true

	self:ChatPrint(BLUES_PHARMA.TRANS.PassiveStart)
end

--Adds a speed and jump boost to it
function PLY:BPAddSpeedJumpBoost(amount, time)
	if self.BPMedicalBuffs.speedJumpBoost.amount > amount then
		return 
	end
	local mul = 1 + (amount / 100)
	--store new values only if we have not already
	if not self.BPMedicalBuffs.speedJumpBoost.isActive then
		local startRunSpeed = self:GetRunSpeed()
		local startWalkSpeed = self:GetWalkSpeed()
		local startJumpHeight = self:GetJumpPower()

		--Set new values
		self:SetWalkSpeed(self:GetWalkSpeed() * mul)
		self:SetRunSpeed(self:GetRunSpeed() * mul)
		self:SetJumpPower(self:GetJumpPower() * mul)

		--Get the difference
		self.BPMedicalBuffs.speedJumpBoost.startRunSpeed = self:GetRunSpeed() - startRunSpeed
		self.BPMedicalBuffs.speedJumpBoost.startWalkSpeed = self:GetWalkSpeed() - startWalkSpeed
		self.BPMedicalBuffs.speedJumpBoost.startJumpHeight = self:GetJumpPower() - startJumpHeight
	else
		--Get there current jump speed, revert it then add onto it
		self:SetWalkSpeed((self:GetWalkSpeed() - self.BPMedicalBuffs.speedJumpBoost.startWalkSpeed) * mul)
		self:SetRunSpeed((self:GetRunSpeed() - self.BPMedicalBuffs.speedJumpBoost.startRunSpeed) * mul)
		self:SetJumpPower((self:GetJumpPower() - self.BPMedicalBuffs.speedJumpBoost.startJumpHeight) * mul)		
	end

	self.BPMedicalBuffs.speedJumpBoost.isActive = true
	self.BPMedicalBuffs.speedJumpBoost.timeLeft = CurTime() + time
	self.BPMedicalBuffs.speedJumpBoost.amount = amount

	self:ChatPrint(BLUES_PHARMA.TRANS.SpeedJumpStart)
end
 
--Doubles the remaining time for each medication buff active
function PLY:BPDoubleRemainingTime()
	for k, v in pairs(self.BPMedicalBuffs) do
		if not v.cortUsed then
			if v.isActive then
				--Double time remaining
				local timeReamining = (v.timeLeft - CurTime()) * 2
				self.BPMedicalBuffs[k].timeLeft = CurTime() + timeReamining
				self.BPMedicalBuffs[k].cortUsed = true
			end
		end
	end

	self:ChatPrint(BLUES_PHARMA.TRANS.DoubleTime)
end

--Buff system
hook.Add("EntityTakeDamage", "BLUES_PHARMA:BUFF:Damage", function(ply, dmgInfo)
	--Check if taker is a player
	if ply:IsPlayer() then
		if ply.BPMedicalBuffs.damageResistance.isActive and 
			CurTime() < ply.BPMedicalBuffs.damageResistance.timeLeft then
			dmgInfo:ScaleDamage(1 - (ply.BPMedicalBuffs.damageResistance.amount/100))
		end

		--Check if attacker has damage boost
		if dmgInfo:GetAttacker():IsPlayer() then
			local att =  dmgInfo:GetAttacker()
			if att.BPMedicalBuffs.damageBuff.isActive and
				CurTime() < att.BPMedicalBuffs.damageBuff.timeLeft then
				dmgInfo:ScaleDamage(1 + (ply.BPMedicalBuffs.damageBuff.amount/100))
			end
		end
	end
end)

--Check every second
local PHTime = 0
hook.Add("Think", "BLUES_PHARMA:BUFF:PassiveHealing", function()
	if CurTime() >= PHTime then
		PHTime = CurTime() + 4
		for k, v in pairs(player.GetAll()) do
			if v.BPMedicalBuffs.passiveHealing.isActive then
				if CurTime() < v.BPMedicalBuffs.passiveHealing.timeLeft then
					if CurTime() >= v.BPMedicalBuffs.passiveHealing.nextTick then
						v.BPMedicalBuffs.passiveHealing.nextTick = CurTime() + v.BPMedicalBuffs.passiveHealing.timeBetweenTick
						v:SetHealth(math.Clamp(v:Health() + v.BPMedicalBuffs.passiveHealing.amount, 0, v:GetMaxHealth()))
					end
				else
					v.BPMedicalBuffs.passiveHealing.isActive = false
					v.BPMedicalBuffs.passiveHealing.amount = 0
					v.BPMedicalBuffs.passiveHealing.cortUsed = false
					v:ChatPrint(BLUES_PHARMA.TRANS.PassiveHealing)
				end
			end

			--Check there > speed/jump boost
			if v.BPMedicalBuffs.speedJumpBoost.isActive and CurTime() > v.BPMedicalBuffs.speedJumpBoost.timeLeft then
				--Restore it all back
				v.BPMedicalBuffs.speedJumpBoost.isActive = false
				v.BPMedicalBuffs.speedJumpBoost.cortUsed = false
				v.BPMedicalBuffs.speedJumpBoost.amount = 0
				v:SetRunSpeed(v:GetRunSpeed() - v.BPMedicalBuffs.speedJumpBoost.startRunSpeed)
				v:SetWalkSpeed(v:GetWalkSpeed() - v.BPMedicalBuffs.speedJumpBoost.startWalkSpeed)
				v:SetJumpPower(v:GetJumpPower() - v.BPMedicalBuffs.speedJumpBoost.startJumpHeight)
				v:ChatPrint(BLUES_PHARMA.TRANS.SpeedJumpExpired )
			end

			if v.BPMedicalBuffs.damageBuff.isActive and CurTime() > v.BPMedicalBuffs.damageBuff.timeLeft then
				--Check for expire
				v.BPMedicalBuffs.damageBuff.isActive = false
				v.BPMedicalBuffs.damageBuff.cortUsed = false
				v.BPMedicalBuffs.damageBuff.amount = 0
				v:ChatPrint(BLUES_PHARMA.TRANS.DamageBuffExpire)
			end

			if v.BPMedicalBuffs.damageResistance.isActive and CurTime() > v.BPMedicalBuffs.damageResistance.timeLeft then
				--Check for expire
				v.BPMedicalBuffs.damageResistance.isActive = false
				v.BPMedicalBuffs.damageResistance.cortUsed = false
				v.BPMedicalBuffs.damageResistance.amount = 0
				v:ChatPrint(BLUES_PHARMA.TRANS.DamageResistanceExpire)
			end

			v.BPOverdose = math.Clamp(v.BPOverdose - BLUES_PHARMA.CONFIG.OverdoseCooldownRate, 0, 100)
			if v.BPOverdoseWarning and v.BPOverdose <= 25 then
				v.BPOverdoseWarning = false
				v:ChatPrint("[BP] "..BLUES_PHARMA.TRANS.FeelingBetter)
			end
		end
	end
end)

local function SavePillSellers()
	local sellers = ents.FindByClass("bp_pill_market")
	local data = {}
	if sellers ~= nil and table.Count(sellers) > 0 then
		for k ,v in pairs(sellers) do
			local entry = {}
			entry.position = v:GetPos()
			entry.angle = v:GetAngles()
			table.insert(data , entry)
		end
		file.Write("blues_pharma_data.txt",util.TableToJSON(data))
	else
		file.Write("blues_pharma_data.txt","[]")
	end
end

local function LoadPillSellers()
	local data = file.Read( "blues_pharma_data.txt", "DATA" ) 
	if data ~= nil then
		data = util.JSONToTable(data)
		for k ,v in pairs(data) do
			local e = ents.Create("bp_pill_market")
			e:SetPos(v.position)
			e:SetAngles(v.angle)
			e:Spawn()
		end
	end
end

hook.Add( "InitPostEntity", "BLUES_PHARMA:LoadSellers", function()
	LoadPillSellers()
end )

hook.Add("PlayerSay", "BLUES_PHARMA:SaveSellers" , function(sender , text)
	if string.lower(string.sub(text , 1 , 16)) == "!savepillsellers" then
		if table.HasValue(BLUES_PHARMA.CONFIG.AuthorisedRanks, sender:GetUserGroup()) then
			SavePillSellers()
			sender:ChatPrint("[BP] Saving all Pill Seller NPC's on the map!")
		else
			sender:ChatPrint("[BP] You do not have permission to do this, if you think this is a mistake contact the dev/owner")
		end
	end
end)



--Assume they want to deselect
net.Receive("BLUES_PHARMA_SELECT", function(len, ply)
	if ply.BPSelectedChemical then
		ply.BPSelectedChemical.playerWhoSelected = nil
		ply.BPSelectedChemical = nil
	end
end)

--A player has requested the contents of the beaker
net.Receive("BLUES_PHARMA_BEAKER_CONTENTS_ALL", function(len, ply)
	local id = ply:UserID()

	if BLUES_PHARMA.NetworkedPlayers[id] == nil then
		BLUES_PHARMA:NetworkNewClient(ply)
		BLUES_PHARMA.NetworkedPlayers[id] = true
	end
end)


net.Receive("BLUES_PHARMA_POUR", function(len, ply)
	if ply.BPIsPouring then
		local amount = net.ReadFloat() or 0

		--Convert to correct units
		amount = math.Round(math.Clamp(350 - ((amount * 250) + 50), 50 , 300) / 50) * 50

		--Get the chemical and the and the beaker
		local beaker = ply.BPPouringBeaker
		local chemical = ply.BPSelectedChemical 

		--Sanity checks
		if not IsValid(beaker) then return end
		if not IsValid(chemical) then return end

		if chemical:GetLiquidAmount() < amount then
			ply:ChatPrint("[BP] "..BLUES_PHARMA.TRANS.NotEnoughtLiquid )
			ply.BPSelectedChemical.playerWhoSelected = nil
			ply.BPSelectedChemical = nil
			return
		end

		if beaker:GetLiquidAmount() + amount > 500 then
			ply:ChatPrint("[BP] "..BLUES_PHARMA.TRANS.BeakerIsFull )
			ply.BPSelectedChemical.playerWhoSelected = nil
			ply.BPSelectedChemical = nil
			return
		end

		if beaker:GetBeakerState() ~= beaker.States.CREATING then return end

		chemical:SetLiquidAmount(chemical:GetLiquidAmount() - amount)

		--Play sound
		beaker:EmitSound("blues_pharm/pour_"..math.random(1, 3)..".wav", 65, math.random(90, 125), 0.7)

		--Deselect this chemical and beaker
		ply.BPSelectedChemical.playerWhoSelected = nil
		ply.BPSelectedChemical = nil
		ply.BPIsPouring = false
		ply.BPPouringBeaker = nil

		--Lets pour!
		beaker:AddChemical(chemical.ChemicalID, amount)

		--Remove the empty jar :)
		if chemical:GetLiquidAmount() <= 0 then
			chemical:Remove()
		end
	end
end)

--SOUNDS
sound.Add( {
    name = "bp_burner", 
    channel = CHAN_AUTO,
    volume = 0.55,
    level = 55,
    pitch = { 95, 105 },
    sound = "blues_pharm/flame_loop.wav"
} )

sound.Add( {
    name = "bp_boiling", 
    channel = CHAN_AUTO,
    volume = 0.6,
    level = 55,
    pitch = { 95, 105 },
    sound = "blues_pharm/boiling_loop.wav"
} )