local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Check game
if game.PlaceId ~= 4924922222 then
   player:Kick("This script only works in Brookhaven!")
   return
end

-- Helper Functions
local function notify(title, text, duration)
   redzlib:MakeNotification({
       Name = title,
       Content = text,
       Time = duration or 5
   })
end

-- Safety Checks
local function isAlive()
   return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getTorso()
   return player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
end

-- Enhanced Flying Function
local FLYING = false
local flySpeed = 50
local flyKeys = {
   W = false,
   A = false,
   S = false,
   D = false,
   Space = false,
   LeftShift = false
}

local function startFly()
   if not isAlive() then return end
   
   local torso = getTorso()
   local gyro = Instance.new("BodyGyro")
   local velocity = Instance.new("BodyVelocity")
   
   gyro.P = 9e4
   gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
   gyro.CFrame = torso.CFrame
   
   velocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   velocity.Velocity = Vector3.new(0, 0.1, 0)
   
   gyro.Parent = torso
   velocity.Parent = torso
   
   FLYING = true
   
   RunService:BindToRenderStep("Fly", 15, function()
       if not isAlive() or not FLYING then
           RunService:UnbindFromRenderStep("Fly")
           gyro:Destroy()
           velocity:Destroy()
           return
       end
       
       local cf = workspace.CurrentCamera.CoordinateFrame
       local direction = Vector3.new()
       
       if flyKeys.W then direction = direction + cf.LookVector end
       if flyKeys.S then direction = direction - cf.LookVector end
       if flyKeys.A then direction = direction - cf.RightVector end
       if flyKeys.D then direction = direction + cf.RightVector end
       if flyKeys.Space then direction = direction + cf.UpVector end
       if flyKeys.LeftShift then direction = direction - cf.UpVector end
       
       if direction.Magnitude > 0 then
           direction = direction.Unit
       end
       
       velocity.Velocity = direction * flySpeed
       gyro.CFrame = cf
   end)
end

local function stopFly()
   FLYING = false
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

-- UI Size Section
mainTab:AddSection({
   Name = "UI size"
})

local function updateUIScale(scale)
   for _, gui in ipairs(player.PlayerGui:GetChildren()) do
       if gui:IsA("ScreenGui") then
           local uiScale = gui:FindFirstChild("UIScale") or Instance.new("UIScale")
           uiScale.Scale = scale
           uiScale.Parent = gui
       end
   end
end

mainTab:AddDropdown({
   Name = "UI Size",
   Options = {"Small", "Very Small", "Large", "Very Large"},
   Default = "Small",
   Callback = function(Value)
       local scales = {
           Small = 0.8,
           ["Very Small"] = 0.6,
           Large = 1.2,
           ["Very Large"] = 1.5
       }
       updateUIScale(scales[Value])
   end
})

-- Fly Section
mainTab:AddSection({
   Name = "Fly"
})

mainTab:AddToggle({
   Name = "Toggle Fly",
   Default = false,
   Callback = function(Value)
       if Value then
           startFly()
           notify("Flight", "Flying enabled", 2)
       else
           stopFly()
           notify("Flight", "Flying disabled", 2)
       end
   end
})

mainTab:AddSlider({
   Name = "Fly Speed",
   Min = 10,
   Max = 200,
   Default = 50,
   Color = Color3.fromRGB(255, 255, 255),
   Increment = 1,
   Callback = function(Value)
       flySpeed = Value
   end    
})

-- Graphics Section
mainTab:AddSection({
   Name = "Graphics"
})

mainTab:AddButton({
   Name = "Remove Fog",
   Callback = function()
       local lighting = game:GetService("Lighting")
       lighting.FogStart = 0
       lighting.FogEnd = 9e9
       lighting.Brightness = 2
       
       for _, v in pairs(lighting:GetChildren()) do
           if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
               v:Destroy()
           end
       end
       notify("Graphics", "Fog removed", 2)
   end
})

-- Player Features Section
mainTab:AddSection({
   Name = "Player Features"
})

-- Launch Nearby Players
local launchingPlayers = false
mainTab:AddToggle({
   Name = "Launch Nearby Players",
   Default = false,
   Callback = function(Value)
       launchingPlayers = Value
       
       if Value then
           RunService:BindToRenderStep("LaunchPlayers", 1, function()
               if not isAlive() then return end
               
               for _, otherPlayer in pairs(Players:GetPlayers()) do
                   if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                       local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                       
                       if distance <= 10 then
                           otherPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 200, 0)
                           if otherPlayer.Character:FindFirstChild("Humanoid") then
                               otherPlayer.Character.Humanoid.WalkSpeed = 0
                               otherPlayer.Character.Humanoid.JumpPower = 0
                           end
                       end
                   end
               end
           end)
       else
           RunService:UnbindFromRenderStep("LaunchPlayers")
       end
   end
})

-- Invisibility
mainTab:AddToggle({
   Name = "Invisibility",
   Default = false,
   Callback = function(Value)
       if not isAlive() then return end
       
       for _, part in pairs(player.Character:GetDescendants()) do
           if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart") then
               part.Transparency = Value and 1 or 0
           end
       end
       
       -- Keep HumanoidRootPart solid for collisions
       if player.Character:FindFirstChild("HumanoidRootPart") then
           player.Character.HumanoidRootPart.Transparency = 1
       end
   end
})

