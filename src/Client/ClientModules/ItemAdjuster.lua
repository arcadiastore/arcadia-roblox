--[[
    ItemAdjuster.lua v3 - Slider-based equipment adjuster
    
    Fitur:
    - GUI panel dengan slider untuk X, Y, Z dan RotX, RotY, RotZ
    - Real-time preview saat geser slider
    - Switch antar equipment slot
    - Copy hasil ke console
    - Reset ke default
]]

local ItemAdjuster = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- State
local isActive = false
local currentSlot = "weapon1h"
local targetModel = nil
local allWelds = {}
local originalC0s = {}  -- Store original C0 for reset

-- GUI
local gui = nil
local sliders = {}
local slotLabel = nil

-- Slider config
local SLIDER_MIN = -5
local SLIDER_MAX = 5
local SLIDER_STEP = 0.05
local ROT_MIN = -180
local ROT_MAX = 180
local ROT_STEP = 1

-- Colors
local BG_COLOR = Color3.fromRGB(25, 25, 35)
local PANEL_COLOR = Color3.fromRGB(35, 35, 50)
local ACCENT_COLOR = Color3.fromRGB(255, 215, 0)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local SLIDER_BG = Color3.fromRGB(50, 50, 70)
local SLIDER_FILL = Color3.fromRGB(100, 180, 255)
local BTN_COLOR = Color3.fromRGB(60, 60, 80)
local SUCCESS_COLOR = Color3.fromRGB(80, 255, 80)

function ItemAdjuster:Create()
    -- Main GUI
    gui = Instance.new("ScreenGui")
    gui.Name = "ItemAdjusterGui"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = playerGui
    
    -- Main frame (right side)
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 300, 0, 450)
    frame.Position = UDim2.new(1, -310, 0.5, -225)
    frame.BackgroundColor3 = BG_COLOR
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 30)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "EQUIPMENT ADJUSTER"
    title.TextColor3 = ACCENT_COLOR
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Slot display
    slotLabel = Instance.new("TextLabel")
    slotLabel.Size = UDim2.new(1, -10, 0, 20)
    slotLabel.Position = UDim2.new(0, 5, 0, 35)
    slotLabel.BackgroundTransparency = 1
    slotLabel.Text = "Slot: weapon1h"
    slotLabel.TextColor3 = TEXT_COLOR
    slotLabel.TextSize = 14
    slotLabel.Font = Enum.Font.Gotham
    slotLabel.Parent = frame
    
    -- Sliders container
    local sliderFrame = Instance.new("ScrollingFrame")
    sliderFrame.Name = "Sliders"
    sliderFrame.Size = UDim2.new(1, -10, 1, -130)
    sliderFrame.Position = UDim2.new(0, 5, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.ScrollBarThickness = 4
    sliderFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
    sliderFrame.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = sliderFrame
    
    -- Create sliders
    local sliderDefs = {
        {name = "Position X", key = "posX", min = SLIDER_MIN, max = SLIDER_MAX, step = SLIDER_STEP},
        {name = "Position Y", key = "posY", min = SLIDER_MIN, max = SLIDER_MAX, step = SLIDER_STEP},
        {name = "Position Z", key = "posZ", min = SLIDER_MIN, max = SLIDER_MAX, step = SLIDER_STEP},
        {name = "Rotation X", key = "rotX", min = ROT_MIN, max = ROT_MAX, step = ROT_STEP},
        {name = "Rotation Y", key = "rotY", min = ROT_MIN, max = ROT_MAX, step = ROT_STEP},
        {name = "Rotation Z", key = "rotZ", min = ROT_MIN, max = ROT_MAX, step = ROT_STEP},
    }
    
    for _, def in ipairs(sliderDefs) do
        sliders[def.key] = self:CreateSlider(sliderFrame, def)
    end
    
    -- Buttons
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -10, 0, 80)
    btnFrame.Position = UDim2.new(0, 5, 1, -85)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = frame
    
    local btnLayout = Instance.new("UIListLayout")
    btnLayout.Padding = UDim.new(0, 5)
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Parent = btnFrame
    
    -- Copy button
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.5, -3, 0, 35)
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    copyBtn.Text = "COPY"
    copyBtn.TextColor3 = TEXT_COLOR
    copyBtn.TextSize = 14
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Parent = btnFrame
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 6)
    copyCorner.Parent = copyBtn
    
    copyBtn.MouseButton1Click:Connect(function()
        self:CopyToClipboard()
    end)
    
    -- Reset button
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0.5, -3, 0, 35)
    resetBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    resetBtn.Text = "RESET"
    resetBtn.TextColor3 = TEXT_COLOR
    resetBtn.TextSize = 14
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.Parent = btnFrame
    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 6)
    resetCorner.Parent = resetBtn
    
    resetBtn.MouseButton1Click:Connect(function()
        self:Reset()
    end)
    
    -- Switch Slot button
    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(1, 0, 0, 30)
    switchBtn.BackgroundColor3 = BTN_COLOR
    switchBtn.Text = "SWITCH SLOT (Tab)"
    switchBtn.TextColor3 = TEXT_COLOR
    switchBtn.TextSize = 12
    switchBtn.Font = Enum.Font.Gotham
    switchBtn.Parent = btnFrame
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 6)
    switchCorner.Parent = switchBtn
    
    switchBtn.MouseButton1Click:Connect(function()
        self:SwitchSlot()
    end)
    
    print("[ItemAdjuster] Created! Press T to toggle.")
