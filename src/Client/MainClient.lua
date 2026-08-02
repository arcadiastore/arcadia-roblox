--[[
    Arcadia Online - Main Client Script (Entry Point)
    
    Loads all client modules and connects events.
    Place di: StarterPlayerScripts (as LocalScript)
    
    @author arcadiastore
    @version 5.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[Client] Client starting...")

-- ============================================
-- WAIT FOR EVENTS
-- ============================================

local Events = nil
for i = 1, 30 do
    Events = ReplicatedStorage:FindFirstChild("Events")
    if Events then break end
    task.wait(1)
    if i % 5 == 0 then
        print("[Client] Waiting for Events... " .. i .. "s")
    end
end

if not Events then
    warn("[Client] Events not found after 30 seconds!")
    return
end

local AttackEvent = Events:WaitForChild("AttackEvent")
local ShopEvent = Events:WaitForChild("ShopEvent")
local QuestEvent = Events:WaitForChild("QuestEvent")
local DialogueEvent = Events:WaitForChild("DialogueEvent")
local UpdateEvent = Events:WaitForChild("UpdateEvent")

print("[Client] Events found!")

-- ============================================
-- LOAD CLIENT MODULES
-- ============================================

local ClientModules = script:WaitForChild("ClientModules")

local HUD = require(ClientModules:WaitForChild("HUD"))
local QuestTracker = require(ClientModules:WaitForChild("QuestTracker"))
local ShopUI = require(ClientModules:WaitForChild("ShopUI"))
local DialogueUI = require(ClientModules:WaitForChild("DialogueUI"))
local Notification = require(ClientModules:WaitForChild("Notification"))
local DamagePopup = require(ClientModules:WaitForChild("DamagePopup"))

print("[Client] All modules loaded!")

-- ============================================
-- CREATE UI
-- ============================================

HUD:Create(playerGui)
QuestTracker:Create(HUD:GetGUI())
ShopUI:Create(HUD:GetGUI())
DialogueUI:Create(HUD:GetGUI())
Notification:Create(HUD:GetGUI())

print("[Client] All UI created!")

-- ============================================
-- EVENT HANDLERS
-- ============================================

-- Update handler
UpdateEvent.OnClientEvent:Connect(function(data)
    if data.type == "Damage" then
        -- Show damage popup at monster position
        if data.monsterPart then
            DamagePopup:Show(data.monsterPart, data.damage, {
                currentHP = data.currentHP,
                maxHP = data.maxHP,
            })
        end
        
    elseif data.type == "Update" then
        HUD:Update(data)
        QuestTracker:Update(data)
        
    elseif data.type == "QuestAccepted" then
        Notification:QuestAccepted(data.questName)
        
    elseif data.type == "QuestCompleted" then
        Notification:QuestCompleted(data.questName, data.rewards)
        
    elseif data.type == "QuestReady" then
        local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
        local npcData = GameData:GetNPC(data.npcName)
        local npcName = npcData and npcData.name or data.npcName
        Notification:QuestReady(data.questName, npcName)
    end
end)

print("[Client] Update handler ready!")

-- Shop handler
ShopEvent.OnClientEvent:Connect(function(data)
    if data.type == "Open" then
        ShopUI:Open(data, ShopEvent)
    elseif data.type == "Bought" then
        ShopUI:UpdateGold(data.gold)
    elseif data.type == "Error" then
        warn("[Shop] " .. data.message)
    end
end)

print("[Client] Shop handler ready!")

-- Dialogue handler
DialogueEvent.OnClientEvent:Connect(function(data)
    if data.type == "Start" or data.type == "Continue" then
        DialogueUI:Show(data, DialogueEvent)
    elseif data.type == "End" then
        DialogueUI:Hide()
    end
end)

print("[Client] Dialogue handler ready!")

-- ============================================
-- NPC INTERACTION (Dynamic - watches for new NPCs)
-- ============================================

local function connectNPC(npc)
    local click = npc:FindFirstChild("ClickDetector")
    if click then
        click.MouseClick:Connect(function()
            local npcId = npc:GetAttribute("NPCId") or npc.Name
            print("[Client] Clicked NPC: " .. npcId)
            DialogueEvent:FireServer("talk", {npcId = npcId})
        end)
        print("[Client] Connected NPC: " .. npc.Name)
    else
        warn("[Client] NPC " .. npc.Name .. " has no ClickDetector!")
    end
end

task.spawn(function()
    local npcFolder = workspace:WaitForChild("NPCs", 30)
    if npcFolder then
        -- Connect existing NPCs
        for _, npc in ipairs(npcFolder:GetChildren()) do
            connectNPC(npc)
        end
        -- Connect new NPCs as they spawn
        npcFolder.ChildAdded:Connect(function(npc)
            connectNPC(npc)
        end)
        print("[Client] NPC interactions connected!")
    else
        warn("[Client] NPCs folder not found!")
    end
end)

-- ============================================
-- MONSTER INTERACTION (Dynamic - watches for new monsters)
-- ============================================

local function connectMonster(monster)
    local click = monster:FindFirstChild("ClickDetector")
    if click then
        click.MouseClick:Connect(function()
            AttackEvent:FireServer(monster)
        end)
    end
end

task.spawn(function()
    local monsterFolder = workspace:WaitForChild("Monsters", 30)
    if monsterFolder then
        -- Connect existing monsters
        for _, monster in ipairs(monsterFolder:GetChildren()) do
            connectMonster(monster)
        end
        -- Connect new monsters as they spawn (respawn)
        monsterFolder.ChildAdded:Connect(function(monster)
            connectMonster(monster)
        end)
        print("[Client] Monster interactions connected!")
    else
        warn("[Client] Monsters folder not found!")
    end
end)

print("[Client] ==========================================")
print("[Client] Arcadia Online Client READY!")
print("[Client] ==========================================")
