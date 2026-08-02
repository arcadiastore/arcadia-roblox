--[[
    DIAGNOSTIC.lua
    Taruh di ServerScriptService (Script biasa, BUKAN di dalam MainServer)
    Jalankan sekali, lihat Output, lalu hapus script ini
]]

print("========== DIAGNOSTIC: Waiting 10 seconds for server to start... ==========")
task.wait(10)
print("========== DIAGNOSTIC: Running now ==========")

-- 1. Cek ServerScriptService
print("\n--- ServerScriptService ---")
for _, child in ipairs(game.ServerScriptService:GetChildren()) do
    print("  " .. child.ClassName .. ": " .. child.Name)
    if child:IsA("Folder") or child:IsA("Script") then
        for _, sub in ipairs(child:GetChildren()) do
            print("    " .. sub.ClassName .. ": " .. sub.Name)
        end
    end
end

-- 2. Cek MainServer
local mainServer = game.ServerScriptService:FindFirstChild("MainServer")
if mainServer then
    print("\n--- MainServer contents ---")
    for _, child in ipairs(mainServer:GetChildren()) do
        print("  " .. child.ClassName .. ": " .. child.Name)
    end
    
    local serverModules = mainServer:FindFirstChild("ServerModules")
    if serverModules then
        print("\n--- ServerModules contents ---")
        for _, child in ipairs(serverModules:GetChildren()) do
            print("  " .. child.ClassName .. ": " .. child.Name)
        end
    else
        print("\n[ERROR] ServerModules NOT FOUND inside MainServer!")
        print("[INFO] Checking if ServerModules is sibling...")
        local sibling = game.ServerScriptService:FindFirstChild("ServerModules")
        if sibling then
            print("[FOUND] ServerModules is sibling (not child) of MainServer!")
            print("[FIX] Drag ServerModules INTO MainServer script")
        else
            print("[ERROR] ServerModules not found anywhere!")
        end
    end
else
    print("\n[ERROR] MainServer script not found!")
end

-- 3. Cek ReplicatedStorage
print("\n--- ReplicatedStorage ---")
for _, child in ipairs(game.ReplicatedStorage:GetChildren()) do
    print("  " .. child.ClassName .. ": " .. child.Name)
end

local gameData = game.ReplicatedStorage:FindFirstChild("GameData")
if gameData then
    print("\n--- GameData contents ---")
    for _, child in ipairs(gameData:GetChildren()) do
        print("  " .. child.ClassName .. ": " .. child.Name)
    end
else
    print("\n[ERROR] GameData NOT FOUND in ReplicatedStorage!")
end

local events = game.ReplicatedStorage:FindFirstChild("Events")
if events then
    print("\n--- Events contents ---")
    for _, child in ipairs(events:GetChildren()) do
        print("  " .. child.ClassName .. ": " .. child.Name)
    end
else
    print("\n[INFO] Events not created yet (server may have failed)")
end

-- 4. Cek StarterPlayerScripts
print("\n--- StarterPlayerScripts ---")
for _, child in ipairs(game.StarterPlayer.StarterPlayerScripts:GetChildren()) do
    print("  " .. child.ClassName .. ": " .. child.Name)
    if child:IsA("Folder") or child:IsA("LocalScript") then
        for _, sub in ipairs(child:GetChildren()) do
            print("    " .. sub.ClassName .. ": " .. sub.Name)
        end
    end
end

local mainClient = game.StarterPlayer.StarterPlayerScripts:FindFirstChild("MainClient")
if mainClient then
    local clientModules = mainClient:FindFirstChild("ClientModules")
    if clientModules then
        print("\n--- ClientModules contents ---")
        for _, child in ipairs(clientModules:GetChildren()) do
            print("  " .. child.ClassName .. ": " .. child.Name)
        end
    else
        print("\n[ERROR] ClientModules NOT FOUND inside MainClient!")
    end
end

-- 5. Cek workspace
print("\n--- Workspace ---")
local npcs = workspace:FindFirstChild("NPCs")
if npcs then
    print("  NPCs folder: YES (" .. #npcs:GetChildren() .. " children)")
else
    print("  NPCs folder: NO (not spawned)")
end

local monsters = workspace:FindFirstChild("Monsters")
if monsters then
    print("  Monsters folder: YES (" .. #monsters:GetChildren() .. " children)")
else
    print("  Monsters folder: NO (not spawned)")
end

print("\n========== END DIAGNOSTIC ==========")
