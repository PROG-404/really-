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

-- Enhanced Animation System
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


-- Enhanced UI Components
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


-- Window System
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


-- Export & Integration
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


-- Advanced Components
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


-- الجزء 26: نظام الأمان المتقدم
local SecuritySystem = {
    _encryptionKey = nil,
    
    initialize = function(self, key)
        self._encryptionKey = key
    end,
    
    encrypt = function(self, data)
        if not self._encryptionKey then return data end
        -- تنفيذ التشفير
        return data 
    end,
    
    decrypt = function(self, data)
        if not self._encryptionKey then return data end
        -- تنفيذ فك التشفير
        return data
    end
}

-- الجزء 27: نظام التخزين المتقدم 
local StorageSystem = {
    _cache = {},
    
    save = function(self, key, value)
        self._cache[key] = value
        -- حفظ في التخزين المحلي
    end,
    
    load = function(self, key)
        return self._cache[key]
    end,
    
    clear = function(self)
        table.clear(self._cache)
    end
}

-- الجزء 28: نظام التحكم بالصوت
local AudioSystem = {
    _sounds = {},
    
    playSound = function(self, id, properties)
        local sound = Instance.new("Sound")
        sound.SoundId = id
        sound.Volume = properties.Volume or 1
        sound.Parent = game.Workspace
        sound:Play()
        
        table.insert(self._sounds, sound)
        return sound
    end,
    
    stopAll = function(self)
        for _, sound in ipairs(self._sounds) do
            sound:Stop()
            sound:Destroy()
        end
        table.clear(self._sounds)
    end
}

-- الجزء 29: نظام الحركة المتقدم
local AdvancedMotion = {
    createPath = function(points)
        local path = {}
        for i = 1, #points do
            path[i] = points[i]
        end
        return path
    end,
    
    followPath = function(instance, path, speed)
        for i = 1, #path do
            local point = path[i]
            local tween = game:GetService("TweenService"):Create(
                instance,
                TweenInfo.new(speed),
                {Position = point}
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end
}

-- الجزء 30: نظام التأثيرات البصرية
local VisualEffects = {
    createParticles = function(parent, properties)
        local emitter = Instance.new("ParticleEmitter")
        emitter.Rate = properties.Rate or 50
        emitter.Speed = NumberRange.new(properties.Speed or 5)
        emitter.Color = properties.Color or ColorSequence.new(Color3.new(1, 1, 1))
        emitter.Parent = parent
        return emitter
    end,
    
    createTrail = function(parent, properties)
        local trail = Instance.new("Trail")
        trail.Color = properties.Color or ColorSequence.new(Color3.new(1, 1, 1))
        trail.Transparency = properties.Transparency or NumberSequence.new(0)
        trail.Parent = parent
        return trail
    end
}

-- الجزء 31: نظام التحكم بالكاميرا المتقدم
local CameraSystem = {
   _camera = workspace.CurrentCamera,
   
   setPosition = function(self, position)
       self._camera.CFrame = CFrame.new(position)
   end,
   
   follow = function(self, target, offset)
       game:GetService("RunService").RenderStepped:Connect(function()
           if target then
               self._camera.CFrame = CFrame.new(target.Position + offset)
           end
       end)
   end,
   
   shake = function(self, duration, intensity)
       local startTime = tick()
       local connection
       
       connection = game:GetService("RunService").RenderStepped:Connect(function()
           local elapsed = tick() - startTime
           if elapsed >= duration then
               connection:Disconnect()
               return
           end
           
           local randomOffset = Vector3.new(
               math.random(-intensity, intensity),
               math.random(-intensity, intensity),
               math.random(-intensity, intensity)
           )
           
           self._camera.CFrame = self._camera.CFrame * CFrame.new(randomOffset)
       end)
   end
}

-- الجزء 32: نظام الأحداث المتقدم
local EventSystem = {
   _events = {},
   
   create = function(self, name)
       self._events[name] = {
           callbacks = {},
           
           connect = function(self, callback)
               table.insert(self.callbacks, callback)
               
               return {
                   disconnect = function()
                       local index = table.find(self.callbacks, callback)
                       if index then
                           table.remove(self.callbacks, index)
                       end
                   end
               }
           end
       }
       
       return self._events[name]  
   end,
   
   fire = function(self, name, ...)
       local event = self._events[name]
       if event then
           for _, callback in ipairs(event.callbacks) do
               callback(...)
           end
       end
   end
}

-- الجزء 33: نظام التحكم بالشبكة
local NetworkSystem = {
   _remotes = {},
   
   createRemote = function(self, name, remoteType)
       local remote
       if remoteType == "Event" then
           remote = Instance.new("RemoteEvent")
       elseif remoteType == "Function" then  
           remote = Instance.new("RemoteFunction")
       end
       
       remote.Name = name
       remote.Parent = game:GetService("ReplicatedStorage")
       self._remotes[name] = remote
       
       return remote
   end,
   
   fireServer = function(self, name, ...)
       local remote = self._remotes[name]
       if remote and remote:IsA("RemoteEvent") then
           remote:FireServer(...)
       end
   end,
   
   fireClient = function(self, name, player, ...)
       local remote = self._remotes[name]
       if remote and remote:IsA("RemoteEvent") then
           remote:FireClient(player, ...)
       end
   end
}

-- الجزء 34: نظام الحماية من التلاعب
local AntiExploitSystem = {
   _checks = {},
   
   addCheck = function(self, name, checkFunction)
       self._checks[name] = checkFunction
   end,
   
   runChecks = function(self)
       for name, check in pairs(self._checks) do
           local success, result = pcall(check)
           if not success or result == false then
               -- تنفيذ إجراء عند اكتشاف تلاعب
               print("Exploit detected:", name)
           end
       end
   end
}

-- الجزء 35: نظام التحكم بالأداء
local PerformanceOptimizer = {
   _monitoring = false,
   _threshold = 30, -- FPS
   
   startMonitoring = function(self)
       self._monitoring = true
       
       game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
           if not self._monitoring then return end
           
           local fps = 1/deltaTime
           if fps < self._threshold then
               self:optimize()
           end
       end)
   end,
   
   optimize = function(self)
       -- تحسين الأداء تلقائياً
       workspace.StreamingEnabled = true
       settings().Rendering.QualityLevel = 1
   end,
   
   setThreshold = function(self, fps)
       self._threshold = fps
   end
}

