--[[
    ProgLib Premium v4.1.0
    Advanced UI Library for Roblox
    
    @class ProgLib
    @author Professional Programming Team
    @last_update 2024
]]

-- Services
local Services = setmetatable({}, {
    __index = function(self, service)
        local service = game:GetService(service)
        self[service] = service
        return service
    end
})

-- Constants
local LIBRARY_INFO = {
    Name = "ProgLib",
    Version = "4.1.0",
    Author = "Professional Programming Team",
    License = "MIT"
}

local DEFAULT_SETTINGS = {
    Theme = {
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
            Background = Color3.fromRGB(15, 15, 20),
            Success = Color3.fromRGB(35, 190, 85),
            Warning = Color3.fromRGB(240, 170, 30),
            Error = Color3.fromRGB(240, 50, 50)
        }
    },
    
    Animation = {
        TweenInfo = {
            Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quart),
            Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart),
            Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quart),
            Long = TweenInfo.new(0.5, Enum.EasingStyle.Quart)
        },
        Effects = {
            Ripple = true,
            Spring = true,
            Fade = true
        }
    },
    
    Window = {
        DefaultSize = Vector2.new(650, 450),
        MinSize = Vector2.new(450, 350),
        MaxSize = Vector2.new(850, 650),
        TitleBarHeight = 35,
        TabBarWidth = 150,
        CornerRadius = 8,
        Shadow = true,
        AutoSave = true,
        SaveInterval = 60
    },
    
    Elements = {
        CornerRadius = UDim.new(0, 6),
        ButtonHeight = 32,
        InputHeight = 35,
        DropdownHeight = 32,
        SliderHeight = 35,
        ToggleSize = 24,
        CheckboxSize = 20,
        ScrollBarWidth = 3,
        TabButtonHeight = 36,
        SectionSpacing = 10,
        ElementSpacing = 8
    }
}

-- Core Library
local ProgLib = {
    Info = LIBRARY_INFO,
    Settings = DEFAULT_SETTINGS,
    
    Core = {
        Services = Services,
        Cache = {
            Instances = setmetatable({}, { __mode = "k" }),
            Connections = {},
            Threads = {},
            Assets = {}
        },
        Debug = {
            Enabled = false,
            LogLevel = 2,
            LogToFile = false,
            LogPath = "ProgLib/logs/",
            
            log = function(self, level, message, ...)
                if level <= self.LogLevel then
                    local formatted = string.format(message, ...)
                    if self.LogToFile then
                        self:writeToLog(formatted)
                    end
                    print(("[ProgLib][%s] %s"):format(
                        level == 1 and "ERROR" or level == 2 and "WARN" or "INFO",
                        formatted
                    ))
                end
            end,
            
            writeToLog = function(self, message)
                if not self.currentLog then
                    local date = os.date("%Y-%m-%d")
                    self.currentLog = self.LogPath .. date .. ".log"
                end
                
                local file = io.open(self.currentLog, "a")
                if file then
                    file:write(os.date("[%H:%M:%S] ") .. message .. "\n")
                    file:close()
                end
            end
        }
    },
    
    Utils = {},
    Systems = {},
    UI = {}
}

-- Type Checking System
ProgLib.Utils.Types = {
    isInstance = function(value)
        return typeof(value) == "Instance"
    end,
    
    isColor3 = function(value)
        return typeof(value) == "Color3"
    end,
    
    isVector2 = function(value)
        return typeof(value) == "Vector2"
    end,
    
    isUDim2 = function(value)
        return typeof(value) == "UDim2"
    end,
    
    assertType = function(value, expectedType, paramName)
        assert(
            typeof(value) == expectedType,
            string.format("Expected %s to be %s, got %s", paramName, expectedType, typeof(value))
        )
    end,
    
    assertInstance = function(value, className, paramName)
        assert(
            ProgLib.Utils.Types.isInstance(value) and value:IsA(className),
            string.format("Expected %s to be Instance of %s", paramName, className)
        )
    end
}

-- Error Handling System
ProgLib.Systems.Error = {
    new = function(message, level)
        return {
            message = message,
            level = level or 1,
            timestamp = os.time(),
            traceback = debug.traceback()
        }
    end,
    
    throw = function(self, message, level)
        local err = self:new(message, level)
        ProgLib.Core.Debug:log(err.level, err.message)
        if err.level == 1 then
            error(err.message, 2)
        end
    end
}

