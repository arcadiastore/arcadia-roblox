--[[
    EquipmentVisuals.lua
    Shows equipped items on player character
    
    Supports both R6 and R15 body types.
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local EquipmentVisuals = {}

local TAG = "EquipVisual"

-- R6 body parts
local R6_PARTS = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

-- R15 body parts
local R15_PARTS = {"Head", "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg"}

-- Map slot attachTo to actual body part names (R6 and R15)
local ATTACH_MAP = {
    ["Head"]       = {R6 = "Head",        R15 = "Head"},
    ["Torso"]      = {R6 = "Torso",       R15 = "UpperTorso"},
    ["Right Arm"]  = {R6 = "Right Arm",   R15 = "RightUpperArm"},
    ["Left Arm"]   = {R6 = "Left Arm",    R15 = "LeftUpperArm"},
    ["Right Leg"]  = {R6 = "Right Leg",   R15 = "RightUpperLeg"},
    ["Left Leg"]   = {R6 = "Left Leg",    R15 = "LeftUpperLeg"},
}

-- Detect rig type
local function getRigType(character)
    if character:FindFirstChild("Torso") and character:FindFirstChild("Right Arm") then
        return "R6"
    elseif character:FindFirstChild("UpperTorso") then
        return "R15"
    end
    return nil
end

-- Get actual body part name for current rig
local function getBodyPartName(attachTo, rigType)
    local mapping = ATTACH_MAP[attachTo]
    if mapping then
        return mapping[rigType] or mapping["R6"]
    end
    return attachTo
end

-- Wait for character body to load
local function waitForBody(character, timeout)
    timeout = timeout or 8
    local start = tick()
    
    local humanoid = character:WaitForChild("Humanoid", timeout)
    if not humanoid then return nil end
    
    -- Wait until we can detect rig type
    local rigType = nil
    while not rigType and (tick() - start) < timeout do
        task.wait(0.1)
        rigType = getRigType(character)
    end
    
    if not rigType then
        -- Try waiting for HumanoidRootPart and check RigType
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Default to R15 if we can't detect
            warn("[EquipVisual] Cannot detect rig type, defaulting to R15")
            return "R15"
        end
        return nil
    end
    
    return rigType
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
    
    if visualData.shape == "Ball" then
        part.Shape = Enum.PartType.Ball
    elseif visualData.shape == "Cylinder" then
        part.Shape = Enum.PartType.Cylinder
    end
    
    local offset = visualData.offset or CFrame.new()
    part.CFrame = bodyPart.CFrame * offset
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = bodyPart
    weld.Part1 = part
    weld.Parent = part
    
    part.Parent = character
    
    return part
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
    
    -- Detect rig type
    local rigType = waitForBody(character, 8)
    if not rigType then
        warn("[EquipVisual] Could not detect rig type! Aborting.")
        return
    end
    
    print("[EquipVisual] Detected rig: " .. rigType)
    
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
            if itemData and itemData.visual then
                local v = itemData.visual
                
                -- Get correct body part name for this rig
                local attachTo = v.attachTo or "Torso"
                local bodyPartName = getBodyPartName(attachTo, rigType)
                
                print("[EquipVisual] " .. itemId .. " -> " .. attachTo .. " -> " .. bodyPartName)
                
                -- Special: fullBody costume
                if v.fullBody then
                    local parts = (rigType == "R6") and R6_PARTS or R15_PARTS
                    for _, partName in ipairs(parts) do
                        local part = character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            part.Color = v.color
                        end
                    end
                end
                
                -- Normal attachment
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
                if v.mirror then
                    local mirrorAttach = (attachTo == "Left Leg") and "Right Leg" or "Left Leg"
                    local mirrorPartName = getBodyPartName(mirrorAttach, rigType)
                    local mirrorPart = createVisualPart(character, mirrorPartName, v, itemData)
                    if mirrorPart then
                        local flippedOffset = CFrame.new(
                            -(v.offset and v.offset.X or 0),
                            v.offset and v.offset.Y or 0,
                            v.offset and v.offset.Z or 0
                        )
                        local mirrorBody = character:FindFirstChild(mirrorPartName)
                        if mirrorBody then
                            mirrorPart.CFrame = mirrorBody.CFrame * flippedOffset
                        end
                    end
                end
                
                print("[EquipVisual] OK: " .. itemId)
            end
        end
    end
end

return EquipmentVisuals
