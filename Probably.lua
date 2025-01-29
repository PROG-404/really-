-- في دالة CreateWindow، أضف هذه الوظائف

-- إضافة نافذة تأكيد الإغلاق
function window:CreateConfirmDialog()
    local dimFrame = Instance.new("Frame")
    dimFrame.Size = UDim2.new(1, 0, 1, 0)
    dimFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dimFrame.BackgroundTransparency = 1
    dimFrame.Parent = mainWindow

    TweenService:Create(dimFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(mainWindow, TweenInfo.new(0.3), {BackgroundTransparency = 0.4}):Play()

    local confirmDialog = Instance.new("Frame")
    confirmDialog.Name = "ConfirmDialog"
    confirmDialog.Size = UDim2.new(0, 250, 0, 150)
    confirmDialog.Position = UDim2.new(0.5, -125, 0.5, -75)
    confirmDialog.BackgroundColor3 = self.Theme.Background
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
    messageText.TextColor3 = self.Theme.Text
    messageText.TextSize = 16
    messageText.Font = Enum.Font.GothamMedium
    messageText.Text = "Are you sure you want to close this window?"
    messageText.TextWrapped = true
    messageText.Parent = confirmDialog

    -- أزرار التأكيد
    local yesButton = Instance.new("TextButton")
    yesButton.Size = UDim2.new(0.4, 0, 0, 35)
    yesButton.Position = UDim2.new(0.1, 0, 1, -50)
    yesButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    yesButton.TextColor3 = self.Theme.Text
    yesButton.TextSize = 14
    yesButton.Font = Enum.Font.GothamBold
    yesButton.Text = "Yes"
    yesButton.Parent = confirmDialog

    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.4, 0, 0, 35)
    noButton.Position = UDim2.new(0.5, 0, 1, -50)
    noButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    noButton.TextColor3 = self.Theme.Text
    noButton.TextSize = 14
    noButton.Font = Enum.Font.GothamBold
    noButton.Text = "No"
    noButton.Parent = confirmDialog

    -- تحسين زوايا الأزرار
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 6)
    yesCorner.Parent = yesButton

    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 6)
    noCorner.Parent = noButton

    -- وظائف الأزرار
    yesButton.MouseButton1Click:Connect(function()
        TweenService:Create(mainWindow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        mainWindow:Destroy()
    end)

    noButton.MouseButton1Click:Connect(function()
        TweenService:Create(dimFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(mainWindow, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(confirmDialog, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        dimFrame:Destroy()
        confirmDialog:Destroy()
    end)
end

-- إضافة وظيفة تغيير الحجم عن طريق الأطراف
local resizing = false
local resizeType = nil
local startSize = nil
local startPos = nil
local RESIZE_MARGIN = 5

mainWindow.MouseMoved:Connect(function(x, y)
    if dragging or resizing then return end
    
    local abs = mainWindow.AbsolutePosition
    local size = mainWindow.AbsoluteSize
    local relX, relY = x - abs.X, y - abs.Y
    local onLeft = relX <= RESIZE_MARGIN
    local onRight = relX >= size.X - RESIZE_MARGIN
    local onTop = relY <= RESIZE_MARGIN
    local onBottom = relY >= size.Y - RESIZE_MARGIN

    if (onLeft or onRight) and (onTop or onBottom) then
        mainWindow.MouseIcon = (onLeft and onTop) or (onRight and onBottom) and "rbxasset://SystemCursors/SizeNWSE" or "rbxasset://SystemCursors/SizeNESW"
    elseif onLeft or onRight then
        mainWindow.MouseIcon = "rbxasset://SystemCursors/SizeWE"
    elseif onTop or onBottom then
        mainWindow.MouseIcon = "rbxasset://SystemCursors/SizeNS"
    else
        mainWindow.MouseIcon = ""
    end
end)

mainWindow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local abs = mainWindow.AbsolutePosition
        local size = mainWindow.AbsoluteSize
        local mousePos = UserInputService:GetMouseLocation()
        local relX, relY = mousePos.X - abs.X, mousePos.Y - abs.Y
        
        local onLeft = relX <= RESIZE_MARGIN
        local onRight = relX >= size.X - RESIZE_MARGIN
        local onTop = relY <= RESIZE_MARGIN
        local onBottom = relY >= size.Y - RESIZE_MARGIN

        if onLeft or onRight or onTop or onBottom then
            resizing = true
            startPos = mousePos
            startSize = mainWindow.Size
            resizeType = {
                left = onLeft,
                right = onRight,
                top = onTop,
                bottom = onBottom
            }
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = UserInputService:GetMouseLocation() - startPos
        local newSize = startSize
        local newPos = mainWindow.Position

        if resizeType.right then
            newSize = UDim2.new(
                startSize.X.Scale,
                math.clamp(startSize.X.Offset + delta.X, window.minSize.X, window.maxSize.X),
                newSize.Y.Scale,
                newSize.Y.Offset
            )
        end
        if resizeType.bottom then
            newSize = UDim2.new(
                newSize.X.Scale,
                newSize.X.Offset,
                startSize.Y.Scale,
                math.clamp(startSize.Y.Offset + delta.Y, window.minSize.Y, window.maxSize.Y)
            )
        end

        mainWindow.Size = newSize
        mainWindow.Position = newPos
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
        mainWindow.MouseIcon = ""
    end
end)

-- تعديل زر الإغلاق لاستخدام نافذة التأكيد
closeButton.MouseButton1Click:Connect(function()
    window:CreateConfirmDialog()
end)
