--[[
    Arcadia Online - NPC Spawner (v3 - Data-Driven)
    
    Spawns NPCs based on GameData module.
    Sets proper attributes for shops and quests.
    
    Place di: ServerScriptService/World (as Script)
    
    @author arcadiastore
    @version 3.0.0
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for GameData
task.wait(3)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

print("[NPCSpawner] NPC Spawner initializing...")

-- Create NPCs folder
local npcFolder = Instance.new("Folder")
npcFolder.Name = "NPCs"
npcFolder.Parent = workspace

-- ============================================
-- SPAWN NPC FUNCTION
-- ============================================

local function spawnNPC(npcId, npcData)
    -- Create NPC part
    local npc = Instance.new("Part")
    npc.Name = npcId
    npc.Size = npcData.size or Vector3.new(2, 5, 2)
    npc.Position = npcData.position + Vector3.new(0, 2.5, 0)
    npc.Anchored = true
    npc.CanCollide = true
    npc.BrickColor = BrickColor.new("Institutional white")
    npc.Material = Enum.Material.SmoothPlastic
    
    -- Set color
    if npcData.color then
        npc.Color = npcData.color
    end
    
    -- Add name tag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = npc
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = npcData.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 0, 0.6, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = npcData.title or ""
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.TextStrokeTransparency = 0
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextScaled = true
    titleLabel.Parent = billboard
    
    -- Set attributes for interaction system
    npc:SetAttribute("NPCId", npcId)
    npc:SetAttribute("HasShop", npcData.hasShop or false)
    npc:SetAttribute("HasQuest", npcData.hasQuest or false)
    
    if npcData.hasShop and npcData.shopId then
        npc:SetAttribute("ShopId", npcData.shopId)
    end
    
    if npcData.hasQuest and npcData.quests then
        npc:SetAttribute("QuestIds", table.concat(npcData.quests, ","))
    end
    
    -- Add ClickDetector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 15
    clickDetector.Parent = npc
    
    npc.Parent = npcFolder
    
    print("[NPCSpawner] Spawned NPC: " .. npcId .. " at " .. tostring(npcData.position))
    return npc
end

-- ============================================
-- SPAWN ALL NPCs FROM GAMEDATA
-- ============================================

for npcId, npcData in pairs(GameData.NPCs) do
    spawnNPC(npcId, npcData)
end

print("[NPCSpawner] All NPCs spawned successfully!")
