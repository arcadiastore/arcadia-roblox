--[[
    Arcadia Online - Item Data
    Sesuai GDD 09_Items.md
    
    Equipment Slots:
    - hat: Topi
    - tshirt: Baju atas
    - pants: Celana
    - shoes: Sepatu
    - ringLeft: Cincin kiri
    - ringRight: Cincin kanan
    - necklace: Kalung
    - weapon1h: Senjata 1 tangan
    - weapon2h: Senjata 2 tangan (tidak bisa pakai shield)
    - wings: Sayap/Tali
    - costume: Kostum (visual only)
]]

local Items = {}

-- ============================================
-- CONSUMABLES
-- ============================================

Items["hp_potion_small"] = {
    id = "hp_potion_small",
    name = "HP Potion (Small)",
    description = "Memulihkan 50 HP",
    type = "consumable",
    price = 50,
    sellPrice = 25,
    stackable = true,
    maxStack = 99,
    effect = {stat = "hp", value = 50},
    icon = "rbxassetid://0", -- placeholder
}

Items["hp_potion_medium"] = {
    id = "hp_potion_medium",
    name = "HP Potion (Medium)",
    description = "Memulihkan 100 HP",
    type = "consumable",
    price = 100,
    sellPrice = 50,
    stackable = true,
    maxStack = 99,
    effect = {stat = "hp", value = 100},
    icon = "rbxassetid://0",
}

Items["mp_potion_small"] = {
    id = "mp_potion_small",
    name = "MP Potion (Small)",
    description = "Memulihkan 30 MP",
    type = "consumable",
    price = 40,
    sellPrice = 20,
    stackable = true,
    maxStack = 99,
    effect = {stat = "mp", value = 30},
    icon = "rbxassetid://0",
}

Items["mp_potion_medium"] = {
    id = "mp_potion_medium",
    name = "MP Potion (Medium)",
    description = "Memulihkan 60 MP",
    type = "consumable",
    price = 80,
    sellPrice = 40,
    stackable = true,
    maxStack = 99,
    effect = {stat = "mp", value = 60},
    icon = "rbxassetid://0",
}

-- ============================================
-- MATERIALS
-- ============================================

Items["slime_gel"] = {
    id = "slime_gel",
    name = "Slime Gel",
    description = "Lendir slime",
    type = "material",
    sellPrice = 5,
    stackable = true,
    maxStack = 99,
    icon = "rbxassetid://0",
}

Items["wolf_fang"] = {
    id = "wolf_fang",
    name = "Wolf Fang",
    description = "Taring serigala",
    type = "material",
    sellPrice = 15,
    stackable = true,
    maxStack = 99,
    icon = "rbxassetid://0",
}

Items["boar_tusk"] = {
    id = "boar_tusk",
    name = "Boar Tusk",
    description = "Gading babi hutan",
    type = "material",
    sellPrice = 25,
    stackable = true,
    maxStack = 99,
    icon = "rbxassetid://0",
}

-- ============================================
-- SPECIAL ITEMS
-- ============================================

