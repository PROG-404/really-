-- Part 1: Core Framework
--[[
    ProgLib Premium v4.3.0
    Advanced UI Library for Roblox
    
    @class ProgLib
    @author Professional Programming Team
    @last_update 2024
]]

-- Optimized Services Loading
local Services = setmetatable({}, {
    __index = function(self, service)
        local service = game:GetService(service)
        self[service] = service
        return service
    end
})

-- Enhanced Settings System
local THEME_VARIANTS = {
    Default = {
        Primary = {
            Main = Color3.fromRGB(25, 25, 30),
            Secondary = Color3.fromRGB(30, 30, 35),
            Accent = Color3.fromRGB(60, 145, 255),
            AccentDark = Color3.fromRGB(40, 125, 235),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(200, 200, 200),
            Border = Color3.fromRGB(50, 50, 55),
            Background = Color3.fromRGB(20, 20, 25),
            Success = Color3.fromRGB(45, 200, 95),
            Warning = Color3.fromRGB(250, 180, 40),
            Error = Color3.fromRGB(250, 60, 60)
        },
        Dark = {
            Main = Color3.fromRGB(20, 20, 25),
            Secondary = Color3.fromRGB(25, 25, 30),
            Accent = Color3.fromRGB(50, 135, 245),
            AccentDark = Color3.fromRGB(30, 115, 225),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(190, 190, 190),
            Border = Color3.fromRGB(45, 45, 50),
            Background = Color3.fromRGB(15, 15, 20)
        },
        Light = {
            Main = Color3.fromRGB(245, 245, 250),
            Secondary = Color3.fromRGB(240, 240, 245),
            Accent = Color3.fromRGB(50, 135, 245),
            AccentDark = Color3.fromRGB(30, 115, 225),
            Text = Color3.fromRGB(30, 30, 35),
            SubText = Color3.fromRGB(100, 100, 110),
            Border = Color3.fromRGB(220, 220, 225),
            Background = Color3.fromRGB(250, 250, 255)
        }
    }
}

-- Part 2: Animation & Effects System

local AnimationSystem = {
    _activeTweens = {},
    _activeEffects = {},
    
    Effects = {
        Ripple = function(instance, properties)
            local ripple = Instance.new("Frame")
            ripple.BackgroundColor3 = Color3.new(1, 1, 1)
            ripple.BackgroundTransparency = 0.8
            ripple.BorderSizePixel = 0
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Position = properties.Position or UDim2.new(0.5, 0, 0.5, 0)
            ripple.Parent = instance
            
            local size = math.max(instance.AbsoluteSize.X, instance.AbsoluteSize.Y) * 1.5
            ripple.Size = UDim2.new(0, 0, 0, 0)
            
            local tween = Services.TweenService:Create(ripple, 
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}
            )
            
            tween:Play()
            tween.Completed:Connect(function()
                ripple:Destroy()
            end)
        end,
        
        Spring = function(instance, properties)
            local initial = instance.Position
            local target = properties.Target
            local speed = properties.Speed or 20
            local damping = properties.Damping or 0.8
            
            local velocity = Vector2.new(0, 0)
            local connection
            
            connection = Services.RunService.RenderStepped:Connect(function(dt)
                local force = (target - initial) * speed
                velocity = velocity * (1 - damping) + force * dt
                
                instance.Position = instance.Position + UDim2.new(0, velocity.X, 0, velocity.Y)
                
                if velocity.Magnitude < 0.1 and (target - instance.Position).Magnitude < 0.1 then
                    connection:Disconnect()
                    instance.Position = target
                end
            end)
        end
    }
}

-- Part 3: Enhanced UI Components

