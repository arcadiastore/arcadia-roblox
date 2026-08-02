--[[
    DamagePopup.lua
    Shows damage numbers when attacking
]]

local DamagePopup = {}

-- Show damage number
function DamagePopup:Show(damage, gui)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 0, 40)
    label.Position = UDim2.new(math.random(30, 70) / 100, 0, math.random(30, 50) / 100, 0)
    label.BackgroundTransparency = 1
    label.Text = "-" .. damage
    label.TextColor3 = Color3.fromRGB(255, 50, 50)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = gui
    
    -- Animate
    task.spawn(function()
        for i = 1, 10 do
            label.Position = label.Position + UDim2.new(0, 0, -0.02, 0)
            label.TextTransparency = i / 10
            label.TextStrokeTransparency = i / 10
            task.wait(0.05)
        end
        label:Destroy()
    end)
end

return DamagePopup
