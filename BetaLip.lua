local ProtLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/PROG-404/really-/refs/heads/main/Library.lua"))()
local mainWindow = ProgLib.UI.Window.new({    Title = "Window Prog",  Size = UDim2.new(0, 600, 0, 400),  Position = UDim2.new(0.5, -300, 0.5, -200), ProgLib:setTheme("Dark")})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
-- Value 
_G.AutoClick = true

-- Function 

Function AutoClick
  _G.AutoClick == true 
	--server
end)
local mainButton = ProgLib.UI.Components.Button.new({
    Text = "Remote",
    Size = UDim2.new(0, 200, 0, 40),
    Position = UDim2.new(0.5, -100, 0.2, 0),
    OnClick = function()
