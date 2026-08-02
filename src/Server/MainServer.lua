--[[
    Arcadia Online - Main Server Script
    
    SEMUA server logic ada di sini!
    Place di: ServerScriptService (as Script)
    
    @author arcadiastore
    @version 4.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Server] ==========================================")
print("[Server] Arcadia Online Server Starting...")
print("[Server] ==========================================")

-- Wait for GameData
task.wait(2)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
print("[Server] GameData loaded!")

-- ============================================
-- CREATE EVENTS
-- ============================================

local Events = Instance.new("Folder")
Events.Name = "Events"
Events.Parent = ReplicatedStorage

local function makeEvent(name)
    local e = Instance.new("RemoteEvent")
    e.Name = name
    e.Parent = Events
    return e
end

local AttackEvent = makeEvent("AttackEvent")
local ShopEvent = makeEvent("ShopEvent")
local QuestEvent = makeEvent("QuestEvent")
local DialogueEvent = makeEvent("DialogueEvent")
local UpdateEvent = makeEvent("UpdateEvent")

print("[Server] Events created!")

-- ============================================
-- PLAYER DATA
-- ============================================

local playerData = {}

local function initPlayer(player)
    playerData[player.UserId] = {
        level = 1,
        exp = 0,
        gold = 100,
        hp = 100,
        maxHp = 100,
        atk = 10,
        def = 5,
        activeQuests = {},
        completedQuests = {},
        inventory = {},
    }
    print("[Server] Player data init: " .. player.Name)
end

local function removePlayer(player)
    playerData[player.UserId] = nil
    print("[Server] Player data removed: " .. player.Name)
end

Players.PlayerAdded:Connect(initPlayer)
Players.PlayerRemoving:Connect(removePlayer)

for _, p in ipairs(Players:GetPlayers()) do
    initPlayer(p)
end

-- ============================================
-- COMBAT SYSTEM
-- ============================================

AttackEvent.OnServerEvent:Connect(function(player, monsterPart)
    if not monsterPart or not monsterPart.Parent then return end
    
    local monsterId = monsterPart:GetAttribute("MonsterId")
    if not monsterId then return end
    
    local data = playerData[player.UserId]
    if not data then return end
    
    local monsterData = GameData:GetMonster(monsterId)
    if not monsterData then return end
    
    -- Get monster HP
    local monsterHP = monsterPart:GetAttribute("CurrentHP")
    if not monsterHP then
        monsterHP = monsterData.hp
        monsterPart:SetAttribute("CurrentHP", monsterHP)
    end
    
    -- Calculate damage
    local damage = GameData.Formulas.physicalDamage(data.atk, 1.0, monsterData.def)
    
    -- Apply damage
    monsterHP = monsterHP - damage
    monsterPart:SetAttribute("CurrentHP", monsterHP)
    
    -- Send feedback to client
    UpdateEvent:FireClient(player, {
        type = "Damage",
        damage = damage,
        target = monsterId,
    })
    
    -- Check if monster died
    if monsterHP <= 0 then
        -- Give rewards
        data.exp = data.exp + monsterData.exp
        data.gold = data.gold + monsterData.gold
        
        print("[Server] " .. player.Name .. " killed " .. monsterId .. " +" .. monsterData.exp .. "EXP +" .. monsterData.gold .. "G")
        
        -- Update quest progress
        for questId, quest in pairs(data.activeQuests) do
            local questData = GameData:GetQuest(questId)
            if questData then
                for i, obj in ipairs(questData.objectives) do
                    if obj.type == "kill" and obj.target == monsterId then
                        quest.progress[i] = (quest.progress[i] or 0) + 1
                        print("[Server] Quest progress: " .. questId .. " " .. quest.progress[i] .. "/" .. obj.count)
                    end
                end
            end
        end
        
        -- Check quest completion
        for questId, quest in pairs(data.activeQuests) do
            local questData = GameData:GetQuest(questId)
            if questData then
                local complete = true
                for i, obj in ipairs(questData.objectives) do
                    if (quest.progress[i] or 0) < obj.count then
                        complete = false
                        break
                    end
                end
                if complete then
                    data.completedQuests[questId] = true
                    data.activeQuests[questId] = nil
                    data.exp = data.exp + questData.rewards.exp
                    data.gold = data.gold + questData.rewards.gold
                    print("[Server] Quest completed: " .. questId)
                end
            end
        end
        
        -- Check level up
        local expNeeded = GameData:CalculateExpForLevel(data.level + 1)
        while data.exp >= expNeeded do
            data.exp = data.exp - expNeeded
            data.level = data.level + 1
            data.maxHp = data.maxHp + 10
            data.hp = data.maxHp
            data.atk = data.atk + 2
            data.def = data.def + 1
            expNeeded = GameData:CalculateExpForLevel(data.level + 1)
            print("[Server] " .. player.Name .. " level up! Lv." .. data.level)
        end
        
        -- Send update to client
        UpdateEvent:FireClient(player, {
            type = "Update",
            level = data.level,
            exp = data.exp,
            gold = data.gold,
            hp = data.hp,
            maxHp = data.maxHp,
            atk = data.atk,
            def = data.def,
            activeQuests = data.activeQuests,
            completedQuests = data.completedQuests,
        })
        
        -- Respawn monster
        task.delay(monsterData.respawnTime, function()
            if monsterPart and monsterPart.Parent then
                monsterPart:SetAttribute("CurrentHP", monsterData.hp)
                monsterPart.Transparency = 0
                monsterPart.CanCollide = true
            end
        end)
        
        -- Hide monster
        monsterPart.Transparency = 1
        monsterPart.CanCollide = false
    end
end)

print("[Server] Combat system ready!")

-- ============================================
-- QUEST SYSTEM
-- ============================================

QuestEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = playerData[player.UserId]
    if not pData then return end
    
    if action == "accept" then
        local questId = data.questId
        local questData = GameData:GetQuest(questId)
        if not questData then return end
        
        -- Check if already active or completed
        if pData.activeQuests[questId] or pData.completedQuests[questId] then
            return
        end
        
        -- Check prerequisite
        if questData.prerequisite and not pData.completedQuests[questData.prerequisite] then
            return
        end
        
        -- Add quest
        pData.activeQuests[questId] = {
            id = questId,
            progress = {},
        }
        for i, obj in ipairs(questData.objectives) do
            pData.activeQuests[questId].progress[i] = 0
        end
        
        print("[Server] " .. player.Name .. " accepted quest: " .. questId)
        
        -- Update client
        UpdateEvent:FireClient(player, {
            type = "Update",
            level = pData.level,
            exp = pData.exp,
            gold = pData.gold,
            hp = pData.hp,
            maxHp = pData.maxHp,
            atk = pData.atk,
            def = pData.def,
            activeQuests = pData.activeQuests,
            completedQuests = pData.completedQuests,
        })
    end
end)

