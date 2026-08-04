--[[
    EquipmentVisuals.lua
    Shows equipped items on player character
    
    Supports R6 and R15.
    Uses MeshPart for proper 3D assets.
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local EquipmentVisuals = {}

local TAG = "EquipVisual"

-- R6 body parts
local R6_PARTS = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

-- Map slot attachTo to actual body part names
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

-- Get actual body part name
local function getBodyPartName(attachTo, rigType)
    local mapping = ATTACH_MAP[attachTo]
    if mapping then
        return mapping[rigType] or mapping["R6"]
    end
    return attachTo
end

-- Wait for body to load
local function waitForBody(character, timeout)
    timeout = timeout or 8
    local start = tick()
    
    local humanoid = character:WaitForChild("Humanoid", timeout)
    if not humanoid then return nil end
    
    local rigType = nil
    while not rigType and (tick() - start) < timeout do
        task.wait(0.1)
        rigType = getRigType(character)
    end
    
    return rigType or "R15"
end

-- Remove all visual parts
function EquipmentVisuals:ClearVisuals(character)
    if not character then return end
    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BasePart") and child:GetAttribute(TAG) then
            child:Destroy()
        end
    end
end

-- Create equipment part (MeshPart if meshId provided, else basic Part)
local function createEquipPart(character, bodyPartName, visualData, itemData)
    local bodyPart = character:FindFirstChild(bodyPartName)
    if not bodyPart then 
        warn("[EquipVisual] Body part not found: " .. bodyPartName)
        return nil 
    end
    
    local part
    local hasMesh = visualData.meshId and visualData.meshId ~= ""
    
    if hasMesh then
        -- Use MeshPart for proper 3D model
        part = Instance.new("MeshPart")
        part.MeshId = visualData.meshId
        if visualData.textureId and visualData.textureId ~= "" then
            part.TextureID = visualData.textureId
        end
        -- Scale mesh if needed (default 1)
        if visualData.scale then
            part.Size = part.Size * visualData.scale
        end
    else
        -- Fallback to basic Part
        part = Instance.new("Part")
        if visualData.shape == "Ball" then
            part.Shape = Enum.PartType.Ball
        elseif visualData.shape == "Cylinder" then
            part.Shape = Enum.PartType.Cylinder
        end
        -- Size only for basic Part
        part.Size = visualData.size or Vector3.new(1, 1, 1)
    end
    
    part.Name = "Equip_" .. (itemData.id or "unknown")
    part.Color = visualData.color or Color3.fromRGB(255, 255, 255)
    part.Material = visualData.material or Enum.Material.SmoothPlastic
    part.CanCollide = false
    part.Anchored = false
    part.Massless = true
    part:SetAttribute(TAG, true)
    
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

-- Apply equipment visuals
function EquipmentVisuals:ApplyVisuals(character, playerData)
    if not character then return end
    if not playerData then return end
    
    local rigType = waitForBody(character, 8)
    if not rigType then
        warn("[EquipVisual] Could not detect rig type!")
        return
    end
    
    print("[EquipVisual] Detected rig: " .. rigType)
    
    self:ClearVisuals(character)
    
    local equipment = playerData.equipment
    if not equipment then return end
    
    print("[EquipVisual] Applying visuals for " .. (character.Name or "unknown"))
    
    for slot, itemId in pairs(equipment) do
        if itemId then
            local itemData = GameData:GetItem(itemId)
            if itemData and itemData.visual then
                local v = itemData.visual
                
                local attachTo = v.attachTo or "Torso"
                local bodyPartName = getBodyPartName(attachTo, rigType)
                
                print("[EquipVisual] " .. itemId .. " -> " .. bodyPartName)
                
                -- FullBody costume
                if v.fullBody then
                    for _, partName in ipairs(R6_PARTS) do
                        local rName = getBodyPartName(partName, rigType)
                        local part = character:FindFirstChild(rName)
                        if part and part:IsA("BasePart") then
                            part.Color = v.color
                        end
                    end
                end
                
                -- Create main part
                local part = createEquipPart(character, bodyPartName, v, itemData)
                
                -- Orb on staff
                if part and v.orb then
                    local orb = createEquipPart(character, bodyPartName, {
                        meshId = v.orb.meshId,
                        textureId = v.orb.textureId,
                        color = v.orb.color or Color3.fromRGB(255, 255, 255),
                        size = v.orb.size or Vector3.new(0.5, 0.5, 0.5),
                        material = Enum.Material.Neon,
                        shape = "Ball",
                        offset = CFrame.new(),
                    }, {id = itemData.id .. "_orb"})
                    
                    if orb then
                        -- Reposition relative to main part
                        local orbOffset = v.orb.offset or CFrame.new(0, 1.5, 0)
                        orb.CFrame = part.CFrame * orbOffset
                        
                        -- Reweld to main part
                        orb:FindFirstChild("WeldConstraint"):Destroy()
                        local orbWeld = Instance.new("WeldConstraint")
                        orbWeld.Part0 = part
                        orbWeld.Part1 = orb
                        orbWeld.Parent = orb
                    end
                end
                
                -- Blade on axe
                if part and v.blade then
                    local blade = createEquipPart(character, bodyPartName, {
                        meshId = v.blade.meshId,
                        textureId = v.blade.textureId,
                        color = v.blade.color or Color3.fromRGB(200, 200, 200),
                        size = v.blade.size or Vector3.new(1, 1, 0.2),
                        material = Enum.Material.Metal,
                        offset = CFrame.new(),
                    }, {id = itemData.id .. "_blade"})
                    
                    if blade then
                        local bladeOffset = v.blade.offset or CFrame.new(0, 1, 0)
                        blade.CFrame = part.CFrame * bladeOffset
                        blade:FindFirstChild("WeldConstraint"):Destroy()
                        local bladeWeld = Instance.new("WeldConstraint")
                        bladeWeld.Part0 = part
                        bladeWeld.Part1 = blade
                        bladeWeld.Parent = blade
                    end
                end
                
                -- Accent on hat
                if part and v.accent then
                    local accent = createEquipPart(character, bodyPartName, {
                        meshId = v.accent.meshId,
                        color = v.accent.color or Color3.fromRGB(255, 255, 255),
                        size = v.accent.size or Vector3.new(0.5, 0.2, 0.5),
                        offset = CFrame.new(),
                    }, {id = itemData.id .. "_accent"})
                    
                    if accent then
                        local accentOffset = v.accent.offset or CFrame.new()
                        accent.CFrame = part.CFrame * accentOffset
                        accent:FindFirstChild("WeldConstraint"):Destroy()
                        local accentWeld = Instance.new("WeldConstraint")
                        accentWeld.Part0 = part
                        accentWeld.Part1 = accent
                        accentWeld.Parent = accent
                    end
                end
                
                -- Mirror (shoes)
                if v.mirror then
                    local mirrorAttach = (attachTo == "Left Leg") and "Right Leg" or "Left Leg"
                    local mirrorPartName = getBodyPartName(mirrorAttach, rigType)
                    local mirrorPart = createEquipPart(character, mirrorPartName, v, itemData)
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
