if SERVER then
    AddCSLuaFile("blues_pharm_translation.lua")
end

include("blues_pharm_translation.lua")

BLUES_PHARMA = BLUES_PHARMA or {}



--A list of all chemical types. An entity can set ChemicalID on it to be considered a chemical
BLUES_PHARMA.Chemicals = {
    [1] = {name = "Keto Acid", color = Color(220,20,60)},
    [2] = {name = "Salicylic Acid", color = Color(95,158,160)},
    [3] = {name = "Propionic Acid", color = Color(154,205,50)},
    [4] = {name = "Acetic Anhydride", color = Color(46,139,87)},
    [5] = {name = "Selenium Dioxide", color = Color(218,165,32)},
    [6] = {name = "2-Napththol", color = Color(30,144,255)},
    [7] = {name = "Methyltestosterone", color = Color(173,255,47)},
    [8] = {name = "Acetone", color = Color(210,105,30)},
    [9] = {name = "Progestorone", color = Color(255,99,71)},
    [10] = {name = "Deionized Water", color = Color(135,206,235)},
    [11] = {name = BLUES_PHARMA.TRANS.BurnedChemicals, color = Color(20,20,20)},
    [12] = {name = "Juul" , abrv = "Supreme" , color = Color(238,232,170)}
} 

BLUES_PHARMA.Medicines = {
    [1] = {
        name = "Aspirin", 
        cookTime = 60, -- Number of seconds it takes to finish cooking
        freezeTime = 60 * 2, --Number of seconds it takes to freeze
        mixIncrement = 5, --The amount to add to the mix value (between 0-100) each mix tick
        overdoseRate = 10, --This is how much it adds to the "overdose" var which has a max of 1 and decreases over time
        pillCount = 5, --This is how many uses a single bottle has
        recipe = {
            [2] = 150, --150ML Salicylic acid
            [4] = 300, --300ml of Acetic anhydride
            [10] = 50 --Water
        },
        onConsumed = function(self, user) --Called when someone eats/takes this medicine. 
            user:BPAddDamageResistance(15, 60)
        end
    },
    [2] = {
        name = "Ibuprofen", 
        cookTime = 90, -- Number of seconds it takes to finish cooking
        freezeTime = 60 * 2.5, --Number of seconds it takes to freeze
        mixIncrement = 6, --The amount to add to the mix value (between 0-100) each mix tick
        overdoseRate = 20, --This is how much it adds to the "overdoes" var which has a max of 1 and decreases over time
        pillCount = 4, --This is how many uses a single bottle has
        recipe = {
            [3] = 150,
            [4] = 300, 
            [10] = 50
        },
        onConsumed = function(self, user) --Called when someone eats/takes this medicine. 
            user:BPAddDamageResistance(40, 40)
        end
    },
    [3] = {
        name = "Naproxen", 
        cookTime = 75, -- Number of seconds it takes to finish cooking
        freezeTime = 60 * 3, --Number of seconds it takes to freeze
        mixIncrement = 7, --The amount to add to the mix value (between 0-100) each mix tick
        overdoseRate = 35, --This is how much it adds to the "overdoes" var which has a max of 1 and decreases over time
        pillCount = 4, --This is how many uses a single bottle has
        recipe = {
            [6] = 250,
            [4] = 150, 
            [10] = 100
        },
        onConsumed = function(self, user) --Called when someone eats/takes this medicine. 
            user:BPAddPassiveHealth(10, 4, 40)
        end
    },
    [4] = {
        name = "Steroids", 
        cookTime = 60 * 2, -- Number of seconds it takes to finish cooking
        freezeTime = 60 * 3, --Number of seconds it takes to freeze
        mixIncrement = 12, --The amount to add to the mix value (between 0-100) each mix tick
        overdoseRate = 35, --This is how much it adds to the "overdoes" var which has a max of 1 and decreases over time
        pillCount = 5, --This is how many uses a single bottle has
        recipe = {
            [7] = 100,
            [5] = 300, 
            [10] = 100
        },
        onConsumed = function(self, user) --Called when someone eats/takes this medicine. 
            user:BPAddDamageBuff(20, 20)
        end
    },
    [5] = {
        name = "Vitamins", 
        cookTime = 120, -- Number of seconds it takes to finish cooking
        freezeTime = 60 * 4, --Number of seconds it takes to freeze
        mixIncrement = 3, --The amount to add to the mix value (between 0-100) each mix tick
        overdoseRate = 10, --This is how much it adds to the "overdoes" var which has a max of 1 and decreases over time
        pillCount = 10, --This is how many uses a single bottle has
        recipe = {
            [1] = 150,
            [8] = 200, 
            [10] = 150
        },
        onConsumed = function(self, user) --Called when someone eats/takes this medicine. 
            user:BPAddDamageBuff(10, 60)
            user:BPAddDamageResistance(10, 60)
            user:BPAddPassiveHealth(4, 4, 20)
            user:BPAddSpeedJumpBoost(10, 60)

        end
    },
    [6] = {
        name = "Corticosteroid", 
        cookTime = 60 * 3, -- Number of seconds it takes to finish cooking
        freezeTime = 60 * 4, --Number of seconds it takes to freeze
        mixIncrement = 4, --The amount to add to the mix value (between 0-100) each mix tick
        overdoseRate = 44, --This is how much it adds to the "overdoes" var which has a max of 1 and decreases over time
        pillCount = 4, --This is how many uses a single bottle has
        recipe = {
            [4] = 200,
            [9] = 200, 
            [10] = 100
        },
        onConsumed = function(self, user) --Called when someone eats/takes this medicine. 
            user:BPDoubleRemainingTime()
        end
    },
    [7] = {
        name = "Dianabol", 
        cookTime = 60 * 2, -- Number of seconds it takes to finish cooking
        freezeTime = 60 * 3, --Number of seconds it takes to freeze
        mixIncrement = 6, --The amount to add to the mix value (between 0-100) each mix tick
        overdoseRate = 10, --This is how much it adds to the "overdoes" var which has a max of 1 and decreases over time
        pillCount = 10, --This is how many uses a single bottle has
        recipe = {
            [7] = 200,
            [1] = 150, 
            [10] = 150
        },
        onConsumed = function(self, user) --Called when someone eats/takes this medicine. 
            user:BPAddSpeedJumpBoost(30, 120)
        end
    },
    [8] = {
        name = "Anadrol", 
        cookTime = 60 * 2, -- Number of seconds it takes to finish cooking
        freezeTime = 60 * 4, --Number of seconds it takes to freeze
        mixIncrement = 6, --The amount to add to the mix value (between 0-100) each mix tick
        overdoseRate = 70, --This is how much it adds to the "overdoes" var which has a max of 1 and decreases over time
        pillCount = 2, --This is how many uses a single bottle has
        recipe = {
            [7] = 300,
            [9] = 100, 
            [10] = 100
        },
        onConsumed = function(self, user) --Called when someone eats/takes this medicine. 
            user:BPAddDamageBuff(50, 40)
        end
    }
}
  
