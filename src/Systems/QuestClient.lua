--[[
    Arcadia Online - Quest Client
    
    Handles quest UI and interaction:
    - Accept quests from NPCs
    - Track quest progress
    - Complete quests
    - Quest journal UI
    
    Place di: StarterPlayerScripts/Client (as LocalScript)
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Player reference
local player = Players.LocalPlayer

print("[QuestClient] Quest Client initializing...")

-- Wait for Events folder
local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
if not eventsFolder then
    warn("[QuestClient] Events folder not found!")
    return
end

-- Get RemoteEvents
local questEvent = eventsFolder:WaitForChild("QuestEvent", 10)

if not questEvent then
    warn("[QuestClient] Quest event not found!")
    return
end

print("[QuestClient] Quest event found!")

-- ============================================
-- QUEST UI
-- ============================================

-- Create quest UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuestUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Quest journal frame (hidden by default)
local journalFrame = Instance.new("Frame")
journalFrame.Name = "Journal"
journalFrame.Size = UDim2.new(0, 400, 0, 500)
journalFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
journalFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
journalFrame.BorderSizePixel = 0
journalFrame.Visible = false
journalFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = journalFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleBar.BorderSizePixel = 0
titleBar.Parent = journalFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Quest Journal"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextStrokeTransparency = 0
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
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
questList.Name = "QuestList"
questList.Size = UDim2.new(1, -20, 1, -50)
questList.Position = UDim2.new(0, 10, 0, 45)
questList.BackgroundTransparency = 1
questList.ScrollBarThickness = 8
questList.Parent = journalFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = questList

-- ============================================
-- QUEST FUNCTIONS
-- ============================================

-- Update quest list
local function updateQuestList()
    -- Clear existing items
    for _, child in ipairs(questList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Get player quests (from server)
    -- For now, show placeholder
    local placeholder = Instance.new("TextLabel")
    placeholder.Name = "Placeholder"
    placeholder.Size = UDim2.new(1, 0, 0, 50)
    placeholder.BackgroundTransparency = 1
    placeholder.Text = "No active quests"
    placeholder.TextColor3 = Color3.fromRGB(150, 150, 150)
    placeholder.TextScaled = true
    placeholder.Font = Enum.Font.Gotham
    placeholder.Parent = questList
end

-- Toggle journal
local function toggleJournal()
    journalFrame.Visible = not journalFrame.Visible
    if journalFrame.Visible then
        updateQuestList()
    end
end

-- ============================================
-- INPUT HANDLING
-- ============================================

-- J key to open quest journal
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
    if input.KeyCode == Enum.KeyCode.J then
        toggleJournal()
    end
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    journalFrame.Visible = false
end)

-- ============================================
-- QUEST EVENT HANDLING
-- ============================================

questEvent.OnClientEvent:Connect(function(data)
    if data.type == "QuestAccepted" then
        -- Show notification
        print("[QuestClient] Quest accepted: " .. data.quest.name)
        
        -- Update journal if open
        if journalFrame.Visible then
            updateQuestList()
        end
        
    elseif data.type == "QuestProgress" then
        -- Show progress notification
        print("[QuestClient] Quest progress: " .. data.objective.target .. " " .. data.objective.current .. "/" .. data.objective.count)
        
    elseif data.type == "QuestCompleted" then
        -- Show completion notification
        print("[QuestClient] Quest completed: " .. data.questId)
        print("[QuestClient] Rewards: +" .. data.rewards.exp .. " EXP, +" .. data.rewards.gold .. " Gold")
        
        -- Update journal if open
        if journalFrame.Visible then
            updateQuestList()
        end
    end
end)

-- ============================================
-- QUEST INTERACTION
-- ============================================

-- Check for quest NPCs
local function checkQuestNPC(target)
    if not target then
        return false
    end
    
    local hasQuest = target:GetAttribute("HasQuest")
    if hasQuest then
        local npcId = target:GetAttribute("NPCId")
        local npcName = target:GetAttribute("NPCName")
        local greeting = target:GetAttribute("Greeting")
        
        print("[QuestClient] Found quest NPC: " .. npcName)
        print("[QuestClient] " .. greeting)
        
        -- Send quest request to server
        questEvent:FireServer("accept", "quest_kill_slimes")
        
        return true
    end
    
    return false
end

-- Mouse click to interact with NPCs
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
    local target = mouse.Target
    if target then
        checkQuestNPC(target)
    end
end)

print("[QuestClient] Quest Client ready!")
print("[QuestClient] Press J to open quest journal!")
