local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()
-- servers
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService") 
local VirtualInputManager = game:GetService("VirtualInputManager")
-- wait for child
local Map = workspace:WaitForChild("Map")
-- run service
local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
local Stepped = RunService.Stepped

-- التحقق من أن السكربت يعمل فقط على لعبة Brookhaven
if game.PlaceId ~= 4924922222 then
    game.Players.LocalPlayer:Kick("This script only works in Brookhaven!")
    return
end

-- إنشاء النافذة
local window = redzlib:MakeWindow({
    Name = "Brookhaven", 
    SubTitle = "by FRONT DARK",
    SaveFolder = "FRONT_REDZ.js"
})

-- إضافة تبويب Discord
local discordTab = window:MakeTab({
    Name = "Discord",
    Icon = "rbxassetid://10709811261"
})

discordTab:AddDiscordInvite({
    Name = "Join Our Discord",
    Logo = "rbxassetid://10709811261", 
    Invite = "https://discord.gg/vr7"
})

-- إضافة تبويب Main
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
        local ui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")

        if ui then
            for _, gui in pairs(ui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    if Value == "Small" then
                        gui.Enabled = true
                        gui:SetAttribute("UIScale", 0.8)
                    elseif Value == "Very Small" then
                        gui.Enabled = true
                        gui:SetAttribute("UIScale", 0.6)
                    elseif Value == "Large" then
                        gui.Enabled = true
                        gui:SetAttribute("UIScale", 1.2)
                    elseif Value == "Very Large" then
                        gui.Enabled = true
                        gui:SetAttribute("UIScale", 1.5)
                    end
                end
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
        -- تفعيل سكربت الطيران
        loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\40\39\104\116\116\112\115\58\47\47\103\105\115\116\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\109\101\111\122\111\110\101\89\84\47\98\102\48\51\57\100\102\102\57\102\48\97\55\48\48\49\57\56\57\48\55\52\101\98\51\99\53\100\50\47\97\114\99\101\117\115\37\50\53\50\48\120\37\50\53\50\48\102\108\121\37\50\53\50\48\50\37\50\53\50\48\111\98\102\108\117\99\97\116\111\114\39\41\44\116\114\117\101\41\41\40\41\10\10")()
    end
})



mainTab:AddSection({
    Name = "game pro "
})

mainTab:AddButton({
    Name = "Remove Fog",
    Desc = "Removes fog and improves render distance",
    Callback = function()
        local lighting = game:GetService("Lighting")

        lighting.FogStart = 0
        lighting.FogEnd = 1e6
        lighting.Brightness = 5
        lighting.GlobalShadows = false

        local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            atmosphere.Density = 0
            atmosphere.Haze = 0
            atmosphere.Glare = 0
        end

        local sky = lighting:FindFirstChildOfClass("Sky")
        if sky then
            sky.SkyboxUp = ""
            sky.SkyboxDn = ""
            sky.SkyboxFt = ""
            sky.SkyboxBk = ""
            sky.SkyboxLf = ""
            sky.SkyboxRt = ""
        end

        local bloom = lighting:FindFirstChildOfClass("BloomEffect")
        if bloom then
            bloom.Intensity = 0
        end
    end
})

mainTab:AddButton({
    Name = "Set to 60 FPS",
    Desc = "Sets the frame rate to 60 FPS",
    Callback = function()
        game:GetService("Players").LocalPlayer:SetAttribute("FrameRateLimit", 60)
    end
})

mainTab:AddButton({
    Name = "Set to 120 FPS",
    Desc = "Sets the frame rate to 120 FPS",
    Callback = function()
        game:GetService("Players").LocalPlayer:SetAttribute("FrameRateLimit", 120)
    end
})

mainTab:AddButton({
    Name = "Set to Normal Graphics",
    Desc = "Sets the graphics quality to normal",
    Callback = function()
        UserSettings():GetService("UserGameSettings")
    end
})