-- الجزء 36: نظام الواجهات المتقدم
local AdvancedUI = {
   createResponsiveFrame = function(properties)
       local frame = Instance.new("Frame")
       frame.Size = properties.Size or UDim2.new(1, 0, 1, 0)
       frame.BackgroundColor3 = properties.Color or Color3.new(1, 1, 1)
       
       -- جعل الإطار متجاوب
       local uiAspect = Instance.new("UIAspectRatioConstraint")
       uiAspect.Parent = frame
       
       -- إضافة حدود متحركة
       local uiStroke = Instance.new("UIStroke")
       uiStroke.Color = properties.StrokeColor or Color3.new(0, 0, 0)
       uiStroke.Thickness = properties.StrokeThickness or 2
       uiStroke.Parent = frame
       
       return frame
   end,
   
   createAnimatedButton = function(properties)
       local button = Instance.new("TextButton")
       button.Size = properties.Size or UDim2.new(0, 200, 0, 50)
       button.BackgroundColor3 = properties.Color or Color3.new(0, 0.5, 1)
       button.Text = properties.Text or "Button"
       
       -- إضافة تأثيرات التحويم
       button.MouseEnter:Connect(function()
           game:GetService("TweenService"):Create(
               button,
               TweenInfo.new(0.3),
               {BackgroundColor3 = properties.HoverColor or Color3.new(0, 0.7, 1)}
           ):Play()
       end)
       
       button.MouseLeave:Connect(function()
           game:GetService("TweenService"):Create(
               button,
               TweenInfo.new(0.3),
               {BackgroundColor3 = properties.Color or Color3.new(0, 0.5, 1)}
           ):Play()
       end)
       
       return button
   end
}


-- الجزء 37: نظام الخرائط الديناميكية
local DynamicMapSystem = {
    _chunks = {},
    _chunkSize = 32,
    
    generateChunk = function(self, x, z)
        local chunk = Instance.new("Model")
        chunk.Name = string.format("Chunk_%d_%d", x, z)
        
        -- توليد التضاريس
        for dx = 0, self._chunkSize-1 do
            for dz = 0, self._chunkSize-1 do
                local worldX = x * self._chunkSize + dx
                local worldZ = z * self._chunkSize + dz
                
                local height = math.noise(worldX * 0.1, worldZ * 0.1) * 10
                
                local part = Instance.new("Part")
                part.Size = Vector3.new(1, 1, 1)
                part.Position = Vector3.new(worldX, height, worldZ)
                part.Parent = chunk
            end
        end
        
        self._chunks[string.format("%d_%d", x, z)] = chunk
        chunk.Parent = workspace
        
        return chunk
    end,
    
    loadChunksAround = function(self, position)
        local chunkX = math.floor(position.X / self._chunkSize)
        local chunkZ = math.floor(position.Z / self._chunkSize)
        
        for dx = -1, 1 do
            for dz = -1, 1 do
                local x = chunkX + dx
                local z = chunkZ + dz
                
                if not self._chunks[string.format("%d_%d", x, z)] then
                    self:generateChunk(x, z)
                end
            end
        end
    end
}

