-- Part 1: Core Framework
local Services = setmetatable({
   _cache = {},
}, {
   __index = function(self, service)
       if not self._cache[service] then
           self._cache[service] = game:GetService(service)
       end
       return self._cache[service]
   end
})

local InstanceManager = {
   _activeInstances = {},
   _uiInstances = {},
   
   create = function(className, properties)
       local instance = Instance.new(className)
       
       if properties then
           for prop, value in pairs(properties) do
               instance[prop] = value
           end
       end
       
       table.insert(InstanceManager._activeInstances, instance)
       return instance
   end,
   
   registerUI = function(ui)
       table.insert(InstanceManager._uiInstances, ui)
       
       if #InstanceManager._uiInstances > 1 then
           InstanceManager._uiInstances[1]:Destroy()
           table.remove(InstanceManager._uiInstances, 1)
       end
   end,
   
   cleanup = function()
       for _, instance in ipairs(InstanceManager._activeInstances) do
           if instance and instance.Parent then
               instance:Destroy()
           end
       end
       table.clear(InstanceManager._activeInstances)
   end
}

local ThemeManager = {
   _activeTheme = nil,
   _subscribers = {},
   
   Themes = {
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
}

-- Part 2: Enhanced Animation System
local AnimationSystem = {
    _activeTweens = {},
    _activeEffects = {},
    
    Effects = {
        Ripple = function(instance, properties)
            local ripple = InstanceManager.create("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 0.8,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = properties.Position or UDim2.new(0.5, 0, 0.5, 0),
                Parent = instance
            })
            
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
        end,
        
        Fade = function(instance, properties)
            local tween = Services.TweenService:Create(instance,
                TweenInfo.new(properties.Duration or 0.3, Enum.EasingStyle.Quad),
                {BackgroundTransparency = properties.Transparency or 1}
            )
            tween:Play()
            return tween
        end,
        
        Scale = function(instance, properties)
            local originalSize = instance.Size
            instance.Size = UDim2.new(0, 0, 0, 0)
            
            local tween = Services.TweenService:Create(instance,
                TweenInfo.new(properties.Duration or 0.3, Enum.EasingStyle.Back),
                {Size = originalSize}
            )
            tween:Play()
            return tween
        end
    }
}


-- Part 3: Enhanced UI Components
local UIComponents = {
    Button = {
        new = function(properties)
            local theme = ThemeManager.Themes.Default.Dark
            
            local button = InstanceManager.create("TextButton", {
                Size = properties.Size or UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = theme.Secondary,
                BorderSizePixel = 0,
                Text = properties.Text or "Button",
                TextColor3 = theme.Text,
                Font = properties.Font or Enum.Font.GothamBold,
                TextSize = properties.TextSize or 14,
                AutoButtonColor = false
            })
            
            local corner = InstanceManager.create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = button
            })
            
            local stroke = InstanceManager.create("UIStroke", {
                Color = theme.Border,
                Transparency = 0.5,
                Parent = button
            })
            
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
            
            if properties.OnClick then
                button.MouseButton1Click:Connect(properties.OnClick)
            end
            
            return button
        end
    }
}


-- Part 4: Window System
local WindowSystem = {
    Window = {
        new = function(properties) 
            local theme = ThemeManager.Themes.Default.Dark
            
            local window = InstanceManager.create("Frame", {
                Size = properties.Size or UDim2.new(0, 600, 0, 400),
                Position = properties.Position or UDim2.new(0.5, -300, 0.5, -200),
                BackgroundColor3 = theme.Main,
                BorderSizePixel = 0,
                Parent = Services.CoreGui
            })
            
            InstanceManager.registerUI(window)
            
            local corner = InstanceManager.create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = window
            })
            
            local titleBar = InstanceManager.create("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = theme.Secondary,
                BorderSizePixel = 0,
                Parent = window
            })
            
            local titleCorner = InstanceManager.create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = titleBar
            })
            
            local titleText = InstanceManager.create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = properties.Title or "Window",
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = titleBar
            })
            
            local closeButton = InstanceManager.create("TextButton", {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -35, 0, 5),
                BackgroundColor3 = theme.Error,
                Text = "×",
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 20,
                Parent = titleBar
            })
            
            local closeCorner = InstanceManager.create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = closeButton
            })
            
            local content = InstanceManager.create("Frame", {
                Size = UDim2.new(1, -20, 1, -60),
                Position = UDim2.new(0, 10, 0, 50),
                BackgroundTransparency = 1,
                Parent = window
            })
            
            return window
        end
    }
}


