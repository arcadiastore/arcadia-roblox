--[[
    Arcadia Online - Shop Data
]]

local Shops = {}

Shops["general_shop"] = {
    id = "general_shop",
    name = "Toko Umum",
    npcId = "Merchant",
    items = {
        "hp_potion_small",
        "hp_potion_medium",
        "mp_potion_small",
    },
}

Shops["weapon_shop"] = {
    id = "weapon_shop",
    name = "Toko Senjata",
    npcId = "Blacksmith",
    items = {
        "wooden_sword",
        "iron_sword",
        "leather_armor",
    },
}

Shops["potion_shop"] = {
    id = "potion_shop",
    name = "Toko Ramuan",
    npcId = "Herbalist",
    items = {
        "hp_potion_small",
        "hp_potion_medium",
        "hp_potion_large",
        "mp_potion_small",
        "mp_potion_medium",
        "mp_potion_large",
    },
}

return Shops
