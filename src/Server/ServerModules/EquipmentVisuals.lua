--[[
    EquipmentVisuals.lua
    Shows equipped items on player character
    
    Supports R6 and R15.
    Uses Accessory system (cara Roblox handle equipment).
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local EquipmentVisuals = {}

local TAG = "EquipVisual"

-- Template storage (letakkan Accessory/MeshPart templates di ServerStorage)
local Templates = game.ServerStorage:FindFirstChild("EquipTemplates")

-- Load templates into memory on script start
local TemplateCache = {}
local function loadTemplates()
    if not Templates then return end
    for _, child in ipairs(Templates:GetChildren()) do
        TemplateCache[child.Name] = child
        print("[EquipVisual] Template loaded: " .. child.Name .. " (" .. child.ClassName .. ")")
        
        -- Jika Model, cari MeshPart di dalamnya
        if child:IsA("Model") then
            local mesh = child:FindFirstChildWhichIsA("MeshPart") or child:FindFirstChildWhichIsA("Part")
            if mesh then
                print("[EquipVisual]   -> MeshPart found in Model: " .. mesh.Name)
            end
        end
    end
end
loadTemplates()

-- R6 body parts
local R6_PARTS = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

-- Map slot attachTo to actual body part names
local ATTACH_MAP = {
    ["Head"]       = {R6 = "Head",        R15 = "Head"},
    ["Torso"]      = {R6 = "Torso",       R15 = "UpperTorso"},
    ["Right Arm"]  = {R6 = "Right Arm",   R15 = "RightHand"},
    ["Left Arm"]   = {R6 = "Left Arm",    R15 = "LeftHand"},
    ["Right Leg"]  = {R6 = "Right Leg",   R15 = "RightUpperLeg"},
    ["Left Leg"]   = {R6 = "Left Leg",    R15 = "LeftUpperLeg"},
}

-- Slot mana saja yang dianggap "tangan"
local HAND_SLOTS = { ["Right Arm"] = true, ["Left Arm"] = true }

-- Offset tambahan untuk tangan
local HAND_GRIP_OFFSET = {
    R6  = CFrame.new(0, -0.85, 0),
    R15 = CFrame.new(0, -0.15, 0),
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
    
    -- Remove custom accessories (marked with TAG)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, accessory in ipairs(character:GetChildren()) do
            if accessory:IsA("Accessory") and accessory:GetAttribute(TAG) then
                accessory:Destroy()
            end
        end
    end
    
    -- Remove any remaining tagged parts
    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BasePart") and child:GetAttribute(TAG) then
            child:Destroy()
        end
    end
end

-- Create Accessory from MeshPart template
local function createAccessoryFromTemplate(template, itemData, offset)
    local accessory = Instance.new("Accessory")
    accessory.Name = "Equip_" .. (itemData.id or "unknown")
    accessory:SetAttribute(TAG, true)
    
    -- Clone the handle from template
    local handle = template:Clone()
    handle.Name = "Handle"
    handle.CanCollide = false
    handle.Massless = true
    handle:SetAttribute(TAG, true)
    
    -- Apply offset if provided
    if offset then
        handle.CFrame = CFrame.new() * offset
    end
    
    handle.Parent = accessory
    return accessory
end

-- Create basic Accessory from Part data
local function createBasicAccessory(visualData, itemData, offset)
    local accessory = Instance.new("Accessory")
    accessory.Name = "Equip_" .. (itemData.id or "unknown")
    accessory:SetAttribute(TAG, true)
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    
    if visualData.shape == "Ball" then
        handle.Shape = Enum.PartType.Ball
    elseif visualData.shape == "Cylinder" then
        handle.Shape = Enum.PartType.Cylinder
    end
    
    handle.Size = visualData.size or Vector3.new(1, 1, 1)
    handle.Color = visualData.color or Color3.fromRGB(255, 255, 255)
    handle.Material = visualData.material or Enum.Material.SmoothPlastic
    handle.CanCollide = false
    handle.Massless = true
    handle:SetAttribute(TAG, true)
    
    if offset then
        handle.CFrame = CFrame.new() * offset
    end
    
    handle.Parent = accessory
    return accessory
end

-- Apply equipment visuals
function EquipmentVisuals:ApplyVisuals(character, playerData)
    if not character then return end
    if not playerData then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
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
                
                -- Shirt/Pants template (armor yang mengikuti bentuk badan)
                if v.shirtTemplate and v.shirtTemplate ~= "" then
                    local shirt = character:FindFirstChildOfClass("Shirt") or Instance.new("Shirt")
                    shirt.ShirtTemplate = v.shirtTemplate
                    shirt.Parent = character
                    print("[EquipVisual] Shirt applied: " .. v.shirtTemplate)
                end
                if v.pantsTemplate and v.pantsTemplate ~= "" then
                    local pants = character:FindFirstChildOfClass("Pants") or Instance.new("Pants")
                    pants.PantsTemplate = v.pantsTemplate
                    pants.Parent = character
                    print("[EquipVisual] Pants applied: " .. v.pantsTemplate)
                end
                
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
                
                -- Skip parts jika sudah ada clothing template
                local hasClothing = (v.shirtTemplate and v.shirtTemplate ~= "") or (v.pantsTemplate and v.pantsTemplate ~= "")
                
                if not hasClothing then
                    local attachTo = v.attachTo or "Torso"
                    local bodyPartName = getBodyPartName(attachTo, rigType)
                    local bodyPart = character:FindFirstChild(bodyPartName)
                    
                    if bodyPart then
                        -- Check for Accessory template
                        local templateName = v.template or itemId
                        local template = TemplateCache[templateName]
                        
                        if template and template:IsA("Accessory") then
                            -- Clone Accessory template
                            local acc = template:Clone()
                            acc:SetAttribute(TAG, true)
                            humanoid:AddAccessory(acc)
                            print("[EquipVisual] Accessory added: " .. templateName)
                            
                        elseif template and template:IsA("Model") then
                            -- Model: ambil semua MeshPart/Part di dalamnya, buat Accessory
                            local parts = template:GetDescendants()
                            local mainPart = nil
                            local allParts = {}
                            
                            for _, child in ipairs(parts) do
                                if child:IsA("MeshPart") or child:IsA("Part") then
                                    table.insert(allParts, child)
                                    if not mainPart then
                                        mainPart = child
                                    end
                                end
                            end
                            
                            if mainPart then
                                -- Buat Accessory dengan Handle = main part
                                local acc = Instance.new("Accessory")
                                acc.Name = "Equip_" .. itemId
                                acc:SetAttribute(TAG, true)
                                
                                -- Clone semua parts
                                local clonedParts = {}
                                for _, p in ipairs(allParts) do
                                    local clone = p:Clone()
                                    clone.CanCollide = false
                                    clone.Massless = true
                                    clone:SetAttribute(TAG, true)
                                    clonedParts[p.Name] = clone
                                end
                                
                                -- Handle = main part
                                local handle = clonedParts[mainPart.Name]
                                handle.Name = "Handle"
                                
                                -- Apply offset
                                local offset = v.offset or CFrame.new()
                                if HAND_SLOTS[attachTo] then
                                    offset = HAND_GRIP_OFFSET[rigType] * offset
                                end
                                handle.CFrame = CFrame.new() * offset
                                
                                -- Weld other parts to Handle
                                for name, p in pairs(clonedParts) do
                                    if name ~= mainPart.Name then
                                        -- Cari original part untuk dapat relative CFrame
                                        local origPart = template:FindFirstChild(name) or template:FindFirstChildWhichIsA("MeshPart", true)
                                        if origPart and origPart ~= mainPart then
                                            local relCF = mainPart.CFrame:ToObjectSpace(origPart.CFrame)
                                            p.CFrame = handle.CFrame * relCF
                                            local weld = Instance.new("WeldConstraint")
                                            weld.Part0 = handle
                                            weld.Part1 = p
                                            weld.Parent = p
                                        end
                                        p.Parent = acc
                                    end
                                end
                                
                                handle.Parent = acc
                                humanoid:AddAccessory(acc)
                                print("[EquipVisual] Model added: " .. templateName .. " (" .. #allParts .. " parts)")
                            else
                                warn("[EquipVisual] Model " .. templateName .. " has no MeshPart/Part!")
                            end
                            
                        elseif template and (template:IsA("MeshPart") or template:IsA("Part")) then
                            -- Clone MeshPart/Part template as Accessory
                            local offset = v.offset or CFrame.new()
                            if HAND_SLOTS[attachTo] then
                                offset = HAND_GRIP_OFFSET[rigType] * offset
                            end
                            local acc = createAccessoryFromTemplate(template, itemData, offset)
                            humanoid:AddAccessory(acc)
                            print("[EquipVisual] Template part added: " .. templateName)
                            
                        elseif v.parts then
                            -- Composite parts (built from basic shapes)
                            local originCFrame = bodyPart.CFrame
                            if HAND_SLOTS[attachTo] then
                                originCFrame = originCFrame * HAND_GRIP_OFFSET[rigType]
                            end
                            originCFrame = originCFrame * (v.offset or CFrame.new())
                            
                            for _, p in ipairs(v.parts) do
                                local part = Instance.new("Part")
                                if p.shape == "Ball" then
                                    part.Shape = Enum.PartType.Ball
                                elseif p.shape == "Cylinder" then
                                    part.Shape = Enum.PartType.Cylinder
                                end
                                
                                part.Name = "Equip_" .. (p.name or itemId)
                                part.Size = p.size or Vector3.new(1, 1, 1)
                                part.Color = p.color or Color3.fromRGB(255, 255, 255)
                                part.Material = p.material or Enum.Material.SmoothPlastic
                                part.CanCollide = false
                                part.Anchored = false
                                part.Massless = true
                                part:SetAttribute(TAG, true)
                                
                                -- Position relative to body
                                local pOffset = p.offset or CFrame.new()
                                if p.relativeTo then
                                    -- Find parent part
                                    for _, existing in ipairs(character:GetChildren()) do
                                        if existing:IsA("BasePart") and existing.Name == "Equip_" .. p.relativeTo then
                                            part.CFrame = existing.CFrame * pOffset
                                            break
                                        end
                                    end
                                else
                                    part.CFrame = originCFrame * pOffset
                                end
                                
                                -- Weld to body
                                local weld = Instance.new("WeldConstraint")
                                weld.Part0 = bodyPart
                                weld.Part1 = part
                                weld.Parent = part
                                
                                part.Parent = character
                            end
                            
                            -- Mirror for boots
                            if v.mirror then
                                local mirrorAttach = (attachTo == "Left Leg") and "Right Leg" or "Left Leg"
                                local mirrorPartName = getBodyPartName(mirrorAttach, rigType)
                                local mirrorBody = character:FindFirstChild(mirrorPartName)
                                if mirrorBody then
                                    for _, p in ipairs(v.parts) do
                                        local part = Instance.new("Part")
                                        if p.shape == "Ball" then
                                            part.Shape = Enum.PartType.Ball
                                        elseif p.shape == "Cylinder" then
                                            part.Shape = Enum.PartType.Cylinder
                                        end
                                        
                                        part.Name = "Equip_" .. (p.name or itemId) .. "_mirror"
                                        part.Size = p.size or Vector3.new(1, 1, 1)
                                        part.Color = p.color or Color3.fromRGB(255, 255, 255)
                                        part.Material = p.material or Enum.Material.SmoothPlastic
                                        part.CanCollide = false
                                        part.Anchored = false
                                        part.Massless = true
                                        part:SetAttribute(TAG, true)
                                        
                                        -- Mirror offset
                                        local pOffset = p.offset or CFrame.new()
                                        local mirrorOrigin = mirrorBody.CFrame * (v.offset or CFrame.new())
                                        part.CFrame = mirrorOrigin * pOffset
                                        
                                        local weld = Instance.new("WeldConstraint")
                                        weld.Part0 = mirrorBody
                                        weld.Part1 = part
                                        weld.Parent = part
                                        
                                        part.Parent = character
                                    end
                                end
                            end
                            
                            print("[EquipVisual] Composite created for " .. itemId)
                            
                        else
                            -- Single basic part (fallback)
                            local acc = createBasicAccessory(v, itemData, v.offset)
                            humanoid:AddAccessory(acc)
                            print("[EquipVisual] Basic part added: " .. itemId)
                        end
                    end
                end
                
                print("[EquipVisual] OK: " .. itemId)
            end
        end
    end
end

return EquipmentVisuals