-- الجزء 38: نظام الظل المتقدم
local AdvancedShadowSystem = {
    createShadowLight = function(position, properties)
        local light = Instance.new("SpotLight")
        light.Position = position
        light.Range = properties.Range or 50
        light.Brightness = properties.Brightness or 2
        light.Shadows = true
        
        -- إضافة تأثيرات حركة الظل
        game:GetService("RunService").RenderStepped:Connect(function()
            light.Position = light.Position + Vector3.new(
                math.sin(tick()) * 0.1,
                0,
                math.cos(tick()) * 0.1
            )
        end)
        
        return light
    end,
    
    createVolumetricLight = function(position, properties)
        local light = Instance.new("PointLight")
        light.Position = position
        light.Range = properties.Range or 30
        light.Brightness = properties.Brightness or 3
        
        -- إضافة تأثير الضوء الحجمي
        local attachment = Instance.new("Attachment")
        attachment.Parent = light
        
        local beam = Instance.new("Beam")
        beam.Attachment0 = attachment
        beam.Width0 = properties.Width or 2
        beam.Width1 = 0
        beam.FaceCamera = true
        
        return light
    end
}

-- الجزء 39: نظام الفيزياء المتقدم
local AdvancedPhysics = {
    _constraints = {},
    
    createRope = function(startPos, endPos, properties)
        local rope = Instance.new("RopeConstraint")
        rope.Length = (startPos - endPos).Magnitude
        rope.Thickness = properties.Thickness or 1
        
        local attachment0 = Instance.new("Attachment")
        attachment0.Position = startPos
        
        local attachment1 = Instance.new("Attachment")
        attachment1.Position = endPos
        
        rope.Attachment0 = attachment0
        rope.Attachment1 = attachment1
        
        table.insert(self._constraints, rope)
        return rope
    end,
    
    createHinge = function(part0, part1, properties)
        local hinge = Instance.new("HingeConstraint")
        hinge.ActuatorType = Enum.ActuatorType.Motor
        hinge.AngularSpeed = properties.Speed or 5
        hinge.AngularResponsiveness = properties.Responsiveness or 10
        
        hinge.Part0 = part0
        hinge.Part1 = part1
        
        table.insert(self._constraints, hinge)
        return hinge
    end
}


-- الجزء 36: نظام الشبكات المتقدم
local NetworkSystem = {
   _connections = {},
   _events = {},
   
   createConnection = function(name, callback)
       NetworkSystem._connections[name] = callback
   end,
   
   fireEvent = function(name, ...)
       if NetworkSystem._connections[name] then
           NetworkSystem._connections[name](...)
       end
   end,
   
   broadcast = function(eventName, data)
       table.insert(NetworkSystem._events, {
           name = eventName,
           data = data,
           timestamp = os.time()
       })
   end
}

-- الجزء 37: نظام التحكم بالكاميرا المتقدم
local CameraSystem = {
   _camera = workspace.CurrentCamera,
   
   setPosition = function(position)
       CameraSystem._camera.CFrame = CFrame.new(position)
   end,
   
   lookAt = function(target)
       CameraSystem._camera.CFrame = CFrame.new(CameraSystem._camera.CFrame.Position, target)
   end,
   
   shake = function(intensity, duration)
       local startTime = os.clock()
       local connection
       
       connection = game:GetService("RunService").RenderStepped:Connect(function()
           local elapsed = os.clock() - startTime
           if elapsed >= duration then
               connection:Disconnect()
               return
           end
           
           local offset = Vector3.new(
               math.random(-intensity, intensity),
               math.random(-intensity, intensity),
               math.random(-intensity, intensity)
           )
           
           CameraSystem._camera.CFrame = CameraSystem._camera.CFrame * CFrame.new(offset)
       end)
   end
}

