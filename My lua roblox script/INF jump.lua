local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAddedWait()
local Humanoid = CharacterWaitForChild(Humanoid)
local UIS = gameGetService(UserInputService)

local Enabled = true
local JumpCooldown = false

local function PerformAirJump()
    if not Enabled or JumpCooldown then return end
    if Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then
        JumpCooldown = true
        HumanoidChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.08)
        JumpCooldown = false
    end
end

UIS.JumpRequestConnect(PerformAirJump)

game.StarterGuiSetCore(SendNotification, {
    Title = Air Jump Loaded,
    Text = Script activated. Press space in air.,
    Duration = 5
})

warn(Air Jump script executed successfully.)