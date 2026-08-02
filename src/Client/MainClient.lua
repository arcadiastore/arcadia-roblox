--[[
    Arcadia Online - Main Client Script
    
    SEMUA client logic ada di sini!
    Place di: StarterPlayerScripts (as LocalScript)
    
    @author arcadiastore
    @version 4.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[Client] Client starting...")

-- Wait for Events (server creates these)
local Events = nil
for i = 1, 30 do  -- Try for 30 seconds
    Events = ReplicatedStorage:FindFirstChild("Events")
    if Events then break end
    task.wait(1)
    if i % 5 == 0 then
        print("[Client] Waiting for Events... " .. i .. "s")
    end
end

if not Events then
    warn("[Client] Events not found after 30 seconds! Server may have error.")
    return
end

local AttackEvent = Events:WaitForChild("AttackEvent")
local ShopEvent = Events:WaitForChild("ShopEvent")
local QuestEvent = Events:WaitForChild("QuestEvent")
local DialogueEvent = Events:WaitForChild("DialogueEvent")
local UpdateEvent = Events:WaitForChild("UpdateEvent")

print("[Client] Events found!")

-- ============================================
-- CREATE HUD
-- ============================================

local gui = Instance.new("ScreenGui")
gui.Name = "GameHUD"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Stats Frame (kiri atas)
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(0, 200, 0, 100)
statsFrame.Position = UDim2.new(0, 10, 0, 10)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statsFrame.BackgroundTransparency = 0.3
statsFrame.BorderSizePixel = 0
statsFrame.Parent = gui

Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 8)

local levelLabel = Instance.new("TextLabel")
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

local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.new(1, -10, 0, 20)
hpLabel.Position = UDim2.new(0, 5, 0, 30)
hpLabel.BackgroundTransparency = 1
hpLabel.Text = "HP: 100/100"
hpLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
hpLabel.TextStrokeTransparency = 0
hpLabel.TextXAlignment = Enum.TextXAlignment.Left
hpLabel.Font = Enum.Font.GothamBold
hpLabel.TextScaled = true
hpLabel.Parent = statsFrame

local expLabel = Instance.new("TextLabel")
expLabel.Size = UDim2.new(1, -10, 0, 20)
expLabel.Position = UDim2.new(0, 5, 0, 55)
expLabel.BackgroundTransparency = 1
expLabel.Text = "EXP: 0"
expLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
expLabel.TextStrokeTransparency = 0
expLabel.TextXAlignment = Enum.TextXAlignment.Left
expLabel.Font = Enum.Font.GothamBold
expLabel.TextScaled = true
expLabel.Parent = statsFrame

local goldLabel = Instance.new("TextLabel")
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

print("[Client] HUD created!")

-- ============================================
-- QUEST TRACKER (kanan atas)
-- ============================================

local questFrame = Instance.new("Frame")
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

local questList = Instance.new("TextLabel")
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

print("[Client] Quest tracker created!")

-- ============================================
-- NOTIFICATION (tengah atas, auto hide)
-- ============================================

local notificationFrame = Instance.new("Frame")
notificationFrame.Size = UDim2.new(0, 400, 0, 60)
notificationFrame.Position = UDim2.new(0.5, -200, 0.15, 0)
notificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
notificationFrame.BackgroundTransparency = 0.2
notificationFrame.BorderSizePixel = 0
notificationFrame.Visible = false
notificationFrame.Parent = gui

Instance.new("UICorner", notificationFrame).CornerRadius = UDim.new(0, 10)

local notificationLabel = Instance.new("TextLabel")
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

print("[Client] Notification system created!")

-- ============================================
-- SHOP UI (tengah, hidden)
-- ============================================

local shopFrame = Instance.new("Frame")
shopFrame.Size = UDim2.new(0, 400, 0, 350)
shopFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
shopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shopFrame.BorderSizePixel = 0
shopFrame.Visible = false
shopFrame.Parent = gui

Instance.new("UICorner", shopFrame).CornerRadius = UDim.new(0, 10)

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -40, 0, 35)
shopTitle.Position = UDim2.new(0, 10, 0, 5)
shopTitle.BackgroundTransparency = 1
shopTitle.Text = "Shop"
shopTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
shopTitle.TextStrokeTransparency = 0
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextScaled = true
shopTitle.Parent = shopFrame

