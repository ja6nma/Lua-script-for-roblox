--Local -_-
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local RAINBOW_COLORS = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211)
}

local SHAPES = {"Ball", "Block", "Cylinder"}
local activeEffects = {}
local playerEffects = {}
local isRunning = true


local function createRemoteEvents()
    local remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "SalineWinRemotes"
    remotesFolder.Parent = ReplicatedStorage
    
    local events = {
        PlayerEffect = Instance.new("RemoteEvent"),
        GlobalEffect = Instance.new("RemoteEvent"),
        ChatMessage = Instance.new("RemoteEvent")
    }
    
    for name, event in pairs(events) do
        event.Name = "SalineWin_" .. name
        event.Parent = remotesFolder
    end
    
    return events
end

local remotes = createRemoteEvents()


local function sendGlobalMessage(message)
    remotes.ChatMessage:FireAllClients(message)
end


local function rainbowEffect()
    while isRunning do
        for _, color in ipairs(RAINBOW_COLORS) do
            if not isRunning then break end
            Lighting.Ambient = color
            Lighting.OutdoorAmbient = color
            remotes.GlobalEffect:FireAllClients("Rainbow", color)
            wait(1)
        end
    end
end


local function fallingObjectsEffect()
    while isRunning do
        if not isRunning then break end
        
        for i = 1, 5 do 
            local shape = SHAPES[math.random(1, #SHAPES)]
            local part = Instance.new("Part")
            part.Shape = Enum.PartType[shape]
            part.Size = Vector3.new(math.random(2, 5), math.random(2, 5), math.random(2, 5))
            part.Anchored = false
            part.CanCollide = true
            part.Material = Enum.Material.Neon
            part.Color = RAINBOW_COLORS[math.random(1, #RAINBOW_COLORS)]
            part.Position = Vector3.new(math.random(-50, 50), 150, math.random(-50, 50))
            part.Parent = workspace
            game:GetService("Debris"):AddItem(part, 20)
        end
        
        wait(0.5)
    end
end


local function applyHighlightToPlayer(player)
    if playerEffects[player] and playerEffects[player].highlight then
        playerEffects[player].highlight:Destroy()
    end
    
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "SalineWinHighlight"
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = RAINBOW_COLORS[math.random(1, #RAINBOW_COLORS)]
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Parent = player.Character
        
        if not playerEffects[player] then playerEffects[player] = {} end
        playerEffects[player].highlight = highlight
        

        coroutine.wrap(function()
            while highlight and highlight.Parent and isRunning do
                for _, color in ipairs(RAINBOW_COLORS) do
                    if not isRunning or not highlight.Parent then break end
                    highlight.FillColor = color
                    wait(0.8)
                end
            end
        end)()
    end
end


local function freezeAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                
                if not playerEffects[player] then playerEffects[player] = {} end
                playerEffects[player].walkSpeed = humanoid.WalkSpeed
                playerEffects[player].jumpPower = humanoid.JumpPower
            end
        end
    end
end


local function teleportAllPlayers()
    while isRunning do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                rootPart.CFrame = CFrame.new(
                    math.random(-40, 40),
                    math.random(10, 30),
                    math.random(-40, 40)
                )
            end
        end
        wait(4)
    end
end


local function musicEffect()
    while isRunning do
        if not activeEffects.music then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://105674377375870"
            sound.Looped = true
            sound.Volume = 0.7
            sound.Parent = SoundService
            sound:Play()
            activeEffects.music = sound
            remotes.GlobalEffect:FireAllClients("Music", true)
        end
        wait(10)
    end
end


local function handleNewPlayers()
    Players.PlayerAdded:Connect(function(player)
        if isRunning then
            wait(2)
            applyHighlightToPlayer(player)
            freezeAllPlayers() 
        end
        
        player.CharacterAdded:Connect(function()
            if isRunning then
                wait(1)
                applyHighlightToPlayer(player)
                freezeAllPlayers()
            end
        end)
    end)
end


local function handlePlayerRemoving()
    Players.PlayerRemoving:Connect(function(player)
        if playerEffects[player] then
            if playerEffects[player].highlight then
                playerEffects[player].highlight:Destroy()
            end
            playerEffects[player] = nil
        end
    end)
end


local function startGlobalSalineWin()
    print("⚠️SalineWin.lua⚠️")
    sendGlobalMessage("⚠️SalineWin.lua⚠️")
    
    isRunning = true
    

    activeEffects.rainbowThread = coroutine.create(rainbowEffect)
    coroutine.resume(activeEffects.rainbowThread)
    
    activeEffects.fallingThread = coroutine.create(fallingObjectsEffect)
    coroutine.resume(activeEffects.fallingThread)
    
    activeEffects.musicThread = coroutine.create(musicEffect)
    coroutine.resume(activeEffects.musicThread)
    
    activeEffects.teleportThread = coroutine.create(teleportAllPlayers)
    coroutine.resume(activeEffects.teleportThread)
    

    for _, player in pairs(Players:GetPlayers()) do
        applyHighlightToPlayer(player)
    end
    
    freezeAllPlayers()
    

    handleNewPlayers()
    handlePlayerRemoving()
    

    while isRunning do

        wait(30)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and not player.Character:FindFirstChild("SalineWinHighlight") then
                applyHighlightToPlayer(player)
            end
        end
        freezeAllPlayers() 
        sendGlobalMessage("SalineWin.lua")
    end
end


local function createClientScript()
    local script = [[
        local Players = game:GetService("Players")
        local Lighting = game:GetService("Lighting")
        local SoundService = game:GetService("SoundService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local TextChatService = game:GetService("TextChatService")
        
        local remotesFolder = ReplicatedStorage:WaitForChild("SalineWinRemotes")
        local chatRemote = remotesFolder:WaitForChild("SalineWin_ChatMessage")
        local globalRemote = remotesFolder:WaitForChild("SalineWin_GlobalEffect")
        

        chatRemote.OnClientEvent:Connect(function(message)
            TextChatService.TextChannels.RBXGeneral:SendAsync(message)
        end)
        

        globalRemote.OnClientEvent:Connect(function(effectType, value)
            if effectType == "Rainbow" then
                Lighting.Ambient = value
                Lighting.OutdoorAmbient = value
            elseif effectType == "Music" then

            end
        end)
        
        print("SalineWin.lua")
    ]]
    
    for _, player in pairs(Players:GetPlayers()) do
        local clientScript = Instance.new("LocalScript")
        clientScript.Name = "SalineWinClient"
        clientScript.Source = script
        clientScript.Parent = player:WaitForChild("PlayerScripts")
    end
end


createClientScript()
startGlobalSalineWin()


while true do
    wait(100)
    print("SalineWin.lua...")
end