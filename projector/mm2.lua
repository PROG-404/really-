local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat


local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()

local window = redzlib:MakeWindow({
    Name = "Script Mm2",
    SubTitle = "by Front_9",
    SaveFolder = "MM2Script"
})

local mainTab = window:MakeTab({
    Title = "Main",
    Icon = "rbxassetid://10709752906"
})



local function SaveSettings()
    local settings = {
        flight = redzlib:GetFlag("flightToggle")
    }
    
    print("Settings saved:", settings)
end

spawn(function()
    while wait(60) do
        SaveSettings()
    end
end)


game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "Script Mm2" then
        SaveSettings()
        print("Script closed")
    end
end)
