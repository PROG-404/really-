local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService") 
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Variables
local player = Players.LocalPlayer
local Map = workspace:WaitForChild("Map")
local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
local Stepped = RunService.Stepped

-- Brookhaven Check
if game.PlaceId ~= 4924922222 then
    player:Kick("This script only works in Brookhaven!")
    return
end

-- Functions
local function getTableKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

-- Window Creation
local window = redzlib:MakeWindow({
    Name = "Brookhaven", 
    SubTitle = "by FRONT DARK",
    SaveFolder = "FRONT_REDZ.js"
})

-- Discord Tab
local discordTab = window:MakeTab({
    Name = "Discord",
    Icon = "rbxassetid://10709811261"
})

discordTab:AddDiscordInvite({
    Name = "Join Our Discord",
    Logo = "rbxassetid://10709811261", 
    Invite = "https://discord.gg/vr7"
})

-- Main Tab
local mainTab = window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10709811261"
})

mainTab:AddSection({
    Name = "UI size"
})

mainTab:AddDropdown({
    Name = "UI Size",
    Options = {"Small", "Very Small", "Large", "Very Large"},
    Default = "Small",
    Callback = function(Value)
        local ui = player:FindFirstChild("PlayerGui")
        if not ui then return end

        local scales = {
            Small = 0.8,
            ["Very Small"] = 0.6,
            Large = 1.2,
            ["Very Large"] = 1.5
        }

        for _, gui in pairs(ui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui.Enabled = true
                gui:SetAttribute("UIScale", scales[Value])
            end
        end
    end
})

mainTab:AddSection({
    Name = "Fly"
})

mainTab:AddButton({
    Name = "Activate Fly Script",
    Desc = "Activates the Fly script when clicked",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end
})

mainTab:AddSection({
    Name = "game pro"
})

mainTab:AddButton({
    Name = "Remove Fog",
    Desc = "Removes fog and improves render distance",
    Callback = function()
        local lighting = game:GetService("Lighting")
        
        lighting.FogStart = 0
        lighting.FogEnd = 1e6
        lighting.Brightness = 2
        lighting.GlobalShadows = false
        
        local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            atmosphere:Destroy()
        end
        
        local sky = lighting:FindFirstChildOfClass("Sky")
        if sky then
            sky:Destroy()
        end
        
        local blur = lighting:FindFirstChildOfClass("BlurEffect")
        if blur then
            blur:Destroy()
        end
    end
})

mainTab:AddButton({
    Name = "Set to 60 FPS",
    Callback = function()
        setfpscap(60)
    end
})

mainTab:AddButton({
    Name = "Set to 120 FPS",
    Callback = function()
        setfpscap(120)
    end
})

mainTab:AddButton({
    Name = "Set to Normal Graphics",
    Callback = function()
        local settings = UserSettings():GetService("UserGameSettings")
        settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel5
        settings.GraphicsQualityLevel = 5
    end
})

mainTab:AddButton({
    Name = "Set to High Graphics",
    Callback = function()
        local settings = UserSettings():GetService("UserGameSettings")
        settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel10
        settings.GraphicsQualityLevel = 10
    end
})

mainTab:AddSection({
    Name = "sabotage"
})

mainTab:AddToggle({
    Name = "Launch Nearby Players",
    Default = false,
    Flag = "togglePlayer",
    Callback = function(Value)
        if Value then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart

                game:GetService("RunService").Stepped:Connect(function()
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local otherHRP = otherPlayer.Character.HumanoidRootPart
                            local distance = (hrp.Position - otherHRP.Position).Magnitude

                            if distance >= 1 and distance <= 10 then
                                otherHRP.Velocity = Vector3.new(0, 200, 0)

                                local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                    humanoid.WalkSpeed = 0
                                    humanoid.JumpPower = 0
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
})

mainTab:AddToggle({
    Name = "Wall Hack",
    Default = false,
    Flag = "toggleWallHack",
    Callback = function(Value)
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character:FindFirstChild("Humanoid")
            if Value then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            else
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

mainTab:AddToggle({
    Name = "Invisibility",
    Default = false,
    Flag = "toggleIvisibility",
    Callback = function(Value)
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = Value and 1 or 0
                end
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.RootPart.CanCollide = not Value
            end
        end
    end
})

-- Player Tab
local playerTab = window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://10709811261"
})

playerTab:AddSection({
    Name = "Player 1"
})

playerTab:AddButton({
    Name = "Reset Player",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
        end
    end
})

playerTab:AddButton({
    Name = "Clear Inventory",
    Callback = function()
        if player.Backpack then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                tool:Destroy()
            end
        end
    end
})

playerTab:AddSection({
    Name = "for player"
})

playerTab:AddToggle({
    Name = "Enable Speed",
    Default = false,
    Flag = "toggleSpeed",
    Callback = function(Value)
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value and 50 or 16
        end
    end
})

playerTab:AddToggle({
    Name = "Enable Jump",
    Default = false,
    Flag = "toggleJump",
    Callback = function(Value)
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character.Humanoid.JumpPower = Value and 100 or 50
        end
    end
})

playerTab:AddSection({
    Name = "wall hack"
})

playerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        if Value then
            _G.InfiniteJump = UserInputService.JumpRequest:Connect(function()
                if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if _G.InfiniteJump then
                _G.InfiniteJump:Disconnect()
                _G.InfiniteJump = nil
            end
        end
    end
})

playerTab:AddSection({ 
   Name = "Name player"
})

playerTab:AddTextBox({
    Name = "Enter Name",
    Default = "",
    PlaceholderText = "Type your name",
    ClearText = true,
    Callback = function(Value)
        if player and player.Character then
            game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("/name " .. Value, "All")
        end
    end
})

-- Teleport Tab
local teleportTab = window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://10709811261"
})

teleportTab:AddSection({
    Name = "teleport to players...!"
})

local selectedPlayer = nil

teleportTab:AddDropdown({
    Name = "Select Player",
    Options = {},
    Default = nil,
    Callback = function(Value)
        selectedPlayer = Value
    end
})

teleportTab:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        if selectedPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
})

teleportTab:AddSection({
    Name = "teleport to home players"
})

local selectedHome = nil
local homes = {
    ["House 1"] = Vector3.new(100, 5, 200),
    ["House 2"] = Vector3.new(300, 5, 400),
    ["House 3"] = Vector3.new(500, 5, 600)
}

teleportTab:AddDropdown({
    Name = "Select Home",
    Options = getTableKeys(homes),
    Default = nil,
    Callback = function(Value)
        selectedHome = Value
    end
})

teleportTab:AddButton({
    Name = "Teleport to Home",
    Callback = function()
        if selectedHome and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = homes[selectedHome]
            if targetPosition then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            end
        end
    end
})

-- Update player list periodically
local function updatePlayerList()
    local playerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(playerNames, p.Name)
        end
    end
    teleportTab:UpdateDropdown("Select Player", playerNames, true)
end

spawn(function()
    while wait(5) do
        updatePlayerList()
    end
end)

-- Save settings when GUI closes
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "redz Library V5" then
        window:SaveConfig()
    end
end)
