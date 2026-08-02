--[[
    CombatSystem.lua
    Handles monster attacking, damage, death, respawn
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local CombatSystem = {}

-- Handle attack event
function CombatSystem:HandleAttack(player, monsterPart, playerData, events)
    print("[Combat] HandleAttack called by " .. player.Name)
    
    if not monsterPart or not monsterPart.Parent then
        warn("[Combat] Invalid monster part")
        return
    end
    
    local monsterId = monsterPart:GetAttribute("MonsterId")
    print("[Combat] MonsterId: " .. tostring(monsterId))
    
    if not monsterId then
        warn("[Combat] No MonsterId attribute on " .. monsterPart.Name)
        return
    end
    
    local data = playerData:Get(player)
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
    local damage = GameData:CalculateDamage(data.atk, 1.0, monsterData.def)
    
    -- Apply damage
    monsterHP = monsterHP - damage
    monsterPart:SetAttribute("CurrentHP", monsterHP)
    
    -- Update HP bar visual (BillboardGui)
    local billboard = monsterPart:FindFirstChild("BillboardGui")
    if billboard then
        local hpLabel = billboard:FindFirstChild("HPLabel")
        if hpLabel then
            hpLabel.Text = "HP: " .. math.max(0, monsterHP) .. "/" .. monsterData.hp
            -- Color: green > yellow > red
            local pct = monsterHP / monsterData.hp
            if pct > 0.5 then
                hpLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            elseif pct > 0.25 then
                hpLabel.TextColor3 = Color3.fromRGB(255, 255, 50)
            else
                hpLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
            print("[Combat] Updated HP label: " .. hpLabel.Text)
        else
            warn("[Combat] HPLabel not found in BillboardGui!")
        end
    else
        warn("[Combat] BillboardGui not found on " .. monsterPart.Name)
    end
    
    print("[Combat] " .. player.Name .. " hit " .. monsterId .. " DMG:" .. damage .. " HP:" .. monsterHP .. "/" .. monsterData.hp)
    
    -- Send damage feedback to client
    events.UpdateEvent:FireClient(player, {
        type = "Damage",
        damage = damage,
        target = monsterId,
    })
    
    -- Check if monster died
    if monsterHP <= 0 then
        self:OnMonsterDeath(player, monsterPart, monsterId, monsterData, data, playerData, events)
    end
end

-- Handle monster death
function CombatSystem:OnMonsterDeath(player, monsterPart, monsterId, monsterData, data, playerData, events)
    -- Give rewards
    data.exp = data.exp + monsterData.exp
    data.gold = data.gold + monsterData.gold
    print("[Combat] " .. player.Name .. " killed " .. monsterId .. " +" .. monsterData.exp .. "EXP +" .. monsterData.gold .. "G")
    
    -- Update quest progress (ONLY ON DEATH!)
    for questId, quest in pairs(data.activeQuests) do
        local questData = GameData:GetQuest(questId)
        if questData then
            for i, obj in ipairs(questData.objectives) do
                if obj.type == "kill" and obj.target == monsterId then
                    quest.progress[i] = (quest.progress[i] or 0) + 1
                    print("[Combat] Quest progress: " .. questId .. " " .. quest.progress[i] .. "/" .. obj.count)
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
                quest.readyToComplete = true
                print("[Combat] Quest ready to turn in: " .. questId)
                
                -- Notify player
                events.UpdateEvent:FireClient(player, {
                    type = "QuestReady",
                    questId = questId,
                    questName = questData.name,
                    npcName = questData.giver,
                })
            end
        end
    end
    
    -- Check level up
    playerData:CheckLevelUp(player, events)
    
    -- Send update
    playerData:SendUpdate(player, events)
    
    -- Hide monster
    monsterPart.Transparency = 1
    monsterPart.CanCollide = false
    
    -- Disable ClickDetector
    local clickDetector = monsterPart:FindFirstChild("ClickDetector")
    if clickDetector then
        clickDetector.MaxActivationDistance = 0
    end
    
    -- Hide name tag
    local billboard = monsterPart:FindFirstChild("BillboardGui")
    if billboard then
        billboard.Enabled = false
    end
    
    -- Respawn monster
    task.delay(monsterData.respawnTime, function()
        if monsterPart and monsterPart.Parent then
            monsterPart:SetAttribute("CurrentHP", monsterData.hp)
            monsterPart.Transparency = 0
            monsterPart.CanCollide = true
            
            if clickDetector then
                clickDetector.MaxActivationDistance = 20
            end
            if billboard then
                billboard.Enabled = true
                -- Reset HP text
                local hpLabel = billboard:FindFirstChild("HPLabel")
                if hpLabel then
                    hpLabel.Text = "HP: " .. monsterData.hp .. "/" .. monsterData.hp
                    hpLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                end
            end
            
            print("[Combat] Monster respawned: " .. monsterId)
        end
    end)
end

return CombatSystem
