 Library redzV5 for PORG

```lua
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua"))()
```
# Add window redz
```lua
local window = redzlib:MakeWindow({
    Name = "NAME WINDOW", 
    SubTitle = "subtitle",
    SaveFolder = "Folder name (optional)"
})

```
# Add Tab redz



```lua
local tab = window:MakeTab({
    Name = "name tab",
    Icon = "rbxassetid://123456789" -- icons 
})
```
# Add section 

```lua
tab:AddSection({
    Name = "Name Section"
})
```

# Add Button 
```lua
tab:AddButton({
    Name = "Name Button",
    Desc = "Add a description",
    Callback = function()
        print("Value")
    end
})
```
# Add Toggles 

```lua
tab:AddToggle({
    Name = "Name Togles",
    Default = false,
    Flag = "toggle1",
    Callback = function(Value)
        print(Value)
    end
})
```

# Add dropdown 

```lua
tab:AddDropdown({
    Name = "Name Drop down list",
    Options = {"Option 1", " 2 Option", " 3 Option"},
    Default = "Option 1",
    Flag = "dropdown1",
    Callback = function(Value)
        print(Value)
    end
})

```

# Add Slider 

```lua
tab:AddSlider({
    Name = "Name Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Increase = 1,
    Flag = "slider1",
    Callback = function(Value)
        print(Value)
    end
})

```

# Add Text Box 

```lua
tab:AddTextBox({
    Name = "Name Text Box",
    Default = "",
    PlaceholderText = "Text here"
    ClearText = true,
    Callback = function(Value)
        print(Value)
    end
})

```
# Add Paragraph

```lua
tab:AddParagraph({
    Title = "Name",
    Text = "Text"
})
```
# Add Discord Invite

```lua
tab:AddDiscordInvite({
    Name = "welcome to discord",
    Logo = "rbxassetid://123456789", -- icon roblox 
    Invite = "https://discord.gg/invite" -- link discord 
})
```
# Multiple uses and questions

# Add 2 window

```lua
local window1 = redzlib:MakeWindow({
    Name = "Name window 1",
    SubTitle = "window 1"
})

local window2 = redzlib:MakeWindow({
    Name = "Name Window 2", 
    SubTitle = "window 2"
})
```
# add 2 tab

### You can change the window number (Window 1, Window 2) in order to add sections and others.

```lua 
local tab1 = window1:MakeTab({
    Name = "Name Tab 1", -- name tab
    Icon = "rbxassetid://123456789" --icon
})

local tab2 = window1:MakeTab({
    Name = "Name Tab 2", -- name tab
    Icon = "rbxassetid://987654321" -- icon
})
```

# Add Dropdown Multiple options

```lua
tab1:AddDropdown({
    Name = "Name Dropdown",
    Options = {"Option 1", "Option 2", "Option 3", "Option 4"},
    Default = {"Option 1", "Option 2"},
    MultiSelect = true,
    Callback = function(Value)
        print(table.concat(Value, ", "))
    end
})

```

# Confirm button

```lua
tab1:AddButton({
    Name = "Confirm button",
    Desc = "Requires confirmation before execution",
    Callback = function()
        window1:Dialog({
            Title = "to be sure",
            Text = "Are you sure to perform this procedure?",
            Options = {
        {"yes", function()
                    print("Confirmed")
                end},
                {"No"}
            }
        })
    end
})
```

# Add slider together modules

```lua
tab1:AddSlider({
    Name = "Name Slidr",
    Min = 0,
    Max = 100,
    Default = 16,
    Increase = 1,
    Flag = "speed",
    Callback = function(Value)
        print(Value .. " studs/second")
    end
})

```
# toggles together notifications

```lua
tab2:AddToggle({
    Name = "Flight activation (example)",
    Default = false,
    Flag = "flying",
    Callback = function(Value)
        if Value then
            print("Flight has been activated")
        else
            print("Flight has been stopped")
        end
    end
})
```
# Text Box Together Check

```lua

tab2:AddTextBox({
    Name = "Name Player",
    Default = "",
    PlaceholderText = "Add Name Player",
    ClearText = true,
    Callback = function(Value)
        -- Verify that the value is more than three characters long
        if #Value >= 3 then
            print(" The name has been assigned: " .. Value)
        else
            print("The name is too short")
        end
    end
})
```
# Update Settings

```lua
tab2:AddButton({
    Name = "Update",
    Desc = "Update Settings",
    Callback = function()
        print("Updating...")
        wait(1)
        print("has been updated!")
    end
})

```
# information

```lua
tab2:AddParagraph({
    Title = "Information about you ", -- example 
    Text = [[
        - text
        - text
        - text
		-- You can add more
    ]]
})
```

# Discord added

```lua
tab2:AddDiscordInvite({
    Name = "The name becomes clear and white",
    Logo = "rbxassetid://123456789", -- The Discord image must be with a Reblox link
    Invite = "https://discord.gg/yourserver", -- Link to add Discord
    Desc = "The name becomes transparent underneath"
})
```

# Updated some buttons

```lua
local function UpdateElements()
    tab1:UpdateSlider("speed", 50)
    tab2:UpdateToggle("flying", true)
end
```
# Save information

```lua
local function SaveSettings()
    local settings = {
        speed = redzlib:GetFlag("speed"),
        flying = redzlib:GetFlag("flying")
    }
    
    print("Settings have been saved:", settings)
end
```

# Save items

```lua
spawn(function()
    while wait(60) do -- Save every minute
        SaveSettings()
    end
end)
```

# Close script

```lua
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "redz Library V5" then
        SaveSettings()
        print("The script has been closed")
    end
end)
```

# There may be items that are not listed here, so please wait if you don't see what you want