-- Part 5: Export & Integration
local ProgLib = {
    Theme = ThemeManager.Themes.Default.Dark,
    Animation = AnimationSystem,
    UI = {
        Components = UIComponents,
        Window = WindowSystem.Window,
        InstanceManager = InstanceManager
    },
    
    setTheme = function(self, themeName)
        if ThemeManager.Themes.Default[themeName] then
            self.Theme = ThemeManager.Themes.Default[themeName]
        end
    end
}

return ProgLib


-- Part 6: Advanced Components
local AdvancedComponents = {
   Dropdown = {
       new = function(properties)
           local theme = ThemeManager.Themes.Default.Dark
           local isOpen = false
           local selectedOption = properties.Default
           local options = properties.Options or {}
           
           local container = InstanceManager.create("Frame", {
               Size = properties.Size or UDim2.new(1, 0, 0, 40),
               BackgroundColor3 = theme.Secondary,
               BorderSizePixel = 0,
               ClipsDescendants = true
           })

           local display = InstanceManager.create("TextButton", {
               Size = UDim2.new(1, 0, 0, 40),
               BackgroundTransparency = 1,
               Text = selectedOption or properties.Placeholder or "Select...",
               TextColor3 = selectedOption and theme.Text or theme.SubText,
               Font = Enum.Font.GothamSemibold,
               TextSize = 14,
               TextXAlignment = Enum.TextXAlignment.Left,
               Parent = container
           })
           
           local arrow = InstanceManager.create("ImageLabel", {
               Size = UDim2.new(0, 20, 0, 20),
               Position = UDim2.new(1, -25, 0, 10),
               BackgroundTransparency = 1,
               Image = "rbxassetid://6034818379",
               ImageColor3 = theme.Text,
               Parent = display
           })
           
           local optionsList = InstanceManager.create("ScrollingFrame", {
               Size = UDim2.new(1, 0, 0, 0),
               Position = UDim2.new(0, 0, 0, 40),
               BackgroundTransparency = 1,
               ScrollBarThickness = 2,
               Visible = false,
               Parent = container
           })
           
           local corner = InstanceManager.create("UICorner", {
               CornerRadius = UDim.new(0, 6),
               Parent = container
           })
           
           return container
       end
   },

   Slider = {
       new = function(properties)
           local theme = ThemeManager.Themes.Default.Dark
           local min = properties.Min or 0
           local max = properties.Max or 100
           local value = properties.Default or min
           
           local container = InstanceManager.create("Frame", {
               Size = properties.Size or UDim2.new(1, 0, 0, 50),
               BackgroundTransparency = 1
           })
           
           local title = InstanceManager.create("TextLabel", {
               Size = UDim2.new(1, -50, 0, 20),
               Position = UDim2.new(0, 0, 0, 0),
               BackgroundTransparency = 1,
               Text = properties.Title or "Slider",
               TextColor3 = theme.Text,
               TextXAlignment = Enum.TextXAlignment.Left,
               Font = Enum.Font.GothamSemibold,
               TextSize = 14,
               Parent = container
           })
           
           local valueLabel = InstanceManager.create("TextLabel", {
               Size = UDim2.new(0, 50, 0, 20),
               Position = UDim2.new(1, -50, 0, 0),
               BackgroundTransparency = 1,
               Text = tostring(value),
               TextColor3 = theme.SubText,
               Font = Enum.Font.Gotham,
               TextSize = 12,
               Parent = container
           })
           
           local sliderBar = InstanceManager.create("Frame", {
               Size = UDim2.new(1, 0, 0, 6),
               Position = UDim2.new(0, 0, 0, 30),
               BackgroundColor3 = theme.Border,
               Parent = container
           })
           
           local sliderCorner = InstanceManager.create("UICorner", {
               CornerRadius = UDim.new(0, 3),
               Parent = sliderBar
           })
           
           local progress = InstanceManager.create("Frame", {
               Size = UDim2.new(0.5, 0, 1, 0),
               BackgroundColor3 = theme.Accent,
               Parent = sliderBar
           })
           
           local progressCorner = InstanceManager.create("UICorner", {
               CornerRadius = UDim.new(0, 3),
               Parent = progress
           })
           
           local knob = InstanceManager.create("Frame", {
               Size = UDim2.new(0, 16, 0, 16),
               Position = UDim2.new(0.5, -8, 0.5, -8),
               BackgroundColor3 = theme.Accent,
               Parent = progress
           })
           
           local knobCorner = InstanceManager.create("UICorner", {
               CornerRadius = UDim.new(0.5, 0),
               Parent = knob
           })
           
           return container
       end
   }
}

