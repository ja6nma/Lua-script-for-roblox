local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local noclipEnabled = false
local connection

local function noclip()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide == true then
            part.CanCollide = false
        end
    end
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled

    if noclipEnabled then

        humanoid:ChangeState(11) 
        connection = RunService.Stepped:Connect(noclip)
        print("Noclip: ON")
    else

        if connection then
            connection:Disconnect()
            connection = nil
        end

        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        print("Noclip: OFF")
    end
end


local input = game:GetService("UserInputService")
input.InputBegan:Connect(function(key, isTyping)
    if not isTyping and key.KeyCode == Enum.KeyCode.F then
        toggleNoclip()
    end
end)


player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    if noclipEnabled and connection then
        connection:Disconnect()
        connection = RunService.Stepped:Connect(noclip)
    end
end)

warn("https://discord.gg/5MAdkQCXde - DeadTeam")