-- Noclip (Wall Hack)
local noclip = false
local function updateNoclip()
   if noclip then
       RunService:BindToRenderStep("Noclip", 0, function()
           if not isAlive() then return end
           for _, part in pairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.CanCollide = false
               end
           end
       end)
   else
       RunService:UnbindFromRenderStep("Noclip")
       if isAlive() then
           for _, part in pairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.CanCollide = true
               end
           end
       end
   end
end

mainTab:AddToggle({
   Name = "Wall Hack",
   Default = false,
   Callback = function(Value)
       noclip = Value
       updateNoclip()
   end
})

-- Player Tab
local playerTab = window:MakeTab({
   Name = "Player",
   Icon = "rbxassetid://10709811261"
})

-- Speed and Jump Controls
playerTab:AddToggle({
   Name = "Enable Speed",
   Default = false,
   Callback = function(Value)
       if isAlive() then
           player.Character.Humanoid.WalkSpeed = Value and 50 or 16
       end
   end
})

playerTab:AddToggle({
   Name = "Enable Jump",
   Default = false,
   Callback = function(Value)
       if isAlive() then
           player.Character.Humanoid.JumpPower = Value and 100 or 50
       end
   end
})

-- Name Changer Section
playerTab:AddSection({
   Name = "Name Changer"
})

playerTab:AddTextBox({
   Name = "Change Name",
   Default = "",
   PlaceholderText = "Enter new name",
   ClearText = true,
   Callback = function(Value)
       if Value ~= "" then
           game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("/name " .. Value, "All")
           notify("Name Change", "Attempted to change name to: " .. Value, 2)
       end
   end
})

playerTab:AddButton({
   Name = "Reset Character",
   Callback = function()
       if isAlive() then
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

-- Teleport Tab
local teleportTab = window:MakeTab({
   Name = "Teleport",
   Icon = "rbxassetid://10709811261"
})

local selectedPlayer = nil

-- Player Teleport
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
       if not selectedPlayer then
           notify("Teleport", "Please select a player first", 2)
           return
       end
       
       local targetPlayer = Players:FindFirstChild(selectedPlayer)
       if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
           player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
           notify("Teleport", "Teleported to " .. selectedPlayer, 2)
       end
   end
})

-- Home Teleport
local homes = {
   ["House 1"] = Vector3.new(100, 5, 200),
   ["House 2"] = Vector3.new(300, 5, 400),
   ["House 3"] = Vector3.new(500, 5, 600),
   ["Main Area"] = Vector3.new(0, 5, 0)
}

teleportTab:AddDropdown({
   Name = "Select Location",
   Options = {"House 1", "House 2", "House 3", "Main Area"},
   Default = nil,
   Callback = function(Value)
       if homes[Value] and isAlive() then
           player.Character.HumanoidRootPart.CFrame = CFrame.new(homes[Value])
           notify("Teleport", "Teleported to " .. Value, 2)
       end
   end
})

-- Update player list
local function updatePlayerList()
   local playerList = {}
   for _, p in pairs(Players:GetPlayers()) do
       if p ~= player then
           table.insert(playerList, p.Name)
       end
   end
   teleportTab:UpdateDropdown("Select Player", playerList, true)
end

spawn(function()
   while wait(5) do
       updatePlayerList()
   end
end)

-- Input Handler for Flying
UserInputService.InputBegan:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   
   if input.KeyCode == Enum.KeyCode.W then
       flyKeys.W = true
   elseif input.KeyCode == Enum.KeyCode.A then
       flyKeys.A = true
   elseif input.KeyCode == Enum.KeyCode.S then
       flyKeys.S = true
   elseif input.KeyCode == Enum.KeyCode.D then
       flyKeys.D = true
   elseif input.KeyCode == Enum.KeyCode.Space then
       flyKeys.Space = true
   elseif input.KeyCode == Enum.KeyCode.LeftShift then
       flyKeys.LeftShift = true
   end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   
   if input.KeyCode == Enum.KeyCode.W then
       flyKeys.W = false
   elseif input.KeyCode == Enum.KeyCode.A then
       flyKeys.A = false
   elseif input.KeyCode == Enum.KeyCode.S then
       flyKeys.S = false
   elseif input.KeyCode == Enum.KeyCode.D then
       flyKeys.D = false
   elseif input.KeyCode == Enum.KeyCode.Space then
       flyKeys.Space = false
   elseif input.KeyCode == Enum.KeyCode.LeftShift then
       flyKeys.LeftShift = false
   end
end)

-- Anti-Kick Protection
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
   local method = getnamecallmethod()
   local args = {...}
   
   if method == "Kick" then
       return wait(9e9)
   end
   
   return oldNamecall(self, ...)
end)

-- Character Added Connections
player.CharacterAdded:Connect(function()
   wait(1)
   if noclip then
       updateNoclip()
   end
end)

notify("Script", "Successfully loaded!", 3)
