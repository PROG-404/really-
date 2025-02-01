
local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- نظام الثيمات المتطور
Library.Themes = {
    Default = {
        MainBackground = Color3.fromRGB(25, 25, 25),
        SecondaryBackground = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(200, 200, 200),
        ButtonColor = Color3.fromRGB(40, 40, 40),
        ButtonHover = Color3.fromRGB(50, 50, 50),
        ControlButtons = {
            Close = Color3.fromRGB(255, 75, 75),
            Minimize = Color3.fromRGB(255, 180, 0),
            Move = Color3.fromRGB(0, 180, 0)
        },
        Gradients = {
            Main = {
                Color1 = Color3.fromRGB(255, 255, 255),
                Color2 = Color3.fromRGB(200, 200, 200)
            }
        }
    },
    Dark = {
        -- يمكن إضافة ثيمات أخرى هنا
    }
}

-- وظائف المساعدة
local function CreateTween(instance, properties, duration, style, direction)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
end

local function AddRippleEffect(button, rippleColor)
    button.ClipsDescendants = true
    
    local function CreateRipple(x, y)
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = rippleColor or Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.6
        ripple.BorderSizePixel = 0
        ripple.Position = UDim2.new(0, x, 0, y)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Parent = button
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        CreateTween(ripple, {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            Position = UDim2.new(0, x - maxSize/2, 0, y - maxSize/2),
            BackgroundTransparency = 1
        }, 0.5).Completed:Connect(function()
            ripple:Destroy()
        end)
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = input.Position.X - button.AbsolutePosition.X
            local y = input.Position.Y - button.AbsolutePosition.Y
            CreateRipple(x, y)
        end
    end)
end

function Library:Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

function Library:CreateWindow(config)
    config = config or {}
    local window = {
        title = config.title or "نافذة جديدة",
        size = config.size or UDim2.new(0, 600, 0, 400),
        position = config.position or UDim2.new(0.5, -300, 0.5, -200),
        theme = config.theme or Library.Themes.Default,
        draggable = config.draggable ~= false,
        minimizable = config.minimizable ~= false,
        closeable = config.closeable ~= false
    }
    
    
    return window
end

function window:CreateTabSystem()
    local tabSystem = {
        tabs = {},
        activeTab = nil
    }

    -- إنشاء حاوية التابات
    local tabContainer = Library:Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = window.theme.SecondaryBackground,
        BackgroundTransparency = 0.2
    })

    -- إضافة تأثيرات التدرج
    local gradient = Library:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, window.theme.Gradients.Main.Color1),
            ColorSequenceKeypoint.new(1, window.theme.Gradients.Main.Color2)
        }),
        Rotation = 45,
        Parent = tabContainer
    })

    -- نظام تمرير التابات
    local scrollFrame = Library:Create("ScrollingFrame", {
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = window.theme.AccentColor,
        Parent = tabContainer
    })

    -- تنظيم التابات
    local listLayout = Library:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = scrollFrame
    })

    return tabSystem
end

