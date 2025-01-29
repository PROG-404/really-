local Library = {
   windows = {},
   initialized = false,
   version = "1.0.0"
}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
           TabSelected = Color3.fromRGB(0, 170, 255),
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

   -- Title Bar
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

   -- Control Buttons
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

   -- Window Controls
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

   UserInputService.InputChanged:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseMovement then
           dragInput = input
           if dragging then
               updateDrag(input)
           end
       end
   end)

   UserInputService.InputEnded:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 then
           dragging = false
       end
   end)

   -- Tab System
   function window:CreateTabSystem()
       local tabList = Instance.new("Frame")
       tabList.Name = "TabList"
       tabList.Size = UDim2.new(0, 150, 1, 0)
       tabList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
       tabList.BorderSizePixel = 0
       tabList.Parent = contentFrame

       local contentArea = Instance.new("Frame")
       contentArea.Name = "ContentArea"
       contentArea.Size = UDim2.new(1, -150, 1, 0)
       contentArea.Position = UDim2.new(0, 150, 0, 0)
       contentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
       contentArea.BorderSizePixel = 0
       contentArea.Parent = contentFrame

       local tabs = {}
       local selectedTab = nil

       function window:AddTab(name, imageId)
           local tabButton = Instance.new("Frame")
           tabButton.Size = UDim2.new(1, 0, 0, 40)
           tabButton.Position = UDim2.new(0, 0, 0, #tabs * 40)
           tabButton.BackgroundTransparency = 1
           tabButton.Parent = tabList

           local icon = Instance.new("ImageLabel")
           icon.Size = UDim2.new(0, 20, 0, 20)
           icon.Position = UDim2.new(0, 10, 0.5, -10)
           icon.BackgroundTransparency = 1
           icon.Image = imageId or "rbxassetid://3926307971"
           icon.Parent = tabButton

           local text = Instance.new("TextLabel")
           text.Size = UDim2.new(1, -40, 1, 0)
           text.Position = UDim2.new(0, 40, 0, 0)
           text.BackgroundTransparency = 1
           text.Text = name
           text.TextColor3 = window.Theme.Text
           text.TextSize = 14
           text.Font = Enum.Font.GothamMedium
           text.TextXAlignment = Enum.TextXAlignment.Left
           text.Parent = tabButton

           local selectLine = Instance.new("Frame")
           selectLine.Size = UDim2.new(1, 0, 0, 2)
           selectLine.Position = UDim2.new(0, 0, 1, -2)
           selectLine.BackgroundColor3 = window.Theme.TabSelected
           selectLine.BorderSizePixel = 0
           selectLine.Visible = false
           selectLine.Parent = tabButton

           local tabContent = Instance.new("Frame")
           tabContent.Size = UDim2.new(1, 0, 1, 0)
           tabContent.BackgroundTransparency = 1
           tabContent.Visible = false
           tabContent.Parent = contentArea

           local button = Instance.new("TextButton")
           button.Size = UDim2.new(1, 0, 1, 0)
           button.BackgroundTransparency = 1
           button.Text = ""
           button.Parent = tabButton

           local tab = {
               button = button,
               content = tabContent,
               selectLine = selectLine
           }

           button.MouseButton1Click:Connect(function()
               if selectedTab then
                   selectedTab.content.Visible = false
                   selectedTab.selectLine.Visible = false
               end
               selectedTab = tab
               tab.content.Visible = true
               tab.selectLine.Visible = true
           end)

           if #tabs == 0 then
               selectedTab = tab
               tab.content.Visible = true
               tab.selectLine.Visible = true
           end

           table.insert(tabs, tab)
           return tabContent
       end

       return window
   end

   return window
end

-- Button Creation
function Library:AddButton(container, text, callback)
   local button = Instance.new("TextButton")
   button.Size = UDim2.new(1, -20, 0, 35)
   button.Position = UDim2.new(0, 10, 0, #container:GetChildren() * 45)
   button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
   button.TextColor3 = Color3.fromRGB(255, 255, 255)
   button.TextSize = 14
   button.Font = Enum.Font.GothamMedium
   button.Text = text
   button.Parent = container

   local buttonCorner = Instance.new("UICorner")
   buttonCorner.CornerRadius = UDim.new(0, 6)
   buttonCorner.Parent = button

   button.MouseButton1Click:Connect(callback)
   return button
end

return Library