local closeShop = Instance.new("TextButton")
closeShop.Size = UDim2.new(0, 25, 0, 25)
closeShop.Position = UDim2.new(1, -30, 0, 5)
closeShop.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeShop.BorderSizePixel = 0
closeShop.Text = "X"
closeShop.TextColor3 = Color3.fromRGB(255, 255, 255)
closeShop.TextScaled = true
closeShop.Font = Enum.Font.GothamBold
closeShop.Parent = shopFrame

closeShop.MouseButton1Click:Connect(function()
    shopFrame.Visible = false
end)

local shopItems = Instance.new("ScrollingFrame")
shopItems.Size = UDim2.new(1, -20, 1, -80)
shopItems.Position = UDim2.new(0, 10, 0, 45)
shopItems.BackgroundTransparency = 1
shopItems.ScrollBarThickness = 6
shopItems.Parent = shopFrame

Instance.new("UIListLayout", shopItems).Padding = UDim.new(0, 5)

local shopGold = Instance.new("TextLabel")
shopGold.Size = UDim2.new(1, -20, 0, 25)
shopGold.Position = UDim2.new(0, 10, 1, -30)
shopGold.BackgroundTransparency = 1
shopGold.Text = "Gold: 100"
shopGold.TextColor3 = Color3.fromRGB(255, 215, 0)
shopGold.TextStrokeTransparency = 0
shopGold.Font = Enum.Font.GothamBold
shopGold.TextScaled = true
shopGold.Parent = shopFrame

print("[Client] Shop UI created!")

-- ============================================
-- DIALOGUE UI (bawah, hidden, larger for quest preview)
-- ============================================

local dialogueFrame = Instance.new("Frame")
dialogueFrame.Size = UDim2.new(0, 500, 0, 350)
dialogueFrame.Position = UDim2.new(0.5, -250, 0.5, -100)
dialogueFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dialogueFrame.BackgroundTransparency = 0.2
dialogueFrame.BorderSizePixel = 0
dialogueFrame.Visible = false
dialogueFrame.Parent = gui

Instance.new("UICorner", dialogueFrame).CornerRadius = UDim.new(0, 10)

local npcName = Instance.new("TextLabel")
npcName.Size = UDim2.new(1, -20, 0, 25)
npcName.Position = UDim2.new(0, 10, 0, 5)
npcName.BackgroundTransparency = 1
npcName.Text = "NPC"
npcName.TextColor3 = Color3.fromRGB(255, 215, 0)
npcName.TextStrokeTransparency = 0
npcName.Font = Enum.Font.GothamBold
npcName.TextScaled = true
npcName.Parent = dialogueFrame

-- Scrolling frame for dialogue text (supports long quest descriptions)
local dialogueScroll = Instance.new("ScrollingFrame")
dialogueScroll.Size = UDim2.new(1, -20, 0, 200)
dialogueScroll.Position = UDim2.new(0, 10, 0, 35)
dialogueScroll.BackgroundTransparency = 1
dialogueScroll.ScrollBarThickness = 6
dialogueScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
dialogueScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
dialogueScroll.Parent = dialogueFrame

local dialogueText = Instance.new("TextLabel")
dialogueText.Size = UDim2.new(1, -10, 0, 0)
dialogueText.Position = UDim2.new(0, 5, 0, 0)
dialogueText.BackgroundTransparency = 1
dialogueText.Text = "Hello!"
dialogueText.TextColor3 = Color3.fromRGB(255, 255, 255)
dialogueText.TextStrokeTransparency = 0
dialogueText.TextWrapped = true
dialogueText.TextYAlignment = Enum.TextYAlignment.Top
dialogueText.Font = Enum.Font.Gotham
dialogueText.TextScaled = false
dialogueText.TextSize = 16
dialogueText.AutomaticSize = Enum.AutomaticSize.Y
dialogueText.Parent = dialogueScroll