-- الجزء 38: نظام الأحداث المتقدم
local EventSystem = {
   _events = {},
   
   on = function(eventName, callback)
       if not EventSystem._events[eventName] then
           EventSystem._events[eventName] = {}
       end
       table.insert(EventSystem._events[eventName], callback)
   end,
   
   emit = function(eventName, ...)
       if EventSystem._events[eventName] then
           for _, callback in ipairs(EventSystem._events[eventName]) do
               callback(...)
           end
       end
   end,
   
   clear = function(eventName)
       EventSystem._events[eventName] = nil
   end
}

-- الجزء 39: نظام التحكم بالوقت
local TimeSystem = {
   _time = 0,
   _scale = 1,
   _callbacks = {},
   
   update = function(dt)
       TimeSystem._time = TimeSystem._time + dt * TimeSystem._scale
       
       for time, callbacks in pairs(TimeSystem._callbacks) do
           if TimeSystem._time >= time then
               for _, callback in ipairs(callbacks) do
                   callback()
               end
               TimeSystem._callbacks[time] = nil
           end
       end
   end,
   
   setTimeScale = function(scale)
       TimeSystem._scale = scale
   end,
   
   after = function(delay, callback)
       local targetTime = TimeSystem._time + delay
       if not TimeSystem._callbacks[targetTime] then
           TimeSystem._callbacks[targetTime] = {}
       end
       table.insert(TimeSystem._callbacks[targetTime], callback)
   end
}

-- الجزء 40: نظام الجسيمات المتقدم
local ParticleSystem = {
   _emitters = {},
   
   createEmitter = function(properties)
       local emitter = Instance.new("ParticleEmitter")
       emitter.Rate = properties.Rate or 50
       emitter.Lifetime = properties.Lifetime or NumberRange.new(1)
       emitter.Speed = properties.Speed or NumberRange.new(5)
       emitter.SpreadAngle = properties.SpreadAngle or Vector2.new(0, 360)
       emitter.Color = properties.Color or ColorSequence.new(Color3.new(1, 1, 1))
       
       table.insert(ParticleSystem._emitters, emitter)
       return emitter
   end,
   
   burst = function(emitter, amount)
       emitter:Emit(amount)
   end,
   
   stopAll = function()
       for _, emitter in ipairs(ParticleSystem._emitters) do
           emitter.Enabled = false
       end
   end
}

-- الجزء 41: نظام التحكم بالأداء المتقدم
local PerformanceController = {
   _monitoring = false,
   _metrics = {},
   
   startMonitoring = function()
       local connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
           table.insert(PerformanceController._metrics, {
               frameTime = dt,
               timestamp = os.clock()
           })
       end)
       return connection
   end,
   
   analyzePerformance = function()
       local totalFrameTime = 0
       for _, metric in ipairs(PerformanceController._metrics) do
           totalFrameTime = totalFrameTime + metric.frameTime
       end
       return totalFrameTime / #PerformanceController._metrics
   end
}

-- الجزء 42: نظام التحكم بالمواد المتقدم
local MaterialSystem = {
   createMaterial = function(properties)
       local material = {
           color = properties.Color or Color3.new(1, 1, 1),
           transparency = properties.Transparency or 0,
           reflectance = properties.Reflectance or 0,
           texture = properties.Texture
       }
       return material
   end,
   
   applyMaterial = function(part, material)
       part.Color = material.color
       part.Transparency = material.transparency
       part.Reflectance = material.reflectance
       if material.texture then
           local texture = Instance.new("Texture")
           texture.Texture = material.texture
           texture.Parent = part
       end
   end
}

-- الجزء 43: نظام المؤثرات البصرية المتقدم
local VisualFXSystem = {
   createBlur = function(parent, properties)
       local blur = Instance.new("BlurEffect")
       blur.Size = properties.Size or 10
       blur.Parent = parent
       return blur
   end,
   
   createBloom = function(parent, properties)
       local bloom = Instance.new("BloomEffect")
       bloom.Intensity = properties.Intensity or 1
       bloom.Size = properties.Size or 24
       bloom.Threshold = properties.Threshold or 2
       bloom.Parent = parent
       return bloom
   end,
   
   createSunRays = function(parent, properties)
       local sunRays = Instance.new("SunRaysEffect")
       sunRays.Intensity = properties.Intensity or 0.25
       sunRays.Spread = properties.Spread or 1
       sunRays.Parent = parent
       return sunRays
   end
}

