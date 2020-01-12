ITEM.Name = "Pills"
ITEM.Description = "Nig"
ITEM.Model = "models/blues_pharm/pill_bottle.mdl"
ITEM.Stackable = false
ITEM.DropStack = false
ITEM.Base = "base_darkrp"

-- Because all of you feel the need to fuck with your shipments on a daily basis.
function ITEM:GetName()
	if not self:GetData("RecipeID") then return end
	return "Pills ("..BLUES_PHARMA.Medicines[self:GetData("RecipeID")].name..")"
end

function ITEM:GetDescription()
	if not self:GetData("RecipeID") then return end
	return BLUES_PHARMA.Medicines[self:GetData("RecipeID")].name.."\n\n"..self:GetData("UsesLeft").." Pills Left.\n\n"..BLUES_PHARMA.Pages[self:GetData("RecipeID") + 1].effects
end

function ITEM:CanPickup( pl, ent )
	return true
end

function ITEM:CanMerge( item )
	return false
end
 
function ITEM:SaveData( ent )
	self:SetData("UsesLeft", ent:GetUsesLeft())
	self:SetData("RecipeID", ent:GetRecipeID())
end

function ITEM:LoadData( ent )
	ent:SetUsesLeft(self:GetData("UsesLeft"))
	ent:SetRecipeID(self:GetData("RecipeID"))
end

function ITEM:Use( pl )
	if not self:GetData("RecipeID") then return end
	if not BLUES_PHARMA.CONFIG.CanConsumePills  then return end

	local uses = self:GetData("UsesLeft")
	uses = uses - 1
	self:SetData("UsesLeft", uses)

	self.Description = BLUES_PHARMA.Medicines[self:GetData("RecipeID")].name.."\n\n"..self:GetData("UsesLeft").." Pills Left.\n\n"

	--Call use func
	local useFunc = BLUES_PHARMA.Medicines[self:GetData("RecipeID")].onConsumed
	useFunc(BLUES_PHARMA.Medicines[self:GetData("RecipeID")], pl)

	pl:BPAddOverdose(BLUES_PHARMA.Medicines[self:GetData("RecipeID")].overdoseRate)

	if uses <= 0 then
		return true
	end

	return false
end