-- Event System
ProgLib.Systems.Events = {
    _events = {},
    
    on = function(self, eventName, callback)
        self._events[eventName] = self._events[eventName] or {}
        table.insert(self._events[eventName], callback)
        
        return function() -- Return cleanup function
            self:off(eventName, callback)
        end
    end,
    
    once = function(self, eventName, callback)
        local connection
        connection = self:on(eventName, function(...)
            connection()
            callback(...)
        end)
        return connection
    end,
    
    off = function(self, eventName, callback)
        if self._events[eventName] then
            for i, cb in ipairs(self._events[eventName]) do
                if cb == callback then
                    table.remove(self._events[eventName], i)
                    break
                end
            end
        end
    end,
    
    emit = function(self, eventName, ...)
        if self._events[eventName] then
            for _, callback in ipairs(self._events[eventName]) do
                task.spawn(callback, ...)
            end
        end
    end,
    
    clear = function(self, eventName)
        if eventName then
            self._events[eventName] = nil
        else
            self._events = {}
        end
    end
}

-- State Management System
ProgLib.Systems.State = {
    _states = {},
    _subscribers = {},
    _computedStates = {},
    
    create = function(self, stateName, initialValue)
        self._states[stateName] = initialValue
        self._subscribers[stateName] = {}
        return {
            get = function()
                return self:get(stateName)
            end,
            set = function(value)
                self:set(stateName, value)
            end,
            subscribe = function(callback)
                return self:subscribe(stateName, callback)
            end
        }
    end,
    
    createComputed = function(self, stateName, computeFn, dependencies)
        self._computedStates[stateName] = {
            compute = computeFn,
            dependencies = dependencies
        }
        
        -- Initial computation
        self._states[stateName] = computeFn(table.unpack(
            table.map(dependencies, function(dep) return self:get(dep) end)
        ))
        
        -- Subscribe to dependencies
        for _, dep in ipairs(dependencies) do
            self:subscribe(dep, function()
                self:_updateComputed(stateName)
            end)
        end
    end,
    
    get = function(self, stateName)
        return self._states[stateName]
    end,
    
    set = function(self, stateName, value)
        local oldValue = self._states[stateName]
        if oldValue ~= value then
            self._states[stateName] = value
            self:_notifySubscribers(stateName, value, oldValue)
        end
    end,
    
    subscribe = function(self, stateName, callback)
        table.insert(self._subscribers[stateName], callback)
        return function() -- Return cleanup function
            self:unsubscribe(stateName, callback)
        end
    end,
    
    unsubscribe = function(self, stateName, callback)
        local subscribers = self._subscribers[stateName]
        if subscribers then
            for i, cb in ipairs(subscribers) do
                if cb == callback then
                    table.remove(subscribers, i)
                    break
                end
            end
        end
    end,
    
    _notifySubscribers = function(self, stateName, newValue, oldValue)
        for _, callback in ipairs(self._subscribers[stateName]) do
            task.spawn(callback, newValue, oldValue)
        end
    end,
    
    _updateComputed = function(self, stateName)
        local computed = self._computedStates[stateName]
        if computed then
            local newValue = computed.compute(table.unpack(
                table.map(computed.dependencies, function(dep) return self:get(dep) end)
            ))
            self:set(stateName, newValue)
        end
    end
}