-- الجزء 44: نظام التحكم بالصوت المتقدم
local AdvancedAudioSystem = {
   _sounds = {},
   
   createSound = function(properties)
       local sound = Instance.new("Sound")
       sound.SoundId = properties.SoundId
       sound.Volume = properties.Volume or 1
       sound.Pitch = properties.Pitch or 1
       sound.Looped = properties.Looped or false
       
       if properties.Effects then
           for _, effect in ipairs(properties.Effects) do
               local soundEffect = Instance.new(effect.Type)
               for property, value in pairs(effect.Properties) do
                   soundEffect[property] = value
               end
               soundEffect.Parent = sound
           end
       end
       
       table.insert(AdvancedAudioSystem._sounds, sound)
       return sound
   end,
   
   fadeVolume = function(sound, targetVolume, duration)
       local tween = game:GetService("TweenService"):Create(
           sound,
           TweenInfo.new(duration, Enum.EasingStyle.Linear),
           {Volume = targetVolume}
       )
       tween:Play()
       return tween
   end
}

-- الجزء 45: نظام التحكم بالحركة المتقدم
local AdvancedMotionSystem = {
   createMotion = function(instance, properties)
       local motion = {
           instance = instance,
           startPos = instance.Position,
           endPos = properties.EndPosition,
           duration = properties.Duration or 1,
           easingStyle = properties.EasingStyle or Enum.EasingStyle.Linear,
           easingDirection = properties.EasingDirection or Enum.EasingDirection.Out
       }
       
       return motion
   end,
   
   play = function(motion, onComplete)
       local tween = game:GetService("TweenService"):Create(
           motion.instance,
           TweenInfo.new(
               motion.duration,
               motion.easingStyle,
               motion.easingDirection
           ),
           {Position = motion.endPos}
       )
       
       if onComplete then
           tween.Completed:Connect(onComplete)
       end
       
       tween:Play()
       return tween
   end
}

function window:CreateTab(name)
    local tab = {
        sections = {}
    }
    
    local tabButton = CreateElement("TextButton", {
        Size = UDim2.new(0, 100, 0, 30),
        BackgroundColor3 = Library.Colors.ElementBackground,
        Text = name,
        TextColor3 = Library.Colors.Text,
        Font = Library.Fonts.Regular,
        TextSize = 14
    })
    AddCorner(tabButton)
    tabButton.Parent = titleBar  -- You might want to create a separate TabBar

    function tab:AddSection(sectionName)
        local section = {
            frame = CreateElement("Frame", {
                Size = UDim2.new(1, -10, 0, 0),
                BackgroundColor3 = Library.Colors.Secondary,
                AutomaticSize = Enum.AutomaticSize.Y
            })
        }
        AddCorner(section.frame)

        local sectionTitle = CreateElement("TextLabel", {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = sectionName,
            TextColor3 = Library.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Library.Fonts.SemiBold
        })
        sectionTitle.Parent = section.frame

        local sectionContent = CreateElement("Frame", {
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 40),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        })
        sectionContent.Parent = section.frame

        function section:AddControl(control)
            control.Parent = sectionContent
            return control
        end

        section.frame.Parent = contentArea
        table.insert(tab.sections, section)
        return section
    end

    return tab
 end
  
function window:AddDropdown(text, options)
    local dropdown = CreateElement("Frame", {
        Size = UDim2.new(1, -10, 0, 35),
        BackgroundColor3 = Library.Colors.ElementBackground
    })
    AddCorner(dropdown)

    local dropdownText = CreateElement("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Library.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    dropdownText.Parent = dropdown

    local toggleButton = CreateElement("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 2),
        BackgroundColor3 = Library.Colors.Accent,
        Text = "▼",
        TextColor3 = Library.Colors.Text
    })
    AddCorner(toggleButton)
    toggleButton.Parent = dropdown

    local dropdownFrame = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Library.Colors.Secondary,
        Visible = false
    })
    AddCorner(dropdownFrame)
    dropdownFrame.Parent = dropdown

    local isOpen = false
    toggleButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownFrame.Visible = isOpen
        toggleButton.Text = isOpen and "▲" or "▼"

        if isOpen then
            for _, option in ipairs(options) do
                local optionButton = CreateElement("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.Colors.ElementBackground,
                    Text = option,
                    TextColor3 = Library.Colors.Text
                })
                optionButton.MouseButton1Click:Connect(function()
                    dropdownText.Text = option
                    toggleButton:FireClick()  -- Close dropdown
                end)
                optionButton.Parent = dropdownFrame
            end
        end
    end)

    dropdown.Parent = contentArea
    return dropdown
   end

