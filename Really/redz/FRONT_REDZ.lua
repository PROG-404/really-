-- Window Creation
local window = redzlib:MakeWindow({
   Name = "Brookhaven Script+",
   SubTitle = "by FRONT DARK Enhanced",
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
   Name = "Main Features",
   Icon = "rbxassetid://10709811261"
})

-- UI Size Section
mainTab:AddSection({
   Name = "UI Size"
})

mainTab:AddDropdown({
   Name = "Script UI Size",
   Options = {"Small", "Very Small", "Large", "Very Large"},
   Default = "Small",
   Callback = function(Value)
       local scales = {
           Small = 0.8,
           ["Very Small"] = 0.6,
           Large = 1.2,
           ["Very Large"] = 1.5
       }
       updateScriptUIScale(scales[Value])
   end
})

mainTab:AddDropdown({
   Name = "Game UI Size",
   Options = {"Small", "Very Small", "Large", "Very Large"},
   Default = "Small",
   Callback = function(Value)
       local scales = {
           Small = 0.8,
           ["Very Small"] = 0.6,
           Large = 1.2,
           ["Very Large"] = 1.5
       }
       updateGameUIScale(scales[Value])
   end
})

-- Flying Section
mainTab:AddSection({
   Name = "Flying"
})

mainTab:AddButton({
   Name = "Load Arceus X Fly V2",
   Callback = function()
       loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\40\39\104\116\116\112\115\58\47\47\103\105\115\116\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\109\101\111\122\111\110\101\89\84\47\98\102\48\51\55\100\102\102\57\102\48\97\55\48\48\49\55\51\48\52\100\100\100\54\55\102\100\99\100\51\55\48\47\114\97\119\47\101\49\52\101\55\52\102\52\50\53\98\48\54\48\100\102\53\50\51\51\52\51\99\102\51\48\98\55\56\55\48\55\52\101\98\51\99\53\100\50\47\97\114\99\101\117\115\37\50\53\50\48\120\37\50\53\50\48\102\108\121\37\50\53\50\48\50\37\50\53\50\48\111\98\102\108\117\99\97\116\111\114\39\41\44\116\114\117\101\41\41\40\41\10\10")()
       notify("Flight", "Arceus X Fly V2 loaded", 2)
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

mainTab:AddToggle({
   Name = "Ghost Mode",
   Default = false,
   Callback = function(Value)
       if not isAlive() then return end
       local character = player.Character
       
       for _, part in pairs(character:GetDescendants()) do
           if part:IsA("BasePart") then
               part.CanCollide = not Value
               part.Transparency = Value and 0.5 or 0
           end
       end
       
       character.Humanoid.WalkSpeed = Value and 25 or 16
   end
})

mainTab:AddToggle({
   Name = "Freeze Nearby Players",
   Default = false,
   Callback = function(Value)
       while Value and wait() do
           if not isAlive() then continue() end
           
           for _, otherPlayer in pairs(Players:GetPlayers()) do
               if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                   local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                   
                   if distance <= 10 then
                       otherPlayer.Character.HumanoidRootPart.Anchored = true
                   else
                       otherPlayer.Character.HumanoidRootPart.Anchored = false
                   end
               end
           end
       end
   end
})

-- Water Walk
local waterWalk = false
mainTab:AddToggle({
   Name = "Water Walk",
   Default = false,
   Callback = function(Value)
       waterWalk = Value
       
       if Value then
           RunService:BindToRenderStep("WaterWalk", 1, function()
               if not isAlive() then return end
               
               local root = player.Character.HumanoidRootPart
               local ray = Ray.new(root.Position, Vector3.new(0, -4, 0))
               local part = workspace:FindPartOnRay(ray)
               
               if part and part.Material == Enum.Material.Water then
                   root.CFrame = CFrame.new(root.Position.X, part.Position.Y + 2, root.Position.Z)
               end
           end)
       else
           RunService:UnbindFromRenderStep("WaterWalk")
       end
   end
})

-- Character Scale
mainTab:AddSlider({
   Name = "Character Scale",
   Min = 0.5,
   Max = 3,
   Default = 1,
   Increment = 0.1,
   Callback = function(Value)
       if not isAlive() then return end
       
       local character = player.Character
       if character:FindFirstChild("Humanoid") then
           local bodyScale = character.Humanoid:FindFirstChild("BodyScale")
           if not bodyScale then
               bodyScale = Instance.new("BodyScale")
               bodyScale.Parent = character.Humanoid
           end
           bodyScale.Value = Value
           
           for _, part in pairs(character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.Size = part.Size * Value
               end
           end
       end
   end
})

-- Player Tab
local playerTab = window:MakeTab({
   Name = "Player",
   Icon = "rbxassetid://10709811261"
})

-- Movement Section
playerTab:AddSection({
   Name = "Movement"
})

playerTab:AddSlider({
   Name = "Walk Speed",
   Min = 16,
   Max = 500,
   Default = 16,
   Increment = 1,
   Callback = function(Value)
       if not isAlive() then return end
       player.Character.Humanoid.WalkSpeed = Value
   end
})

playerTab:AddSlider({
   Name = "Jump Power",
   Min = 50,
   Max = 500,
   Default = 50,
   Increment = 1,
   Callback = function(Value)
       if not isAlive() then return end
       player.Character.Humanoid.JumpPower = Value
   end
})

playerTab:AddToggle({
   Name = "Infinite Jump",
   Default = false,
   Callback = function(Value)
       getgenv().InfiniteJump = Value
       game:GetService("UserInputService").JumpRequest:connect(function()
           if getgenv().InfiniteJump then
               if isAlive() then
                   player.Character.Humanoid:ChangeState("Jumping")
               end
           end
       end)
   end
})

-- Animations Section
playerTab:AddSection({
   Name = "Animations"
})

playerTab:AddButton({
   Name = "Ninja Animation",
   Callback = function()
       if not isAlive() then return end
       local Animate = player.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=656117400"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=656118341"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=656121766"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=656118852"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=656114359"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
   end
})

playerTab:AddButton({
   Name = "Zombie Animation",
   Callback = function()
       if not isAlive() then return end
       local Animate = player.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616161997"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616156119"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616157476"
   end
})

-- Character Mods Section
playerTab:AddSection({
   Name = "Character Mods"
})

playerTab:AddToggle({
   Name = "No Clip",
   Default = false,
   Callback = function(Value)
       if not isAlive() then return end
       
       if Value then
           RunService:BindToRenderStep("NoClip", 0, function()
               if not isAlive() then return end
               for _, part in pairs(player.Character:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.CanCollide = false
                   end
               end
           end)
       else
           RunService:UnbindFromRenderStep("NoClip")
           if isAlive() then
               for _, part in pairs(player.Character:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.CanCollide = true
                   end
               end
           end
       end
   end
})

playerTab:AddToggle({
   Name = "Anti Ragdoll",
   Default = false,
   Callback = function(Value)
       getgenv().AntiRagdoll = Value
       while getgenv().AntiRagdoll and wait() do
           if isAlive() then
               for _, v in pairs(player.Character:GetDescendants()) do
                   if v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint") then
                       v:Destroy()
                   end
               end
           end
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

-- Visibility Section
playerTab:AddSection({
   Name = "Visibility"
})

playerTab:AddToggle({
   Name = "Invisible",
   Default = false,
   Callback = function(Value)
       if not isAlive() then return end
       
       local character = player.Character
       local transparencyValue = Value and 1 or 0
       
       for _, part in pairs(character:GetDescendants()) do
           if part:IsA("BasePart") or part:IsA("Decal") then
               if part.Name ~= "HumanoidRootPart" then
                   part.Transparency = transparencyValue
               end
           end
       end
   end
})

-- Combat Section
playerTab:AddSection({
   Name = "Combat"
})

playerTab:AddToggle({
   Name = "Anti Fling",
   Default = false,
   Callback = function(Value)
       if not isAlive() then return end
       
       if Value then
           player.Character.HumanoidRootPart.Anchored = true
       else
           player.Character.HumanoidRootPart.Anchored = false
       end
   end
})

playerTab:AddToggle({
   Name = "Auto Reset on Low Health",
   Default = false,
   Callback = function(Value)
       getgenv().AutoReset = Value
       while getgenv().AutoReset and wait() do
           if isAlive() and player.Character.Humanoid.Health <= 15 then
               player.Character:BreakJoints()
           end
       end
   end
})

-- Extra Features Section
playerTab:AddSection({
   Name = "Extra Features"
})

playerTab:AddToggle({
   Name = "Auto Sprint",
   Default = false,
   Callback = function(Value)
       getgenv().AutoSprint = Value
       while getgenv().AutoSprint and wait() do
           if isAlive() then
               local humanoid = player.Character.Humanoid
               if humanoid.MoveDirection.Magnitude > 0 then
                   humanoid.WalkSpeed = 25
               else
                   humanoid.WalkSpeed = 16
               end
           end
       end
   end
})

playerTab:AddButton({
   Name = "Remove Body Parts R15",
   Callback = function()
       if not isAlive() then return end
       
       local character = player.Character
       local humanoid = character.Humanoid
       
       if humanoid.RigType == Enum.HumanoidRigType.R15 then
           local parts = {
               "LeftLowerLeg",
               "LeftUpperLeg",
               "RightLowerLeg",
               "RightUpperLeg",
               "LeftFoot",
               "LeftUpperArm",
               "LeftLowerArm",
               "RightUpperArm",
               "RightLowerArm",
               "LeftHand",
               "RightHand",
               "RightFoot"
           }
           
           for _, partName in ipairs(parts) do
               local part = character:FindFirstChild(partName)
               if part then
                   part:Destroy()
               end
           end
           notify("Character", "R15 parts removed", 2)
       else
           notify("Error", "Character must be R15", 2)
       end
   end
})

playerTab:AddButton({
   Name = "Chat Spy",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/GisonSSS/Scripts/main/ChatSpy.lua", true))()
       notify("Chat", "Chat Spy enabled", 2)
   end
})

-- Camera Section
playerTab:AddSection({
   Name = "Camera"
})

playerTab:AddToggle({
   Name = "No Camera Shake",
   Default = false,
   Callback = function(Value)
       if Value then
           game:GetService("Players").LocalPlayer.PlayerScripts.CameraShake.Disabled = true
       else
           game:GetService("Players").LocalPlayer.PlayerScripts.CameraShake.Disabled = false
       end
   end
})

playerTab:AddSlider({
   Name = "Field of View",
   Min = 30,
   Max = 120,
   Default = 70,
   Increment = 1,
   Callback = function(Value)
       game:GetService("Workspace").CurrentCamera.FieldOfView = Value
   end
})

-- Anti Cheat Bypass Section
playerTab:AddSection({
   Name = "Anti Cheat"
})

playerTab:AddToggle({
   Name = "Anti AFK",
   Default = false,
   Callback = function(Value)
       if Value then
           local vu = game:GetService("VirtualUser")
           player.Idled:Connect(function()
               vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
               wait(1)
               vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
           end)
       end
   end
})

playerTab:AddToggle({
   Name = "Anti Ban",
   Default = false,
   Callback = function(Value)
       getgenv().AntiBan = Value
       while getgenv().AntiBan and wait() do
           for _, v in pairs(player.Character:GetDescendants()) do
               if v:IsA("BoolValue") and (v.Name:match("IsBanned") or v.Name:match("Banned")) then
                   v:Destroy()
               end
           end
       end
   end
})

-- Custom Animation Section
playerTab:AddSection({
   Name = "Custom Animations"
})

playerTab:AddButton({
   Name = "Astronaut Animation",
   Callback = function()
       if not isAlive() then return end
       local Animate = player.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=891621366"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=891633237"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=891667138"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=891636393"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=891627522"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=891609353"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=891617961"
   end
})

playerTab:AddButton({
   Name = "Superhero Animation",
   Callback = function()
       if not isAlive() then return end
       local Animate = player.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616111295"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616113536"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616122287"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616117076"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616115533"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616104706"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616108001"
   end
})

-- Character Modifications
playerTab:AddSection({
   Name = "Character Modifications"
})

playerTab:AddButton({
   Name = "Remove Accessories",
   Callback = function()
       if not isAlive() then return end
       for _, accessory in pairs(player.Character:GetChildren()) do
           if accessory:IsA("Accessory") then
               accessory:Destroy()
           end
       end
   end
})

playerTab:AddToggle({
   Name = "Anti Head Shot",
   Default = false,
   Callback = function(Value)
       if not isAlive() then return end
       
       if Value then
           local head = player.Character:FindFirstChild("Head")
           if head then
               head.CanCollide = false
               head.Transparency = 0.5
           end
       else
           local head = player.Character:FindFirstChild("Head")
           if head then
               head.CanCollide = true
               head.Transparency = 0
           end
       end
   end
})

-- Movement Enhancements
playerTab:AddSection({
   Name = "Movement Enhancements"
})

playerTab:AddToggle({
   Name = "Bunny Hop",
   Default = false,
   Callback = function(Value)
       getgenv().BunnyHop = Value
       while getgenv().BunnyHop and wait() do
           if isAlive() then
               local humanoid = player.Character.Humanoid
               if humanoid.MoveDirection.Magnitude > 0 then
                   humanoid.Jump = true
               end
           end
       end
   end
})

playerTab:AddToggle({
   Name = "Air Walk",
   Default = false,
   Callback = function(Value)
       if Value then
           local airPart = Instance.new("Part")
           airPart.Size = Vector3.new(7, 2, 3)
           airPart.Transparency = 0.5
           airPart.Anchored = true
           airPart.Name = "AirWalkPart"
           
           RunService:BindToRenderStep("AirWalk", 0, function()
               if isAlive() then
                   airPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
                   airPart.Parent = workspace
               end
           end)
       else
           RunService:UnbindFromRenderStep("AirWalk")
           local airPart = workspace:FindFirstChild("AirWalkPart")
           if airPart then
               airPart:Destroy()
           end
       end
   end
})

-- Visual Effects
playerTab:AddSection({
   Name = "Visual Effects"
})

playerTab:AddToggle({
   Name = "Rainbow Character",
   Default = false,
   Callback = function(Value)
       getgenv().RainbowCharacter = Value
       while getgenv().RainbowCharacter and wait() do
           if isAlive() then
               local hue = tick() % 5 / 5
               local color = Color3.fromHSV(hue, 1, 1)
               
               for _, part in pairs(player.Character:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.Color = color
                   end
               end
           end
       end
   end
})

playerTab:AddToggle({
   Name = "Trail Effect",
   Default = false,
   Callback = function(Value)
       if not isAlive() then return end
       
       local trail = player.Character.HumanoidRootPart:FindFirstChild("Trail")
       if Value then
           if not trail then
               trail = Instance.new("Trail")
               trail.Name = "Trail"
               trail.Attachment0 = Instance.new("Attachment", player.Character.HumanoidRootPart)
               trail.Attachment1 = Instance.new("Attachment", player.Character.HumanoidRootPart)
               trail.Attachment0.Position = Vector3.new(0, -1, 0)
               trail.Attachment1.Position = Vector3.new(0, 1, 0)
               trail.Parent = player.Character.HumanoidRootPart
           end
       else
           if trail then
               trail:Destroy()
           end
       end
   end
})

-- Protection Features
playerTab:AddSection({
   Name = "Protection Features"
})

playerTab:AddToggle({
   Name = "Anti Tool Kill",
   Default = false,
   Callback = function(Value)
       getgenv().AntiToolKill = Value
       while getgenv().AntiToolKill and wait() do
           if isAlive() then
               for _, tool in pairs(workspace:GetDescendants()) do
                   if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                       tool.Handle.Touched:Connect(function() end)
                   end
               end
           end
       end
   end
})

playerTab:AddToggle({
   Name = "Anti Void",
   Default = false,
   Callback = function(Value)
       if Value then
           local antiVoidPart = Instance.new("Part")
           antiVoidPart.Size = Vector3.new(1000, 1, 1000)
           antiVoidPart.Position = Vector3.new(0, -1000, 0)
           antiVoidPart.Anchored = true
           antiVoidPart.Transparency = 0.5
           antiVoidPart.Name = "AntiVoid"
           antiVoidPart.Parent = workspace
       else
           local antiVoid = workspace:FindFirstChild("AntiVoid")
           if antiVoid then
               antiVoid:Destroy()
           end
       end
   end
})



-- Teleport Tab
local teleportTab = window:MakeTab({
   Name = "Teleport",
   Icon = "rbxassetid://10709811261"
})

-- Player Teleport Section
teleportTab:AddSection({
   Name = "Player Teleporter"
})

-- Variables
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local selectedPlayer = nil

-- Function to get updated player list
local function getPlayerList()
   local playerList = {}
   for _, p in pairs(Players:GetPlayers()) do
       if p ~= player then
           table.insert(playerList, p.Name)
       end
   end
   return playerList
end

-- Function to update dropdown
local function updatePlayerDropdown()
   local playerDropdown = teleportTab:AddDropdown({
       Name = "Select Player",
       Options = getPlayerList(),
       Callback = function(Value)
           selectedPlayer = Value
           notify("Player Selected", "Selected: " .. Value, 2)
       end
   })
end

-- Add teleport button
teleportTab:AddButton({
   Name = "Teleport to Player",
   Callback = function()
       if selectedPlayer then
           local targetPlayer = Players:FindFirstChild(selectedPlayer)
           if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
               if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                   -- Smooth teleport
                   local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                   local success, error = pcall(function()
                       player.Character:SetPrimaryPartCFrame(targetCFrame)
                   end)
                   
                   if success then
                       notify("Teleport", "Successfully teleported to " .. selectedPlayer, 2)
                   else
                       notify("Error", "Failed to teleport: " .. error, 2)
                   end
               else
                   notify("Error", "Your character is not loaded", 2)
               end
           else
               notify("Error", "Selected player is not available", 2)
           end
       else
           notify("Error", "Please select a player first", 2)
       end
   end
})

-- Refresh player list button
teleportTab:AddButton({
   Name = "Refresh Player List",
   Callback = function()
       updatePlayerDropdown()
       notify("Refresh", "Player list updated", 2)
   end
})

-- Safe distance teleport toggle
teleportTab:AddToggle({
   Name = "Safe Distance Teleport",
   Default = true,
   Callback = function(Value)
       getgenv().SafeDistance = Value
   end
})

-- Initialize
updatePlayerDropdown()

-- Player Join/Leave Handler
Players.PlayerAdded:Connect(function()
   updatePlayerDropdown()
end)

Players.PlayerRemoving:Connect(function()
   updatePlayerDropdown()
end)
