local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- إنشاء الواجهة
local ScreenGui = Instance.new("ScreenGui")
local ToggleFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ToggleButton = Instance.new("TextButton")

-- تعيين الواجهة
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- تصميم الإطار
ToggleFrame.Name = "ToggleFrame"
ToggleFrame.Parent = ScreenGui
ToggleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleFrame.BackgroundTransparency = 0
ToggleFrame.Position = UDim2.new(0.5, -75, 0, 5)
ToggleFrame.Size = UDim2.new(0, 150, 0, 40)

UICorner.CornerRadius = UDim.new(0.5, 0)
UICorner.Parent = ToggleFrame

-- إضافة النقاط الدائرية الثابتة
local numDots = 8
local radius = 15
local centerX = 75
local centerY = 20

for i = 1, numDots do
    local angle = (i - 1) * (2 * math.pi / numDots)
    local x = centerX + radius * math.cos(angle)
    local y = centerY + radius * math.sin(angle)
    
    local dot = Instance.new("Frame")
    local dotCorner = Instance.new("UICorner")
    
    dot.Name = "Dot"..i
    dot.Parent = ToggleFrame
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BackgroundTransparency = 0.5
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0, x, 0, y)
    
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
end

-- تصميم الزر
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ToggleFrame
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = "Ace OFF"
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold

-- تأثير الألوان المتحركة
local function updateColors()
    while wait() do
        for i = 0, 1, 0.005 do
            ToggleButton.TextColor3 = Color3.fromHSV(i, 1, 1)
            wait(0.05)
        end
    end
end
coroutine.wrap(updateColors)()


Module.Hooking = (function()
    if _ENV.rz_AimBot then
        return _ENV.rz_AimBot
    end
    
    local module = {}
    _ENV.rz_AimBot = module
    
    local Enabled = _ENV.rz_EnabledOptions;
    local IsAlive = Module.IsAlive;
    
    local NextEnemy = nil;
    local NextTarget = nil;
    local UpdateDebounce = 0;
    local TargetDebounce = 0;
    
    local GetPlayers = Players.GetPlayers
    local GetChildren = Enemies.GetChildren
    local Skills = ToDictionary({"Z", "X", "C", "V", "F"})
    
    local function CanAttack(player)
        return player.Team and (player.Team.Name == "Pirates" or player.Team ~= Player.Team)
    end
    
    local function GetNextTarget(Mode)
        if (tick() - TargetDebounce) < 2.5 then
            return NextEnemy
        end
        
        if (Mode and _ENV[Mode]) then
            return NextTarget
        end
    end
    
    local function UpdateTarget()
        if (tick() - UpdateDebounce) < 0.5 then
            return nil
        end
        
        local PrimaryPart = Player.Character and Player.Character.PrimaryPart
        
        if not PrimaryPart then
            return nil
        end
        
        local Position = PrimaryPart.Position
        local Players = Players:GetPlayers()
        local Enemies = Enemies:GetChildren()
        
        local Distance, Nearest = 750
        
        if #Players > 1 then
            for _, player in ipairs(Players) do
                if player ~= Player and CanAttack(player) and IsAlive(player.Character) then
                    local UpperTorso = player.Character:FindFirstChild("UpperTorso")
                    local Magnitude = UpperTorso and (UpperTorso.Position - Position).Magnitude
                    
                    if UpperTorso and Magnitude < Distance then
                        Distance, Nearest = Magnitude, UpperTorso
                    end
                end
            end
        end
        if #Enemies > 0 and not Settings.NoAimMobs then
            for _, Enemy in ipairs(Enemies) do
                local UpperTorso = Enemy:FindFirstChild("UpperTorso")
                if UpperTorso and IsAlive(Enemy) then
                    local Magnitude = (UpperTorso.Position - Position).Magnitude
                    if Magnitude < Distance then
                        Distance, Nearest = Magnitude, UpperTorso
                    end
                end
            end
        end
        
        NextTarget, UpdateDebounce = Nearest, tick()
    end
    
    function module:SpeedBypass()
        if _ENV._Enabled_Speed_Bypass then
            return nil
        end
        
        _ENV._Enabled_Speed_Bypass = true
        
        local oldHook;
        oldHook = hookmetamethod(Player, "__newindex", function(self, index, value)
            if self.Name == "Humanoid" and index == "WalkSpeed" then
                return oldHook(self, index, _ENV.WalkSpeedBypass or value)
            end
            return oldHook(self, index, value)
        end)
    end
    
    function module:SetTarget(Part)
        TargetDebounce, NextEnemy = tick(), Part.Parent:FindFirstChild("UpperTorso") or Part
    end
    
    Stepped:Connect(UpdateTarget)
    
    local old_namecall; old_namecall = _ENV.original_namecall or hookmetamethod(game, "__namecall", function(self, ...)
        local Method = string.lower(getnamecallmethod())
        
        if Method ~= "fireserver" then
            return old_namecall(self, ...)
        end
        
        local Name = self.Name
        
        if Name == "RE/ShootGunEvent" then
            local Position, Enemies = ...
            
            if typeof(Position) == "Vector3" and type(Enemies) == "table" then
                local Target = GetNextTarget("AimBot_Gun")
                
                if Target then
                    if Target.Name == "UpperTorso" then
                        table.insert(Enemies, Target)
                    end
                    
                    Position = Target.Position
                end
                
                return old_namecall(self, Position, Enemies)
            end
        elseif Name == "RemoteEvent" and self.Parent.ClassName == "Tool" then
            local v1, v2 = ...
            
            if typeof(v1) == "Vector3" and not v2 then
                local Target = GetNextTarget("AimBot_Skills")
                
                if Target then
                    return old_namecall(self, Target.Position)
                end
            elseif v1 == "TAP" and typeof(v2) == "Vector3" then
                local Target = GetNextTarget("AimBot_Tap")
                
                if Target then
                    return old_namecall(self, "TAP", Target.Position)
                end
            end
        end
        
        return old_namecall(self, ...)
    end)
    
    _ENV.original_namecall = old_namecall
    return module
end)()
