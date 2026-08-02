--[[
    Arcadia Online - Main Client Script
    
    Handles all client-side UI and interactions.
    
    Place di: StarterPlayerScripts (as LocalScript)
    
    @author arcadiastore
    @version 3.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[MainClient] Client initializing...")

-- Wait for Events
local EventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
if not EventsFolder then
    warn("[MainClient] Events folder not found!")
    return
end

-- Get all events
local AttackMonster = EventsFolder:WaitForChild("AttackMonster")
local CombatFeedback = EventsFolder:WaitForChild("CombatFeedback")
local QuestEvent = EventsFolder:WaitForChild("QuestEvent")
local ShopEvent = EventsFolder:WaitForChild("ShopEvent")
local DialogueEvent = EventsFolder:WaitForChild("DialogueEvent")
local NotificationEvent = EventsFolder:WaitForChild("NotificationEvent")

print("[MainClient] All events found!")

-- ============================================
-- CREATE HUD
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Stats frame
local statsFrame = Instance.new("Frame")
statsFrame.Name = "Stats"
statsFrame.Size = UDim2.new(0, 200, 0, 100)
statsFrame.Position = UDim2.new(0, 10, 0, 10)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statsFrame.BackgroundTransparency = 0.3
statsFrame.BorderSizePixel = 0
statsFrame.Parent = screenGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsFrame

-- Level label
local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "Level"
levelLabel.Size = UDim2.new(1, -10, 0, 20)
levelLabel.Position = UDim2.new(0, 5, 0, 5)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: 1"
levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
levelLabel.TextStrokeTransparency = 0
levelLabel.TextXAlignment = Enum.TextXAlignment.Left
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextScaled = true
levelLabel.Parent = statsFrame

-- HP bar
local hpBarBg = Instance.new("Frame")
hpBarBg.Name = "HPBarBg"
hpBarBg.Size = UDim2.new(1, -10, 0, 15)
hpBarBg.Position = UDim2.new(0, 5, 0, 30)
hpBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
hpBarBg.BorderSizePixel = 0
hpBarBg.Parent = statsFrame

local hpBar = Instance.new("Frame")
hpBar.Name = "HPBar"
hpBar.Size = UDim2.new(1, 0, 1, 0)
hpBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
hpBar.BorderSizePixel = 0
hpBar.Parent = hpBarBg

local hpLabel = Instance.new("TextLabel")
hpLabel.Name = "HPLabel"
hpLabel.Size = UDim2.new(1, 0, 1, 0)
hpLabel.BackgroundTransparency = 1
hpLabel.Text = "HP: 100/100"
hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hpLabel.TextStrokeTransparency = 0
hpLabel.Font = Enum.Font.GothamBold
hpLabel.TextScaled = true
hpLabel.Parent = hpBarBg

-- EXP bar
local expBarBg = Instance.new("Frame")
expBarBg.Name = "EXPBarBg"
expBarBg.Size = UDim2.new(1, -10, 0, 15)
expBarBg.Position = UDim2.new(0, 5, 0, 50)
expBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
expBarBg.BorderSizePixel = 0
expBarBg.Parent = statsFrame

local expBar = Instance.new("Frame")
expBar.Name = "EXPBar"
expBar.Size = UDim2.new(0, 0, 1, 0)
expBar.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
expBar.BorderSizePixel = 0
expBar.Parent = expBarBg

local expLabel = Instance.new("TextLabel")
expLabel.Name = "EXPLabel"
expLabel.Size = UDim2.new(1, 0, 1, 0)
expLabel.BackgroundTransparency = 1
expLabel.Text = "EXP: 0/100"
expLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
expLabel.TextStrokeTransparency = 0
expLabel.Font = Enum.Font.GothamBold
expLabel.TextScaled = true
expLabel.Parent = expBarBg

-- Gold label
local goldLabel = Instance.new("TextLabel")
goldLabel.Name = "Gold"
goldLabel.Size = UDim2.new(1, -10, 0, 20)
goldLabel.Position = UDim2.new(0, 5, 0, 75)
goldLabel.BackgroundTransparency = 1
goldLabel.Text = "Gold: 100"
goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
goldLabel.TextStrokeTransparency = 0
goldLabel.TextXAlignment = Enum.TextXAlignment.Left
goldLabel.Font = Enum.Font.GothamBold
goldLabel.TextScaled = true
goldLabel.Parent = statsFrame

-- ============================================
-- QUEST TRACKER
-- ============================================

local questFrame = Instance.new("Frame")
questFrame.Name = "QuestTracker"
questFrame.Size = UDim2.new(0, 250, 0, 150)
questFrame.Position = UDim2.new(1, -260, 0, 10)
questFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
questFrame.BackgroundTransparency = 0.3
questFrame.BorderSizePixel = 0
questFrame.Parent = screenGui

local questCorner = Instance.new("UICorner")
questCorner.CornerRadius = UDim.new(0, 8)
questCorner.Parent = questFrame

local questTitle = Instance.new("TextLabel")
questTitle.Name = "Title"
questTitle.Size = UDim2.new(1, -10, 0, 25)
questTitle.Position = UDim2.new(0, 5, 0, 5)
questTitle.BackgroundTransparency = 1
questTitle.Text = "Active Quests"
questTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
questTitle.TextStrokeTransparency = 0
questTitle.Font = Enum.Font.GothamBold
questTitle.TextScaled = true
questTitle.Parent = questFrame

local questList = Instance.new("TextLabel")
questList.Name = "QuestList"
questList.Size = UDim2.new(1, -10, 1, -35)
questList.Position = UDim2.new(0, 5, 0, 30)
questList.BackgroundTransparency = 1
questList.Text = "No active quests"
questList.TextColor3 = Color3.fromRGB(200, 200, 200)
questList.TextStrokeTransparency = 0
questList.TextXAlignment = Enum.TextXAlignment.Left
questList.TextYAlignment = Enum.TextYAlignment.Top
questList.Font = Enum.Font.Gotham
questList.TextScaled = true
questList.TextWrapped = true
questList.Parent = questFrame

-- ============================================
-- DAMAGE POPUP
-- ============================================

local function showDamagePopup(damage, isCritical)
    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(0, 100, 0, 40)
    popup.Position = UDim2.new(0.5, -50, 0.4, 0)
    popup.BackgroundTransparency = 1
    popup.Text = "-" .. damage
    popup.TextColor3 = isCritical and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
    popup.TextStrokeTransparency = 0
    popup.Font = Enum.Font.GothamBold
    popup.TextScaled = true
    popup.Parent = screenGui
    
    -- Animate
    local tweenService = game:GetService("TweenService")
    local tween = tweenService:Create(popup, TweenInfo.new(1), {
        Position = UDim2.new(0.5, -50, 0.3, 0),
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function()
        popup:Destroy()
    end)
end

-- ============================================
-- COMBAT FEEDBACK
-- ============================================

CombatFeedback.OnClientEvent:Connect(function(data)
    if data.type == "DamageDealt" then
        showDamagePopup(data.damage, false)
        
        -- Update monster HP bar if exists
        -- TODO: Update monster UI
        
    elseif data.type == "MonsterKilled" then
        -- Show kill notification
        print("[Client] Killed " .. data.monsterId .. " - EXP: +" .. data.exp .. " Gold: +" .. data.gold)
        
    elseif data.type == "PlayerDamage" then
        showDamagePopup(data.damage, false)
    end
end)

-- ============================================
-- QUEST EVENT
-- ============================================

local activeQuests = {}

QuestEvent.OnClientEvent:Connect(function(data)
    if data.type == "QuestAccepted" then
        activeQuests[data.quest.id] = {
            quest = data.quest,
            progress = {},
        }
        for i, obj in ipairs(data.quest.objectives) do
            activeQuests[data.quest.id].progress[i] = 0
        end
        
        -- Show notification
        print("[Quest] Quest accepted: " .. data.quest.name)
        
    elseif data.type == "QuestProgress" then
        if activeQuests[data.questId] then
            activeQuests[data.questId].progress = data.progress
        end
        
    elseif data.type == "QuestCompleted" then
        activeQuests[data.questId] = nil
        print("[Quest] Quest completed: " .. data.questId)
    end
    
    -- Update quest tracker UI
    local questText = ""
    for questId, questData in pairs(activeQuests) do
        questText = questText .. questData.quest.name .. "\n"
        for i, objective in ipairs(questData.quest.objectives) do
            local progress = questData.progress[i] or 0
            questText = questText .. "  " .. objective.target .. ": " .. progress .. "/" .. objective.count .. "\n"
        end
    end
    
    if questText == "" then
        questText = "No active quests"
    end
    
    questList.Text = questText
end)

-- ============================================
-- SHOP EVENT
-- ============================================

-- Create shop UI (hidden by default)
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopUI"
shopFrame.Size = UDim2.new(0, 400, 0, 350)
shopFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
shopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shopFrame.BorderSizePixel = 0
shopFrame.Visible = false
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 10)
shopCorner.Parent = shopFrame

-- Shop title
local shopTitle = Instance.new("TextLabel")
shopTitle.Name = "Title"
shopTitle.Size = UDim2.new(1, -40, 0, 35)
shopTitle.Position = UDim2.new(0, 10, 0, 5)
shopTitle.BackgroundTransparency = 1
shopTitle.Text = "Shop"
shopTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
shopTitle.TextStrokeTransparency = 0
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextScaled = true
shopTitle.Parent = shopFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = shopFrame

closeButton.MouseButton1Click:Connect(function()
    shopFrame.Visible = false
end)

-- Items scroll
local itemsScroll = Instance.new("ScrollingFrame")
itemsScroll.Name = "Items"
itemsScroll.Size = UDim2.new(1, -20, 1, -80)
itemsScroll.Position = UDim2.new(0, 10, 0, 45)
itemsScroll.BackgroundTransparency = 1
itemsScroll.ScrollBarThickness = 6
itemsScroll.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = itemsScroll

-- Gold display in shop
local shopGoldLabel = Instance.new("TextLabel")
shopGoldLabel.Name = "Gold"
shopGoldLabel.Size = UDim2.new(1, -20, 0, 25)
shopGoldLabel.Position = UDim2.new(0, 10, 1, -30)
shopGoldLabel.BackgroundTransparency = 1
shopGoldLabel.Text = "Gold: 100"
shopGoldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
shopGoldLabel.TextStrokeTransparency = 0
shopGoldLabel.Font = Enum.Font.GothamBold
shopGoldLabel.TextScaled = true
shopGoldLabel.Parent = shopFrame

ShopEvent.OnClientEvent:Connect(function(data)
    if data.type == "ShopOpened" then
        -- Clear old items
        for _, child in ipairs(itemsScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Add new items
        for _, item in ipairs(data.items) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Name = item.id
            itemFrame.Size = UDim2.new(1, 0, 0, 40)
            itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            itemFrame.BorderSizePixel = 0
            itemFrame.Parent = itemsScroll
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 5)
            itemCorner.Parent = itemFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = item.name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextScaled = true
            nameLabel.Parent = itemFrame
            
            local priceLabel = Instance.new("TextLabel")
            priceLabel.Size = UDim2.new(0.2, 0, 1, 0)
            priceLabel.Position = UDim2.new(0.6, 0, 0, 0)
            priceLabel.BackgroundTransparency = 1
            priceLabel.Text = item.price .. "G"
            priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            priceLabel.Font = Enum.Font.GothamBold
            priceLabel.TextScaled = true
            priceLabel.Parent = itemFrame
            
            local buyButton = Instance.new("TextButton")
            buyButton.Size = UDim2.new(0.2, -5, 0.8, 0)
            buyButton.Position = UDim2.new(0.8, 0, 0.1, 0)
            buyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            buyButton.BorderSizePixel = 0
            buyButton.Text = "Buy"
            buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            buyButton.Font = Enum.Font.GothamBold
            buyButton.TextScaled = true
            buyButton.Parent = itemFrame
            
            buyButton.MouseButton1Click:Connect(function()
                ShopEvent:FireServer("buy", {itemId = item.id, quantity = 1})
            end)
        end
        
        shopFrame.Visible = true
        shopGoldLabel.Text = "Gold: " .. (data.playerGold or "?")
        
    elseif data.type == "ItemBought" then
        shopGoldLabel.Text = "Gold: " .. data.gold
        goldLabel.Text = "Gold: " .. data.gold
        print("[Shop] Bought " .. data.quantity .. "x " .. data.itemId)
        
    elseif data.type == "Error" then
        warn("[Shop] " .. data.message)
    end
end)

-- ============================================
-- DIALOGUE EVENT
-- ============================================

-- Create dialogue UI
local dialogueFrame = Instance.new("Frame")
dialogueFrame.Name = "DialogueUI"
dialogueFrame.Size = UDim2.new(0, 400, 0, 200)
dialogueFrame.Position = UDim2.new(0.5, -200, 0.7, 0)
dialogueFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dialogueFrame.BackgroundTransparency = 0.2
dialogueFrame.BorderSizePixel = 0
dialogueFrame.Visible = false
dialogueFrame.Parent = screenGui

local dialogueCorner = Instance.new("UICorner")
dialogueCorner.CornerRadius = UDim.new(0, 10)
dialogueCorner.Parent = dialogueFrame

local npcNameLabel = Instance.new("TextLabel")
npcNameLabel.Name = "NPCName"
npcNameLabel.Size = UDim2.new(1, -20, 0, 25)
npcNameLabel.Position = UDim2.new(0, 10, 0, 5)
npcNameLabel.BackgroundTransparency = 1
npcNameLabel.Text = "NPC"
npcNameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
npcNameLabel.TextStrokeTransparency = 0
npcNameLabel.Font = Enum.Font.GothamBold
npcNameLabel.TextScaled = true
npcNameLabel.Parent = dialogueFrame

local dialogueText = Instance.new("TextLabel")
dialogueText.Name = "Text"
dialogueText.Size = UDim2.new(1, -20, 0, 50)
dialogueText.Position = UDim2.new(0, 10, 0, 35)
dialogueText.BackgroundTransparency = 1
dialogueText.Text = "Hello adventurer!"
dialogueText.TextColor3 = Color3.fromRGB(255, 255, 255)
dialogueText.TextStrokeTransparency = 0
dialogueText.TextWrapped = true
dialogueText.Font = Enum.Font.Gotham
dialogueText.TextScaled = true
dialogueText.Parent = dialogueFrame

local responseScroll = Instance.new("ScrollingFrame")
responseScroll.Name = "Responses"
responseScroll.Size = UDim2.new(1, -20, 0, 100)
responseScroll.Position = UDim2.new(0, 10, 0, 90)
responseScroll.BackgroundTransparency = 1
responseScroll.ScrollBarThickness = 4
responseScroll.Parent = dialogueFrame

local responseLayout = Instance.new("UIListLayout")
responseLayout.Padding = UDim.new(0, 5)
responseLayout.Parent = responseScroll

local currentNPCId = nil

DialogueEvent.OnClientEvent:Connect(function(data)
    if data.type == "DialogueStart" or data.type == "DialogueContinue" then
        currentNPCId = data.npcId
        npcNameLabel.Text = data.npcName or data.npcId
        dialogueText.Text = data.dialogue.text
        
        -- Clear old responses
        for _, child in ipairs(responseScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Add responses
        for _, response in ipairs(data.dialogue.responses) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.BorderSizePixel = 0
            btn.Text = response.text
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            btn.Parent = responseScroll
            
            btn.MouseButton1Click:Connect(function()
                DialogueEvent:FireServer("respond", {
                    npcId = currentNPCId,
                    responseText = response.text,
                })
            end)
        end
        
        dialogueFrame.Visible = true
        
    elseif data.type == "DialogueEnd" then
        dialogueFrame.Visible = false
        currentNPCId = nil
    end
end)

-- ============================================
-- NPC INTERACTION (Click to interact)
-- ============================================

local function setupNPCInteraction()
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then
        -- Wait for NPCs to be created
        task.wait(5)
        npcFolder = workspace:FindFirstChild("NPCs")
    end
    
    if npcFolder then
        for _, npc in ipairs(npcFolder:GetChildren()) do
            if npc:IsA("Model") or npc:IsA("Part") then
                local clickDetector = npc:FindFirstChild("ClickDetector") or npc:FindFirstChildWhichIsA("ClickDetector")
                if not clickDetector then
                    clickDetector = Instance.new("ClickDetector")
                    clickDetector.MaxActivationDistance = 15
                    clickDetector.Parent = npc
                end
                
                clickDetector.MouseClick:Connect(function()
                    local npcId = npc:GetAttribute("NPCId") or npc.Name
                    print("[Client] Clicked NPC: " .. npcId)
                    
                    -- Check if NPC has shop
                    local hasShop = npc:GetAttribute("HasShop")
                    local hasQuest = npc:GetAttribute("HasQuest")
                    
                    if hasShop then
                        local shopId = npc:GetAttribute("ShopId")
                        if shopId then
                            ShopEvent:FireServer("open", {shopId = shopId})
                        end
                    else
                        -- Start dialogue
                        DialogueEvent:FireServer("talk", {npcId = npcId})
                    end
                end)
            end
        end
        print("[MainClient] NPC interactions setup!")
    else
        warn("[MainClient] NPC folder not found!")
    end
end

-- Setup NPC interactions after delay
task.spawn(function()
    task.wait(6)
    setupNPCInteraction()
end)

-- ============================================
-- MONSTER INTERACTION (Click to attack)
-- ============================================

local function setupMonsterInteraction()
    local monsterFolder = workspace:FindFirstChild("Monsters")
    if not monsterFolder then
        task.wait(5)
        monsterFolder = workspace:FindFirstChild("Monsters")
    end
    
    if monsterFolder then
        for _, monster in ipairs(monsterFolder:GetChildren()) do
            if monster:IsA("Model") or monster:IsA("Part") then
                local clickDetector = monster:FindFirstChild("ClickDetector") or monster:FindFirstChildWhichIsA("ClickDetector")
                if not clickDetector then
                    clickDetector = Instance.new("ClickDetector")
                    clickDetector.MaxActivationDistance = 20
                    clickDetector.Parent = monster
                end
                
                clickDetector.MouseClick:Connect(function()
                    print("[Client] Attacking monster: " .. monster.Name)
                    AttackMonster:FireServer(monster)
                end)
            end
        end
        print("[MainClient] Monster interactions setup!")
    else
        warn("[MainClient] Monster folder not found!")
    end
end

task.spawn(function()
    task.wait(6)
    setupMonsterInteraction()
end)

-- ============================================
-- NOTIFICATION EVENT
-- ============================================

NotificationEvent.OnClientEvent:Connect(function(data)
    if data.type == "LevelUp" then
        -- Show level up notification
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 300, 0, 60)
        notif.Position = UDim2.new(0.5, -150, 0.3, 0)
        notif.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        notif.BackgroundTransparency = 0.2
        notif.Text = "LEVEL UP! Level " .. data.level
        notif.TextColor3 = Color3.fromRGB(0, 0, 0)
        notif.Font = Enum.Font.GothamBold
        notif.TextScaled = true
        notif.Parent = screenGui
        
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 10)
        notifCorner.Parent = notif
        
        task.delay(3, function()
            notif:Destroy()
        end)
    end
end)

print("[MainClient] Client fully initialized!")
