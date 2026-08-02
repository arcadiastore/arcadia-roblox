--[[
    Arcadia Online - NPC Data
    
    SEMUA data NPC ada di sini!
    Sesuai GDD 13_NPC.md
    
    @author arcadiastore
    @version 3.0.0
]]

local NPCs = {}

NPCs["Elder"] = {
    id = "Elder",
    name = "Elder Tetua",
    title = "Kepala Desa",
    color = Color3.fromRGB(200, 200, 200),
    size = Vector3.new(2, 5, 2),
    position = Vector3.new(-25, 1, -20),
    hasQuest = true,
    hasShop = false,
    quests = {"quest_kill_slimes", "quest_kill_boars", "quest_kill_guardian"},
}

NPCs["Blacksmith"] = {
    id = "Blacksmith",
    name = "Pandai Besi",
    title = "Ahli Senjata",
    color = Color3.fromRGB(139, 90, 43),
    size = Vector3.new(2, 5, 2),
    position = Vector3.new(25, 1, -15),
    hasQuest = false,
    hasShop = true,
    shopId = "weapon_shop",
}

NPCs["Merchant"] = {
    id = "Merchant",
    name = "Pedagang",
    title = "Penjaja Keliling",
    color = Color3.fromRGB(255, 200, 100),
    size = Vector3.new(2, 5, 2),
    position = Vector3.new(-25, 1, 5),
    hasQuest = false,
    hasShop = true,
    shopId = "general_shop",
}

NPCs["Guard"] = {
    id = "Guard",
    name = "Penjaga Desa",
    title = "Kapten Penjaga",
    color = Color3.fromRGB(100, 100, 200),
    size = Vector3.new(2, 5, 2),
    position = Vector3.new(0, 1, -25),
    hasQuest = true,
    hasShop = false,
    quests = {"quest_kill_wolves"},
}

NPCs["TrainingMaster"] = {
    id = "TrainingMaster",
    name = "Master Pelatihan",
    title = "Instruktur Tempur",
    color = Color3.fromRGB(200, 100, 100),
    size = Vector3.new(2, 5, 2),
    position = Vector3.new(0, 1, 35),
    hasQuest = false,
    hasShop = false,
}

return NPCs
