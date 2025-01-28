local Library = require("https://raw.githubusercontent.com/PROG-404/really-/refs/heads/main/Probably.lua")

-- Create new library instance
local gui = Library.new()

-- Create window with custom config
local window = gui:CreateWindow({
    title = "FRONT LIBRARY",
})

-- Add buttons or other elements
gui:AddButton(window, "Click Me!", function()
    print("Button clicked!")
end)
