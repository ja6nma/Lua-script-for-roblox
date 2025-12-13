local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local UIS = game:GetService("UserInputService")

local Enabled = true
local JumpCooldown = false

local function PerformAirJump()
    if not Enabled or JumpCooldown then return end
    if Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then
        JumpCooldown = true
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.08)
        JumpCooldown = false
    end
end

UIS.JumpRequest:Connect(PerformAirJump)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Air Jump Loaded",
    Text = "Script activated. Press space in air.",
    Duration = 5
})

warn("Air Jump script executed successfully.")
warn("https://discord.gg/vSjXGEz24j - DeadTeam")
