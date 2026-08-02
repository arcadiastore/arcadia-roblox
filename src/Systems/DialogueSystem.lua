--[[
    Arcadia Online - Dialogue System
    
    Handles NPC dialogue according to GDD:
    - Talk to NPCs
    - Dialogue trees
    - Quest integration
    - Shop integration
    
    Place di: ServerScriptService/Systems (as Script)
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tunggu game load
task.wait(8)

print("[Dialogue] Dialogue System initializing...")

-- ============================================
-- DIALOGUE DEFINITIONS (GDD)
-- ============================================

local DIALOGUE_DATA = {
    -- Elder Tetua
    {
        npcId = "Elder",
        lines = {
            {
                text = "Selamat datang di desa kita, petualang muda!",
                action = nil,
            },
            {
                text = "Aku punya tugas untukmu. Maukah kau membantu desa?",
                action = "quest_offer",
                questId = "quest_kill_slimes",
            },
            {
                text = "Pergilah ke Training Ground dan bunuh 5 Slime yang mengganggu.",
                action = nil,
            },
        },
    },
    
    -- Pandai Besi
    {
        npcId = "Blacksmith",
        lines = {
            {
                text = "Butuh senjata atau armor? Aku punya yang terbaik!",
                action = "open_shop",
                shopId = "weapon_shop",
            },
            {
                text = "Lihat koleksiku dan pilih yang cocok untukmu.",
                action = nil,
            },
        },
    },
    
    -- Pedagang
    {
        npcId = "Merchant",
        lines = {
            {
                text = "Hei! Mau beli sesuatu? Aku punya barang bagus!",
                action = "open_shop",
                shopId = "general_shop",
            },
            {
                text = "Potion, ramuan, segala macam ada!",
                action = nil,
            },
        },
    },
    
    -- Penjaga Desa
    {
        npcId = "Guard",
        lines = {
            {
                text = "Hati-hati di luar desa. Monster semakin berbahaya.",
                action = nil,
            },
            {
                text = "Gunakan serangan dasar untuk slime, tapi untuk serigala kau perlu skill.",
                action = nil,
            },
        },
    },
    
    -- Master Pelatihan
    {
        npcId = "TrainingMaster",
        lines = {
            {
                text = "Selamat datang di Training Ground! Di sini kau bisa berlatih.",
                action = nil,
            },
            {
                text = "Klik kiri untuk menyerang. Coba serang dummy itu!",
                action = "tutorial_attack",
            },
            {
                text = "Tekan 1-4 untuk menggunakan skill. Skill punya cooldown.",
                action = "tutorial_skill",
            },
            {
                text = "Bicara dengan Elder Tetua untuk mendapatkan quest pertamamu.",
                action = nil,
            },
        },
    },
}

-- ============================================
-- DIALOGUE MANAGER
-- ============================================

local DialogueManager = {}
DialogueManager.__index = DialogueManager

function DialogueManager.new()
    local self = setmetatable({}, DialogueManager)
    
    -- Player dialogue state
    self.playerDialogueState = {}
    
    return self
end

function DialogueManager:Init()
    -- Setup connections
    self:SetupPlayerConnections()
    self:SetupDialogueEvents()
    
    print("[Dialogue] Dialogue System initialized!")
end

function DialogueManager:SetupPlayerConnections()
    -- Player join
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    -- Player leave
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
end

function DialogueManager:OnPlayerAdded(player)
    -- Initialize player dialogue state
    self.playerDialogueState[player.UserId] = {
        currentDialogue = nil,
        currentLine = 1,
    }
    
    print("[Dialogue] Player dialogue state initialized: " .. player.Name)
end

function DialogueManager:OnPlayerRemoving(player)
    -- Cleanup
    self.playerDialogueState[player.UserId] = nil
end

function DialogueManager:SetupDialogueEvents()
    -- RemoteEvent untuk dialogue
    local dialogueEvent = Instance.new("RemoteEvent")
    dialogueEvent.Name = "DialogueEvent"
    dialogueEvent.Parent = ReplicatedStorage:FindFirstChild("Events")
    
    -- Handle dialogue requests
    dialogueEvent.OnServerEvent:Connect(function(player, action, data)
        if action == "start" then
            self:StartDialogue(player, data.npcId)
        elseif action == "next" then
            self:NextDialogueLine(player)
        elseif action == "close" then
            self:CloseDialogue(player)
        end
    end)
end

function DialogueManager:StartDialogue(player, npcId)
    -- Find dialogue data
    local dialogueData = nil
    for _, dialogue in ipairs(DIALOGUE_DATA) do
        if dialogue.npcId == npcId then
            dialogueData = dialogue
            break
        end
    end
    
    if not dialogueData then
        warn("[Dialogue] Dialogue not found for NPC: " .. npcId)
        return
    end
    
    -- Set dialogue state
    local state = self.playerDialogueState[player.UserId]
    state.currentDialogue = dialogueData
    state.currentLine = 1
    
    -- Send first line to client
    local dialogueEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("DialogueEvent")
    if dialogueEvent then
        dialogueEvent:FireClient(player, {
            type = "DialogueStarted",
            npcId = npcId,
            line = dialogueData.lines[1],
            lineIndex = 1,
            totalLines = #dialogueData.lines,
        })
    end
    
    print("[Dialogue] " .. player.Name .. " started dialogue with " .. npcId)
end

function DialogueManager:NextDialogueLine(player)
    local state = self.playerDialogueState[player.UserId]
    if not state.currentDialogue then
        return
    end
    
    -- Move to next line
    state.currentLine = state.currentLine + 1
    
    -- Check if dialogue ended
    if state.currentLine > #state.currentDialogue.lines then
        self:CloseDialogue(player)
        return
    end
    
    -- Get current line
    local currentLine = state.currentDialogue.lines[state.currentLine]
    
    -- Send line to client
    local dialogueEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("DialogueEvent")
    if dialogueEvent then
        dialogueEvent:FireClient(player, {
            type = "DialogueLine",
            npcId = state.currentDialogue.npcId,
            line = currentLine,
            lineIndex = state.currentLine,
            totalLines = #state.currentDialogue.lines,
        })
    end
    
    -- Handle action
    if currentLine.action then
        self:HandleDialogueAction(player, currentLine)
    end
    
    print("[Dialogue] " .. player.Name .. " - Line " .. state.currentLine)
end

function DialogueManager:CloseDialogue(player)
    local state = self.playerDialogueState[player.UserId]
    state.currentDialogue = nil
    state.currentLine = 1
    
    -- Send close event to client
    local dialogueEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("DialogueEvent")
    if dialogueEvent then
        dialogueEvent:FireClient(player, {
            type = "DialogueClosed",
        })
    end
    
    print("[Dialogue] " .. player.Name .. " closed dialogue")
end

function DialogueManager:HandleDialogueAction(player, line)
    if line.action == "quest_offer" then
        -- Offer quest
        if _G.QuestManager then
            _G.QuestManager:AcceptQuest(player, line.questId)
        end
        
    elseif line.action == "open_shop" then
        -- Open shop
        if _G.ShopManager then
            _G.ShopManager:OpenShop(player, line.shopId)
        end
        
    elseif line.action == "tutorial_attack" then
        -- Tutorial: Attack
        print("[Dialogue] Tutorial: Attack")
        
    elseif line.action == "tutorial_skill" then
        -- Tutorial: Skill
        print("[Dialogue] Tutorial: Skill")
    end
end

function DialogueManager:GetPlayerDialogueState(player)
    return self.playerDialogueState[player.UserId]
end

-- ============================================
-- INITIALIZE
-- ============================================

-- Create Events folder if not exists
local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
if not eventsFolder then
    eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "Events"
    eventsFolder.Parent = ReplicatedStorage
end

-- Initialize dialogue manager
local dialogueManager = DialogueManager.new()
dialogueManager:Init()

-- Make accessible from other scripts
_G.DialogueManager = dialogueManager

print("[Dialogue] Dialogue System ready!")