-- Animation System
ProgLib.Systems.Animation = {
    _tweens = {},
    _sequences = {},
    
    tween = function(self, instance, properties, config)
        if not instance or not properties then return end
        
        -- Cancel existing tween for this instance
        self:cancel(instance)
        
        -- Configure tween
        local tweenInfo
        if typeof(config) == "string" then
            tweenInfo = ProgLib.Settings.Animation.TweenInfo[config] or 
                       ProgLib.Settings.Animation.TweenInfo.Normal
        elseif typeof(config) == "TweenInfo" then
            tweenInfo = config
        else
            tweenInfo = ProgLib.Settings.Animation.TweenInfo.Normal
        end
        
        -- Create and play tween
        local tween = Services.TweenService:Create(instance, tweenInfo, properties)
        self._tweens[instance] = tween
        
        tween.Completed:Connect(function()
            if self._tweens[instance] == tween then
                self._tweens[instance] = nil
            end
        end)
        
        tween:Play()
        return tween
    end,
    
    sequence = function(self, animations)
        local sequence = {
            animations = animations,
            currentIndex = 0,
            playing = false,
            completed = Instance.new("BindableEvent")
        }
        
        function sequence:play()
            if self.playing then return end
            self.playing = true
            
            local function playNext()
                self.currentIndex = self.currentIndex + 1
                if self.currentIndex <= #self.animations then
                    local anim = self.animations[self.currentIndex]
                    if typeof(anim) == "function" then
                        anim()
                        playNext()
                    else
                        anim.tween.Completed:Connect(playNext)
                        anim.tween:Play()
                    end
                else
                    self.playing = false
                    self.completed:Fire()
                end
            end
            
            playNext()
        end
        
        function sequence:stop()
            self.playing = false
            for _, anim in ipairs(self.animations) do
                if typeof(anim) ~= "function" then
                    anim.tween:Cancel()
                end
            end
        end
        
        table.insert(self._sequences, sequence)
        return sequence
    end,
    
    spring = function(self, instance, property, target, config)
        config = config or {}
        local speed = config.speed or 20
        local dampingRatio = config.dampingRatio or 1
        
        local connection
        connection = Services.RunService.RenderStepped:Connect(function(dt)
            local current = instance[property]
            local velocity = config._velocity or 0
            
            local spring = (target - current) * speed
            local damping = velocity * -dampingRatio
            local acceleration = spring + damping
            
            config._velocity = velocity + acceleration * dt
            instance[property] = current + config._velocity * dt
            
            if math.abs(target - current) < 0.001 and math.abs(config._velocity) < 0.001 then
                connection:Disconnect()
                instance[property] = target
            end
        end)
        
        return {
            stop = function()
                connection:Disconnect()
            end
        }
    end,
    
    cancel = function(self, instance)
        local tween = self._tweens[instance]
        if tween then
            tween:Cancel()
            self._tweens[instance] = nil
        end
    end,
    
    cancelAll = function(self)
        for instance, tween in pairs(self._tweens) do
            tween:Cancel()
        end
        self._tweens = {}
        
        for _, sequence in ipairs(self._sequences) do
            sequence:stop()
        end
        self._sequences = {}
    end
}





-- Component System
ProgLib.Systems.Component = {
    _components = {},
    _instances = {},
    
    create = function(self, name, config)
        assert(type(name) == "string", "Component name must be a string")
        assert(type(config) == "table", "Component config must be a table")
        assert(type(config.render) == "function", "Component must have a render function")
        
        local component = {
            name = name,
            config = config,
            
            new = function(props)
                local instance = {
                    props = props or {},
                    state = {},
                    _connections = {},
                    _mounted = false
                }
                
                -- State management
                function instance:setState(newState)
                    for key, value in pairs(newState) do
                        self.state[key] = value
                    end
                    if self._mounted and config.update then
                        config.update(self)
                    end
                end
                
                -- Lifecycle methods
                function instance:mount()
                    if not self._mounted then
                        self.gui = config.render(self)
                        if config.mounted then
                            config.mounted(self)
                        end
                        self._mounted = true
                    end
                    return self.gui
                end
                
                function instance:unmount()
                    if self._mounted then
                        if config.willUnmount then
                            config.willUnmount(self)
                        end
                        for _, connection in pairs(self._connections) do
                            connection:Disconnect()
                        end
                        if self.gui then
                            self.gui:Destroy()
                        end
                        self._mounted = false
                    end
                end
                
                -- Store instance reference
                table.insert(self._instances, instance)
                
                return instance
            end
        }
        
        self._components[name] = component
        return component
    end,
    
    get = function(self, name)
        return self._components[name]
    end,
    
    cleanup = function(self)
        for _, instance in ipairs(self._instances) do
            instance:unmount()
        end
        self._instances = {}
    end
}

