-- إعداد المتغيرات والخدمات الأساسية
local AceAimbot = {
    Config = {
        Enabled = false,
        Target = {
            Players = true,
            NPCs = true,
            MaxDistance = 750,
            PreferredPart = "UpperTorso",
            FallbackParts = {"HumanoidRootPart", "Head"},
            TargetUpdateRate = 0.3,
            TargetRetentionTime = 2.5
        },
        UI = {
            Visible = true,
            Rainbow = false, -- تم تعطيل خاصية الألوان المتغيرة
            Position = UDim2.new(0.5, -75, 0, 5),
            Size = UDim2.new(0, 150, 0, 40),
            Dots = 6, -- تم تقليل عدد النقاط لتحسين الأداء
            DotsRadius = 15
        },
        Features = {
            AimAssist = true,
            TriggerBot = false,
            SpeedBypass = false,
            WalkSpeed = 16,
            SilentAim = true,
            AutoBuso = true     -- تفعيل هاكي تلقائياً
        },
        BusoCheckInterval = 3,  -- تم زيادة الفاصل الزمني للتحقق إلى 3 ثوانٍ
        KeyBinds = {
            Toggle = Enum.KeyCode.RightAlt,
            TargetSwitch = Enum.KeyCode.Tab
        }
    },
    Services = {},
    Cache = {
        NextEnemy = nil,
        NextTarget = nil,
        UpdateTimestamp = 0,
        TargetTimestamp = 0,
        HookCache = {},
        ClosestParts = {},
        LastBusoCheck = 0
    },
    UI = {},
    Hooks = {}
}

-- تهيئة الخدمات
AceAimbot.Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    ContextActionService = game:GetService("ContextActionService")
}

local Player = AceAimbot.Services.Players.LocalPlayer
local Stepped = AceAimbot.Services.RunService.Stepped
local Enemies = workspace:FindFirstChild("Enemies") or Instance.new("Folder", workspace)
Enemies.Name = "Enemies"

-- وظائف مساعدة
AceAimbot.Utils = {
    IsAlive = function(character)
        if not character then return false end
        local humanoid = character:FindFirstChild("Humanoid")
        return humanoid and humanoid.Health > 0
    end,
    
    GetTargetPart = function(model)
        if not model then return nil end
        
        local targetPart = model:FindFirstChild(AceAimbot.Config.Target.PreferredPart)
        if targetPart then return targetPart end
        
        for _, partName in ipairs(AceAimbot.Config.Target.FallbackParts) do
            local part = model:FindFirstChild(partName)
            if part then return part end
        end
        
        return nil
    end,
    
    CanTarget = function(player)
        if player == Player then return false end
        return player.Team and (player.Team.Name == "Pirates" or player.Team ~= Player.Team)
    end,
    
    ToDictionary = function(array)
        local dict = {}
        for _, v in ipairs(array) do
            dict[v] = true
        end
        return dict
    end,
    
    CreateTween = function(object, info, properties)
        local tween = AceAimbot.Services.TweenService:Create(object, info, properties)
        return tween
    end,
    
    -- إطلاق الحدث البعيد
    FireRemote = function(remoteName, ...)
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteName, true)
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        end
    end
}

