# Library redzV5 for PORG

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
    Name = "قائمة منسدلة",
    Options = {"الخيار 1", "الخيار 2", "الخيار 3"},
    Default = "الخيار 1",
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
    Name = "النافذة الأولى",
    SubTitle = "window 1"
})

local window2 = redzlib:MakeWindow({
    Name = "النافذة الثانية", 
    SubTitle = window 2"
})
```
# add 2 tab

### You can change the window number (Window 1, Window 2) in order to add sections and others.

```lua 
local tab1 = window1:MakeTab({
    Name = "التبويب الأول", -- name tab
    Icon = "rbxassetid://123456789" --icon
})

local tab2 = window1:MakeTab({
    Name = "التبويب الثاني", -- name tab
    Icon = "rbxassetid://987654321" -- icon
})
```

#

```lua
tab1:AddDropdown({
    Name = "قائمة متعددة الاختيارات",
    Options = {"خيار 1", "خيار 2", "خيار 3", "خيار 4"},
    Default = {"خيار 1", "خيار 2"},
    MultiSelect = true,
    Callback = function(Value)
        print(table.concat(Value, ", "))
    end
})

```

#

```lua
tab1:AddButton({
    Name = "زر مع تأكيد",
    Desc = "يتطلب تأكيد قبل التنفيذ",
    Callback = function()
        window1:Dialog({
            Title = "تأكيد",
            Text = "هل أنت متأكد من تنفيذ هذا الإجراء؟",
            Options = {
        {"نعم", function()
                    print("تم التأكيد")
                end},
                {"لا"}
            }
        })
    end
})
```

#

```lua
```
#

```lua
```
#

```lua
```
#

```lua
```

```

-- إضافة زر مع تأكيد
tab1:AddButton({
    Name = "زر مع تأكيد",
    Desc = "يتطلب تأكيد قبل التنفيذ",
    Callback = function()
        window1:Dialog({
            Title = "تأكيد",
            Text = "هل أنت متأكد من تنفيذ هذا الإجراء؟",
            Options = {
        {"نعم", function()
                    print("تم التأكيد")
                end},
                {"لا"}
            }
        })
    end
})

-- إضافة شريط تمرير مع وحدات
tab1:AddSlider({
    Name = "السرعة",
    Min = 0,
    Max = 100,
    Default = 16,
    Increase = 1,
    Flag = "speed",
    Callback = function(Value)
        print(Value .. " studs/second")
    end
})

-- إضافة قسم مع عناصر متعددة
local section = tab2:AddSection({
    Name = "إعدادات اللاعب"
})

-- إضافة مؤشرات تبديل مرتبطة
tab2:AddToggle({
    Name = "تفعيل الطيران",
    Default = false,
    Flag = "flying",
    Callback = function(Value)
        if Value then
            print("تم تفعيل الطيران")
        else
            print("تم إيقاف الطيران")
        end
    end
})

-- إضافة مربع نص مع تحقق
tab2:AddTextBox({
    Name = "اسم اللاعب",
    Default = "",
    PlaceholderText = "ادخل اسم اللاعب",
    ClearText = true,
    Callback = function(Value)
        -- تحقق من صحة الاسم
        if #Value >= 3 then
            print("تم تعيين الاسم: " .. Value)
        else
            print("الاسم قصير جداً")
        end
    end
})

-- إضافة زر تحديث
tab2:AddButton({
    Name = "تحديث",
    Desc = "تحديث الإعدادات",
    Callback = function()
        print("جاري التحديث...")
        wait(1)
        print("تم التحديث!")
    end
})

-- إضافة نص معلوماتي
tab2:AddParagraph({
    Title = "معلومات",
    Text = [[
        - استخدم الزر للتحديث
        - يمكنك تغيير الإعدادات في أي وقت
        - احفظ التغييرات قبل الخروج
    ]]
})

-- إضافة رابط ديسكورد مع شعار مخصص
tab2:AddDiscordInvite({
    Name = "مجتمع السكربت",
    Logo = "rbxassetid://123456789",
    Invite = "https://discord.gg/yourserver",
    Desc = "انضم إلى مجتمعنا للحصول على المساعدة والتحديثات!"
})

-- إضافة دالة تحديث العناصر
local function UpdateElements()
    tab1:UpdateSlider("speed", 50)
    tab2:UpdateToggle("flying", true)
end

-- إضافة دالة حفظ الإعدادات
local function SaveSettings()
    local settings = {
        speed = redzlib:GetFlag("speed"),
        flying = redzlib:GetFlag("flying")
    }
    
    print("تم حفظ الإعدادات:", settings)
end

-- إضافة مؤقت لحفظ الإعدادات تلقائياً
spawn(function()
    while wait(60) do -- حفظ كل دقيقة
        SaveSettings()
    end
end)

-- إضافة دالة تنظيف عند إغلاق السكربت
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "redz Library V5" then
        SaveSettings()
        print("تم إغلاق السكربت")
    end
end)

```