-- Part 7: Modal System
local ModalSystem = {
    new = function(properties)
        local theme = ThemeManager.Themes.Default.Dark
        
        local overlay = InstanceManager.create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.5,
            Parent = Services.CoreGui
        })
        
        local modal = InstanceManager.create("Frame", {
            Size = UDim2.new(0, 400, 0, 200),
            Position = UDim2.new(0.5, -200, 0.5, -100),
            BackgroundColor3 = theme.Secondary,
            Parent = overlay
        })
        
        local corner = InstanceManager.create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = modal
        })
        
        local title = InstanceManager.create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = properties.Title or "Modal",
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = modal
        })
        
        local content = InstanceManager.create("Frame", {
            Size = UDim2.new(1, -20, 1, -110),
            Position = UDim2.new(0, 10, 0, 60),
            BackgroundTransparency = 1,
            Parent = modal
        })
        
        local buttonContainer = InstanceManager.create("Frame", {
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.new(0, 10, 1, -50),
            BackgroundTransparency = 1,
            Parent = modal
        })
        
        return modal
    end
}

-- Part 8: Notification System
local NotificationSystem = {
    _activeNotifications = {},
    
    notify = function(self, properties)
        local theme = ThemeManager.Themes.Default.Dark
        
        local notification = InstanceManager.create("Frame", {
            Size = UDim2.new(0, 300, 0, 80),
            Position = UDim2.new(1, 20, 1, -90),
            BackgroundColor3 = theme.Secondary,
            Parent = Services.CoreGui
        })
        
        local corner = InstanceManager.create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = notification
        })
        
        local icon = InstanceManager.create("ImageLabel", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Image = properties.Icon or "",
            ImageColor3 = theme.Text,
            Parent = notification
        })
        
        local title = InstanceManager.create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 30),
            Position = UDim2.new(0, 50, 0, 10),
            BackgroundTransparency = 1,
            Text = properties.Title or "Notification",
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notification
        })
        
        local message = InstanceManager.create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 40),
            BackgroundTransparency = 1,
            Text = properties.Message or "",
            TextColor3 = theme.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = notification
        })
        
        table.insert(self._activeNotifications, notification)
        
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
                table.remove(self._activeNotifications, table.find(self._activeNotifications, notification))
            end)
        end)
    end
}

