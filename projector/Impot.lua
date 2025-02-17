local ScreenGui = Instance.new("ScreenGui")
local ToggleFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local Dots = {}
local dotTargets = {}

-- تعيين الواجهة للاعب
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- تصميم الإطار
ToggleFrame.Name = "ToggleFrame"
ToggleFrame.Parent = ScreenGui
ToggleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleFrame.BackgroundTransparency = 0
ToggleFrame.Position = UDim2.new(0.5, -50, 0, 5)
ToggleFrame.Size = UDim2.new(0, 100, 0, 30)

-- إضافة النقاط البيضاء
for i = 1, 5 do
   local dot = Instance.new("Frame")
   dot.Name = "Dot"..i
   dot.Parent = ToggleFrame
   dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
   dot.Size = UDim2.new(0, 2, 0, 2)
   dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
   table.insert(Dots, dot)
   
   -- تهيئة أهداف النقاط
   dotTargets[i] = {
       x = math.random(),
       y = math.random()
   }
end

-- تصميم الزر
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ToggleFrame
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = "FRONT"
ToggleButton.TextSize = 16
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

-- وظائف حركة النقاط
local function getNewTarget()
   return {
       x = math.random(),
       y = math.random()
   }
end

local function moveDots()
   while wait(0.016) do -- حوالي 60 FPS
       for index, dot in ipairs(Dots) do
           local currentX = dot.Position.X.Scale
           local currentY = dot.Position.Y.Scale
           local target = dotTargets[index]
           
           -- حساب المسافة للهدف
           local distanceX = math.abs(currentX - target.x)
           local distanceY = math.abs(currentY - target.y)
           
           -- إذا وصلت النقطة قريباً من هدفها، نحدد هدفاً جديداً
           if distanceX < 0.01 and distanceY < 0.01 then
               dotTargets[index] = getNewTarget()
               target = dotTargets[index]
           end
           
           -- حركة سلسة وبطيئة
           local newX = currentX + (target.x - currentX) * 0.02
           local newY = currentY + (target.y - currentY) * 0.02
           
           dot.Position = UDim2.new(newX, 0, newY, 0)
       end
   end
end
coroutine.wrap(moveDots)()


-- وظيفة لجعل الشخصية تنظر إلى اللاعب
local function lookAtPlayer(targetPlayer)
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local targetCharacter = targetPlayer.Character
    if not targetCharacter then return end
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRootPart then return end
    
    -- حساب الاتجاه للاعب المستهدف
    local direction = (targetRootPart.Position - rootPart.Position).Unit
    local lookAt = CFrame.new(rootPart.Position, targetRootPart.Position)
    
    -- تغيير اتجاه الشخصية
    rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(
        targetRootPart.Position.X,
        rootPart.Position.Y,
        targetRootPart.Position.Z
    ))
end

-- تعديل وظيفة التبديل
local toggled = false
local currentTarget = nil -- لتخزين اللاعب الحالي

ToggleButton.MouseButton1Click:Connect(function()
    toggled = not toggled
    if toggled then
        ToggleButton.Text = "Ace ON"
        -- بدء البحث والنظر إلى أقرب لاعب
        spawn(function()
            while toggled do
                local nearestPlayer = findNearestPlayer()
                if nearestPlayer then
                    -- تحديث الهدف فقط إذا كان هناك لاعب جديد أقرب
                    if nearestPlayer ~= currentTarget then
                        currentTarget = nearestPlayer
                    end
                    -- النظر إلى اللاعب المستهدف
                    if currentTarget then
                        lookAtPlayer(currentTarget)
                    end
                end
                wait(1) -- انتظار ثانية قبل البحث مرة أخرى
            end
        end)
    else
        ToggleButton.Text = "Ace OFF"
        currentTarget = nil -- إعادة تعيين الهدف عند الإيقاف
    end
end)