-- UI Elements System
ProgLib.UI.Elements = {
    Button = {
        create = function(config)
            config = config or {}
            local theme = ProgLib.Systems.Theme:get()
            
            local button = ProgLib.Utils.Create("TextButton", {
                Size = UDim2.new(1, 0, 0, config.height or ProgLib.Settings.Elements.ButtonHeight),
                BackgroundColor3 = theme.Secondary,
                BorderSizePixel = 0,
                Text = config.text or "Button",
                TextColor3 = theme.Text,
                Font = config.font or Enum.Font.GothamSemibold,
                TextSize = config.textSize or 14,
                AutoButtonColor = false
            }, {
                Corner = ProgLib.Utils.Create("UICorner", {
                    CornerRadius = UDim.new(0, ProgLib.Settings.Elements.CornerRadius)
                }),
                
                Stroke = ProgLib.Utils.Create("UIStroke", {
                    Color = theme.Border,
                    Transparency = 0.5
                })
            })
            
            -- Hover and click effects
            local normalColor = theme.Secondary
            local hoverColor = theme.Secondary:Lerp(theme.Accent, 0.1)
            local clickColor = theme.Secondary:Lerp(theme.Accent, 0.2)
            
            button.MouseEnter:Connect(function()
                ProgLib.Systems.Animation:tween(button, {
                    BackgroundColor3 = hoverColor
                }, "Quick")
            end)
            
            button.MouseLeave:Connect(function()
                ProgLib.Systems.Animation:tween(button, {
                    BackgroundColor3 = normalColor
                }, "Quick")
            end)
            
            button.MouseButton1Down:Connect(function()
                ProgLib.Systems.Animation:tween(button, {
                    BackgroundColor3 = clickColor
                }, "Quick")
                
                if ProgLib.Settings.Animation.Effects.Ripple then
                    ProgLib.Systems.Animation:ripple(button, {
                        Color = theme.Accent,
                        StartTransparency = 0.6
                    })
                end
            end)
            
            button.MouseButton1Up:Connect(function()
                ProgLib.Systems.Animation:tween(button, {
                    BackgroundColor3 = hoverColor
                }, "Quick")
            end)
            
            if config.onClick then
                button.MouseButton1Click:Connect(config.onClick)
            end
            
            -- Additional features
            local buttonObj = {
                instance = button,
                
                setEnabled = function(self, enabled)
                    button.AutoButtonColor = enabled
                    button.TextTransparency = enabled and 0 or 0.5
                    if not enabled then
                        ProgLib.Systems.Animation:tween(button, {
                            BackgroundColor3 = normalColor:Lerp(theme.Background, 0.5)
                        }, "Quick")
                    end
                end,
                
                setText = function(self, text)
                    button.Text = text
                end,
                
                setLoading = function(self, loading)
                    if loading then
                        self.originalText = button.Text
                        local dots = {".", "..", "..."}
                        local index = 0
                        
                        self.loadingConnection = Services.RunService.Heartbeat:Connect(function()
                            index = (index + 1) % #dots
                            button.Text = "Loading" .. dots[index + 1]
                        end)
                        
                        self:setEnabled(false)
                    else
                        if self.loadingConnection then
                            self.loadingConnection:Disconnect()
                            self.loadingConnection = nil
                        end
                        button.Text = self.originalText
                        self:setEnabled(true)
                    end
                end
            }
            
            return buttonObj
        end
    },
    
    Input = {
        create = function(config)
            config = config or {}
            local theme = ProgLib.Systems.Theme:get()
            
            local container = ProgLib.Utils.Create("Frame", {
                Size = UDim2.new(1, 0, 0, config.height or ProgLib.Settings.Elements.InputHeight),
                BackgroundColor3 = theme.Background,
                BorderSizePixel = 0
            }, {
                Corner = ProgLib.Utils.Create("UICorner", {
                    CornerRadius = UDim.new(0, ProgLib.Settings.Elements.CornerRadius)
                }),
                
                Stroke = ProgLib.Utils.Create("UIStroke", {
                    Color = theme.Border,
                    Transparency = 0.5
                })
            })
            
            local textBox = ProgLib.Utils.Create("TextBox", {
                Parent = container,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = config.defaultText or "",
                PlaceholderText = config.placeholder or "Enter text...",
                TextColor3 = theme.Text,
                PlaceholderColor3 = theme.SubText,
                Font = config.font or Enum.Font.Gotham,
                TextSize = config.textSize or 14,
                ClearTextOnFocus = config.clearOnFocus ~= false,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Focus effects
            textBox.Focused:Connect(function()
                ProgLib.Systems.Animation:tween(container.Stroke, {
                    Color = theme.Accent,
                    Transparency = 0
                }, "Quick")
            end)
            
            textBox.FocusLost:Connect(function(enterPressed)
                ProgLib.Systems.Animation:tween(container.Stroke, {
                    Color = theme.Border,
                    Transparency = 0.5
                }, "Quick")
                
                if config.onFocusLost then
                    config.onFocusLost(textBox.Text, enterPressed)
                end
            end)
            
            if config.onChanged then
                textBox:GetPropertyChangedSignal("Text"):Connect(function()
                    config.onChanged(textBox.Text)
                end)
            end
            
            -- Additional features
            local inputObj = {
                instance = container,
                textBox = textBox,
                
                getText = function(self)
                    return textBox.Text
                end,
                
                setText = function(self, text)
                    textBox.Text = text
                end,
                
                setPlaceholder = function(self, text)
                    textBox.PlaceholderText = text
                end,
                
                focus = function(self)
                    textBox:CaptureFocus()
                end,
                
                clear = function(self)
                    textBox.Text = ""
                end
            }
            
            return inputObj
        end
    }
}




-- Additional UI Elements
ProgLib.UI.Elements.Toggle = {
    create = function(config)
        config = config or {}
        local theme = ProgLib.Systems.Theme:get()
        local enabled = config.default or false
        
        -- Create container
        local container = ProgLib.Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, config.height or ProgLib.Settings.Elements.ToggleSize),
            BackgroundTransparency = 1
        })
        
        -- Create toggle button
        local toggleButton = ProgLib.Utils.Create("Frame", {
            Parent = container,
            Size = UDim2.new(0, ProgLib.Settings.Elements.ToggleSize, 0, ProgLib.Settings.Elements.ToggleSize),
            BackgroundColor3 = enabled and theme.Accent or theme.Secondary,
            BorderSizePixel = 0
        }, {
            Corner = ProgLib.Utils.Create("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }),
            
            Indicator = ProgLib.Utils.Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = enabled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8),
                BackgroundColor3 = theme.Text,
                BorderSizePixel = 0
            }, {
                Corner = ProgLib.Utils.Create("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                })
            })
        })
        
        -- Create label if provided
        if config.text then
            local label = ProgLib.Utils.Create("TextLabel", {
                Parent = container,
                Size = UDim2.new(1, -(ProgLib.Settings.Elements.ToggleSize + 10), 1, 0),
                Position = UDim2.new(0, ProgLib.Settings.Elements.ToggleSize + 10, 0, 0),
                BackgroundTransparency = 1,
                Text = config.text,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = config.font or Enum.Font.Gotham,
                TextSize = config.textSize or 14
            })
        end
        
        -- Create hitbox
        local hitbox = ProgLib.Utils.Create("TextButton", {
            Parent = container,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        })
        
        -- Toggle functionality
        local function updateToggle(value)
            enabled = value
            
            -- Animate toggle
            ProgLib.Systems.Animation:tween(toggleButton, {
                BackgroundColor3 = enabled and theme.Accent or theme.Secondary
            }, "Quick")
            
            ProgLib.Systems.Animation:tween(toggleButton.Indicator, {
                Position = enabled and 
                    UDim2.new(1, -20, 0.5, -8) or 
                    UDim2.new(0, 4, 0.5, -8)
            }, "Quick")
            
            if config.onToggle then
                config.onToggle(enabled)
            end
        end
        
        hitbox.MouseButton1Click:Connect(function()
            updateToggle(not enabled)
        end)
        
        return {
            instance = container,
            
            getValue = function(self)
                return enabled
            end,
            
            setValue = function(self, value)
                if value ~= enabled then
                    updateToggle(value)
                end
            end,
            
            toggle = function(self)
                updateToggle(not enabled)
            end
        }
    end
}

