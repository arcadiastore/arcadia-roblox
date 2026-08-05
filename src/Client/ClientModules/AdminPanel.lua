--[[
    AdminPanel.lua
    Client-side admin panel UI
    
    Keamanan:
    - Panel hanya bisa dibuka jika server konfirmasi admin status
    - Tekan F7 -> client minta check_admin -> server validasi -> buka panel
    - Item list di-load saat panel dibuka pertama kali
]]

local AdminPanel = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local AdminEvent = nil
local gui = nil
local isOpen = false
local isAdmin = false  -- Server-confirmed admin status
local allItems = {}    -- Cache item list
local itemsLoaded = false

-- Colors
local BG_COLOR = Color3.fromRGB(30, 30, 40)
local PANEL_COLOR = Color3.fromRGB(40, 40, 55)
local ACCENT_COLOR = Color3.fromRGB(255, 215, 0)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local BTN_COLOR = Color3.fromRGB(60, 60, 80)
local SUCCESS_COLOR = Color3.fromRGB(80, 255, 80)
local ERROR_COLOR = Color3.fromRGB(255, 80, 80)

function AdminPanel:Create(parentGui)
    -- Wait for AdminEvent
    local Events = ReplicatedStorage:WaitForChild("Events", 30)
    if not Events then
        warn("[AdminPanel] Events folder not found!")
        return
    end
    AdminEvent = Events:WaitForChild("AdminEvent", 30)
    if not AdminEvent then
        warn("[AdminPanel] AdminEvent not found!")
        return
    end
    
    -- Build UI (hidden by default)
    self:BuildUI(parentGui)
    
    -- Listen for server responses
    AdminEvent.OnClientEvent:Connect(function(action, data)
        if action == "admin_status" then
            if data.is_admin then
                isAdmin = true
                if gui then
                    gui.Enabled = true
                    isOpen = true
                    -- Load item list on first open
                    if not itemsLoaded then
                        AdminEvent:FireServer("list_items", {})
                    end
                end
            else
                warn("[AdminPanel] You are not an admin!")
            end
            
        elseif action == "success" then
            self:SetStatus(data.message or "Success!", SUCCESS_COLOR)
            
        elseif action == "error" then
            self:SetStatus(data.message or "Error!", ERROR_COLOR)
            
        elseif action == "item_list" then
            allItems = data.items or {}
            itemsLoaded = true
            self:SetStatus("Loaded " .. #allItems .. " items", SUCCESS_COLOR)
            self:RefreshItemList()
        end
    end)
    
    print("[AdminPanel] Created! Press F7 to open (admin only).")
end

function AdminPanel:BuildUI(parentGui)
    -- Main GUI
    gui = Instance.new("ScreenGui")
    gui.Name = "AdminPanelGui"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = parentGui
    
    -- Background frame
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 500, 0, 550)
    frame.Position = UDim2.new(0.5, -250, 0.5, -275)
    frame.BackgroundColor3 = BG_COLOR
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = PANEL_COLOR
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ADMIN PANEL - GameMaster"
    title.TextColor3 = ACCENT_COLOR
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = ERROR_COLOR
    closeBtn.Text = "X"
    closeBtn.TextColor3 = TEXT_COLOR
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Tab buttons
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "Tabs"
    tabFrame.Size = UDim2.new(1, -20, 0, 35)
    tabFrame.Position = UDim2.new(0, 10, 0, 45)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = frame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabFrame
    
    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -140)
    content.Position = UDim2.new(0, 10, 0, 85)
    content.BackgroundColor3 = PANEL_COLOR
    content.BorderSizePixel = 0
    content.Parent = frame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = content
    
    -- Status bar
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "Status"
    statusFrame.Size = UDim2.new(1, -20, 0, 30)
    statusFrame.Position = UDim2.new(0, 10, 1, -40)
    statusFrame.BackgroundColor3 = PANEL_COLOR
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = frame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusText"
    statusLabel.Size = UDim2.new(1, -10, 1, 0)
    statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready"
    statusLabel.TextColor3 = TEXT_COLOR
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusFrame
    
    -- Build tab contents
    self:BuildGiveItemTab(content)
    self:BuildToolsTab(content)
    
    -- Create tab buttons
    local tabs = {
        {name = "Give Item", tab = "GiveItem"},
        {name = "Tools", tab = "Tools"},
    }
    
    for _, tabInfo in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tabInfo.tab .. "Tab"
        btn.Size = UDim2.new(0, 120, 1, 0)
        btn.BackgroundColor3 = BTN_COLOR
        btn.Text = tabInfo.name
        btn.TextColor3 = TEXT_COLOR
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            self:ShowTab(tabInfo.tab, content, tabFrame)
        end)
    end
    
    -- Show first tab by default
    self:ShowTab("GiveItem", content, tabFrame)
