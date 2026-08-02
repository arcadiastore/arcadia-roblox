--[[
    Arcadia Online - NPC Spawner (v2 - Data-Driven)
    
    Semua data dari GameData module
    Tidak ada hardcode!
    
    Place di: ServerScriptService/World (as Script)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Wait for GameData
task.wait(3)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

print("[NPC] Spawning NPCs from GameData...")

-- ============================================
-- NPC CREATION
-- ============================================

local function createNPC(npcData)
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
    head.Color = Color3.fromRGB(255, 205, 148)
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
    
    -- ClickDetector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 10
    clickDetector.Parent = body
    
    -- Set attributes (only ID, data from GameData)
    body:SetAttribute("NPCId", npcData.id)
    
    npcFolder.Parent = Workspace:FindFirstChild("NPCs") or Workspace
    
    print("[NPC] Spawned: " .. npcData.name .. " at " .. tostring(npcData.position))
    
    return npcFolder
end

-- ============================================
-- SPAWN FROM GAMEDATA
-- ============================================

-- Create NPCs folder
local npcsFolder = Workspace:FindFirstChild("NPCs")
if not npcsFolder then
    npcsFolder = Instance.new("Folder")
    npcsFolder.Name = "NPCs"
    npcsFolder.Parent = Workspace
end

-- Spawn NPCs from GameData
local totalSpawned = 0
for npcId, npcData in pairs(GameData.NPCs) do
    createNPC(npcData)
    totalSpawned = totalSpawned + 1
end

print("[NPC] All NPCs spawned from GameData: " .. totalSpawned .. " total")
