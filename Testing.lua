-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- Tạo GUI Console
local function CreateConsoleGUI()
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VampireConsole"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "ConsoleFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0, 20, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Stroke
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(100, 100, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Vampire Sparkle Hub - Console"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 4)
    UICorner2.Parent = CloseButton
    
    -- Output Console
    local OutputFrame = Instance.new("Frame")
    OutputFrame.Name = "OutputFrame"
    OutputFrame.Size = UDim2.new(1, -20, 1, -130)
    OutputFrame.Position = UDim2.new(0, 10, 0, 50)
    OutputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    OutputFrame.BorderSizePixel = 0
    OutputFrame.ClipsDescendants = true
    OutputFrame.Parent = MainFrame
    
    local OutputScrolling = Instance.new("ScrollingFrame")
    OutputScrolling.Name = "OutputScrolling"
    OutputScrolling.Size = UDim2.new(1, 0, 1, 0)
    OutputScrolling.BackgroundTransparency = 1
    OutputScrolling.BorderSizePixel = 0
    OutputScrolling.ScrollBarThickness = 6
    OutputScrolling.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    OutputScrolling.Parent = OutputFrame
    
    local OutputLayout = Instance.new("UIListLayout")
    OutputLayout.Name = "OutputLayout"
    OutputLayout.Padding = UDim.new(0, 5)
    OutputLayout.Parent = OutputScrolling
    
    -- Input Area
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Size = UDim2.new(1, -20, 0, 40)
    InputFrame.Position = UDim2.new(0, 10, 1, -50)
    InputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = MainFrame
    
    local InputBox = Instance.new("TextBox")
    InputBox.Name = "InputBox"
    InputBox.Size = UDim2.new(1, -80, 1, -10)
    InputBox.Position = UDim2.new(0, 5, 0, 5)
    InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Text = ""
    InputBox.PlaceholderText = "Nhập lệnh... (ví dụ: help, status, toggle autograb)"
    InputBox.TextSize = 14
    InputBox.Font = Enum.Font.Gotham
    InputBox.ClearTextOnFocus = false
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.Parent = InputFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 4)
    InputCorner.Parent = InputBox
    
    local SendButton = Instance.new("TextButton")
    SendButton.Name = "SendButton"
    SendButton.Size = UDim2.new(0, 60, 1, -10)
    SendButton.Position = UDim2.new(1, -65, 0, 5)
    SendButton.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    SendButton.Text = "Gửi"
    SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SendButton.TextSize = 14
    SendButton.Font = Enum.Font.GothamBold
    SendButton.Parent = InputFrame
    
    local SendCorner = Instance.new("UICorner")
    SendCorner.CornerRadius = UDim.new(0, 4)
    SendCorner.Parent = SendButton
    
    -- Quick Buttons
    local QuickButtonFrame = Instance.new("Frame")
    QuickButtonFrame.Name = "QuickButtonFrame"
    QuickButtonFrame.Size = UDim2.new(1, -20, 0, 30)
    QuickButtonFrame.Position = UDim2.new(0, 10, 1, -90)
    QuickButtonFrame.BackgroundTransparency = 1
    QuickButtonFrame.Parent = MainFrame
    
    local function CreateQuickButton(text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 80, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 12
        button.Font = Enum.Font.Gotham
        button.Parent = QuickButtonFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    -- Sắp xếp các nút nhanh
    local buttons = {
        {"Help", function() AddOutput("=== HELP ===") AddOutput("/help - Hiển thị trợ giúp") AddOutput("/status - Trạng thái tính năng") AddOutput("/toggle [tên] - Bật/tắt tính năng") AddOutput("/reload - Tải lại config") AddOutput("/clear - Xóa console") end},
        {"Status", function() ShowStatus() end},
        {"Clear", function() ClearOutput() end}
    }
    
    for i, btnData in ipairs(buttons) do
        local btn = CreateQuickButton(btnData[1], btnData[2])
        btn.Position = UDim2.new(0, (i-1)*85, 0, 0)
    end
    
    -- Biến để lưu trữ
    local consoleOutput = {}
    local isVisible = true
    
    -- Function để thêm output vào console
    local function AddOutput(text, color)
        color = color or Color3.fromRGB(255, 255, 255)
        
        local timestamp = os.date("[%H:%M:%S]")
        local messageFrame = Instance.new("Frame")
        messageFrame.Size = UDim2.new(1, 0, 0, 20)
        messageFrame.BackgroundTransparency = 1
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -10, 1, 0)
        messageLabel.Position = UDim2.new(0, 5, 0, 0)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = timestamp .. " " .. text
        messageLabel.TextColor3 = color
        messageLabel.TextSize = 12
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextYAlignment = Enum.TextYAlignment.Top
        messageLabel.TextWrapped = true
        messageLabel.Parent = messageFrame
        
        -- Auto resize height
        local textSize = TextService:GetTextSize(messageLabel.Text, messageLabel.TextSize, messageLabel.Font, Vector2.new(OutputScrolling.AbsoluteSize.X - 20, math.huge))
        messageFrame.Size = UDim2.new(1, 0, 0, textSize.Y + 5)
        messageLabel.Size = UDim2.new(1, -10, 0, textSize.Y)
        
        messageFrame.Parent = OutputScrolling
        
        table.insert(consoleOutput, {
            text = text,
            color = color,
            time = timestamp
        })
        
        -- Auto scroll to bottom
        task.wait()
        OutputScrolling.CanvasSize = UDim2.new(0, 0, 0, OutputLayout.AbsoluteContentSize.Y)
        OutputScrolling.CanvasPosition = Vector2.new(0, OutputScrolling.CanvasSize.Y.Offset)
    end
    
    -- Function xóa output
    local function ClearOutput()
        for _, child in ipairs(OutputScrolling:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        consoleOutput = {}
    end
    
    -- Function xử lý lệnh
    local function ProcessCommand(command)
        command = string.lower(command:gsub("^/", ""))
        local args = {}
        
        for arg in command:gmatch("%S+") do
            table.insert(args, arg)
        end
        
        if #args == 0 then return end
        
        local cmd = args[1]
        table.remove(args, 1)
        
        -- Lệnh help
        if cmd == "help" then
            AddOutput("=== HỆ THỐNG LỆNH ===", Color3.fromRGB(100, 200, 255))
            AddOutput("/help - Hiển thị trợ giúp")
            AddOutput("/status - Xem trạng thái tất cả tính năng")
            AddOutput("/toggle [tên] - Bật/tắt tính năng")
            AddOutput("/start [tên] - Bật tính năng")
            AddOutput("/stop [tên] - Tắt tính năng")
            AddOutput("/list - Danh sách tính năng")
            AddOutput("/reload - Tải lại config")
            AddOutput("/clear - Xóa console")
            AddOutput("/webhook [url] - Đặt webhook URL")
            AddOutput("/delay [tên] [giây] - Đặt delay")
            AddOutput("/config - Xem config hiện tại")
            
        -- Lệnh status
        elseif cmd == "status" then
            AddOutput("=== TRẠNG THÁI TÍNH NĂNG ===", Color3.fromRGB(100, 255, 100))
            
            -- Auto Farming
            AddOutput("\n[AUTO FARMING]:", Color3.fromRGB(255, 200, 100))
            local farmingStatus = {
                {"Auto Grab", _G.autoGrab},
                {"Auto Eat", _G.autoEat},
                {"Auto Sell", _G.autoSell},
                {"Auto Throw", _G.autoThrow},
                {"Auto TP", _G.autotp},
                {"Auto Move", _G.autoMove},
                {"Auto Jump", _G.autoJump},
                {"Anti Ragdoll", _G.antiRagdoll},
                {"Auto Collect Cube", _G.collectCubes},
                {"Auto Collect Candy", _G.collectCandy},
                {"Auto Spin", _G.autospin},
                {"Auto Rewards", _G.autoRewards}
            }
            
            for _, status in ipairs(farmingStatus) do
                local statusText = status[2] and "✓ ĐANG BẬT" or "✗ ĐANG TẮT"
                local color = status[2] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
                AddOutput("  " .. status[1] .. ": " .. statusText, color)
            end
            
            -- Shop Toggle
            AddOutput("\n[SHOP TOGGLE]:", Color3.fromRGB(255, 200, 100))
            local shopStatus = {
                {"Auto Max Size", _G.autoBuyv1},
                {"Auto Walk Speed", _G.autoBuyv2},
                {"Auto Size Multiplier", _G.autoBuyv3},
                {"Auto Eat Speed", _G.autoBuyv4},
                {"Auto Low Gravity", _G.autoBuy1},
                {"Auto Money Rain", _G.autoBuy2},
                {"Auto Robot", _G.autoBuy3},
                {"Auto Nuke", _G.autoBuy4},
                {"Auto Skeletons", _G.autoBuy5},
                {"Auto Color Crate", _G.autoCrates1},
                {"Auto Standard Crate", _G.autoCrates2}
            }
            
            for _, status in ipairs(shopStatus) do
                local statusText = status[2] and "✓ ĐANG BẬT" or "✗ ĐANG TẮT"
                local color = status[2] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
                AddOutput("  " .. status[1] .. ": " .. statusText, color)
            end
            
            -- Delays
            AddOutput("\n[DELAYS]:", Color3.fromRGB(255, 200, 100))
            AddOutput("  Grab Delay: " .. _G.grabDelay .. "s")
            AddOutput("  Eat Delay: " .. _G.eatDelay .. "s")
            AddOutput("  Sell Delay: " .. _G.sellDelay .. "s")
            AddOutput("  Throw Delay: " .. _G.throwDelay .. "s")
            AddOutput("  TP Delay: " .. _G.tpDelay .. "s")
            
        -- Lệnh toggle
        elseif cmd == "toggle" then
            if #args < 1 then
                AddOutput("Sai cú pháp: /toggle [tên_tính_năng]", Color3.fromRGB(255, 100, 100))
                return
            end
            
            local feature = table.concat(args, " "):lower()
            local featureMap = {
                ["autograb"] = {"autoGrab", autoGrab, "Auto Grab"},
                ["autoeat"] = {"autoEat", autoEat, "Auto Eat"},
                ["autosell"] = {"autoSell", autoSell, "Auto Sell"},
                ["autothrow"] = {"autoThrow", autoThrow, "Auto Throw"},
                ["autotp"] = {"autotp", autotp, "Auto TP"},
                ["automove"] = {"autoMove", autoMove, "Auto Move"},
                ["autojump"] = {"autoJump", autoJump, "Auto Jump"},
                ["antiragdoll"] = {"antiRagdoll", antiRagdoll, "Anti Ragdoll"},
                ["collectcube"] = {"collectCubes", function() collectItems("Cube") end, "Collect Cube"},
                ["collectcandy"] = {"collectCandy", function() collectItems("Candy") end, "Collect Candy"},
                ["autospin"] = {"autospin", autospin, "Auto Spin"},
                ["autorewards"] = {"autoRewards", autoRewards, "Auto Rewards"}
            }
            
            if featureMap[feature] then
                local varName, func, displayName = unpack(featureMap[feature])
                _G[varName] = not _G[varName]
                
                if _G[varName] then
                    task.spawn(func)
                    AddOutput("✓ Đã bật " .. displayName, Color3.fromRGB(100, 255, 100))
                else
                    AddOutput("✗ Đã tắt " .. displayName, Color3.fromRGB(255, 100, 100))
                end
            else
                AddOutput("Không tìm thấy tính năng: " .. feature, Color3.fromRGB(255, 100, 100))
            end
            
        -- Lệnh start/stop
        elseif cmd == "start" or cmd == "stop" then
            if #args < 1 then
                AddOutput("Sai cú pháp: /" .. cmd .. " [tên_tính_năng]", Color3.fromRGB(255, 100, 100))
                return
            end
            
            local feature = table.concat(args, " "):lower()
            local featureMap = {
                ["autograb"] = {"autoGrab", autoGrab, "Auto Grab"},
                ["autoeat"] = {"autoEat", autoEat, "Auto Eat"},
                ["autosell"] = {"autoSell", autoSell, "Auto Sell"},
                ["autothrow"] = {"autoThrow", autoThrow, "Auto Throw"},
                ["autotp"] = {"autotp", autotp, "Auto TP"},
                ["automove"] = {"autoMove", autoMove, "Auto Move"},
                ["autojump"] = {"autoJump", autoJump, "Auto Jump"},
                ["antiragdoll"] = {"antiRagdoll", antiRagdoll, "Anti Ragdoll"},
                ["collectcube"] = {"collectCubes", function() collectItems("Cube") end, "Collect Cube"},
                ["collectcandy"] = {"collectCandy", function() collectItems("Candy") end, "Collect Candy"},
                ["autospin"] = {"autospin", autospin, "Auto Spin"},
                ["autorewards"] = {"autoRewards", autoRewards, "Auto Rewards"}
            }
            
            if featureMap[feature] then
                local varName, func, displayName = unpack(featureMap[feature])
                _G[varName] = (cmd == "start")
                
                if cmd == "start" then
                    task.spawn(func)
                    AddOutput("✓ Đã bật " .. displayName, Color3.fromRGB(100, 255, 100))
                else
                    AddOutput("✗ Đã tắt " .. displayName, Color3.fromRGB(255, 100, 100))
                end
            else
                AddOutput("Không tìm thấy tính năng: " .. feature, Color3.fromRGB(255, 100, 100))
            end
            
        -- Lệnh list
        elseif cmd == "list" then
            AddOutput("=== DANH SÁCH TÍNH NĂNG ===", Color3.fromRGB(100, 200, 255))
            AddOutput("autograb, autoeat, autosell, autothrow")
            AddOutput("autotp, automove, autojump, antiragdoll")
            AddOutput("collectcube, collectcandy, autospin, autorewards")
            
        -- Lệnh reload
        elseif cmd == "reload" then
            AddOutput("Đang tải lại config...", Color3.fromRGB(255, 200, 100))
            StartFromConfig()
            AddOutput("✓ Đã tải lại config thành công!", Color3.fromRGB(100, 255, 100))
            
        -- Lệnh clear
        elseif cmd == "clear" then
            ClearOutput()
            AddOutput("Console đã được xóa", Color3.fromRGB(100, 200, 255))
            
        -- Lệnh webhook
        elseif cmd == "webhook" then
            if #args < 1 then
                AddOutput("Webhook hiện tại: " .. (WebhookUrl ~= "" and WebhookUrl or "Chưa đặt"), Color3.fromRGB(255, 200, 100))
                return
            end
            
            WebhookUrl = args[1]
            AddOutput("✓ Đã đặt webhook URL: " .. WebhookUrl, Color3.fromRGB(100, 255, 100))
            
        -- Lệnh delay
        elseif cmd == "delay" then
            if #args < 2 then
                AddOutput("Sai cú pháp: /delay [tên] [giây]", Color3.fromRGB(255, 100, 100))
                AddOutput("Ví dụ: /delay grab 1.5", Color3.fromRGB(255, 100, 100))
                return
            end
            
            local delayType = args[1]:lower()
            local delayValue = tonumber(args[2])
            
            if not delayValue then
                AddOutput("Giá trị delay không hợp lệ!", Color3.fromRGB(255, 100, 100))
                return
            end
            
            local delayMap = {
                ["grab"] = {"grabDelay", "Grab Delay"},
                ["eat"] = {"eatDelay", "Eat Delay"},
                ["sell"] = {"sellDelay", "Sell Delay"},
                ["throw"] = {"throwDelay", "Throw Delay"},
                ["tp"] = {"tpDelay", "TP Delay"}
            }
            
            if delayMap[delayType] then
                local varName, displayName = unpack(delayMap[delayType])
                _G[varName] = delayValue
                AddOutput("✓ Đã đặt " .. displayName .. " thành " .. delayValue .. "s", Color3.fromRGB(100, 255, 100))
            else
                AddOutput("Loại delay không hợp lệ!", Color3.fromRGB(255, 100, 100))
            end
            
        -- Lệnh config
        elseif cmd == "config" then
            AddOutput("=== CONFIG HIỆN TẠI ===", Color3.fromRGB(100, 200, 255))
            for category, settings in pairs(getgenv().Config) do
                AddOutput("\n[" .. category .. "]:", Color3.fromRGB(255, 200, 100))
                for setting, value in pairs(settings) do
                    local valueText = ""
                    if type(value) == "boolean" then
                        valueText = value and "true" or "false"
                    else
                        valueText = tostring(value)
                    end
                    AddOutput("  " .. setting .. ": " .. valueText)
                end
            end
            
        -- Lệnh không tìm thấy
        else
            AddOutput("Lệnh không hợp lệ: " .. cmd, Color3.fromRGB(255, 100, 100))
            AddOutput("Gõ /help để xem danh sách lệnh", Color3.fromRGB(255, 200, 100))
        end
    end
    
    -- Function hiển thị trạng thái
    local function ShowStatus()
        ProcessCommand("status")
    end
    
    -- Kết nối sự kiện
    CloseButton.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end)
    
    SendButton.MouseButton1Click:Connect(function()
        local text = InputBox.Text
        if text ~= "" then
            AddOutput("> " .. text, Color3.fromRGB(200, 200, 255))
            ProcessCommand(text)
            InputBox.Text = ""
        end
    end)
    
    InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = InputBox.Text
            if text ~= "" then
                AddOutput("> " .. text, Color3.fromRGB(200, 200, 255))
                ProcessCommand(text)
                InputBox.Text = ""
            end
        end
    end)
    
    -- Cho phép kéo thả
    local dragging = false
    local dragStart, frameStart
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                frameStart.X.Scale, 
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Hotkey để toggle console (F9)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F9 then
            isVisible = not isVisible
            MainFrame.Visible = isVisible
        end
    end)
    
    -- Trả về các function public
    return {
        AddOutput = AddOutput,
        ClearOutput = ClearOutput,
        ShowStatus = ShowStatus,
        IsVisible = function() return isVisible end,
        SetVisible = function(visible) 
            isVisible = visible
            MainFrame.Visible = visible
        end
    }
