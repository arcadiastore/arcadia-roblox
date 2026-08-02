--[[
    Arcadia Online - Party Manager
    
    Handles party system:
    - Create party
    - Join/leave party
    - Party chat
    - Shared EXP
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PartyManager = {}
PartyManager.__index = PartyManager

-- Party settings
local MAX_PARTY_SIZE = 4
local EXP_SHARE_RANGE = 100  -- studs

function PartyManager.new()
    local self = setmetatable({}, PartyManager)
    
    self.parties = {}  -- partyId -> party data
    self.playerParties = {}  -- userId -> partyId
    self.nextPartyId = 1
    
    return self
end

-- Create party
function PartyManager:CreateParty(leader)
    local partyId = self.nextPartyId
    self.nextPartyId = self.nextPartyId + 1
    
    self.parties[partyId] = {
        id = partyId,
        leader = leader.UserId,
        members = { leader.UserId },
        createdAt = os.time(),
    }
    
    self.playerParties[leader.UserId] = partyId
    
    print("[Party] Party created by " .. leader.Name .. " (ID: " .. partyId .. ")")
    
    -- Notify client
    self:NotifyPartyUpdate(partyId)
    
    return partyId
end

-- Join party
function PartyManager:JoinParty(player, partyId)
    local party = self.parties[partyId]
    if not party then
        return false, "Party not found"
    end
    
    -- Check if already in party
    if self.playerParties[player.UserId] then
        return false, "Already in a party"
    end
    
    -- Check party size
    if #party.members >= MAX_PARTY_SIZE then
        return false, "Party is full"
    end
    
    -- Add to party
    table.insert(party.members, player.UserId)
    self.playerParties[player.UserId] = partyId
    
    print("[Party] " .. player.Name .. " joined party " .. partyId)
    
    -- Notify all members
    self:NotifyPartyUpdate(partyId)
    self:BroadcastToParty(partyId, player.Name .. " joined the party!")
    
    return true, "Joined party"
end

-- Leave party
function PartyManager:LeaveParty(player)
    local partyId = self.playerParties[player.UserId]
    if not partyId then
        return false, "Not in a party"
    end
    
    local party = self.parties[partyId]
    if not party then
        return false, "Party not found"
    end
    
    -- Remove from party
    for i, memberId in ipairs(party.members) do
        if memberId == player.UserId then
            table.remove(party.members, i)
            break
        end
    end
    
    self.playerParties[player.UserId] = nil
    
    -- If party is empty, disband
    if #party.members == 0 then
        self.parties[partyId] = nil
        print("[Party] Party " .. partyId .. " disbanded")
    else
        -- If leader left, assign new leader
        if party.leader == player.UserId then
            party.leader = party.members[1]
        end
        
        self:NotifyPartyUpdate(partyId)
        self:BroadcastToParty(partyId, player.Name .. " left the party")
    end
    
    print("[Party] " .. player.Name .. " left party " .. partyId)
    
    return true, "Left party"
end

-- Get party
function PartyManager:GetParty(partyId)
    return self.parties[partyId]
end

-- Get player's party
function PartyManager:GetPlayerParty(player)
    local partyId = self.playerParties[player.UserId]
    if partyId then
        return self.parties[partyId]
    end
    return nil
end

-- Check if players are in same party
function PartyManager:AreInSameParty(player1, player2)
    local partyId1 = self.playerParties[player1.UserId]
    local partyId2 = self.playerParties[player2.UserId]
    
    return partyId1 and partyId2 and partyId1 == partyId2
end

-- Get party members
function PartyManager:GetPartyMembers(partyId)
    local party = self.parties[partyId]
    if not party then return {} end
    
    local members = {}
    for _, memberId in ipairs(party.members) do
        local player = Players:GetPlayerByUserId(memberId)
        if player then
            table.insert(members, player)
        end
    end
    
    return members
end

-- Share EXP to party members
function PartyManager:ShareEXP(player, expAmount)
    local partyId = self.playerParties[player.UserId]
    if not partyId then
        -- No party, player gets all EXP
        return expAmount
    end
    
    local party = self.parties[partyId]
    if not party then return expAmount end
    
    -- Find nearby party members
    local nearbyMembers = self:GetNearbyPartyMembers(player, partyId, EXP_SHARE_RANGE)
    
    if #nearbyMembers > 0 then
        -- Split EXP among nearby members
        local expPerMember = math.floor(expAmount / #nearbyMembers)
        
        for _, member in ipairs(nearbyMembers) do
            -- Award EXP to member
            local PlayerStats = require(game.ServerScriptService.Modules.PlayerStats)
            if PlayerStats then
                PlayerStats:AddEXP(member, expPerMember)
            end
        end
        
        return 0  -- Player already got their share
    end
    
    return expAmount  -- No nearby members, player gets all
end

-- Get nearby party members
function PartyManager:GetNearbyPartyMembers(player, partyId, range)
    local party = self.parties[partyId]
    if not party then return {} end
    
    local nearby = {}
    local playerCharacter = player.Character
    
    if not playerCharacter then return {} end
    
    local playerPosition = playerCharacter:FindFirstChild("HumanoidRootPart")
    if not playerPosition then return {} end
    
    for _, memberId in ipairs(party.members) do
        if memberId ~= player.UserId then
            local member = Players:GetPlayerByUserId(memberId)
            if member and member.Character then
                local memberPosition = member.Character:FindFirstChild("HumanoidRootPart")
                if memberPosition then
                    local distance = (playerPosition.Position - memberPosition.Position).Magnitude
                    if distance <= range then
                        table.insert(nearby, member)
                    end
                end
            end
        end
    end
    
    return nearby
end

-- Party chat
function PartyManager:PartyChat(player, message)
    local partyId = self.playerParties[player.UserId]
    if not partyId then return false end
    
    local party = self.parties[partyId]
    if not party then return false end
    
    -- Send message to all party members
    for _, memberId in ipairs(party.members) do
        local member = Players:GetPlayerByUserId(memberId)
        if member then
            local chatEvent = ReplicatedStorage:FindFirstChild("PartyChatEvent")
            if chatEvent then
                chatEvent:FireClient(member, player.Name, message)
            end
        end
    end
    
    return true
end

-- Broadcast message to party
function PartyManager:BroadcastToParty(partyId, message)
    local party = self.parties[partyId]
    if not party then return end
    
    for _, memberId in ipairs(party.members) do
        local member = Players:GetPlayerByUserId(memberId)
        if member then
            local notificationEvent = ReplicatedStorage:FindFirstChild("NotificationEvent")
            if notificationEvent then
                notificationEvent:FireClient(member, message)
            end
        end
    end
end

-- Notify party update
function PartyManager:NotifyPartyUpdate(partyId)
    local party = self.parties[partyId]
    if not party then return end
    
    local partyData = {
        id = party.id,
        leader = party.leader,
        members = {},
    }
    
    for _, memberId in ipairs(party.members) do
        local member = Players:GetPlayerByUserId(memberId)
        if member then
            table.insert(partyData.members, {
                userId = memberId,
                name = member.Name,
            })
        end
    end
    
    for _, memberId in ipairs(party.members) do
        local member = Players:GetPlayerByUserId(memberId)
        if member then
            local partyUpdateEvent = ReplicatedStorage:FindFirstChild("PartyUpdateEvent")
            if partyUpdateEvent then
                partyUpdateEvent:FireClient(member, partyData)
            end
        end
    end
end

-- Serialize for saving
function PartyManager:Serialize(player)
    local partyId = self.playerParties[player.UserId]
    if partyId then
        return { partyId = partyId }
    end
    return {}
end

return PartyManager.new()