ProgLib.UI.Elements.Dropdown = {
    create = function(config)
        config = config or {}
        local theme = ProgLib.Systems.Theme:get()
        local isOpen = false
        local selectedOption = config.default
        local options = config.options or {}
        
        -- Create container
        local container = ProgLib.Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, config.height or ProgLib.Settings.Elements.DropdownHeight),
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            ClipsDescendants = true
        }, {
            Corner = ProgLib.Utils.Create("UICorner", {
                CornerRadius = UDim.new(0, ProgLib.Settings.Elements.CornerRadius)
            })
        })
        
        -- Create header
        local header = ProgLib.Utils.Create("TextButton", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, ProgLib.Settings.Elements.DropdownHeight),
            BackgroundTransparency = 1,
            Text = selectedOption or config.placeholder or "Select option...",
            TextColor3 = selectedOption and theme.Text or theme.SubText,
            Font = config.font or Enum.Font.Gotham,
            TextSize = config.textSize or 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        }, {
            Padding = ProgLib.Utils.Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 30)
            }),
            
            Icon = ProgLib.Utils.Create("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -23, 0.5, -8),
                BackgroundTransparency = 1,
                Image = "rbxassetid://7072706796", -- Down arrow
                ImageColor3 = theme.SubText,
                Rotation = 0
            })
        })
        
        -- Create options list
        local optionsList = ProgLib.Utils.Create("ScrollingFrame", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, ProgLib.Settings.Elements.DropdownHeight),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Border,
            TopImage = "rbxassetid://7072725398",
            MidImage = "rbxassetid://7072725398",
            BottomImage = "rbxassetid://7072725398",
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, {
            Layout = ProgLib.Utils.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
        })
        
        -- Update canvas size when options change
        local function updateCanvasSize()
            optionsList.CanvasSize = UDim2.new(0, 0, 0, optionsList.Layout.AbsoluteContentSize.Y)
        end
        
        -- Toggle dropdown
        local function toggleDropdown()
            isOpen = not isOpen
            
            -- Animate arrow
            ProgLib.Systems.Animation:tween(header.Icon, {
                Rotation = isOpen and 180 or 0
            }, "Quick")
            
            -- Animate container
            local targetSize = isOpen and 
                UDim2.new(1, 0, 0, ProgLib.Settings.Elements.DropdownHeight + math.min(optionsList.CanvasSize.Y.Offset, 150)) or
                UDim2.new(1, 0, 0, ProgLib.Settings.Elements.DropdownHeight)
            
            ProgLib.Systems.Animation:tween(container, {
                Size = targetSize
            }, "Quick")
        end
        
        header.MouseButton1Click:Connect(toggleDropdown)
        
        -- Option selection handling
        local function selectOption(option)
            selectedOption = option
            header.Text = option
            header.TextColor3 = theme.Text
            
            if isOpen then
                toggleDropdown()
            end
            
            if config.onSelect then
                config.onSelect(option)
            end
        end
        
        -- Create option buttons
        local function createOption(option)
            local optionButton = ProgLib.Utils.Create("TextButton", {
                Parent = optionsList,
                Size = UDim2.new(1, 0, 0, ProgLib.Settings.Elements.DropdownHeight),
                BackgroundColor3 = theme.Background,
                BorderSizePixel = 0,
                Text = option,
                TextColor3 = theme.Text,
                Font = config.font or Enum.Font.Gotham,
                TextSize = config.textSize or 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            }, {
                Corner = ProgLib.Utils.Create("UICorner", {
                    CornerRadius = UDim.new(0, ProgLib.Settings.Elements.CornerRadius)
                }),
                
                Padding = ProgLib.Utils.Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })
            
            -- Hover effects
            optionButton.MouseEnter:Connect(function()
                ProgLib.Systems.Animation:tween(optionButton, {
                    BackgroundColor3 = theme.Secondary
                }, "Quick")
            end)
            
            optionButton.MouseLeave:Connect(function()
                ProgLib.Systems.Animation:tween(optionButton, {
                    BackgroundColor3 = theme.Background
                }, "Quick")
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                selectOption(option)
            end)
        end
        
        -- Add options
        for _, option in ipairs(options) do
            createOption(option)
        end
        
        updateCanvasSize()
        
        return {
            instance = container,
            
            getValue = function(self)
                return selectedOption
            end,
            
            setValue = function(self, option)
                if table.find(options, option) then
                    selectOption(option)
                end
            end,
            
            setOptions = function(self, newOptions)
                -- Clear existing options
                for _, child in ipairs(optionsList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add new options
                options = newOptions
                for _, option in ipairs(options) do
                    createOption(option)
                end
                
                updateCanvasSize()
                
                -- Reset selection if current selection is not in new options
                if not table.find(options, selectedOption) then
                    selectedOption = nil
                    header.Text = config.placeholder or "Select option..."
                    header.TextColor3 = theme.SubText
                end
            end,
            
            isOpen = function(self)
                return isOpen
            end,
            
            toggle = function(self)
                toggleDropdown()
            end
        }
    end
}

