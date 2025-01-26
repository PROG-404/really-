local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Colors = {
        Primary = Color3.fromRGB(30, 30, 45),
        Secondary = Color3.fromRGB(35, 35, 50),
        Accent = Color3.fromRGB(100, 190, 255),
        AccentDark = Color3.fromRGB(85, 170, 255),
        Border = Color3.fromRGB(60, 60, 80),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        ElementBackground = Color3.fromRGB(40, 40, 60),
        ElementBackgroundHover = Color3.fromRGB(45, 45, 65),
        Notification = Color3.fromRGB(45, 45, 65),
        Shadow = Color3.fromRGB(20, 20, 30)
    },
    Fonts = {
        Regular = Enum.Font.GothamMedium,
        Bold = Enum.Font.GothamBold,
        SemiBold = Enum.Font.GothamSemibold
    },
    Settings = {
        AnimationDuration = 0.3,
        EasingStyle = Enum.EasingStyle.Quart,
        CornerRadius = UDim.new(0, 6),
        ElementPadding = UDim.new(0, 8),
        MinWindowSize = Vector2.new(500, 300),
        MaxWindowSize = Vector2.new(800, 600)
    }
}

-- Utility Functions
local function CreateElement(class, properties)
    local element = Instance.new(class)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Library.Settings.CornerRadius
    corner.Parent = parent
    return corner
end

local function AddShadow(parent, transparency)
    local shadow = CreateElement("Frame", {
        Name = "Shadow",
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.new(0, -2, 0, -2),
        BackgroundColor3 = Library.Colors.Shadow,
        BackgroundTransparency = transparency or 0.5,
        BorderSizePixel = 0,
        ZIndex = parent.ZIndex - 1
    })
    AddCorner(shadow, UDim.new(0, 8))
    shadow.Parent = parent
    return shadow
end

function Library:CreateWindow(config)
    config = config or {}
    local window = {}
    local isMinimized = false
    local isDragging = false
    
    -- Main GUI
    local gui = CreateElement("ScreenGui", {
        Name = config.Name or "ModernUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Try to parent to CoreGui
    pcall(function()
        gui.Parent = CoreGui
    end)
    if not gui.Parent then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Container
    local mainContainer = CreateElement("Frame", {
        Name = "MainContainer",
        Size = UDim2.new(0, 550, 0, 350),
        Position = UDim2.new(0.5, -275, 0.5, -175),
        BackgroundColor3 = Library.Colors.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    AddCorner(mainContainer)
    AddShadow(mainContainer)
    mainContainer.Parent = gui
    
    -- Gradient Border
    local borderFrame = CreateElement("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Library.Colors.Border,
        BorderSizePixel = 0,
        ZIndex = 0
    })
    AddCorner(borderFrame)
    
    local gradient = CreateElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Colors.Accent),
            ColorSequenceKeypoint.new(1, Library.Colors.AccentDark)
        }),
        Rotation = 45
    })
    gradient.Parent = borderFrame
    borderFrame.Parent = mainContainer
    
    -- Title Bar
    local titleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Library.Colors.Secondary,
        BorderSizePixel = 0
    })
    AddCorner(titleBar)
    titleBar.Parent = mainContainer
    
    -- Title
    local titleText = CreateElement("TextLabel", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "Modern UI",
        TextColor3 = Library.Colors.Text,
        TextSize = 16,
        Font = Library.Fonts.Bold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    titleText.Parent = titleBar
    
    -- Control Buttons Container
    local controlButtons = CreateElement("Frame", {
        Size = UDim2.new(0, 70, 1, -10),
        Position = UDim2.new(1, -80, 0, 5),
        BackgroundTransparency = 1
    })
    controlButtons.Parent = titleBar
    
    -- Create Control Buttons
    local buttonConfig = {
        {Name = "Minimize", Text = "-", Position = UDim2.new(0, 0, 0, 0)},
        {Name = "Close", Text = "×", Position = UDim2.new(1, -30, 0, 0)}
    }
    
    for _, btnConfig in ipairs(buttonConfig) do
        local button = CreateElement("TextButton", {
            Name = btnConfig.Name,
            Size = UDim2.new(0, 30, 0, 30),
            Position = btnConfig.Position,
            BackgroundColor3 = Library.Colors.ElementBackground,
            Text = btnConfig.Text,
            TextColor3 = Library.Colors.Text,
            TextSize = 20,
            Font = Library.Fonts.Bold
        })
        AddCorner(button)
        
        -- Button Hover Effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Library.Colors.ElementBackgroundHover
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Library.Colors.ElementBackground
            }):Play()
        end)
        
        button.Parent = controlButtons
    end
    
    -- Content Area
    local contentArea = CreateElement("ScrollingFrame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -20, 1, -70),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Library.Colors.AccentDark,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local contentLayout = CreateElement("UIListLayout", {
        Padding = Library.Settings.ElementPadding,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    contentLayout.Parent = contentArea
    contentArea.Parent = mainContainer
    
    -- Window Functionality
    local function UpdateCanvasSize()
        local absoluteContentSize = contentLayout.AbsoluteContentSize
        contentArea.CanvasSize = UDim2.new(0, 0, 0, absoluteContentSize.Y)
    end
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
    
    -- Dragging Logic
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            mainContainer.Position = newPosition
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    -- Button Functionality
    local minimizeBtn = controlButtons:WaitForChild("Minimize")
    local closeBtn = controlButtons:WaitForChild("Close")
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(1, -20, 0, 40) or UDim2.new(1, -20, 1, -70)
        TweenService:Create(contentArea, TweenInfo.new(Library.Settings.AnimationDuration, Library.Settings.EasingStyle), {
            Size = targetSize
        }):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(mainContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        closeTween.Completed:Connect(function()
            gui:Destroy()
        end)
        closeTween:Play()
    end)
    
    -- Opening Animation
    mainContainer.Size = UDim2.new(0, 0, 0, 0)
    mainContainer.BackgroundTransparency = 1
    
    TweenService:Create(mainContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 550, 0, 350),
        BackgroundTransparency = 0
    }):Play()
    
    -- Tab System
    function window:CreateTab(name)
        local tab = {}
        -- Tab implementation here
        return tab
    end
    
    -- Element Creation Methods
    function window:AddButton(text, callback)
        local button = CreateElement("TextButton", {
            Size = UDim2.new(1, -10, 0, 35),
            BackgroundColor3 = Library.Colors.ElementBackground,
            Text = text,
            TextColor3 = Library.Colors.Text,
            Font = Library.Fonts.Regular,
            TextSize = 14
        })
        AddCorner(button)
        button.Parent = contentArea
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    function window:AddToggle(text, default, callback)
        local toggle = CreateElement("Frame", {
            Size = UDim2.new(1, -10, 0, 35),
            BackgroundColor3 = Library.Colors.ElementBackground
        })
        AddCorner(toggle)
        
        -- Toggle implementation here
        return toggle
    end
    
    -- Return the window interface
    return window
end

return Library
