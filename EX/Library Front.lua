local Library = require(script.Parent.RedZLibrary)

-- Create new library instance
local gui = Library.new()

-- Create window with custom config
local window = gui:CreateWindow({
    title = "RedZ Library",
    size = UDim2.new(0, 400, 0, 300),
    theme = {
        background = Color3.fromRGB(25, 25, 25),
        foreground = Color3.fromRGB(30, 30, 30),
        accent = Color3.fromRGB(0, 170, 255),
        text = Color3.fromRGB(255, 255, 255),
        buttons = {
            close = Color3.fromRGB(255, 0, 0),
            minimize = Color3.fromRGB(50, 50, 50)
        }
    }
})

-- Add buttons or other elements
gui:AddButton(window, "Click Me!", function()
    print("Button clicked!")
end)
