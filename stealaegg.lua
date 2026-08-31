-- 🐔 Steal an Egg Menu - Roblox Exploit
-- Script feito para rodar com loadstring
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/thallesfreefire61-bot/steal-egg-menu/main/stealaegg.lua"))()

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações
local Config = {
    speedEnabled = false,
    speedValue = 500,
    flyEnabled = false,
    theme = "dark",
    opacity = 0.95,
    menuVisible = true,
    currentTab = "main"
}

-- Cores dos temas
local Themes = {
    dark = {
        bg = Color3.fromRGB(25, 25, 25),
        header = Color3.fromRGB(25, 25, 25),
        content = Color3.fromRGB(35, 35, 35),
        sidebar = Color3.fromRGB(30, 30, 30),
        button = Color3.fromRGB(45, 45, 45),
        buttonActive = Color3.fromRGB(60, 60, 60),
        text = Color3.fromRGB(255, 255, 255),
        accent = Color3.fromRGB(0, 200, 100),
        title = Color3.fromRGB(255, 200, 0)
    },
    light = {
        bg = Color3.fromRGB(245, 245, 245),
        header = Color3.fromRGB(240, 240, 240),
        content = Color3.fromRGB(250, 250, 250),
        sidebar = Color3.fromRGB(235, 235, 235),
        button = Color3.fromRGB(220, 220, 220),
        buttonActive = Color3.fromRGB(150, 150, 255),
        text = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(0, 150, 255),
        title = Color3.fromRGB(0, 100, 200)
    },
    neon = {
        bg = Color3.fromRGB(10, 14, 39),
        header = Color3.fromRGB(10, 14, 39),
        content = Color3.fromRGB(15, 20, 50),
        sidebar = Color3.fromRGB(12, 16, 45),
        button = Color3.fromRGB(20, 25, 60),
        buttonActive = Color3.fromRGB(255, 0, 255),
        text = Color3.fromRGB(0, 255, 0),
        accent = Color3.fromRGB(255, 0, 255),
        title = Color3.fromRGB(0, 255, 255)
    }
}

local currentTheme = Themes[Config.theme]

-- Variáveis do Fly
local flying = false
local bodyVelocity = nil
local bodyGyro = nil

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggMenu"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ==================== CRIAR ELEMENTOS ====================

local function createFrame(parent, name, size, position, bgColor)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = bgColor
    frame.BorderSizePixel = 0
    frame.Parent = parent
    return frame
end

local function createButton(parent, name, size, position, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = currentTheme.button
    button.TextColor3 = currentTheme.text
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

local function createLabel(parent, name, size, position, text, textSize)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = currentTheme.text
    label.Font = Enum.Font.Gotham
    label.TextSize = textSize or 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createToggle(parent, name, position, label, callback)
    local toggleContainer = createFrame(parent, name, UDim2.new(1, -20, 0, 50), position, currentTheme.button)
    
    -- Label
    local labelObj = createLabel(toggleContainer, "Label", UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 10, 0, 0), label, 16)
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 40, 0, 25)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = toggleContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = toggleBtn
    
    local isEnabled = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggleBtn.BackgroundColor3 = isEnabled and currentTheme.accent or Color3.fromRGB(100, 100, 100)
        if callback then
            callback(isEnabled)
        end
    end)
    
    return toggleContainer, toggleBtn, function() return isEnabled end
end

-- ==================== FLY SYSTEM ====================

local function startFlying()
    if flying then return end
    flying = true
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Criar BodyVelocity
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = rootPart
    
    -- Criar BodyGyro
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not flying or not bodyVelocity or bodyVelocity.Parent == nil then
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            flying = false
            connection:Disconnect()
            return
        end
        
        local speed = Config.speedValue / 50
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + rootPart.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - rootPart.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - rootPart.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + rootPart.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        
        bodyVelocity.Velocity = moveDirection * speed
        bodyGyro.CFrame = rootPart.CFrame
    end)
end

local function stopFlying()
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

-- ==================== CRIAR MENU ====================

-- Header
local headerFrame = createFrame(screenGui, "Header", UDim2.new(0, 300, 0, 60), UDim2.new(0, 10, 0, 10), currentTheme.header)

