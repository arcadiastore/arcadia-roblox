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
        "job_change_ticket",
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

return Shops
