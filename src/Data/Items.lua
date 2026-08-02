--[[
    Arcadia Online - Item Data
    Sesuai GDD 09_Items.md
]]

local Items = {}

-- Potions
Items["hp_potion_small"] = {
    id = "hp_potion_small",
    name = "HP Potion (Small)",
    description = "Memulihkan 50 HP",
    type = "consumable",
    price = 50,
    sellPrice = 25,
    effect = {stat = "hp", value = 50},
}

Items["hp_potion_medium"] = {
    id = "hp_potion_medium",
    name = "HP Potion (Medium)",
    description = "Memulihkan 100 HP",
    type = "consumable",
    price = 100,
    sellPrice = 50,
    effect = {stat = "hp", value = 100},
}

Items["mp_potion_small"] = {
    id = "mp_potion_small",
    name = "MP Potion (Small)",
    description = "Memulihkan 30 MP",
    type = "consumable",
    price = 40,
    sellPrice = 20,
    effect = {stat = "mp", value = 30},
}

-- Materials
Items["slime_gel"] = {
    id = "slime_gel",
    name = "Slime Gel",
    description = "Lendir slime",
    type = "material",
    sellPrice = 5,
}

Items["wolf_fang"] = {
    id = "wolf_fang",
    name = "Wolf Fang",
    description = "Taring serigala",
    type = "material",
    sellPrice = 15,
}

-- Equipment
Items["wooden_sword"] = {
    id = "wooden_sword",
    name = "Wooden Sword",
    description = "Senjata kayu sederhana",
    type = "equipment",
    slot = "weapon",
    price = 100,
    sellPrice = 50,
    levelReq = 1,
    stats = {atk = 5},
}

Items["iron_sword"] = {
    id = "iron_sword",
    name = "Iron Sword",
    description = "Senjata besi",
    type = "equipment",
    slot = "weapon",
    price = 300,
    sellPrice = 150,
    levelReq = 5,
    stats = {atk = 12},
}

Items["leather_armor"] = {
    id = "leather_armor",
    name = "Leather Armor",
    description = "Armor kulit ringan",
    type = "equipment",
    slot = "body",
    price = 150,
    sellPrice = 75,
    levelReq = 1,
    stats = {def = 5},
}

return Items
