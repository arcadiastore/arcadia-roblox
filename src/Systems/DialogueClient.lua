--[[
    Arcadia Online - Dialogue Client (FIXED)
    
    Shows interaction prompt when near NPC
    Press F to talk
    
    Place di: StarterPlayerScripts/Client (as LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

print("[DialogueClient] Dialogue Client initializing...")

-- Wait for Events
local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
if not eventsFolder then
    warn("[DialogueClient] Events folder not found!")
    return
end

local dialogueEvent = eventsFolder:WaitForChild("DialogueEvent", 10)
if not dialogueEvent then
    warn("[DialogueClient] Dialogue event not found!")
    return
end

-- ============================================
-- DIALOGUE UI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DialogueUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Dialogue frame (hidden by default)
local dialogueFrame = Instance.new("Frame")
dialogueFrame.Name = "Dialogue"
dialogueFrame.Size = UDim2.new(0, 600, 0, 150)
dialogueFrame.Position = UDim2.new(0.5, -300, 0.8, -75)
dialogueFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dialogueFrame.BorderSizePixel = 0
dialogueFrame.Visible = false
dialogueFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = dialogueFrame

-- NPC name
local npcNameLabel = Instance.new("TextLabel")
npcNameLabel.Size = UDim2.new(0, 200, 0, 30)
npcNameLabel.Position = UDim2.new(0, 10, 0, 5)
npcNameLabel.BackgroundTransparency = 1
npcNameLabel.Text = "NPC"
npcNameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
npcNameLabel.TextStrokeTransparency = 0
npcNameLabel.TextScaled = true
npcNameLabel.Font = Enum.Font.GothamBold
npcNameLabel.TextXAlignment = Enum.TextXAlignment.Left
npcNameLabel.Parent = dialogueFrame

-- Dialogue text
local dialogueText = Instance.new("TextLabel")
dialogueText.Size = UDim2.new(1, -20, 0, 60)
dialogueText.Position = UDim2.new(0, 10, 0, 35)
dialogueText.BackgroundTransparency = 1
dialogueText.Text = ""
dialogueText.TextColor3 = Color3.fromRGB(255, 255, 255)
dialogueText.TextStrokeTransparency = 0
dialogueText.TextScaled = true
dialogueText.Font = Enum.Font.Gotham
dialogueText.TextXAlignment = Enum.TextXAlignment.Left
dialogueText.TextWrapped = true
dialogueText.Parent = dialogueFrame

-- Continue prompt
local continueLabel = Instance.new("TextLabel")
continueLabel.Size = UDim2.new(0, 200, 0, 20)
continueLabel.Position = UDim2.new(0.5, -100, 1, -25)
continueLabel.BackgroundTransparency = 1
continueLabel.Text = "Click to continue..."
continueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
continueLabel.TextStrokeTransparency = 0
continueLabel.TextScaled = true
continueLabel.Font = Enum.Font.Gotham
continueLabel.Parent = dialogueFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = dialogueFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

-- ============================================
-- INTERACTION PROMPT (Shared with QuestClient)
-- ============================================

-- This is handled by QuestClient.lua
-- No duplicate prompt needed

-- ============================================
-- DIALOGUE FUNCTIONS
-- ============================================

local isDialogueOpen = false

local function typewriterEffect(text, label)
    label.Text = ""
    for i = 1, #text do
        label.Text = string.sub(text, 1, i)
        task.wait(0.03)
    end
end

local function showDialogueLine(data)
    npcNameLabel.Text = data.npcId
    
    typewriterEffect(data.line.text, dialogueText)
    
    if data.lineIndex >= data.totalLines then
        continueLabel.Text = "Click to close..."
    else
        continueLabel.Text = "Click to continue..."
    end
    
    dialogueFrame.Visible = true
    isDialogueOpen = true
end

local function closeDialogue()
    dialogueFrame.Visible = false
    dialogueText.Text = ""
    isDialogueOpen = false
end

-- ============================================
-- INPUT HANDLING
-- ============================================

-- Click to continue
dialogueFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dialogueEvent:FireServer("next")
    end
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    dialogueEvent:FireServer("close")
    closeDialogue()
end)

-- F key to interact with NPCs
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        -- Don't interact if dialogue is already open
        if isDialogueOpen then
            return
        end
        
        local target = mouse.Target
        if target then
            local npcId = target:GetAttribute("NPCId")
            local npcName = target:GetAttribute("NPCName")
            
            if npcId and npcName then
                -- Start dialogue
                dialogueEvent:FireServer("start", {
                    npcId = npcId,
                })
                print("[DialogueClient] Talking to: " .. npcName)
            end
        end
    end
end)

-- ESC to close dialogue
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Escape then
        if isDialogueOpen then
            dialogueEvent:FireServer("close")
            closeDialogue()
        end
    end
end)

-- ============================================
-- DIALOGUE EVENT HANDLING
-- ============================================

dialogueEvent.OnClientEvent:Connect(function(data)
    if data.type == "DialogueStarted" then
        showDialogueLine(data)
        
    elseif data.type == "DialogueLine" then
        showDialogueLine(data)
        
    elseif data.type == "DialogueClosed" then
        closeDialogue()
    end
end)

print("[DialogueClient] Dialogue Client ready!")
print("[DialogueClient] Press F to talk to NPCs!")
