--[[
    Arcadia Online - Shop Data
    
    SEMUA data shop ada di sini!
    
    @author arcadiastore
    @version 3.0.0
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
        "mp_potion_medium",
    },
}

Shops["weapon_shop"] = {
    id = "weapon_shop",
    name = "Toko Senjata",
    npcId = "Blacksmith",
    items = {
        "wooden_sword",
        "iron_sword",
        "steel_sword",
        "wooden_staff",
        "short_bow",
    },
}

return Shops
