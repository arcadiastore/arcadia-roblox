--[[
    Arcadia Online - Main Server Script (Entry Point)
    
    Loads all server modules and connects events.
    Place di: ServerScriptService (as Script)
    
    @author arcadiastore
    @version 5.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Server] ==========================================")
print("[Server] Arcadia Online Server Starting...")
print("[Server] ==========================================")

-- Wait for GameData
task.wait(2)
local success, GameData = pcall(function()
    return require(ReplicatedStorage:WaitForChild("GameData"))
end)

if not success or not GameData then
    warn("[Server] Failed to load GameData!")
    return
end
print("[Server] GameData loaded!")

-- ============================================
-- LOAD SERVER MODULES
-- ============================================

local ServerModules = script:WaitForChild("ServerModules")

local PlayerData = require(ServerModules:WaitForChild("PlayerData"))
local CombatSystem = require(ServerModules:WaitForChild("CombatSystem"))
local QuestSystem = require(ServerModules:WaitForChild("QuestSystem"))
local ShopSystem = require(ServerModules:WaitForChild("ShopSystem"))
local DialogueSystem = require(ServerModules:WaitForChild("DialogueSystem"))
local WorldBuilder = require(ServerModules:WaitForChild("WorldBuilder"))

print("[Server] All modules loaded!")

-- ============================================
-- CREATE EVENTS
-- ============================================

local Events = Instance.new("Folder")
Events.Name = "Events"
Events.Parent = ReplicatedStorage

local function makeEvent(name)
    local e = Instance.new("RemoteEvent")
    e.Name = name
    e.Parent = Events
    return e
end

local AttackEvent = makeEvent("AttackEvent")
local ShopEvent = makeEvent("ShopEvent")
local QuestEvent = makeEvent("QuestEvent")
local DialogueEvent = makeEvent("DialogueEvent")
local UpdateEvent = makeEvent("UpdateEvent")

-- Events table for modules
local events = {
    AttackEvent = AttackEvent,
    ShopEvent = ShopEvent,
    QuestEvent = QuestEvent,
    DialogueEvent = DialogueEvent,
    UpdateEvent = UpdateEvent,
}

print("[Server] Events created!")

-- ============================================
-- PLAYER CONNECTIONS
-- ============================================

Players.PlayerAdded:Connect(function(player)
    PlayerData:Init(player)
    
    -- Send initial data after character loads
    player.CharacterAdded:Connect(function()
        task.wait(1)
        PlayerData:SendUpdate(player, events)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    PlayerData:Save(player)
    PlayerData:Remove(player)
end)

print("[Server] Player connections ready!")

-- ============================================
-- EVENT HANDLERS
-- ============================================

-- Combat
AttackEvent.OnServerEvent:Connect(function(player, monsterPart)
    CombatSystem:HandleAttack(player, monsterPart, PlayerData, events)
end)

-- Shop
ShopEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = PlayerData:Get(player)
    if not pData then return end
    
    if action == "open" then
        ShopSystem:OpenShop(player, pData, data.shopId, events)
    elseif action == "buy" then
        ShopSystem:BuyItem(player, pData, data.itemId, events)
    end
end)

-- Quest
QuestEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = PlayerData:Get(player)
    if not pData then return end
    
    if action == "accept" then
        QuestSystem:AcceptQuest(player, pData, data.questId, events)
    end
end)

-- Dialogue
DialogueEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = PlayerData:Get(player)
    if not pData then return end
    
    if action == "talk" then
        DialogueSystem:Talk(player, pData, data.npcId, events)
    elseif action == "respond" then
        DialogueSystem:Respond(player, pData, data.npcId, data.responseText, events)
    end
end)

print("[Server] Event handlers ready!")

-- ============================================
-- BUILD WORLD
-- ============================================

WorldBuilder:Build()

print("[Server] ==========================================")
print("[Server] Arcadia Online Server READY!")
print("[Server] ==========================================")