-- إعداد واجهة المستخدم
AceAimbot.SetupUI = function()
    -- إنشاء الواجهة الرئيسية
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AceAimbotGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleFrame.BackgroundTransparency = 0.2
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Position = AceAimbot.Config.UI.Position
    toggleFrame.Size = AceAimbot.Config.UI.Size
    toggleFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0.5, 0)
    uiCorner.Parent = toggleFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 255, 255)
    uiStroke.Transparency = 0.7
    uiStroke.Thickness = 1.5
    uiStroke.Parent = toggleFrame
    
    -- إضافة النقاط الدائرية الثابتة
    local numDots = AceAimbot.Config.UI.Dots
    local radius = AceAimbot.Config.UI.DotsRadius
    local centerX = toggleFrame.Size.X.Offset / 2
    local centerY = toggleFrame.Size.Y.Offset / 2

    for i = 1, numDots do
        local angle = (i - 1) * (2 * math.pi / numDots)
        local x = centerX + radius * math.cos(angle)
        local y = centerY + radius * math.sin(angle)
        
        local dot = Instance.new("Frame")
        dot.Name = "Dot" .. i
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BackgroundTransparency = 0.5
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0, x - 2, 0, y - 2)
        dot.Parent = toggleFrame
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
    end
    
    -- إضافة زر التبديل
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.BackgroundTransparency = 1
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Text = "Ace OFF"
    toggleButton.TextSize = 18
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    toggleButton.Parent = toggleFrame
    
    -- إضافة قائمة الحالة
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 0, 1, 5)
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.TextSize = 14
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextStrokeTransparency = 0.7
    statusLabel.Text = "Target: None"
    statusLabel.Visible = false
    statusLabel.Parent = toggleFrame
    
    -- تعيين الواجهة للاعب
    screenGui.Parent = Player:WaitForChild("PlayerGui")
    
    -- تخزين مراجع واجهة المستخدم
    AceAimbot.UI = {
        ScreenGui = screenGui,
        ToggleFrame = toggleFrame,
        ToggleButton = toggleButton,
        StatusLabel = statusLabel,
        UIStroke = uiStroke
    }
    
    -- إعداد وظائف واجهة المستخدم
    toggleButton.MouseButton1Click:Connect(function()
        AceAimbot.Config.Enabled = not AceAimbot.Config.Enabled
        AceAimbot.UpdateUI()
    end)
    
    -- إعداد السحب والإفلات
    local isDragging = false
    local dragInput
    local dragStart
    local startPos
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = toggleFrame.Position
        end
    end)
    
    toggleFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    AceAimbot.Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    AceAimbot.Services.RunService.RenderStepped:Connect(function()
        if isDragging and dragInput and dragStart then
            local delta = dragInput.Position - dragStart
            toggleFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- تم إزالة كود تأثير ألوان قوس قزح
end

-- تحديث واجهة المستخدم
AceAimbot.UpdateUI = function()
    if not AceAimbot.UI.ToggleButton then return end
    
    AceAimbot.UI.ToggleButton.Text = AceAimbot.Config.Enabled and "Ace ON" or "Ace OFF"
    local targetColor = AceAimbot.Config.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    -- تطبيق اللون الثابت بدلاً من تأثير قوس قزح
    AceAimbot.UI.ToggleButton.TextColor3 = targetColor
    AceAimbot.UI.StatusLabel.Visible = AceAimbot.Config.Enabled
    
    -- تحديث حالة التأثير
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local strokeProperties = {
        Color = AceAimbot.Config.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100),
        Transparency = AceAimbot.Config.Enabled and 0.3 or 0.7
    }
    
    AceAimbot.Utils.CreateTween(AceAimbot.UI.UIStroke, tweenInfo, strokeProperties):Play()
end

-- وظيفة تفعيل هاكي
AceAimbot.EnableBuso = function()
    local character = Player.Character
    if AceAimbot.Config.Features.AutoBuso and 
       AceAimbot.Utils.IsAlive(character) and 
       not character:FindFirstChild("HasBuso") then
        -- استدعاء Remote Event للهاكي
        AceAimbot.Utils.FireRemote("Buso")
    end
end

-- نظام فحص هاكي - محسن للأداء
AceAimbot.StartBusoChecker = function()
    -- بدء دورة الفحص المستمر مع تحسين الأداء
    local busoThread = coroutine.create(function()
        while true do
            local currentTime = tick()
            if (currentTime - AceAimbot.Cache.LastBusoCheck) >= AceAimbot.Config.BusoCheckInterval then
                AceAimbot.EnableBuso()
                AceAimbot.Cache.LastBusoCheck = currentTime
            end
            wait(1) -- معدل فحص أقل لتوفير موارد المعالج
        end
    end)
    coroutine.resume(busoThread)
    
    -- استماع لأحداث إعادة إنشاء الشخصية
    Player.CharacterAdded:Connect(function(character)
        if AceAimbot.Config.Features.AutoBuso then
            -- محاولة تفعيل هاكي بعد التأكد من تحميل الشخصية
            character:WaitForChild("HumanoidRootPart")
            wait(1) -- انتظار لضمان تحميل الشخصية بالكامل
            AceAimbot.EnableBuso()
        end
    end)
    
    -- مراقبة إزالة هاكي - محسنة للأداء
    local function checkBusoStatus(character)
        if not character then return end
        local hasBuso = character:FindFirstChild("HasBuso")
        
        if hasBuso then
            hasBuso.AncestryChanged:Connect(function(_, parent)
                if parent == nil and AceAimbot.Config.Features.AutoBuso then
                    -- إعادة تفعيل هاكي بعد إزالته
                    wait(1)
                    AceAimbot.EnableBuso()
                end
            end)
        end
    end
    
    Player.CharacterAdded:Connect(checkBusoStatus)
    if Player.Character then
        checkBusoStatus(Player.Character)
    end
