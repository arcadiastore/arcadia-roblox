--[[
    SkillBar.lua
    Displays skill bar with 1-4 keys, cooldowns, and MP cost
]]

local SkillBar = {}

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))
local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = nil
local skillFrame = nil
local skillButtons = {}
local cooldownLabels = {}

local currentData = nil
local cooldownTimers = {}  -- skillId = endTime
local currentTarget = nil  -- Current target monster part
local autoAttackRunning = false
local autoAttackThread = nil
local targetFrame = nil
local targetNameLabel = nil
local targetHPLabel = nil
local targetHPBar = nil

-- Create target frame UI
function SkillBar:CreateTargetFrame()
    if not mainGui then return end
    
    targetFrame = Instance.new("Frame")
    targetFrame.Name = "TargetFrame"
    targetFrame.Size = UDim2.new(0, 200, 0, 50)
    targetFrame.Position = UDim2.new(0.5, -100, 0, 10)
    targetFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    targetFrame.BackgroundTransparency = 0.3
    targetFrame.BorderSizePixel = 0
    targetFrame.Visible = false
    targetFrame.Parent = mainGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = targetFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 2
    stroke.Parent = targetFrame
    
    -- Target name
    targetNameLabel = Instance.new("TextLabel")
    targetNameLabel.Name = "TargetName"
    targetNameLabel.Size = UDim2.new(1, -10, 0, 20)
    targetNameLabel.Position = UDim2.new(0, 5, 0, 5)
    targetNameLabel.BackgroundTransparency = 1
    targetNameLabel.Text = "Target"
    targetNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetNameLabel.TextSize = 14
    targetNameLabel.Font = Enum.Font.SourceSansBold
    targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetNameLabel.Parent = targetFrame
    
    -- HP Bar background
    local hpBarBg = Instance.new("Frame")
    hpBarBg.Name = "HPBarBG"
    hpBarBg.Size = UDim2.new(1, -10, 0, 12)
    hpBarBg.Position = UDim2.new(0, 5, 0, 28)
    hpBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    hpBarBg.BorderSizePixel = 0
    hpBarBg.Parent = targetFrame
    
    local hpCorner = Instance.new("UICorner")
    hpCorner.CornerRadius = UDim.new(0, 4)
    hpCorner.Parent = hpBarBg
    
    -- HP Bar fill
    targetHPBar = Instance.new("Frame")
    targetHPBar.Name = "HPBarFill"
    targetHPBar.Size = UDim2.new(1, 0, 1, 0)
    targetHPBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    targetHPBar.BorderSizePixel = 0
    targetHPBar.Parent = hpBarBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = targetHPBar
    
    -- HP Text
    targetHPLabel = Instance.new("TextLabel")
    targetHPLabel.Name = "HPText"
    targetHPLabel.Size = UDim2.new(1, 0, 1, 0)
    targetHPLabel.BackgroundTransparency = 1
    targetHPLabel.Text = "100/100"
    targetHPLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetHPLabel.TextSize = 10
    targetHPLabel.Font = Enum.Font.SourceSansBold
    targetHPLabel.ZIndex = 2
    targetHPLabel.Parent = hpBarBg
end

-- Update target frame display
function SkillBar:UpdateTargetFrame()
    if not targetFrame then return end
    
    local target = self:GetTarget()
    if not target then
        targetFrame.Visible = false
        return
    end
    
    targetFrame.Visible = true
    
    -- Get monster data
    local monsterId = target:GetAttribute("MonsterId")
    local monsterData = GameData:GetMonster(monsterId)
    
    if monsterData then
        targetNameLabel.Text = monsterData.name .. " (Lv." .. monsterData.level .. ")"
    else
        targetNameLabel.Text = target.Name
    end
    
    -- Get HP
    local currentHP = target:GetAttribute("CurrentHP") or 0
    local maxHP = monsterData and monsterData.hp or 100
    
    -- Update HP bar
    local pct = math.clamp(currentHP / maxHP, 0, 1)
    targetHPBar.Size = UDim2.new(pct, 0, 1, 0)
    targetHPLabel.Text = math.floor(currentHP) .. "/" .. maxHP
    
    -- Color based on HP
    if pct > 0.5 then
        targetHPBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    elseif pct > 0.25 then
        targetHPBar.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
    else
        targetHPBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end
local autoAttackRunning = false
local autoAttackThread = nil

