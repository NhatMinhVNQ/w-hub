local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "WindUI Library", -- UI Title
    Icon = "droplet-off", -- Url or rbxassetid or lucide
    Author = ".ftgs", -- Author & Creator
    Folder = "CloudHub", -- Folder name for saving data (And key)
    Size = UDim2.fromOffset(580, 460), -- UI Size
    KeySystem = { -- Creates key system
        Key = { "1234", "SuperKey5678" }, -- keys
        Note = "The Key is '1234' or 'SuperKey5678'", -- Note
        URL = "https://github.com/Footagesus/WindUI", -- URL To get key (example: Discord)
        SaveKey = true, -- Saves the key in the folder specified above
    }, 
    Transparent = true,-- UI Transparency
    Theme = "Dark", -- UI Theme
    SideBarWidth = 200, -- UI Sidebar Width (number)
    HasOutline = false, -- Adds Oultines to the window
})

WindUI:SetNotificationLower(false)

Window:EditOpenButton({
    Title = "Open UI Button",
    Icon = "image-upscale",  -- New icon
    CornerRadius = UDim.new(0,10),
    StrokeThickness = 3,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    )
})

-- Tabs

-- TransparencyValue
WindUI.TransparencyValue = .1

-- Font (example)
-- WindUI:SetFont("rbxassetid://font-id")

--- Section for Tabs

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house",
})

Window:SelectTab(1)

local EmptyTab = Window:Tab({
    Title = "Empty Tab",
    Icon = "frown",
})

local EmptyTab2 = Window:Tab({
    Title = "Tab Without icon",
})

local NotificationTab = Window:Tab({
    Title = "Notification Tab",
    Icon = "bell",
})

local BlockedElementsTab = Window:Tab({
    Title = "Blocked Elements",
    Icon = "rbxassetid://120011858138977",
})

local Divider = Window:Divider()

local TabWithNewIcon = Window:Tab({
    Title = "Tab with new Icon",
    Icon = "book-user",
})

local Divider = Window:Divider()

local WindowTab = Window:Tab({
    Title = "Window and File Configuration",
    Icon = "settings",
})
local CreateThemeTab = Window:Tab({
    Title = "Create theme",
    Icon = "palette",
})

local Divider = Window:Divider()

for i=1, 20 do
    Window:Tab({
        Title = "Just An Empty Tab",
        Image = "grid"
    })
end

-- Main Tab

MainTab:Section({ 
    Title = "Big section!",
    TextSize = 22,
})
MainTab:Section({ 
    Title = "Section Left",
    TextXAlignment = "Left"
})
MainTab:Section({ 
    Title = "Section Center",
    TextXAlignment = "Center"
})
MainTab:Section({ 
    Title = "Section Right",
    TextXAlignment = "Right"
})

MainTab:Section({ Title = "Paragraphs" })

local Paragraph1 = MainTab:Paragraph({
    Title = "Paragraph",
    Desc = "Paragraph Content \nAnd second line",
})
local Paragraph = MainTab:Paragraph({
    Title = "Paragraph without content",
})
local Paragraph2 = MainTab:Paragraph({
    Title = "Paragraph with Lucide icon.",
    --Desc = "Paragraph With Lucide icon.",
    Image = "frown"
})
local Paragraph3 = MainTab:Paragraph({
    Title = "Paragraph with URL image.",
    --Desc = "Paragraph With Lucide icon.",
    Image = "https://images.opencollective.com/lucide-icons/9fe79a6/logo/256.png"
})
local Paragraph4 = MainTab:Paragraph({
    Title = "Paragraph with rbxassetid:// image and ImageSize=20",
    Desc = "BHub is my unsuccessful project",
    Image = "rbxassetid://13899223441",
    ImageSize = 20,
})
local Paragraph5 = MainTab:Paragraph({
    Title = "Paragraph with Buttons",
    Buttons = {
        {
            Title = "Button 1",
            Callback = function() print("hi") end
        },
        {
            Title = "Button 2",
            Callback = function() print("hi 2") end
        }
    }
})
local Paragraph6 = MainTab:Paragraph({
    Title = "Paragraph with Buttons and Image",
    Image = "car",
    Buttons = {
        {
            Title = "Button 1",
            Callback = function() print("hi") end
        },
        {
            Title = "Button 2",
            Callback = function() print("hi 2") end
        },
        {
            Title = "Button 3",
            Callback = function() print("hi 2") end
        }
    }
})

