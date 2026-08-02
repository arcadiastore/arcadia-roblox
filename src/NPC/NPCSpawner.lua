--[[
    Arcadia Online - NPC Spawner
    
    Creates NPCs according to GDD:
    - Elder Tetua (Quest Giver)
    - Blacksmith (Shop - Weapons)
    - Merchant (Shop - Potions)
    - Guard (Dialogue)
    - Training Master (Tutorial)
    
    Place di: ServerScriptService/World (as Script)
    
    @author arcadiastore
    @version 1.0.0
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tunggu game load
task.wait(3)

print("[NPC] Spawning NPCs...")

-- ============================================
-- NPC DEFINITIONS (GDD)
-- ============================================

local NPC_DATA = {
    {
        id = "Elder",
        name = "Elder Tetua",
        title = "Kepala Desa",
        position = Vector3.new(-25, 1, -20),
        color = Color3.fromRGB(200, 200, 200),  -- White robe
        dialogue = {
            greeting = "Selamat datang di desa kita, petualang muda!",
            quest = "Aku punya tugas untukmu. Maukah kau membantu desa?",
            questComplete = "Luar biasa! Terimalah hadiah ini!",
        },
        quests = {"quest_kill_slimes"},
    },
    {
        id = "Blacksmith",
        name = "Pandai Besi",
        title = "Ahli Senjata",
        position = Vector3.new(25, 1, -15),
        color = Color3.fromRGB(139, 90, 43),  -- Brown apron
        dialogue = {
            greeting = "Butuh senjata atau armor? Aku punya yang terbaik!",
        },
        shop = "WeaponShop",
    },
    {
        id = "Merchant",
        name = "Pedagang",
        title = "Penjaja Keliling",
        position = Vector3.new(-25, 1, 5),
        color = Color3.fromRGB(255, 200, 100),  -- Yellow/gold
        dialogue = {
            greeting = "Hei! Mau beli sesuatu? Aku punya barang bagus!",
        },
        shop = "GeneralShop",
    },
    {
        id = "Guard",
        name = "Penjaga Desa",
        title = "Kapten Penjaga",
        position = Vector3.new(0, 1, -25),
        color = Color3.fromRGB(100, 100, 200),  -- Blue armor
        dialogue = {
            greeting = "Hati-hati di luar desa. Monster semakin berbahaya.",
            tip = "Gunakan serangan dasar untuk slime, tapi untuk serigala kau perlu skill.",
        },
    },
    {
        id = "TrainingMaster",
        name = "Master Pelatihan",
        title = "Instruktur Tempur",
        position = Vector3.new(0, 1, 35),
        color = Color3.fromRGB(200, 100, 100),  -- Red gi
        dialogue = {
            greeting = "Selamat datang di Training Ground! Di sini kau bisa berlatih.",
            tutorial_attack = "Klik kiri untuk menyerang. Coba serang dummy itu!",
            tutorial_skill = "Tekan 1-4 untuk menggunakan skill. Skill punya cooldown.",
            tutorial_quest = "Bicara dengan Elder Tetua untuk mendapatkan quest pertamamu.",
        },
    },
}

-- ============================================
-- NPC CREATION FUNCTION
-- ============================================

local function createNPC(npcData)
    -- Create folder
    local npcFolder = Instance.new("Model")
    npcFolder.Name = "NPC_" .. npcData.id
    
    -- Create body
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(2, 3, 1)
    body.Position = npcData.position + Vector3.new(0, 1.5, 0)
    body.Anchored = true
    body.Material = Enum.Material.SmoothPlastic
    body.Color = npcData.color
    body.Parent = npcFolder
    
    -- Create head
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1.2, 1.2, 1.2)
    head.Shape = Enum.PartType.Ball
    head.Position = npcData.position + Vector3.new(0, 3.6, 0)
    head.Anchored = true
    head.Material = Enum.Material.SmoothPlastic
    head.Color = Color3.fromRGB(255, 205, 148)  -- Skin color
    head.Parent = npcFolder
    
    -- Name tag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Size = UDim2.new(6, 0, 2, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = head
    billboard.Parent = head
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = npcData.name
    nameLabel.Parent = billboard
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.Text = npcData.title
    titleLabel.Parent = billboard
    
    -- ClickDetector for interaction
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 10
    clickDetector.Parent = body
    
    -- Interaction script
    local interactionScript = Instance.new("Script")
    interactionScript.Name = "Interaction"
    interactionScript.Parent = body
    
    -- Set attributes for data
    body:SetAttribute("NPCId", npcData.id)
    body:SetAttribute("NPCName", npcData.name)
    body:SetAttribute("HasQuest", npcData.quests ~= nil)
    body:SetAttribute("HasShop", npcData.shop ~= nil)
    
    -- Store dialogue in attributes (simplified)
    if npcData.dialogue then
        body:SetAttribute("Greeting", npcData.dialogue.greeting or "")
        body:SetAttribute("QuestDialogue", npcData.dialogue.quest or "")
    end
    
    npcFolder.Parent = Workspace:FindFirstChild("NPCs") or Workspace
    
    print("[NPC] Spawned: " .. npcData.name .. " at " .. tostring(npcData.position))
    
    return npcFolder
end

-- ============================================
-- SPAWN ALL NPCs
-- ============================================

-- Create NPCs folder if not exists
local npcsFolder = Workspace:FindFirstChild("NPCs")
if not npcsFolder then
    npcsFolder = Instance.new("Folder")
    npcsFolder.Name = "NPCs"
    npcsFolder.Parent = Workspace
end

-- Spawn NPCs
for _, npcData in ipairs(NPC_DATA) do
    createNPC(npcData)
end

print("[NPC] All NPCs spawned!")
print("[NPC] - Elder Tetua (Quest)")
print("[NPC] - Pandai Besi (Shop)")
print("[NPC] - Pedagang (Shop)")
print("[NPC] - Penjaga Desa (Info)")
print("[NPC] - Master Pelatihan (Tutorial)")
