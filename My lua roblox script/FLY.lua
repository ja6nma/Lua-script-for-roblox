local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local FLY_SPEED = 50
local flyEnabled = false
local bodyGyro
local bodyVelocity
local connection

local function startFly()
    flyEnabled = true
    

    humanoid.PlatformStand = true
    

    bodyGyro = Instance.new("BodyGyro")
    bodyVelocity = Instance.new("BodyVelocity")
    
    bodyGyro.P = 10000
    bodyGyro.D = 500
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
    
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root
    

    connection = RunService.Stepped:Connect(function()
        if not flyEnabled or not root or not bodyVelocity then
            return
        end
        
        local direction = Vector3.new(0, 0, 0)

      
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + (root.CFrame.LookVector * FLY_SPEED)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - (root.CFrame.LookVector * FLY_SPEED)
        end
        

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - (root.CFrame.RightVector * FLY_SPEED)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + (root.CFrame.RightVector * FLY_SPEED)
        end
        

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + (Vector3.new(0, 1, 0) * FLY_SPEED)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - (Vector3.new(0, 1, 0) * FLY_SPEED)
        end
        

        bodyVelocity.Velocity = direction
        

        if bodyGyro then
            bodyGyro.CFrame = CFrame.new(root.Position, root.Position + root.CFrame.LookVector)
        end
    end)
    
    print("Fly: ENABLED | Controls: W/A/S/D, Space=Up, Shift=Down")
end

local function stopFly()
    flyEnabled = false
    
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    humanoid.PlatformStand = false
    
    print("Fly: DISABLED")
end

local function toggleFly()
    if flyEnabled then
        stopFly()
    else
        startFly()
    end
end


UserInputService.InputBegan:Connect(function(input, isTyping)
    if not isTyping and input.KeyCode == Enum.KeyCode.E then
        toggleFly()
    end
end)


player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
    
    if flyEnabled then
        stopFly()
        wait(0.5)
        startFly()
    end
end)

print("Fly script loaded! Press E to toggle flight")
print("https://discord.gg/5MAdkQCXde - DeadTeam")
