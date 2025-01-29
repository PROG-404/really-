-- Get the library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PROG-404/really-/refs/heads/main/Model.lua"))()

-- Create a new instance of the library
local UI = Library.new()

-- Create a window
local Window = UI:CreateWindow({
    title = "My Cool GUI",
    size = UDim2.new(0, 500, 0, 350),
})

-- Create tabs
local MainTab = Tabs:AddTab("Main", "rbxassetid://3926307971")
local SettingsTab = Tabs:AddTab("Settings", "rbxassetid://3926307971")


-- Add buttons to Main tab
Library:AddButton(MainTab, "Click Me!", function()
    print("Button clicked!")
end)