end

function ItemAdjuster:CreateSlider(parent, def)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = PANEL_COLOR
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = container
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = def.name
    label.TextColor3 = TEXT_COLOR
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Value label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 2)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "0.00"
    valueLabel.TextColor3 = ACCENT_COLOR
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -10, 0, 8)
    track.Position = UDim2.new(0, 5, 0, 28)
    track.BackgroundColor3 = SLIDER_BG
    track.BorderSizePixel = 0
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 4)
    trackCorner.Parent = track
    
    -- Slider fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = SLIDER_FILL
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    -- Slider handle
    local handle = Instance.new("TextButton")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(0.5, -8, 0.5, -8)
    handle.BackgroundColor3 = ACCENT_COLOR
    handle.Text = ""
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 8)
    handleCorner.Parent = handle
    
    -- Slider logic
    local sliderData = {
        container = container,
        label = label,
        valueLabel = valueLabel,
        track = track,
        fill = fill,
        handle = handle,
        key = def.key,
        min = def.min,
        max = def.max,
        step = def.step,
        value = 0,
    }
    
    -- Mouse drag on handle
    local dragging = false
    
    handle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local trackAbsPos = track.AbsolutePosition
            local trackAbsSize = track.AbsoluteSize
            local mouseX = input.Position.X
            
            local ratio = math.clamp((mouseX - trackAbsPos.X) / trackAbsSize.X, 0, 1)
            local rawValue = def.min + ratio * (def.max - def.min)
            local stepped = math.floor(rawValue / def.step + 0.5) * def.step
            
            self:SetSliderValue(sliderData, stepped)
        end
    end)
    
    -- Click on track to jump
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local trackAbsPos = track.AbsolutePosition
            local trackAbsSize = track.AbsoluteSize
            local mouseX = input.Position.X
            
            local ratio = math.clamp((mouseX - trackAbsPos.X) / trackAbsSize.X, 0, 1)
            local rawValue = def.min + ratio * (def.max - def.min)
            local stepped = math.floor(rawValue / def.step + 0.5) * def.step
            
            self:SetSliderValue(sliderData, stepped)
        end
    end)
    
    return sliderData
end

function ItemAdjuster:SetSliderValue(sliderData, value)
    value = math.clamp(value, sliderData.min, sliderData.max)
    sliderData.value = value
    
    -- Update visual
    local ratio = (value - sliderData.min) / (sliderData.max - sliderData.min)
    sliderData.fill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderData.handle.Position = UDim2.new(ratio, -8, 0.5, -8)
    sliderData.valueLabel.Text = string.format("%.2f", value)
    
    -- Apply to equipment
    self:ApplyCurrentValues()
end