function tabSystem:AddTab(name, icon)
    local tab = {
        elements = {},
        active = false
    }

    -- إنشاء زر التاب
    local tabButton = Library:Create("Frame", {
        Size = UDim2.new(1, -16, 0, 40),
        Position = UDim2.new(0, 8, 0, #self.tabs * 45),
        BackgroundColor3 = window.theme.ButtonColor,
        BackgroundTransparency = 0.2
    })

    -- إضافة التأثيرات المرئية للزر
    local buttonStroke = Library:Create("UIStroke", {
        Color = window.theme.AccentColor,
        Transparency = 0.8,
        Thickness = 1.2,
        Parent = tabButton
    })

    -- أيقونة التاب
    if icon then
        local iconImage = Library:Create("ImageLabel", {
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 8, 0.5, -12),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = window.theme.TextColor,
            Parent = tabButton
        })

        -- تأثير دوران الأيقونة
        local rotationEffect = function()
            local rotation = 0
            return function()
                rotation = rotation + 1
                iconImage.Rotation = math.sin(rotation * 0.05) * 5
            end
        end
        
        RunService.RenderStepped:Connect(rotationEffect())
    end

    -- محتوى التاب
    local contentFrame = Library:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        Visible = false,
        Parent = window.contentContainer
    })

    -- وظائف إضافة العناصر
    function tab:AddButton(text, callback)
        local button = Library:Create("TextButton", {
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 0, #self.elements * 45),
            BackgroundColor3 = window.theme.ButtonColor,
            Text = text,
            TextColor3 = window.theme.TextColor,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold
        })

        AddRippleEffect(button, window.theme.AccentColor)
        
        button.MouseButton1Click:Connect(function()
            callback()
        end)

        table.insert(self.elements, button)
        return button
    end

    function tab:AddToggle(config)
        local toggle = {
            value = config.default or false
        }

        local toggleFrame = Library:Create("Frame", {
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 0, #self.elements * 45),
            BackgroundColor3 = window.theme.ButtonColor,
            BackgroundTransparency = 0.2
        })

        -- إضافة التبديل المرئي
        local indicator = Library:Create("Frame", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 8, 0.5, -10),
            BackgroundColor3 = toggle.value and window.theme.AccentColor or window.theme.ButtonColor,
            Parent = toggleFrame
        })

        -- تحديث حالة التبديل
        function toggle:SetValue(value)
            self.value = value
            CreateTween(indicator, {
                BackgroundColor3 = value and window.theme.AccentColor or window.theme.ButtonColor
            }):Play()
            config.callback(value)
        end

        table.insert(self.elements, toggleFrame)
        return toggle
    end

    function tab:AddSlider(config)
        local slider = {
            value = config.default or config.min,
            min = config.min or 0,
            max = config.max or 100
        }

        local sliderFrame = Library:Create("Frame", {
            Size = UDim2.new(1, -20, 0, 45),
            Position = UDim2.new(0, 10, 0, #self.elements * 55),
            BackgroundColor3 = window.theme.ButtonColor,
            BackgroundTransparency = 0.2
        })

        -- إضافة شريط التمرير
        local sliderBar = Library:Create("Frame", {
            Size = UDim2.new(1, -20, 0, 4),
            Position = UDim2.new(0, 10, 0.7, 0),
            BackgroundColor3 = window.theme.SecondaryBackground,
            Parent = sliderFrame
        })

        local sliderFill = Library:Create("Frame", {
            Size = UDim2.new((slider.value - slider.min)/(slider.max - slider.min), 0, 1, 0),
            BackgroundColor3 = window.theme.AccentColor,
            Parent = sliderBar
        })

        -- تحديث قيمة المنزلق
        function slider:SetValue(value)
            value = math.clamp(value, self.min, self.max)
            self.value = value
            CreateTween(sliderFill, {
                Size = UDim2.new((value - self.min)/(self.max - self.min), 0, 1, 0)
            }):Play()
            config.callback(value)
        end

        table.insert(self.elements, sliderFrame)
        return slider
    end

    table.insert(self.tabs, tab)
    return tab
end

-- نظام النوافذ المنبثقة
function window:CreatePopup(config)
    local popup = {
        visible = false
    }

    -- إنشاء الخلفية المعتمة
    local blur = Library:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
   ffgb     Parent = window.mainFrame
    })

    -- إنشاء النافذة المنبثقة
    local popupFrame = Library:Create("Frame", {
        Size = UDim2.new(0, 300, 0, 200),
        Position = UDim2.new(0.5, -150, 0.5, -100),
        BackgroundColor3 = window.theme.MainBackground,
        BackgroundTransparency = 1,
        Parent = blur
    })

    -- إضافة العنوان
    local titleBar = Library:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = window.theme.SecondaryBackground,
        Parent = popupFrame
    })

    local titleText = Library:Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.title or "نافذة منبثقة",
        TextColor3 = window.theme.TextColor,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = titleBar
    })

    -- وظائف التحكم
    function popup:Show()
        self.visible = true
        CreateTween(blur, {BackgroundTransparency = 0.5}):Play()
        CreateTween(popupFrame, {BackgroundTransparency = 0}):Play()
    end

    function popup:Hide()
        self.visible = false
        CreateTween(blur, {BackgroundTransparency = 1}):Play()
        CreateTween(popupFrame, {BackgroundTransparency = 1}):Play()
    end

    return popup
end

-- نظام الإشعارات
function window:CreateNotification(config)
    local notification = {}
    
    -- إنشاء إطار الإشعار
    local notifFrame = Library:Create("Frame", {
        Size = UDim2.new(0, 250, 0, 60),
        Position = UDim2.new(1, -260, 1, -70),
        BackgroundColor3 = window.theme.MainBackground,
        Parent = window.notificationContainer
    })

    -- إضافة الأيقونة
    local icon = Library:Create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        BackgroundTransparency = 1,
        Image = config.icon or "",
        Parent = notifFrame
    })

    -- إضافة النص
    local message = Library:Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, -10),
        Position = UDim2.new(0, 40, 0, 5),
        BackgroundTransparency = 1,
        Text = config.text or "",
        TextColor3 = window.theme.TextColor,
        TextSize = 14,
        TextWrapped = true,
        Font = Enum.Font.GothamMedium,
        Parent = notifFrame
    })

    -- تأثيرات الحركة
    CreateTween(notifFrame, {
        Position = UDim2.new(1, -260, 1, -70)
    }):Play()

    -- إزالة الإشعار تلقائياً
    delay(config.duration or 3, function()
        CreateTween(notifFrame, {
            Position = UDim2.new(1, 0, 1, -70)
        }).Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)

    return notification
end