MainTab:Section({ Title = "Code" })

MainTab:Code({
    Title = "main.lua",
    Code = [[-- This is a simple Lua script
local message = "hi"
print(message)

-- Condition check
if message == "hi" then
    print("Hello, world!")
end

local function pisun(a,b)
    return print(a,b)
end

pisun("hello", "world")]],
})

MainTab:Code({
    Title = "Example.lua",
    Code = [[local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "WindUI Library", -- UI Title
    Icon = "image", -- Url or rbxassetid or lucide
    Author = ".ftgs", -- Author & Creator
    Folder = "CloudHub", -- Folder name for saving data (And key)
    Size = UDim2.fromOffset(580, 460), -- UI Size
    KeySystem = { -- Creates key system
        Key = "1234", -- key
        Note = "The Key is 1234", -- Note
        URL = "https://github.com/Footagesus/WindUI", -- URL To get key (example: Discord)
        SaveKey = true, -- Saves the key in the folder specified above
    }, 
    Transparent = true,-- UI Transparency
    Theme = "Dark", -- UI Theme
    SideBarWidth = 170, -- UI Sidebar Width (number)
    HasOutline = true, -- Adds Oultines to the window
})

]],
})

Paragraph1:SetTitle("New Title!")
Paragraph1:SetDesc("New Description!")


MainTab:Section({ Title = "Buttons" })

local Dialog = Window:Dialog({
    Icon = "droplet", -- lucide
    Title = "Dialog",
    Content = "Dialog Content",
    Buttons = {
        {
            Title = "Confirm",
            Variant = "Primary", -- Or "Secondary"
            Callback = function()
                print("confirm")
            end
        },
        {
            Title = "Cancel",
            Callback = function()
                print("cancel")
            end
        },
        {
            Title = "Idk",
            Callback = function()
                print("idk")
            end
        }
    }
})

local Button = MainTab:Button({
    Title = "Button Main",
    Desc = "Button Desc",
    Callback = function()
        Dialog:Open()
    end,
})
local ButtonClose = MainTab:Button({
    Title = "Button Main Close Window",
    Callback = function()
        Window:Close():Destroy()
    end,
})


MainTab:Section({ Title = "Toggles" })

local Button = MainTab:Toggle({
    Title = "Toggle Main",
    Callback = function(state)
        print(state)
    end,
})
local Button = MainTab:Toggle({
    Title = "Toggle Main",
    Desc = "Toggle Desc Main",
    Value = true,
    Callback = function(state)
        if state then
            print("True State")
        else
            print("False State")
        end
    end,
})


MainTab:Section({ Title = "Sliders" })

local Slider = MainTab:Slider({
    Title = "Slider FieldOfView",
    Step = 1,
    Value = {
        Min = 20,
        Max = 120,
        Default = 70,
    },
    Callback = function(value)
        game.Workspace.Camera.FieldOfView = value
    end
})

local Slider = MainTab:Slider({
    Title = "Slider Main FieldOfView",
    Desc = "Slider Main Desc",
    Step = 1,
    Value = {
        Min = 16,
        Max = 500,
        Default = 16,
    },
    Callback = function(value)
        game.Workspace[game.Players.LocalPlayer.Name].Humanoid.WalkSpeed = value
    end
})

local Sliderbb = MainTab:Slider({
    Title = "Just slider",
    Locked = false,
    Step = 1,
    Value = {
        Min = 0,
        Max = 1000,
        Default = 0,
    },
    Callback = function(value)
        -- Functikn
    end
})

Sliderbb:Set(20)


MainTab:Section({ Title = "Keybinds" })

local KeybindClicked = false
local Keybind = MainTab:Keybind({
    Title = "Keybind Toggle UI",
    Desc = "Keybind Toggle UI Desc",
    Value = "LeftShift",
    CanChange = true,
    Callback = function(k)
        if not KeybindClicked then
            Window:Close()
        else
            Window:Open()
        end
        KeybindClicked = not KeybindClicked
    end
})
local Keybind = MainTab:Keybind({
    Title = "Keybind Toggle UI",
    Value = "F",
    CanChange = true,
    Callback = function(k)
        print(k)
    end
})


MainTab:Section({ Title = "Inputs" })