-- Part 9: Contextual Help System
local HelpSystem = {
    _activeTooltips = {},
    
    showTooltip = function(self, instance, properties)
        local theme = ThemeManager.Themes.Default.Dark
        
        local tooltip = InstanceManager.create("Frame", {
            Size = UDim2.new(0, 200, 0, 40),
            BackgroundColor3 = theme.Secondary,
            Visible = false,
            Parent = Services.CoreGui
        })
        
        local corner = InstanceManager.create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tooltip
        })
        
        local text = InstanceManager.create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = properties.Text or "",
            TextColor3 = theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextWrapped = true,
            Parent = tooltip
        })
        
        instance.MouseEnter:Connect(function()
            local pos = instance.AbsolutePosition
            tooltip.Position = UDim2.new(0, pos.X, 0, pos.Y - 50)
            tooltip.Visible = true
        end)
        
        instance.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
        
        return tooltip
    end
}

-- Final Export
return {
    Components = AdvancedComponents,
    Modal = ModalSystem,
    Notification = NotificationSystem,
    Help = HelpSystem
}


-- Part 10: Context Menu System
local ContextMenuSystem = {
   _activeMenu = nil,
   
   new = function(items)
       local theme = ThemeManager.Themes.Default.Dark
       
       local function createMenu(position)
           if ContextMenuSystem._activeMenu then
               ContextMenuSystem._activeMenu:Destroy()
           end
           
           local menu = InstanceManager.create("Frame", {
               Size = UDim2.new(0, 200, 0, #items * 30 + 10),
               Position = position,
               BackgroundColor3 = theme.Secondary,
               BorderSizePixel = 0,
               Parent = Services.CoreGui
           })
           
           local corner = InstanceManager.create("UICorner", {
               CornerRadius = UDim.new(0, 6),
               Parent = menu
           })
           
           local shadow = InstanceManager.create("ImageLabel", {
               Size = UDim2.new(1, 30, 1, 30),
               Position = UDim2.new(0, -15, 0, -15),
               BackgroundTransparency = 1,
               Image = "rbxassetid://5554236805",
               ImageColor3 = Color3.new(0, 0, 0),
               ImageTransparency = 0.7,
               Parent = menu
           })
           
           for i, item in ipairs(items) do
               local button = InstanceManager.create("TextButton", {
                   Size = UDim2.new(1, -10, 0, 30),
                   Position = UDim2.new(0, 5, 0, (i-1) * 30 + 5),
                   BackgroundColor3 = theme.Main,
                   Text = item.Text,
                   TextColor3 = theme.Text,
                   Font = Enum.Font.Gotham,
                   TextSize = 14,
                   Parent = menu
               })
               
               local btnCorner = InstanceManager.create("UICorner", {
                   CornerRadius = UDim.new(0, 4),
                   Parent = button
               })
               
               if item.OnClick then
                   button.MouseButton1Click:Connect(function()
                       item.OnClick()
                       menu:Destroy()
                       ContextMenuSystem._activeMenu = nil
                   end)
               end
               
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
           
           ContextMenuSystem._activeMenu = menu
           return menu
       end
       
       return function(position)
           return createMenu(position)
       end
   end
}

-- Part 11: Dialog System
local DialogSystem = {
    _activeDialogs = {},
    
    show = function(self, properties)
        local theme = ThemeManager.Themes.Default.Dark
        
        local dialog = InstanceManager.create("Frame", {
            Size = UDim2.new(0, 400, 0, 200),
            Position = UDim2.new(0.5, -200, 0.5, -100),
            BackgroundColor3 = theme.Secondary,
            Parent = Services.CoreGui
        })
        
        local corner = InstanceManager.create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = dialog
        })
        
        local overlay = InstanceManager.create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.5,
            Parent = dialog.Parent
        })
        
        local container = InstanceManager.create("Frame", {
            Size = UDim2.new(1, -40, 1, -40),
            Position = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Parent = dialog
        })
        
        local title = InstanceManager.create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = properties.Title or "Dialog",
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            Parent = container
        })
        
        local message = InstanceManager.create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = properties.Message or "",
            TextColor3 = theme.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextWrapped = true,
            Parent = container
        })
        
        local buttonContainer = InstanceManager.create("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 1, -40),
            BackgroundTransparency = 1,
            Parent = container
        })
        
        if properties.Buttons then
            local buttonWidth = 100
            local spacing = 10
            local totalWidth = (#properties.Buttons * buttonWidth) + ((#properties.Buttons - 1) * spacing)
            local startX = (400 - totalWidth) / 2
            
            for i, btnProps in ipairs(properties.Buttons) do
                local button = InstanceManager.create("TextButton", {
                    Size = UDim2.new(0, buttonWidth, 1, 0),
                    Position = UDim2.new(0, startX + ((i-1) * (buttonWidth + spacing)), 0, 0),
                    BackgroundColor3 = btnProps.Primary and theme.Accent or theme.Main,
                    Text = btnProps.Text,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 14,
                    Parent = buttonContainer
                })
                
                local btnCorner = InstanceManager.create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = button
                })
                
                if btnProps.OnClick then
                    button.MouseButton1Click:Connect(function()
                        btnProps.OnClick()
                        dialog:Destroy()
                        overlay:Destroy()
                    end)
                end
            end
        end
        
        table.insert(self._activeDialogs, dialog)
        return dialog
    end
}

