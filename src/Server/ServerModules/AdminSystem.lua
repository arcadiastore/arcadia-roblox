--[[
    AdminSystem.lua
    Server-side admin commands
    
    Keamanan:
    - Hanya UserId dalam whitelist yang bisa akses
    - Semua validasi di SERVER, client hanya UI
    - GM Code dihapus, diganti UserId whitelist
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))
local Players = game:GetService("Players")

local AdminSystem = {}

-- ============================================
-- ADMIN WHITELIST (UserId)
-- Tambahkan UserId admin di sini
-- ============================================
local ADMIN_IDS = {
    8892555519,  -- Astagfirulove (Owner)
}

-- Helper: cek apakah player admin
local function isAdmin(player)
    for _, id in ipairs(ADMIN_IDS) do
        if player.UserId == id then
            return true
        end
    end
    return false
end

function AdminSystem:Init(events)
    self.events = events
    self.PlayerData = nil  -- Lazy load
    
    -- Handle AdminEvent
    events.AdminEvent.OnServerEvent:Connect(function(player, action, data)
        -- Validasi admin di SERVER
        if not isAdmin(player) then
            warn("[AdminSystem] Non-admin " .. player.Name .. " tried to use: " .. tostring(action))
            events.AdminEvent:FireClient(player, "error", {message = "Akses ditolak!"})
            return
        end
        
        -- Validasi data
        data = data or {}
        
        -- GM Commands
        if action == "give_item" then
            if data.item_id and data.item_id ~= "" then
                self:GiveItem(player, data.item_id, data.quantity or 1, data.target)
            else
                events.AdminEvent:FireClient(player, "error", {message = "Item ID kosong!"})
            end
            
        elseif action == "give_gold" then
            self:GiveGold(player, tonumber(data.amount) or 0, data.target)
            
        elseif action == "heal" then
            self:Heal(player, data.target)
            
        elseif action == "teleport" then
            if data.target and data.target ~= "" then
                self:Teleport(player, data.target)
            else
                events.AdminEvent:FireClient(player, "error", {message = "Isi nama target!"})
            end
            
        elseif action == "list_items" then
            self:ListItems(player)
            
        elseif action == "set_level" then
            self:SetLevel(player, tonumber(data.level) or 1, data.target)
            
        elseif action == "give_all_items" then
            self:GiveAllItems(player)
            
        elseif action == "check_admin" then
            -- Client minta konfirmasi admin status
            events.AdminEvent:FireClient(player, "admin_status", {is_admin = true})
        end
    end)
    
    print("[AdminSystem] Initialized! Admin count: " .. #ADMIN_IDS)
end

-- Lazy load PlayerData
function AdminSystem:GetPlayerData()
    if not self.PlayerData then
        self.PlayerData = require(game.ServerScriptService.MainServer.ServerModules.PlayerData)
    end
    return self.PlayerData
end

-- Give item
function AdminSystem:GiveItem(player, itemId, quantity, targetPlayerName)
    local PlayerData = self:GetPlayerData()
    
    local target = player
    if targetPlayerName and targetPlayerName ~= "" then
        target = Players:FindFirstChild(targetPlayerName)
    end
    
    if not target then
        self.events.AdminEvent:FireClient(player, "error", {message = "Player '" .. tostring(targetPlayerName) .. "' tidak ditemukan!"})
        return
    end
    
    local itemData = GameData:GetItem(itemId)
    if not itemData then
        self.events.AdminEvent:FireClient(player, "error", {message = "Item '" .. itemId .. "' tidak ada di GameData!"})
        return
    end
    
    local pData = PlayerData:Get(target)
    if not pData then
        self.events.AdminEvent:FireClient(player, "error", {message = "Data player tidak ditemukan!"})
        return
    end
    
    -- Tambahkan ke inventory
    local added = false
    if itemData.stackable then
        for i, slot in ipairs(pData.inventory) do
            if slot.id == itemId then
                slot.quantity = (slot.quantity or 1) + quantity
                added = true
                break
            end
        end
    end
    
    if not added then
        for i = 1, quantity do
            table.insert(pData.inventory, {id = itemId, quantity = 1})
        end
    end
    
    -- Update client
    PlayerData:SendUpdate(target, self.events)
    
    print("[AdminSystem] " .. player.Name .. " gave " .. quantity .. "x " .. itemId .. " to " .. target.Name)
    self.events.AdminEvent:FireClient(player, "success", {
        message = "Berhasil kasih " .. quantity .. "x " .. (itemData.name or itemId) .. " ke " .. target.Name
    })
end

-- Give gold
function AdminSystem:GiveGold(player, amount, targetPlayerName)
    if amount <= 0 then
        self.events.AdminEvent:FireClient(player, "error", {message = "Jumlah harus > 0!"})
        return
    end
    
    local PlayerData = self:GetPlayerData()
    
    local target = player
    if targetPlayerName and targetPlayerName ~= "" then
        target = Players:FindFirstChild(targetPlayerName)
    end
    
    if not target then
        self.events.AdminEvent:FireClient(player, "error", {message = "Player tidak ditemukan!"})
        return
    end
    
    local pData = PlayerData:Get(target)
    if not pData then return end
    
    pData.gold = (pData.gold or 0) + amount
    PlayerData:SendUpdate(target, self.events)
    
    print("[AdminSystem] " .. player.Name .. " gave " .. amount .. " gold to " .. target.Name)
    self.events.AdminEvent:FireClient(player, "success", {
        message = "Berhasil kasih " .. amount .. " gold ke " .. target.Name
    })
end

-- Heal
function AdminSystem:Heal(player, targetPlayerName)
    local PlayerData = self:GetPlayerData()
    
    local target = player
    if targetPlayerName and targetPlayerName ~= "" then
        target = Players:FindFirstChild(targetPlayerName)
    end
    
    if not target then
        self.events.AdminEvent:FireClient(player, "error", {message = "Player tidak ditemukan!"})
        return
    end
    
    if target.Character then
        local humanoid = target.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
    
    local pData = PlayerData:Get(target)
    if pData then
        pData.hp = pData.maxHp or 100
        pData.mp = pData.maxMp or 50
        PlayerData:SendUpdate(target, self.events)
    end
    
    print("[AdminSystem] " .. player.Name .. " healed " .. target.Name)
    self.events.AdminEvent:FireClient(player, "success", {message = "Healed " .. target.Name})
end

-- Teleport to player
function AdminSystem:Teleport(player, targetPlayerName)
    local target = Players:FindFirstChild(targetPlayerName)
    if not target then
        self.events.AdminEvent:FireClient(player, "error", {message = "Player '" .. targetPlayerName .. "' tidak ditemukan!"})
        return
    end
    
    if not target.Character then
        self.events.AdminEvent:FireClient(player, "error", {message = "Player belum spawn!"})
        return
    end
    
    local targetPos = target.Character:GetPivot()
    if player.Character then
        player.Character:PivotTo(targetPos + Vector3.new(3, 0, 0))
    end
    
    print("[AdminSystem] " .. player.Name .. " teleported to " .. target.Name)
    self.events.AdminEvent:FireClient(player, "success", {message = "Teleported to " .. target.Name})
end

-- List all items
function AdminSystem:ListItems(player)
    local items = {}
    for id, data in pairs(GameData.Items or {}) do
        table.insert(items, {
            id = id, 
            name = data.name or id, 
            type = data.type or "unknown",
            slot = data.slot or "",
        })
    end
    
    -- Sort by name
    table.sort(items, function(a, b) return a.id < b.id end)
    
    self.events.AdminEvent:FireClient(player, "item_list", {items = items})
    print("[AdminSystem] Sent item list to " .. player.Name .. " (" .. #items .. " items)")
end

-- Set level
function AdminSystem:SetLevel(player, level, targetPlayerName)
    if level < 1 or level > 999 then
        self.events.AdminEvent:FireClient(player, "error", {message = "Level harus 1-999!"})
        return
    end
    
    local PlayerData = self:GetPlayerData()
    
    local target = player
    if targetPlayerName and targetPlayerName ~= "" then
        target = Players:FindFirstChild(targetPlayerName)
    end
    
    if not target then
        self.events.AdminEvent:FireClient(player, "error", {message = "Player tidak ditemukan!"})
        return
    end
    
    local pData = PlayerData:Get(target)
    if not pData then return end
    
    pData.level = level
    pData.exp = 0
    PlayerData:SendUpdate(target, self.events)
    
    print("[AdminSystem] " .. player.Name .. " set " .. target.Name .. " level to " .. level)
    self.events.AdminEvent:FireClient(player, "success", {
        message = "Set " .. target.Name .. " level ke " .. level
    })
end

-- Give all items
function AdminSystem:GiveAllItems(player)
    local PlayerData = self:GetPlayerData()
    local pData = PlayerData:Get(player)
    if not pData then return end
    
    local count = 0
    for id, data in pairs(GameData.Items or {}) do
        if data.type == "equipment" then
            table.insert(pData.inventory, {id = id, quantity = 1})
            count = count + 1
        end
    end
    
    PlayerData:SendUpdate(player, self.events)
    
    print("[AdminSystem] " .. player.Name .. " got all " .. count .. " equipment items")
    self.events.AdminEvent:FireClient(player, "success", {
        message = "Berhasil kasih semua equipment (" .. count .. " items)"
    })
end

return AdminSystem
