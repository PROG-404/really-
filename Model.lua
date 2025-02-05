-- FrontLip UI Library
-- Created by: Anthropic
-- Version: 1.0.0

local FrontLip = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Constants
FrontLip.Constants = {
   DefaultPadding = 10,
   DefaultCornerRadius = 8,
   DefaultAnimationDuration = 0.3,
   MinWindowSize = Vector2.new(200, 150),
   MaxWindowSize = Vector2.new(800, 600)
}

-- Enhanced theme system with multiple presets
FrontLip.Themes = {
   Default = {
       MainBackground = Color3.fromRGB(20, 20, 25),
       SecondaryBackground = Color3.fromRGB(25, 25, 30),
       AccentColor = Color3.fromRGB(65, 143, 232),
       TextColor = Color3.fromRGB(255, 255, 255),
       SubTextColor = Color3.fromRGB(200, 200, 200),
       ButtonColor = Color3.fromRGB(35, 35, 40),
       ButtonHover = Color3.fromRGB(45, 45, 50),
       ControlButtons = {
           Close = Color3.fromRGB(255, 70, 70),
           Minimize = Color3.fromRGB(255, 185, 0),
           Move = Color3.fromRGB(0, 185, 0)
       },
       Gradients = {
           Main = {
               Color1 = Color3.fromRGB(65, 143, 232),
               Color2 = Color3.fromRGB(55, 123, 212)
           }
       }
   },
   Dark = {
       MainBackground = Color3.fromRGB(15, 15, 20),
       SecondaryBackground = Color3.fromRGB(20, 20, 25),
       AccentColor = Color3.fromRGB(90, 90, 255),
       TextColor = Color3.fromRGB(255, 255, 255),
       SubTextColor = Color3.fromRGB(200, 200, 200),
       ButtonColor = Color3.fromRGB(30, 30, 35),
       ButtonHover = Color3.fromRGB(40, 40, 45),
       ControlButtons = {
           Close = Color3.fromRGB(255, 70, 70),
           Minimize = Color3.fromRGB(255, 185, 0),
           Move = Color3.fromRGB(0, 185, 0)
       }
   },
   Light = {
       MainBackground = Color3.fromRGB(240, 240, 245),
       SecondaryBackground = Color3.fromRGB(230, 230, 235),
       AccentColor = Color3.fromRGB(65, 143, 232),
       TextColor = Color3.fromRGB(30, 30, 30),
       SubTextColor = Color3.fromRGB(70, 70, 70),
       ButtonColor = Color3.fromRGB(220, 220, 225),
       ButtonHover = Color3.fromRGB(210, 210, 215),
       ControlButtons = {
           Close = Color3.fromRGB(255, 70, 70),
           Minimize = Color3.fromRGB(255, 185, 0),
           Move = Color3.fromRGB(0, 185, 0)
       }
   }
}

-- Input System
FrontLip.Input = {
   MousePosition = Vector2.new(),
   KeysDown = {},
   
   Init = function(self)
       UserInputService.InputBegan:Connect(function(input)
           if input.KeyCode then
               self.KeysDown[input.KeyCode] = true
           end
       end)
       
       UserInputService.InputEnded:Connect(function(input)
           if input.KeyCode then
               self.KeysDown[input.KeyCode] = false
           end
       end)
       
       UserInputService.InputChanged:Connect(function(input)
           if input.UserInputType == Enum.UserInputType.MouseMovement then
               self.MousePosition = input.Position
           end
       end)
   end,
   
   IsKeyDown = function(self, keyCode)
       return self.KeysDown[keyCode] == true
   end
}

-- Animation System
FrontLip.Animations = {
   ButtonClick = function(button)
       local originalSize = button.Size
       local originalPosition = button.Position
       
       local clickAnimation = TweenService:Create(button, TweenInfo.new(0.1), {
           Size = originalSize - UDim2.new(0, 4, 0, 4),
           Position = originalPosition + UDim2.new(0, 2, 0, 2)
       })
       
       clickAnimation:Play()
       wait(0.1)
       
       local releaseAnimation = TweenService:Create(button, TweenInfo.new(0.1), {
           Size = originalSize,
           Position = originalPosition
       })
       
       releaseAnimation:Play()
   end,
   
   Fade = function(instance, transparency)
       local fadeAnimation = TweenService:Create(instance, TweenInfo.new(0.3), {
           BackgroundTransparency = transparency
       })
       fadeAnimation:Play()
       return fadeAnimation
   end
}