-- Part 12: Main Export & Integration
local ProgLib = {
    Theme = ThemeManager.Themes.Default.Dark,
    Animation = AnimationSystem,
    UI = {
        Components = UIComponents,
        Advanced = AdvancedComponents,
        Window = WindowSystem.Window,
        Modal = ModalSystem,
        Notification = NotificationSystem,
        ContextMenu = ContextMenuSystem,
        Dialog = DialogSystem,
        Help = HelpSystem,
        InstanceManager = InstanceManager
    },
    
    setTheme = function(self, themeName)
        if ThemeManager.Themes.Default[themeName] then
            self.Theme = ThemeManager.Themes.Default[themeName]
            ThemeManager:setTheme(themeName)
        end
    end,
    
    cleanup = function()
        InstanceManager.cleanup()
    end
}

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == game:GetService("Players").LocalPlayer then
        ProgLib.cleanup()
    end
end)

return ProgLib


-- الجزء 13: نظام التأثيرات المتقدمة 
local AdvancedEffects = {
    _effects = {},

    createGlow = function(instance, properties)
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.new(1, 20, 1, 20)
        glow.Position = UDim2.new(0, -10, 0, -10)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://7341141225"
        glow.ImageColor3 = properties.Color or Color3.fromRGB(255, 255, 255)
        glow.ImageTransparency = properties.Transparency or 0.8
        glow.Parent = instance
        
        return glow
    end,

    createBlur = function(instance, properties)
        local blur = Instance.new("BlurEffect")
        blur.Size = properties.Size or 10
        blur.Parent = instance
        
        return blur
    end,

    createShadow = function(instance, properties)
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 40, 1, 40)
        shadow.Position = UDim2.new(0, -20, 0, -20)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://7341141225"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = properties.Transparency or 0.7
        shadow.Parent = instance
        
        return shadow
    end
}

-- الجزء 14: نظام الأزرار المتقدمة
local AdvancedButtons = {
    createGradientButton = function(properties)
        local button = Instance.new("TextButton")
        button.Size = properties.Size or UDim2.new(0, 200, 0, 50)
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = properties.Text or "زر"
        button.TextColor3 = properties.TextColor or Color3.fromRGB(255, 255, 255)
        button.Font = properties.Font or Enum.Font.GothamBold
        button.TextSize = properties.TextSize or 14
        button.AutoButtonColor = false

        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, properties.GradientStart or Color3.fromRGB(60, 145, 255)),
            ColorSequenceKeypoint.new(1, properties.GradientEnd or Color3.fromRGB(40, 125, 235))
        })
        gradient.Parent = button

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button

        return button
    end,
}