function window:AddMultiSelect(text, options)
    local multiSelect = CreateElement("Frame", {
        Size = UDim2.new(1, -10, 0, 35),
        BackgroundColor3 = Library.Colors.ElementBackground
    })
    AddCorner(multiSelect)

    local selectText = CreateElement("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Library.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    selectText.Parent = multiSelect

    local toggleButton = CreateElement("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 2),
        BackgroundColor3 = Library.Colors.Accent,
        Text = "▼",
        TextColor3 = Library.Colors.Text
    })
    AddCorner(toggleButton)
    toggleButton.Parent = multiSelect

    local dropdownFrame = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Library.Colors.Secondary,
        Visible = false
    })
    AddCorner(dropdownFrame)
    dropdownFrame.Parent = multiSelect

    local selectedOptions = {}
    local isOpen = false

    toggleButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownFrame.Visible = isOpen
        toggleButton.Text = isOpen and "▲" or "▼"

        if isOpen then
            for _, option in ipairs(options) do
                local optionButton = CreateElement("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.Colors.ElementBackground,
                    Text = option,
                    TextColor3 = Library.Colors.Text
                })
                
                optionButton.MouseButton1Click:Connect(function()
                    if not selectedOptions[option] then
                        selectedOptions[option] = true
                        optionButton.BackgroundColor3 = Library.Colors.Accent
                    else
                        selectedOptions[option] = nil
                        optionButton.BackgroundColor3 = Library.Colors.ElementBackground
                    end

                    local selectedText = {}
                    for opt, _ in pairs(selectedOptions) do
                        table.insert(selectedText, opt)
                    end
                    selectText.Text = #selectedText > 0 and table.concat(selectedText, ", ") or text
                end)
                
                optionButton.Parent = dropdownFrame
            end
        end
    end)

    multiSelect.Parent = contentArea
    return multiSelect
end

function Library:CreateDraggableWindow(config)
    local window = {}
    local isDragging = false
    local dragInput
    local dragStart
    local startPos

    -- Main Window Frame
    local frame = CreateElement("Frame", {
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = Library.Colors.Primary,
        BorderSizePixel = 0
    })
    AddCorner(frame)
    AddShadow(frame)

    -- Draggable Header
    local header = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Library.Colors.Secondary,
        BorderSizePixel = 0
    })
    header.Parent = frame

    -- Title
    local titleLabel = CreateElement("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = config.Title or "Draggable Window",
        TextColor3 = Library.Colors.Text,
        BackgroundTransparency = 1,
        Font = Library.Fonts.Bold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    titleLabel.Parent = header

    -- Drag Functionality
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            update(input)
        end
    end)

    -- Snap to Grid
    local function snapToGrid(position, gridSize)
        gridSize = gridSize or 10
        local x = math.floor(position.X.Offset / gridSize + 0.5) * gridSize
        local y = math.floor(position.Y.Offset / gridSize + 0.5) * gridSize
        return UDim2.new(position.X.Scale, x, position.Y.Scale, y)
    end

    -- Optional Boundary Constraints
    local function constrainPosition(newPos)
        local screenSize = game.Workspace.CurrentCamera.ViewportSize
        local frameSize = frame.AbsoluteSize

        newPos = UDim2.new(
            newPos.X.Scale, 
            math.clamp(newPos.X.Offset, 0, screenSize.X - frameSize.X),
            newPos.Y.Scale, 
            math.clamp(newPos.Y.Offset, 0, screenSize.Y - frameSize.Y)
        )

        return newPos
    end

    -- Smooth Movement
    local function smoothMove(targetPos)
        local tweenInfo = TweenInfo.new(
            0.2, 
            Library.Settings.EasingStyle, 
            Enum.EasingDirection.Out
        )
        
        TweenService:Create(frame, tweenInfo, {
            Position = targetPos
        }):Play()
    end

    return {
        Frame = frame,
        SnapToGrid = function(gridSize) 
            local newPos = snapToGrid(frame.Position, gridSize)
            smoothMove(newPos)
        end,
        SetBoundary = function(min, max)
            -- Implement boundary logic here
        end
    }
end

