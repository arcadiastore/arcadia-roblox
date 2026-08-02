--[[
    DialogueUI.lua
    Dialogue interface with quest preview
]]

local DialogueUI = {}

-- UI Elements
local dialogueFrame, npcName, dialogueText, responseFrame

-- Create Dialogue UI
function DialogueUI:Create(gui)
    -- Large frame for quest preview
    dialogueFrame = Instance.new("Frame")
    dialogueFrame.Size = UDim2.new(0, 500, 0, 350)
    dialogueFrame.Position = UDim2.new(0.5, -250, 0.5, -100)
    dialogueFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dialogueFrame.BackgroundTransparency = 0.2
    dialogueFrame.BorderSizePixel = 0
    dialogueFrame.Visible = false
    dialogueFrame.Parent = gui
    
    Instance.new("UICorner", dialogueFrame).CornerRadius = UDim.new(0, 10)
    
    -- NPC Name
    npcName = Instance.new("TextLabel")
    npcName.Size = UDim2.new(1, -20, 0, 25)
    npcName.Position = UDim2.new(0, 10, 0, 5)
    npcName.BackgroundTransparency = 1
    npcName.Text = "NPC"
    npcName.TextColor3 = Color3.fromRGB(255, 215, 0)
    npcName.TextStrokeTransparency = 0
    npcName.Font = Enum.Font.GothamBold
    npcName.TextScaled = true
    npcName.Parent = dialogueFrame
    
    -- Scrolling frame for dialogue text
    local dialogueScroll = Instance.new("ScrollingFrame")
    dialogueScroll.Size = UDim2.new(1, -20, 0, 200)
    dialogueScroll.Position = UDim2.new(0, 10, 0, 35)
    dialogueScroll.BackgroundTransparency = 1
    dialogueScroll.ScrollBarThickness = 6
    dialogueScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    dialogueScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dialogueScroll.Parent = dialogueFrame
    
    dialogueText = Instance.new("TextLabel")
    dialogueText.Size = UDim2.new(1, -10, 0, 0)
    dialogueText.Position = UDim2.new(0, 5, 0, 0)
    dialogueText.BackgroundTransparency = 1
    dialogueText.Text = ""
    dialogueText.TextColor3 = Color3.fromRGB(255, 255, 255)
    dialogueText.TextStrokeTransparency = 0
    dialogueText.TextWrapped = true
    dialogueText.TextYAlignment = Enum.TextYAlignment.Top
    dialogueText.Font = Enum.Font.Gotham
    dialogueText.TextScaled = false
    dialogueText.TextSize = 16
    dialogueText.AutomaticSize = Enum.AutomaticSize.Y
    dialogueText.Parent = dialogueScroll
    
    -- Response buttons
    responseFrame = Instance.new("ScrollingFrame")
    responseFrame.Size = UDim2.new(1, -20, 0, 90)
    responseFrame.Position = UDim2.new(0, 10, 0, 245)
    responseFrame.BackgroundTransparency = 1
    responseFrame.ScrollBarThickness = 4
    responseFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    responseFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    responseFrame.Parent = dialogueFrame
    
    Instance.new("UIListLayout", responseFrame).Padding = UDim.new(0, 5)
    
    print("[DialogueUI] Created!")
end

-- Show dialogue
function DialogueUI:Show(data, DialogueEvent)
    if not dialogueFrame then return end
    
    npcName.Text = data.npcName or data.npcId
    dialogueText.Text = data.dialogue.text
    
    -- Clear old responses
    for _, child in ipairs(responseFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Add response buttons
    for _, resp in ipairs(data.dialogue.responses) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.BorderSizePixel = 0
        btn.Text = resp.text
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextScaled = true
        btn.Parent = responseFrame
        
        btn.MouseButton1Click:Connect(function()
            DialogueEvent:FireServer("respond", {
                npcId = data.npcId,
                responseText = resp.text,
            })
        end)
    end
    
    dialogueFrame.Visible = true
end

-- Hide dialogue
function DialogueUI:Hide()
    if dialogueFrame then
        dialogueFrame.Visible = false
    end
end

return DialogueUI
