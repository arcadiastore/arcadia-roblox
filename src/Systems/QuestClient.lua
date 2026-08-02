--[[
    Arcadia Online - Quest Client (v2 - Data-Driven)
    
    Baca data dari GameData (via server events)
    Tidak ada hardcode!
    
    Place di: StarterPlayerScripts/Client (as LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

print("[QuestClient] Quest Client initializing...")

-- Wait for Events
local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
if not eventsFolder then return end

local questEvent = eventsFolder:WaitForChild("QuestEvent", 10)
if not questEvent then return end

-- ============================================
-- CLIENT DATA (from server)
-- ============================================

local activeQuests = {}

-- ============================================
-- QUEST TRACKER (Always visible)
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuestUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Tracker frame
local trackerFrame = Instance.new("Frame")
trackerFrame.Name = "Tracker"
trackerFrame.Size = UDim2.new(0, 250, 0, 100)
trackerFrame.Position = UDim2.new(1, -260, 0, 10)
trackerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
trackerFrame.BackgroundTransparency = 0.3
trackerFrame.BorderSizePixel = 0
trackerFrame.Parent = screenGui

local trackerCorner = Instance.new("UICorner")
trackerCorner.CornerRadius = UDim.new(0, 8)
trackerCorner.Parent = trackerFrame

local trackerTitle = Instance.new("TextLabel")
trackerTitle.Size = UDim2.new(1, -10, 0, 25)
trackerTitle.Position = UDim2.new(0, 5, 0, 5)
trackerTitle.BackgroundTransparency = 1
trackerTitle.Text = "Active Quest"
trackerTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
trackerTitle.TextStrokeTransparency = 0
trackerTitle.TextScaled = true
trackerTitle.Font = Enum.Font.GothamBold
trackerTitle.TextXAlignment = Enum.TextXAlignment.Left
trackerTitle.Parent = trackerFrame

local trackerQuestName = Instance.new("TextLabel")
trackerQuestName.Size = UDim2.new(1, -10, 0, 20)
trackerQuestName.Position = UDim2.new(0, 5, 0, 30)
trackerQuestName.BackgroundTransparency = 1
trackerQuestName.Text = "No active quest"
trackerQuestName.TextColor3 = Color3.fromRGB(255, 255, 255)
trackerQuestName.TextStrokeTransparency = 0
trackerQuestName.TextScaled = true
trackerQuestName.Font = Enum.Font.Gotham
trackerQuestName.TextXAlignment = Enum.TextXAlignment.Left
trackerQuestName.Parent = trackerFrame

local trackerProgress = Instance.new("TextLabel")
trackerProgress.Size = UDim2.new(1, -10, 0, 40)
trackerProgress.Position = UDim2.new(0, 5, 0, 50)
trackerProgress.BackgroundTransparency = 1
trackerProgress.Text = ""
trackerProgress.TextColor3 = Color3.fromRGB(200, 200, 200)
trackerProgress.TextStrokeTransparency = 0
trackerProgress.TextScaled = true
trackerProgress.Font = Enum.Font.Gotham
trackerProgress.TextXAlignment = Enum.TextXAlignment.Left
trackerProgress.TextWrapped = true
trackerProgress.Parent = trackerFrame

-- ============================================
-- QUEST JOURNAL
-- ============================================

local journalFrame = Instance.new("Frame")
journalFrame.Name = "Journal"
journalFrame.Size = UDim2.new(0, 400, 0, 500)
journalFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
journalFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
journalFrame.BorderSizePixel = 0
journalFrame.Visible = false
journalFrame.Parent = screenGui

local journalCorner = Instance.new("UICorner")
journalCorner.CornerRadius = UDim.new(0, 10)
journalCorner.Parent = journalFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = journalFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Quest Journal"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextStrokeTransparency = 0
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

-- Quest list
local questList = Instance.new("ScrollingFrame")
questList.Size = UDim2.new(1, -20, 1, -50)
questList.Position = UDim2.new(0, 10, 0, 45)
questList.BackgroundTransparency = 1
questList.ScrollBarThickness = 8
questList.Parent = journalFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = questList

-- ============================================
-- INTERACTION PROMPT
-- ============================================

local promptFrame = Instance.new("Frame")
promptFrame.Name = "InteractionPrompt"
promptFrame.Size = UDim2.new(0, 200, 0, 50)
promptFrame.Position = UDim2.new(0.5, -100, 0.7, 0)
promptFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
promptFrame.BackgroundTransparency = 0.3
promptFrame.BorderSizePixel = 0
promptFrame.Visible = false
promptFrame.Parent = screenGui

local promptCorner = Instance.new("UICorner")
promptCorner.CornerRadius = UDim.new(0, 8)
promptCorner.Parent = promptFrame

local promptKey = Instance.new("TextLabel")
promptKey.Size = UDim2.new(0, 40, 1, 0)
promptKey.Position = UDim2.new(0, 5, 0, 0)
promptKey.BackgroundTransparency = 1
promptKey.Text = "[F]"
promptKey.TextColor3 = Color3.fromRGB(255, 215, 0)
promptKey.TextStrokeTransparency = 0
promptKey.TextScaled = true
promptKey.Font = Enum.Font.GothamBold
promptKey.Parent = promptFrame

local promptText = Instance.new("TextLabel")
promptText.Size = UDim2.new(1, -50, 1, 0)
promptText.Position = UDim2.new(0, 45, 0, 0)
promptText.BackgroundTransparency = 1
promptText.Text = "Interact"
promptText.TextColor3 = Color3.fromRGB(255, 255, 255)
promptText.TextStrokeTransparency = 0
promptText.TextScaled = true
promptText.Font = Enum.Font.Gotham
promptText.TextXAlignment = Enum.TextXAlignment.Left
promptText.Parent = promptFrame

-- ============================================
-- UI UPDATE FUNCTIONS
-- ============================================

local function updateTracker()
    local quest = nil
    for id, q in pairs(activeQuests) do
        quest = q
        break
    end
    
    if quest then
        trackerQuestName.Text = quest.name
        local progressText = ""
        for _, obj in ipairs(quest.objectives) do
            progressText = progressText .. obj.target .. ": " .. obj.current .. "/" .. obj.count .. "\n"
        end
        trackerProgress.Text = progressText
    else
        trackerQuestName.Text = "No active quest"
        trackerProgress.Text = ""
    end
end

local function updateJournalList()
    for _, child in ipairs(questList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local hasQuests = false
    for _ in pairs(activeQuests) do
        hasQuests = true
        break
    end
    
    if not hasQuests then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 50)
        empty.BackgroundTransparency = 1
        empty.Text = "No active quests\nTalk to Elder Tetua!"
        empty.TextColor3 = Color3.fromRGB(150, 150, 150)
        empty.TextScaled = true
        empty.Font = Enum.Font.Gotham
        empty.Parent = questList
        return
    end
    
    for questId, quest in pairs(activeQuests) do
        local questFrame = Instance.new("Frame")
        questFrame.Name = questId
        questFrame.Size = UDim2.new(1, 0, 0, 80)
        questFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        questFrame.BorderSizePixel = 0
        questFrame.Parent = questList
        
        local qCorner = Instance.new("UICorner")
        qCorner.CornerRadius = UDim.new(0, 5)
        qCorner.Parent = questFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -10, 0, 25)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = quest.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = questFrame
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -10, 0, 20)
        descLabel.Position = UDim2.new(0, 5, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = quest.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextStrokeTransparency = 0
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = questFrame
        
        local objText = ""
        for _, obj in ipairs(quest.objectives) do
            local status = obj.current >= obj.count and "✓" or "○"
            objText = objText .. status .. " " .. obj.target .. ": " .. obj.current .. "/" .. obj.count .. "\n"
        end
        
        local objLabel = Instance.new("TextLabel")
        objLabel.Size = UDim2.new(1, -10, 0, 30)
        objLabel.Position = UDim2.new(0, 5, 0, 50)
        objLabel.BackgroundTransparency = 1
        objLabel.Text = objText
        objLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        objLabel.TextStrokeTransparency = 0
        objLabel.TextScaled = true
        objLabel.Font = Enum.Font.Gotham
        objLabel.TextXAlignment = Enum.TextXAlignment.Left
        objLabel.Parent = questFrame
    end
end

-- ============================================
-- INPUT HANDLING
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.J then
        journalFrame.Visible = not journalFrame.Visible
        if journalFrame.Visible then
            updateJournalList()
        end
    end
end)

closeButton.MouseButton1Click:Connect(function()
    journalFrame.Visible = false
end)

-- NPC hover detection
mouse.Move:Connect(function()
    local target = mouse.Target
    if target then
        local npcId = target:GetAttribute("NPCId")
        if npcId then
            -- Get NPC data from GameData
            local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
            local npcData = GameData:GetNPC(npcId)
            
            if npcData then
                local interactionText = "Talk to " .. npcData.name
                if npcData.hasShop then
                    interactionText = "Open Shop - " .. npcData.name
                elseif npcData.hasQuest then
                    interactionText = "Accept Quest - " .. npcData.name
                end
                
                promptText.Text = interactionText
                promptFrame.Visible = true
            end
        else
            local monsterId = target:GetAttribute("MonsterId")
            if monsterId then
                local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
                local monsterData = GameData:GetMonster(monsterId)
                if monsterData then
                    promptText.Text = "Attack " .. monsterData.name
                    promptFrame.Visible = true
                end
            else
                promptFrame.Visible = false
            end
        end
    else
        promptFrame.Visible = false
    end
end)

-- ============================================
-- QUEST EVENT HANDLING
-- ============================================

questEvent.OnClientEvent:Connect(function(data)
    if data.type == "QuestAccepted" then
        activeQuests[data.quest.id] = {
            id = data.quest.id,
            name = data.quest.name,
            description = data.quest.description,
            objectives = data.quest.objectives,
            rewards = data.quest.rewards,
        }
        
        updateTracker()
        if journalFrame.Visible then
            updateJournalList()
        end
        
        print("[QuestClient] Quest accepted: " .. data.quest.name)
        
    elseif data.type == "QuestProgress" then
        if activeQuests[data.questId] then
            for _, obj in ipairs(activeQuests[data.questId].objectives) do
                if obj.target == data.objective.target then
                    obj.current = data.objective.current
                end
            end
        end
        
        updateTracker()
        if journalFrame.Visible then
            updateJournalList()
        end
        
        print("[QuestClient] Progress: " .. data.objective.target .. " " .. data.objective.current .. "/" .. data.objective.count)
        
    elseif data.type == "QuestCompleted" then
        activeQuests[data.questId] = nil
        
        updateTracker()
        if journalFrame.Visible then
            updateJournalList()
        end
        
        print("[QuestClient] Quest completed!")
    end
end)

print("[QuestClient] Quest Client ready!")
