--[[
    AdminSystem.lua
    Server-side admin commands
    
    Fitur:
    - GM Code redeem (ubah job ke GameMaster)
    - Give item ke diri/sendiri/semua
    - Use semua item tanpa batasan job
    - Teleport, heal, kill, dll
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local AdminSystem = {}

-- Config
local GM_CODE = "GM2024"  -- Ubah kode ini!
local GM_JOB = "GameMaster"

-- Track GM players
local GMPlayers = {}  -- [player] = true

-- Helper: cek apakah player GM
local function isGM(player)
    return GMPlayers[player] == true
end

function AdminSystem:Init(events)
    self.events = events
    
    -- Handle AdminEvent
    events.AdminEvent.OnServerEvent:Connect(function(player, action, data)
        -- Cek apakah player GM
        if not GMPlayers[player] then
            -- Cek kode GM
            if action == "redeem_code" and data.code == GM_CODE then
                GMPlayers[player] = true
                
                -- Set job ke GameMaster
                local pData = require(game.ServerScriptService.MainServer.ServerModules.PlayerData):Get(player)
                if pData then
                    pData.job = GM_JOB
                    -- Beri semua skill
                    pData.learnedSkills = {}
                    for skillId, _ in pairs(GameData.Skills or {}) do
                        table.insert(pData.learnedSkills, skillId)
                    end
                    print("[AdminSystem] " .. player.Name .. " redeemed GM code -> " .. GM_JOB)
                end
                
                events.AdminEvent:FireClient(player, "gm_granted", {})
                return
            end
            
            -- Bukan GM, tolak
            events.AdminEvent:FireClient(player, "error", {message = "Kamu bukan GameMaster!"})
            return
        end
        
        -- GM Commands
        if action == "give_item" then
            self:GiveItem(player, data.item_id, data.quantity or 1, data.target)
            
        elseif action == "give_gold" then
            self:GiveGold(player, data.amount, data.target)
            
        elseif action == "heal" then
            self:Heal(player, data.target)
            
        elseif action == "teleport" then
            self:Teleport(player, data.target)
            
        elseif action == "list_items" then
            self:ListItems(player)
            
        elseif action == "set_level" then
            self:SetLevel(player, data.level, data.target)
            
        elseif action == "give_all_items" then
            self:GiveAllItems(player)
        end
    end)
    
    -- Track disconnect
    game.Players.PlayerRemoving:Connect(function(player)
        GMPlayers[player] = nil
    end)
    
    print("[AdminSystem] Initialized!")
end

-- Give item
function AdminSystem:GiveItem(player, itemId, quantity, targetPlayerName)
    local PlayerData = require(game.ServerScriptService.MainServer.ServerModules.PlayerData)
    
    local target = player
    if targetPlayerName and targetPlayerName ~= "" then
        target = game.Players:FindFirstChild(targetPlayerName)
    end
    
    if not target then
        self.events.AdminEvent:FireClient(player, "error", {message = "Player tidak ditemukan!"})
        return
    end
    
    local itemData = GameData:GetItem(itemId)
    if not itemData then
        self.events.AdminEvent:FireClient(player, "error", {message = "Item '" .. itemId .. "' tidak ada!"})
        return
    end
    
    local pData = PlayerData:Get(target)
    if not pData then return end
    
    -- Tambahkan ke inventory
    local added = false
    if itemData.stackable then
        -- Cari stack yang sudah ada
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
    local PlayerData = require(game.ServerScriptService.MainServer.ServerModules.PlayerData)
    
    local target = player
    if targetPlayerName and targetPlayerName ~= "" then
        target = game.Players:FindFirstChild(targetPlayerName)
    end
    
    if not target then return end
    
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
    local PlayerData = require(game.ServerScriptService.MainServer.ServerModules.PlayerData)
    
    local target = player
    if targetPlayerName and targetPlayerName ~= "" then
        target = game.Players:FindFirstChild(targetPlayerName)
    end
    
    if not target or not target.Character then return end
    
    local humanoid = target.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = humanoid.MaxHealth
    end
    
    local pData = PlayerData:Get(target)
    if pData then
        pData.hp = pData.maxHp or 100
        pData.mp = pData.maxMp or 50
        PlayerData:SendUpdate(target, self.events)
    end
    
    print("[AdminSystem] " .. player.Name .. " healed " .. target.Name)
end

-- Teleport to player
function AdminSystem:Teleport(player, targetPlayerName)
    if not targetPlayerName or targetPlayerName == "" then return end
    
    local target = game.Players:FindFirstChild(targetPlayerName)
    if not target or not target.Character then return end
    
    local targetPos = target.Character:GetPivot()
    if player.Character then
        player.Character:PivotTo(targetPos + Vector3.new(3, 0, 0))
    end
    
    print("[AdminSystem] " .. player.Name .. " teleported to " .. target.Name)
end

-- List all items
function AdminSystem:ListItems(player)
    local items = {}
    for id, data in pairs(GameData.Items or {}) do
        table.insert(items, {id = id, name = data.name or id, type = data.type or "unknown"})
    end
    
    self.events.AdminEvent:FireClient(player, "item_list", {items = items})
    print("[AdminSystem] Sent item list to " .. player.Name .. " (" .. #items .. " items)")
end

-- Set level
function AdminSystem:SetLevel(player, level, targetPlayerName)
    local PlayerData = require(game.ServerScriptService.MainServer.ServerModules.PlayerData)
    
    local target = player
    if targetPlayerName and targetPlayerName ~= "" then
        target = game.Players:FindFirstChild(targetPlayerName)
    end
    
    if not target then return end
    
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
    local PlayerData = require(game.ServerScriptService.MainServer.ServerModules.PlayerData)
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

-- Check apakah player GM (dipakai module lain)
function AdminSystem:IsGM(player)
    return GMPlayers[player] == true
end

return AdminSystem
