--NOTE: Don't use permaprop for the NPC's, use !savepillsellers instead.
BLUES_PHARMA = BLUES_PHARMA or {}
BLUES_PHARMA.CONFIG = {}

--This is how fast the "overdose" value goes down. This is per seconds (0 - 100)
--Default: 0.5 = Aprox 3 minutes from full overdose
BLUES_PHARMA.CONFIG.OverdoseCooldownRate = 2

--These are the ranks that have permission to do !savepillsellers
BLUES_PHARMA.CONFIG.AuthorisedRanks = {
	"owner",
	"superadmin"
}

--These are the prices of each full pill bottle sold at the pill market.
BLUES_PHARMA.CONFIG.SellPrices = {
	[1] = 3000, -- Aspirin
	[2] = 3500, -- Ibuprofen
	[3] = 4000, -- Naproxen
	[4] = 3500, -- Steroid
	[5] = 2150, -- Vitamin
	[6] = 4500, -- Corticosteroid
	[7] = 4000, -- Dianabol
	[8] = 6000 -- Anadrol
}  

--Set this to false if you don't wnat them to be able to eat the pills and get buffs
BLUES_PHARMA.CONFIG.CanConsumePills = true

--INFO: If you want to change more specific things about the recipes and there buff, do so in autorun/sh_blues_pharmaceuticals

--This is the maximum distance to render Cam3D2D UI at. This is Squared (Don't change it if you don't know what this means).
BLUES_PHARMA.CONFIG.Cam3D2DRenderDist = 400000  

--Change these functions if you are using a custom gamemode that isn't darkrp
BLUES_PHARMA.CONFIG.AddMoney = function(user, amount)
	user:addMoney(amount)
end

--Add entities are below here. Remove this if you want to do it manually
hook.Add("loadCustomDarkRPItems", "BLUES_PHARMA:RegisterEntities", function()
DarkRP.createCategory{
		name = "Blue's Pharmaceuticals",
		categorises = "entities",
		startExpanded = true,
		color = Color(120, 170, 255, 255),
		sortOrder = 2,
	}

	DarkRP.createEntity("Guide Book", {
		ent = "bp_guide_book",
		model = "models/blues_pharm/book.mdl",
		price = 250,
		max = 1,
		cmd = "bpbuyguide",
		category = "Blue's Pharmaceuticals"
	}) 

	--Six is the max amount in a single freezer, so match this to the number of freezers allowed
	DarkRP.createEntity("Beaker", {
		ent = "bp_beaker",
		model = "models/blues_pharm/beaker.mdl",
		price = 500,
		max = 6,
		cmd = "bpbuybeaker",
		category = "Blue's Pharmaceuticals"
	}) 

	DarkRP.createEntity("Bunsen Burner", {
		ent = "bp_bunsen_burner",
		model = "models/blues_pharm/bunsen_burner.mdl",
		price = 5000,
		max = 4,
		cmd = "bpbuybunsenburner",
		category = "Blue's Pharmaceuticals"
	}) 

	DarkRP.createEntity("Freezer", {
		ent = "bp_freezer",
		model = "models/blues_pharm/freezer.mdl",
		price = 20000,
		max = 1,
		cmd = "bpbuyfreezer",
		category = "Blue's Pharmaceuticals"
	}) 

	DarkRP.createEntity("Pill Press", {
		ent = "bp_pill_press",
		model = "models/blues_pharm/pill_presser.mdl",
		price = 8000,
		max = 2,
		cmd = "bpbuypillpress",
		category = "Blue's Pharmaceuticals"
	})

	--Chemicals below
	DarkRP.createEntity("Keto Acid", {
		ent = "bp_chemical_keto_acid",
		model = "models/blues_pharm/jar_1.mdl",
		price = 750,
		max = 2,
		cmd = "bpbuyketoacid",
		category = "Blue's Pharmaceuticals"
	})

	DarkRP.createEntity("Propionic Acid", {
		ent = "bp_chemical_prop_acid",
		model = "models/blues_pharm/jar_2.mdl",
		price = 750,
		max = 2,
		cmd = "bpbuypropacid",
		category = "Blue's Pharmaceuticals"
	})
	
	DarkRP.createEntity("Salicylic Acid", {
		ent = "bp_chemical_sali_acid",
		model = "models/blues_pharm/jar_2.mdl",
		price = 500,
		max = 2,
		cmd = "bpbuysaliacid",
		category = "Blue's Pharmaceuticals"
	})

	DarkRP.createEntity("Methyltestosterone", {
		ent = "bp_chemical_17alph",
		model = "models/blues_pharm/jar_3.mdl",
		price = 2000,
		max = 2,
		cmd = "bpbuymeth",
		category = "Blue's Pharmaceuticals"
	})

	DarkRP.createEntity("2-Napththol", {
		ent = "bp_chemical_2nap",
		model = "models/blues_pharm/jar_3.mdl",
		price = 1250,
		max = 2,
		cmd = "bpbuynapth",
		category = "Blue's Pharmaceuticals"
	})

	DarkRP.createEntity("Progestorone", {
		ent = "bp_chemical_prog",
		model = "models/blues_pharm/jar_3.mdl",
		price = 3000,
		max = 2,
		cmd = "bpbuyprog",
		category = "Blue's Pharmaceuticals"
	})

	DarkRP.createEntity("Acetone", {
		ent = "bp_chemical_acet2",
		model = "models/blues_pharm/jar_3.mdl",
		price = 750,
		max = 2,
		cmd = "bpbuyacet",
		category = "Blue's Pharmaceuticals"
	})

	DarkRP.createEntity("Acetic Anhydride", {
		ent = "bp_chemical_acet",
		model = "models/blues_pharm/jar_4.mdl",
		price = 1000,
		max = 2,
		cmd = "bpbuyacet2",
		category = "Blue's Pharmaceuticals"
	})

	DarkRP.createEntity("Selenium Dioxide", {
		ent = "bp_chemical_sele",
		model = "models/blues_pharm/jar_4.mdl",
		price = 2000,
		max = 2,
		cmd = "bpbuysele",
		category = "Blue's Pharmaceuticals"
	})

	DarkRP.createEntity("Deionized Water", {
		ent = "bp_chemical_deio",
		model = "models/blues_pharm/jar_5.mdl",
		price = 500,
		max = 2,
		cmd = "bpbuywater",
		category = "Blue's Pharmaceuticals"
	})
end)