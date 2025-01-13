local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()
local window = redzlib:MakeWindow({
    Name = "Blox peta", 
    SubTitle = "Porg",
    SaveFolder = "example.json"
})

local Maintab = window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://123456789" -- icons 
})

Maintab:AddSection({
    Name = "Main"
})

Maintab:AddDiscordInvite({
    Name = "Invite",
    Logo = "rbxassetid://123456789", -- icon roblox 
    Invite = "https://discord.gg/BnYk2BtZ" -- link discord 
})
