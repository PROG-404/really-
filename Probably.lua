-- FrontLip Library
local FrontLip = {
   Windows = {},
   Flags = {},
   Theme = {
       Background = Color3.fromRGB(25, 25, 25),
       Foreground = Color3.fromRGB(35, 35, 35), 
       Accent = Color3.fromRGB(0, 170, 255),
       Text = Color3.fromRGB(255, 255, 255),
       DarkText = Color3.fromRGB(175, 175, 175),
       InputBackground = Color3.fromRGB(45, 45, 45)
   }
}
FrontLip.__index = FrontLip

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function FrontLip.new()
   local self = setmetatable({
       windows = {},
       currentWindow = nil,
       screenGui = Instance.new("ScreenGui")
   }, FrontLip)
   
   self.screenGui.Name = "FrontLip"
   self.screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
   
   return self
end

function FrontLip:CreateWindow(config)
   config = config or {}
   local window = {
       title = config.title or "FrontLip Window",
       size = config.size or UDim2.new(0, 300, 0, 200),
       position = config.position or UDim2.new(0.5, -150, 0.5, -100),
       minSize = config.minSize or Vector2.new(200, 150),
       maxSize = config.maxSize or Vector2.new(800, 600)
   }

   -- Main Window Frame
   local mainWindow = Instance.new("Frame")
   mainWindow.Name = "MainWindow"
   mainWindow.Size = window.size
   mainWindow.Position = window.position
   mainWindow.BackgroundColor3 = self.Theme.Background
   mainWindow.BackgroundTransparency = 0.1
   mainWindow.BorderSizePixel = 0
   mainWindow.Active = true
   mainWindow.Parent = self.screenGui
   window.main = mainWindow

   -- Window Corner Rounding
   local mainCorner = Instance.new("UICorner")
   mainCorner.CornerRadius = UDim.new(0, 8)
   mainCorner.Parent = mainWindow

   -- Title Bar
   local titleBar = Instance.new("Frame")
   titleBar.Name = "TitleBar"
   titleBar.Size = UDim2.new(1, 0, 0, 30)
   titleBar.BackgroundColor3 = self.Theme.Foreground
   titleBar.BackgroundTransparency = 0.1
   titleBar.BorderSizePixel = 0
   titleBar.Parent = mainWindow

   -- Add Separator Line
   local separatorLine = Instance.new("Frame")
   separatorLine.Name = "SeparatorLine"
   separatorLine.Size = UDim2.new(1, 0, 0, 1)
   separatorLine.Position = UDim2.new(0, 0, 1, 0)
   separatorLine.BackgroundColor3 = self.Theme.Accent
   separatorLine.BorderSizePixel = 0
   separatorLine.Parent = titleBar

   -- Title Text
   local titleText = Instance.new("TextLabel")
   titleText.Size = UDim2.new(1, -60, 1, 0)
   titleText.Position = UDim2.new(0, 10, 0, 0)
   titleText.BackgroundTransparency = 1
   titleText.TextColor3 = self.Theme.Text
   titleText.TextSize = 14
   titleText.Font = Enum.Font.GothamBold
   titleText.Text = window.title
   titleText.TextXAlignment = Enum.TextXAlignment.Left
   titleText.Parent = titleBar

   -- Control Buttons
   local closeButton = Instance.new("TextButton")
   closeButton.Size = UDim2.new(0, 30, 0, 30)
   closeButton.Position = UDim2.new(1, -30, 0, 0)
   closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
   closeButton.Text = "X"
   closeButton.TextColor3 = self.Theme.Text
   closeButton.TextSize = 14
   closeButton.Font = Enum.Font.GothamBold
   closeButton.Parent = titleBar

   local minimizeButton = Instance.new("TextButton")
   minimizeButton.Size = UDim2.new(0, 30, 0, 30)
   minimizeButton.Position = UDim2.new(1, -60, 0, 0)
   minimizeButton.BackgroundColor3 = self.Theme.InputBackground
   minimizeButton.Text = "-"
   minimizeButton.TextColor3 = self.Theme.Text
   minimizeButton.TextSize = 14
   minimizeButton.Font = Enum.Font.GothamBold
   minimizeButton.Parent = titleBar

   -- Window Content Frame
   local contentFrame = Instance.new("Frame")
   contentFrame.Name = "Content"
   contentFrame.Size = UDim2.new(1, 0, 1, -30)
   contentFrame.Position = UDim2.new(0, 0, 0, 30)
   contentFrame.BackgroundTransparency = 1
   contentFrame.Parent = mainWindow
   window.content = contentFrame

   -- Window Dragging
   local dragging = false
   local dragStart = nil
   local startPos = nil

   titleBar.InputBegan:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 then
           dragging = true
           dragStart = input.Position
           startPos = mainWindow.Position
       end
   end)

   UserInputService.InputChanged:Connect(function(input)
       if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
           local delta = input.Position - dragStart
           mainWindow.Position = UDim2.new(
               startPos.X.Scale,
               startPos.X.Offset + delta.X,
               startPos.Y.Scale,
               startPos.Y.Offset + delta.Y
           )
       end
   end)

   UserInputService.InputEnded:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 then
           dragging = false
       end
   end)

   -- Minimize/Close Functions
   local originalSize = window.size
   local minimized = false

   minimizeButton.MouseButton1Click:Connect(function()
       minimized = not minimized
       local targetSize = minimized and UDim2.new(window.size.X.Scale, window.size.X.Offset, 0, 30) or originalSize
       
       local tween = TweenService:Create(mainWindow, 
           TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
           {Size = targetSize}
       )
       tween:Play()
       
       minimizeButton.Text = minimized and "+" or "-"
   end)

   closeButton.MouseButton1Click:Connect(function()
       local tween = TweenService:Create(mainWindow,
           TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
           {BackgroundTransparency = 1}
       )
       tween:Play()
       tween.Completed:Connect(function()
           mainWindow:Destroy()
       end)
   end)

   table.insert(self.windows, window)
   self.currentWindow = window

   return window
end

return FrontLip
