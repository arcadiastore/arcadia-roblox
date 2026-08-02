--[[
    Arcadia Online - Dialogue System (v2 - Data-Driven)
    
    Semua data dari GameData module
    Tidak ada hardcode!
    
    Place di: ServerScriptService/Systems (as Script)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for GameData
task.wait(3)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

print("[Dialogue] Dialogue System initializing...")

-- ============================================
-- DIALOGUE MANAGER
-- ============================================

local DialogueManager = {}
DialogueManager.__index = DialogueManager

function DialogueManager.new()
    local self = setmetatable({}, DialogueManager)
    self.playerDialogueState = {}
    return self
end

function DialogueManager:Init()
    self:SetupPlayerConnections()
    self:SetupDialogueEvents()
    
    -- Create Events folder if not exists
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if not eventsFolder then
        eventsFolder = Instance.new("Folder")
        eventsFolder.Name = "Events"
        eventsFolder.Parent = ReplicatedStorage
    end
    
    print("[Dialogue] Dialogue System initialized!")
end

function DialogueManager:SetupPlayerConnections()
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
end

function DialogueManager:OnPlayerAdded(player)
    self.playerDialogueState[player.UserId] = {
        currentDialogue = nil,
        currentLine = 1,
    }
    print("[Dialogue] Player dialogue state initialized: " .. player.Name)
end

function DialogueManager:OnPlayerRemoving(player)
    self.playerDialogueState[player.UserId] = nil
end

function DialogueManager:SetupDialogueEvents()
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    
    local dialogueEvent = Instance.new("RemoteEvent")
    dialogueEvent.Name = "DialogueEvent"
    dialogueEvent.Parent = eventsFolder
    
    dialogueEvent.OnServerEvent:Connect(function(player, action, data)
        if action == "start" then
            self:StartDialogue(player, data.npcId)
        elseif action == "next" then
            self:NextDialogueLine(player)
        elseif action == "close" then
            self:CloseDialogue(player)
        end
    end)
end

function DialogueManager:StartDialogue(player, npcId)
    -- Get dialogue data from GameData
    local dialogueData = GameData:GetDialogue(npcId)
    if not dialogueData then
        warn("[Dialogue] Dialogue not found for NPC: " .. npcId)
        return
    end
    
    local state = self.playerDialogueState[player.UserId]
    state.currentDialogue = dialogueData
    state.currentLine = 1
    
    -- Get NPC data from GameData
    local npcData = GameData:GetNPC(npcId)
    local npcName = npcData and npcData.name or npcId
    
    -- Send to client
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local dialogueEvent = eventsFolder:FindFirstChild("DialogueEvent")
    if dialogueEvent then
        dialogueEvent:FireClient(player, {
            type = "DialogueStarted",
            npcId = npcId,
            npcName = npcName,
            line = dialogueData.lines[1],
            lineIndex = 1,
            totalLines = #dialogueData.lines,
        })
    end
    
    print("[Dialogue] " .. player.Name .. " started dialogue with " .. npcName)
end

function DialogueManager:NextDialogueLine(player)
    local state = self.playerDialogueState[player.UserId]
    if not state.currentDialogue then return end
    
    state.currentLine = state.currentLine + 1
    
    if state.currentLine > #state.currentDialogue.lines then
        self:CloseDialogue(player)
        return
    end
    
    local currentLine = state.currentDialogue.lines[state.currentLine]
    
    -- Get NPC data from GameData
    local npcData = GameData:GetNPC(state.currentDialogue.npcId)
    local npcName = npcData and npcData.name or state.currentDialogue.npcId
    
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local dialogueEvent = eventsFolder:FindFirstChild("DialogueEvent")
    if dialogueEvent then
        dialogueEvent:FireClient(player, {
            type = "DialogueLine",
            npcId = state.currentDialogue.npcId,
            npcName = npcName,
            line = currentLine,
            lineIndex = state.currentLine,
            totalLines = #state.currentDialogue.lines,
        })
    end
    
    -- Handle action from GameData
    if currentLine.action then
        self:HandleDialogueAction(player, state.currentDialogue.npcId, currentLine)
    end
    
    print("[Dialogue] " .. player.Name .. " - Line " .. state.currentLine)
end

function DialogueManager:CloseDialogue(player)
    local state = self.playerDialogueState[player.UserId]
    state.currentDialogue = nil
    state.currentLine = 1
    
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local dialogueEvent = eventsFolder:FindFirstChild("DialogueEvent")
    if dialogueEvent then
        dialogueEvent:FireClient(player, {type = "DialogueClosed"})
    end
    
    print("[Dialogue] " .. player.Name .. " closed dialogue")
end

function DialogueManager:HandleDialogueAction(player, npcId, line)
    if line.action == "quest_offer" then
        -- Get NPC data to find quest
        local npcData = GameData:GetNPC(npcId)
        if npcData and npcData.quests then
            -- Find first available quest
            for _, questId in ipairs(npcData.quests) do
                local questData = GameData:GetQuest(questId)
                if questData then
                    if _G.QuestManager then
                        _G.QuestManager:AcceptQuest(player, questId)
                    end
                    break
                end
            end
        end
        
    elseif line.action == "open_shop" then
        -- Get NPC data to find shop
        local npcData = GameData:GetNPC(npcId)
        if npcData and npcData.shopId then
            if _G.ShopManager then
                _G.ShopManager:OpenShop(player, npcData.shopId)
            end
        end
        
    elseif line.action == "tutorial" then
        print("[Dialogue] Tutorial action for " .. player.Name)
    end
end

-- Initialize
local dialogueManager = DialogueManager.new()
dialogueManager:Init()
_G.DialogueManager = dialogueManager

print("[Dialogue] Dialogue System ready!")
