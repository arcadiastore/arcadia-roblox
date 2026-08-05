--[[
    EquipmentVisuals.lua
    Shows equipped items on player character
    
    Supports R6 and R15.
    Uses MeshPart for proper 3D assets.
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local EquipmentVisuals = {}

local TAG = "EquipVisual"

-- Template storage (letakkan MeshPart templates di ServerStorage)
local Templates = game.ServerStorage:FindFirstChild("EquipTemplates")

-- Load templates into memory on script start
local TemplateCache = {}
local function loadTemplates()
    if not Templates then return end
    for _, child in ipairs(Templates:GetChildren()) do
        if child:IsA("MeshPart") or child:IsA("Part") then
            TemplateCache[child.Name] = child
            print("[EquipVisual] Template loaded: " .. child.Name)
        end
    end
end
loadTemplates()

-- R6 body parts
local R6_PARTS = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

-- Map slot attachTo to actual body part names
-- PENTING: untuk weapon (Right Arm/Left Arm) kita attach ke part TANGAN
-- (RightHand/LeftHand) di R15, bukan ke lengan atas (dekat bahu). Ini yang
-- membuat senjata terlihat "dipegang" dengan benar, bukan menempel di bahu.
local ATTACH_MAP = {
    ["Head"]       = {R6 = "Head",        R15 = "Head"},
    ["Torso"]      = {R6 = "Torso",       R15 = "UpperTorso"},
    ["Right Arm"]  = {R6 = "Right Arm",   R15 = "RightHand"},
    ["Left Arm"]   = {R6 = "Left Arm",    R15 = "LeftHand"},
    ["Right Leg"]  = {R6 = "Right Leg",   R15 = "RightUpperLeg"},
    ["Left Leg"]   = {R6 = "Left Leg",    R15 = "LeftUpperLeg"},
}

-- Slot mana saja yang dianggap "tangan" (perlu koreksi titik genggam)
local HAND_SLOTS = { ["Right Arm"] = true, ["Left Arm"] = true }

-- Offset tambahan dari titik tengah part ke titik genggam tangan yang wajar.
-- R6: "Right Arm"/"Left Arm" adalah 1 part utuh dari bahu sampai tangan
--     (tinggi 2 stud), jadi titik genggam ada di dekat UJUNG BAWAH part.
-- R15: "RightHand"/"LeftHand" sudah berupa part kecil di tangan, jadi cukup
--     sedikit koreksi ke arah jari (bukan pergelangan).
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
    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BasePart") and child:GetAttribute(TAG) then
            child:Destroy()
        end
    end
end

-- Create equipment part (MeshPart if meshId provided, else basic Part)
-- extraOffset = koreksi titik genggam tangan (lihat HAND_GRIP_OFFSET), sudah
-- termasuk ke dalam origin sebelum offset spesifik item diterapkan.
local function createEquipPart(character, bodyPartName, visualData, itemData, extraOffset)
    local bodyPart = character:FindFirstChild(bodyPartName)
    if not bodyPart then 
        warn("[EquipVisual] Body part not found: " .. bodyPartName)
        return nil 
    end
    
    local part
    local itemId = itemData.id or "unknown"
    local templateName = visualData.template  -- Nama template di ServerStorage
    
    -- PRIORITAS: Clone dari template (paling reliable)
    if templateName and TemplateCache[templateName] then
        part = TemplateCache[templateName]:Clone()
        print("[EquipVisual] Cloned template: " .. templateName)
    elseif TemplateCache[itemId] then
        -- Coba pakai nama item sebagai template name
        part = TemplateCache[itemId]:Clone()
        print("[EquipVisual] Cloned template by item ID: " .. itemId)
    else
        -- Fallback: basic Part (tanpa mesh)
        part = Instance.new("Part")
        if visualData.shape == "Ball" then
            part.Shape = Enum.PartType.Ball
        elseif visualData.shape == "Cylinder" then
            part.Shape = Enum.PartType.Cylinder
        end
        part.Size = visualData.size or Vector3.new(1, 1, 1)
        -- Hanya warn jika benar-benar tidak ada visual data
        if not visualData.shape and not visualData.size then
            warn("[EquipVisual] No visual data for " .. itemId .. ". Tambahkan 'parts' atau 'shape/size' di visual data.")
        end
    end
    
    part.Name = "Equip_" .. itemId
    part.Color = visualData.color or Color3.fromRGB(255, 255, 255)
    part.Material = visualData.material or Enum.Material.SmoothPlastic
    part.CanCollide = false
    part.Anchored = false
    part.Massless = true
    part:SetAttribute(TAG, true)
    
    -- Scale if needed
    if visualData.scale then
        part.Size = part.Size * visualData.scale
    end
    
    -- Attach to body part (origin = titik genggam tangan, lalu offset item)
    local origin = bodyPart.CFrame * (extraOffset or CFrame.new())
    local offset = visualData.offset or CFrame.new()
    part.CFrame = origin * offset
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = bodyPart
    weld.Part1 = part
    weld.Parent = part
    
    part.Parent = character
    
    return part
end

-- Buat 1 sub-part untuk composite weapon (Block/Cylinder/Ball/Wedge/CornerWedge)
-- Wedge/CornerWedge dipakai supaya bilah senjata TAPERED (meruncing) alih-alih
-- kotak polos, tanpa perlu mesh custom.
local function createShapedSubPart(shape, size, color, material)
    local part
    if shape == "Wedge" then
        part = Instance.new("WedgePart")
    elseif shape == "CornerWedge" then
        part = Instance.new("CornerWedgePart")
    else
        part = Instance.new("Part")
        if shape == "Ball" then
            part.Shape = Enum.PartType.Ball
        elseif shape == "Cylinder" then
            part.Shape = Enum.PartType.Cylinder
        end
    end
    part.Size = size or Vector3.new(0.2, 0.2, 0.2)
    part.Color = color or Color3.fromRGB(255, 255, 255)
    part.Material = material or Enum.Material.SmoothPlastic
    part.CanCollide = false
    part.Anchored = false
    part.Massless = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    return part
end

-- Bangun 1 item equipment (senjata, armor, aksesoris, wings, dll) dari
-- beberapa sub-part (visualData.parts) supaya berbentuk nyata, alih-alih
-- 1 kotak polos. Dipakai untuk SEMUA kategori equipment, bukan cuma senjata.
-- Setiap entry di `parts` boleh punya `relativeTo = "NamaPartLain"` supaya
-- posisinya dihitung relatif terhadap part lain yang sudah dibuat (misal
-- bilah relatif terhadap gagang), sehingga mudah disusun jadi 1 bentuk utuh.
local function buildCompositeVisual(character, bodyPart, originCFrame, itemData)
    local v = itemData.visual
    local partsSpec = v.parts
    if not partsSpec or #partsSpec == 0 then return nil end

    local built = {}
    local primary = nil

    for i, spec in ipairs(partsSpec) do
        local part = createShapedSubPart(
            spec.shape,
            spec.size,
            spec.color or v.color,
            spec.material or v.material
        )
        local subName = spec.name or ("part" .. i)
        part.Name = "Equip_" .. itemData.id .. "_" .. subName
        part:SetAttribute(TAG, true)

        local baseCFrame = originCFrame
        if spec.relativeTo and built[spec.relativeTo] then
            baseCFrame = built[spec.relativeTo]
        end

        local worldCFrame = baseCFrame * (spec.offset or CFrame.new())
        part.CFrame = worldCFrame
        part.Parent = character

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = bodyPart
        weld.Part1 = part
        weld.Parent = part

        built[subName] = worldCFrame
        if not primary then primary = part end
    end

    return primary
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
                
                -- Shirt/Pants template (armor yang mengikuti bentuk badan)
                -- Jika ada shirt/pants template, apply dan skip parts
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
                
                -- FullBody costume (tetap ganti warna body parts)
                if v.fullBody then
                    for _, partName in ipairs(R6_PARTS) do
                        local rName = getBodyPartName(partName, rigType)
                        local part = character:FindFirstChild(rName)
                        if part and part:IsA("BasePart") then
                            part.Color = v.color
                        end
                    end
                end
                
                -- SKIP parts creation jika sudah ada shirt/pants template
                local hasClothing = (v.shirtTemplate and v.shirtTemplate ~= "") or (v.pantsTemplate and v.pantsTemplate ~= "")
                
                if not hasClothing then
                    -- Koreksi ke titik genggam tangan (hanya untuk slot tangan)
                    local extraOffset = HAND_SLOTS[attachTo] and HAND_GRIP_OFFSET[rigType] or nil
                    
                    -- Create main part: kalau item punya "parts" (bentuk composite,
                    -- misal pedang: gagang+guard+bilah+ujung, atau helm: dome+brim),
                    -- pakai itu supaya berbentuk nyata. Kalau tidak, fallback ke
                    -- template/kotak lama.
                    local part
                    if v.parts then
                        local bodyPart = character:FindFirstChild(bodyPartName)
                        if bodyPart then
                            local originCFrame = bodyPart.CFrame * (extraOffset or CFrame.new()) * (v.offset or CFrame.new())
                            part = buildCompositeVisual(character, bodyPart, originCFrame, itemData)
                        end
                    else
                        part = createEquipPart(character, bodyPartName, v, itemData, extraOffset)
                    end
                    
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
                
                -- Mirror (shoes, atau item lain yang perlu di 2 sisi)
                if v.mirror then
                    local mirrorAttach = (attachTo == "Left Leg") and "Right Leg" or "Left Leg"
                    local mirrorPartName = getBodyPartName(mirrorAttach, rigType)
                    local mirrorBody = character:FindFirstChild(mirrorPartName)
                    if mirrorBody then
                        if v.parts then
                            -- Composite (misal boot dari sole+cuff+toe): bangun
                            -- ulang set part yang sama di kaki sebelah. Geometrinya
                            -- sudah simetris kiri-kanan (tidak ada offset X lateral
                            -- di dalam `parts`), jadi tidak perlu dibalik manual.
                            local mirrorOrigin = mirrorBody.CFrame * (v.offset or CFrame.new())
                            buildCompositeVisual(character, mirrorBody, mirrorOrigin, itemData)
                        else
                            local mirrorPart = createEquipPart(character, mirrorPartName, v, itemData)
                            if mirrorPart then
                                local flippedOffset = CFrame.new(
                                    -(v.offset and v.offset.X or 0),
                                    v.offset and v.offset.Y or 0,
                                    v.offset and v.offset.Z or 0
                                )
                                mirrorPart.CFrame = mirrorBody.CFrame * flippedOffset
                            end
                        end
                    end
                end
                
                print("[EquipVisual] OK: " .. itemId)
                end  -- end if not hasClothing
            end
        end
    end
end

return EquipmentVisuals