end

-- تحديث الهدف التالي - محسن للأداء
AceAimbot.UpdateTarget = function()
    if not AceAimbot.Config.Enabled then return end
    
    -- التحقق من وقت التحديث
    local currentTime = tick()
    if (currentTime - AceAimbot.Cache.UpdateTimestamp) < AceAimbot.Config.Target.TargetUpdateRate then
        return
    end
    
    -- التحقق من الشخصية
    local character = Player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local playerPosition = rootPart.Position
    local closestDistance = AceAimbot.Config.Target.MaxDistance
    local closestPart = nil
    
    -- البحث عن اللاعبين
    if AceAimbot.Config.Target.Players then
        for _, targetPlayer in ipairs(AceAimbot.Services.Players:GetPlayers()) do
            if targetPlayer ~= Player and AceAimbot.Utils.CanTarget(targetPlayer) then
                local targetChar = targetPlayer.Character
                if AceAimbot.Utils.IsAlive(targetChar) then
                    local targetPart = AceAimbot.Utils.GetTargetPart(targetChar)
                    if targetPart then
                        local distance = (targetPart.Position - playerPosition).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPart = targetPart
                            AceAimbot.Cache.ClosestParts[targetPlayer.Name] = targetPart
                        end
                    end
                end
            end
        end
    end
    
    -- البحث عن الكائنات غير اللاعبين
    if AceAimbot.Config.Target.NPCs then
        for _, npc in ipairs(Enemies:GetChildren()) do
            if AceAimbot.Utils.IsAlive(npc) then
                local targetPart = AceAimbot.Utils.GetTargetPart(npc)
                if targetPart then
                    local distance = (targetPart.Position - playerPosition).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPart = targetPart
                        AceAimbot.Cache.ClosestParts[npc.Name] = targetPart
                    end
                end
            end
        end
    end
    
    -- تحديث الهدف والطابع الزمني
    AceAimbot.Cache.NextTarget = closestPart
    AceAimbot.Cache.UpdateTimestamp = currentTime
    
    -- تحديث حالة UI
    if AceAimbot.UI.StatusLabel then
        local targetName = "None"
        if closestPart then
            local parent = closestPart.Parent
            targetName = parent and (parent:FindFirstChild("Name") and parent.Name.Value or parent.Name) or "Unknown"
            targetName = targetName .. " [" .. math.floor(closestDistance) .. "m]"
        end
        AceAimbot.UI.StatusLabel.Text = "Target: " .. targetName
    end
end

-- تعيين الهدف المخصص
AceAimbot.SetTarget = function(part)
    if not part then return end
    
    AceAimbot.Cache.NextEnemy = part
    AceAimbot.Cache.TargetTimestamp = tick()
    
    -- تحديث النص
    if AceAimbot.UI.StatusLabel then
        local parent = part.Parent
        local targetName = parent and (parent:FindFirstChild("Name") and parent.Name.Value or parent.Name) or "Custom"
        AceAimbot.UI.StatusLabel.Text = "Target: " .. targetName .. " [LOCKED]"
    end
end

-- الحصول على الهدف الحالي
AceAimbot.GetActiveTarget = function(mode)
    -- التحقق من الهدف المحدد يدوياً
    if (tick() - AceAimbot.Cache.TargetTimestamp) < AceAimbot.Config.Target.TargetRetentionTime then
        return AceAimbot.Cache.NextEnemy
    end
    
    -- العودة إلى الهدف التلقائي
    return AceAimbot.Cache.NextTarget
