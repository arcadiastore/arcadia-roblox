--[[
    Notification.lua
    Handles all notifications (quest, level up, etc.)
]]

local Notification = {}

-- UI Elements
local notificationFrame, notificationLabel

-- Create Notification UI
function Notification:Create(gui)
    notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 400, 0, 60)
    notificationFrame.Position = UDim2.new(0.5, -200, 0.15, 0)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notificationFrame.BackgroundTransparency = 0.2
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Visible = false
    notificationFrame.Parent = gui
    
    Instance.new("UICorner", notificationFrame).CornerRadius = UDim.new(0, 10)
    
    notificationLabel = Instance.new("TextLabel")
    notificationLabel.Size = UDim2.new(1, -20, 1, 0)
    notificationLabel.Position = UDim2.new(0, 10, 0, 0)
    notificationLabel.BackgroundTransparency = 1
    notificationLabel.Text = ""
    notificationLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    notificationLabel.TextStrokeTransparency = 0
    notificationLabel.Font = Enum.Font.GothamBold
    notificationLabel.TextScaled = true
    notificationLabel.TextWrapped = true
    notificationLabel.Parent = notificationFrame
    
    print("[Notification] Created!")
end

-- Show notification
function Notification:Show(text, color, duration)
    if not notificationFrame then return end
    
    notificationLabel.Text = text
    notificationLabel.TextColor3 = color or Color3.fromRGB(255, 215, 0)
    notificationFrame.Visible = true
    
    task.delay(duration or 3, function()
        if notificationFrame then
            notificationFrame.Visible = false
        end
    end)
end

-- Show quest accepted
function Notification:QuestAccepted(questName)
    self:Show("Quest Accepted: " .. questName, Color3.fromRGB(100, 255, 100), 3)
end

-- Show quest ready to turn in
function Notification:QuestReady(questName, npcName)
    self:Show("Quest Selesai: " .. questName .. "\nKembali ke " .. npcName .. " untuk ambil reward!", Color3.fromRGB(100, 200, 255), 5)
end

-- Show quest completed with rewards
function Notification:QuestCompleted(questName, rewards)
    self:Show("Quest Complete: " .. questName .. "\nReward: " .. rewards, Color3.fromRGB(255, 215, 0), 5)
end

return Notification
