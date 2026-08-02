--[[
    QuestTracker.lua
    Displays active quests and progress (INFORMATIF!)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestTracker = {}

-- UI Elements
local questFrame, questList

-- Create Quest Tracker
function QuestTracker:Create(gui)
    questFrame = Instance.new("Frame")
    questFrame.Size = UDim2.new(0, 250, 0, 150)
    questFrame.Position = UDim2.new(1, -260, 0, 10)
    questFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    questFrame.BackgroundTransparency = 0.3
    questFrame.BorderSizePixel = 0
    questFrame.Parent = gui
    
    Instance.new("UICorner", questFrame).CornerRadius = UDim.new(0, 8)
    
    local questTitle = Instance.new("TextLabel")
    questTitle.Size = UDim2.new(1, -10, 0, 25)
    questTitle.Position = UDim2.new(0, 5, 0, 5)
    questTitle.BackgroundTransparency = 1
    questTitle.Text = "Quests"
    questTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    questTitle.TextStrokeTransparency = 0
    questTitle.Font = Enum.Font.GothamBold
    questTitle.TextScaled = true
    questTitle.Parent = questFrame
    
    questList = Instance.new("TextLabel")
    questList.Size = UDim2.new(1, -10, 1, -35)
    questList.Position = UDim2.new(0, 5, 0, 30)
    questList.BackgroundTransparency = 1
    questList.Text = "Tidak ada quest aktif"
    questList.TextColor3 = Color3.fromRGB(200, 200, 200)
    questList.TextStrokeTransparency = 0
    questList.TextXAlignment = Enum.TextXAlignment.Left
    questList.TextYAlignment = Enum.TextYAlignment.Top
    questList.Font = Enum.Font.Gotham
    questList.TextScaled = true
    questList.TextWrapped = true
    questList.Parent = questFrame
    
    print("[QuestTracker] Created!")
end

-- Update quest display (INFORMATIF!)
function QuestTracker:Update(data)
    if not questList then return end
    
    local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
    
    local questText = ""
    if data.activeQuests then
        for questId, quest in pairs(data.activeQuests) do
            local questData = GameData:GetQuest(questId)
            if questData then
                questText = questText .. questData.name .. "\n"
                
                -- Show objectives with status
                local allComplete = true
                for i, obj in ipairs(questData.objectives) do
                    local prog = quest.progress[i] or 0
                    local done = prog >= obj.count
                    if not done then allComplete = false end
                    
                    local status = done and "✓" or ">"
                    questText = questText .. "  " .. status .. " " .. obj.description .. ": " .. prog .. "/" .. obj.count .. "\n"
                end
                
                -- If ready to complete, show return message
                if quest.readyToComplete or allComplete then
                    local npcData = GameData:GetNPC(questData.giver)
                    local npcName = npcData and npcData.name or questData.giver
                    questText = questText .. "  → Kembali ke " .. npcName .. " untuk ambil reward!\n"
                end
                
                questText = questText .. "\n"
            end
        end
    end
    questList.Text = questText ~= "" and questText or "Tidak ada quest aktif"
end

return QuestTracker
