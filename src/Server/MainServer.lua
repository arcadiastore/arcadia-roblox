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
local EquipEvent = makeEvent("EquipEvent")
local InventoryEvent = makeEvent("InventoryEvent")

-- Events table for modules
local events = {
    AttackEvent = AttackEvent,
    ShopEvent = ShopEvent,
    QuestEvent = QuestEvent,
    DialogueEvent = DialogueEvent,
    UpdateEvent = UpdateEvent,
    EquipEvent = EquipEvent,
    InventoryEvent = InventoryEvent,
}

print("[Server] Events created!")

-- ============================================
-- PLAYER CONNECTIONS
-- ============================================

Players.PlayerAdded:Connect(function(player)
    PlayerData:Init(player)
    
    -- Track when character dies
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function()
                -- Reset HP in data immediately on death
                local pData = PlayerData:Get(player)
                if pData then
                    pData.hp = 0
                    PlayerData:SendUpdate(player, events)
                    print("[Server] " .. player.Name .. " died - HP set to 0")
                end
            end)
        end
        
        -- Reset HP to max on respawn (after death)
        task.wait(2)  -- Wait for respawn to complete
        
        local pData = PlayerData:Get(player)
        if pData then
            pData.hp = pData.maxHp or 100
            pData.mp = pData.maxMp or 50
            
            -- Get new Humanoid (after respawn)
            local newChar = player.Character
            if newChar then
                local newHumanoid = newChar:FindFirstChild("Humanoid")
                if newHumanoid then
                    newHumanoid.MaxHealth = pData.maxHp or 100
                    newHumanoid.Health = pData.maxHp or 100
                end
            end
            
            PlayerData:SendUpdate(player, events)
            print("[Server] " .. player.Name .. " respawned - HP reset to " .. pData.hp)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    -- PlayerData:Save(player) -- Disabled in Studio mode
    PlayerData:Remove(player)
end)

-- Init players who joined BEFORE this script connected
for _, player in ipairs(Players:GetPlayers()) do
    if not PlayerData:Get(player) then
        print("[Server] Late init for: " .. player.Name)
        PlayerData:Init(player)
        if player.Character then
            task.wait(1)
            PlayerData:SendUpdate(player, events)
        end
    end
end

print("[Server] Player connections ready!")

-- ============================================
-- EVENT HANDLERS
-- ============================================

-- Combat
AttackEvent.OnServerEvent:Connect(function(player, monsterPart)
    print("[Server] AttackEvent received from " .. player.Name)
    local pData = PlayerData:Get(player)
    if not pData then
        PlayerData:Init(player)
        pData = PlayerData:Get(player)
    end
    CombatSystem:HandleAttack(player, monsterPart, PlayerData, events)
end)

-- Shop
ShopEvent.OnServerEvent:Connect(function(player, action, data)
    print("[Server] ShopEvent: " .. player.Name .. " -> " .. action)
    local pData = PlayerData:Get(player)
    if not pData then
        PlayerData:Init(player)
        pData = PlayerData:Get(player)
    end
    if not pData then warn("[Server] Still no player data!") return end
    
    if action == "open" then
        ShopSystem:OpenShop(player, pData, data.shopId, events)
    elseif action == "buy" then
        ShopSystem:BuyItem(player, pData, data.itemId, events)
    end
end)

-- Quest
QuestEvent.OnServerEvent:Connect(function(player, action, data)
    print("[Server] QuestEvent: " .. player.Name .. " -> " .. action)
    local pData = PlayerData:Get(player)
    if not pData then
        PlayerData:Init(player)
        pData = PlayerData:Get(player)
    end
    if not pData then warn("[Server] Still no player data!") return end
    
    if action == "accept" then
        QuestSystem:AcceptQuest(player, pData, data.questId, events)
    end
end)

-- Dialogue
DialogueEvent.OnServerEvent:Connect(function(player, action, data)
    print("[Server] DialogueEvent: " .. player.Name .. " -> " .. action .. " -> " .. tostring(data.npcId))
    local pData = PlayerData:Get(player)
    if not pData then
        warn("[Server] No player data for " .. player.Name .. " - auto initializing...")
        PlayerData:Init(player)
        pData = PlayerData:Get(player)
    end
    if not pData then warn("[Server] Still no player data!") return end
    
    if action == "talk" then
        local result = DialogueSystem:Talk(player, pData, data.npcId, events)
        print("[Server] Talk result: " .. tostring(result))
    elseif action == "respond" then
        local result = DialogueSystem:Respond(player, pData, data.npcId, data.responseText, events)
        print("[Server] Respond result: " .. tostring(result))
    elseif action == "auto_report" then
        -- Open dialogue with NPC (NOT auto-complete!)
        local result = DialogueSystem:Talk(player, pData, data.npcId, events)
        print("[Server] AutoReport talk result: " .. tostring(result))
    end
end)

-- Equipment
EquipEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = PlayerData:Get(player)
    if not pData then
        PlayerData:Init(player)
        pData = PlayerData:Get(player)
    end
    if not pData then return end
    
    if action == "equip" then
        local success, msg = PlayerData:EquipItem(player, data.itemId, data.slot, events)
        if not success then
            EquipEvent:FireClient(player, {type = "Error", message = msg})
        else
            EquipEvent:FireClient(player, {type = "Success", message = msg})
        end
    elseif action == "unequip" then
        local success, msg = PlayerData:UnequipItem(player, data.slot, events)
        if not success then
            EquipEvent:FireClient(player, {type = "Error", message = msg})
        else
            EquipEvent:FireClient(player, {type = "Success", message = msg})
        end
    end
end)

-- Inventory (use consumable)
InventoryEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = PlayerData:Get(player)
    if not pData then
        PlayerData:Init(player)
        pData = PlayerData:Get(player)
    end
    if not pData then return end
    
    if action == "use" then
        local itemId = data.itemId
        local itemData = GameData.Items and GameData.Items[itemId]
        if not itemData then return end
        
        if itemData.type == "consumable" then
            if PlayerData:HasItem(player, itemId, 1) then
                -- Apply effect
                if itemData.effect then
                    if itemData.effect.stat == "hp" then
                        pData.hp = math.min(pData.hp + itemData.effect.value, pData.maxHp)
                    elseif itemData.effect.stat == "mp" then
                        pData.mp = math.min((pData.mp or 0) + itemData.effect.value, pData.maxMp or 50)
                    end
                end
                PlayerData:RemoveItem(player, itemId, 1, events)
                InventoryEvent:FireClient(player, {type = "Used", itemName = itemData.name})
            end
        end
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