function Library:CreateKeyBinder()
    local KeyBinder = {
        Bindings = {},
        Blacklist = {
            [Enum.KeyCode.Unknown] = true,
            [Enum.KeyCode.Backspace] = true,
            [Enum.KeyCode.Return] = true
        }
    }

    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")

    -- Create Keybind Frame
    local keybindFrame = CreateElement("Frame", {
        Size = UDim2.new(0, 300, 0, 400),
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = Library.Colors.Primary
    })
    AddCorner(keybindFrame)

    -- Keybind Title
    local titleLabel = CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Library.Colors.Secondary,
        Text = "Key Bindings",
        TextColor3 = Library.Colors.Text,
        TextSize = 18,
        Font = Library.Fonts.Bold
    })
    titleLabel.Parent = keybindFrame

    -- Scrolling Frame for Bindings
    local scrollFrame = CreateElement("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5
    })
    scrollFrame.Parent = keybindFrame

    -- Layout for Bindings
    local bindingLayout = CreateElement("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    bindingLayout.Parent = scrollFrame

    function KeyBinder:AddBinding(name, defaultKey)
        local binding = {
            Name = name,
            CurrentKey = defaultKey,
            Callback = nil
        }

        local bindingFrame = CreateElement("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Library.Colors.ElementBackground
        })
        AddCorner(bindingFrame)

        local nameLabel = CreateElement("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Text = name,
            TextColor3 = Library.Colors.Text,
            BackgroundTransparency = 1
        })
        nameLabel.Parent = bindingFrame

        local keyButton = CreateElement("TextButton", {
            Size = UDim2.new(0.3, 0, 1, 0),
            Position = UDim2.new(0.7, 0, 0, 0),
            Text = defaultKey and defaultKey.Name or "None",
            BackgroundColor3 = Library.Colors.Accent
        })
        AddCorner(keyButton)
        keyButton.Parent = bindingFrame

        -- Key Binding Logic
        keyButton.MouseButton1Click:Connect(function()
            keyButton.Text = "Press any key..."
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and not self.Blacklist[input.KeyCode] then
                    binding.CurrentKey = input.KeyCode
                    keyButton.Text = input.KeyCode.Name
                    
                    if connection then
                        connection:Disconnect()
                    end
                end
            end)
        end)

        function binding:SetCallback(func)
            self.Callback = func
        end

        bindingFrame.Parent = scrollFrame
        table.insert(self.Bindings, binding)

        return binding
    end

    -- Global Key Handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        for _, binding in ipairs(KeyBinder.Bindings) do
            if input.KeyCode == binding.CurrentKey and binding.Callback then
                binding.Callback()
            end
        end
    end)

    -- Save and Load Bindings
    function KeyBinder:SaveBindings()
        local savedBindings = {}
        for _, binding in ipairs(self.Bindings) do
            savedBindings[binding.Name] = binding.CurrentKey and binding.CurrentKey.Name or "None"
        end
        return savedBindings
    end

    function KeyBinder:LoadBindings(savedBindings)
        for _, binding in ipairs(self.Bindings) do
            local savedKey = savedBindings[binding.Name]
            if savedKey and savedKey ~= "None" then
                binding.CurrentKey = Enum.KeyCode[savedKey]
            end
        end
    end

    return KeyBinder
end

-- Usage Example
local keyBinder = Library:CreateKeyBinder()

local jumpBinding = keyBinder:AddBinding("Jump", Enum.KeyCode.Space)
jumpBinding:SetCallback(function()
    print("Jump Activated!")
end)

local sprintBinding = keyBinder:AddBinding("Sprint", Enum.KeyCode.LeftShift)
sprintBinding:SetCallback(function()
    print("Sprint Activated!")
end)