mainTab:AddButton({
    Name = "Set to High Graphics",
    Desc = "Sets the graphics quality to high",
    Callback = function()
        game:GetService("Settings"):SetQualityLevel(10) 
        print("Graphics set to high quality")
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
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character

            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart

                game:GetService("RunService").Stepped:Connect(function()
                    for _, otherPlayer in pairs(game:GetService("Players"):GetPlayers()) do
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
        local player = game:GetService("Players").LocalPlayer
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
        local player = game:GetService("Players").LocalPlayer
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



-- إضافة تبويب Player
local playerTab = window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://10709811261"
})

-- إضافة قسم Player 1
playerTab:AddSection({ Name = "Player 1" })

-- زر إعادة تعيين اللاعب
playerTab:AddButton({
    Name = "Reset Player",
    Desc = "Respawn the player",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character then
            player.Character:BreakJoints()
        end
    end
})

-- زر إزالة العناصر من الحقيبة
playerTab:AddButton({
    Name = "Clear Inventory",
    Desc = "Removes all tools from inventory",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Backpack then
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
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            humanoid.WalkSpeed = Value and 50 or 16 -- السرعة العادية 16، والسرعة المفعلة 50
        end
    end
})


playerTab:AddToggle({
    Name = "Enable Jump",
    Default = false,
    Flag = "toggleJump",
    Callback = function(Value)
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            humanoid.JumpPower = Value and 100 or 50 -- القفز العادي 50، والمُعزز 100
        end
    end
})

playerTab:AddSection({
    Name = "wall hack"
})

playerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "toggleInfiniteJump",
    Callback = function(Value)
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character

        if Value then
            _G.InfiniteJump = UserInputService.JumpRequest:Connect(function()
                if character and character:FindFirstChildOfClass("Humanoid") then
                    character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
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


-- إضافة قسم تغيير اسم اللاعب
playerTab:AddSection({ 
   Name = "Name player"
})

playerTab:AddTextBox({
    Name = "Enter Name",
    Default = "",
    PlaceholderText = "Type your name",
    ClearText = true,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local args = {
                [1] = "setname",
                [2] = Value
            }
            game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("/name " .. Value, "All")
        end
    end
})

-- زر تطبيق الاسم
playerTab:AddButton({
    Name = "Set Name",
    Desc = "Apply new display name",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player then
            local enteredName = playerTab:GetFlag("Enter Name")
            game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("/name " .. enteredName, "All")
        end
    end
})

local teleportTab = window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://123456789" -- icons 
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


local function updatePlayerList()
    local players = game:GetService("Players"):GetPlayers()
    local playerNames = {}

    for _, player in ipairs(players) do
        if player ~= game:GetService("Players").LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end

    tab:UpdateDropdown("Select Player", playerNames)
end


task.spawn(function()
    while wait(5) do
        updatePlayerList()
    end
end)


teleportTab:AddButton({
    Name = "Teleport to Player",
    Desc = "Teleports instantly to the selected player",
    Callback = function()
        local localPlayer = game:GetService("Players").LocalPlayer
        local character = localPlayer.Character

        if selectedPlayer and character and character:FindFirstChild("HumanoidRootPart") then
            local targetPlayer = game:GetService("Players"):FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
})

teleportTab:AddSection({
    Name = "teleport to home players"
})

local selectedHome = nil
local selectedPlayer2 = nil

-- قائمة البيوت المتاحة
local homes = {
    ["House 1"] = Vector3.new(100, 5, 200),
    ["House 2"] = Vector3.new(300, 5, 400),
    ["House 3"] = Vector3.new(500, 5, 600)
}

-- قائمة اختيار المنزل
teleportTab:AddDropdown({
    Name = "Select Home",
    Options = table.keys(homes),
    Default = nil,
    Callback = function(Value)
        selectedHome = Value
    end
})

-- قائمة اختيار اللاعب
teleportTab:AddDropdown({
    Name = "Home Players",
    Options = {},
    Default = nil,
    Callback = function(Value)
        selectedPlayer2 = Value
    end
})

-- تحديث قائمة اللاعبين
local function updatePlayerList()
    local players = game:GetService("Players"):GetPlayers()
    local playerNames = {}

    for _, player in ipairs(players) do
        if player ~= game:GetService("Players").LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end

    teleportTab:UpdateDropdown("Select Player", playerNames)
end


task.spawn(function()
    while wait(5) do
        updatePlayerList()
    end
end)

-- زر الانتقال إلى المنزل المختار أو منزل اللاعب
teleportTab:AddButton({
    Name = "Teleport to Home",
    Desc = "Teleports to the selected home or player's home",
    Callback = function()
        local localPlayer = game:GetService("Players").LocalPlayer
        local character = localPlayer.Character

        if character and character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = nil

            if selectedHome and homes[selectedHome] then
                targetPosition = homes[selectedHome]
            elseif selectedPlayer then
                local targetPlayer = game:GetService("Players"):FindFirstChild(selectedPlayer)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                end
            end

            if targetPosition then
                character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            end
        end
    end
})


game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "redz Library V5" then
        SaveSettings()
        print("The script has been closed")
    end
end)
