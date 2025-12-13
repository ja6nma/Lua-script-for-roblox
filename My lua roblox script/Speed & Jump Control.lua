local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlMenu_Fixed"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 200)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Speed/Jump Control"
title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = mainFrame

local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(1, -20, 0, 20)
speedText.Position = UDim2.new(0, 10, 0, 40)
speedText.Text = "WalkSpeed (Current: " .. humanoid.WalkSpeed .. ")"
speedText.BackgroundTransparency = 1
speedText.TextColor3 = Color3.fromRGB(180, 180, 255)
speedText.TextXAlignment = Enum.TextXAlignment.Left
speedText.Parent = mainFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.6, 0, 0, 25)
speedBox.Position = UDim2.new(0, 10, 0, 65)
speedBox.PlaceholderText = "Enter number (16-500)"
speedBox.Text = tostring(humanoid.WalkSpeed)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Parent = mainFrame

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.35, -10, 0, 25)
speedButton.Position = UDim2.new(0.65, 5, 0, 65)
speedButton.Text = "APPLY"
speedButton.BackgroundColor3 = Color3.fromRGB(80, 120, 80)
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Parent = mainFrame

local jumpText = Instance.new("TextLabel")
jumpText.Size = UDim2.new(1, -20, 0, 20)
jumpText.Position = UDim2.new(0, 10, 0, 100)
jumpText.Text = "JumpPower (Current: " .. humanoid.JumpPower .. ")"
jumpText.BackgroundTransparency = 1
jumpText.TextColor3 = Color3.fromRGB(255, 180, 180)
jumpText.TextXAlignment = Enum.TextXAlignment.Left
jumpText.Parent = mainFrame

local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(0.6, 0, 0, 25)
jumpBox.Position = UDim2.new(0, 10, 0, 125)
jumpBox.PlaceholderText = "Enter number (50-1000)"
jumpBox.Text = tostring(humanoid.JumpPower)
jumpBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBox.Parent = mainFrame

local jumpButton = Instance.new("TextButton")
jumpButton.Size = UDim2.new(0.35, -10, 0, 25)
jumpButton.Position = UDim2.new(0.65, 5, 0, 125)
jumpButton.Text = "APPLY"
jumpButton.BackgroundColor3 = Color3.fromRGB(120, 80, 80)
jumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpButton.Parent = mainFrame

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(1, -20, 0, 25)
resetButton.Position = UDim2.new(0, 10, 0, 165)
resetButton.Text = "RESET TO DEFAULT"
resetButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Parent = mainFrame

speedButton.MouseButton1Click:Connect(function()
    local num = tonumber(speedBox.Text)
    if num and num >= 16 and num <= 500 then
        humanoid.WalkSpeed = num
        speedText.Text = "WalkSpeed (Current: " .. num .. ")"
    else
        speedBox.Text = "Invalid"
    end
end)

jumpButton.MouseButton1Click:Connect(function()
    local num = tonumber(jumpBox.Text)
    if num and num >= 50 and num <= 1000 then
        humanoid.JumpPower = num
        jumpText.Text = "JumpPower (Current: " .. num .. ")"
    else
        jumpBox.Text = "Invalid"
    end
end)

resetButton.MouseButton1Click:Connect(function()
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    speedBox.Text = "16"
    jumpBox.Text = "50"
    speedText.Text = "WalkSpeed (Current: 16)"
    jumpText.Text = "JumpPower (Current: 50)"
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    speedBox.Text = tostring(humanoid.WalkSpeed)
    jumpBox.Text = tostring(humanoid.JumpPower)
    speedText.Text = "WalkSpeed (Current: " .. humanoid.WalkSpeed .. ")"
    jumpText.Text = "JumpPower (Current: " .. humanoid.JumpPower .. ")"
    warn("https://discord.gg/vSjXGEz24j - DeadTeam")
end)
