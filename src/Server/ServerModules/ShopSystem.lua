--[[
    ShopSystem.lua
    Handles shop open, buy items
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local ShopSystem = {}

-- Open shop
function ShopSystem:OpenShop(player, data, shopId, events)
    local shopData = GameData:GetShop(shopId)
    if not shopData then
        warn("[Shop] Shop not found: " .. shopId)
        return false
    end
    
    local shopItems = GameData:GetShopItems(shopId)
    
    events.ShopEvent:FireClient(player, {
        type = "Open",
        shop = shopData,
        items = shopItems,
        gold = data.gold,
    })
    
    print("[Shop] " .. player.Name .. " opened shop: " .. shopId)
    return true
end

-- Buy item
function ShopSystem:BuyItem(player, data, itemId, events)
    local itemData = GameData:GetItem(itemId)
    if not itemData then
        warn("[Shop] Item not found: " .. itemId)
        events.ShopEvent:FireClient(player, {type = "Error", message = "Item tidak ditemukan!"})
        return false
    end
    
    print("[Shop] Buy attempt: " .. itemId .. " price=" .. tostring(itemData.price) .. " gold=" .. tostring(data.gold) .. " type_price=" .. type(itemData.price) .. " type_gold=" .. type(data.gold))
    
    -- Check gold
    local price = tonumber(itemData.price) or 0
    local gold = tonumber(data.gold) or 0
    if gold < price then
        print("[Shop] Not enough gold! Need " .. price .. " have " .. gold)
        events.ShopEvent:FireClient(player, {type = "Error", message = "Gold tidak cukup! Butuh " .. price .. "G"})
        return false
    end
    
    -- Buy
    data.gold = data.gold - itemData.price
    
    local PlayerData = require(script.Parent.PlayerData)
    PlayerData:AddItem(player, itemId, 1, events)
    
    print("[Shop] " .. player.Name .. " bought " .. itemId .. " for " .. itemData.price .. "G")
    
    -- Send success
    events.ShopEvent:FireClient(player, {
        type = "Bought",
        itemId = itemId,
        itemName = itemData.name,
        price = itemData.price,
        gold = data.gold,
    })
    
    -- Update client
    PlayerData:SendUpdate(player, events)
    
    return true
end

return ShopSystem
