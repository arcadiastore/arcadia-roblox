--[[
    Arcadia Online - Main Server Script
    
    Initializes all server-side systems.
    
    Place di: ServerScriptService (as Script)
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for modules to load
task.wait(1)

-- Load systems safely
local function safeRequire(module)
    local success, result = pcall(require, module)
    if success then
        return result
    else
        warn("[MainServer] Failed to load module: " .. module.Name .. " - " .. tostring(result))
        return nil
    end
end

-- Load core modules
local GameManager = safeRequire(ServerScriptService:WaitForChild("Core"):WaitForChild("GameManager"))
local SaveManager = safeRequire(ServerScriptService:WaitForChild("Systems"):WaitForChild("SaveManager"))

-- Initialize
if GameManager then
    GameManager:Init()
end

if SaveManager then
    SaveManager:SetupConnections()
end

-- Setup RemoteEvents
local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
if not EventsFolder then
    EventsFolder = Instance.new("Folder")
    EventsFolder.Name = "Events"
    EventsFolder.Parent = ReplicatedStorage
end

-- Create RemoteEvents if they don't exist
local function getOrCreateEvent(name)
    local event = EventsFolder:FindFirstChild(name)
    if not event then
        event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = EventsFolder
    end
    return event
end

local CombatEvent = getOrCreateEvent("CombatEvent")
local QuestEvent = getOrCreateEvent("QuestEvent")
local ShopEvent = getOrCreateEvent("ShopEvent")
local NPCEvent = getOrCreateEvent("NPCEvent")
local NotificationEvent = getOrCreateEvent("NotificationEvent")

-- Handle Combat
CombatEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "attack" then
        -- Handle attack
        print("[Combat] " .. player.Name .. " attacks")
    end
end)

-- Handle NPC Interaction
NPCEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "talk" then
        -- Handle NPC talk
        print("[NPC] " .. player.Name .. " talks to " .. tostring(data.npcId))
        
        -- Send response back to client
        NPCEvent:FireClient(player, "dialogue", {
            npcName = data.npcId,
            text = "Hello, adventurer!",
        })
    end
end)

-- Handle Quest
QuestEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "accept" then
        print("[Quest] " .. player.Name .. " accepts quest: " .. tostring(data.questId))
    elseif action == "complete" then
        print("[Quest] " .. player.Name .. " completes quest: " .. tostring(data.questId))
    end
end)

-- Handle Shop
ShopEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "buy" then
        print("[Shop] " .. player.Name .. " buys: " .. tostring(data.itemId))
    elseif action == "sell" then
        print("[Shop] " .. player.Name .. " sells: " .. tostring(data.itemId))
    end
end)

print("[MainServer] Arcadia Online server initialized!")