local UIComponents = {
    Button = {
        new = function(properties)
            local theme = THEME_VARIANTS.Default.Dark
            
            local button = Instance.new("TextButton")
            button.Size = properties.Size or UDim2.new(1, 0, 0, 40)
            button.BackgroundColor3 = theme.Secondary
            button.BorderSizePixel = 0
            button.Text = properties.Text or "Button"
            button.TextColor3 = theme.Text
            button.Font = properties.Font or Enum.Font.GothamBold
            button.TextSize = properties.TextSize or 14
            button.AutoButtonColor = false
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = button
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = theme.Border
            stroke.Transparency = 0.5
            stroke.Parent = button
            
            -- Hover & Click Effects
            button.MouseEnter:Connect(function()
                Services.TweenService:Create(button, 
                    TweenInfo.new(0.2), 
                    {BackgroundColor3 = theme.Secondary:Lerp(theme.Accent, 0.1)}
                ):Play()
            end)
            
            button.MouseLeave:Connect(function()
                Services.TweenService:Create(button, 
                    TweenInfo.new(0.2), 
                    {BackgroundColor3 = theme.Secondary}
                ):Play()
            end)
            
            button.MouseButton1Down:Connect(function()
                AnimationSystem.Effects.Ripple(button, {
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                })
            end)
            
            return button
        end
    },
    
    Slider = {
        new = function(properties)
            local theme = THEME_VARIANTS.Default.Dark
            
            local slider = Instance.new("Frame")
            slider.Size = properties.Size or UDim2.new(1, 0, 0, 50)
            slider.BackgroundTransparency = 1
            
            -- Create components...
            
            return slider
        end
    }
}

-- Part 4: Advanced Window System

local WindowSystem = {
   _activeWindows = {},
   
   Window = {
       new = function(properties)
           local theme = THEME_VARIANTS.Default.Dark
           
           local window = Instance.new("Frame")
           window.Size = properties.Size or UDim2.new(0, 600, 0, 400)
           window.Position = properties.Position or UDim2.new(0.5, -300, 0.5, -200)
           window.BackgroundColor3 = theme.Main
           window.BorderSizePixel = 0
           window.Parent = Services.CoreGui
           
           local corner = Instance.new("UICorner")
           corner.CornerRadius = UDim.new(0, 8)
           corner.Parent = window
           
           -- Title Bar
           local titleBar = Instance.new("Frame")
           titleBar.Size = UDim2.new(1, 0, 0, 40)
           titleBar.BackgroundColor3 = theme.Secondary
           titleBar.BorderSizePixel = 0
           titleBar.Parent = window
           
           local titleCorner = Instance.new("UICorner")
           titleCorner.CornerRadius = UDim.new(0, 8)
           titleCorner.Parent = titleBar
           
           local titleText = Instance.new("TextLabel")
           titleText.Size = UDim2.new(1, -20, 1, 0)
           titleText.Position = UDim2.new(0, 10, 0, 0)
           titleText.BackgroundTransparency = 1
           titleText.Text = properties.Title or "Window"
           titleText.TextColor3 = theme.Text
           titleText.Font = Enum.Font.GothamBold
           titleText.TextSize = 16
           titleText.TextXAlignment = Enum.TextXAlignment.Left
           titleText.Parent = titleBar
           
           -- Close Button
           local closeButton = Instance.new("TextButton")
           closeButton.Size = UDim2.new(0, 30, 0, 30)
           closeButton.Position = UDim2.new(1, -35, 0, 5)
           closeButton.BackgroundColor3 = theme.Error
           closeButton.Text = "×"
           closeButton.TextColor3 = theme.Text
           closeButton.Font = Enum.Font.GothamBold
           closeButton.TextSize = 20
           closeButton.Parent = titleBar
           
           local closeCorner = Instance.new("UICorner")
           closeCorner.CornerRadius = UDim.new(0, 6)
           closeCorner.Parent = closeButton
           
           -- Content Area
           local content = Instance.new("Frame")
           content.Size = UDim2.new(1, -20, 1, -60)
           content.Position = UDim2.new(0, 10, 0, 50)
           content.BackgroundTransparency = 1
           content.Parent = window
           
           -- Dragging System
           local dragging = false
           local dragInput
           local dragStart
           local startPos

           titleBar.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 then
                   dragging = true
                   dragStart = input.Position
                   startPos = window.Position
               end
           end)

           titleBar.InputEnded:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 then
                   dragging = false
               end
           end)

           Services.UserInputService.InputChanged:Connect(function(input)
               if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                   local delta = input.Position - dragStart
                   window.Position = UDim2.new(
                       startPos.X.Scale,
                       startPos.X.Offset + delta.X,
                       startPos.Y.Scale,
                       startPos.Y.Offset + delta.Y
                   )
               end
           end)
           
           -- Window Methods
           local windowObj = {
               instance = window,
               content = content,
               
               setTitle = function(self, title)
                   titleText.Text = title
               end,
               
               setSize = function(self, size)
                   window.Size = size
               end,
               
               setPosition = function(self, position)
                   window.Position = position
               end,
               
               addElement = function(self, element)
                   element.Parent = content
                   return element
               end,
               
               close = function(self)
                   window:Destroy()
               end
           }
           
           closeButton.MouseButton1Click:Connect(function()
               windowObj:close()
           end)
           
           return windowObj
       end
   }
}

