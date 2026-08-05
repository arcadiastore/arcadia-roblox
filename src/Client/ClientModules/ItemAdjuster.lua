--[[
    ItemAdjuster.lua
    Client-side drag-to-adjust equipment position
    
    Fitur:
    - Klik kiri + drag = geser posisi (X, Y, Z)
    - Klik kanan + drag = putar rotasi
    - Scroll = geser Z (maju/mundur)
    - R = reset ke default
    - C = copy CFrame ke clipboard
    - Tab = switch antar equipment yang di-equip
]]

local ItemAdjuster = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- State
local isActive = false
local currentSlot = "weapon1h"  -- Current equipment slot being adjusted
local targetModel = nil         -- Model/part being dragged
local targetWeld = nil          -- Weld to adjust
local isDragging = false
local isRotating = false
local lastMousePos = nil

-- Sensitivity
local DRAG_SPEED = 0.01       -- Studs per pixel
local ROTATE_SPEED = 0.5      -- Degrees per pixel
local SCROLL_SPEED = 0.1      -- Studs per scroll

-- GUI
local gui = nil
local statusLabel = nil
local coordLabel = nil

-- Available slots to adjust
local ADJUSTABLE_SLOTS = {
    "weapon1h", "weapon2h", "hat", "wings", "shoes", "necklace", "costume"
}

function ItemAdjuster:Create(parentGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "ItemAdjusterGui"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = parentGui
    
    -- Status panel (bottom center)
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 400, 0, 120)
    panel.Position = UDim2.new(0.5, -200, 1, -130)
    panel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    panel.BackgroundTransparency = 0.1
    panel.BorderSizePixel = 0
    panel.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 25)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "ITEM ADJUSTER"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel
    
    -- Status
    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Slot: weapon1h | Drag to move, Right-drag to rotate"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = panel
    
    -- Coordinates
    coordLabel = Instance.new("TextLabel")
    coordLabel.Size = UDim2.new(1, -10, 0, 20)
    coordLabel.Position = UDim2.new(0, 5, 0, 50)
    coordLabel.BackgroundTransparency = 1
    coordLabel.Text = "Offset: 0, 0, 0 | Rotation: 0, 0, 0"
    coordLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    coordLabel.TextSize = 13
    coordLabel.Font = Enum.Font.Code
    coordLabel.TextXAlignment = Enum.TextXAlignment.Left
    coordLabel.Parent = panel
    
    -- Controls help
    local help = Instance.new("TextLabel")
    help.Size = UDim2.new(1, -10, 0, 40)
    help.Position = UDim2.new(0, 5, 0, 75)
    help.BackgroundTransparency = 1
    help.Text = "LMB Drag=Move | RMB Drag=Rotate | Scroll=Z | Tab=Switch Slot | C=Copy | R=Reset | T=Done"
    help.TextColor3 = Color3.fromRGB(150, 150, 180)
    help.TextSize = 11
    help.Font = Enum.Font.Gotham
    help.TextWrapped = true
    help.TextXAlignment = Enum.TextXAlignment.Left
    help.Parent = panel
    
    print("[ItemAdjuster] Created! Press T to toggle.")
end

function ItemAdjuster:Toggle()
    if isActive then
        self:Deactivate()
    else
        self:Activate()
    end
end

function ItemAdjuster:Activate()
    if not gui then
        warn("[ItemAdjuster] Not initialized!")
        return
    end
    
    -- Find equipped items
    local character = player.Character
    if not character then
        warn("[ItemAdjuster] No character!")
        return
    end
    
    -- Find the first equipped visual
    local found = self:FindEquippedItem(currentSlot)
    if not found then
        -- Try other slots
        for _, slot in ipairs(ADJUSTABLE_SLOTS) do
            found = self:FindEquippedItem(slot)
            if found then
                currentSlot = slot
                break
            end
        end
    end
    
    if not found then
        warn("[ItemAdjuster] No equipped items found!")
        return
    end
    
    isActive = true
    gui.Enabled = true
    self:SelectTarget(found)
    
    -- Highlight
    self:SetHighlight(true)
    
    print("[ItemAdjuster] Active! Slot: " .. currentSlot)
end

function ItemAdjuster:Deactivate()
    isActive = false
    isDragging = false
    isRotating = false
    
    if gui then
        gui.Enabled = false
    end
    
    self:SetHighlight(false)
    print("[ItemAdjuster] Deactivated.")
end