-- Set current target (called from main client when monster is clicked)
function SkillBar:SetTarget(monsterPart)
    currentTarget = monsterPart
    if monsterPart then
        print("[SkillBar] Target set: " .. monsterPart.Name)
        -- Start auto-attack
    else
        print("[SkillBar] Target cleared")
        -- Stop auto-attack
        self:StopAutoAttack()
    end
end

-- Start auto-attack loop
function SkillBar:StartAutoAttack(AttackEvent)
    -- Stop existing auto-attack
    self:StopAutoAttack()
    
    autoAttackRunning = true
    print("[SkillBar] Auto-attack STARTED")
    
    autoAttackThread = task.spawn(function()
        while autoAttackRunning do
            -- Check if target still valid
            local target = self:GetTarget()
            if not target then
                print("[SkillBar] Target invalid, stopping auto-attack")
                autoAttackRunning = false
                break
            end
            
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if rootPart and humanoid then
                    local dist = (target.Position - rootPart.Position).Magnitude
                    
                    -- Walk to target if too far
                    if dist > 10 then
                        humanoid:MoveTo(target.Position)
                        print("[SkillBar] Walking to target... dist=" .. math.floor(dist))
                    else
                        -- In range, attack!
                        humanoid:MoveTo(rootPart.Position)  -- Stop moving
                        print("[SkillBar] ATTACKING! dist=" .. math.floor(dist))
                        AttackEvent:FireServer(target)
                    end
                end
            end
            
            -- Wait based on weapon speed
            local cooldown = 1.0
            if currentData and currentData.equipment then
                local weaponId = currentData.equipment.weapon1h or currentData.equipment.weapon2h
                if weaponId then
                    local GameDataItems = GameData.Items or {}
                    local wData = GameDataItems[weaponId]
                    if wData and wData.stats and wData.stats.spd then
                        cooldown = math.max(0.4, 1.2 - (wData.stats.spd * 0.05))
                    end
                end
            end
            
            task.wait(cooldown + 0.1)
        end
        print("[SkillBar] Auto-attack STOPPED")
    end)
end

-- Stop auto-attack
function SkillBar:StopAutoAttack()
    autoAttackRunning = false
    if autoAttackThread then
        task.cancel(autoAttackThread)
        autoAttackThread = nil
    end
end

-- Get current target
function SkillBar:GetTarget()
    -- Validate target still exists and alive
    if currentTarget and currentTarget.Parent then
        local hp = currentTarget:GetAttribute("CurrentHP")
        if hp and hp > 0 then
            return currentTarget
        end
    end
    currentTarget = nil
    return nil
end

-- Create skill bar UI
function SkillBar:Create()
    mainGui = playerGui:FindFirstChild("GameHUD")
    if not mainGui then
        -- Create own GUI if HUD not found
        mainGui = Instance.new("ScreenGui")
        mainGui.Name = "GameHUD"
        mainGui.ResetOnSpawn = false
        mainGui.Parent = playerGui
    end
    
    -- Create target frame at top
    self:CreateTargetFrame()
    
    -- Skill bar frame at bottom center
    skillFrame = Instance.new("Frame")
    skillFrame.Name = "SkillBar"
    skillFrame.Size = UDim2.new(0, 280, 0, 55)
    skillFrame.Position = UDim2.new(0.5, -140, 1, -110)
    skillFrame.BackgroundTransparency = 0.3
    skillFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    skillFrame.BorderSizePixel = 0
    skillFrame.Visible = false
    skillFrame.Parent = mainGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = skillFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 150)
    stroke.Thickness = 2
    stroke.Parent = skillFrame
    
    -- 4 skill slots
    for i = 1, 4 do
        local btn = Instance.new("TextButton")
        btn.Name = "Skill" .. i
        btn.Size = UDim2.new(0, 55, 0, 45)
        btn.Position = UDim2.new(0, 10 + (i-1) * 65, 0, 5)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        btn.Text = ""
        btn.AutoButtonColor = true
        btn.Parent = skillFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        -- Key number
        local keyLabel = Instance.new("TextLabel")
        keyLabel.Name = "KeyLabel"
        keyLabel.Size = UDim2.new(0, 16, 0, 16)
        keyLabel.Position = UDim2.new(0, 2, 0, 2)
        keyLabel.BackgroundTransparency = 1
        keyLabel.Text = tostring(i)
        keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        keyLabel.TextSize = 12
        keyLabel.Font = Enum.Font.SourceSansBold
        keyLabel.Parent = btn
        
        -- Skill name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, -4, 1, -18)
        nameLabel.Position = UDim2.new(0, 2, 0, 16)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = ""
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 10
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextWrapped = true
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = btn
        
        -- Cooldown overlay
        local cdOverlay = Instance.new("Frame")
        cdOverlay.Name = "CooldownOverlay"
        cdOverlay.Size = UDim2.new(1, 0, 0, 0)
        cdOverlay.Position = UDim2.new(0, 0, 1, 0)
        cdOverlay.AnchorPoint = Vector2.new(0, 1)
        cdOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        cdOverlay.BackgroundTransparency = 0.4
        cdOverlay.BorderSizePixel = 0
        cdOverlay.ZIndex = 2
        cdOverlay.Parent = btn
        
        local cdCorner = Instance.new("UICorner")
        cdCorner.CornerRadius = UDim.new(0, 8)
        cdCorner.Parent = cdOverlay
        
        -- Cooldown text
        local cdLabel = Instance.new("TextLabel")
        cdLabel.Name = "CooldownLabel"
        cdLabel.Size = UDim2.new(1, 0, 1, 0)
        cdLabel.BackgroundTransparency = 1
        cdLabel.Text = ""
        cdLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        cdLabel.TextSize = 16
        cdLabel.Font = Enum.Font.SourceSansBold
        cdLabel.ZIndex = 3
        cdLabel.Visible = false
        cdLabel.Parent = btn
        
        -- MP cost label
        local mpLabel = Instance.new("TextLabel")
        mpLabel.Name = "MPCost"
        mpLabel.Size = UDim2.new(1, 0, 0, 12)
        mpLabel.Position = UDim2.new(0, 0, 1, -12)
        mpLabel.BackgroundTransparency = 1
        mpLabel.Text = ""
        mpLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        mpLabel.TextSize = 9
        mpLabel.Font = Enum.Font.SourceSans
        mpLabel.ZIndex = 2
        mpLabel.Parent = btn
        
        skillButtons[i] = btn
        cooldownLabels[i] = {overlay = cdOverlay, label = cdLabel}
        
        -- Click handler
        btn.MouseButton1Click:Connect(function()
            SkillBar:UseSkill(i)
        end)
    end