local titleLabel = createLabel(headerFrame, "Title", UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 10, 0, 15), "🐔 Steal an Egg", 18)
titleLabel.TextColor3 = currentTheme.title
titleLabel.TextScaled = false

local hideBtn = createButton(headerFrame, "HideBtn", UDim2.new(0, 40, 0, 40), UDim2.new(1, -90, 0, 10), "▼", function()
    Config.menuVisible = not Config.menuVisible
    screenGui.Enabled = Config.menuVisible
end)

local closeBtn = createButton(headerFrame, "CloseBtn", UDim2.new(0, 40, 0, 40), UDim2.new(1, -45, 0, 10), "✕", function()
    screenGui:Destroy()
end)

-- Abas Sidebar
local tabsFrame = createFrame(screenGui, "Tabs", UDim2.new(0, 80, 0, 200), UDim2.new(0, 10, 0, 75), currentTheme.sidebar)

local mainTabBtn = createButton(tabsFrame, "MainTab", UDim2.new(1, -10, 0, 90), UDim2.new(0, 5, 0, 5), "⚙️\nPrincipal", function()
    Config.currentTab = "main"
    mainTabBtn.BackgroundColor3 = currentTheme.buttonActive
    settingsTabBtn.BackgroundColor3 = currentTheme.button
    mainPanel.Visible = true
    settingsPanel.Visible = false
end)

local settingsTabBtn = createButton(tabsFrame, "SettingsTab", UDim2.new(1, -10, 0, 90), UDim2.new(0, 5, 0, 100), "🔧\nConfig", function()
    Config.currentTab = "settings"
    mainTabBtn.BackgroundColor3 = currentTheme.button
    settingsTabBtn.BackgroundColor3 = currentTheme.buttonActive
    mainPanel.Visible = false
    settingsPanel.Visible = true
end)

-- Painel Principal
local mainPanel = createFrame(screenGui, "MainPanel", UDim2.new(0, 250, 0, 200), UDim2.new(0, 95, 0, 75), currentTheme.content)

local speedLabel = createLabel(mainPanel, "SpeedLabel", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 10), "⚡ Speed", 14)
speedLabel.TextColor3 = currentTheme.accent

local speedToggleContainer, speedToggleBtn, getSpeedEnabled = createToggle(mainPanel, "SpeedToggle", UDim2.new(0, 10, 0, 35), "⚡ Speed", function(enabled)
    Config.speedEnabled = enabled
    print("⚡ Speed " .. (enabled and "ativado!" or "desativado!"))
end)

local speedValueLabel = createLabel(mainPanel, "SpeedValue", UDim2.new(1, -20, 0, 15), UDim2.new(0, 10, 0, 90), "Velocidade: 500", 12)

local speedSlider = Instance.new("TextButton")
speedSlider.Name = "SpeedSlider"
speedSlider.Size = UDim2.new(1, -20, 0, 10)
speedSlider.Position = UDim2.new(0, 10, 0, 110)
speedSlider.BackgroundColor3 = currentTheme.button
speedSlider.BorderSizePixel = 0
speedSlider.Text = ""
speedSlider.Parent = mainPanel

local speedFill = Instance.new("Frame")
speedFill.Name = "Fill"
speedFill.Size = UDim2.new((500 - 100) / 900, 0, 1, 0)
speedFill.BackgroundColor3 = currentTheme.accent
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSlider

local sliderDragging = false
speedSlider.MouseButton1Down:Connect(function()
    sliderDragging = true
end)

mouse.Move:Connect(function()
    if sliderDragging then
        local sliderPos = speedSlider.AbsolutePosition.X
        local sliderSize = speedSlider.AbsoluteSize.X
        local mousePos = mouse.X
        local percent = math.max(0, math.min(1, (mousePos - sliderPos) / sliderSize))
        local value = math.floor(100 + (percent * 900))
        
        speedFill.Size = UDim2.new(percent, 0, 1, 0)
        speedValueLabel.Text = "Velocidade: " .. value
        Config.speedValue = value
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

local flyLabel = createLabel(mainPanel, "FlyLabel", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 130), "✈️ Fly (Voar)", 14)
flyLabel.TextColor3 = currentTheme.accent