-- Part 5: TabSystem and Layout Manager

local TabSystem = {
    new = function(window)
        local theme = THEME_VARIANTS.Default.Dark
        
        local tabContainer = Instance.new("Frame")
        tabContainer.Size = UDim2.new(0, 150, 1, 0)
        tabContainer.BackgroundColor3 = theme.Secondary
        tabContainer.BorderSizePixel = 0
        tabContainer.Parent = window.content
        
        local tabList = Instance.new("ScrollingFrame")
        tabList.Size = UDim2.new(1, 0, 1, 0)
        tabList.BackgroundTransparency = 1
        tabList.ScrollBarThickness = 2
        tabList.Parent = tabContainer
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Padding = UDim.new(0, 5)
        tabLayout.Parent = tabList
        
        local contentContainer = Instance.new("Frame")
        contentContainer.Size = UDim2.new(1, -160, 1, 0)
        contentContainer.Position = UDim2.new(0, 160, 0, 0)
        contentContainer.BackgroundTransparency = 1
        contentContainer.Parent = window.content
        
        local tabs = {}
        local activeTab = nil
        
        local tabSystem = {
            addTab = function(self, name)
                local tab = {
                    button = Instance.new("TextButton"),
                    content = Instance.new("Frame")
                }
                
                -- Tab Button
                tab.button.Size = UDim2.new(1, -10, 0, 40)
                tab.button.Position = UDim2.new(0, 5, 0, 0)
                tab.button.BackgroundColor3 = theme.Main
                tab.button.Text = name
                tab.button.TextColor3 = theme.Text
                tab.button.Font = Enum.Font.GothamSemibold
                tab.button.TextSize = 14
                tab.button.Parent = tabList
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 6)
                corner.Parent = tab.button
                
                -- Tab Content
                tab.content.Size = UDim2.new(1, 0, 1, 0)
                tab.content.BackgroundTransparency = 1
                tab.content.Visible = false
                tab.content.Parent = contentContainer
                
                tab.button.MouseButton1Click:Connect(function()
                    if activeTab then
                        activeTab.content.Visible = false
                        Services.TweenService:Create(activeTab.button,
                            TweenInfo.new(0.2),
                            {BackgroundColor3 = theme.Main}
                        ):Play()
                    end
                    
                    activeTab = tab
                    tab.content.Visible = true
                    Services.TweenService:Create(tab.button,
                        TweenInfo.new(0.2),
                        {BackgroundColor3 = theme.Accent}
                    ):Play()
                end)
                
                if not activeTab then
                    activeTab = tab
                    tab.content.Visible = true
                    tab.button.BackgroundColor3 = theme.Accent
                end
                
                tabs[name] = tab
                return tab.content
            end
        }
        
        return tabSystem
    end
}

-- Part 6: Notification System