-- Visual Effects System
FrontLip.Effects = {
   Ripple = function(button, rippleColor)
       button.ClipsDescendants = true
       
       local function CreateRipple(x, y)
           local ripple = FrontLip:Create("Frame", {
               BackgroundColor3 = rippleColor or Color3.fromRGB(255, 255, 255),
               BackgroundTransparency = 0.6,
               Position = UDim2.new(0, x, 0, y),
               Size = UDim2.new(0, 0, 0, 0),
               Parent = button
           })

           local corner = FrontLip:Create("UICorner", {
               CornerRadius = UDim.new(1, 0),
               Parent = ripple
           })

           local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
           local animation = TweenService:Create(ripple, TweenInfo.new(0.5), {
               Size = UDim2.new(0, maxSize, 0, maxSize),
               Position = UDim2.new(0, x - maxSize/2, 0, y - maxSize/2),
               BackgroundTransparency = 1
           })

           animation.Completed:Connect(function()
               ripple:Destroy()
           end)
           animation:Play()
       end

       button.InputBegan:Connect(function(input)
           if input.UserInputType == Enum.UserInputType.MouseButton1 then
               local x = input.Position.X - button.AbsolutePosition.X
               local y = input.Position.Y - button.AbsolutePosition.Y
               CreateRipple(x, y)
           end
       end)
   end,
   
   Shadow = function(frame, strength)
       local shadow = FrontLip:Create("ImageLabel", {
           Size = UDim2.new(1, strength * 2, 1, strength * 2),
           Position = UDim2.new(0, -strength, 0, -strength),
           BackgroundTransparency = 1,
           Image = "rbxassetid://5554236805",
           ImageColor3 = Color3.fromRGB(0, 0, 0),
           ImageTransparency = 0.8 - (strength/10),
           Parent = frame
       })
       return shadow
   end
}

-- Element Creation Helper
function FrontLip:Create(className, properties)
   local instance = Instance.new(className)
   for property, value in pairs(properties) do
       instance[property] = value
   end
   return instance
end

-- Window System
function FrontLip:CreateWindow(config)
   local window = {
       title = config.title or "FrontLip Window",
       size = config.size or UDim2.new(0, 600, 0, 400),
       position = config.position or UDim2.new(0.5, -300, 0.5, -200),
       theme = config.theme or FrontLip.Themes.Default,
       draggable = config.draggable ~= false,
       minimizable = config.minimizable ~= false,
       closeable = config.closeable ~= false
   }

   -- Main window frame
   local mainFrame = FrontLip:Create("Frame", {
       Name = "FrontLipWindow",
       Size = window.size,
       Position = window.position,
       BackgroundColor3 = window.theme.MainBackground,
       Parent = CoreGui
   })

   -- Title bar
   local titleBar = FrontLip:Create("Frame", {
       Size = UDim2.new(1, 0, 0, 30),
       BackgroundColor3 = window.theme.SecondaryBackground,
       Parent = mainFrame
   })

   -- Window title
   local titleText = FrontLip:Create("TextLabel", {
       Size = UDim2.new(1, -10, 1, 0),
       Position = UDim2.new(0, 10, 0, 0),
       BackgroundTransparency = 1,
       Text = window.title,
       TextColor3 = window.theme.TextColor,
       TextSize = 14,
       Font = Enum.Font.GothamBold,
       Parent = titleBar
   })

   -- Add window methods
   function window:AddTab(name)
       -- Tab implementation
       local tab = {}
       return tab
   end

   function window:AddButton(config)
       local button = FrontLip:Create("TextButton", {
           Size = UDim2.new(0, 200, 0, 40),
           BackgroundColor3 = window.theme.ButtonColor,
           Text = config.text or "Button",
           TextColor3 = window.theme.TextColor,
           Parent = mainFrame
       })

       -- Add effects
       FrontLip.Effects.Ripple(button, window.theme.AccentColor)
       
       button.MouseButton1Click:Connect(function()
           FrontLip.Animations.ButtonClick(button)
           if config.callback then
               config.callback()
           end
       end)

       return button
   end

   function window:AddToggle(config)
       local toggle = {
           value = config.default or false,
           onChange = config.onChange
       }

       local container = FrontLip:Create("Frame", {
           Size = UDim2.new(0, 50, 0, 24),
           BackgroundColor3 = window.theme.ButtonColor,
           Parent = mainFrame
       })

       -- Toggle implementation
       return toggle
   end

   function window:AddSlider(config)
       local slider = {
           value = config.default or config.min,
           min = config.min or 0,
           max = config.max or 100
       }

       -- Slider implementation
       return slider
   end

   function window:AddDropdown(config)
       local dropdown = {
           selected = config.default or config.options[1],
           options = config.options,
           onChange = config.onChange
       }

       -- Dropdown implementation
       return dropdown
   end

   -- Enable dragging if configured
   if window.draggable then
       local dragging = false
       local dragInput
       local dragStart
       local startPos

       titleBar.InputBegan:Connect(function(input)
           if input.UserInputType == Enum.UserInputType.MouseButton1 then
               dragging = true
               dragStart = input.Position
               startPos = mainFrame.Position
           end
       end)

       titleBar.InputEnded:Connect(function(input)
           if input.UserInputType == Enum.UserInputType.MouseButton1 then
               dragging = false
           end
       end)

       UserInputService.InputChanged:Connect(function(input)
           if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
               local delta = input.Position - dragStart
               mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
           end
       end)
   end

   return window
end

-- Initialize Input System
FrontLip.Input:Init()

-- Return Library
return FrontLip