local Input = MainTab:Input({
    Title = "Input Notify",
    Desc = "Input Notify Desc",
    Value = "Text Hello",
    PlaceholderText = "Enter your message ahhh",
    ClearTextOnFocus = true, -- muahahahaah
    Callback = function(Text)
        WindUI:Notify({
            Title = "Input message",
            Content = "Message: " .. Text,
            Duration = 5,
        })
    end
})
local Input = MainTab:Input({
    Title = "Input Notify 2",
    Value = "",
    PlaceholderText = "Enter your message ahhh",
    ClearTextOnFocus = false,
    Callback = function(Text)
        WindUI:Notify({
            Title = "Input message 2",
            Content = "Message: " .. Text,
            Duration = 5,
        })
    end
})


MainTab:Section({ Title = "Dropdowns" })

local Dropdown = MainTab:Dropdown({
    Title = "Dropdown",
    Desc = "Dropdown Desc",
    Multi = false,
    Value = "Tab 1",
    AllowNone = true,
    Values = {
        "Tab 1", "Tab 2", "Tab 3", "Tab 4", "Tab 5", "Tab 6", "Tab 7", "Tab 8", "Tab 9", "Tab 10",
        "Tab 11", "Tab 12", "Tab 13", "Tab 14", "Tab 15", "Tab 16", "Tab 17", "Tab 18", "Tab 19", "Tab 20"
    },
    Callback = function(Tab)
        WindUI:Notify({
            Title = "Dropdown Select",
            Content = "Selected: " .. Tab,
            Duration = 2,
        })
    end
})

MainTab:Button({
    Title = "Refresh Dropdown ↑",
    Callback = function()
        local someItems = {}
        
        for i = 1, 100 do
            table.insert(someItems, "Item blablablabla " .. i)
        end

        Dropdown:Refresh(someItems)
    end
})

local Dropdown = MainTab:Dropdown({
    Title = "Dropdown 2",
    Desc = "Dropdown Desc 2",
    Multi = true,
    Value = {
        "Tab 1", "Tab 5"
    },
    Values = {
        "Tab 1", "Tab 2", "Tab 3", "Tab 4", "Tab 5", 
    },
    Callback = function(Tab)
        WindUI:Notify({
            Title = "Dropdown Select 2",
            Content = "Selected: " .. game:GetService("HttpService"):JSONEncode(Tab),
            Duration = 2,
        })
    end
})

MainTab:Section({ Title = "Colorpickers" })

local Colorpicker = MainTab:Colorpicker({
    Title = "Colorpicker",
    Default = Color3.fromRGB(255, 129, 0),
    Callback = function(color)
        WindUI:Notify({
            Title = "Colorpicker Callback",
            Content = "Color: \nR: " .. math.floor(color.R * 255) .. "\nG: " .. math.floor(color.G * 255) .. "\nB: " .. math.floor(color.B * 255),
            Duration = 6,
        })
    end
})

local Colorpicker2 = MainTab:Colorpicker({
    Title = "Colorpicker",
    Desc = "Colorpicker Desc Transparency",
    Transparency = 0.5,
    Default = Color3.fromRGB(96, 205, 255),
    Callback = function(color, transparency)
        WindUI:Notify({
            Title = "Colorpicker Callback 2",
            Content = "Color: \nR: " .. math.floor(color.R * 255) .. "\nG: " .. math.floor(color.G * 255) .. "\nB: " .. math.floor(color.B * 255) .. "\nTransparency: " .. transparency,
            Duration = 6,
        })
    end
})

-- Notification Tab


local Button = NotificationTab:Button({
    Title = "Notify",
    Desc = "Notify Button Desc",
    Callback = function()
        WindUI:Notify({
            Title = "Notification",
            Content = "Content",
            Icon = "eye",
            Duration = 5,
        })
    end,
})
local Button = NotificationTab:Button({
    Title = "Long Notify",
    Desc = "Long Notify Button Desc",
    Callback = function()
        WindUI:Notify({
            Title = "Notification LONG AND BIG a a a a a ",
            Content = "Content LON GGGGG EEE RRR AND BIGGER aaaaaaaaa",
            Icon = "droplet",
            Duration = 200,
        })
    end,
})

-- Outdated

-- local Button = NotificationTab:Button({
--     Title = "Notification with buttons",
--     Desc = "Notify with buttons and Callback",
--     Callback = function()
--         local Notification
--         Notification = WindUI:Notify({
--             Title = "Question",
--             Content = "Would you like to die?",
--             Icon = "circle-help",
--             CanClose = false, -- dont allow to close the notification
--             --Duration = 5, -- removing duration
--             Buttons = {  -- Buttons
--                 {
--                     Name = "Yes",
--                     Callback = function() 
--                         game.Players.LocalPlayer.Character.Humanoid.Health = 0 
--                     end
--                 },
--                 {
--                     Name = "Nope",
--                     Callback = function() 
--                         print("Cancelled...")
--                     end
--                 },
--             }
--         })
--     end,
-- })