end

function AdminPanel:RequestItemList()
    if AdminEvent then
        AdminEvent:FireServer("list_items", {})
    end
end

function AdminPanel:SetStatus(text, color)
    if not gui then return end
    local frame = gui:FindFirstChild("MainFrame")
    if not frame then return end
    local status = frame:FindFirstChild("Status")
    if not status then return end
    local label = status:FindFirstChild("StatusText")
    if label then
        label.Text = text
        label.TextColor3 = color or TEXT_COLOR
    end
end

function AdminPanel:ShowTab(tabName, content, tabFrame)
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("Frame") and child:GetAttribute("Tab") then
            child.Visible = (child:GetAttribute("Tab") == tabName)
        end
    end
    
    for _, child in ipairs(tabFrame:GetChildren()) do
        if child:IsA("TextButton") then
            if child.Name == tabName .. "Tab" then
                child.BackgroundColor3 = ACCENT_COLOR
                child.TextColor3 = Color3.fromRGB(0, 0, 0)
            else
                child.BackgroundColor3 = BTN_COLOR
                child.TextColor3 = TEXT_COLOR
            end
        end
    end
end

function AdminPanel:RefreshItemList()
    local content = gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("Content")
    if not content then return end
    local giveTab = content:FindFirstChild("GiveItemContent")
    if not giveTab then return end
    local listFrame = giveTab:FindFirstChild("ItemList")
    if not listFrame then return end
    
    -- Clear old items
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Populate
    local count = 0
    for _, item in ipairs(allItems) do
        if count < 100 then
            count = count + 1
            local btn = Instance.new("TextButton")
            btn.Name = item.id
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.BackgroundColor3 = BTN_COLOR
            btn.Text = "  " .. item.id .. "  (" .. (item.name or "?") .. ") [" .. (item.type or "?") .. "]"
            btn.TextColor3 = TEXT_COLOR
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = listFrame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                -- Store selected item
                giveTab:SetAttribute("SelectedItemId", item.id)
                local selectedLabel = giveTab:FindFirstChild("SelectedLabel")
                if selectedLabel then
                    selectedLabel.Text = "Selected: " .. item.id .. " (" .. (item.name or "?") .. ")"
                end
                -- Highlight
                for _, b in ipairs(listFrame:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = BTN_COLOR
                        b.TextColor3 = TEXT_COLOR
                    end
                end
                btn.BackgroundColor3 = ACCENT_COLOR
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            end)
        end
    end
    
    listFrame.CanvasSize = UDim2.new(0, 0, 0, count * 27)
end