end

-- Function để tích hợp với script chính
local function IntegrateConsole()
    local console = CreateConsoleGUI()
    
    -- Thêm thông báo khởi động
    console.AddOutput("=== VAMPIRE SPARKLE HUB ===", Color3.fromRGB(100, 200, 255))
    console.AddOutput("Script đã khởi động thành công!", Color3.fromRGB(100, 255, 100))
    console.AddOutput("Nhấn F9 để ẩn/hiện console", Color3.fromRGB(255, 200, 100))
    console.AddOutput("Gõ /help để xem danh sách lệnh", Color3.fromRGB(255, 200, 100))
    
    -- Thay thế các print bằng console output
    local oldPrint = print
    print = function(...)
        local args = {...}
        local message = ""
        for i, v in ipairs(args) do
            message = message .. tostring(v) .. (i < #args and " " or "")
        end
        console.AddOutput(message)
        oldPrint(...)
    end
    
    -- Log các sự kiện quan trọng
    local function LogFeatureToggle(feature, enabled)
        local status = enabled and "✓ BẬT" or "✗ TẮT"
        console.AddOutput(feature .. ": " .. status, 
            enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
    end
    
    -- Wrap các function để log
    local originalFunctions = {}
    
    local function WrapFunction(funcName, displayName)
        originalFunctions[funcName] = _G[funcName]
        
        _G[funcName] = function(value)
            local oldValue = _G[funcName]
            originalFunctions[funcName](value)
            
            if oldValue ~= value then
                LogFeatureToggle(displayName, value)
            end
        end
    end
    
    -- Bọc các toggle function
    local toggleMap = {
        autoGrab = "Auto Grab",
        autoEat = "Auto Eat",
        autoSell = "Auto Sell",
        autoThrow = "Auto Throw",
        autotp = "Auto TP",
        autoMove = "Auto Move",
        autoJump = "Auto Jump",
        antiRagdoll = "Anti Ragdoll"
    }
    
    for varName, displayName in pairs(toggleMap) do
        WrapFunction(varName, displayName)
    end
    
    return console
end

-- Trong phần khởi động chính của script, thêm:
local console = IntegrateConsole()

-- Thay thế các print thông báo bằng console
console.AddOutput("Đang khởi động Auto Farm...", Color3.fromRGB(255, 200, 100))

-- Bắt đầu từ config
StartFromConfig()

console.AddOutput("✓ Script đã sẵn sàng!", Color3.fromRGB(100, 255, 100))
console.AddOutput("Nhấn F9 để mở/đóng console", Color3.fromRGB(100, 200, 255))