-- الجزء 15: نظام الحركات 
local Animations = {
    slideIn = function(instance, direction, duration)
        local startPos = instance.Position
        local offScreen
        
        if direction == "right" then
            offScreen = UDim2.new(1, 50, startPos.Y.Scale, startPos.Y.Offset)
        elseif direction == "left" then
            offScreen = UDim2.new(-1, -50, startPos.Y.Scale, startPos.Y.Offset)
        elseif direction == "up" then
            offScreen = UDim2.new(startPos.X.Scale, startPos.X.Offset, -1, -50)
        elseif direction == "down" then
            offScreen = UDim2.new(startPos.X.Scale, startPos.X.Offset, 1, 50)
        end
        
        instance.Position = offScreen
        local tween = game:GetService("TweenService"):Create(
            instance,
            TweenInfo.new(duration or 0.5, Enum.EasingStyle.Back),
            {Position = startPos}
        )
        tween:Play()
        return tween
    end,
}


-- الجزء 16: نظام القوائم المتقدم
local AdvancedMenuSystem = {
   createMenu = function(properties)
       local menu = Instance.new("Frame")
       menu.Size = UDim2.new(0, 200, 0, 300)
       menu.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
       menu.BorderSizePixel = 0

       local title = Instance.new("TextLabel")
       title.Size = UDim2.new(1, 0, 0, 40)
       title.BackgroundTransparency = 1
       title.Text = properties.Title or "القائمة"
       title.TextColor3 = Color3.fromRGB(255, 255, 255)
       title.Font = Enum.Font.GothamBold
       title.TextSize = 16
       title.Parent = menu

       local items = Instance.new("ScrollingFrame")
       items.Size = UDim2.new(1, 0, 1, -40)
       items.Position = UDim2.new(0, 0, 0, 40)
       items.BackgroundTransparency = 1
       items.ScrollBarThickness = 4
       items.Parent = menu

       return menu
   end
}

-- الجزء 17: نظام التحكم بالألوان
local ColorSystem = {
   _activeColors = {},
   
   createColorPicker = function(properties)
       local picker = Instance.new("Frame")
       picker.Size = UDim2.new(0, 200, 0, 250)
       picker.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
       
       local hueSlider = Instance.new("Frame")
       hueSlider.Size = UDim2.new(1, -20, 0, 20)
       hueSlider.Position = UDim2.new(0, 10, 1, -30)
       hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
       hueSlider.Parent = picker
       
       local colorDisplay = Instance.new("Frame")
       colorDisplay.Size = UDim2.new(1, -20, 1, -60)
       colorDisplay.Position = UDim2.new(0, 10, 0, 10)
       colorDisplay.BackgroundColor3 = properties.DefaultColor or Color3.fromRGB(255, 0, 0)
       colorDisplay.Parent = picker
       
       return picker
   end
}

-- الجزء 18: نظام التأثيرات الحركية
local MotionEffects = {
   _effects = {},
   
   createWave = function(instance)
       local wave = Instance.new("Frame")
       wave.Size = UDim2.new(0, 0, 0, 0)
       wave.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
       wave.BackgroundTransparency = 0.8
       wave.Parent = instance
       
       local animation = game:GetService("TweenService"):Create(
           wave,
           TweenInfo.new(0.5),
           {
               Size = UDim2.new(2, 0, 2, 0),
               BackgroundTransparency = 1
           }
       )
       
       animation:Play()
       animation.Completed:Connect(function()
           wave:Destroy()
       end)
   end,
   
   createPulse = function(instance, properties)
       local originalSize = instance.Size
       local expandedSize = UDim2.new(
           originalSize.X.Scale * 1.1,
           originalSize.X.Offset,
           originalSize.Y.Scale * 1.1,
           originalSize.Y.Offset
       )
       
       while true do
           local expand = game:GetService("TweenService"):Create(
               instance,
               TweenInfo.new(0.5),
               {Size = expandedSize}
           )
           
           local shrink = game:GetService("TweenService"):Create(
               instance,
               TweenInfo.new(0.5),
               {Size = originalSize}
           )
           
           expand:Play()
           wait(0.5)
           shrink:Play()
           wait(0.5)
       end
   end
}