print("[Server] Quest system ready!")

-- ============================================
-- SHOP SYSTEM
-- ============================================

ShopEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = playerData[player.UserId]
    if not pData then return end
    
    if action == "open" then
        local shopId = data.shopId
        local shopData = GameData:GetShop(shopId)
        if not shopData then return end
        
        local shopItems = GameData:GetShopItems(shopId)
        
        ShopEvent:FireClient(player, {
            type = "Open",
            shop = shopData,
            items = shopItems,
            gold = pData.gold,
        })
        
        print("[Server] " .. player.Name .. " opened shop: " .. shopId)
        
    elseif action == "buy" then
        local itemId = data.itemId
        local itemData = GameData:GetItem(itemId)
        if not itemData then return end
        
        if pData.gold < itemData.price then
            ShopEvent:FireClient(player, {type = "Error", message = "Gold tidak cukup!"})
            return
        end
        
        pData.gold = pData.gold - itemData.price
        pData.inventory[itemId] = (pData.inventory[itemId] or 0) + 1
        
        print("[Server] " .. player.Name .. " bought " .. itemId)
        
        ShopEvent:FireClient(player, {
            type = "Bought",
            itemId = itemId,
            gold = pData.gold,
        })
        
        UpdateEvent:FireClient(player, {
            type = "Update",
            level = pData.level,
            exp = pData.exp,
            gold = pData.gold,
            hp = pData.hp,
            maxHp = pData.maxHp,
            atk = pData.atk,
            def = pData.def,
            activeQuests = pData.activeQuests,
            completedQuests = pData.completedQuests,
        })
    end
end)

print("[Server] Shop system ready!")

-- ============================================
-- DIALOGUE SYSTEM
-- ============================================

DialogueEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "talk" then
        local npcId = data.npcId
        local dialogueData = GameData:GetDialogue(npcId)
        if not dialogueData then return end
        
        local npcData = GameData:GetNPC(npcId)
        
        DialogueEvent:FireClient(player, {
            type = "Start",
            npcId = npcId,
            npcName = npcData and npcData.name or npcId,
            dialogue = dialogueData.greeting,
        })
        
    elseif action == "respond" then
        local npcId = data.npcId
        local responseText = data.responseText
        local dialogueData = GameData:GetDialogue(npcId)
        if not dialogueData then return end
        
        -- Find current dialogue
        local current = dialogueData.greeting
        local selected = nil
        
        for _, resp in ipairs(current.responses) do
            if resp.text == responseText then
                selected = resp
                break
            end
        end
        
        if not selected then return end
        
        -- Check if opens shop
        if current.openShop then
            ShopEvent:FireServer("open", {shopId = current.openShop})
            return
        end
        
        -- Check if gives quest
        if current.questId then
            QuestEvent:FireServer("accept", {questId = current.questId})
            return
        end
        
        -- Go to next dialogue
        if selected.next then
            local nextDialogue = dialogueData[selected.next]
            if nextDialogue then
                DialogueEvent:FireClient(player, {
                    type = "Continue",
                    npcId = npcId,
                    dialogue = nextDialogue,
                })
            end
        else
            DialogueEvent:FireClient(player, {
                type = "End",
                npcId = npcId,
            })
        end
    end
end)

print("[Server] Dialogue system ready!")

-- ============================================
-- SPAWN NPCs
-- ============================================

task.wait(1)

local npcFolder = Instance.new("Folder")
npcFolder.Name = "NPCs"
npcFolder.Parent = workspace

for npcId, npcData in pairs(GameData.NPCs) do
    local npc = Instance.new("Part")
    npc.Name = npcId
    npc.Size = Vector3.new(2, 5, 2)
    npc.Position = npcData.position + Vector3.new(0, 2.5, 0)
    npc.Anchored = true
    npc.CanCollide = true
    npc.Color = npcData.color or Color3.fromRGB(200, 200, 200)
    npc.Material = Enum.Material.SmoothPlastic
    
    -- Name tag
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = npc
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = npcData.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 0, 0.6, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = npcData.title or ""
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.TextStrokeTransparency = 0
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextScaled = true
    titleLabel.Parent = billboard
    
    -- Attributes
    npc:SetAttribute("NPCId", npcId)
    npc:SetAttribute("HasShop", npcData.hasShop or false)
    npc:SetAttribute("HasQuest", npcData.hasQuest or false)
    if npcData.hasShop then
        npc:SetAttribute("ShopId", npcData.shopId)
    end
    
    -- ClickDetector
    local click = Instance.new("ClickDetector")
    click.MaxActivationDistance = 15
    click.Parent = npc
    
    npc.Parent = npcFolder
end

print("[Server] NPCs spawned!")

-- ============================================
-- SPAWN MONSTERS
-- ============================================

local monsterFolder = Instance.new("Folder")
monsterFolder.Name = "Monsters"
monsterFolder.Parent = workspace

for monsterId, monsterData in pairs(GameData.Monsters) do
    local spawnData = GameData.SpawnPositions[monsterData.spawnArea]
    if spawnData then
        local count = 1
        if monsterId == "Slime" then count = 5
        elseif monsterId == "Wolf" then count = 4
        elseif monsterId == "Boar" then count = 3
        end
        
        for i = 1, count do
            local positions = spawnData.positions
            local posIndex = ((i - 1) % #positions) + 1
            local basePos = positions[posIndex]
            local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            
            local monster = Instance.new("Part")
            monster.Name = monsterId
            monster.Size = monsterData.size
            monster.Position = basePos + offset + Vector3.new(0, monsterData.size.Y / 2, 0)
            monster.Anchored = true
            monster.CanCollide = true
            monster.Color = monsterData.color
            monster.Material = Enum.Material.SmoothPlastic
            
            if monsterData.shape == "Ball" then
                monster.Shape = Enum.PartType.Ball
            end
            
            -- Name tag
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 120, 0, 60)
            billboard.StudsOffset = Vector3.new(0, monsterData.size.Y + 1, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = monster
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = monsterData.name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextScaled = true
            nameLabel.Parent = billboard
            
            local levelLabel = Instance.new("TextLabel")
            levelLabel.Size = UDim2.new(1, 0, 0.3, 0)
            levelLabel.Position = UDim2.new(0, 0, 0.5, 0)
            levelLabel.BackgroundTransparency = 1
            levelLabel.Text = "Lv." .. monsterData.level
            levelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            levelLabel.TextStrokeTransparency = 0
            levelLabel.Font = Enum.Font.Gotham
            levelLabel.TextScaled = true
            levelLabel.Parent = billboard
            
            -- Attributes
            monster:SetAttribute("MonsterId", monsterId)
            monster:SetAttribute("CurrentHP", monsterData.hp)
            monster:SetAttribute("MaxHP", monsterData.hp)
            
            -- ClickDetector
            local click = Instance.new("ClickDetector")
            click.MaxActivationDistance = 20
            click.Parent = monster
            
            monster.Parent = monsterFolder
        end
    end
end

print("[Server] Monsters spawned!")

print("[Server] ==========================================")
print("[Server] Server ready!")
print("[Server] ==========================================")
