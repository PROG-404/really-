local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local validPlaceIds = {2753915549, 4442272183, 7449423635}
local isValidGame = false
for _, id in ipairs(validPlaceIds) do
    if game.PlaceId == id then
        isValidGame = true
        break
    end
end

if not isValidGame then
    warn("This script works only on Blox Fruits!")
    return
end

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
                enableNotifications = true,
                autoSellItems = false,
                autoBuyItems = false,
                maxFarmDistance = 50,
                enableAntiAfk = true,
                npcLocations = {
                    pirate = {
                        name = "Pirate NPC",
                        position = {100, 5, 50}
                    },
                    marine = {
                        name = "Marine NPC",
                        position = {200, 5, 50}
                    }
                }
            },
            userData = {
                lastUsed = os.date("%Y-%m-%d"),
                playTime = "0h 0m",
                completedQuests = {},
                level = 1,
                experience = 0,
                beli = 0,
                fragments = 0,
                inventory = {
                    weapons = {"Sword"},
                    fruits = {},
                    accessories = {}
                },
                stats = {
                    strength = 10,
                    defense = 10,
                    agility = 10
                }
            },
            options = {
                availablePlayers = {},
                gameMode = "Blox Fruits",
                availableWeapons = {"Sword", "Gun", "Fighting Style"},
                availableFruits = {"Flame", "Ice", "Dark"},
                availableAccessories = {"Black Cape", "Sunglasses"},
                quests = {},
                farmingLocations = {
                    {
                        name = "Starter Island",
                        levelRange = "1-10",
                        recommendedWeapon = "Sword"
                    },
                    {
                        name = "Pirate Village",
                        levelRange = "10-20",
                        recommendedWeapon = "Gun"
                    }
                }
            },
            logs = {
                activity = {},
                errors = {},
                warnings = {}
            }
        }
    end
end

local function saveSettings(data)
    local success, err = pcall(function()
        writefile("example.json", HttpService:JSONEncode(data))
    end)
    if not success then
        warn("Failed to save settings: " .. err)
    end
end

local settings = loadSettings()

local function interactWithNPC(npcPosition)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(unpack(npcPosition))})
    tween:Play()
    tween.Completed:Wait()
    warn("Interacted with NPC at position: " .. table.concat(npcPosition, ", "))
end

local Quests = {
    {
        name = "Defeat Bandits",
        minLevel = 1,
        maxLevel = 10,
        npcPosition = {120, 5, 60}
    },
    {
        name = "Defeat Pirates",
        minLevel = 10,
        maxLevel = 20,
        npcPosition = {220, 5, 60}
    },
    {
        name = "Defeat Marines",
        minLevel = 20,
        maxLevel = 30,
        npcPosition = {320, 5, 60}
    }
}

settings.options.quests = Quests
saveSettings(settings)

local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()
local window = redzlib:MakeWindow({
    Name = "Blox peta", 
    SubTitle = "Porg",
    SaveFolder = "example.json"
})

local Maintab = window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10709761889"
})

Maintab:AddSection({
    Name = "Main"
})

Maintab:AddButton({
    Name = "Reset Player",
    Callback = function()
        if Player and Character then
            Character:BreakJoints()
        end
    end
})

Maintab:AddButton({
    Name = "Join Pirates",
    Callback = function()
        local npcPosition = settings.settings.npcLocations.pirate.position
        interactWithNPC(npcPosition)
    end
})

Maintab:AddButton({
    Name = "Join Marines",
    Callback = function()
        local npcPosition = settings.settings.npcLocations.marine.position
        interactWithNPC(npcPosition)
    end
})

Maintab:AddButton({
    Name = "Auto Accept Quests",
    Callback = function()
        autoAcceptQuests()
    end
})

settings.userData.lastUsed = os.date("%Y-%m-%d")
saveSettings(settings)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "redz Library V5" then
        saveSettings(settings)
        print("The script has been closed")
    end
end)

