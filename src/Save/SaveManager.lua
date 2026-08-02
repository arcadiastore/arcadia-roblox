--[[
    Arcadia Online - Save Manager
    
    Handles save/load system using Roblox DataStore.
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")

local SaveManager = {}
SaveManager.__index = SaveManager

-- DataStore (lazy load to avoid Studio errors)
local DataStoreService = nil
local playerDataStore = nil

-- Default player data
local DEFAULT_DATA = {
    level = 1,
    exp = 0,
    gold = 100,
    job = nil,
    stats = {
        STR = 0,
        AGI = 0,
        INT = 0,
        VIT = 0,
        DEX = 0,
        LUK = 0,
    },
    inventory = {
        items = {},
        equipment = {},
    },
    quests = {
        active = {},
        completed = {},
    },
    position = { x = 0, y = 5, z = 0 },
    settings = {
        musicVolume = 0.5,
        sfxVolume = 0.5,
    },
    firstJoin = 0,
    lastJoin = 0,
    playTime = 0,
}

function SaveManager.new()
    local self = setmetatable({}, SaveManager)
    
    self.playerData = {}
    self.autoSaveInterval = 300
    self.isStudio = game:GetService("RunService"):IsStudio()
    
    -- Try to initialize DataStore
    self:InitDataStore()
    
    return self
end

-- Initialize DataStore safely
function SaveManager:InitDataStore()
    if self.isStudio then
        warn("[SaveManager] Running in Studio - DataStore disabled")
        return
    end
    
    local success, result = pcall(function()
        DataStoreService = game:GetService("DataStoreService")
        playerDataStore = DataStoreService:GetDataStore("ArcadiaOnline_PlayerData_v1")
    end)
    
    if success then
        print("[SaveManager] DataStore initialized")
    else
        warn("[SaveManager] DataStore not available: " .. tostring(result))
    end
end

-- Load player data
function SaveManager:LoadPlayer(player)
    local userId = player.UserId
    
    -- In Studio, use default data
    if self.isStudio or not playerDataStore then
        self.playerData[userId] = self:CreateDefaultData()
        self.playerData[userId].firstJoin = os.time()
        self.playerData[userId].lastJoin = os.time()
        print("[SaveManager] Using default data for: " .. player.Name)
        return self.playerData[userId]
    end
    
    -- Try to load from DataStore
    local key = "Player_" .. userId
    
    local success, data = pcall(function()
        return playerDataStore:GetAsync(key)
    end)
    
    if success and data then
        self.playerData[userId] = self:MergeWithDefaults(data)
        print("[SaveManager] Loaded data for: " .. player.Name)
    else
        self.playerData[userId] = self:CreateDefaultData()
        self.playerData[userId].firstJoin = os.time()
        print("[SaveManager] New player: " .. player.Name)
    end
    
    self.playerData[userId].lastJoin = os.time()
    
    return self.playerData[userId]
end

-- Save player data
function SaveManager:SavePlayer(player)
    local userId = player.UserId
    
    if not self.playerData[userId] then
        return false
    end
    
    -- In Studio, skip saving
    if self.isStudio or not playerDataStore then
        print("[SaveManager] Studio mode - skipping save for: " .. player.Name)
        return true
    end
    
    local key = "Player_" .. userId
    
    local success, err = pcall(function()
        playerDataStore:SetAsync(key, self.playerData[userId])
    end)
    
    if success then
        print("[SaveManager] Saved data for: " .. player.Name)
        return true
    else
        warn("[SaveManager] Failed to save: " .. tostring(err))
        return false
    end
end

-- Create default data
function SaveManager:CreateDefaultData()
    local data = {}
    for key, value in pairs(DEFAULT_DATA) do
        if type(value) == "table" then
            data[key] = {}
            for k, v in pairs(value) do
                data[key][k] = v
            end
        else
            data[key] = value
        end
    end
    return data
end

-- Merge loaded data with defaults
function SaveManager:MergeWithDefaults(loadedData)
    local data = self:CreateDefaultData()
    
    for key, value in pairs(loadedData) do
        if data[key] ~= nil then
            if type(value) == "table" and type(data[key]) == "table" then
                for k, v in pairs(value) do
                    data[key][k] = v
                end
            else
                data[key] = value
            end
        end
    end
    
    return data
end

-- Get player data
function SaveManager:GetPlayerData(player)
    local userId = player.UserId
    return self.playerData[userId]
end

-- Update player data
function SaveManager:UpdatePlayerData(player, key, value)
    local userId = player.UserId
    if self.playerData[userId] then
        self.playerData[userId][key] = value
    end
end

-- Get specific data field
function SaveManager:GetData(player, key)
    local userId = player.UserId
    if self.playerData[userId] then
        return self.playerData[userId][key]
    end
    return nil
end

-- Set specific data field
function SaveManager:SetData(player, key, value)
    local userId = player.UserId
    if self.playerData[userId] then
        self.playerData[userId][key] = value
    end
end

-- Start auto-save
function SaveManager:StartAutoSave()
    task.spawn(function()
        while true do
            task.wait(self.autoSaveInterval)
            
            for _, player in ipairs(Players:GetPlayers()) do
                self:SavePlayer(player)
            end
            
            print("[SaveManager] Auto-save completed")
        end
    end)
end

-- Save all players
function SaveManager:SaveAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        self:SavePlayer(player)
    end
end

-- Setup player connections
function SaveManager:SetupConnections()
    Players.PlayerAdded:Connect(function(player)
        self:LoadPlayer(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:SavePlayer(player)
        self.playerData[player.UserId] = nil
    end)
    
    game:BindToClose(function()
        self:SaveAllPlayers()
    end)
    
    -- Start auto-save
    self:StartAutoSave()
end

return SaveManager