end

-- تعديل سرعة المشي
AceAimbot.SpeedBypass = function()
    if AceAimbot.Cache.HookCache.SpeedBypass then return end
    
    AceAimbot.Cache.HookCache.SpeedBypass = true
    
    local oldHook
    oldHook = hookmetamethod(game, "__newindex", function(self, index, value)
        if self.ClassName == "Humanoid" and index == "WalkSpeed" and AceAimbot.Config.Features.SpeedBypass then
            return oldHook(self, index, AceAimbot.Config.Features.WalkSpeed)
        end
        return oldHook(self, index, value)
    end)
end

-- إعداد الـ aimbot - محسن للأداء
AceAimbot.SetupAimbot = function()
    -- تتبع الهدف مع تحسين الأداء
    local skipFrames = 0
    Stepped:Connect(function()
        -- تخطي بعض الإطارات لتحسين الأداء
        skipFrames = skipFrames + 1
        if skipFrames < 2 then return end
        skipFrames = 0
        
        if AceAimbot.Config.Enabled then
            AceAimbot.UpdateTarget()
        end
    end)
    
    -- إعداد اختطاف الدوال البعيدة
    local oldNamecall = AceAimbot.Cache.HookCache.Namecall or hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- التحقق إذا كان Aimbot مفعل
        if not AceAimbot.Config.Enabled or not AceAimbot.Config.Features.SilentAim then
            return oldNamecall(self, ...)
        end
        
        -- معالجة FireServer للأسلحة
        if method == "FireServer" then
            local name = self.Name
            
            -- حدث إطلاق السلاح
            if name == "RE/ShootGunEvent" then
                local position, enemies = ...
                
                if typeof(position) == "Vector3" and type(enemies) == "table" then
                    local target = AceAimbot.GetActiveTarget("AimBot_Gun")
                    
                    if target then
                        if target.Name == AceAimbot.Config.Target.PreferredPart then
                            table.insert(enemies, target)
                        end
                        
                        -- تحديث موقع إطلاق النار
                        position = target.Position
                    end
                    
                    return oldNamecall(self, position, enemies)
                end
            -- حدث المهارات
            elseif name == "RemoteEvent" and self.Parent and self.Parent:IsA("Tool") then
                local v1, v2 = ...
                
                -- إطلاق مهارة بموقع
                if typeof(v1) == "Vector3" and not v2 then
                    local target = AceAimbot.GetActiveTarget("AimBot_Skills")
                    
                    if target then
                        return oldNamecall(self, target.Position)
                    end
                -- إطلاق مهارة TAP
                elseif v1 == "TAP" and typeof(v2) == "Vector3" then
                    local target = AceAimbot.GetActiveTarget("AimBot_Tap")
                    
                    if target then
                        return oldNamecall(self, "TAP", target.Position)
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    AceAimbot.Cache.HookCache.Namecall = oldNamecall
    
    -- إعداد اختصارات المفاتيح
    AceAimbot.Services.ContextActionService:BindAction("ToggleAceAimbot", function(_, state)
        if state == Enum.UserInputState.Begin then
            AceAimbot.Config.Enabled = not AceAimbot.Config.Enabled
            AceAimbot.UpdateUI()
        end
    end, false, AceAimbot.Config.KeyBinds.Toggle)
    
    -- تفعيل تعديل السرعة إذا كان مطلوباً
    if AceAimbot.Config.Features.SpeedBypass then
        AceAimbot.SpeedBypass()
    end
    
    -- بدء فاحص هاكي
    AceAimbot.StartBusoChecker()
end

-- وظيفة البدء
AceAimbot.Start = function()
    AceAimbot.SetupUI()
    AceAimbot.SetupAimbot()
    AceAimbot.UpdateUI()
    
    -- تفقد هاكي مباشرة للشخصية الحالية
    if Player.Character then
        AceAimbot.EnableBuso()
    end
    
    print("Ace Aimbot v2.0 - تم التشغيل بنجاح!")
end

-- بدء النظام
AceAimbot.Start()

return AceAimbot
