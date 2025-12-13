local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP = {
    Enabled = true,
    TeamCheck = false,
    VisibleOnly = true,
    MaxDistance = 1000,
    
    Box = {
        Enabled = true,
        Color = Color3.fromRGB(255, 50, 50),
        Thickness = 2,
        Filled = false
    },
    
    Tracer = {
        Enabled = true,
        Color = Color3.fromRGB(50, 255, 50),
        Thickness = 2,
        Origin = "Bottom"
    },
    
    Name = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 16,
        ShowDistance = true,
        ShowHealth = true
    },
    
    HealthBar = {
        Enabled = true,
        Width = 2,
        ColorFrom = Color3.fromRGB(255, 0, 0),
        ColorTo = Color3.fromRGB(0, 255, 0)
    },
    
    Weapon = {
        Enabled = true,
        Color = Color3.fromRGB(200, 200, 200),
        Size = 14
    }
}

local Settings = {
    ToggleKey = "p",
    RefreshRate = 0.016
}

local ESPObjects = {}
local LastUpdate = tick()

local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end

local function CreateESP(Player)
    local Drawings = {}
    
    Drawings.Box = CreateDrawing("Square", {
        Visible = false,
        Color = ESP.Box.Color,
        Thickness = ESP.Box.Thickness,
        Filled = ESP.Box.Filled
    })
    
    Drawings.Tracer = CreateDrawing("Line", {
        Visible = false,
        Color = ESP.Tracer.Color,
        Thickness = ESP.Tracer.Thickness
    })
    
    Drawings.Name = CreateDrawing("Text", {
        Visible = false,
        Color = ESP.Name.Color,
        Size = ESP.Name.Size,
        Center = true,
        Outline = true
    })
    
    Drawings.HealthBarOutline = CreateDrawing("Square", {
        Visible = false,
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
        Filled = true
    })
    
    Drawings.HealthBar = CreateDrawing("Square", {
        Visible = false,
        Color = ESP.HealthBar.ColorTo,
        Thickness = 1,
        Filled = true
    })
    
    Drawings.Weapon = CreateDrawing("Text", {
        Visible = false,
        Color = ESP.Weapon.Color,
        Size = ESP.Weapon.Size,
        Center = true,
        Outline = true
    })
    
    ESPObjects[Player] = Drawings
end

local function CalculateTracerOrigin()
    local screenSize = Camera.ViewportSize
    if ESP.Tracer.Origin == "Bottom" then
        return Vector2.new(screenSize.X / 2, screenSize.Y)
    elseif ESP.Tracer.Origin == "Middle" then
        return Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    else
        return Vector2.new(screenSize.X / 2, 0)
    end
end

local function GetPlayerWeapon(Character)
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") or tool:IsA("HopperBin") then
            return tool.Name
        end
    end
    return "None"
end

