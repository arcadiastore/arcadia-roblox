--[[
    Arcadia Online - Game Data Module (SINGLE SOURCE OF TRUTH)
    
    Semua data game ada di sini:
    - Monster definitions
    - Quest definitions
    - Item definitions
    - NPC definitions
    - Dialogue definitions
    - Shop definitions
    
    Place di: ReplicatedStorage (as ModuleScript)
    
    CARA PAKAI:
    local GameData = require(ReplicatedStorage.GameData)
    local slime = GameData.Monsters["Slime"]
    
    @author arcadiastore
    @version 2.0.0
]]

local GameData = {}

-- ============================================
-- MONSTER DATA
-- ============================================

GameData.Monsters = {
    ["Slime"] = {
        id = "Slime",
        name = "Slime",
        level = 1,
        hp = 50,
        atk = 5,
        def = 3,
        exp = 20,
        gold = 10,
        color = Color3.fromRGB(50, 200, 50),
        size = Vector3.new(3, 3, 3),
        shape = "Ball",
        spawnArea = "TrainingGround",
        respawnTime = 10,
        drops = {
            {itemId = "hp_potion_small", chance = 0.3},
            {itemId = "slime_gel", chance = 0.5},
        },
    },
    
    ["Wolf"] = {
        id = "Wolf",
        name = "Serigala",
        level = 5,
        hp = 120,
        atk = 15,
        def = 8,
        exp = 50,
        gold = 25,
        color = Color3.fromRGB(128, 128, 128),
        size = Vector3.new(3, 2, 5),
        shape = "Block",
        spawnArea = "ForestEntrance",
        respawnTime = 15,
        drops = {
            {itemId = "wolf_fang", chance = 0.4},
            {itemId = "leather_armor", chance = 0.1},
        },
    },
    
    ["Boar"] = {
        id = "Boar",
        name = "Babi Hutan",
        level = 7,
        hp = 180,
        atk = 20,
        def = 12,
        exp = 80,
        gold = 40,
        color = Color3.fromRGB(139, 90, 43),
        size = Vector3.new(4, 3, 5),
        shape = "Block",
        spawnArea = "DeepForest",
        respawnTime = 20,
        drops = {
            {itemId = "boar_meat", chance = 0.6},
            {itemId = "iron_armor", chance = 0.05},
        },
    },
    
    ["Guardian"] = {
        id = "Guardian",
        name = "Guardian of the Forest",
        level = 10,
        hp = 500,
        atk = 35,
        def = 20,
        exp = 200,
        gold = 100,
        color = Color3.fromRGB(200, 50, 50),
        size = Vector3.new(6, 8, 4),
        shape = "Block",
        spawnArea = "ForestGate",
        respawnTime = 60,
        isBoss = true,
        drops = {
            {itemId = "steel_sword", chance = 0.3},
            {itemId = "boss_gem", chance = 1.0},
        },
    },
}

-- ============================================
-- ITEM DATA
-- ============================================

GameData.Items = {
    -- Potions
    ["hp_potion_small"] = {
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
    },
    ["hp_potion_medium"] = {
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
    },
    ["hp_potion_large"] = {
        id = "hp_potion_large",
        name = "HP Potion (Large)",
        description = "Memulihkan 200 HP",
        type = "consumable",
        subtype = "potion",
        price = 200,
        sellPrice = 100,
        stackable = true,
        maxStack = 99,
        effect = {stat = "hp", value = 200},
    },
    ["mp_potion_small"] = {
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
    },
    ["mp_potion_medium"] = {
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
    },
    
    -- Materials (Monster Drops)
    ["slime_gel"] = {
        id = "slime_gel",
        name = "Slime Gel",
        description = "Lendir slime, bisa dijual",
        type = "material",
        subtype = "drop",
        price = 0,
        sellPrice = 5,
        stackable = true,
        maxStack = 99,
    },
    ["wolf_fang"] = {
        id = "wolf_fang",
        name = "Wolf Fang",
        description = "Taring serigala",
        type = "material",
        subtype = "drop",
        price = 0,
        sellPrice = 15,
        stackable = true,
        maxStack = 99,
    },
    ["boar_meat"] = {
        id = "boar_meat",
        name = "Boar Meat",
        description = "Daging babi hutan, bisa dimakan",
        type = "consumable",
        subtype = "food",
        price = 0,
        sellPrice = 20,
        stackable = true,
        maxStack = 99,
        effect = {stat = "hp", value = 80},
    },
    ["boss_gem"] = {
        id = "boss_gem",
        name = "Guardian Gem",
        description = "Permata dari Guardian",
        type = "material",
        subtype = "quest_item",
        price = 0,
        sellPrice = 500,
        stackable = true,
        maxStack = 1,
    },
    
    -- Weapons
    ["wooden_sword"] = {
        id = "wooden_sword",
        name = "Wooden Sword",
        description = "Senjata kayu sederhana",
        type = "equipment",
        subtype = "weapon",
        slot = "weapon",
        price = 100,
        sellPrice = 50,
        stackable = false,
        levelReq = 1,
        stats = {atk = 5},
    },
    ["iron_sword"] = {
        id = "iron_sword",
        name = "Iron Sword",
        description = "Senjata besi yang kuat",
        type = "equipment",
        subtype = "weapon",
        slot = "weapon",
        price = 300,
        sellPrice = 150,
        stackable = false,
        levelReq = 5,
        stats = {atk = 12},
    },
    ["steel_sword"] = {
        id = "steel_sword",
        name = "Steel Sword",
        description = "Senjata baja terbaik",
        type = "equipment",
        subtype = "weapon",
        slot = "weapon",
        price = 600,
        sellPrice = 300,
        stackable = false,
        levelReq = 10,
        stats = {atk = 20},
    },
    
    -- Armor
    ["leather_armor"] = {
        id = "leather_armor",
        name = "Leather Armor",
        description = "Armor kulit ringan",
        type = "equipment",
        subtype = "armor",
        slot = "body",
        price = 150,
        sellPrice = 75,
        stackable = false,
        levelReq = 1,
        stats = {def = 5},
    },
    ["iron_armor"] = {
        id = "iron_armor",
        name = "Iron Armor",
        description = "Armor besi yang kuat",
        type = "equipment",
        subtype = "armor",
        slot = "body",
        price = 400,
        sellPrice = 200,
        stackable = false,
        levelReq = 5,
        stats = {def = 12},
    },
    ["steel_armor"] = {
        id = "steel_armor",
        name = "Steel Armor",
        description = "Armor baja terbaik",
        type = "equipment",
        subtype = "armor",
        slot = "body",
        price = 800,
        sellPrice = 400,
        stackable = false,
        levelReq = 10,
        stats = {def = 20},
    },
    
    -- Accessories
    ["hp_ring"] = {
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
    },
    ["atk_necklace"] = {
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
    },
}

