-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Load RedzLib
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()

-- Create Window
local window = redzlib:MakeWindow({
    Name = "Blox Fruits Script",
    SubTitle = "By PORG",
    SaveFolder = "example.json"
})

-- Load settings from JSON
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
                autoFarm = {
                    enabled = false,
                    targetType = "NPCs",
                    attackRange = 50,
                    preferredWeapon = "Sword"
                },
                quests = {
                    enabled = false,
                    currentQuest = "Pirate",
                    questLocations = {
                        Pirate = {
                            name = "Pirate Starter",
                            npcName = "Pirate Quest Giver",
                            position = {100, 5, 50},
                            requiredLevel = 1
                        },
                        Marine = {
                            name = "Marine Starter",
                            npcName = "Marine Quest Giver",
                            position = {200, 5, 50},
                            requiredLevel = 10
                        },
                        Boss = {
                            name = "Boss Location",
                            npcName = "Boss NPC",
                            position = {300, 5, 50},
                            requiredLevel = 20
                        }
                    }
                },
                teleport = {
                    enabled = false,
                    locations = {
                        {
                            name = "Starter Island",
                            position = {100, 5, 50}
                        },
                        {
                            name = "Pirate Village",
                            position = {200, 5, 50}
                        }
                    }
                },
                misc = {
                    antiAfk = true,
                    notifications = true
                }
            },
            userData = {
                lastUsed = os.date("%Y-%m-%d"),
                playTime = "0h 0m",
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
            logs = {
                activity = {},
                errors = {},
                warnings = {}
            }
        }
    end
end

-- Save settings to JSON
local function saveSettings(data)
    local success, err = pcall(function()
        writefile("example.json", HttpService:JSONEncode(data))
    end)
    if not success then
        warn("Failed to save settings: " .. err)
    end
end

-- Load settings
local settings = loadSettings()

-- Function to interact with NPC
local function interactWithNPC(npcPosition)
    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(unpack(npcPosition))})
    tween:Play()
    tween.Completed:Wait()
    warn("Interacted with NPC at position: " .. table.concat(npcPosition, ", "))
end

-- Function to accept quest
local function acceptQuest(questType)
    local questData = settings.settings.quests.questLocations[questType]
    if questData then
        interactWithNPC(questData.position)
        warn("Accepted quest: " .. questType)
    else
        warn("Quest data not found for: " .. questType)
    end
end

-- Auto Farm Toggle
local autoFarmEnabled = false
local autoFarmConnection
window:MakeTab({
    Name = "Farm",
    Icon = "rbxassetid://10709761889"
}):AddToggle({
    Name = "Enable Auto Farm",
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
        if autoFarmEnabled then
            autoFarmConnection = RunService.Heartbeat:Connect(function()
                -- Accept quest
                acceptQuest(settings.settings.quests.currentQuest)

                -- Find and attack targets
                local target = nil
                for _, npc in ipairs(game:GetService("Workspace").NPCs:GetChildren()) do
                    if npc:FindFirstChild("HumanoidRootPart") then
                        target = npc
                        break
                    end
                end

                if target then
                    HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end)
        else
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
            end
        end
    end
})

-- Log Script Closure
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "redz Library V5" then
        saveSettings(settings)
        print("The script has been closed")
    end
end)
