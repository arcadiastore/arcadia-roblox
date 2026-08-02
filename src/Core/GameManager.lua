--[[
    Arcadia Online - Game Manager
    
    Core game manager that handles:
    - Game initialization
    - Player connections
    - Game state management
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Game Configuration
local GameConfig = {
    GAME_NAME = "Arcadia Online",
    VERSION = "1.0.0",
    MAX_PLAYERS = 50,
    STARTING_LEVEL = 1,
    MAX_LEVEL = 100,
    STARTING_GOLD = 100,
    STARTING_POSITION = Vector3.new(0, 5, 0),
}

-- Game State
local GameState = {
    Players = {},
    ActiveQuests = {},
    WorldState = {},
}

-- Game Manager Class
local GameManager = {}
GameManager.__index = GameManager

function GameManager.new()
    local self = setmetatable({}, GameManager)
    
    self.config = GameConfig
    self.state = GameState
    self.modules = {}
    
    return self
end

-- Initialize the game
function GameManager:Init()
    print("[GameManager] Initializing Arcadia Online v" .. self.config.VERSION)
    
    -- Load core modules
    self:LoadModules()
    
    -- Setup player connections
    self:SetupPlayerConnections()
    
    -- Initialize world
    self:InitWorld()
    
    print("[GameManager] Game initialized successfully!")
end

-- Load all game modules
function GameManager:LoadModules()
    local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
    if modulesFolder then
        for _, module in ipairs(modulesFolder:GetChildren()) do
            if module:IsA("ModuleScript") then
                local success, result = pcall(require, module)
                if success then
                    self.modules[module.Name] = result
                    print("[GameManager] Loaded module: " .. module.Name)
                else
                    warn("[GameManager] Failed to load module: " .. module.Name .. " - " .. tostring(result))
                end
            end
        end
    end
end

-- Setup player connection events
function GameManager:SetupPlayerConnections()
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
end

-- Handle player joining
function GameManager:OnPlayerAdded(player)
    print("[GameManager] Player joined: " .. player.Name)
    
    -- Create player data
    local playerData = {
        player = player,
        level = self.config.STARTING_LEVEL,
        exp = 0,
        gold = self.config.STARTING_GOLD,
        job = nil,
        stats = {},
        inventory = {},
        quests = {},
        position = self.config.STARTING_POSITION,
    }
    
    -- Store player data
    self.state.Players[player.UserId] = playerData
    
    -- Load saved data (if exists)
    self:LoadPlayerData(player)
    
    -- Setup character
    self:SetupCharacter(player)
end

-- Handle player leaving
function GameManager:OnPlayerRemoving(player)
    print("[GameManager] Player left: " .. player.Name)
    
    -- Save player data
    self:SavePlayerData(player)
    
    -- Remove from state
    self.state.Players[player.UserId] = nil
end

-- Setup player character
function GameManager:SetupCharacter(player)
    player.CharacterAdded:Connect(function(character)
        -- Teleport to starting position
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(self.config.STARTING_POSITION)
        
        -- Setup character stats
        self:SetupCharacterStats(player, character)
    end)
end

-- Setup character stats
function GameManager:SetupCharacterStats(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    local playerData = self.state.Players[player.UserId]
    
    if playerData then
        -- Set health based on stats
        humanoid.MaxHealth = playerData.stats.maxHp or 100
        humanoid.Health = humanoid.MaxHealth
    end
end

-- Load player data from DataStore
function GameManager:LoadPlayerData(player)
    local DataStoreService = game:GetService("DataStoreService")
    local dataStore = DataStoreService:GetDataStore("PlayerData")
    
    local success, data = pcall(function()
        return dataStore:GetAsync("Player_" .. player.UserId)
    end)
    
    if success and data then
        -- Restore player data
        local playerData = self.state.Players[player.UserId]
        if playerData then
            for key, value in pairs(data) do
                playerData[key] = value
            end
            print("[GameManager] Loaded data for: " .. player.Name)
        end
    else
        print("[GameManager] No saved data for: " .. player.Name)
    end
end

-- Save player data to DataStore
function GameManager:SavePlayerData(player)
    local DataStoreService = game:GetService("DataStoreService")
    local dataStore = DataStoreService:GetDataStore("PlayerData")
    
    local playerData = self.state.Players[player.UserId]
    if playerData then
        local success, err = pcall(function()
            dataStore:SetAsync("Player_" .. player.UserId, playerData)
        end)
        
        if success then
            print("[GameManager] Saved data for: " .. player.Name)
        else
            warn("[GameManager] Failed to save data for: " .. player.Name .. " - " .. tostring(err))
        end
    end
end

-- Initialize world
function GameManager:InitWorld()
    print("[GameManager] Initializing world...")
    
    -- Load world modules
    if self.modules.WorldManager then
        self.modules.WorldManager:Init()
    end
end

-- Get player data
function GameManager:GetPlayerData(player)
    return self.state.Players[player.UserId]
end

-- Update player data
function GameManager:UpdatePlayerData(player, key, value)
    local playerData = self.state.Players[player.UserId]
    if playerData then
        playerData[key] = value
    end
end

-- Broadcast message to all players
function GameManager:Broadcast(message)
    for _, playerData in pairs(self.state.Players) do
        -- Send message to player UI
        -- Implementation depends on UI system
    end
end

-- Return the game manager instance
return GameManager.new()
