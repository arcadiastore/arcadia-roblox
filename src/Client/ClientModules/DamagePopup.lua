--[[
    DamagePopup.lua
    Shows damage numbers at monster position
]]

local DamagePopup = {}

-- Show damage number at monster position
function DamagePopup:Show(monsterPart, damage, hpData)
    if not monsterPart or not monsterPart.Parent then return end
    
    -- Update HP bar on monster (client-side)
    if hpData then
        local billboard = monsterPart:FindFirstChild("BillboardGui")
        if billboard then
            local hpLabel = billboard:FindFirstChild("HPLabel")
            if hpLabel then
                hpLabel.Text = "HP: " .. hpData.currentHP .. "/" .. hpData.maxHP
                local pct = hpData.currentHP / hpData.maxHP
                if pct > 0.5 then
                    hpLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                elseif pct > 0.25 then
                    hpLabel.TextColor3 = Color3.fromRGB(255, 255, 50)
                else
                    hpLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            end
        end
    end
    
    -- Create damage popup at monster position
    local popup = Instance.new("BillboardGui")
    popup.Name = "DamagePopup"
    popup.Size = UDim2.new(0, 80, 0, 40)
    popup.StudsOffset = Vector3.new(math.random(-2, 2), 3, 0)
    popup.AlwaysOnTop = true
    popup.Parent = monsterPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "-" .. damage
    label.TextColor3 = Color3.fromRGB(255, 50, 50)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = popup
    
    -- Animate: float up and fade
    task.spawn(function()
        for i = 1, 15 do
            popup.StudsOffset = popup.StudsOffset + Vector3.new(0, 0.15, 0)
            label.TextTransparency = i / 15
            label.TextStrokeTransparency = i / 15
            task.wait(0.03)
        end
        popup:Destroy()
    end)
end

return DamagePopup