-- الجزء 19: نظام الأشكال المتقدم
local ShapeSystem = {
   createCircle = function(properties)
       local circle = Instance.new("Frame")
       circle.Size = properties.Size or UDim2.new(0, 100, 0, 100)
       circle.BackgroundColor3 = properties.Color or Color3.fromRGB(255, 255, 255)
       
       local corner = Instance.new("UICorner")
       corner.CornerRadius = UDim.new(1, 0)
       corner.Parent = circle
       
       return circle
   end,
   
   createTriangle = function(properties)
       local triangle = Instance.new("ImageLabel")
       triangle.Size = properties.Size or UDim2.new(0, 100, 0, 100)
       triangle.BackgroundTransparency = 1
       triangle.Image = "rbxassetid://triangle_image_id"
       triangle.ImageColor3 = properties.Color or Color3.fromRGB(255, 255, 255)
       
       return triangle
   end
}

-- الجزء 20: نظام الإشعارات المتقدم
local AdvancedNotifications = {
   _queue = {},
   
   show = function(properties)
       local notification = Instance.new("Frame")
       notification.Size = UDim2.new(0, 300, 0, 80)
       notification.Position = UDim2.new(1, 20, 1, -90)
       notification.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
       
       local title = Instance.new("TextLabel")
       title.Text = properties.Title or "إشعار"
       title.Parent = notification
       
       local message = Instance.new("TextLabel")
       message.Text = properties.Message or ""
       message.Parent = notification
       
       game:GetService("TweenService"):Create(
           notification,
           TweenInfo.new(0.5),
           {Position = UDim2.new(1, -320, 1, -90)}
       ):Play()
       
       wait(properties.Duration or 3)
       
       game:GetService("TweenService"):Create(
           notification,
           TweenInfo.new(0.5),
           {Position = UDim2.new(1, 20, 1, -90)}
       ):Play()
       
       wait(0.5)
       notification:Destroy()
   end
}

return {
   AdvancedMenu = AdvancedMenuSystem,
   ColorPicker = ColorSystem,
   Motion = MotionEffects,
   Shapes = ShapeSystem,
   Notifications = AdvancedNotifications
}

-- الجزء 21: نظام الرسوم المتحركة المتقدم
local AnimationsPlus = {
   createFloating = function(instance)
       local originalPosition = instance.Position
       
       while true do
           local upTween = game:GetService("TweenService"):Create(
               instance,
               TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
               {Position = UDim2.new(
                   originalPosition.X.Scale,
                   originalPosition.X.Offset,
                   originalPosition.Y.Scale,
                   originalPosition.Y.Offset - 10
               )}
           )
           
           local downTween = game:GetService("TweenService"):Create(
               instance,
               TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
               {Position = originalPosition}
           )
           
           upTween:Play()
           wait(1.5)
           downTween:Play()
           wait(1.5)
       end
   end,
   
   createSpinning = function(instance, speed)
       local rotation = 0
       
       game:GetService("RunService").RenderStepped:Connect(function()
           rotation = rotation + (speed or 1)
           instance.Rotation = rotation
           
           if rotation >= 360 then
               rotation = 0
           end
       end)
   end,
   
   createBouncing = function(instance)
       local originalSize = instance.Size
       
       while true do
           local squeezeTween = game:GetService("TweenService"):Create(
               instance,
               TweenInfo.new(0.5, Enum.EasingStyle.Bounce),
               {
                   Size = UDim2.new(
                       originalSize.X.Scale * 0.9,
                       originalSize.X.Offset,
                       originalSize.Y.Scale * 1.1,
                       originalSize.Y.Offset
                   )
               }
           )
           
           local restoreTween = game:GetService("TweenService"):Create(
               instance,
               TweenInfo.new(0.5, Enum.EasingStyle.Bounce),
               {Size = originalSize}
           )
           
           squeezeTween:Play()
           wait(0.5)
           restoreTween:Play()
           wait(0.5)
       end
   end
}