local NotificationSystem = {
    _notifications = {},
    
    notify = function(self, properties)
        local theme = THEME_VARIANTS.Default.Dark
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 300, 0, 80)
        notification.Position = UDim2.new(1, 20, 1, -90)
        notification.BackgroundColor3 = theme.Secondary
        notification.BorderSizePixel = 0
        notification.Parent = Services.CoreGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notification
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = properties.Title or "Notification"
        title.TextColor3 = theme.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = notification
        
        local message = Instance.new("TextLabel")
        message.Size = UDim2.new(1, -20, 0, 40)
        message.Position = UDim2.new(0, 10, 0, 35)
        message.BackgroundTransparency = 1
        message.Text = properties.Message or ""
        message.TextColor3 = theme.SubText
        message.Font = Enum.Font.Gotham
        message.TextSize = 14
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextWrapped = true
        message.Parent = notification
        
        -- Animation
        Services.TweenService:Create(notification,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart),
            {Position = UDim2.new(1, -320, 1, -90)}
        ):Play()
        
        task.delay(properties.Duration or 3, function()
            Services.TweenService:Create(notification,
                TweenInfo.new(0.5, Enum.EasingStyle.Quart),
                {Position = UDim2.new(1, 20, 1, -90)}
            ):Play()
            
            task.delay(0.5, function()
                notification:Destroy()
            end)
        end)
    end
}

-- Part 7: Main Export

local ProgLib = {
    Theme = THEME_VARIANTS.Default.Dark,
    Animation = AnimationSystem,
    UI = {
        Components = UIComponents,
        Window = WindowSystem.Window,
        Tabs = TabSystem,
        Notify = function(...)
            return NotificationSystem:notify(...)
        end
    },
    
    setTheme = function(self, themeName)
        if THEME_VARIANTS.Default[themeName] then
            self.Theme = THEME_VARIANTS.Default[themeName]
        end
    end
}

return ProgLib

-- Part 8: Advanced UI Components

