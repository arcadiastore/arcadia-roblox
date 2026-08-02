--[[
    Arcadia Online - Job Data
    Sesuai GDD 06_Jobs.md
    
    Setiap job punya:
    - Base stats modifier (tambahan di atas base player)
    - Stat growth per level
    - Equipment restrictions
    - Description
]]

local Jobs = {}

Jobs["Warrior"] = {
    id = "Warrior",
    name = "Warrior",
    description = "Petarung jarak dekat dengan HP dan DEF tinggi. Ahli pedang, kapak, dan palu.",
    role = "Tank / Melee DPS",
    
    -- Base stat modifiers (ditambahkan ke base stats)
    stats = {
        hp = 50,      -- +50 HP
        mp = 0,
        atk = 5,      -- +5 ATK
        def = 8,      -- +8 DEF
        matk = 0,
        mdef = 2,
        spd = -2,     -- -2 SPD (lambat)
        luk = 0,
    },
    
    -- Stat growth per level
    growth = {
        hp = 15,      -- +15 HP per level
        mp = 2,       -- +2 MP per level
        atk = 3,      -- +3 ATK per level
        def = 3,      -- +3 DEF per level
        matk = 0,
        mdef = 1,
        spd = 0,
        luk = 1,
    },
    
    -- Equipment restrictions
    weapons = {"Sword", "Axe", "Hammer"},
    armor = {"Heavy", "Medium"},
    
    -- Color for UI
    color = Color3.fromRGB(220, 50, 50),
    
    -- Icon (emoji for text UI)
    icon = "[W]",
}

Jobs["Mage"] = {
    id = "Mage",
    name = "Mage",
    description = "Penyihir jarak jauh dengan MATK tinggi. Ahli sihir elemental dan support.",
    role = "Ranged Magic DPS / Support",
    
    stats = {
        hp = -20,     -- -20 HP (rapuh)
        mp = 50,      -- +50 MP
        atk = 0,
        def = -3,     -- -3 DEF (rapuh)
        matk = 10,    -- +10 MATK
        mdef = 5,     -- +5 MDEF
        spd = 3,      -- +3 SPD
        luk = 2,
    },
    
    growth = {
        hp = 5,       -- +5 HP per level (rendah)
        mp = 10,      -- +10 MP per level (tinggi)
        atk = 0,
        def = 1,
        matk = 4,     -- +4 MATK per level
        mdef = 2,
        spd = 1,
        luk = 1,
    },
    
    weapons = {"Staff", "Wand", "Orb"},
    armor = {"Cloth"},
    
    color = Color3.fromRGB(50, 100, 220),
    icon = "[M]",
}

Jobs["Archer"] = {
    id = "Archer",
    name = "Archer",
    description = "Pemanah jarak jauh dengan SPD tinggi. Ahli busur, panah, dan belati.",
    role = "Ranged Physical DPS",
    
    stats = {
        hp = 10,
        mp = 10,
        atk = 3,      -- +3 ATK
        def = 0,
        matk = 0,
        mdef = 2,
        spd = 8,      -- +8 SPD (cepat)
        luk = 5,      -- +5 LUK (beruntung)
    },
    
    growth = {
        hp = 8,
        mp = 5,
        atk = 3,
        def = 1,
        matk = 0,
        mdef = 1,
        spd = 2,      -- +2 SPD per level
        luk = 2,      -- +2 LUK per level
    },
    
    weapons = {"Bow", "Crossbow", "Dagger"},
    armor = {"Light", "Medium"},
    
    color = Color3.fromRGB(50, 180, 50),
    icon = "[A]",
}

-- Get all jobs as list (for UI)
function Jobs:GetAll()
    local list = {}
    for id, job in pairs(self) do
        if type(job) == "table" and job.id then
            table.insert(list, job)
        end
    end
    -- Sort by name
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

-- Get job by ID
function Jobs:Get(id)
    return self[id]
end

return Jobs
