--[[
    EquipmentVisuals.lua
    Shows equipped items on player character
    
    PISAHKAN:
    - Weapon → Weld langsung ke tangan
    - Armor → Shirt/Pants template
    - Hat/Wings/Accessories → Accessory system
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local EquipmentVisuals = {}

local TAG = "EquipVisual"

-- Template storage
local Templates = game.ServerStorage:FindFirstChild("EquipTemplates")
local TemplateCache = {}
local function loadTemplates()
    if not Templates then return end
    for _, child in ipairs(Templates:GetChildren()) do
        TemplateCache[child.Name] = child
        print("[EquipVisual] Template loaded: " .. child.Name .. " (" .. child.ClassName .. ")")
    end
end
loadTemplates()

-- R6 body parts
local R6_PARTS = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

-- Map slot ke body part
local SLOT_TO_PART = {
    ["weapon1h"] = "Right Arm",  -- R6: Right Arm, R15: RightUpperArm (bukan RightHand)
    ["weapon2h"] = "Right Arm",
    ["hat"]      = "Head",
    ["tshirt"]   = "Torso",
    ["pants"]    = "Torso",
    ["shoes"]    = "Right Leg",
    ["wings"]    = "Torso",
    ["necklace"] = "Torso",
    ["ring"]     = "Right Arm",
    ["costume"]  = "Torso",
}

-- R15 mapping
local R15_MAP = {
    ["Head"]      = "Head",
    ["Torso"]     = "UpperTorso",
    ["Right Arm"] = "RightUpperArm",  -- Pakai lengan atas, bukan tangan
    ["Left Arm"]  = "LeftUpperArm",
    ["Right Leg"] = "RightUpperLeg",
    ["Left Leg"]  = "LeftUpperLeg",
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

-- Get R15 part name
local function getPartName(slot, rigType)
    local r6Name = SLOT_TO_PART[slot] or "Torso"
    if rigType == "R15" then
        local r15Name = R15_MAP[r6Name] or r6Name
        print("[EquipVisual] getPartName: " .. slot .. " -> " .. r6Name .. " -> " .. r15Name)
        return r15Name
    end
    return r6Name
end

-- Wait for body
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

-- Cleanup
function EquipmentVisuals:ClearVisuals(character)
    if not character then return end
    -- Remove tagged accessories
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") and child:GetAttribute(TAG) then
            child:Destroy()
        end
    end
    -- Remove tagged parts
    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BasePart") and child:GetAttribute(TAG) then
            child:Destroy()
        end
    end
    -- Remove shirt/pants if they were from equipment
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Shirt") and child:GetAttribute(TAG) then
            child:Destroy()
        end
        if child:IsA("Pants") and child:GetAttribute(TAG) then
            child:Destroy()
        end
    end
end

-- WEAPON: Weld langsung ke tangan
local function applyWeapon(character, itemId, v, bodyPart, rigType)
    local templateName = v.template or itemId
    local template = TemplateCache[templateName]
    
    if not template then
        warn("[EquipVisual] Template not found for weapon: " .. templateName)
        return
    end
    
    local offset = v.offset or CFrame.new(1.5, 0, 0)
    local scale = v.scale or 1
    
    -- Kumpulkan semua parts dari template
    local allParts = {}
    local mainPart = nil
    
    if template:IsA("MeshPart") or template:IsA("Part") then
        allParts = {template}
        mainPart = template
    elseif template:IsA("Model") then
        for _, child in ipairs(template:GetDescendants()) do
            if child:IsA("MeshPart") or child:IsA("Part") then
                table.insert(allParts, child)
                if not mainPart then mainPart = child end
            end
        end
    elseif template:IsA("Accessory") then
        local handle = template:FindFirstChild("Handle")
        if handle then
            allParts = {handle}
            mainPart = handle
        end
    end
    
    if #allParts == 0 then
        warn("[EquipVisual] No parts found in template: " .. templateName)
        return
    end
    
    print("[EquipVisual] Weapon " .. templateName .. ": " .. #allParts .. " parts")
    
    -- Hitung offset relatif antar parts (dari posisi template asli)
    -- mainPart jadi anchor, parts lain relatif terhadap mainPart
    local mainCF = mainPart.CFrame
    
    -- Clone dan weld SEMUA parts
    local clonedMain = nil
    for i, origPart in ipairs(allParts) do
        local clone = origPart:Clone()
        clone.Name = "Equip_" .. itemId .. (i > 1 and ("_" .. i) or "")
        clone.CanCollide = false
        clone.Massless = true
        clone.Anchored = false
        clone.Transparency = 0
        clone:SetAttribute(TAG, true)
        
        -- Scale
        if scale ~= 1 then
            clone.Size = clone.Size * scale
        end
        
        -- Hitung posisi: offset relatif dari mainPart + offset user
        local relCF = mainCF:ToObjectSpace(origPart.CFrame)
        if scale ~= 1 then
            relCF = CFrame.new(relCF.Position * scale) * (relCF - relCF.Position)
        end
        
        clone.CFrame = bodyPart.CFrame * offset * relCF
        
        -- Weld ke body part
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = bodyPart
        weld.Part1 = clone
        weld.Parent = clone
        
        clone.Parent = character
        
        if i == 1 then
            clonedMain = clone
        end
    end
    
    print("[EquipVisual] Weapon welded: " .. itemId .. " (" .. #allParts .. " parts) -> " .. bodyPart.Name)
end

-- ARMOR: Shirt/Pants template
local function applyArmor(character, itemId, v)
    if v.shirtTemplate and v.shirtTemplate ~= "" then
        local shirt = character:FindFirstChildOfClass("Shirt")
        if not shirt then
            shirt = Instance.new("Shirt")
            shirt:SetAttribute(TAG, true)
        end
        shirt.ShirtTemplate = v.shirtTemplate
        shirt.Parent = character
        print("[EquipVisual] Shirt applied: " .. itemId)
    end
    if v.pantsTemplate and v.pantsTemplate ~= "" then
        local pants = character:FindFirstChildOfClass("Pants")
        if not pants then
            pants = Instance.new("Pants")
            pants:SetAttribute(TAG, true)
        end
        pants.PantsTemplate = v.pantsTemplate
        pants.Parent = character
        print("[EquipVisual] Pants applied: " .. itemId)
    end
end

-- HAT/WINGS/ACCESSORY: Accessory system
local function applyAccessory(character, itemId, v, bodyPart, humanoid, slot)
    local templateName = v.template or itemId
    local template = TemplateCache[templateName]
    
    -- Tentukan AccessoryType berdasarkan slot
    local accType = Enum.AccessoryType.Hat
    local attName = "HatAttachment"
    
    if slot == "hat" then
        accType = Enum.AccessoryType.Hat
        attName = "HatAttachment"
    elseif slot == "wings" then
        accType = Enum.AccessoryType.Back
        attName = "BodyBackAttachment"
    elseif slot == "necklace" then
        accType = Enum.AccessoryType.Neck
        attName = "NeckAttachment"
    elseif slot == "shoes" then
        accType = Enum.AccessoryType.LeftFront
        attName = "LeftFootAttachment"
    else
        accType = Enum.AccessoryType.Front
        attName = "BodyFrontAttachment"
    end
    
    local function makeAccessoryFromParts(allParts, mainPart)
        local acc = Instance.new("Accessory")
        acc.Name = "Equip_" .. itemId
        acc.AccessoryType = accType
        acc:SetAttribute(TAG, true)
        
        local mainCF = mainPart.CFrame
        local handle = nil
        
        for i, origPart in ipairs(allParts) do
            local clone = origPart:Clone()
            clone.Name = (i == 1) and "Handle" or ("Equip_" .. itemId .. "_" .. i)
            clone.CanCollide = false
            clone.Massless = true
            clone.Transparency = 0
            clone:SetAttribute(TAG, true)
            
            if i == 1 then
                -- Main part = Handle
                local att = Instance.new("Attachment")
                att.Name = attName
                att.Parent = clone
                handle = clone
            else
                -- Weld other parts to Handle
                local relCF = mainCF:ToObjectSpace(origPart.CFrame)
                clone.CFrame = handle.CFrame * relCF
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = handle
                weld.Part1 = clone
                weld.Parent = clone
            end
            
            clone.Parent = acc
        end
        
        humanoid:AddAccessory(acc)
        print("[EquipVisual] Accessory added: " .. itemId .. " (" .. #allParts .. " parts, " .. accType.Name .. ")")
    end
    
    if template then
        if template:IsA("Accessory") then
            local acc = template:Clone()
            acc:SetAttribute(TAG, true)
            acc.AccessoryType = accType
            humanoid:AddAccessory(acc)
            print("[EquipVisual] Accessory cloned: " .. itemId)
            
        elseif template:IsA("MeshPart") or template:IsA("Part") then
            makeAccessoryFromParts({template}, template)
            
        elseif template:IsA("Model") then
            local allParts = {}
            local mainPart = nil
            for _, child in ipairs(template:GetDescendants()) do
                if child:IsA("MeshPart") or child:IsA("Part") then
                    table.insert(allParts, child)
                    if not mainPart then mainPart = child end
                end
            end
            if #allParts > 0 then
                makeAccessoryFromParts(allParts, mainPart)
            else
                warn("[EquipVisual] No parts in Model: " .. templateName)
            end
        end
    elseif v.parts then
        -- Composite parts (basic shapes)
        local originCFrame = bodyPart.CFrame * (v.offset or CFrame.new())
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
            
            local pOffset = p.offset or CFrame.new()
            part.CFrame = originCFrame * pOffset
            
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = bodyPart
            weld.Part1 = part
            weld.Parent = part
            
            part.Parent = character
        end
        print("[EquipVisual] Composite created: " .. itemId)
    end
end

-- COSTUME: FullBody color change
local function applyCostume(character, itemId, v, rigType)
    if v.fullBody then
        for _, partName in ipairs(R6_PARTS) do
            local rName = partName
            if rigType == "R15" then
                rName = R15_MAP[partName] or partName
            end
            local part = character:FindFirstChild(rName)
            if part and part:IsA("BasePart") then
                part.Color = v.color
            end
        end
    end
    -- Juga buat composite parts jika ada
    if v.parts then
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then
            local originCFrame = torso.CFrame * (v.offset or CFrame.new())
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
                
                local pOffset = p.offset or CFrame.new()
                part.CFrame = originCFrame * pOffset
                
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = torso
                weld.Part1 = part
                weld.Parent = part
                
                part.Parent = character
            end
        end
    end
end

-- MAIN: Apply all visuals
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
                local bodyPartName = getPartName(slot, rigType)
                local bodyPart = character:FindFirstChild(bodyPartName)
                
                -- Tentukan tipe item
                local isWeapon = (slot == "weapon1h" or slot == "weapon2h")
                local isArmor = (slot == "tshirt" or slot == "pants")
                local isCostume = (slot == "costume")
                local isHat = (slot == "hat")
                local isWings = (slot == "wings")
                local isAccessory = (slot == "necklace" or slot == "ring" or slot == "shoes")
                
                if isWeapon then
                    -- WEAPON: Weld langsung ke tangan
                    if bodyPart then
                        applyWeapon(character, itemId, v, bodyPart, rigType)
                    end
                    
                elseif isArmor then
                    -- ARMOR: Shirt/Pants template
                    applyArmor(character, itemId, v)
                    
                elseif isCostume then
                    -- COSTUME: FullBody + parts
                    applyCostume(character, itemId, v, rigType)
                    
                else
                    -- HAT/WINGS/ACCESSORIES: Accessory system
                    if bodyPart then
                        applyAccessory(character, itemId, v, bodyPart, humanoid, slot)
                    end
                end
                
                -- Mirror untuk shoes
                if v.mirror and bodyPart then
                    local mirrorSlot = (slot == "shoes") and "shoes" or slot
                    local mirrorPartName = getPartName(mirrorSlot, rigType)
                    if mirrorPartName ~= bodyPartName then
                        local mirrorBody = character:FindFirstChild(mirrorPartName)
                        if mirrorBody then
                            local templateName = v.template or itemId
                            local template = TemplateCache[templateName]
                            if template then
                                local mesh = template:IsA("MeshPart") and template or template:FindFirstChildWhichIsA("MeshPart")
                                if mesh then
                                    local mirrorPart = mesh:Clone()
                                    mirrorPart.Name = "Equip_" .. itemId .. "_mirror"
                                    mirrorPart.CanCollide = false
                                    mirrorPart.Massless = true
                                    mirrorPart:SetAttribute(TAG, true)
                                    mirrorPart.CFrame = mirrorBody.CFrame * (v.offset or CFrame.new())
                                    local weld = Instance.new("WeldConstraint")
                                    weld.Part0 = mirrorBody
                                    weld.Part1 = mirrorPart
                                    weld.Parent = mirrorPart
                                    mirrorPart.Parent = character
                                end
                            end
                        end
                    end
                end
                
                print("[EquipVisual] OK: " .. itemId)
            end
        end
    end
end

return EquipmentVisuals