Items["job_change_ticket"] = {
    id = "job_change_ticket",
    name = "Job Change Ticket",
    description = "Tiket untuk mengganti job. Bicara dengan Job Master.",
    type = "special",
    sellPrice = 2500,
    stackable = true,
    maxStack = 5,
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - WEAPON (1 Hand)
-- ============================================

Items["wooden_sword"] = {
    id = "wooden_sword",
    name = "Wooden Sword",
    description = "Senjata kayu sederhana",
    type = "equipment",
    slot = "weapon1h",
    price = 100,
    sellPrice = 50,
    levelReq = 1,
    jobReq = {"Warrior"},
    stats = {atk = 5},
    range = 8,
    visual = {
        meshId = "rbxassetid://10176805591",
        size = Vector3.new(1, 1, 3),  -- sesuaikan setelah test
        color = Color3.fromRGB(255, 255, 255),
        material = Enum.Material.SmoothPlastic,
        offset = CFrame.new(1.5, 0, 0) * CFrame.Angles(math.rad(90), 0, math.rad(-30)),
        attachTo = "Right Arm",
    },
    icon = "rbxassetid://10176805591",
}

Items["iron_sword"] = {
    id = "iron_sword",
    name = "Iron Sword",
    description = "Senjata besi yang kuat",
    type = "equipment",
    slot = "weapon1h",
    price = 300,
    sellPrice = 150,
    levelReq = 5,
    jobReq = {"Warrior"},
    stats = {atk = 12},
    range = 8,
    visual = {
        color = Color3.fromRGB(180, 180, 180),  -- abu besi
        size = Vector3.new(0.3, 3, 0.3),
        shape = "Block",
        offset = CFrame.new(1.2, 0, 0) * CFrame.Angles(0, 0, math.rad(-30)),
        attachTo = "Right Arm",
    },
    icon = "rbxassetid://0",
}

Items["steel_sword"] = {
    id = "steel_sword",
    name = "Steel Sword",
    description = "Pedang baja berkualitas tinggi",
    type = "equipment",
    slot = "weapon1h",
    price = 800,
    sellPrice = 400,
    levelReq = 10,
    jobReq = {"Warrior", "Archer"},
    stats = {atk = 25, spd = 2},
    range = 8,
    visual = {
        color = Color3.fromRGB(200, 210, 220),  -- baja terang
        size = Vector3.new(0.3, 3.5, 0.3),
        shape = "Block",
        offset = CFrame.new(1.2, 0, 0) * CFrame.Angles(0, 0, math.rad(-30)),
        attachTo = "Right Arm",
    },
    icon = "rbxassetid://0",
}

Items["hunting_dagger"] = {
    id = "hunting_dagger",
    name = "Hunting Dagger",
    description = "Belati berburu yang tajam",
    type = "equipment",
    slot = "weapon1h",
    price = 200,
    sellPrice = 100,
    levelReq = 3,
    jobReq = {"Archer"},
    stats = {atk = 8, spd = 3},
    range = 6,
    visual = {
        color = Color3.fromRGB(160, 160, 170),  -- abu keperakan
        size = Vector3.new(0.2, 1.5, 0.2),
        shape = "Block",
        offset = CFrame.new(1, 0.3, 0) * CFrame.Angles(0, 0, math.rad(-45)),
        attachTo = "Right Arm",
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - WEAPON (2 Hands)
-- ============================================

Items["wooden_staff"] = {
    id = "wooden_staff",
    name = "Wooden Staff",
    description = "Tongkat kayu sederhana",
    type = "equipment",
    slot = "weapon2h",
    price = 100,
    sellPrice = 50,
    levelReq = 1,
    jobReq = {"Mage"},
    stats = {matk = 8, mp = 10},
    range = 25,
    visual = {
        color = Color3.fromRGB(139, 90, 43),  -- coklat kayu
        size = Vector3.new(0.3, 4, 0.3),
        shape = "Block",
        offset = CFrame.new(1.2, 0, 0) * CFrame.Angles(0, 0, math.rad(-15)),
        attachTo = "Right Arm",
        orb = {  -- bola di ujung staff
            color = Color3.fromRGB(80, 150, 255),  -- biru magic
            size = Vector3.new(0.6, 0.6, 0.6),
            offset = CFrame.new(0, 2, 0),
        },
    },
    icon = "rbxassetid://0",
}

Items["iron_staff"] = {
    id = "iron_staff",
    name = "Iron Staff",
    description = "Tongkat besi dengan kekuatan magic",
    type = "equipment",
    slot = "weapon2h",
    price = 400,
    sellPrice = 200,
    levelReq = 5,
    jobReq = {"Mage"},
    stats = {matk = 18, mp = 25},
    range = 25,
    visual = {
        color = Color3.fromRGB(100, 100, 110),  -- besi gelap
        size = Vector3.new(0.3, 4.5, 0.3),
        shape = "Block",
        offset = CFrame.new(1.2, 0, 0) * CFrame.Angles(0, 0, math.rad(-15)),
        attachTo = "Right Arm",
        orb = {
            color = Color3.fromRGB(150, 50, 255),  -- ungu magic
            size = Vector3.new(0.7, 0.7, 0.7),
            offset = CFrame.new(0, 2.2, 0),
        },
    },
    icon = "rbxassetid://0",
}

Items["great_axe"] = {
    id = "great_axe",
    name = "Great Axe",
    description = "Kapak besar yang menghancurkan",
    type = "equipment",
    slot = "weapon2h",
    price = 500,
    sellPrice = 250,
    levelReq = 7,
    jobReq = {"Warrior"},
    stats = {atk = 30, def = -3},
    range = 10,
    visual = {
        color = Color3.fromRGB(120, 120, 120),  -- abu gelap
        size = Vector3.new(0.4, 3.5, 0.4),
        shape = "Block",
        offset = CFrame.new(1.3, 0, 0) * CFrame.Angles(0, 0, math.rad(-20)),
        attachTo = "Right Arm",
        blade = {  -- mata kapak
            color = Color3.fromRGB(200, 200, 210),
            size = Vector3.new(1.2, 1.5, 0.2),
            offset = CFrame.new(0, 1.5, 0),
        },
    },
    icon = "rbxassetid://0",
}

Items["longbow"] = {
    id = "longbow",
    name = "Longbow",
    description = "Busur panjang dengan jangkauan jauh",
    type = "equipment",
    slot = "weapon2h",
    price = 350,
    sellPrice = 175,
    levelReq = 5,
    jobReq = {"Archer"},
    stats = {atk = 15, spd = 5},
    range = 30,
    visual = {
        color = Color3.fromRGB(139, 90, 43),  -- coklat kayu
        size = Vector3.new(0.2, 3, 0.2),
        shape = "Block",
        offset = CFrame.new(1.2, 0, 0) * CFrame.Angles(0, 0, math.rad(10)),
        attachTo = "Left Arm",
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - HAT
-- ============================================

Items["leather_cap"] = {
    id = "leather_cap",
    name = "Leather Cap",
    description = "Topi kulit ringan",
    type = "equipment",
    slot = "hat",
    price = 80,
    sellPrice = 40,
    levelReq = 1,
    stats = {def = 2},
    visual = {
        color = Color3.fromRGB(139, 90, 43),  -- coklat kulit
        size = Vector3.new(2.2, 0.8, 2.2),
        shape = "Block",
        offset = CFrame.new(0, 1.2, 0),
        attachTo = "Head",
    },
    icon = "rbxassetid://0",
}

Items["iron_helmet"] = {
    id = "iron_helmet",
    name = "Iron Helmet",
    description = "Helm besi pelindung",
    type = "equipment",
    slot = "hat",
    price = 250,
    sellPrice = 125,
    levelReq = 5,
    stats = {def = 5, hp = 10},
    visual = {
        color = Color3.fromRGB(160, 160, 170),  -- abu besi
        size = Vector3.new(2.4, 1.2, 2.4),
        shape = "Block",
        offset = CFrame.new(0, 0.8, 0),
        attachTo = "Head",
    },
    icon = "rbxassetid://0",
}

Items["mage_hat"] = {
    id = "mage_hat",
    name = "Mage Hat",
    description = "Topi penyihir berujung",
    type = "equipment",
    slot = "hat",
    price = 200,
    sellPrice = 100,
    levelReq = 3,
    stats = {matk = 3, mdef = 2},
    visual = {
        color = Color3.fromRGB(50, 50, 150),  -- biru gelap
        size = Vector3.new(2, 2, 2),
        shape = "Block",
        offset = CFrame.new(0, 1.8, 0),
        attachTo = "Head",
        accent = {  -- pita/hiasan
            color = Color3.fromRGB(200, 180, 50),  -- emas
            size = Vector3.new(2.2, 0.3, 2.2),
            offset = CFrame.new(0, -0.5, 0),
        },
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - TSHIRT (Body Armor)
-- ============================================

Items["leather_armor"] = {
    id = "leather_armor",
    name = "Leather Armor",
    description = "Armor kulit ringan",
    type = "equipment",
    slot = "tshirt",
    price = 150,
    sellPrice = 75,
    levelReq = 1,
    stats = {def = 5},
    visual = {
        color = Color3.fromRGB(120, 75, 30),  -- coklat gelap
        size = Vector3.new(2.5, 2.5, 1.5),
        shape = "Block",
        offset = CFrame.new(0, 0, 0),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

Items["iron_chestplate"] = {
    id = "iron_chestplate",
    name = "Iron Chestplate",
    description = "Dada besi yang kuat",
    type = "equipment",
    slot = "tshirt",
    price = 500,
    sellPrice = 250,
    levelReq = 7,
    stats = {def = 12, hp = 20},
    visual = {
        color = Color3.fromRGB(140, 140, 150),  -- abu besi
        size = Vector3.new(2.6, 2.6, 1.6),
        shape = "Block",
        offset = CFrame.new(0, 0, 0),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

Items["cloth_robe"] = {
    id = "cloth_robe",
    name = "Cloth Robe",
    description = "Jubah kain penyihir",
    type = "equipment",
    slot = "tshirt",
    price = 200,
    sellPrice = 100,
    levelReq = 3,
    stats = {def = 2, matk = 3, mp = 15},
    visual = {
        color = Color3.fromRGB(40, 40, 120),  -- biru gelap
        size = Vector3.new(2.4, 3, 1.4),
        shape = "Block",
        offset = CFrame.new(0, -0.3, 0),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - PANTS
-- ============================================

Items["leather_pants"] = {
    id = "leather_pants",
    name = "Leather Pants",
    description = "Celana kulit",
    type = "equipment",
    slot = "pants",
    price = 100,
    sellPrice = 50,
    levelReq = 1,
    stats = {def = 3},
    visual = {
        color = Color3.fromRGB(100, 65, 25),  -- coklat kulit
        size = Vector3.new(2.2, 2, 1.3),
        shape = "Block",
        offset = CFrame.new(0, 0, 0),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

Items["iron_leggings"] = {
    id = "iron_leggings",
    name = "Iron Leggings",
    description = "Legging besi pelindung",
    type = "equipment",
    slot = "pants",
    price = 300,
    sellPrice = 150,
    levelReq = 5,
    stats = {def = 6, spd = -1},
    visual = {
        color = Color3.fromRGB(130, 130, 140),  -- abu besi
        size = Vector3.new(2.3, 2, 1.4),
        shape = "Block",
        offset = CFrame.new(0, 0, 0),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - SHOES
-- ============================================

Items["leather_boots"] = {
    id = "leather_boots",
    name = "Leather Boots",
    description = "Sepatu kulit nyaman",
    type = "equipment",
    slot = "shoes",
    price = 80,
    sellPrice = 40,
    levelReq = 1,
    stats = {def = 1, spd = 2},
    visual = {
        color = Color3.fromRGB(90, 55, 20),  -- coklat gelap
        size = Vector3.new(1, 0.6, 1.3),
        shape = "Block",
        offset = CFrame.new(0, -0.8, 0.2),
        attachTo = "Left Leg",
        mirror = true,  -- juga apply ke Right Leg
    },
    icon = "rbxassetid://0",
}

Items["iron_boots"] = {
    id = "iron_boots",
    name = "Iron Boots",
    description = "Sepatu besi berat",
    type = "equipment",
    slot = "shoes",
    price = 200,
    sellPrice = 100,
    levelReq = 5,
    stats = {def = 4, spd = -1},
    visual = {
        color = Color3.fromRGB(130, 130, 140),  -- abu besi
        size = Vector3.new(1.1, 0.7, 1.4),
        shape = "Block",
        offset = CFrame.new(0, -0.8, 0.2),
        attachTo = "Left Leg",
        mirror = true,
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - RINGS
-- ============================================

Items["copper_ring"] = {
    id = "copper_ring",
    name = "Copper Ring",
    description = "Cincin tembaga sederhana",
    type = "equipment",
    slot = "ring",
    price = 50,
    sellPrice = 25,
    levelReq = 1,
    stats = {atk = 1, def = 1},
    visual = {
        color = Color3.fromRGB(180, 120, 50),  -- tembaga
        size = Vector3.new(0.5, 0.2, 0.5),
        shape = "Block",
        offset = CFrame.new(0, -0.8, 0),
        attachTo = "Right Arm",
    },
    icon = "rbxassetid://0",
}

Items["silver_ring"] = {
    id = "silver_ring",
    name = "Silver Ring",
    description = "Cincin perak berkilau",
    type = "equipment",
    slot = "ring",
    price = 200,
    sellPrice = 100,
    levelReq = 5,
    stats = {atk = 3, def = 2, luk = 2},
    visual = {
        color = Color3.fromRGB(200, 200, 210),  -- perak
        size = Vector3.new(0.5, 0.2, 0.5),
        shape = "Block",
        offset = CFrame.new(0, -0.8, 0),
        attachTo = "Right Arm",
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - NECKLACE
-- ============================================

Items["wooden_pendant"] = {
    id = "wooden_pendant",
    name = "Wooden Pendant",
    description = "Liontin kayu pelindung",
    type = "equipment",
    slot = "necklace",
    price = 60,
    sellPrice = 30,
    levelReq = 1,
    stats = {mdef = 3, hp = 5},
    visual = {
        color = Color3.fromRGB(139, 90, 43),  -- coklat kayu
        size = Vector3.new(0.5, 0.5, 0.3),
        shape = "Ball",
        offset = CFrame.new(0, 1.2, -0.8),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

Items["silver_necklace"] = {
    id = "silver_necklace",
    name = "Silver Necklace",
    description = "Kalung perak berkilau",
    type = "equipment",
    slot = "necklace",
    price = 300,
    sellPrice = 150,
    levelReq = 5,
    stats = {mdef = 5, hp = 15, mp = 10},
    visual = {
        color = Color3.fromRGB(200, 200, 210),  -- perak
        size = Vector3.new(0.6, 0.6, 0.3),
        shape = "Ball",
        offset = CFrame.new(0, 1.2, -0.8),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - WINGS/ROPE
-- ============================================

Items["basic_wings"] = {
    id = "basic_wings",
    name = "Basic Wings",
    description = "Sayap sederhana untuk terbang rendah",
    type = "equipment",
    slot = "wings",
    price = 500,
    sellPrice = 250,
    levelReq = 10,
    stats = {spd = 10},
    visual = {
        color = Color3.fromRGB(255, 255, 255),  -- putih
        size = Vector3.new(4, 3, 0.3),
        shape = "Block",
        offset = CFrame.new(0, 0.5, 1.2),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

Items["rope_climbing"] = {
    id = "rope_climbing",
    name = "Climbing Rope",
    description = "Tali panjat untuk area tinggi",
    type = "equipment",
    slot = "wings",
    price = 200,
    sellPrice = 100,
    levelReq = 3,
    stats = {spd = 3, def = 1},
    visual = {
        color = Color3.fromRGB(180, 150, 100),  -- coklat tali
        size = Vector3.new(0.5, 2, 0.5),
        shape = "Block",
        offset = CFrame.new(0, 0, 1),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - COSTUME (Visual only)
-- ============================================

Items["costume_ninja"] = {
    id = "costume_ninja",
    name = "Ninja Costume",
    description = "Kostum ninja hitam",
    type = "equipment",
    slot = "costume",
    price = 1000,
    sellPrice = 500,
    levelReq = 1,
    stats = {},
    visual = {
        color = Color3.fromRGB(30, 30, 30),  -- hitam
        size = Vector3.new(2.6, 3.5, 1.5),
        shape = "Block",
        offset = CFrame.new(0, -0.5, 0),
        attachTo = "Torso",
        fullBody = true,  -- ganti warna seluruh tubuh
    },
    icon = "rbxassetid://0",
}

Items["costume_knight"] = {
    id = "costume_knight",
    name = "Knight Costume",
    description = "Kostum ksatria kerajaan",
    type = "equipment",
    slot = "costume",
    price = 1000,
    sellPrice = 500,
    levelReq = 1,
    stats = {},
    visual = {
        color = Color3.fromRGB(180, 170, 140),  -- emas pucat
        size = Vector3.new(2.6, 3.5, 1.5),
        shape = "Block",
        offset = CFrame.new(0, -0.5, 0),
        attachTo = "Torso",
        fullBody = true,
    },
    icon = "rbxassetid://0",
}

return Items
