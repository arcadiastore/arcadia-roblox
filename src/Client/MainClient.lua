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
local EquipEvent = Events:WaitForChild("EquipEvent")
local InventoryEvent = Events:WaitForChild("InventoryEvent")

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
local EquipmentUI = require(ClientModules:WaitForChild("EquipmentUI"))
local InventoryUI = require(ClientModules:WaitForChild("InventoryUI"))
local AutoPanel = require(ClientModules:WaitForChild("AutoPanel"))

print("[Client] All modules loaded!")

-- ============================================
-- CREATE UI
-- ============================================

HUD:Create(playerGui)
QuestTracker:Create(HUD:GetGUI())
ShopUI:Create(HUD:GetGUI())
DialogueUI:Create(HUD:GetGUI())
Notification:Create(HUD:GetGUI())
EquipmentUI:Create(playerGui)
InventoryUI:Create(playerGui)
AutoPanel:Create(playerGui)
QuestTracker:SetAutoPanel(AutoPanel)

print("[Client] All UI created!")

-- ============================================
-- EVENT HANDLERS
-- ============================================

-- Update handler
UpdateEvent.OnClientEvent:Connect(function(data)
    if data.type == "Damage" then
        print("[Client] Damage: -" .. data.damage .. " to " .. tostring(data.monsterName) .. " HP:" .. data.currentHP .. "/" .. data.maxHP)
        
        -- Find monster in workspace
        local monsterFolder = workspace:FindFirstChild("Monsters")
        if monsterFolder and data.monsterName then
            local monsterPart = monsterFolder:FindFirstChild(data.monsterName)
            print("[Client] Looking for: " .. data.monsterName .. " Found: " .. tostring(monsterPart))
            
            if monsterPart then
                -- List children for debug
                for _, child in ipairs(monsterPart:GetChildren()) do
                    print("[Client]   Child: " .. child.Name .. " (" .. child.ClassName .. ")")
                end
                -- Update HP label
                local billboard = monsterPart:FindFirstChild("NameTag")
                if billboard then
                    local hpLabel = billboard:FindFirstChild("HPLabel")
                    if hpLabel then
                        hpLabel.Text = "HP: " .. data.currentHP .. "/" .. data.maxHP
                        local pct = data.currentHP / data.maxHP
                        if pct > 0.5 then
                            hpLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                        elseif pct > 0.25 then
                            hpLabel.TextColor3 = Color3.fromRGB(255, 255, 50)
                        else
                            hpLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                        end
                        print("[Client] HP updated: " .. hpLabel.Text)
                    end
                end
                -- Show damage popup
                DamagePopup:Show(monsterPart, data.damage)
            else
                warn("[Client] Monster not found: " .. data.monsterName)
            end
        end
        
    elseif data.type == "Update" then
        HUD:Update(data)
        QuestTracker:Update(data)
        AutoPanel:Update(data)
        EquipmentUI:Update(data)
        InventoryUI:Update(data)
        
    elseif data.type == "QuestAccepted" then
        Notification:QuestAccepted(data.questName)
        
    elseif data.type == "QuestCompleted" then
        Notification:QuestCompleted(data.questName, data.rewards)
        
    elseif data.type == "QuestReady" then
        AutoPanel:QuestReady(data.questId)
        local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
        local npcData = GameData:GetNPC(data.npcName)
        local npcName = npcData and npcData.name or tostring(data.npcName)
        local questName = data.questName or "Quest"
        Notification:QuestReady(questName, npcName)
        
    elseif data.type == "MonsterAttack" then
        -- Show monster attack notification
        Notification:Show(data.monsterName .. " menyerang! -" .. data.damage .. " HP", Color3.fromRGB(255, 80, 80), 2)
        
    elseif data.type == "MonsterRespawn" then
        -- Reset HP display on respawned monster
        local monsterFolder = workspace:FindFirstChild("Monsters")
        if monsterFolder and data.monsterName then
            local monsterPart = monsterFolder:FindFirstChild(data.monsterName)
            if monsterPart then
                local billboard = monsterPart:FindFirstChild("NameTag")
                if billboard then
                    local hpLabel = billboard:FindFirstChild("HPLabel")
                    if hpLabel then
                        hpLabel.Text = "HP: " .. data.maxHP .. "/" .. data.maxHP
                        hpLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                    end
                end
            end
        end
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

-- Equipment event handler
EquipEvent.OnClientEvent:Connect(function(data)
    if data.type == "Success" then
        Notification:Show(data.message or "Equipment updated!", Color3.fromRGB(100, 255, 100))
    elseif data.type == "Error" then
        Notification:Show(data.message or "Equipment error!", Color3.fromRGB(255, 100, 100))
    end
end)

-- Inventory event handler
InventoryEvent.OnClientEvent:Connect(function(data)
    if data.type == "Used" then
        Notification:Show("Used: " .. (data.itemName or "item"), Color3.fromRGB(100, 200, 255))
    end
end)

-- Keyboard shortcuts
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    -- Skip if typing in a TextBox
    local focused = playerGui:FindFirstChildWhichIsA("TextBox", true)
    if focused and focused:IsFocused() then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        print("[Client] E pressed")
        EquipmentUI:Toggle()
        if EquipmentUI:IsOpen() and InventoryUI:IsOpen() then
            InventoryUI:Toggle()
        end
    elseif input.KeyCode == Enum.KeyCode.B then
        print("[Client] B pressed - Inventory")
        InventoryUI:Toggle()
        if InventoryUI:IsOpen() and EquipmentUI:IsOpen() then
            EquipmentUI:Toggle()
        end
    end
end)

print("[Client] Equipment & Inventory connected!")

print("[Client] ==========================================")
print("[Client] Arcadia Online Client READY!")
print("[Client] ==========================================")