-- ============================================
-- QUEST DATA
-- ============================================

GameData.Quests = {
    ["quest_kill_slimes"] = {
        id = "quest_kill_slimes",
        name = "Permintaan Tetua",
        description = "Bunuh 5 Slime di Training Ground",
        level = 1,
        giver = "Elder",
        objectives = {
            {type = "kill", target = "Slime", count = 5},
        },
        rewards = {
            exp = 50,
            gold = 100,
            items = {},
        },
        prerequisite = nil,
        nextQuest = "quest_kill_wolves",
    },
    
    ["quest_kill_wolves"] = {
        id = "quest_kill_wolves",
        name = "Ancaman Serigala",
        description = "Bunuh 3 Serigala di Forest Entrance",
        level = 5,
        giver = "Guard",
        objectives = {
            {type = "kill", target = "Wolf", count = 3},
        },
        rewards = {
            exp = 150,
            gold = 300,
            items = {
                {itemId = "iron_sword", count = 1},
            },
        },
        prerequisite = "quest_kill_slimes",
        nextQuest = "quest_kill_boars",
    },
    
    ["quest_kill_boars"] = {
        id = "quest_kill_boars",
        name = "Pemburu Babi Hutan",
        description = "Bunuh 5 Babi Hutan di Deep Forest",
        level = 7,
        giver = "Elder",
        objectives = {
            {type = "kill", target = "Boar", count = 5},
        },
        rewards = {
            exp = 300,
            gold = 500,
            items = {
                {itemId = "iron_armor", count = 1},
            },
        },
        prerequisite = "quest_kill_wolves",
        nextQuest = "quest_kill_guardian",
    },
    
    ["quest_kill_guardian"] = {
        id = "quest_kill_guardian",
        name = "Guardian of the Forest",
        description = "Kalahkan Guardian Boss",
        level = 10,
        giver = "Elder",
        objectives = {
            {type = "kill", target = "Guardian", count = 1},
        },
        rewards = {
            exp = 1000,
            gold = 2000,
            items = {
                {itemId = "steel_sword", count = 1},
                {itemId = "steel_armor", count = 1},
            },
        },
        prerequisite = "quest_kill_boars",
        nextQuest = nil,
    },
}

-- ============================================
-- NPC DATA
-- ============================================

GameData.NPCs = {
    ["Elder"] = {
        id = "Elder",
        name = "Elder Tetua",
        title = "Kepala Desa",
        color = Color3.fromRGB(200, 200, 200),
        position = Vector3.new(-25, 1, -20),
        hasQuest = true,
        hasShop = false,
        quests = {"quest_kill_slimes", "quest_kill_boars", "quest_kill_guardian"},
    },
    ["Blacksmith"] = {
        id = "Blacksmith",
        name = "Pandai Besi",
        title = "Ahli Senjata",
        color = Color3.fromRGB(139, 90, 43),
        position = Vector3.new(25, 1, -15),
        hasQuest = false,
        hasShop = true,
        shopId = "weapon_shop",
    },
    ["Merchant"] = {
        id = "Merchant",
        name = "Pedagang",
        title = "Penjaja Keliling",
        color = Color3.fromRGB(255, 200, 100),
        position = Vector3.new(-25, 1, 5),
        hasQuest = false,
        hasShop = true,
        shopId = "general_shop",
    },
    ["Guard"] = {
        id = "Guard",
        name = "Penjaga Desa",
        title = "Kapten Penjaga",
        color = Color3.fromRGB(100, 100, 200),
        position = Vector3.new(0, 1, -25),
        hasQuest = true,
        hasShop = false,
        quests = {"quest_kill_wolves"},
    },
    ["TrainingMaster"] = {
        id = "TrainingMaster",
        name = "Master Pelatihan",
        title = "Instruktur Tempur",
        color = Color3.fromRGB(200, 100, 100),
        position = Vector3.new(0, 1, 35),
        hasQuest = false,
        hasShop = false,
    },
}

