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
    
    -- Setup character
    self:SetupCharacter(player)
end

-- Handle player leaving
function GameManager:OnPlayerRemoving(player)
    print("[GameManager] Player left: " .. player.Name)
    
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

-- Initialize world
function GameManager:InitWorld()
    print("[GameManager] Initializing world...")
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

return GameManager
