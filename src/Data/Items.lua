--[[
    Arcadia Online - Item Data
    
    SEMUA data item ada di sini!
    Sesuai GDD 09_Items.md
    
    @author arcadiastore
    @version 3.0.0
]]

local Items = {}

-- ============================================
-- POTIONS
-- ============================================

Items["hp_potion_small"] = {
    id = "hp_potion_small",
    name = "HP Potion (Small)",
    description = "Memulihkan 50 HP",
    type = "consumable",
    subtype = "potion",
    price = 50,
    sellPrice = 25,
    stackable = true,
    maxStack = 99,
    effect = {stat = "hp", value = 50},
}

Items["hp_potion_medium"] = {
    id = "hp_potion_medium",
    name = "HP Potion (Medium)",
    description = "Memulihkan 100 HP",
    type = "consumable",
    subtype = "potion",
    price = 100,
    sellPrice = 50,
    stackable = true,
    maxStack = 99,
    effect = {stat = "hp", value = 100},
}

Items["mp_potion_small"] = {
    id = "mp_potion_small",
    name = "MP Potion (Small)",
    description = "Memulihkan 30 MP",
    type = "consumable",
    subtype = "potion",
    price = 40,
    sellPrice = 20,
    stackable = true,
    maxStack = 99,
    effect = {stat = "mp", value = 30},
}

Items["mp_potion_medium"] = {
    id = "mp_potion_medium",
    name = "MP Potion (Medium)",
    description = "Memulihkan 60 MP",
    type = "consumable",
    subtype = "potion",
    price = 80,
    sellPrice = 40,
    stackable = true,
    maxStack = 99,
    effect = {stat = "mp", value = 60},
}

-- ============================================
-- MATERIALS (Monster Drops)
-- ============================================

Items["slime_gel"] = {
    id = "slime_gel",
    name = "Slime Gel",
    description = "Lendir slime",
    type = "material",
    subtype = "drop",
    price = 0,
    sellPrice = 5,
    stackable = true,
    maxStack = 99,
}

Items["wolf_fang"] = {
    id = "wolf_fang",
    name = "Wolf Fang",
    description = "Taring serigala",
    type = "material",
    subtype = "drop",
    price = 0,
    sellPrice = 15,
    stackable = true,
    maxStack = 99,
}

Items["boar_meat"] = {
    id = "boar_meat",
    name = "Boar Meat",
    description = "Daging babi hutan",
    type = "consumable",
    subtype = "food",
    price = 0,
    sellPrice = 20,
    stackable = true,
    maxStack = 99,
    effect = {stat = "hp", value = 80},
}

Items["boss_gem"] = {
    id = "boss_gem",
    name = "Guardian Gem",
    description = "Permata dari Guardian",
    type = "material",
    subtype = "quest_item",
    price = 0,
    sellPrice = 500,
    stackable = true,
    maxStack = 1,
}

-- ============================================
-- EQUIPMENT - WEAPONS
-- ============================================

Items["wooden_sword"] = {
    id = "wooden_sword",
    name = "Wooden Sword",
    description = "Senjata kayu sederhana",
    type = "equipment",
    subtype = "weapon",
    slot = "weapon",
    weaponType = "Sword",
    price = 100,
    sellPrice = 50,
    stackable = false,
    levelReq = 1,
    jobReq = {"Warrior", "Knight", "Berserker"},
    stats = {atk = 5},
}

Items["iron_sword"] = {
    id = "iron_sword",
    name = "Iron Sword",
    description = "Senjata besi",
    type = "equipment",
    subtype = "weapon",
    slot = "weapon",
    weaponType = "Sword",
    price = 300,
    sellPrice = 150,
    stackable = false,
    levelReq = 5,
    jobReq = {"Warrior", "Knight", "Berserker"},
    stats = {atk = 12},
}

Items["steel_sword"] = {
    id = "steel_sword",
    name = "Steel Sword",
    description = "Senjata baja",
    type = "equipment",
    subtype = "weapon",
    slot = "weapon",
    weaponType = "Sword",
    price = 600,
    sellPrice = 300,
    stackable = false,
    levelReq = 10,
    jobReq = {"Warrior", "Knight", "Berserker"},
    stats = {atk = 20},
}

Items["wooden_staff"] = {
    id = "wooden_staff",
    name = "Wooden Staff",
    description = "Tongkat kayu untuk mage",
    type = "equipment",
    subtype = "weapon",
    slot = "weapon",
    weaponType = "Staff",
    price = 100,
    sellPrice = 50,
    stackable = false,
    levelReq = 1,
    jobReq = {"Mage", "Wizard", "Cleric"},
    stats = {matk = 5},
}

Items["short_bow"] = {
    id = "short_bow",
    name = "Short Bow",
    description = "Busur pendek untuk archer",
    type = "equipment",
    subtype = "weapon",
    slot = "weapon",
    weaponType = "Bow",
    price = 100,
    sellPrice = 50,
    stackable = false,
    levelReq = 1,
    jobReq = {"Archer", "Ranger"},
    stats = {atk = 5, spd = 2},
}

-- ============================================
-- EQUIPMENT - ARMOR
-- ============================================

Items["leather_armor"] = {
    id = "leather_armor",
    name = "Leather Armor",
    description = "Armor kulit ringan",
    type = "equipment",
    subtype = "armor",
    slot = "body",
    armorType = "Light",
    price = 150,
    sellPrice = 75,
    stackable = false,
    levelReq = 1,
    jobReq = {"Archer", "Ranger", "Assassin"},
    stats = {def = 5},
}

Items["iron_armor"] = {
    id = "iron_armor",
    name = "Iron Armor",
    description = "Armor besi",
    type = "equipment",
    subtype = "armor",
    slot = "body",
    armorType = "Heavy",
    price = 400,
    sellPrice = 200,
    stackable = false,
    levelReq = 5,
    jobReq = {"Warrior", "Knight", "Berserker"},
    stats = {def = 12},
}

Items["cloth_robe"] = {
    id = "cloth_robe",
    name = "Cloth Robe",
    description = "Jubah kain untuk mage",
    type = "equipment",
    subtype = "armor",
    slot = "body",
    armorType = "Cloth",
    price = 100,
    sellPrice = 50,
    stackable = false,
    levelReq = 1,
    jobReq = {"Mage", "Wizard", "Cleric"},
    stats = {mdef = 5, mp = 10},
}

-- ============================================
-- EQUIPMENT - ACCESSORIES
-- ============================================

Items["hp_ring"] = {
    id = "hp_ring",
    name = "HP Ring",
    description = "Cincin yang meningkatkan HP",
    type = "equipment",
    subtype = "accessory",
    slot = "ring",
    price = 200,
    sellPrice = 100,
    stackable = false,
    levelReq = 3,
    stats = {hp = 20},
}

Items["atk_necklace"] = {
    id = "atk_necklace",
    name = "ATK Necklace",
    description = "Kalung yang meningkatkan ATK",
    type = "equipment",
    subtype = "accessory",
    slot = "necklace",
    price = 250,
    sellPrice = 125,
    stackable = false,
    levelReq = 3,
    stats = {atk = 5},
}

return Items
