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

-- إعدادات Aimbot
local Settings = {
    Enabled = false,
    TeamCheck = false,
    TargetPart = "Head",
    MaxDistance = 1000
}

-- وظيفة العثور على أقرب لاعب
local function getClosestPlayer()
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local closestPlayer = nil
    local shortestDistance = Settings.MaxDistance
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if not Settings.TeamCheck or player.Team ~= localPlayer.Team then
                local playerCharacter = player.Character
                if playerCharacter then
                    local targetPart = playerCharacter:FindFirstChild(Settings.TargetPart)
                    if targetPart then
                        local distance = (rootPart.Position - targetPart.Position).Magnitude
                        if distance < shortestDistance then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- وظيفة Aimbot
local function aimbot()
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    local targetPlayer = getClosestPlayer()
    if targetPlayer and targetPlayer.Character then
        local targetPart = targetPlayer.Character:FindFirstChild(Settings.TargetPart)
        if targetPart then
            humanoid.AutoRotate = false
            
            local targetPos = targetPart.Position
            local characterPos = rootPart.Position
            
            rootPart.CFrame = CFrame.new(characterPos, Vector3.new(
                targetPos.X,
                characterPos.Y,
                targetPos.Z
            ))
        end
    end
end

-- تفعيل/تعطيل Aimbot
ToggleButton.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    ToggleButton.Text = Settings.Enabled and "Ace ON" or "Ace OFF"
    
    -- إعادة تفعيل AutoRotate عند إيقاف Aimbot
    if not Settings.Enabled then
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
        end
    end
end)

-- تشغيل Aimbot
RunService.RenderStepped:Connect(function()
    if Settings.Enabled then
        aimbot()
    end
end)
