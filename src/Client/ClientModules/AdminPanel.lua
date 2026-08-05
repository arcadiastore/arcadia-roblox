--[[
    AdminPanel.lua
    Client-side admin panel UI
    
    Fitur:
    - Input GM code untuk jadi GameMaster
    - Give item (search + select)
    - Give gold
    - Heal / Teleport / Set Level
    - List semua items
]]

local AdminPanel = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local AdminEvent = nil
local gui = nil
local isOpen = false
local allItems = {}  -- Cache item list

-- Colors
local BG_COLOR = Color3.fromRGB(30, 30, 40)
local PANEL_COLOR = Color3.fromRGB(40, 40, 55)
local ACCENT_COLOR = Color3.fromRGB(255, 215, 0)  -- Gold
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local BTN_COLOR = Color3.fromRGB(60, 60, 80)
local BTN_HOVER = Color3.fromRGB(80, 80, 110)
local SUCCESS_COLOR = Color3.fromRGB(80, 255, 80)
local ERROR_COLOR = Color3.fromRGB(255, 80, 80)

function AdminPanel:Create(parentGui)
    -- Wait for AdminEvent
    local Events = ReplicatedStorage:WaitForChild("Events", 10)
    if not Events then return end
    AdminEvent = Events:WaitForChild("AdminEvent", 10)
    if not AdminEvent then return end
    
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
    title.Name = "Title"
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
    closeBtn.Name = "CloseBtn"
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
    
    -- Build tabs
    self:BuildGiveItemTab(content)
    self:BuildToolsTab(content)
    self:BuildGMCodeTab(content)
    
    -- Create tab buttons
    local tabs = {
        {name = "Give Item", tab = "GiveItem"},
        {name = "Tools", tab = "Tools"},
        {name = "GM Code", tab = "GMCode"},
    }
    
    for _, tabInfo in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tabInfo.tab .. "Tab"
        btn.Size = UDim2.new(0, 100, 1, 0)
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
    
    -- Listen for server responses
    AdminEvent.OnClientEvent:Connect(function(action, data)
        if action == "gm_granted" then
            self:SetStatus("GameMaster granted! Kamu sekarang GM.", SUCCESS_COLOR)
            gui.Enabled = true
            isOpen = true
            
        elseif action == "success" then
            self:SetStatus(data.message or "Success!", SUCCESS_COLOR)
            
        elseif action == "error" then
            self:SetStatus(data.message or "Error!", ERROR_COLOR)
            
        elseif action == "item_list" then
            allItems = data.items or {}
            self:SetStatus("Loaded " .. #allItems .. " items", SUCCESS_COLOR)
        end
    end)
    
    -- Request item list on open
    self:RequestItemList()
    
    print("[AdminPanel] Created!")
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
    -- Hide all tab content
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("Frame") and child:GetAttribute("Tab") then
            child.Visible = (child:GetAttribute("Tab") == tabName)
        end
    end
    
    -- Highlight active tab
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

function AdminPanel:BuildGiveItemTab(parent)
    local tab = Instance.new("Frame")
    tab.Name = "GiveItemContent"
    tab.Size = UDim2.new(1, -10, 1, -10)
    tab.Position = UDim2.new(0, 5, 0, 5)
    tab.BackgroundTransparency = 1
    tab:SetAttribute("Tab", "GiveItem")
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
    targetLabel.Size = UDim2.new(0.3, 0, 0, 20)
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
    targetBox.Size = UDim2.new(0.65, 0, 0, 30)
    targetBox.Position = UDim2.new(0.35, 0, 0, 327)
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
    giveBtn.Name = "GiveBtn"
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
    
    -- Give All button
    local giveAllBtn = Instance.new("TextButton")
    giveAllBtn.Name = "GiveAllBtn"
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
    
    -- State
    local selectedItemId = nil
    
    -- Function to populate list
    local function populateList(filter)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        filter = filter and filter:lower() or ""
        local count = 0
        
        for _, item in ipairs(allItems) do
            local match = filter == "" 
                or item.id:lower():find(filter) 
                or (item.name and item.name:lower():find(filter))
            
            if match and count < 50 then
                count = count + 1
                local btn = Instance.new("TextButton")
                btn.Name = item.id
                btn.Size = UDim2.new(1, -10, 0, 25)
                btn.BackgroundColor3 = BTN_COLOR
                btn.Text = item.id .. " (" .. (item.name or "?") .. ")"
                btn.TextColor3 = TEXT_COLOR
                btn.TextSize = 12
                btn.Font = Enum.Font.Gotham
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = listFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    selectedItemId = item.id
                    selectedLabel.Text = "Selected: " .. item.id .. " (" .. (item.name or "?") .. ")"
                    -- Highlight
                    for _, b in ipairs(listFrame:GetChildren()) do
                        if b:IsA("TextButton") then
                            b.BackgroundColor3 = BTN_COLOR
                        end
                    end
                    btn.BackgroundColor3 = ACCENT_COLOR
                    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
                end)
            end
        end
        
        listFrame.CanvasSize = UDim2.new(0, 0, 0, count * 27)
    end
    
    -- Search box filter
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populateList(searchBox.Text)
    end)
    
    -- Give button
    giveBtn.MouseButton1Click:Connect(function()
        if not selectedItemId then
            self:SetStatus("Pilih item dulu!", ERROR_COLOR)
            return
        end
        
        local qty = tonumber(qtyBox.Text) or 1
        local target = targetBox.Text
        
        AdminEvent:FireServer("give_item", {
            item_id = selectedItemId,
            quantity = qty,
            target = target ~= "" and target or nil,
        })
        
        self:SetStatus("Giving " .. qty .. "x " .. selectedItemId .. "...")
    end)
    
    -- Give All button
    giveAllBtn.MouseButton1Click:Connect(function()
        AdminEvent:FireServer("give_all_items", {})
        self:SetStatus("Giving all equipment...")
    end)
    
    -- Initial populate
    task.delay(1, function()
        populateList("")
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
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        yPos = yPos + 48
    end
    
    -- Target player
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0, 20)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target Player (kosong=self):"
    targetLabel.TextColor3 = ACCENT_COLOR
    targetLabel.TextSize = 14
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = tab
    yPos = yPos + 25
    
    local targetBox = Instance.new("TextBox")
    targetBox.Name = "TargetBox"
    targetBox.Size = UDim2.new(1, 0, 0, 30)
    targetBox.Position = UDim2.new(0, 0, 0, yPos)
    targetBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    targetBox.Text = ""
    targetBox.PlaceholderText = "Player name"
    targetBox.TextColor3 = TEXT_COLOR
    targetBox.TextSize = 14
    targetBox.Font = Enum.Font.Gotham
    targetBox.Parent = tab
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 6)
    targetCorner.Parent = targetBox
    yPos = yPos + 40
    
    -- Gold amount
    local goldLabel = Instance.new("TextLabel")
    goldLabel.Size = UDim2.new(0.4, 0, 0, 20)
    goldLabel.BackgroundTransparency = 1
    goldLabel.Text = "Gold Amount:"
    goldLabel.TextColor3 = TEXT_COLOR
    goldLabel.TextSize = 14
    goldLabel.Font = Enum.Font.Gotham
    goldLabel.TextXAlignment = Enum.TextXAlignment.Left
    goldLabel.Parent = tab
    
    local goldBox = Instance.new("TextBox")
    goldBox.Name = "GoldBox"
    goldBox.Size = UDim2.new(0.55, 0, 0, 30)
    goldBox.Position = UDim2.new(0.45, 0, 0, yPos)
    goldBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    goldBox.Text = "1000"
    goldBox.TextColor3 = TEXT_COLOR
    goldBox.TextSize = 14
    goldBox.Font = Enum.Font.Gotham
    goldBox.Parent = tab
    
    local goldCorner = Instance.new("UICorner")
    goldCorner.CornerRadius = UDim.new(0, 6)
    goldCorner.Parent = goldBox
    yPos = yPos + 40
    
    -- Level
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(0.4, 0, 0, 20)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level:"
    levelLabel.TextColor3 = TEXT_COLOR
    levelLabel.TextSize = 14
    levelLabel.Font = Enum.Font.Gotham
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Parent = tab
    
    local levelBox = Instance.new("TextBox")
    levelBox.Name = "LevelBox"
    levelBox.Size = UDim2.new(0.55, 0, 0, 30)
    levelBox.Position = UDim2.new(0.45, 0, 0, yPos)
    levelBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    levelBox.Text = "50"
    levelBox.TextColor3 = TEXT_COLOR
    levelBox.TextSize = 14
    levelBox.Font = Enum.Font.Gotham
    levelBox.Parent = tab
    
    local levelCorner = Instance.new("UICorner")
    levelCorner.CornerRadius = UDim.new(0, 6)
    levelCorner.Parent = levelBox
    yPos = yPos + 45
    
    -- Buttons
    makeButton("HEAL", Color3.fromRGB(50, 180, 50), function()
        AdminEvent:FireServer("heal", {target = targetBox.Text ~= "" and targetBox.Text or nil})
        self:SetStatus("Healing...")
    end)
    
    makeButton("GIVE GOLD", Color3.fromRGB(255, 215, 0), function()
        local amount = tonumber(goldBox.Text) or 1000
        AdminEvent:FireServer("give_gold", {
            amount = amount,
            target = targetBox.Text ~= "" and targetBox.Text or nil,
        })
        self:SetStatus("Giving " .. amount .. " gold...")
    end)
    
    makeButton("SET LEVEL", Color3.fromRGB(100, 100, 255), function()
        local level = tonumber(levelBox.Text) or 50
        AdminEvent:FireServer("set_level", {
            level = level,
            target = targetBox.Text ~= "" and targetBox.Text or nil,
        })
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

function AdminPanel:BuildGMCodeTab(parent)
    local tab = Instance.new("Frame")
    tab.Name = "GMCodeContent"
    tab.Size = UDim2.new(1, -10, 1, -10)
    tab.Position = UDim2.new(0, 5, 0, 5)
    tab.BackgroundTransparency = 1
    tab:SetAttribute("Tab", "GMCode")
    tab.Visible = false
    tab.Parent = parent
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 60)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Masukkan GM Code untuk mendapatkan akses GameMaster.\n\nGameMaster bisa pakai SEMUA item tanpa batasan job."
    infoLabel.TextColor3 = TEXT_COLOR
    infoLabel.TextSize = 14
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextWrapped = true
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = tab
    
    local codeBox = Instance.new("TextBox")
    codeBox.Name = "CodeBox"
    codeBox.Size = UDim2.new(1, 0, 0, 35)
    codeBox.Position = UDim2.new(0, 0, 0, 70)
    codeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    codeBox.Text = ""
    codeBox.PlaceholderText = "Masukkan GM Code..."
    codeBox.TextColor3 = ACCENT_COLOR
    codeBox.TextSize = 16
    codeBox.Font = Enum.Font.GothamBold
    codeBox.ClearTextOnFocus = true
    codeBox.Parent = tab
    
    local codeCorner = Instance.new("UICorner")
    codeCorner.CornerRadius = UDim.new(0, 8)
    codeCorner.Parent = codeBox
    
    local redeemBtn = Instance.new("TextButton")
    redeemBtn.Size = UDim2.new(1, 0, 0, 40)
    redeemBtn.Position = UDim2.new(0, 0, 0, 115)
    redeemBtn.BackgroundColor3 = ACCENT_COLOR
    redeemBtn.Text = "REDEEM CODE"
    redeemBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    redeemBtn.TextSize = 18
    redeemBtn.Font = Enum.Font.GothamBold
    redeemBtn.Parent = tab
    
    local redeemCorner = Instance.new("UICorner")
    redeemCorner.CornerRadius = UDim.new(0, 8)
    redeemCorner.Parent = redeemBtn
    
    redeemBtn.MouseButton1Click:Connect(function()
        local code = codeBox.Text
        if code == "" then
            self:SetStatus("Masukkan kode!", ERROR_COLOR)
            return
        end
        AdminEvent:FireServer("redeem_code", {code = code})
        self:SetStatus("Checking code...")
    end)
end

function AdminPanel:Open()
    if gui then
        gui.Enabled = true
        isOpen = true
        self:RequestItemList()
    end
end

function AdminPanel:Close()
    if gui then
        gui.Enabled = false
        isOpen = false
    end
end

function AdminPanel:Toggle()
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