local responseFrame = Instance.new("ScrollingFrame")
responseFrame.Size = UDim2.new(1, -20, 0, 90)
responseFrame.Position = UDim2.new(0, 10, 0, 245)
responseFrame.BackgroundTransparency = 1
responseFrame.ScrollBarThickness = 4
responseFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
responseFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
responseFrame.Parent = dialogueFrame

Instance.new("UIListLayout", responseFrame).Padding = UDim.new(0, 5)

print("[Client] Dialogue UI created!")

-- ============================================
-- DAMAGE POPUP
-- ============================================

local function showDamage(damage)
    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(0, 100, 0, 40)
    popup.Position = UDim2.new(0.5, -50, 0.4, 0)
    popup.BackgroundTransparency = 1
    popup.Text = "-" .. damage
    popup.TextColor3 = Color3.fromRGB(255, 50, 50)
    popup.TextStrokeTransparency = 0
    popup.Font = Enum.Font.GothamBold
    popup.TextScaled = true
    popup.Parent = gui
    
    local tween = game:GetService("TweenService"):Create(popup, TweenInfo.new(1), {
        Position = UDim2.new(0.5, -50, 0.3, 0),
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function() popup:Destroy() end)
end

-- ============================================
-- UPDATE HANDLER
-- ============================================

UpdateEvent.OnClientEvent:Connect(function(data)
    if data.type == "Damage" then
        showDamage(data.damage)
        
    elseif data.type == "Update" then
        levelLabel.Text = "Level: " .. data.level
        hpLabel.Text = "HP: " .. data.hp .. "/" .. data.maxHp
        expLabel.Text = "EXP: " .. data.exp
        goldLabel.Text = "Gold: " .. data.gold
        
        -- Update quest tracker
        local questText = ""
        if data.activeQuests then
            for questId, quest in pairs(data.activeQuests) do
                local questData = require(ReplicatedStorage:WaitForChild("GameData")):GetQuest(questId)
                if questData then
                    questText = questText .. questData.name .. "\n"
                    
                    -- Show objectives
                    local allComplete = true
                    for i, obj in ipairs(questData.objectives) do
                        local prog = quest.progress[i] or 0
                        local done = prog >= obj.count
                        if not done then allComplete = false end
                        
                        local status = done and "✓" or ">"
                        questText = questText .. "  " .. status .. " " .. obj.target .. ": " .. prog .. "/" .. obj.count .. "\n"
                    end
                    
                    -- If quest ready to complete, show return message
                    if quest.readyToComplete or allComplete then
                        local npcData = require(ReplicatedStorage:WaitForChild("GameData")):GetNPC(questData.giver)
                        local npcName = npcData and npcData.name or questData.giver
                        questText = questText .. "  → Kembali ke " .. npcName .. " untuk ambil reward!\n"
                    end
                    
                    questText = questText .. "\n"
                end
            end
        end
        questList.Text = questText ~= "" and questText or "Tidak ada quest aktif"
        
    elseif data.type == "QuestAccepted" then
        notificationLabel.Text = "Quest Accepted: " .. data.questName
        notificationLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        notificationFrame.Visible = true
        task.delay(3, function()
            notificationFrame.Visible = false
        end)
        
    elseif data.type == "QuestCompleted" then
        notificationLabel.Text = "Quest Complete!\n" .. data.questName .. "\nReward: " .. data.rewards
        notificationLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        notificationFrame.Visible = true
        task.delay(5, function()
            notificationFrame.Visible = false
        end)
        
    elseif data.type == "QuestReady" then
        local npcData = require(ReplicatedStorage:WaitForChild("GameData")):GetNPC(data.npcName)
        local npcName = npcData and npcData.name or data.npcName
        notificationLabel.Text = "Quest Selesai: " .. data.questName .. "\nKembali ke " .. npcName .. " untuk ambil reward!"
        notificationLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        notificationFrame.Visible = true
        task.delay(5, function()
            notificationFrame.Visible = false
        end)
    end
end)

print("[Client] Update handler ready!")

-- ============================================
-- SHOP HANDLER
-- ============================================

ShopEvent.OnClientEvent:Connect(function(data)
    if data.type == "Open" then
        -- Clear old items
        for _, child in ipairs(shopItems:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        -- Add items
        for _, item in ipairs(data.items) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 40)
            row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            row.BorderSizePixel = 0
            row.Parent = shopItems
            
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
            
            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(0.6, 0, 1, 0)
            name.BackgroundTransparency = 1
            name.Text = item.name
            name.TextColor3 = Color3.fromRGB(255, 255, 255)
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Font = Enum.Font.Gotham
            name.TextScaled = true
            name.Parent = row
            
            local price = Instance.new("TextLabel")
            price.Size = UDim2.new(0.2, 0, 1, 0)
            price.Position = UDim2.new(0.6, 0, 0, 0)
            price.BackgroundTransparency = 1
            price.Text = item.price .. "G"
            price.TextColor3 = Color3.fromRGB(255, 215, 0)
            price.Font = Enum.Font.GothamBold
            price.TextScaled = true
            price.Parent = row
            
            local buyBtn = Instance.new("TextButton")
            buyBtn.Size = UDim2.new(0.2, -5, 0.8, 0)
            buyBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
            buyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            buyBtn.BorderSizePixel = 0
            buyBtn.Text = "Buy"
            buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            buyBtn.Font = Enum.Font.GothamBold
            buyBtn.TextScaled = true
            buyBtn.Parent = row
            
            buyBtn.MouseButton1Click:Connect(function()
                ShopEvent:FireServer("buy", {itemId = item.id})
            end)
        end
        
        shopGold.Text = "Gold: " .. data.gold
        shopFrame.Visible = true
        
    elseif data.type == "Bought" then
        shopGold.Text = "Gold: " .. data.gold
        goldLabel.Text = "Gold: " .. data.gold
        
    elseif data.type == "Error" then
        warn("[Shop] " .. data.message)
    end
end)

print("[Client] Shop handler ready!")

-- ============================================
-- DIALOGUE HANDLER
-- ============================================

local currentNPC = nil

DialogueEvent.OnClientEvent:Connect(function(data)
    if data.type == "Start" or data.type == "Continue" then
        currentNPC = data.npcId
        npcName.Text = data.npcName or data.npcId
        dialogueText.Text = data.dialogue.text
        
        -- Clear old responses
        for _, child in ipairs(responseFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        -- Add responses
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
                    npcId = currentNPC,
                    responseText = resp.text,
                })
            end)
        end
        
        dialogueFrame.Visible = true
        
    elseif data.type == "End" then
        dialogueFrame.Visible = false
        currentNPC = nil
    end
