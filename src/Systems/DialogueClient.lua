--[[
    Arcadia Online - Dialogue Client
    
    Handles dialogue UI and interaction:
    - Talk to NPCs
    - Display dialogue text
    - Next line on click
    
    Place di: StarterPlayerScripts/Client (as LocalScript)
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Player reference
local player = Players.LocalPlayer

print("[DialogueClient] Dialogue Client initializing...")

-- Wait for Events folder
local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
if not eventsFolder then
    warn("[DialogueClient] Events folder not found!")
    return
end

-- Get RemoteEvents
local dialogueEvent = eventsFolder:WaitForChild("DialogueEvent", 10)

if not dialogueEvent then
    warn("[DialogueClient] Dialogue event not found!")
    return
end

print("[DialogueClient] Dialogue event found!")

-- ============================================
-- DIALOGUE UI
-- ============================================

-- Create dialogue UI
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

-- NPC name label
local npcNameLabel = Instance.new("TextLabel")
npcNameLabel.Name = "NPCName"
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
dialogueText.Name = "Text"
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
continueLabel.Name = "Continue"
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
closeButton.Name = "Close"
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
-- DIALOGUE FUNCTIONS
-- ============================================

-- Typewriter effect
local function typewriterEffect(text, label)
    label.Text = ""
    for i = 1, #text do
        label.Text = string.sub(text, 1, i)
        task.wait(0.03)
    end
end

-- Show dialogue line
local function showDialogueLine(data)
    -- Update NPC name
    npcNameLabel.Text = data.npcId
    
    -- Typewriter effect
    typewriterEffect(data.line.text, dialogueText)
    
    -- Update continue prompt
    if data.lineIndex >= data.totalLines then
        continueLabel.Text = "Click to close..."
    else
        continueLabel.Text = "Click to continue..."
    end
    
    -- Show frame
    dialogueFrame.Visible = true
end

-- Close dialogue
local function closeDialogue()
    dialogueFrame.Visible = false
    dialogueText.Text = ""
end

-- ============================================
-- INPUT HANDLING
-- ============================================

-- Click to continue dialogue
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
local mouse = player:GetMouse()
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
    if input.KeyCode == Enum.KeyCode.F then
        -- Check if clicked on NPC
        local target = mouse.Target
        if target then
            local npcId = target:GetAttribute("NPCId")
            if npcId then
                -- Start dialogue
                dialogueEvent:FireServer("start", {
                    npcId = npcId,
                })
                print("[DialogueClient] Talking to: " .. target:GetAttribute("NPCName"))
            end
        end
    end
end)

-- ============================================
-- DIALOGUE EVENT HANDLING
-- ============================================

dialogueEvent.OnClientEvent:Connect(function(data)
    if data.type == "DialogueStarted" then
        -- Show dialogue
        showDialogueLine(data)
        
    elseif data.type == "DialogueLine" then
        -- Show next line
        showDialogueLine(data)
        
    elseif data.type == "DialogueClosed" then
        -- Close dialogue
        closeDialogue()
    end
end)

print("[DialogueClient] Dialogue Client ready!")
print("[DialogueClient] Press F to talk to NPCs!")
