-- UI Library
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Library = {}

-- نظام الألوان النهائي
Library.Colors = {
    Background = Color3.fromRGB(10, 10, 15),
    BackgroundSecondary = Color3.fromRGB(15, 15, 20),
    TitleBar = Color3.fromRGB(20, 20, 25),
    Border = Color3.fromRGB(50, 50, 60),
    Highlight = Color3.fromRGB(80, 80, 95),
    Accent = Color3.fromRGB(100, 120, 255),
    AccentDark = Color3.fromRGB(80, 100, 235),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(200, 200, 200)
}

-- تهيئة النافذة الرئيسية
function Library:CreateWindow(name)
    local window = {}
    
    -- إنشاء ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModernUI"
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- الإطار الرئيسي
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)  -- يبدأ صغيراً للحركة
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundColor3 = self.Colors.Background
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = gui
    
    -- زوايا مستديرة
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, -20, 0, 40)
    titleBar.Position = UDim2.new(0, 10, 0, 10)
    titleBar.BackgroundColor3 = self.Colors.TitleBar
    titleBar.BackgroundTransparency = 0.8
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    -- زوايا مستديرة للعنوان
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleBar
    
    -- نص العنوان
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -10, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = name or "Modern UI"
    titleText.TextColor3 = self.Colors.Text
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- زر الإغلاق
    local closeButton = Instance.new("ImageButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = self.Colors.Accent
    closeButton.BackgroundTransparency = 0.9
    closeButton.AutoButtonColor = false
    closeButton.Text = "X"
    closeButton.TextColor3 = self.Colors.Text
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    -- زوايا للزر
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- منطقة المحتوى
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 2
    contentFrame.ScrollBarImageColor3 = self.Colors.AccentDark
    contentFrame.Parent = mainFrame
    
    -- تنظيم المحتوى
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = contentFrame
    
    -- حركة فتح النافذة
    local function openAnimation()
        TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 340, 0, 440),
            Position = UDim2.new(0.5, -170, 0.5, -220),
            BackgroundTransparency = 0
        }):Play()
    end
    
    -- تأثير إغلاق النافذة
    local function closeAnimation()
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        tween.Completed:Connect(function()
            gui:Destroy()
        end)
        tween:Play()
    end
    
    -- تفعيل السحب
    local isDragging = false
    local dragInput
    local dragStart
    local startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            local delta = input.Position - dragStart
            TweenService:Create(mainFrame, TweenInfo.new(0.1), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    -- ربط الأزرار
    closeButton.MouseButton1Click:Connect(closeAnimation)
    
    -- بدء حركة الفتح
    openAnimation()
    
    -- تصدير الوظائف
    window.gui = gui
    window.mainFrame = mainFrame
    window.contentFrame = contentFrame
    window.closeAnimation = closeAnimation
    
    return window
end

return Library