function Library:CreateThemeManager()
    local ThemeManager = {
        CurrentTheme = "Dark",
        Themes = {
            Dark = {
                Primary = Color3.fromRGB(30, 30, 45),
                Secondary = Color3.fromRGB(35, 35, 50),
                Accent = Color3.fromRGB(100, 190, 255),
                Text = Color3.fromRGB(255, 255, 255),
                Shadow = Color3.fromRGB(0, 0, 0)
            },
            Light = {
                Primary = Color3.fromRGB(240, 240, 250),
                Secondary = Color3.fromRGB(220, 220, 230),
                Accent = Color3.fromRGB(50, 100, 255),
                Text = Color3.fromRGB(20, 20, 30),
                Shadow = Color3.fromRGB(100, 100, 100)
            },
            Cyberpunk = {
                Primary = Color3.fromRGB(20, 20, 30),
                Secondary = Color3.fromRGB(40, 40, 60),
                Accent = Color3.fromRGB(0, 255, 200),
                Text = Color3.fromRGB(0, 255, 200),
                Shadow = Color3.fromRGB(0, 100, 100)
            }
        },
        AppliedElements = {}
    }

    function ThemeManager:CreateThemeSelector()
        local selectorFrame = CreateElement("Frame", {
            Size = UDim2.new(0, 200, 0, 300),
            BackgroundColor3 = self.Themes.Dark.Primary
        })
        AddCorner(selectorFrame)

        for themeName, themeColors in pairs(self.Themes) do
            local themeButton = CreateElement("TextButton", {
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, #selectorFrame:GetChildren() * 50),
                Text = themeName,
                BackgroundColor3 = themeColors.Accent
            })
            AddCorner(themeButton)
            themeButton.Parent = selectorFrame

            themeButton.MouseButton1Click:Connect(function()
                self:ApplyTheme(themeName)
            end)
        end

        return selectorFrame
    end

    function ThemeManager:ApplyTheme(themeName)
        local theme = self.Themes[themeName]
        self.CurrentTheme = themeName

        for _, element in ipairs(self.AppliedElements) do
            if element.Type == "Frame" then
                element.Object.BackgroundColor3 = theme.Primary
            elseif element.Type == "Button" then
                element.Object.BackgroundColor3 = theme.Accent
            elseif element.Type == "Text" then
                element.Object.TextColor3 = theme.Text
            end

            -- Shadow/Blur Effect
            if element.Shadow then
                element.Shadow.BackgroundColor3 = theme.Shadow
                element.Shadow.BackgroundTransparency = 0.5
            end
        end
    end

    function ThemeManager:TrackElement(element, elementType, addShadow)
        local shadowObj = nil
        if addShadow then
            shadowObj = AddShadow(element, 0.5)
        end

        table.insert(self.AppliedElements, {
            Object = element,
            Type = elementType,
            Shadow = shadowObj
        })

        return element
    end

    return ThemeManager
end

-- Usage Example
local themeManager = Library:CreateThemeManager()

-- Create a themed window with shadow
local window = Library:CreateWindow({Title = "Themed Window"})
local themeSelector = themeManager:CreateThemeSelector()

-- Track and theme elements
local button = themeManager:TrackElement(
    window:AddButton("Themed Button", function() end), 
    "Button", 
    true  -- Add shadow
)

function Library:CreateWindowScaler(window)
    local ScaleManager = {
        CurrentScale = 1,
        ScaleSteps = {
            {Name = "Tiny", Scale = 0.5},
            {Name = "Normal", Scale = 1},
            {Name = "Large", Scale = 1.5},
            {Name = "Extra Large", Scale = 2}
        }
    }

    function ScaleManager:CreateScaleSelector()
        local selectorFrame = CreateElement("Frame", {
            Size = UDim2.new(0, 200, 0, 200),
            BackgroundColor3 = Library.Colors.Primary
        })
        AddCorner(selectorFrame)

        for _, scaleOption in ipairs(self.ScaleSteps) do
            local scaleButton = CreateElement("TextButton", {
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, (#selectorFrame:GetChildren() * 50)),
                Text = scaleOption.Name,
                BackgroundColor3 = Library.Colors.Accent
            })
            AddCorner(scaleButton)
            scaleButton.Parent = selectorFrame

            scaleButton.MouseButton1Click:Connect(function()
                self:ScaleWindow(scaleOption.Scale)
            end)
        end

        return selectorFrame
    end

    function ScaleManager:ScaleWindow(scale)
        local mainContainer = window.MainContainer  -- Assume this exists in your window object
        local originalSize = mainContainer.Size
        local originalPosition = mainContainer.Position

        local newSize = UDim2.new(
            originalSize.X.Scale, 
            originalSize.X.Offset * scale, 
            originalSize.Y.Scale, 
            originalSize.Y.Offset * scale
        )

        local newPosition = UDim2.new(
            originalPosition.X.Scale, 
            (game.Workspace.CurrentCamera.ViewportSize.X - newSize.X.Offset) / 2,
            originalPosition.Y.Scale, 
            (game.Workspace.CurrentCamera.ViewportSize.Y - newSize.Y.Offset) / 2
        )

        TweenService:Create(mainContainer, TweenInfo.new(0.3), {
            Size = newSize,
            Position = newPosition
        }):Play()

        self.CurrentScale = scale
    end

    return ScaleManager
end

-- Usage Example
local window = Library:CreateWindow({Title = "Scalable Window"})
local scaleManager = Library:CreateWindowScaler(window)
local scaleSelector = scaleManager:CreateScaleSelector()

