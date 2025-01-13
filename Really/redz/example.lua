local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Check if the game is "Blox Fruits"
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
    warn("This script works only on Blox Fruits!")
    return
end

-- Load settings from example.json
local function loadSettings()
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile("example.json"))
    end)
    if success then
        return result
    else
        warn("Failed to load settings. Using default settings.")
        return {
            settings = {
                toggleContinuousReset = false,
                autoFarm = false,
                preferredWeapon = "Sword",
                farmSpeed = 5,
                enableNotifications = true
            },
            userData = {
                lastUsed = os.date("%Y-%m-%d"),
                playTime = "0h 0m",
                completedQuests = {},
                level = 1
            },
            options = {
                availablePlayers = {},
                gameMode = "Blox Fruits",
                availableWeapons = {"Sword", "Gun", "Fighting Style"},
                quests = {}
            },
            logs = {
                activity = {}
            }
        }
    end
end

-- Save settings to example.json
local function saveSettings(data)
    writefile("example.json", HttpService:JSONEncode(data))
end

-- Loaded settings
local settings = loadSettings()

-- Create window using RedzLib
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()
local window = redzlib:MakeWindow({
    Name = "Blox peta", 
    SubTitle = "Porg",
    SaveFolder = "example.json"
})

-- Main Tab
local Maintab = window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10709761889" -- or 98248469922804
})

Maintab:AddSection({
    Name = "Main"
})

-- Add Reset Player Button
Maintab:AddButton({
    Name = "Reset Player",
    Callback = function()
        local player = Players.LocalPlayer
        if player and player.Character then
            player.Character:BreakJoints() -- Kill the player
        end
    end
})

-- Farm Tab
local Farmtab = window:MakeTab({
    Name = "Farm",
    Icon = "rbxassetid://10709761889"
})

Farmtab:AddSection({
    Name = "Auto Level"
})

-- Add Toggle for Continuous Reset
local isResetting = settings.settings.toggleContinuousReset
local toggleReset

Farmtab:AddToggle({
    Name = "Toggle Continuous Reset",
    Default = isResetting,
    Callback = function(Value)
        settings.settings.toggleContinuousReset = Value
        if settings.settings.toggleContinuousReset then
            toggleReset = RunService.Heartbeat:Connect(function()
                local player = Players.LocalPlayer
                if player and player.Character then
                    player.Character:BreakJoints() -- Continuous reset
                end
            end)
        else
            if toggleReset then toggleReset:Disconnect() end
        end
        -- Save settings after the change
        saveSettings(settings)
    end
})

-- Add Toggle for Auto Farm
local autoFarm = settings.settings.autoFarm
Farmtab:AddToggle({
    Name = "Toggle Auto Farm",
    Default = autoFarm,
    Callback = function(Value)
        settings.settings.autoFarm = Value
        -- Save settings after the change
        saveSettings(settings)
    end
})

-- Player List Dropdown
local playerList = settings.options.availablePlayers
Farmtab:AddDropdown({
    Name = "Player List",
    Options = playerList,
    Default = settings.settings.selectedPlayer,
    Callback = function(Value)
        settings.settings.selectedPlayer = Value
        -- Save settings after the change
        saveSettings(settings)
    end
})

-- Update settings when the script is used
settings.userData.lastUsed = os.date("%Y-%m-%d")
saveSettings(settings)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "redz Library V5" then
        SaveSettings()
        print("The script has been closed")
    end
end)