-- Window Tab

--- Custom Theme Load

---- 1. Add Theme

WindUI:AddTheme({
    Name = "Halloween",
    
    Accent = "#331400",
    Outline = "#400000",
    
    Text = "#EAEAEA",
    PlaceholderText = "#AAAAAA"
})



---- 2. Use Theme

WindUI:SetTheme("Dark")

---- 3. Load Themes

local HttpService = game:GetService("HttpService")

local folderPath = "WindUI"
makefolder(folderPath)

local function SaveFile(fileName, data)
    local filePath = folderPath .. "/" .. fileName .. ".json"
    local jsonData = HttpService:JSONEncode(data)
    writefile(filePath, jsonData)
end

local function LoadFile(fileName)
    local filePath = folderPath .. "/" .. fileName .. ".json"
    if isfile(filePath) then
        local jsonData = readfile(filePath)
        return HttpService:JSONDecode(jsonData)
    end
end

local function ListFiles()
    local files = {}
    for _, file in ipairs(listfiles(folderPath)) do
        local fileName = file:match("([^/]+)%.json$")
        if fileName then
            table.insert(files, fileName)
        end
    end
    return files
end

WindowTab:Section({ Title = "Window" })

local themeValues = {}
for name, _ in pairs(WindUI:GetThemes()) do
    table.insert(themeValues, name)
end

local themeDropdown = WindowTab:Dropdown({
    Title = "Select Theme",
    Multi = false,
    AllowNone = false,
    Value = nil,
    Values = themeValues,
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})
themeDropdown:Select(WindUI:GetCurrentTheme())

local ToggleTransparency = WindowTab:Toggle({
    Title = "Toggle Window Transparency",
    Callback = function(e)
        Window:ToggleTransparency(e)
    end,
    Value = WindUI:GetTransparency()
})

WindowTab:Section({ Title = "Save" })

local fileNameInput = ""
WindowTab:Input({
    Title = "Write File Name",
    PlaceholderText = "Enter file name",
    Callback = function(text)
        fileNameInput = text
    end
})

