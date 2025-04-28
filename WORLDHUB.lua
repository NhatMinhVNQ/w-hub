local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
local Button = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
local CloseCorner = Instance.new("UICorner")

ScreenGui.Parent = CoreGui
ScreenGui.Name = "ScriptStoppedGUI"

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 400, 0, 220)
Frame.Position = UDim2.new(0.5, -200, 0.5, -500)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0

UICorner.Parent = Frame
UICorner.CornerRadius = UDim.new(0, 10)

TextLabel.Parent = Frame
TextLabel.Size = UDim2.new(1, -20, 0.6, -20)
TextLabel.Position = UDim2.new(0, 10, 0, 10)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "This Script Has Stopped Working,\nGo to Discord to Get a New Script"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.Font = Enum.Font.FredokaOne
TextLabel.TextWrapped = true

Button.Parent = Frame
Button.Size = UDim2.new(0.6, 0, 0.2, 0)
Button.Position = UDim2.new(0.2, 0, 0.65, 0)
Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Button.Text = "Join Discord"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextScaled = true
Button.Font = Enum.Font.FredokaOne
Button.BorderSizePixel = 0

ButtonCorner.Parent = Button
ButtonCorner.CornerRadius = UDim.new(0, 8)

CloseButton.Parent = Frame
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.FredokaOne
CloseButton.BorderSizePixel = 0

CloseCorner.Parent = CloseButton
CloseCorner.CornerRadius = UDim.new(1, 0)

local function hoverEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(0, 140, 220)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
    end)
end

hoverEffect(Button)

local function hoverCloseEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
end

hoverCloseEffect(CloseButton)

TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -200, 0.5, -110)
}):Play()

Button.MouseButton1Click:Connect(function()

    local sizeUp = TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.65, 0, 0.22, 0)
    })
    local sizeDown = TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0.6, 0, 0.2, 0)
    })
    
    sizeUp:Play()
    sizeUp.Completed:Wait()
    sizeDown:Play()
    
    setclipboard("https://discord.gg/3W2p7zsKZS")
end)

CloseButton.MouseButton1Click:Connect(function()
    local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -200, 0.5, -500)
    })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    ScreenGui:Destroy()
end)