-- ============================================
-- SHOP DATA
-- ============================================

GameData.Shops = {
    ["general_shop"] = {
        id = "general_shop",
        name = "Toko Umum",
        npcId = "Merchant",
        items = {
            "hp_potion_small",
            "hp_potion_medium",
            "mp_potion_small",
            "mp_potion_medium",
            "boar_meat",
        },
    },
    ["weapon_shop"] = {
        id = "weapon_shop",
        name = "Toko Senjata",
        npcId = "Blacksmith",
        items = {
            "wooden_sword",
            "iron_sword",
            "steel_sword",
            "leather_armor",
            "iron_armor",
            "steel_armor",
            "hp_ring",
            "atk_necklace",
        },
    },
}

-- ============================================
-- DIALOGUE DATA
-- ============================================

GameData.Dialogues = {
    ["Elder"] = {
        npcId = "Elder",
        lines = {
            {text = "Selamat datang di desa kita, petualang muda!", action = nil},
            {text = "Aku punya tugas untukmu. Maukah kau membantu desa?", action = "quest_offer"},
            {text = "Pergilah ke Training Ground dan bunuh Slime yang mengganggu.", action = nil},
        },
    },
    ["Blacksmith"] = {
        npcId = "Blacksmith",
        lines = {
            {text = "Butuh senjata atau armor? Aku punya yang terbaik!", action = "open_shop"},
            {text = "Lihat koleksiku dan pilih yang cocok untukmu.", action = nil},
        },
    },
    ["Merchant"] = {
        npcId = "Merchant",
        lines = {
            {text = "Hei! Mau beli sesuatu? Aku punya barang bagus!", action = "open_shop"},
            {text = "Potion, ramuan, segala macam ada!", action = nil},
        },
    },
    ["Guard"] = {
        npcId = "Guard",
        lines = {
            {text = "Hati-hati di luar desa. Monster semakin berbahaya.", action = nil},
            {text = "Bunuh 3 Serigala untuk membuktikan kekuatanmu!", action = "quest_offer"},
        },
    },
    ["TrainingMaster"] = {
        npcId = "TrainingMaster",
        lines = {
            {text = "Selamat datang di Training Ground!", action = nil},
            {text = "Klik kiri untuk menyerang. Coba serang Slime!", action = "tutorial"},
            {text = "Bicara dengan Elder Tetua untuk quest pertamamu.", action = nil},
        },
    },
}

-- ============================================
-- SPAWN POSITIONS
-- ============================================

GameData.SpawnPositions = {
    VillageCenter = Vector3.new(0, 5, 0),
    
    TrainingGround = {
        Vector3.new(10, 2, 45),
        Vector3.new(-10, 2, 45),
        Vector3.new(15, 2, 50),
        Vector3.new(-15, 2, 50),
        Vector3.new(0, 2, 55),
    },
    
    ForestEntrance = {
        Vector3.new(20, 1.5, -40),
        Vector3.new(-20, 1.5, -40),
        Vector3.new(15, 1.5, -50),
        Vector3.new(-15, 1.5, -50),
    },
    
    DeepForest = {
        Vector3.new(30, 2, -60),
        Vector3.new(-30, 2, -60),
        Vector3.new(25, 2, -70),
    },
    
    ForestGate = {
        Vector3.new(0, 4, -80),
    },
}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

function GameData:GetMonster(id)
    return self.Monsters[id]
end

function GameData:GetItem(id)
    return self.Items[id]
end

function GameData:GetQuest(id)
    return self.Quests[id]
end

function GameData:GetNPC(id)
    return self.NPCs[id]
end

function GameData:GetShop(id)
    return self.Shops[id]
end

function GameData:GetDialogue(npcId)
    return self.Dialogues[npcId]
end

function GameData:GetMonstersByArea(area)
    local monsters = {}
    for id, monster in pairs(self.Monsters) do
        if monster.spawnArea == area then
            table.insert(monsters, monster)
        end
    end
    return monsters
end

function GameData:GetShopItems(shopId)
    local shop = self.Shops[shopId]
    if not shop then return {} end
    
    local items = {}
    for _, itemId in ipairs(shop.items) do
        local item = self.Items[itemId]
        if item then
            table.insert(items, item)
        end
    end
    return items
end

function GameData:GetAvailableQuests(playerLevel, completedQuests)
    local available = {}
    for id, quest in pairs(self.Quests) do
        if quest.level <= playerLevel then
            if not completedQuests[id] then
                if not quest.prerequisite or completedQuests[quest.prerequisite] then
                    table.insert(available, quest)
                end
            end
        end
    end
    return available
end

return GameData
