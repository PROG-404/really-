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

       local messageText = Instance.new("TextLabel")
       messageText.Size = UDim2.new(1, -20, 0, 60)
       messageText.Position = UDim2.new(0, 10, 0, 20)
       messageText.BackgroundTransparency = 1
       messageText.TextColor3 = window.Theme.Text
       messageText.TextSize = 16
       messageText.Font = Enum.Font.GothamMedium
       messageText.Text = "Are you sure you want to close this window?"
       messageText.TextWrapped = true
       messageText.Parent = confirmDialog

       local function CreateConfirmButton(text, position, color)
           local button = Instance.new("TextButton")
           button.Size = UDim2.new(0.4, 0, 0, 35)
           button.Position = position
           button.BackgroundColor3 = color
           button.TextColor3 = window.Theme.Text
           button.TextSize = 14
           button.Font = Enum.Font.GothamBold
           button.Text = text
           button.Parent = confirmDialog

           local buttonCorner = Instance.new("UICorner")
           buttonCorner.CornerRadius = UDim.new(0, 6)
           buttonCorner.Parent = button

           return button
       end

       local yesButton = CreateConfirmButton("Yes", UDim2.new(0.1, 0, 1, -50), Color3.fromRGB(255, 0, 0))
       local noButton = CreateConfirmButton("No", UDim2.new(0.5, 0, 1, -50), Color3.fromRGB(0, 170, 0))

       local function enableButtons()
           closeButton.AutoButtonColor = true
           minimizeButton.AutoButtonColor = true
           moveButton.AutoButtonColor = true
       end

       yesButton.MouseButton1Click:Connect(function()
           enableButtons()
           TweenService:Create(mainWindow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
           task.wait(0.3)
           mainWindow:Destroy()
       end)

       noButton.MouseButton1Click:Connect(function()
           enableButtons()
           TweenService:Create(dimFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
           TweenService:Create(mainWindow, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
           TweenService:Create(confirmDialog, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
           task.wait(0.3)
           dimFrame:Destroy()
           confirmDialog:Destroy()
       end)
   end

   local dragging = false
   local dragInput
   local dragStart
   local startPos

   local function updateDrag(input)
       if dragging then
           local delta = input.Position - dragStart
           mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
       end
   end

   titleBar.InputBegan:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 then
           dragging = true
           dragStart = input.Position
           startPos = mainWindow.Position
       end
   end)

   local moveMode = false

   moveButton.MouseButton1Click:Connect(function()
       moveMode = not moveMode
       if moveMode then
           moveButton.BackgroundColor3 = window.Theme.Accent
       else
           moveButton.BackgroundColor3 = window.Theme.Buttons.Move
       end
   end)

   UserInputService.InputChanged:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseMovement then
           if dragging then
               updateDrag(input)
           end
           if moveMode and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
               updateDrag(input)
           end
       end
   end)

   UserInputService.InputEnded:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 then
           dragging = false
       end
   end)

   closeButton.MouseButton1Click:Connect(function()
       window:CreateConfirmDialog()
   end)

   local minimized = false
   local originalSize = window.size
   
   minimizeButton.MouseButton1Click:Connect(function()
       minimized = not minimized
       local newSize = minimized and UDim2.new(window.size.X.Scale, window.size.X.Offset, 0, 30) or originalSize
       CreateTween(mainWindow, {Size = newSize}, 0.3):Play()
       minimizeButton.Text = minimized and "+" or "-"
   end)

   table.insert(self.windows, window)
   self.currentWindow = window

   return window
end

function Library:AddButton(window, text, callback)
   local button = Instance.new("TextButton")
   button.Size = UDim2.new(1, -20, 0, 35)
   button.Position = UDim2.new(0, 10, 0, #window.content:GetChildren() * 45)
   button.BackgroundColor3 = window.Theme.Buttons.Minimize
   button.TextColor3 = window.Theme.Text
   button.TextSize = 14
   button.Font = Enum.Font.GothamMedium
   button.Text = text
   button.Parent = window.content

   local buttonCorner = Instance.new("UICorner")
   buttonCorner.CornerRadius = UDim.new(0, 6)
   buttonCorner.Parent = button

   button.MouseButton1Click:Connect(callback)
   return button
end

return Library
