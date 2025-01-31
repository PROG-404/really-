local FRONT = {
    windows = {},
    version = "1.0.0",
    theme = {
        Background = Color3.fromRGB(25, 25, 25),
        Foreground = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        ButtonColor = Color3.fromRGB(40, 40, 40),
        ShadowColor = Color3.fromRGB(0, 0, 0),
        TabSelectedColor = Color3.fromRGB(0, 170, 255)
    }
}
FRONT.__index = FRONT

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Utility Functions
local function AddShadow(instance, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.ZIndex = instance.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = FRONT.theme.ShadowColor
    shadow.ImageTransparency = transparency or 0.5
    shadow.Parent = instance
    return shadow
end

local function CreateTween(instance, props, duration, style, dir)
    local tInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tInfo, props)
    return tween
end

local function AddRippleEffect(button)
    button.ClipsDescendants = true
    
    button.MouseButton1Down:Connect(function(x, y)
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.BorderSizePixel = 0
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.85
        ripple.ZIndex = button.ZIndex + 1
        ripple.Parent = button

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple

        local targetSize = UDim2.new(0, button.AbsoluteSize.X * 2, 0, button.AbsoluteSize.X * 2)
        local targetPos = UDim2.new(0.5, -button.AbsoluteSize.X, 0.5, -button.AbsoluteSize.X)
        
        CreateTween(ripple, {Size = targetSize, Position = targetPos}, 0.5):Play()
        CreateTween(ripple, {BackgroundTransparency = 1}, 0.5):Play()

        wait(0.5)
        ripple:Destroy()
    end)
end

function FRONT.new()
    local self = setmetatable({}, FRONT)
    
    -- Create ScreenGui with proper parent
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "FRONT_Library"
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to parent to CoreGui, fallback to PlayerGui
    local success, _ = pcall(function()
        self.gui.Parent = CoreGui
    end)
    
    if not success then
        self.gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return self
end
