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

-- Create skill bar UI
function SkillBar:Create()
    mainGui = playerGui:FindFirstChild("ArcadiaHUD")
    if not mainGui then
        warn("[SkillBar] No ArcadiaHUD found")
        return
    end
    
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
    if not currentData then return end
    if not currentData.job then return end
    if not currentData.learnedSkills then return end
    
    -- Get skill ID from job
    local jobSkills = {
        Warrior = {"warrior_power_strike", "warrior_shout"},
        Mage = {"mage_fireball", "mage_ice_shield"},
        Archer = {"archer_arrow_rain", "archer_eagle_eye"},
    }
    
    local skills = jobSkills[currentData.job]
    if not skills or not skills[slotIndex] then return end
    
    local skillId = skills[slotIndex]
    
    -- Check if learned
    if not currentData.learnedSkills[skillId] then
        return
    end
    
    -- Check cooldown
    if cooldownTimers[skillId] and tick() < cooldownTimers[skillId] then
        return
    end
    
    -- Check MP
    local skillData = GameData.Skills and GameData.Skills[skillId]
    if not skillData then return end
    if (currentData.mp or 0) < skillData.mpCost then
        return
    end
    
    -- Fire skill event
    local SkillEvent = game.ReplicatedStorage:FindFirstChild("SkillEvent")
    if not SkillEvent then return end
    
    -- Get target monster (closest or current target)
    local monsterPart = SkillBar:GetTargetMonster()
    
    -- For buffs and heals, monster target not needed
    if skillData.type == "buff" or skillData.type == "heal" then
        SkillEvent:FireServer({skillId = skillId, monsterPart = nil})
    else
        if not monsterPart then return end
        SkillEvent:FireServer({skillId = skillId, monsterPart = monsterPart})
    end
    
    -- Start cooldown
    cooldownTimers[skillId] = tick() + skillData.cooldown
    
    print("[SkillBar] Used " .. skillData.name)
end

-- Get closest monster as target
function SkillBar:GetTargetMonster()
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
    
    return closest
end

-- Update skill bar with current player data
function SkillBar:Update(data)
    currentData = data
    
    if not skillFrame then return end
    
    -- Show skill bar only if player has a job
    if not data.job then
        skillFrame.Visible = false
        return
    end
    
    skillFrame.Visible = true
    
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
    if not currentData or not currentData.job then return end
    
    local keyMap = {
        [Enum.KeyCode.One] = 1,
        [Enum.KeyCode.Two] = 2,
        [Enum.KeyCode.Three] = 3,
        [Enum.KeyCode.Four] = 4,
    }
    
    local slot = keyMap[input.KeyCode]
    if slot then
        -- Don't process if typing in a textbox
        if playerGui:FindFirstChild("Chat") and playerGui.Chat:FindFirstChild("ChatBar") then
            local chatBar = playerGui.Chat.ChatBar:FindFirstChild("TextBox")
            if chatBar and chatBar:IsFocused() then return end
        end
        
        self:UseSkill(slot)
    end
end

return SkillBar