function ItemAdjuster:FindEquippedItem(slot)
    local character = player.Character
    if not character then return nil end
    
    -- Look for equipped visuals by naming pattern "Equip_"
    local found = {}
    for _, child in ipairs(character:GetDescendants()) do
        if child.Name and child.Name:match("^Equip_") then
            table.insert(found, child)
        end
    end
    
    -- Also check Accessory objects
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") then
            table.insert(found, child)
        end
    end
    
    -- Return first found (or nil)
    if #found > 0 then
        print("[ItemAdjuster] Found " .. #found .. " equipped visuals:")
        for i, item in ipairs(found) do
            print("  " .. i .. ". " .. item.Name .. " (" .. item.ClassName .. ")")
        end
        return found[1]
    end
    
    return nil
end

function ItemAdjuster:SelectTarget(model)
    targetModel = model
    targetWeld = nil
    
    -- Find the weld that attaches this to character
    -- Look for EquipWeld_ first (our custom welds)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("Weld") and desc.Name:match("^EquipWeld_") then
            targetWeld = desc
            break
        end
    end
    
    -- Fallback: any Weld
    if not targetWeld then
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("Weld") then
                targetWeld = desc
                break
            end
        end
    end
    
    -- Also check parent if model is a part
    if not targetWeld and model:IsA("BasePart") then
        for _, desc in ipairs(model:GetChildren()) do
            if desc:IsA("Weld") then
                targetWeld = desc
                break
            end
        end
    end
    
    self:UpdateCoordDisplay()
    
    if statusLabel then
        statusLabel.Text = "Slot: " .. currentSlot .. " | Model: " .. model.Name .. " | Weld: " .. (targetWeld and targetWeld.Name or "NONE")
    end
    
    if targetWeld then
        print("[ItemAdjuster] Found weld: " .. targetWeld.Name .. " C0: " .. tostring(targetWeld.C0))
    else
        warn("[ItemAdjuster] No weld found on " .. model.Name)
    end
end

function ItemAdjuster:SwitchSlot()
    local currentIndex = 1
    for i, slot in ipairs(ADJUSTABLE_SLOTS) do
        if slot == currentSlot then
            currentIndex = i
            break
        end
    end
    
    -- Find next slot with equipped item
    for i = 1, #ADJUSTABLE_SLOTS do
        local nextIndex = ((currentIndex - 1 + i) % #ADJUSTABLE_SLOTS) + 1
        local nextSlot = ADJUSTABLE_SLOTS[nextIndex]
        local found = self:FindEquippedItem(nextSlot)
        if found then
            currentSlot = nextSlot
            self:SelectTarget(found)
            self:SetHighlight(true)
            print("[ItemAdjuster] Switched to slot: " .. currentSlot)
            return
        end
    end
    
    print("[ItemAdjuster] No other equipped items found!")
end

function ItemAdjuster:SetHighlight(enabled)
    if not targetModel then return end
    
    -- Remove existing highlight
    local existing = targetModel:FindFirstChild("AdjustHighlight")
    if existing then
        existing:Destroy()
    end
    
    if enabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "AdjustHighlight"
        highlight.FillColor = Color3.fromRGB(255, 215, 0)
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Adornee = targetModel
        highlight.Parent = targetModel
    end
end

function ItemAdjuster:UpdateCoordDisplay()
    if not targetModel or not coordLabel then return end
    
    local cf
    if targetModel:IsA("Model") then
        cf = targetModel:GetPivot()
    else
        cf = targetModel.CFrame
    end
    
    local pos = cf.Position
    local rx, ry, rz = cf:ToEulerAnglesXYZ()
    
    coordLabel.Text = string.format(
        "Pos: %.2f, %.2f, %.2f | Rot: %.1f, %.1f, %.1f",
        pos.X, pos.Y, pos.Z,
        math.deg(rx), math.deg(ry), math.deg(rz)
    )
end

function ItemAdjuster:OnMouseDown(input)
    if not isActive or not targetModel then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRotating = true
        lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
    end
end

function ItemAdjuster:OnMouseUp(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRotating = false
    end
    lastMousePos = nil
end

function ItemAdjuster:OnMouseMove(input)
    if not isActive or not targetModel then return end
    
    local currentPos = Vector2.new(input.Position.X, input.Position.Y)
    if not lastMousePos then
        lastMousePos = currentPos
        return
    end
    
    local delta = currentPos - lastMousePos
    lastMousePos = currentPos
    
    if isDragging then
        -- Move based on camera direction
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local right = camera.CFrame.RightVector
        local up = camera.CFrame.UpVector
        
        local offset = (right * delta.X + up * -delta.Y) * DRAG_SPEED
        self:ApplyOffset(offset)
        
    elseif isRotating then
        -- Rotate
        local rotX = -delta.Y * ROTATE_SPEED
        local rotY = -delta.X * ROTATE_SPEED
        self:ApplyRotation(rotX, rotY, 0)
    end
end

function ItemAdjuster:OnScroll(input)
    if not isActive or not targetModel then return end
    
    local direction = input.Position.Z > 0 and 1 or -1
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local forward = camera.CFrame.LookVector
    local offset = forward * direction * SCROLL_SPEED
    self:ApplyOffset(offset)
end

function ItemAdjuster:ApplyOffset(offset)
    if not targetModel then return end
    
    -- Only adjust weld C0, don't move the model directly
    -- Moving model directly would move the character too
    if targetWeld and targetWeld:IsA("Weld") then
        targetWeld.C0 = targetWeld.C0 * CFrame.new(offset.X, offset.Y, offset.Z)
    elseif targetWeld and targetWeld:IsA("WeldConstraint") then
        -- WeldConstraint can't be adjusted, move model but counter-move character
        -- Just print warning
        warn("[ItemAdjuster] WeldConstraint detected - cannot adjust offset")
    end
    
    self:UpdateCoordDisplay()
end

function ItemAdjuster:ApplyRotation(rx, ry, rz)
    if not targetModel then return end
    
    local rotCF = CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
    
    -- Only adjust weld C0 rotation
    if targetWeld and targetWeld:IsA("Weld") then
        targetWeld.C0 = targetWeld.C0 * rotCF
    elseif targetWeld and targetWeld:IsA("WeldConstraint") then
        warn("[ItemAdjuster] WeldConstraint detected - cannot adjust rotation")
    end
    
    self:UpdateCoordDisplay()
end

function ItemAdjuster:Reset()
    if not targetModel then return end
    
    -- Ask server for default offset
    local AdminEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AdminEvent")
    if AdminEvent then
        AdminEvent:FireServer("reset_visual", {slot = currentSlot})
    end
    
    print("[ItemAdjuster] Reset requested for " .. currentSlot)
end

function ItemAdjuster:CopyToClipboard()
    if not targetModel then return end
    
    local cf
    if targetModel:IsA("Model") then
        cf = targetModel:GetPivot()
    else
        cf = targetModel.CFrame
    end
    
    local pos = cf.Position
    local rx, ry, rz = cf:ToEulerAnglesXYZ()
    
    -- Generate Lua code for Items.lua
    local code = string.format(
        'offset = CFrame.new(%.2f, %.2f, %.2f) * CFrame.Angles(math.rad(%.1f), math.rad(%.1f), math.rad(%.1f))',
        pos.X, pos.Y, pos.Z,
        math.deg(rx), math.deg(ry), math.deg(rz)
    )
    
    -- Copy to clipboard (Roblox has limited clipboard support)
    -- Print to output for manual copy
    print("========================================")
    print("[ADJUST] " .. currentSlot .. ":")
    print("  " .. code)
    print("========================================")
    print(">> Copy the line above to Items.lua visual.offset")
    
    if statusLabel then
        statusLabel.Text = "Slot: " .. currentSlot .. " | Copied to Output! Check console."
    end
end

-- Input handling
function ItemAdjuster:HandleInput(input, gameProcessed)
    if not isActive then return end
    
    -- Don't process if typing
    if gameProcessed then return end
    
    -- Key binds
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Tab then
            self:SwitchSlot()
            return true
        elseif input.KeyCode == Enum.KeyCode.C then
            self:CopyToClipboard()
            return true
        elseif input.KeyCode == Enum.KeyCode.R then
            self:Reset()
            return true
        end
    end
    
    -- Mouse
    if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.MouseButton2 then
        self:OnMouseDown(input)
        return true
    end
    
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        self:OnScroll(input)
        return true
    end
    
    return false
end

function ItemAdjuster:HandleInputEnd(input)
    if not isActive then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.MouseButton2 then
        self:OnMouseUp(input)
    end
end

function ItemAdjuster:HandleMouseMove(input)
    if not isActive then return end
    
    if isDragging or isRotating then
        self:OnMouseMove(input)
    end
end

function ItemAdjuster:IsActive()
    return isActive
end

return ItemAdjuster
