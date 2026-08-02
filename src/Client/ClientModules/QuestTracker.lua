--[[
    QuestTracker.lua
    Displays active quests with clickable objectives for auto quest
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestTracker = {}

local autoPanel = nil  -- Reference to AutoPanel

-- UI Elements
local questFrame, questScroll

-- Set AutoPanel reference
function QuestTracker:SetAutoPanel(ap)
    autoPanel = ap
end

-- Create Quest Tracker
function QuestTracker:Create(gui)
    questFrame = Instance.new("Frame")
    questFrame.Size = UDim2.new(0, 250, 0, 180)
    questFrame.Position = UDim2.new(1, -260, 0, 10)
    questFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    questFrame.BackgroundTransparency = 0.3
    questFrame.BorderSizePixel = 0
    questFrame.Parent = gui
    
    Instance.new("UICorner", questFrame).CornerRadius = UDim.new(0, 8)
    
    local questTitle = Instance.new("TextLabel")
    questTitle.Size = UDim2.new(1, -10, 0, 22)
    questTitle.Position = UDim2.new(0, 5, 0, 3)
    questTitle.BackgroundTransparency = 1
    questTitle.Text = "Quests"
    questTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    questTitle.TextStrokeTransparency = 0
    questTitle.Font = Enum.Font.GothamBold
    questTitle.TextScaled = true
    questTitle.TextXAlignment = Enum.TextXAlignment.Left
    questTitle.Parent = questFrame
    
    -- Scroll frame for quest list
    questScroll = Instance.new("ScrollingFrame")
    questScroll.Size = UDim2.new(1, -10, 1, -30)
    questScroll.Position = UDim2.new(0, 5, 0, 27)
    questScroll.BackgroundTransparency = 1
    questScroll.ScrollBarThickness = 4
    questScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    questScroll.Parent = questFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = questScroll
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        questScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
    end)
    
    print("[QuestTracker] Created!")
end

-- Update quest display (INFORMATIF + clickable)
function QuestTracker:Update(data)
    if not questScroll then return end
    
    local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
    
    -- Clear old entries
    for _, child in ipairs(questScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    if not data.activeQuests then return end
    
    local layoutOrder = 0
    
    for questId, quest in pairs(data.activeQuests) do
        local questData = GameData:GetQuest(questId)
        if questData then
            layoutOrder = layoutOrder + 1
            
            -- Quest name header
            local header = Instance.new("TextButton")
            header.Name = "Q_" .. questId
            header.Size = UDim2.new(1, 0, 0, 20)
            header.BackgroundTransparency = 1
            header.Text = questData.name
            header.TextColor3 = Color3.fromRGB(255, 215, 0)
            header.Font = Enum.Font.GothamBold
            header.TextScaled = true
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.LayoutOrder = layoutOrder
            header.Parent = questScroll
            
            -- Show objectives
            local allComplete = true
            for i, obj in ipairs(questData.objectives) do
                layoutOrder = layoutOrder + 1
                local prog = quest.progress and quest.progress[i] or 0
                local done = prog >= obj.count
                if not done then allComplete = false end
                
                local status = done and "✓" or ">"
                local color = done and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 200, 200)
                
                local objBtn = Instance.new("TextButton")
                objBtn.Name = "Obj_" .. questId .. "_" .. i
                objBtn.Size = UDim2.new(1, 0, 0, 18)
                objBtn.BackgroundTransparency = 1
                objBtn.Text = "  " .. status .. " " .. obj.description .. ": " .. prog .. "/" .. obj.count
                objBtn.TextColor3 = color
                objBtn.Font = Enum.Font.Gotham
                objBtn.TextScaled = true
                objBtn.TextXAlignment = Enum.TextXAlignment.Left
                objBtn.LayoutOrder = layoutOrder
                objBtn.Parent = questScroll
                
                -- Clickable: auto quest for kill objectives
                if not done and obj.type == "kill" then
                    objBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    objBtn.BackgroundTransparency = 0.7
                    
                    objBtn.MouseButton1Click:Connect(function()
                        if autoPanel then
                            autoPanel:StartAutoQuest(obj.target)
                        end
                    end)
                    
                    objBtn.MouseEnter:Connect(function()
                        objBtn.BackgroundTransparency = 0.3
                    end)
                    objBtn.MouseLeave:Connect(function()
                        objBtn.BackgroundTransparency = 0.7
                    end)
                end
            end
            
            -- Return to NPC message
            if quest.readyToComplete or allComplete then
                layoutOrder = layoutOrder + 1
                local npcData = GameData:GetNPC(questData.giver)
                local npcName = npcData and npcData.name or questData.giver
                
                local returnBtn = Instance.new("TextButton")
                returnBtn.Size = UDim2.new(1, 0, 0, 18)
                returnBtn.BackgroundTransparency = 1
                returnBtn.Text = "  → Kembali ke " .. npcName .. "!"
                returnBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
                returnBtn.Font = Enum.Font.GothamBold
                returnBtn.TextScaled = true
                returnBtn.TextXAlignment = Enum.TextXAlignment.Left
                returnBtn.LayoutOrder = layoutOrder
                returnBtn.Parent = questScroll
                
                -- Click to walk to NPC
                returnBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
                returnBtn.BackgroundTransparency = 0.7
                returnBtn.MouseButton1Click:Connect(function()
                    -- Walk to NPC
                    local Players = game:GetService("Players")
                    local plr = Players.LocalPlayer
                    local char = plr.Character
                    if char then
                        local humanoid = char:FindFirstChild("Humanoid")
                        if humanoid then
                            local npcFolder = workspace:FindFirstChild("NPCs")
                            if npcFolder then
                                local npcPart = npcFolder:FindFirstChild(questData.giver)
                                if npcPart then
                                    humanoid:MoveTo(npcPart.Position)
                                end
                            end
                        end
                    end
                end)
            end
            
            -- Spacer
            layoutOrder = layoutOrder + 1
            local spacer = Instance.new("Frame")
            spacer.Size = UDim2.new(1, 0, 0, 5)
            spacer.BackgroundTransparency = 1
            spacer.LayoutOrder = layoutOrder
            spacer.Parent = questScroll
        end
    end
end

return QuestTracker