function AdminPanel:BuildGiveItemTab(parent)
    local tab = Instance.new("Frame")
    tab.Name = "GiveItemContent"
    tab.Size = UDim2.new(1, -10, 1, -10)
    tab.Position = UDim2.new(0, 5, 0, 5)
    tab.BackgroundTransparency = 1
    tab:SetAttribute("Tab", "GiveItem")
    tab:SetAttribute("SelectedItemId", "")
    tab.Visible = true
    tab.Parent = parent
    
    -- Search
    local searchLabel = Instance.new("TextLabel")
    searchLabel.Size = UDim2.new(1, 0, 0, 20)
    searchLabel.BackgroundTransparency = 1
    searchLabel.Text = "Search Item:"
    searchLabel.TextColor3 = ACCENT_COLOR
    searchLabel.TextSize = 14
    searchLabel.Font = Enum.Font.GothamBold
    searchLabel.TextXAlignment = Enum.TextXAlignment.Left
    searchLabel.Parent = tab
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, 0, 0, 30)
    searchBox.Position = UDim2.new(0, 0, 0, 22)
    searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Ketik nama item..."
    searchBox.TextColor3 = TEXT_COLOR
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = tab
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchBox
    
    -- Item list (scrollable)
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "ItemList"
    listFrame.Size = UDim2.new(1, 0, 0, 200)
    listFrame.Position = UDim2.new(0, 0, 0, 58)
    listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 6
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.Parent = tab
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = listFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame
    
    -- Selected item display
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Name = "SelectedLabel"
    selectedLabel.Size = UDim2.new(1, 0, 0, 25)
    selectedLabel.Position = UDim2.new(0, 0, 0, 265)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = "Selected: (none)"
    selectedLabel.TextColor3 = ACCENT_COLOR
    selectedLabel.TextSize = 14
    selectedLabel.Font = Enum.Font.GothamBold
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Parent = tab
    
    -- Quantity
    local qtyLabel = Instance.new("TextLabel")
    qtyLabel.Size = UDim2.new(0.3, 0, 0, 20)
    qtyLabel.Position = UDim2.new(0, 0, 0, 295)
    qtyLabel.BackgroundTransparency = 1
    qtyLabel.Text = "Quantity:"
    qtyLabel.TextColor3 = TEXT_COLOR
    qtyLabel.TextSize = 14
    qtyLabel.Font = Enum.Font.Gotham
    qtyLabel.TextXAlignment = Enum.TextXAlignment.Left
    qtyLabel.Parent = tab
    
    local qtyBox = Instance.new("TextBox")
    qtyBox.Name = "QtyBox"
    qtyBox.Size = UDim2.new(0.3, 0, 0, 30)
    qtyBox.Position = UDim2.new(0.35, 0, 0, 292)
    qtyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    qtyBox.Text = "1"
    qtyBox.TextColor3 = TEXT_COLOR
    qtyBox.TextSize = 14
    qtyBox.Font = Enum.Font.Gotham
    qtyBox.Parent = tab
    
    local qtyCorner = Instance.new("UICorner")
    qtyCorner.CornerRadius = UDim.new(0, 6)
    qtyCorner.Parent = qtyBox
    
    -- Target player
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0.35, 0, 0, 20)
    targetLabel.Position = UDim2.new(0, 0, 0, 330)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target (kosong=self):"
    targetLabel.TextColor3 = TEXT_COLOR
    targetLabel.TextSize = 14
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = tab
    
    local targetBox = Instance.new("TextBox")
    targetBox.Name = "TargetBox"
    targetBox.Size = UDim2.new(0.6, 0, 0, 30)
    targetBox.Position = UDim2.new(0.4, 0, 0, 327)
    targetBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    targetBox.Text = ""
    targetBox.PlaceholderText = "Player name (optional)"
    targetBox.TextColor3 = TEXT_COLOR
    targetBox.TextSize = 14
    targetBox.Font = Enum.Font.Gotham
    targetBox.Parent = tab
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 6)
    targetCorner.Parent = targetBox
    
    -- Give button
    local giveBtn = Instance.new("TextButton")
    giveBtn.Size = UDim2.new(1, 0, 0, 40)
    giveBtn.Position = UDim2.new(0, 0, 0, 370)
    giveBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    giveBtn.Text = "GIVE ITEM"
    giveBtn.TextColor3 = TEXT_COLOR
    giveBtn.TextSize = 18
    giveBtn.Font = Enum.Font.GothamBold
    giveBtn.Parent = tab
    
    local giveBtnCorner = Instance.new("UICorner")
    giveBtnCorner.CornerRadius = UDim.new(0, 8)
    giveBtnCorner.Parent = giveBtn
    
    giveBtn.MouseButton1Click:Connect(function()
        local selectedId = tab:GetAttribute("SelectedItemId")
        if not selectedId or selectedId == "" then
            self:SetStatus("Pilih item dulu!", ERROR_COLOR)
            return
        end
        
        local qty = tonumber(qtyBox.Text) or 1
        local target = targetBox.Text
        
        AdminEvent:FireServer("give_item", {
            item_id = selectedId,
            quantity = qty,
            target = target ~= "" and target or nil,
        })
        
        self:SetStatus("Giving " .. qty .. "x " .. selectedId .. "...")
    end)
    
    -- Give All button
    local giveAllBtn = Instance.new("TextButton")
    giveAllBtn.Size = UDim2.new(1, 0, 0, 35)
    giveAllBtn.Position = UDim2.new(0, 0, 0, 418)
    giveAllBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 50)
    giveAllBtn.Text = "GIVE ALL EQUIPMENT"
    giveAllBtn.TextColor3 = TEXT_COLOR
    giveAllBtn.TextSize = 16
    giveAllBtn.Font = Enum.Font.GothamBold
    giveAllBtn.Parent = tab
    
    local giveAllCorner = Instance.new("UICorner")
    giveAllCorner.CornerRadius = UDim.new(0, 8)
    giveAllCorner.Parent = giveAllBtn
    
    giveAllBtn.MouseButton1Click:Connect(function()
        AdminEvent:FireServer("give_all_items", {})
        self:SetStatus("Giving all equipment...")
    end)
    
    -- Search filter
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = searchBox.Text:lower()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                local match = filter == "" 
                    or child.Name:lower():find(filter) 
                    or child.Text:lower():find(filter)
                child.Visible = match
            end
        end
    end)