local flyToggleContainer, flyToggleBtn, getFlyEnabled = createToggle(mainPanel, "FlyToggle", UDim2.new(0, 10, 0, 155), "✈️ Fly", function(enabled)
    Config.flyEnabled = enabled
    if enabled then
        startFlying()
        print("✈️ Fly ativado! Use W/A/S/D para mover, ESPAÇO para subir, CTRL para descer")
    else
        stopFlying()
        print("✈️ Fly desativado!")
    end
end)

-- Painel Configurações
local settingsPanel = createFrame(screenGui, "SettingsPanel", UDim2.new(0, 250, 0, 200), UDim2.new(0, 95, 0, 75), currentTheme.content)
settingsPanel.Visible = false

local themeLabel = createLabel(settingsPanel, "ThemeLabel", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 10), "🎨 Tema:", 14)
themeLabel.TextColor3 = currentTheme.accent

local darkThemeBtn = createButton(settingsPanel, "DarkBtn", UDim2.new(0.3, -5, 0, 30), UDim2.new(0, 10, 0, 35), "Escuro", function()
    Config.theme = "dark"
    print("🎨 Tema alterado para: Escuro")
end)

local lightThemeBtn = createButton(settingsPanel, "LightBtn", UDim2.new(0.3, -5, 0, 30), UDim2.new(0.35, -2, 0, 35), "Claro", function()
    Config.theme = "light"
    print("🎨 Tema alterado para: Claro")
end)

local neonThemeBtn = createButton(settingsPanel, "NeonBtn", UDim2.new(0.3, -5, 0, 30), UDim2.new(0.7, 0, 0, 35), "Neon", function()
    Config.theme = "neon"
    print("🎨 Tema alterado para: Neon")
end)

local opacityLabel = createLabel(settingsPanel, "OpacityLabel", UDim2.new(1, -20, 0, 15), UDim2.new(0, 10, 0, 75), "Opacidade: 95%", 12)

local opacitySlider = Instance.new("TextButton")
opacitySlider.Name = "OpacitySlider"
opacitySlider.Size = UDim2.new(1, -20, 0, 10)
opacitySlider.Position = UDim2.new(0, 10, 0, 95)
opacitySlider.BackgroundColor3 = currentTheme.button
opacitySlider.BorderSizePixel = 0
opacitySlider.Text = ""
opacitySlider.Parent = settingsPanel

local opacityFill = Instance.new("Frame")
opacityFill.Name = "Fill"
opacityFill.Size = UDim2.new(0.95, 0, 1, 0)
opacityFill.BackgroundColor3 = currentTheme.accent
opacityFill.BorderSizePixel = 0
opacityFill.Parent = opacitySlider

local opacityDragging = false
opacitySlider.MouseButton1Down:Connect(function()
    opacityDragging = true
end)

mouse.Move:Connect(function()
    if opacityDragging then
        local sliderPos = opacitySlider.AbsolutePosition.X
        local sliderSize = opacitySlider.AbsoluteSize.X
        local mousePos = mouse.X
        local percent = math.max(0.3, math.min(1, (mousePos - sliderPos) / sliderSize))
        
        opacityFill.Size = UDim2.new(percent, 0, 1, 0)
        opacityLabel.Text = "Opacidade: " .. math.floor(percent * 100) .. "%"
        Config.opacity = percent
        screenGui.BackgroundTransparency = 1 - Config.opacity
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        opacityDragging = false
    end
end)

local saveBtn = createButton(settingsPanel, "SaveBtn", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 150), "💾 Salvar", function()
    print("✅ Configurações salvas!")
    print("Speed: " .. Config.speedValue)
    print("Fly: " .. tostring(Config.flyEnabled))
    print("Speed Enabled: " .. tostring(Config.speedEnabled))
    print("Tema: " .. Config.theme)
    print("Opacidade: " .. math.floor(Config.opacity * 100) .. "%")
end)

-- ==================== INICIALIZAR ====================

print("🐔 Menu Steal an Egg carregado com sucesso!")
print("Use W, A, S, D para voar (quando ativo)")
print("ESPAÇO para subir, CTRL para descer")