-- الجزء 22: نظام القوائم المنسدلة المتقدم
local AdvancedDropdown = {
   create = function(properties)
       local dropdown = Instance.new("Frame")
       dropdown.Size = UDim2.new(0, 200, 0, 40)
       dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
       
       local selected = Instance.new("TextLabel")
       selected.Size = UDim2.new(1, -40, 1, 0)
       selected.Position = UDim2.new(0, 10, 0, 0)
       selected.BackgroundTransparency = 1
       selected.Text = properties.Placeholder or "اختر..."
       selected.TextColor3 = Color3.fromRGB(200, 200, 200)
       selected.TextXAlignment = Enum.TextXAlignment.Left
       selected.Parent = dropdown
       
       local arrow = Instance.new("TextLabel")
       arrow.Size = UDim2.new(0, 20, 1, 0)
       arrow.Position = UDim2.new(1, -30, 0, 0)
       arrow.BackgroundTransparency = 1
       arrow.Text = "▼"
       arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
       arrow.Parent = dropdown
       
       local optionsList = Instance.new("Frame")
       optionsList.Size = UDim2.new(1, 0, 0, 0)
       optionsList.Position = UDim2.new(0, 0, 1, 0)
       optionsList.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
       optionsList.Visible = false
       optionsList.Parent = dropdown
       
       return dropdown
   end
}

-- الجزء 23: نظام التحديثات التلقائية
local AutoUpdateSystem = {
   _version = "5.0.0",
   _components = {},
   
   registerComponent = function(self, component)
       table.insert(self._components, component)
   end,
   
   refreshAll = function(self)
       for _, component in ipairs(self._components) do
           if component.refresh then
               component:refresh()
           end
       end
   end,
   
   checkForUpdates = function(self)
       -- هنا يمكن إضافة منطق للتحقق من التحديثات
       return false
   end
}

-- الجزء 24: نظام الأداء المتقدم
local PerformanceSystem = {
   _monitoring = false,
   _stats = {},
   
   startMonitoring = function(self)
       self._monitoring = true
       
       game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
           if self._monitoring then
               table.insert(self._stats, deltaTime)
               if #self._stats > 100 then
                   table.remove(self._stats, 1)
               end
           end
       end)
   end,
   
   getAverageFPS = function(self)
       if #self._stats == 0 then return 0 end
       
       local sum = 0
       for _, deltaTime in ipairs(self._stats) do
           sum = sum + (1 / deltaTime)
       end
       return sum / #self._stats
   end
}

-- الجزء 25: نظام التحكم بالنوافذ المتقدم
local WindowManager = {
   _windows = {},
   _activeWindow = nil,
   
   createWindow = function(self, properties)
       local window = Instance.new("Frame")
       window.Size = properties.Size or UDim2.new(0, 400, 0, 300)
       window.Position = properties.Position or UDim2.new(0.5, -200, 0.5, -150)
       window.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
       
       -- إضافة شريط العنوان
       local titleBar = Instance.new("Frame")
       titleBar.Size = UDim2.new(1, 0, 0, 30)
       titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
       titleBar.Parent = window
       
       local title = Instance.new("TextLabel")
       title.Size = UDim2.new(1, -60, 1, 0)
       title.BackgroundTransparency = 1
       title.Text = properties.Title or "نافذة جديدة"
       title.TextColor3 = Color3.fromRGB(255, 255, 255)
       title.Parent = titleBar
       
       local closeButton = Instance.new("TextButton")
       closeButton.Size = UDim2.new(0, 30, 0, 30)
       closeButton.Position = UDim2.new(1, -30, 0, 0)
       closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
       closeButton.Text = "×"
       closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
       closeButton.Parent = titleBar
       
       table.insert(self._windows, window)
       return window
   end
}
