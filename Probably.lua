-- RedZLibrary.lua
local Library = {
    windows = {},
    initialized = false,
    version = "1.0.0"
}
Library.__index = Library

-- Utility Functions
local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function CreateTween(instance, props, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, props)
    return tween
end

-- Main Library Constructor
function Library.new()
    local self = setmetatable({
        windows = {},
        currentWindow = nil,
        screenGui = Instance.new("ScreenGui")
    }, Library)
    
    self.screenGui.Name = "RedZLibrary"
    self.screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    return self
end

-- Window Creation
function Library:CreateWindow(config)
    config = config or {}
    local window = {
        title = config.title or "Window",
        size = config.size or UDim2.new(0, 300, 0, 200),
        position = config.position or UDim2.new(0.5, -150, 0.5, -100),
        minSize = config.minSize or Vector2.new(200, 150),
        maxSize = config.maxSize or Vector2.new(800, 600),
        theme = config.theme or {
            background = Color3.fromRGB(25, 25, 25),
            foreground = Color3.fromRGB(30, 30, 30),
            accent = Color3.fromRGB(0, 170, 255),
            text = Color3.fromRGB(255, 255, 255),
            buttons = {
                close = Color3.fromRGB(255, 0, 0),
                minimize = Color3.fromRGB(50, 50, 50)
            }
        }
    }

    -- Main Window Frame
    local mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.Size = window.size
    mainWindow.Position = window.position
    mainWindow.BackgroundColor3 = window.theme.background
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
    titleBar.BackgroundColor3 = window.theme.foreground
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = window.theme.text
    titleText.TextSize = 14
    titleText.Font = Enum.Font.GothamSemibold
    titleText.Text = window.title
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Control Buttons Container
    local controlButtons = Instance.new("Frame")
    controlButtons.Name = "ControlButtons"
    controlButtons.Size = UDim2.new(0, 60, 1, 0)
    controlButtons.Position = UDim2.new(1, -60, 0, 0)
    controlButtons.BackgroundTransparency = 1
    controlButtons.Parent = titleBar

    -- Create Button Function
    local function CreateButton(name, position, color)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0, 30, 0, 30)
        button.Position = position
        button.BackgroundColor3 = color
        button.BackgroundTransparency = 0.1
        button.TextColor3 = window.theme.text
        button.TextSize = 14
        button.Font = Enum.Font.GothamBold
        button.Parent = controlButtons

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        return button
    end

    -- Close and Minimize Buttons
    local closeButton = CreateButton("Close", UDim2.new(1, -30, 0, 0), window.theme.buttons.close)
    closeButton.Text = "X"
    
    local minimizeButton = CreateButton("Minimize", UDim2.new(0, 0, 0, 0), window.theme.buttons.minimize)
    minimizeButton.Text = "-"

    -- Content Container
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainWindow
    window.content = contentFrame

    -- Confirmation Dialog
    function window:CreateConfirmDialog()
        local dimFrame = Instance.new("Frame")
        dimFrame.Size = UDim2.new(1, 0, 1, 0)
        dimFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        dimFrame.BackgroundTransparency = 0
        dimFrame.Parent = mainWindow

        CreateTween(dimFrame, {BackgroundTransparency = 0.5}, 0.3):Play()
        CreateTween(mainWindow, {BackgroundTransparency = 0.4}, 0.3):Play()

        local confirmDialog = Instance.new("Frame")
        confirmDialog.Name = "ConfirmDialog"
        confirmDialog.Size = UDim2.new(0, 250, 0, 150)
        confirmDialog.Position = UDim2.new(0.5, -125, 0.5, -75)
        confirmDialog.BackgroundColor3 = window.theme.background
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
        messageText.TextColor3 = window.theme.text
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
            button.TextColor3 = window.theme.text
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

        yesButton.MouseButton1Click:Connect(function()
            CreateTween(mainWindow, {BackgroundTransparency = 1}, 0.3):Play()
            task.wait(0.3)
            mainWindow:Destroy()
        end)

        noButton.MouseButton1Click:Connect(function()
            CreateTween(dimFrame, {BackgroundTransparency = 1}, 0.3):Play()
            CreateTween(mainWindow, {BackgroundTransparency = 0.1}, 0.3):Play()
            CreateTween(confirmDialog, {BackgroundTransparency = 1}, 0.3):Play()
            task.wait(0.3)
            dimFrame:Destroy()
            confirmDialog:Destroy()
        end)
    end

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

    game:GetService("UserInputService").InputChanged:Connect(function(input)
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

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Window Resizing
    local resizing = false
    local resizeMargin = 10

    contentFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local framePos = mainWindow.AbsolutePosition
            local frameSize = mainWindow.AbsoluteSize
            
            local onRightEdge = mousePos.X > framePos.X + frameSize.X - resizeMargin
            local onBottomEdge = mousePos.Y > framePos.Y + frameSize.Y - resizeMargin
            
            if onRightEdge or onBottomEdge then
                resizing = true
                dragStart = mousePos
                startPos = mainWindow.Size
            end
        end
    end)

    -- Button Functions
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

    -- Add window to library's window list
    table.insert(self.windows, window)
    self.currentWindow = window

    return window
end

-- Add Elements Functions
function Library:AddButton(window, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 35)
    button.Position = UDim2.new(0, 10, 0, #window.content:GetChildren() * 45)
    button.BackgroundColor3 = window.theme.buttons.minimize
    button.TextColor3 = window.theme.text
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
