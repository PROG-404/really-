local Library = {
   windows = {},
   initialized = false,
   version = "1.0.0"
}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function Lerp(a, b, t)
   return a + (b - a) * t
end

local function CreateTween(instance, props, duration)
   local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
   local tween = TweenService:Create(instance, tweenInfo, props)
   return tween
end

function Library.new()
   local self = setmetatable({
       windows = {},
       currentWindow = nil,
       screenGui = Instance.new("ScreenGui")
   }, Library)
   
   self.screenGui.Name = "FrontLib"
   self.screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
   
   return self
end

function Library:CreateWindow(config)
   config = config or {}
   local window = {
       title = config.title or "Window",
       size = config.size or UDim2.new(0, 500, 0, 350),
       position = config.position or UDim2.new(0.5, -250, 0.5, -175),
       Theme = {
           Background = Color3.fromRGB(25, 25, 25),
           Foreground = Color3.fromRGB(30, 30, 30),
           Accent = Color3.fromRGB(0, 170, 255),
           Text = Color3.fromRGB(255, 255, 255),
           TabBackground = Color3.fromRGB(20, 20, 20),
           Buttons = {
               Close = Color3.fromRGB(25, 25, 25),
               Minimize = Color3.fromRGB(25, 25, 25),
               Move = Color3.fromRGB(25, 25, 25)
           }
       }
   }

   local mainWindow = Instance.new("Frame")
   mainWindow.Name = "MainWindow"
   mainWindow.Size = window.size
   mainWindow.Position = window.position
   mainWindow.BackgroundColor3 = window.Theme.Background
   mainWindow.BackgroundTransparency = 0.1
   mainWindow.BorderSizePixel = 0
   mainWindow.Active = true
   mainWindow.Parent = self.screenGui
   window.main = mainWindow

   local mainCorner = Instance.new("UICorner")
   mainCorner.CornerRadius = UDim.new(0, 8)
   mainCorner.Parent = mainWindow

   local titleBar = Instance.new("Frame")
   titleBar.Name = "TitleBar"
   titleBar.Size = UDim2.new(1, 0, 0, 30)
   titleBar.BackgroundColor3 = window.Theme.Foreground
   titleBar.BackgroundTransparency = 0.1
   titleBar.BorderSizePixel = 0
   titleBar.Parent = mainWindow

   local titleCorner = Instance.new("UICorner")
   titleCorner.CornerRadius = UDim.new(0, 8)
   titleCorner.Parent = titleBar

   local titleText = Instance.new("TextLabel")
   titleText.Size = UDim2.new(1, -60, 1, 0)
   titleText.Position = UDim2.new(0, 10, 0, 0)
   titleText.BackgroundTransparency = 1
   titleText.TextColor3 = window.Theme.Text
   titleText.TextSize = 14
   titleText.Font = Enum.Font.GothamSemibold
   titleText.Text = window.title
   titleText.TextXAlignment = Enum.TextXAlignment.Left
   titleText.Parent = titleBar

   local controlButtons = Instance.new("Frame")
   controlButtons.Name = "ControlButtons"
   controlButtons.Size = UDim2.new(0, 90, 1, 0)
   controlButtons.Position = UDim2.new(1, -90, 0, 0)
   controlButtons.BackgroundTransparency = 1
   controlButtons.Parent = titleBar

   local function CreateButton(name, position, color, text)
       local button = Instance.new("TextButton")
       button.Name = name
       button.Size = UDim2.new(0, 30, 0, 30)
       button.Position = position
       button.BackgroundColor3 = color
       button.BackgroundTransparency = 0.1
       button.TextColor3 = window.Theme.Text
       button.TextSize = 14
       button.Font = Enum.Font.GothamBold
       button.Text = text
       button.Parent = controlButtons

       local buttonCorner = Instance.new("UICorner")
       buttonCorner.CornerRadius = UDim.new(0, 6)
       buttonCorner.Parent = button

       return button
   end


   local moveButton = CreateButton("Move", UDim2.new(0, 0, 0, 0), window.Theme.Buttons.Move, "%")
   local minimizeButton = CreateButton("Minimize", UDim2.new(0.5, -15, 0, 0), window.Theme.Buttons.Minimize, "-")
   local closeButton = CreateButton("Close", UDim2.new(1, -30, 0, 0), window.Theme.Buttons.Close, "X")

   local contentFrame = Instance.new("Frame")
   contentFrame.Name = "Content"
   contentFrame.Size = UDim2.new(1, 0, 1, -30)
   contentFrame.Position = UDim2.new(0, 0, 0, 30)
   contentFrame.BackgroundTransparency = 1
   contentFrame.Parent = mainWindow
   window.content = contentFrame

   function window:CreateTabSystem()
       local tabContainer = Instance.new("Frame")
       tabContainer.Name = "TabContainer"
       tabContainer.Size = UDim2.new(0, 150, 1, 0)
       tabContainer.BackgroundColor3 = window.Theme.TabBackground
       tabContainer.BorderSizePixel = 0
       tabContainer.Parent = contentFrame

       local tabContentContainer = Instance.new("Frame")
       tabContentContainer.Name = "TabContentContainer"
       tabContentContainer.Size = UDim2.new(1, -150, 1, 0)
       tabContentContainer.Position = UDim2.new(0, 150, 0, 0)
       tabContentContainer.BackgroundTransparency = 1
       tabContentContainer.Parent = contentFrame


      function window:CreateConfirmDialog()
       local dimFrame = Instance.new("Frame")
       dimFrame.Size = UDim2.new(1, 0, 1, 0)
       dimFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
       dimFrame.BackgroundTransparency = 1
       dimFrame.Parent = mainWindow

       closeButton.AutoButtonColor = false
       minimizeButton.AutoButtonColor = false
       moveButton.AutoButtonColor = false

       local blocker = Instance.new("TextButton")
       blocker.Size = UDim2.new(1, 0, 1, 0)
       blocker.BackgroundTransparency = 1
       blocker.Text = ""
       blocker.Parent = dimFrame

       TweenService:Create(dimFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
       TweenService:Create(mainWindow, TweenInfo.new(0.3), {BackgroundTransparency = 0.4}):Play()

       local confirmDialog = Instance.new("Frame")
       confirmDialog.Name = "ConfirmDialog"
       confirmDialog.Size = UDim2.new(0, 250, 0, 150)
       confirmDialog.Position = UDim2.new(0.5, -125, 0.5, -75)
       confirmDialog.BackgroundColor3 = window.Theme.Background
       confirmDialog.BackgroundTransparency = 0
       confirmDialog.BorderSizePixel = 0
       confirmDialog.Parent = mainWindow

       local dialogCorner = Instance.new("UICorner")
       dialogCorner.CornerRadius = UDim.new(0, 8)
       dialogCorner.Parent = confirmDialog

       return window
   end

   local dragging = false
   local dragInput
   local dragStart
   local startPos

   titleBar.InputBegan:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 then
           dragging = true
           dragStart = input.Position
           startPos = mainWindow.Position
       end
   end)

   UserInputService.InputEnded:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 then
           dragging = false
       end
   end)

   return window
end

return Library