ProgLib.UI.Components.Dropdown = {
   new = function(properties)
       local theme = ProgLib.Theme
       local isOpen = false
       local selectedOption = properties.Default
       local options = properties.Options or {}
       
       -- Main Container
       local container = Instance.new("Frame")
       container.Size = properties.Size or UDim2.new(1, 0, 0, 40)
       container.BackgroundColor3 = theme.Secondary
       container.BorderSizePixel = 0
       container.ClipsDescendants = true
       
       local corner = Instance.new("UICorner")
       corner.CornerRadius = UDim.new(0, 6)
       corner.Parent = container
       
       -- Selected Value Display
       local display = Instance.new("TextButton")
       display.Size = UDim2.new(1, 0, 0, 40)
       display.BackgroundTransparency = 1
       display.Text = selectedOption or properties.Placeholder or "Select..."
       display.TextColor3 = selectedOption and theme.Text or theme.SubText
       display.Font = Enum.Font.GothamSemibold
       display.TextSize = 14
       display.TextXAlignment = Enum.TextXAlignment.Left
       display.Parent = container
       
       local padding = Instance.new("UIPadding")
       padding.PaddingLeft = UDim.new(0, 10)
       padding.Parent = display
       
       -- Options List
       local optionsList = Instance.new("ScrollingFrame")
       optionsList.Size = UDim2.new(1, 0, 0, 0)
       optionsList.Position = UDim2.new(0, 0, 0, 40)
       optionsList.BackgroundTransparency = 1
       optionsList.ScrollBarThickness = 2
       optionsList.Visible = false
       optionsList.Parent = container
       
       local listLayout = Instance.new("UIListLayout")
       listLayout.Padding = UDim.new(0, 2)
       listLayout.Parent = optionsList

       -- Toggle Dropdown
       local function toggleDropdown()
           isOpen = not isOpen
           
           local targetSize = isOpen and 
               UDim2.new(1, 0, 0, math.min(40 + (#options * 30), 200)) or
               UDim2.new(1, 0, 0, 40)
           
           Services.TweenService:Create(container, 
               TweenInfo.new(0.3, Enum.EasingStyle.Quart),
               {Size = targetSize}
           ):Play()
           
           optionsList.Visible = isOpen
       end
       
       display.MouseButton1Click:Connect(toggleDropdown)
       
       -- Add Options
       local function addOption(value)
           local option = Instance.new("TextButton")
           option.Size = UDim2.new(1, 0, 0, 30)
           option.BackgroundColor3 = theme.Main
           option.Text = tostring(value)
           option.TextColor3 = theme.Text
           option.Font = Enum.Font.Gotham
           option.TextSize = 14
           option.Parent = optionsList
           
           local optionCorner = Instance.new("UICorner")
           optionCorner.CornerRadius = UDim.new(0, 6)
           optionCorner.Parent = option
           
           option.MouseButton1Click:Connect(function()
               selectedOption = value
               display.Text = tostring(value)
               display.TextColor3 = theme.Text
               
               if properties.OnSelected then
                   properties.OnSelected(value)
               end
               
               toggleDropdown()
           end)
           
           -- Hover Effect
           option.MouseEnter:Connect(function()
               Services.TweenService:Create(option,
                   TweenInfo.new(0.2),
                   {BackgroundColor3 = theme.Secondary}
               ):Play()
           end)
           
           option.MouseLeave:Connect(function()
               Services.TweenService:Create(option,
                   TweenInfo.new(0.2),
                   {BackgroundColor3 = theme.Main}
               ):Play()
           end)
       end
       
       for _, option in ipairs(options) do
           addOption(option)
       end
       
       -- Dropdown Methods
       local dropdownObj = {
           Instance = container,
           
           getValue = function(self)
               return selectedOption
           end,
           
           setValue = function(self, value)
               if table.find(options, value) then
                   selectedOption = value
                   display.Text = tostring(value)
                   display.TextColor3 = theme.Text
                   
                   if properties.OnSelected then
                       properties.OnSelected(value)
                   end
               end
           end,
           
           setOptions = function(self, newOptions)
               options = newOptions
               for _, child in ipairs(optionsList:GetChildren()) do
                   if child:IsA("TextButton") then
                       child:Destroy()
                   end
               end
               
               for _, option in ipairs(options) do
                   addOption(option)
               end
               
               if not table.find(options, selectedOption) then
                   selectedOption = nil
                   display.Text = properties.Placeholder or "Select..."
                   display.TextColor3 = theme.SubText
               end
           end
       }
       
       return dropdownObj
   end
}

-- Part 9: Modal System

ProgLib.UI.Modal = {
    new = function(properties)
        local theme = ProgLib.Theme
        
        -- Overlay
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 1
        overlay.Parent = Services.CoreGui
        
        -- Modal Container
        local modal = Instance.new("Frame")
        modal.Size = UDim2.new(0, 400, 0, 250)
        modal.Position = UDim2.new(0.5, -200, 0.5, -125)
        modal.BackgroundColor3 = theme.Secondary
        modal.BackgroundTransparency = 1
        modal.BorderSizePixel = 0
        modal.Parent = overlay
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = modal
        
        -- Content
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 40)
        title.Position = UDim2.new(0, 10, 0, 10)
        title.BackgroundTransparency = 1
        title.Text = properties.Title or "Modal"
        title.TextColor3 = theme.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 20
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = modal
        
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, -20, 1, -110)
        content.Position = UDim2.new(0, 10, 0, 60)
        content.BackgroundTransparency = 1
        content.Parent = modal
        
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -20, 0, 40)
        buttonContainer.Position = UDim2.new(0, 10, 1, -50)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = modal
        
        -- Methods
        local modalObj = {
            Instance = modal,
            Content = content,
            
            show = function(self)
                Services.TweenService:Create(overlay,
                    TweenInfo.new(0.3),
                    {BackgroundTransparency = 0.5}
                ):Play()
                
                Services.TweenService:Create(modal,
                    TweenInfo.new(0.3, Enum.EasingStyle.Back),
                    {BackgroundTransparency = 0}
                ):Play()
            end,
            
            hide = function(self)
                Services.TweenService:Create(overlay,
                    TweenInfo.new(0.3),
                    {BackgroundTransparency = 1}
                ):Play()
                
                Services.TweenService:Create(modal,
                    TweenInfo.new(0.3),
                    {BackgroundTransparency = 1}
                ):Play()
                
                task.delay(0.3, function()
                    overlay:Destroy()
                end)
            end,
            
            addButton = function(self, properties)
                local button = ProgLib.UI.Components.Button.new({
                    Text = properties.Text,
                    Size = UDim2.new(0, 100, 1, 0),
                    Position = UDim2.new(1, -100 * (#buttonContainer:GetChildren()), 0, 0)
                })
                
                if properties.OnClick then
                    button.MouseButton1Click:Connect(properties.OnClick)
                end
                
                button.Parent = buttonContainer
                return button
            end
        }
        
        if properties.Content then
            properties.Content(content)
        end
        
        return modalObj
    end
}

-- Part 10: Context Menu System

ProgLib.UI.ContextMenu = {
    new = function(items)
        local theme = ProgLib.Theme
        local menu = nil
        
        local function createMenu(position)
            if menu then menu:Destroy() end
            
            menu = Instance.new("Frame")
            menu.Size = UDim2.new(0, 200, 0, #items * 30 + 10)
            menu.Position = position
            menu.BackgroundColor3 = theme.Secondary
            menu.BorderSizePixel = 0
            menu.Parent = Services.CoreGui
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = menu
            
            local shadow = Instance.new("ImageLabel")
            shadow.Size = UDim2.new(1, 30, 1, 30)
            shadow.Position = UDim2.new(0, -15, 0, -15)
            shadow.BackgroundTransparency = 1
            shadow.Image = "rbxassetid://5554236805"
            shadow.ImageColor3 = Color3.new(0, 0, 0)
            shadow.ImageTransparency = 0.7
            shadow.Parent = menu
            
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 2)
            layout.Parent = menu
            
            for _, item in ipairs(items) do
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, -10, 0, 30)
                button.Position = UDim2.new(0, 5, 0, 0)
                button.BackgroundColor3 = theme.Main
                button.Text = item.Text
                button.TextColor3 = theme.Text
                button.Font = Enum.Font.Gotham
                button.TextSize = 14
                button.Parent = menu
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = button
                
                if item.OnClick then
                    button.MouseButton1Click:Connect(function()
                        item.OnClick()
                        menu:Destroy()
                        menu = nil
                    end)
                end
                
                -- Hover Effect
                button.MouseEnter:Connect(function()
                    Services.TweenService:Create(button,
                        TweenInfo.new(0.2),
                        {BackgroundColor3 = theme.Accent}
                    ):Play()
                end)
                
                button.MouseLeave:Connect(function()
                    Services.TweenService:Create(button,
                        TweenInfo.new(0.2),
                        {BackgroundColor3 = theme.Main}
                    ):Play()
                end)
            end
        end
        
        -- Close menu when clicking outside
        Services.UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and menu then
                local mousePos = Services.UserInputService:GetMouseLocation()
                local menuPos = menu.AbsolutePosition
                local menuSize = menu.AbsoluteSize
                
                if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
                   mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                    menu:Destroy()
                    menu = nil
                end
            end
        end)
        
        return function()
            local mousePos = Services.UserInputService:GetMouseLocation()
            createMenu(UDim2.new(0, mousePos.X, 0, mousePos.Y))
        end
    end
}

return ProgLib

-- Part 11: State Management System

local StateManagement = {
    create = function(initialState)
        local state = {
            _value = initialState,
            _subscribers = {}
        }
        
        function state:get()
            return self._value
        end
        
        function state:set(newValue)
            self._value = newValue
            for _, callback in ipairs(self._subscribers) do
                callback(newValue)
            end
        end
        
        function state:subscribe(callback)
            table.insert(self._subscribers, callback)
            return function()
                for i, sub in ipairs(self._subscribers) do
                    if sub == callback then
                        table.remove(self._subscribers, i)
                        break
                    end
                end
            end
        end
        
        return state
    end
}

-- Part 12: Final Integration

-- Add new systems to main ProgLib
ProgLib.Utilities = Utilities
ProgLib.Animation.Sequences = EnhancedAnimations.Sequences
ProgLib.Animation.Springs = EnhancedAnimations.Springs
ProgLib.State = StateManagement
ProgLib.UI.Components.ColorPicker = ColorPickerComponent
ProgLib.UI.Components.TreeView = TreeViewComponent
ProgLib.UI.createContextMenu = createContextMenu

return ProgLib