end

function AdminPanel:BuildToolsTab(parent)
    local tab = Instance.new("Frame")
    tab.Name = "ToolsContent"
    tab.Size = UDim2.new(1, -10, 1, -10)
    tab.Position = UDim2.new(0, 5, 0, 5)
    tab.BackgroundTransparency = 1
    tab:SetAttribute("Tab", "Tools")
    tab.Visible = false
    tab.Parent = parent
    
    local yPos = 0
    local function makeLabel(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = ACCENT_COLOR
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = tab
        yPos = yPos + 22
    end
    
    local function makeTextBox(name, placeholder, default)
        local box = Instance.new("TextBox")
        box.Name = name
        box.Size = UDim2.new(1, 0, 0, 30)
        box.Position = UDim2.new(0, 0, 0, yPos)
        box.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        box.Text = default or ""
        box.PlaceholderText = placeholder or ""
        box.TextColor3 = TEXT_COLOR
        box.TextSize = 14
        box.Font = Enum.Font.Gotham
        box.Parent = tab
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = box
        yPos = yPos + 35
        return box
    end
    
    local function makeButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = TEXT_COLOR
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tab
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn
        btn.MouseButton1Click:Connect(callback)
        yPos = yPos + 48
    end
    
    makeLabel("Target Player (kosong=self):")
    local targetBox = makeTextBox("TargetBox", "Player name", "")
    
    makeLabel("Gold Amount:")
    local goldBox = makeTextBox("GoldBox", "Amount", "1000")
    
    makeLabel("Level:")
    local levelBox = makeTextBox("LevelBox", "Level", "50")
    
    yPos = yPos + 5
    
    makeButton("HEAL", Color3.fromRGB(50, 180, 50), function()
        local target = targetBox.Text ~= "" and targetBox.Text or nil
        AdminEvent:FireServer("heal", {target = target})
        self:SetStatus("Healing...")
    end)
    
    makeButton("GIVE GOLD", Color3.fromRGB(255, 215, 0), function()
        local amount = tonumber(goldBox.Text) or 1000
        local target = targetBox.Text ~= "" and targetBox.Text or nil
        AdminEvent:FireServer("give_gold", {amount = amount, target = target})
        self:SetStatus("Giving " .. amount .. " gold...")
    end)
    
    makeButton("SET LEVEL", Color3.fromRGB(100, 100, 255), function()
        local level = tonumber(levelBox.Text) or 50
        local target = targetBox.Text ~= "" and targetBox.Text or nil
        AdminEvent:FireServer("set_level", {level = level, target = target})
        self:SetStatus("Setting level to " .. level .. "...")
    end)
    
    makeButton("TELEPORT TO PLAYER", Color3.fromRGB(200, 100, 255), function()
        if targetBox.Text ~= "" then
            AdminEvent:FireServer("teleport", {target = targetBox.Text})
            self:SetStatus("Teleporting to " .. targetBox.Text .. "...")
        else
            self:SetStatus("Isi nama target dulu!", ERROR_COLOR)
        end
    end)
end

function AdminPanel:Open()
    if not AdminEvent then
        warn("[AdminPanel] Not initialized!")
        return
    end
    
    -- Request admin check from server
    AdminEvent:FireServer("check_admin", {})
    self:SetStatus("Checking admin status...")
end

function AdminPanel:Close()
    if gui then
        gui.Enabled = false
        isOpen = false
    end
end

function AdminPanel:Toggle()
    if not AdminEvent then
        warn("[AdminPanel] Not initialized!")
        return
    end
    
    if isOpen then
        self:Close()
    else
        self:Open()
    end
end

function AdminPanel:IsOpen()
    return isOpen
end

return AdminPanel