-- نظام القوائم المنسدلة
function window:CreateDropdown(config)
    local dropdown = {
        value = config.default,
        options = config.options or {},
        expanded = false
    }

    -- إنشاء إطار القائمة
    local dropFrame = Library:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = window.theme.ButtonColor,
        Parent = config.parent
    })

    -- زر القائمة
    local dropButton = Library:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = config.title,
        TextColor3 = window.theme.TextColor,
        Font = Enum.Font.GothamMedium,
        Parent = dropFrame
    })

    -- قائمة الخيارات
    local optionContainer = Library:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = window.theme.SecondaryBackground,
        ClipsDescendants = true,
        Parent = dropFrame
    })

    -- تحديث القائمة
    function dropdown:SetOptions(options)
        self.options = options
        -- تحديث واجهة الخيارات
    end

    function dropdown:Toggle()
        self.expanded = not self.expanded
        local size = self.expanded and #self.options * 30 or 0
        CreateTween(optionContainer, {
            Size = UDim2.new(1, 0, 0, size)
        }):Play()
    end

    dropButton.MouseButton1Click:Connect(function()
        dropdown:Toggle()
    end)

    return dropdown
end

-- نظام الألوان والتأثيرات المتقدمة
function Library:CreateColorPicker(config)
    local colorPicker = {
        color = config.default or Color3.new(1, 1, 1),
        rainbow = false
    }

    local pickerFrame = Library:Create("Frame", {
        Size = UDim2.new(0, 200, 0, 220),
        BackgroundColor3 = window.theme.MainBackground,
        Parent = config.parent
    })

    -- لوحة الألوان
    local colorPanel = Library:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 150),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = pickerFrame
    })

    -- شريط تدرج الألوان
    local hueBar = Library:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 170),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = pickerFrame
    })

    -- زر قوس قزح
    local rainbowToggle = Library:Create("TextButton", {
        Size = UDim2.new(0, 100, 0, 25),
        Position = UDim2.new(0.5, -50, 1, -30),
        BackgroundColor3 = window.theme.ButtonColor,
        Text = "قوس قزح",
        TextColor3 = window.theme.TextColor,
        Parent = pickerFrame
    })

    -- تحديث اللون
    function colorPicker:SetColor(color)
        self.color = color
        if config.callback then
            config.callback(color)
        end
    end

    -- وضع قوس قزح
    function colorPicker:ToggleRainbow()
        self.rainbow = not self.rainbow
        if self.rainbow then
            spawn(function()
                while self.rainbow do
                    local hue = tick() % 5 / 5
                    self:SetColor(Color3.fromHSV(hue, 1, 1))
                    wait()
                end
            end)
        end
    end

    -- نظام التأثيرات المتحركة
    local AnimationSystem = {
        animations = {},
        currentFrame = 0
    }

    function AnimationSystem:AddAnimation(config)
        local animation = {
            startValue = config.startValue,
            endValue = config.endValue,
            duration = config.duration,
            easing = config.easing or "linear"
        }

        table.insert(self.animations, animation)
        return animation
    end

    function AnimationSystem:Update()
        for _, anim in pairs(self.animations) do
            local progress = self.currentFrame / (anim.duration * 60)
            if progress <= 1 then
                -- تطبيق التأثير
                local currentValue = self:Lerp(anim.startValue, anim.endValue, self:Ease(progress, anim.easing))
                anim.callback(currentValue)
            end
        end
        self.currentFrame = self.currentFrame + 1
    end

    function AnimationSystem:Lerp(start, finish, alpha)
        return start + (finish - start) * alpha
    end

    function AnimationSystem:Ease(t, style)
        if style == "linear" then
            return t
        elseif style == "quad" then
            return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2
        end
    end

    -- نظام الإضاءة والظلال
    local LightingSystem = {
        lights = {},
        shadows = {}
    }

    function LightingSystem:CreateLight(position, radius, intensity)
        local light = {
            position = position,
            radius = radius,
            intensity = intensity
        }

        table.insert(self.lights, light)
        return light
    end

    function LightingSystem:CreateShadow(object, offset, blur)
        local shadow = Library:Create("ImageLabel", {
            Size = UDim2.new(1, offset * 2, 1, offset * 2),
            Position = UDim2.new(0, -offset, 0, -offset),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.8,
            Parent = object
        })

        table.insert(self.shadows, shadow)
        return shadow
    end

    -- نظام الجسيمات
    local ParticleSystem = {
        particles = {},
        active = false
    }

    function ParticleSystem:CreateParticle(config)
        local particle = Library:Create("Frame", {
            Size = UDim2.new(0, config.size, 0, config.size),
            BackgroundColor3 = config.color,
            BackgroundTransparency = 0,
            Position = config.position,
            Parent = config.parent
        })

        -- تحريك الجسيم
        spawn(function()
            while particle.Parent do
                particle.Position = particle.Position + config.velocity
                particle.BackgroundTransparency = particle.BackgroundTransparency + 0.1
                if particle.BackgroundTransparency >= 1 then
                    particle:Destroy()
                end
                wait()
            end
        end)

        table.insert(self.particles, particle)
        return particle
    end

    return colorPicker
end