end

-- Use skill by slot index
function SkillBar:UseSkill(slotIndex)
    print("[SkillBar] UseSkill called! slot=" .. slotIndex)
    
    if not currentData then
        warn("[SkillBar] UseSkill: no currentData")
        return
    end
    if not currentData.job then
        warn("[SkillBar] UseSkill: no job")
        return
    end
    if not currentData.learnedSkills then
        warn("[SkillBar] UseSkill: no learnedSkills")
        return
    end
    
    -- Get skill ID from job
    local jobSkills = {
        Warrior = {"warrior_power_strike", "warrior_shout"},
        Mage = {"mage_fireball", "mage_ice_shield"},
        Archer = {"archer_arrow_rain", "archer_eagle_eye"},
    }
    
    local skills = jobSkills[currentData.job]
    print("[SkillBar] Job=" .. currentData.job .. " skills=" .. tostring(skills))
    
    if not skills or not skills[slotIndex] then
        warn("[SkillBar] No skill at slot " .. slotIndex)
        return
    end
    
    local skillId = skills[slotIndex]
    print("[SkillBar] skillId=" .. skillId)
    
    -- Check if learned
    if not currentData.learnedSkills[skillId] then
        warn("[SkillBar] Skill not learned: " .. skillId)
        print("[SkillBar] learnedSkills keys:")
        for k, v in pairs(currentData.learnedSkills) do
            print("  " .. k .. " = " .. tostring(v))
        end
        SkillBar:ShowNotLearned(slotIndex)
        return
    end
    
    -- Check cooldown
    if cooldownTimers[skillId] and tick() < cooldownTimers[skillId] then
        SkillBar:ShowOnCooldown(slotIndex)
        return
    end
    
    -- Check MP
    local skillData = GameData.Skills and GameData.Skills[skillId]
    if not skillData then return end
    if (currentData.mp or 0) < skillData.mpCost then
        SkillBar:ShowNoMP(slotIndex)
        return
    end
    
    -- VISUAL: Button flash animation
    SkillBar:FlashButton(slotIndex)
    
    -- VISUAL: Skill name popup on screen
    SkillBar:ShowSkillPopup(skillData.name, skillData.type)
    
    -- Fire skill event
    local SkillEvent = game.ReplicatedStorage:FindFirstChild("SkillEvent")
    if not SkillEvent then return end
    
    -- Get target monster (closest or current target)
    local monsterPart = SkillBar:GetTargetMonster()
    
    -- For buffs and heals, monster target not needed
    if skillData.type == "buff" or skillData.type == "heal" then
        print("[SkillBar] >>> SENDING SKILL: " .. skillId .. " (no target)")
        SkillEvent:FireServer({skillId = skillId, monsterPart = nil})
    else
        local target = monsterPart or self:GetTargetMonster()
        if not target then
            warn("[SkillBar] No target for damage skill!")
            return
        end
        print("[SkillBar] >>> SENDING SKILL: " .. skillId .. " to " .. target.Name)
        SkillEvent:FireServer({skillId = skillId, monsterPart = target})
    end
    
    -- Start cooldown
    cooldownTimers[skillId] = tick() + skillData.cooldown
    
    print("[SkillBar] Used " .. skillData.name)