end)

print("[Client] Dialogue handler ready!")

-- ============================================
-- NPC INTERACTION
-- ============================================

task.spawn(function()
    task.wait(5)
    
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, npc in ipairs(npcFolder:GetChildren()) do
            local click = npc:FindFirstChild("ClickDetector")
            if click then
                click.MouseClick:Connect(function()
                    local npcId = npc:GetAttribute("NPCId") or npc.Name
                    local hasShop = npc:GetAttribute("HasShop")
                    local hasQuest = npc:GetAttribute("HasQuest")
                    
                    if hasShop then
                        local shopId = npc:GetAttribute("ShopId")
                        if shopId then
                            ShopEvent:FireServer("open", {shopId = shopId})
                        end
                    else
                        DialogueEvent:FireServer("talk", {npcId = npcId})
                    end
                end)
            end
        end
        print("[Client] NPC interactions ready!")
    end
end)

-- ============================================
-- MONSTER INTERACTION
-- ============================================

task.spawn(function()
    task.wait(5)
    
    local monsterFolder = workspace:FindFirstChild("Monsters")
    if monsterFolder then
        for _, monster in ipairs(monsterFolder:GetChildren()) do
            local click = monster:FindFirstChild("ClickDetector")
            if click then
                click.MouseClick:Connect(function()
                    AttackEvent:FireServer(monster)
                end)
            end
        end
        print("[Client] Monster interactions ready!")
    end
end)

print("[Client] ==========================================")
print("[Client] Client ready!")
print("[Client] ==========================================")