function ItemAdjuster:ApplyCurrentValues()
    if not targetModel or #allWelds == 0 then return end
    
    local px = sliders.posX.value
    local py = sliders.posY.value
    local pz = sliders.posZ.value
    local rx = sliders.rotX.value
    local ry = sliders.rotY.value
    local rz = sliders.rotZ.value
    
    local offsetCF = CFrame.new(px, py, pz) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
    
    -- Apply to all welds relative to original C0
    for i, weld in ipairs(allWelds) do
        if weld and weld.Parent and originalC0s[i] then
            weld.C0 = originalC0s[i] * offsetCF
        end
    end
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
    local found = self:FindEquippedItems()
    if not found or #found == 0 then
        warn("[ItemAdjuster] No equipped items found!")
        return
    end
    
    isActive = true
    gui.Enabled = true
    
    -- Select first item
    self:SelectTarget(found[1])
    
    print("[ItemAdjuster] Active! Adjust with sliders.")
end

function ItemAdjuster:Deactivate()
    isActive = false
    if gui then
        gui.Enabled = false
    end
    print("[ItemAdjuster] Deactivated.")
end

function ItemAdjuster:FindEquippedItems()
    local character = player.Character
    if not character then return {} end
    
    local found = {}
    for _, child in ipairs(character:GetDescendants()) do
        if child.Name and child.Name:match("^Equip_") then
            table.insert(found, child)
        end
    end
    
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") then
            table.insert(found, child)
        end
    end
    
    return found
end

function ItemAdjuster:SelectTarget(model)
    targetModel = model
    allWelds = {}
    originalC0s = {}
    
    -- Find ALL welds
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("Weld") then
            table.insert(allWelds, desc)
            table.insert(originalC0s, desc.C0)
        end
    end
    
    if model:IsA("BasePart") then
        for _, desc in ipairs(model:GetChildren()) do
            if desc:IsA("Weld") then
                table.insert(allWelds, desc)
                table.insert(originalC0s, desc.C0)
            end
        end
    end
    
    -- Reset sliders to 0
    for _, slider in pairs(sliders) do
        self:SetSliderValue(slider, 0)
    end
    
    if slotLabel then
        slotLabel.Text = "Slot: " .. currentSlot .. " | " .. model.Name .. " | Welds: " .. #allWelds
    end
    
    print("[ItemAdjuster] Selected: " .. model.Name .. " (" .. #allWelds .. " welds)")
end

function ItemAdjuster:SwitchSlot()
    local items = self:FindEquippedItems()
    if #items == 0 then return end
    
    -- Find current index
    local currentIndex = 1
    for i, item in ipairs(items) do
        if item == targetModel then
            currentIndex = i
            break
        end
    end
    
    -- Next
    local nextIndex = (currentIndex % #items) + 1
    self:SelectTarget(items[nextIndex])
end

function ItemAdjuster:Reset()
    -- Reset all welds to original C0
    for i, weld in ipairs(allWelds) do
        if weld and weld.Parent and originalC0s[i] then
            weld.C0 = originalC0s[i]
        end
    end
    
    -- Reset sliders
    for _, slider in pairs(sliders) do
        self:SetSliderValue(slider, 0)
    end
    
    print("[ItemAdjuster] Reset to original position.")
end

function ItemAdjuster:CopyToClipboard()
    local px = sliders.posX.value
    local py = sliders.posY.value
    local pz = sliders.posZ.value
    local rx = sliders.rotX.value
    local ry = sliders.rotY.value
    local rz = sliders.rotZ.value
    
    local code = string.format(
        'offset = CFrame.new(%.2f, %.2f, %.2f) * CFrame.Angles(math.rad(%.1f), math.rad(%.1f), math.rad(%.1f))',
        px, py, pz, rx, ry, rz
    )
    
    print("========================================")
    print("[ADJUST] " .. currentSlot .. ":")
    print("  " .. code)
    print("========================================")
    print(">> Copy the line above to Items.lua visual.offset")
end

function ItemAdjuster:HandleInput(input, gameProcessed)
    if not isActive then return end
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.T then
            self:Deactivate()
            return true
        elseif input.KeyCode == Enum.KeyCode.Tab then
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
    
    return false
end

function ItemAdjuster:IsActive()
    return isActive
end

return ItemAdjuster
