AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/blues_pharm/beaker.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
	end

	self:SetHealth(25)

	self.angleResetCooldown = 0

	self:SetLiquidAmount(0)

	--A list of all chemicals, and the amount of them in the beaker
	self.ChemicalTable = {}
	self:SetUseType(SIMPLE_USE)

	--Stores the recipe
	self.recipe = false

	--Add our ent to the table
	self.tableID = table.insert(BLUES_PHARMA.Beakers, self)

	--Set out state
	self:SetBeakerState(self.States.CREATING)

	--< 0 = no recipe
	self:SetRecipe(-1)
end

function ENT:ResetBeaker()
	self.recipe = false
	self:SetRecipe(-1)
	self:SetBeakerState(self.States.CREATING)

	--Clear chemicals
	self.ChemicalTable = {}

	--Set liquid level to 0
	self:SetLiquidAmount(0)

	net.Start("BLUES_PHARMA_BEAKER_CONTENTS")
	net.WriteEntity(self)
	net.WriteTable(self.ChemicalTable)
	net.Broadcast()

	--Set material back to liquid state
	timer.Simple(3, function()
		if IsValid(self) then
			net.Start("BLUES_PHARMA_UPDATE_MAT")
			net.WriteBool(false)
			net.WriteEntity(self)
			net.Broadcast()
		end
	end)
end

--Ruins a batch
function ENT:BurnLiquid()
	self.ChemicalTable = {[11] = 500}

	--Update chemicals
	net.Start("BLUES_PHARMA_BEAKER_CONTENTS")
	net.WriteEntity(self)
	net.WriteTable(self.ChemicalTable)
	net.Broadcast()

	--Update state
	self:SetBeakerState(self.States.CREATING)
end

--Adds a chemical to the list and recalculate the liquid amount and color
function ENT:AddChemical(chemicalID, amount)
	if self.recipe ~= false then return end

	if self.ChemicalTable[chemicalID] ~= nil then
		self.ChemicalTable[chemicalID] = self.ChemicalTable[chemicalID] + amount
	else
		self.ChemicalTable[chemicalID] = amount
	end

	--Calculate liquid amount
	local total = 0
	for k, v in pairs(self.ChemicalTable) do
		total = total + v
	end

	--Set the liquid amount so it updates visually on the client
	self:SetLiquidAmount(total)

	--Network the new chemicals
	net.Start("BLUES_PHARMA_BEAKER_CONTENTS")
	net.WriteEntity(self)
	net.WriteTable(self.ChemicalTable)
	net.Broadcast()
 
	--Lets see if we made a recipe
	self.recipe = BLUES_PHARMA:CheckRecipie(self)

	--Update our state
	if self.recipe ~= false then
		self:SetBeakerState(self.States.WAITING_FOR_MIX_AND_BURN)
		self:SetRecipe(self.recipe)
	end	
end

function ENT:Use(act, caller)
	--Shift + E = Upright
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y + 180,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	elseif caller:KeyDown(IN_WALK) then
		if self:GetBeakerState() == self.States.CREATING then
			self:ResetBeaker()
		end
	else
		if caller.BPSelectedChemical ~= nil then
			caller.BPIsPouring = true
			caller.BPPouringBeaker = self
			BLUES_PHARMA:GetPourAmount(caller)
		end 
	end
end

function ENT:OnRemove()
	BLUES_PHARMA.Beakers[self.tableID] = nil
end