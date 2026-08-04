--[[
    EquipmentVisuals.lua
    Shows equipped items on player character
    
    Attach visual parts to character body based on equipment data.
    Supports R6 body part names.
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local EquipmentVisuals = {}

-- Tag name for cleanup
local TAG = "EquipVisual"

-- R6 Body part names
local R6_PARTS = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

-- Wait for all R6 body parts to load
local function waitForBodyParts(character, timeout)
    timeout = timeout or 5
    local startTime = tick()
    
    for _, partName in ipairs(R6_PARTS) do
        local part = character:FindFirstChild(partName)
        while not part and (tick() - startTime) < timeout do
            task.wait(0.1)
            part = character:FindFirstChild(partName)
        end
        if not part then
            warn("[EquipVisual] Timeout waiting for: " .. partName)
            return false
        end
    end
    
    return true
end

-- Check if character is R6
local function isR6(character)
    return character:FindFirstChild("Torso") ~= nil 
       and character:FindFirstChild("Right Arm") ~= nil
end

-- Remove all visual parts from character
function EquipmentVisuals:ClearVisuals(character)
    if not character then return end
    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BasePart") and child:GetAttribute(TAG) then
            child:Destroy()
        end
    end
end

-- Create a visual part attached to a body part
local function createVisualPart(character, bodyPartName, visualData, itemData)
    local bodyPart = character:FindFirstChild(bodyPartName)
    if not bodyPart then 
        warn("[EquipVisual] Body part not found: " .. bodyPartName)
        return nil 
    end
    
    local part = Instance.new("Part")
    part.Name = "Equip_" .. (itemData.id or "unknown")
    part.Size = visualData.size or Vector3.new(1, 1, 1)
    part.Color = visualData.color or Color3.fromRGB(255, 255, 255)
    part.Material = Enum.Material.SmoothPlastic
    part.CanCollide = false
    part.Anchored = false
    part.Massless = true
    part:SetAttribute(TAG, true)
    
    -- Shape
    if visualData.shape == "Ball" then
        part.Shape = Enum.PartType.Ball
    elseif visualData.shape == "Cylinder" then
        part.Shape = Enum.PartType.Cylinder
    end
    
    -- Attach to body part
    local offset = visualData.offset or CFrame.new()
    part.CFrame = bodyPart.CFrame * offset
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = bodyPart
    weld.Part1 = part
    weld.Parent = part
    
    part.Parent = character
    
    return part
end

-- Force character to R6 by respawning if needed
function EquipmentVisuals:EnsureR6(player)
    local character = player.Character
    if not character then return end
    
    -- If already R6, no need to do anything
    if isR6(character) then
        return true
    end
    
    -- Character is R15, need to respawn as R6
    print("[EquipVisual] Character is R15, forcing R6 respawn...")
    
    -- Store current position
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local savedPos = rootPart and rootPart.Position or Vector3.new(0, 5, 0)
    
    -- Destroy current character
    character:BreakJoints()
    
    -- Wait for character to be removed
    task.wait(0.5)
    
    -- The CharacterAdded event will handle the rest
    return false
end

-- Apply equipment visuals to character
function EquipmentVisuals:ApplyVisuals(character, playerData)
    if not character then 
        warn("[EquipVisual] No character!")
        return 
    end
    if not playerData then
        warn("[EquipVisual] No playerData!")
        return
    end
    
    -- Check if R6
    if not isR6(character) then
        warn("[EquipVisual] Character is not R6! Body parts may be missing.")
        warn("[EquipVisual] Waiting for R6 parts...")
        
        -- Wait a bit more for parts
        if not waitForBodyParts(character, 3) then
            warn("[EquipVisual] Failed to get R6 parts. Aborting visuals.")
            return
        end
    end
    
    -- Clear old visuals
    self:ClearVisuals(character)
    
    local equipment = playerData.equipment
    if not equipment then
        warn("[EquipVisual] No equipment table!")
        return
    end
    
    print("[EquipVisual] Applying visuals for " .. (character.Name or "unknown"))
    
    -- Apply each equipped item
    for slot, itemId in pairs(equipment) do
        if itemId then
            local itemData = GameData:GetItem(itemId)
            if itemData then
                print("[EquipVisual] Processing: " .. itemId .. " (slot: " .. slot .. ")")
                
                if itemData.visual then
                    local v = itemData.visual
                    
                    -- Special: fullBody costume
                    if v.fullBody then
                        for _, partName in ipairs(R6_PARTS) do
                            local part = character:FindFirstChild(partName)
                            if part then
                                part.Color = v.color
                            end
                        end
                    end
                    
                    -- Normal attachment
                    local bodyPartName = v.attachTo or "Torso"
                    local part = createVisualPart(character, bodyPartName, v, itemData)
                    
                    -- Orb on staff
                    if part and v.orb then
                        local orb = Instance.new("Part")
                        orb.Name = "Equip_Orb"
                        orb.Size = v.orb.size or Vector3.new(0.5, 0.5, 0.5)
                        orb.Color = v.orb.color or Color3.fromRGB(255, 255, 255)
                        orb.Material = Enum.Material.Neon
                        orb.Shape = Enum.PartType.Ball
                        orb.CanCollide = false
                        orb.Anchored = false
                        orb.Massless = true
                        orb:SetAttribute(TAG, true)
                        
                        local orbOffset = v.orb.offset or CFrame.new(0, 1.5, 0)
                        orb.CFrame = part.CFrame * orbOffset
                        
                        local orbWeld = Instance.new("WeldConstraint")
                        orbWeld.Part0 = part
                        orbWeld.Part1 = orb
                        orbWeld.Parent = orb
                        
                        orb.Parent = character
                        print("[EquipVisual] Added orb")
                    end
                    
                    -- Blade on axe
                    if part and v.blade then
                        local blade = Instance.new("Part")
                        blade.Name = "Equip_Blade"
                        blade.Size = v.blade.size or Vector3.new(1, 1, 0.2)
                        blade.Color = v.blade.color or Color3.fromRGB(200, 200, 200)
                        blade.Material = Enum.Material.Metal
                        blade.CanCollide = false
                        blade.Anchored = false
                        blade.Massless = true
                        blade:SetAttribute(TAG, true)
                        
                        local bladeOffset = v.blade.offset or CFrame.new(0, 1, 0)
                        blade.CFrame = part.CFrame * bladeOffset
                        
                        local bladeWeld = Instance.new("WeldConstraint")
                        bladeWeld.Part0 = part
                        bladeWeld.Part1 = blade
                        bladeWeld.Parent = blade
                        
                        blade.Parent = character
                    end
                    
                    -- Accent on hat
                    if part and v.accent then
                        local accent = Instance.new("Part")
                        accent.Name = "Equip_Accent"
                        accent.Size = v.accent.size or Vector3.new(0.5, 0.2, 0.5)
                        accent.Color = v.accent.color or Color3.fromRGB(255, 255, 255)
                        accent.Material = Enum.Material.SmoothPlastic
                        accent.CanCollide = false
                        accent.Anchored = false
                        accent.Massless = true
                        accent:SetAttribute(TAG, true)
                        
                        local accentOffset = v.accent.offset or CFrame.new()
                        accent.CFrame = part.CFrame * accentOffset
                        
                        local accentWeld = Instance.new("WeldConstraint")
                        accentWeld.Part0 = part
                        accentWeld.Part1 = accent
                        accentWeld.Parent = accent
                        
                        accent.Parent = character
                    end
                    
                    -- Mirror (for shoes - apply to both legs)
                    if v.mirror and bodyPartName ~= "Right Leg" then
                        local rightLeg = character:FindFirstChild("Right Leg")
                        if rightLeg then
                            local mirrorPart = createVisualPart(character, "Right Leg", v, itemData)
                            if mirrorPart then
                                local flippedOffset = CFrame.new(
                                    -(v.offset and v.offset.X or 0),
                                    v.offset and v.offset.Y or 0,
                                    v.offset and v.offset.Z or 0
                                )
                                mirrorPart.CFrame = rightLeg.CFrame * flippedOffset
                            end
                        end
                    end
                    
                    print("[EquipVisual] Applied visual for " .. itemId)
                else
                    print("[EquipVisual] No visual data for " .. itemId)
                end
            else
                warn("[EquipVisual] Item not found in GameData: " .. tostring(itemId))
            end
        end
    end
end

return EquipmentVisuals