local function UpdatePlayerESP(Player, Drawings)
    if not Player.Character then return end
    
    local Humanoid = Player.Character:FindFirstChild("Humanoid")
    local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end
    
    if ESP.TeamCheck and Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then
        for _, drawing in pairs(Drawings) do
            drawing.Visible = false
        end
        return
    end
    
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
        and (RootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude 
        or 0
    
    if distance > ESP.MaxDistance then
        for _, drawing in pairs(Drawings) do
            drawing.Visible = false
        end
        return
    end
    
    if ESP.VisibleOnly then
        local rayOrigin = Camera.CFrame.Position
        local rayDirection = (RootPart.Position - rayOrigin).Unit * distance
        local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
        
        if raycastResult then
            local hitPart = raycastResult.Instance
            if hitPart and not hitPart:IsDescendantOf(Player.Character) then
                for _, drawing in pairs(Drawings) do
                    drawing.Visible = false
                end
                return
            end
        end
    end
    
    local pos, onScreen = Camera:WorldToViewportPoint(RootPart.Position)
    if not onScreen then
        for _, drawing in pairs(Drawings) do
            drawing.Visible = false
        end
        return
    end
    
    local boxSize = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
    local boxPos = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
    
    if ESP.Box.Enabled then
        Drawings.Box.Size = boxSize
        Drawings.Box.Position = boxPos
        Drawings.Box.Visible = true
    else
        Drawings.Box.Visible = false
    end
    
    if ESP.Tracer.Enabled then
        Drawings.Tracer.From = CalculateTracerOrigin()
        Drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
        Drawings.Tracer.Visible = true
    else
        Drawings.Tracer.Visible = false
    end
    
    if ESP.HealthBar.Enabled then
        local health = Humanoid.Health / Humanoid.MaxHealth
        local healthBarHeight = boxSize.Y * math.clamp(health, 0, 1)
        
        Drawings.HealthBarOutline.Size = Vector2.new(ESP.HealthBar.Width, boxSize.Y + 2)
        Drawings.HealthBarOutline.Position = Vector2.new(boxPos.X - ESP.HealthBar.Width - 2, boxPos.Y - 1)
        Drawings.HealthBarOutline.Visible = true
        
        Drawings.HealthBar.Size = Vector2.new(ESP.HealthBar.Width, healthBarHeight)
        Drawings.HealthBar.Position = Vector2.new(
            boxPos.X - ESP.HealthBar.Width - 2, 
            boxPos.Y + boxSize.Y - healthBarHeight
        )
        Drawings.HealthBar.Color = ESP.HealthBar.ColorFrom:Lerp(ESP.HealthBar.ColorTo, health)
        Drawings.HealthBar.Visible = true
    else
        Drawings.HealthBarOutline.Visible = false
        Drawings.HealthBar.Visible = false
    end
    
    if ESP.Name.Enabled then
        local infoText = Player.Name
        if ESP.Name.ShowDistance then
            infoText = infoText .. string.format(" [%dm]", math.floor(distance))
        end
        if ESP.Name.ShowHealth then
            infoText = infoText .. string.format(" [%.0fHP]", Humanoid.Health)
        end
        
        Drawings.Name.Text = infoText
        Drawings.Name.Position = Vector2.new(pos.X, boxPos.Y - 20)
        Drawings.Name.Visible = true
    else
        Drawings.Name.Visible = false
    end
    
    if ESP.Weapon.Enabled then
        local weaponName = GetPlayerWeapon(Player.Character)
        Drawings.Weapon.Text = weaponName
        Drawings.Weapon.Position = Vector2.new(pos.X, boxPos.Y + boxSize.Y + 5)
        Drawings.Weapon.Visible = true
    else
        Drawings.Weapon.Visible = false
    end
end

local function UpdateAllESP()
    if not ESP.Enabled then
        for _, Drawings in pairs(ESPObjects) do
            for _, drawing in pairs(Drawings) do
                drawing.Visible = false
            end
        end
        return
    end
    
    for Player, Drawings in pairs(ESPObjects) do
        if Player and Player.Parent then
            UpdatePlayerESP(Player, Drawings)
        else
            for _, drawing in pairs(Drawings) do
                drawing.Visible = false
            end
        end
    end
end

for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    CreateESP(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    if ESPObjects[Player] then
        for _, drawing in pairs(ESPObjects[Player]) do
            drawing:Remove()
        end
        ESPObjects[Player] = nil
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[Settings.ToggleKey:upper()] then
        ESP.Enabled = not ESP.Enabled
        warn("ESP " .. (ESP.Enabled and "Enabled" or "Disabled"))
    end
end)

RunService.RenderStepped:Connect(function()
    if tick() - LastUpdate >= Settings.RefreshRate then
        UpdateAllESP()
        LastUpdate = tick()
    end
end)


warn("Advanced ESP loaded. Press " .. Settings.ToggleKey:upper() .. " to toggle.")
warn("https://discord.gg/vSjXGEz24j - DeadTeam")