end

-- Get closest monster as target
function SkillBar:GetTargetMonster()
    -- First, use current target if valid
    local target = self:GetTarget()
    if target then
        return target
    end
    
    -- Otherwise, find closest monster
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local closest = nil
    local closestDist = 100  -- Max range
    
    local worldFolder = workspace:FindFirstChild("World")
    if not worldFolder then return nil end
    local monstersFolder = worldFolder:FindFirstChild("Monsters")
    if not monstersFolder then return nil end
    
    for _, monster in ipairs(monstersFolder:GetChildren()) do
        local hp = monster:GetAttribute("CurrentHP")
        if hp and hp > 0 then
            local dist = (monster.Position - rootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = monster
            end
        end
    end
    
    -- Set as current target
    if closest then
        currentTarget = closest
    end
    
    return closest
end

-- Update skill bar with current player data
function SkillBar:Update(data)
    currentData = data
    
    if not skillFrame then return end
    
    -- Always show skill bar
    skillFrame.Visible = true
    
    -- If no job, show empty slots
    if not data.job then
        for i = 1, 4 do
            local btn = skillButtons[i]
            if btn then
                local nameLabel = btn:FindFirstChild("NameLabel")
                local mpLabel = btn:FindFirstChild("MPCost")
                if nameLabel then nameLabel.Text = "Pilih Job" end
                if mpLabel then mpLabel.Text = "" end
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                btn.BackgroundTransparency = 0.7
            end
        end
        return
    end
    
    -- Job skill mapping
    local jobSkills = {
        Warrior = {"warrior_power_strike", "warrior_shout"},
        Mage = {"mage_fireball", "mage_ice_shield"},
        Archer = {"archer_arrow_rain", "archer_eagle_eye"},
    }
    
    local skills = jobSkills[data.job] or {}
    
    for i = 1, 4 do
        local btn = skillButtons[i]
        if not btn then continue end
        
        local skillId = skills[i]
        local nameLabel = btn:FindFirstChild("NameLabel")
        local mpLabel = btn:FindFirstChild("MPCost")
        
        if skillId and data.learnedSkills and data.learnedSkills[skillId] then
            local skillData = GameData.Skills and GameData.Skills[skillId]
            if skillData then
                nameLabel.Text = skillData.name
                mpLabel.Text = "MP: " .. skillData.mpCost
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
                
                -- Check if enough MP
                if (data.mp or 0) < skillData.mpCost then
                    btn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
                end
            end
        elseif skillId then
            -- Skill not learned yet
            local skillData = GameData.Skills and GameData.Skills[skillId]
            nameLabel.Text = skillData and ("Lv.5: " .. skillData.name) or "???"
            mpLabel.Text = ""
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.BackgroundTransparency = 0.5
        else
            nameLabel.Text = ""
            mpLabel.Text = ""
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            btn.BackgroundTransparency = 0.7
        end
    end
end

-- Update cooldown displays (called every frame)
function SkillBar:UpdateCooldowns()
    -- Update target frame
    self:UpdateTargetFrame()
    
    if not currentData or not currentData.job then return end
    
    local jobSkills = {
        Warrior = {"warrior_power_strike", "warrior_shout"},
        Mage = {"mage_fireball", "mage_ice_shield"},
        Archer = {"archer_arrow_rain", "archer_eagle_eye"},
    }
    
    local skills = jobSkills[currentData.job] or {}
    local now = tick()
    
    for i = 1, 4 do
        local skillId = skills[i]
        local cdInfo = cooldownLabels[i]
        if not cdInfo then continue end
        
        if skillId and cooldownTimers[skillId] then
            local remaining = cooldownTimers[skillId] - now
            if remaining > 0 then
                local skillData = GameData.Skills and GameData.Skills[skillId]
                local maxCd = skillData and skillData.cooldown or 1
                local pct = remaining / maxCd
                cdInfo.overlay.Size = UDim2.new(1, 0, pct, 0)
                cdInfo.label.Text = math.ceil(remaining) .. "s"
                cdInfo.label.Visible = true
            else
                cdInfo.overlay.Size = UDim2.new(1, 0, 0, 0)
                cdInfo.label.Visible = false
                cooldownTimers[skillId] = nil
            end
        else
            cdInfo.overlay.Size = UDim2.new(1, 0, 0, 0)
            cdInfo.label.Visible = false
        end
    end
end

-- Handle key input for skills
function SkillBar:HandleInput(input)
    print("[SkillBar] HandleInput called! KeyCode=" .. tostring(input.KeyCode))
    
    if not currentData then
        warn("[SkillBar] No currentData!")
        return
    end
    if not currentData.job then
        warn("[SkillBar] No job! currentData.job is nil")
        return
    end
    
    local keyMap = {
        [Enum.KeyCode.One] = 1,
        [Enum.KeyCode.Two] = 2,
        [Enum.KeyCode.Three] = 3,
        [Enum.KeyCode.Four] = 4,
    }
    
    local slot = keyMap[input.KeyCode]
    print("[SkillBar] Slot=" .. tostring(slot))
    
    if slot then
        self:UseSkill(slot)
    end
end

-- ============================================
-- VISUAL EFFECTS
-- ============================================

-- Flash button when skill is used
function SkillBar:FlashButton(slotIndex)
    local btn = skillButtons[slotIndex]
    if not btn then return end
    
    local TweenService = game:GetService("TweenService")
    local originalColor = btn.BackgroundColor3
    
    -- Flash white
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local tween = TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = originalColor})
    tween:Play()