BLUES_PHARMA.Pages = {
    [1] = {
        type = "header",
        title = [[
        Blue's 
Pharmaceuticals]],
        contents = BLUES_PHARMA.TRANS.BOOK.MiniTutorial1,
        contentsRight = BLUES_PHARMA.TRANS.BOOK.MiniTutorial2..[[


This book is dedicated to the following people.

        -Bear AKA bonehit
        -Golden 'The robot' Robo
        -J.P Studios
        -Opium Aryan
        -Trillex]]
    },
    --healers 
    [2] = {
       type = "recipe",
       recipeID = 1, 
       desc = [[Aspirin, also known as acetylsalicylic acid, is a medication used to treat pain, fever, or inflammation. Specific inflammatory conditions which aspirin is used to treat include Kawasaki disease, pericarditis, and rheumatic fever. Aspirin given shortly after a heart attack decreases the risk of death.]],
       effects = [[Grants the user a mild (15%) increase in damage resistance for around 1 minute. The effects of this medication do not stack and attempts to do so risk overdosing.]],
    },
    [3] = {
       type = "recipe",
       recipeID = 2, 
       desc = [[Ibuprofen is a medication in the nonsteroidal anti-inflammatory drug class that is used for treating pain, fever, and inflammation. This includes painful menstrual periods, migraines, and rheumatoid arthritis. It may also be used to close a patent ductus arteriosus in a premature baby.]],
       effects = [[Gives the user a moderate (40%) increase in damage resistance for around 40 seconds. The effects of this medication do not stack and attempts to do so risk overdosing.]],
    },
    [4] = {
       type = "recipe",
       recipeID = 3, 
       desc = [[Naproxen, sold under the brand names Aleve and Naprosyn among others, is a nonsteroidal anti-inflammatory drug used to treat pain, menstrual cramps, inflammatory diseases such as rheumatoid arthritis, and fever. It is taken by mouth. It is available in immediate and delayed release formulations.]],
       effects = [[Mildly heals the user (+10 hp every 4 seconds) for 80 seconds resulting in 100hp being healed. The effects of this medication do not stack and attempts to do so risk overdosing.]],
    },

    --Buffs
    [5] = {
       type = "recipe",
       recipeID = 4, 
       desc = [[A steroid is a biologically active organic compound with four rings arranged in a specific molecular configuration. Steroids have two principal biological functions: as important components of cell membranes which alter membrane fluidity; and as signaling molecules.]],
       effects = [[Gives the user a mild (20%) buff to damage for around a minute. The effects of this medication do not stack and attempts to do so risk overdosing.]],
    },
    [6] = {
       type = "recipe",
       recipeID = 5, 
       desc = [[A vitamin is an organic molecule that is an essential micronutrient that an organism needs in small quantities for the proper functioning of its metabolism. Essential nutrients cannot be synthesized in the organism, either at all or not in sufficient quantities, and therefore must be obtained through the diet.]],
       effects = [[Gives the user mild healing (4 hp per 4 seconds) for 20 seconds, and a mild (10%) increase to things such as: Movement speed, jump height, damage and damage resistance for around a minute. The effects of this medication do not stack and attempts to do so risk overdosing.]],
    },
    [7] = {
       type = "recipe",
       recipeID = 6, 
       desc = [[Corticosteroids are man-made drugs that closely resemble cortisol, a hormone that your adrenal glands produce naturally. Corticosteroids are often referred to by the shortened term "steroids." Corticosteroids are different from the male hormone-related steroid compounds that some athletes abuse.]],
       effects = [[Amplifies the duration of currently active healing and damage resistance effects by double the time left remaining. The effects of this medication do not stack and attempts to do so risk overdosing.]],
    },
    [8] = {
        type = "recipe",
        recipeID = 7,
        desc = [[Metandienone, also known as methandienone or methandrostenolone and sold under the brand name Dianabol among others, is an androgen and anabolic steroid medication which is mostly no longer used. It is also used non-medically for physique- and performance-enhancing purposes. It is taken by mouth.]],
        effects = [[Grants a moderate (30%) increase to the users movement speed and jump height for around 2 minutes. The effects of this medication do not stack and attempts to do so risk overdosing.]],
    },
    [9] = {
        type = "recipe",
        recipeID = 8,
        desc = [[Oxymetholone, sold under the brand names Anadrol and Anapolon among others, is an androgen and anabolic steroid medication which is used primarily in the treatment of anemia. It is also used to treat osteoporosis, HIV/AIDS wasting syndrome, and to promote weight gain and muscle growth in certain situations.]],
        effects = [[Grants a large (50%) buff to damage for around 40 seconds. The effects of this medication do not stack and attempts to do so risk overdosing.]],
    }
}