WindowTab:Button({
    Title = "Save File",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

WindowTab:Section({ Title = "Load" })

local filesDropdown
local files = ListFiles()

filesDropdown = WindowTab:Dropdown({
    Title = "Select File",
    Multi = false,
    AllowNone = true,
    Values = files,
    Callback = function(selectedFile)
        fileNameInput = selectedFile
    end
})

WindowTab:Button({
    Title = "Load File",
    Callback = function()
        if fileNameInput ~= "" then
            local data = LoadFile(fileNameInput)
            if data then
                WindUI:Notify({
                    Title = "File Loaded",
                    Content = "Loaded data: " .. HttpService:JSONEncode(data),
                    Duration = 5,
                })
                if data.Transparent then 
                    Window:ToggleTransparency(data.Transparent)
                    ToggleTransparency:SetValue(data.Transparent)
                end
                if data.Theme then WindUI:SetTheme(data.Theme) end
            end
        end
    end
})

WindowTab:Button({
    Title = "Overwrite File",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

WindowTab:Button({
    Title = "Refresh List",
    Callback = function()
        filesDropdown:Refresh(ListFiles())
    end
})






----



BlockedElementsTab:Code({
    Title = "Blocked_Example.lua",
    Locked = true,
    Code = [[local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "WindUI Library", -- UI Title
    Icon = "image", -- Url or rbxassetid or lucide
    Author = ".ftgs", -- Author & Creator
    Folder = "CloudHub", -- Folder name for saving data (And key)
    Size = UDim2.fromOffset(580, 460), -- UI Size
    KeySystem = { -- Creates key system
        Key = "1234", -- key
        Note = "The Key is 1234", -- Note
        URL = "https://github.com/Footagesus/WindUI", -- URL To get key (example: Discord)
        SaveKey = true, -- Saves the key in the folder specified above
    }, 
    Transparent = true,-- UI Transparency
    Theme = "Dark", -- UI Theme
    SideBarWidth = 170, -- UI Sidebar Width (number)
    HasOutline = true, -- Adds Oultines to the window
})

]],
})


local Button = BlockedElementsTab:Button({
    Title = "Blocked Button",
    Desc = "Blocked Button Desc",
    Locked = true, --
    Callback = function()
        WindUI:Notify({
            Title = "Hui",
            Duration = 2,
        })
    end
})

local Toggle = BlockedElementsTab:Toggle({
    Title = "Blocked Toggle",
    Callback = function(state)
        print(state)
    end,
})
Toggle:Lock()

local Sliderbb = BlockedElementsTab:Slider({
    Title = "Blocked Slider",
    Locked = true,
    Step = 1,
    Value = {
        Min = 20,
        Max = 120,
        Default = 70,
    },
    Callback = function(value)
        game.Workspace.Camera.FieldOfView = value
    end
})

local Keybind = BlockedElementsTab:Keybind({
    Title = "Blocked Keybind",
    Value = "F",
    Locked = true,
    CanChange = true,
    Callback = function(k)
        print(k)
    end
})

local Input = BlockedElementsTab:Input({
    Title = "Blocked Input",
    Value = "",
    Locked = true,
    PlaceholderText = "Enter your message...",
    ClearTextOnFocus = false,
    Callback = function(Text)
        WindUI:Notify({
            Title = "Input message 2",
            Content = "Message: " .. Text,
            Duration = 5,
        })
    end
})

local Dropdown = BlockedElementsTab:Dropdown({
    Title = "Blocked Dropdown",
    Multi = false,
    Value = "Tab 1",
    Locked = true,
    AllowNone = true,
    Values = {
        "Tab 1", "Tab 2", "Tab 3", "Tab 4", "Tab 5", "Tab 6", "Tab 7", "Tab 8", "Tab 9", "Tab 10",
        "Tab 11", "Tab 12", "Tab 13", "Tab 14", "Tab 15", "Tab 16", "Tab 17", "Tab 18", "Tab 19", "Tab 20"
    },
    Callback = function(Tab)
        WindUI:Notify({
            Title = "Dropdown Select",
            Content = "Selected: " .. Tab,
            Duration = 2,
        })
    end
})

BlockedElementsTab:Section({Title = "Unlocked"})

local Colorpicker = BlockedElementsTab:Colorpicker({
    Title = "Unlocked Colorpicker",
    Locked = true,
    Default = Color3.fromRGB(255, 129, 0),
    Callback = function(color)
        WindUI:Notify({
            Title = "Colorpicker Callback",
            Content = "Color: \nR: " .. math.floor(color.R * 255) .. "\nG: " .. math.floor(color.G * 255) .. "\nB: " .. math.floor(color.B * 255),
            Duration = 6,
        })
    end
})

--- Unlock
Colorpicker:Unlock()


---

local currentThemeName = WindUI:GetCurrentTheme()
local themes = WindUI:GetThemes()

local ThemeAccent = themes[currentThemeName].Accent
local ThemeOutline = themes[currentThemeName].Outline
local ThemeText = themes[currentThemeName].Text
local ThemePlaceholderText = themes[currentThemeName].PlaceholderText

function updateTheme()
    WindUI:AddTheme({
        Name = currentThemeName,
        Accent = ThemeAccent,
        Outline = ThemeOutline,
        Text = ThemeText,
        PlaceholderText = ThemePlaceholderText
    })
    WindUI:SetTheme(currentThemeName)
end

local CreateInput = CreateThemeTab:Input({
    Title = "Theme Name",
    Value = currentThemeName,
    Callback = function(name)
        currentThemeName = name
    end
})

CreateThemeTab:Colorpicker({
    Title = "Background Color",
    Default = Color3.fromHex(ThemeAccent),
    Callback = function(color)
        ThemeAccent = color:ToHex()
    end
})

CreateThemeTab:Colorpicker({
    Title = "Outline Color",
    Default = Color3.fromHex(ThemeOutline),
    Callback = function(color)
        ThemeOutline = color:ToHex()
    end
})

CreateThemeTab:Colorpicker({
    Title = "Text Color",
    Default = Color3.fromHex(ThemeText),
    Callback = function(color)
        ThemeText = color:ToHex()
    end
})

CreateThemeTab:Colorpicker({
    Title = "Placeholder Text Color",
    Default = Color3.fromHex(ThemePlaceholderText),
    Callback = function(color)
        ThemePlaceholderText = color:ToHex()
    end
})

CreateThemeTab:Button({
    Title = "Update Theme",
    Callback = function()
        updateTheme()
    end
})