end

-- Show skill name popup on screen
function SkillBar:ShowSkillPopup(skillName, skillType)
    if not mainGui then return end
    
    local TweenService = game:GetService("TweenService")
    
    -- Color based on skill type
    local color = Color3.fromRGB(255, 200, 50)  -- Default gold
    if skillType == "physical" then
        color = Color3.fromRGB(255, 100, 50)  -- Orange
    elseif skillType == "magic" then
        color = Color3.fromRGB(100, 150, 255)  -- Blue
    elseif skillType == "heal" then
        color = Color3.fromRGB(50, 255, 100)  -- Green
    elseif skillType == "buff" then
        color = Color3.fromRGB(200, 100, 255)  -- Purple
    end
    
    -- Create popup
    local popup = Instance.new("TextLabel")
    popup.Name = "SkillPopup"
    popup.Size = UDim2.new(0, 200, 0, 40)
    popup.Position = UDim2.new(0.5, -100, 0.5, -80)
    popup.BackgroundTransparency = 1
    popup.Text = skillName .. "!"
    popup.TextColor3 = color
    popup.TextSize = 28
    popup.Font = Enum.Font.SourceSansBold
    popup.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    popup.TextStrokeTransparency = 0.3
    popup.ZIndex = 100
    popup.Parent = mainGui
    
    -- Animate: fade out and move up
    local tweenUp = TweenService:Create(popup, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -100, 0.5, -130),
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    })
    tweenUp:Play()
    tweenUp.Completed:Connect(function()
        popup:Destroy()
    end)
end

-- Show "not learned" feedback
function SkillBar:ShowNotLearned(slotIndex)
    local btn = skillButtons[slotIndex]
    if not btn then return end
    
    local TweenService = game:GetService("TweenService")
    
    -- Flash red
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    local tween = TweenService:Create(btn, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
    tween:Play()
end

-- Show "on cooldown" feedback
function SkillBar:ShowOnCooldown(slotIndex)
    local btn = skillButtons[slotIndex]
    if not btn then return end
    
    local TweenService = game:GetService("TweenService")
    
    -- Flash yellow
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
    local tween = TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 90)})
    tween:Play()
end

-- Show "no MP" feedback
function SkillBar:ShowNoMP(slotIndex)
    local btn = skillButtons[slotIndex]
    if not btn then return end
    
    local TweenService = game:GetService("TweenService")
    
    -- Flash blue
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
    local tween = TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 40, 40)})
    tween:Play()
    
    -- Show "No MP" text briefly
    local nameLabel = btn:FindFirstChild("NameLabel")
    if nameLabel then
        local original = nameLabel.Text
        nameLabel.Text = "No MP!"
        nameLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        task.delay(1, function()
            if nameLabel then
                nameLabel.Text = original
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
    end
end

return SkillBar
