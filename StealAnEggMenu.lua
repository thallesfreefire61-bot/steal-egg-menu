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
    opacity = 0.95
}

-- Variáveis do menu
local menuVisible = true
local currentTab = "main"
local flying = false
local bodyVelocity

-- Criar ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Função para criar frame com estilo
local function createStyledFrame(parent, name, size, position, bgColor, borderSize)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = bgColor
    frame.BorderSizePixel = borderSize or 0
    frame.Parent = parent
    return frame
end

-- Função para criar botão com estilo
local function createStyledButton(parent, name, size, position, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Parent = parent
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Função para criar toggle
local function createToggle(parent, labelText, position, callback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = labelText .. "Toggle"
    toggleContainer.Size = UDim2.new(1, -20, 0, 50)
    toggleContainer.Position = position
    toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toggleContainer.BorderSizePixel = 0
    toggleContainer.Parent = parent
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = labelText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleContainer
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 40, 0, 25)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = toggleContainer
    
    -- Criar corner arredondado
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = toggleBtn
    
    local isEnabled = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
        callback(isEnabled)
    end)
    
    return toggleContainer, toggleBtn, function() return isEnabled end
end

-- HEADER DO MENU
local headerFrame = createStyledFrame(screenGui, "Header", UDim2.new(0, 300, 0, 50), UDim2.new(0, 10, 0, 10), Color3.fromRGB(25, 25, 25), 0)

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "🐔 Steal an Egg"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerFrame

-- Botão Ocultar
local hideBtn = createStyledButton(headerFrame, "HideBtn", UDim2.new(0, 40, 0, 40), UDim2.new(1, -90, 0, 5), "▼", function()
    menuVisible = not menuVisible
    if not menuVisible then
        headerFrame:TweenPosition(UDim2.new(0, 10, 0, 10), "Out", "Quad", 0.3, true)
    else
        headerFrame:TweenPosition(UDim2.new(0, 10, 0, 10), "Out", "Quad", 0.3, true)
    end
end)

-- Botão Fechar
local closeBtn = createStyledButton(headerFrame, "CloseBtn", UDim2.new(0, 40, 0, 40), UDim2.new(1, -45, 0, 5), "✕", function()
    screenGui:Destroy()
end)

-- ABAS SIDEBAR
local tabsFrame = createStyledFrame(screenGui, "Tabs", UDim2.new(0, 80, 0, 150), UDim2.new(0, 10, 0, 65), Color3.fromRGB(30, 30, 30), 0)

local mainTabBtn = createStyledButton(tabsFrame, "MainTab", UDim2.new(1, -10, 0, 65), UDim2.new(0, 5, 0, 5), "⚙️\nPrincipal", function()
    currentTab = "main"
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    settingsTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainPanel.Visible = true
    settingsPanel.Visible = false
end)

local settingsTabBtn = createStyledButton(tabsFrame, "SettingsTab", UDim2.new(1, -10, 0, 75), UDim2.new(0, 5, 0, 75), "🔧\nConfig", function()
    currentTab = "settings"
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    settingsTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    mainPanel.Visible = false
    settingsPanel.Visible = true
end)

-- PAINEL PRINCIPAL
local mainPanel = createStyledFrame(screenGui, "MainPanel", UDim2.new(0, 250, 0, 250), UDim2.new(0, 95, 0, 65), Color3.fromRGB(35, 35, 35), 0)

-- Toggle Speed
local speedToggleContainer, speedToggleBtn, getSpeedEnabled = createToggle(mainPanel, "⚡ Speed", UDim2.new(0, 0, 0, 10))

-- Slider Speed
local speedSliderFrame = createStyledFrame(mainPanel, "SpeedSlider", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 65))

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(0.5, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.Text = "Velocidade:"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedSliderFrame

local speedValue = Instance.new("TextLabel")
speedValue.Name = "SpeedValue"
speedValue.Size = UDim2.new(0.5, 0, 0, 20)
speedValue.Position = UDim2.new(0.5, 0, 0, 0)
speedValue.Text = "500"
speedValue.BackgroundTransparency = 1
speedValue.TextColor3 = Color3.fromRGB(0, 200, 100)
speedValue.Font = Enum.Font.GothamBold
speedValue.TextXAlignment = Enum.TextXAlignment.Right
speedValue.Parent = speedSliderFrame

local speedSlider = Instance.new("TextButton")
speedSlider.Name = "SpeedSlider"
speedSlider.Size = UDim2.new(1, 0, 0, 10)
speedSlider.Position = UDim2.new(0, 0, 0, 25)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedSlider.BorderSizePixel = 0
speedSlider.Text = ""
speedSlider.Parent = speedSliderFrame

local speedFill = Instance.new("Frame")
speedFill.Name = "Fill"
speedFill.Size = UDim2.new((500 - 100) / 900, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSlider

speedSlider.MouseButton1Down:Connect(function()
    local dragging = true
    mouse.Move:Connect(function()
        if dragging then
            local mousePos = mouse.X
            local sliderPos = speedSlider.AbsolutePosition.X
            local sliderSize = speedSlider.AbsoluteSize.X
            local percent = math.max(0, math.min(1, (mousePos - sliderPos) / sliderSize))
            local value = math.floor(100 + (percent * 900))
            
            speedFill.Size = UDim2.new(percent, 0, 1, 0)
            speedValue.Text = tostring(value)
            Config.speedValue = value
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end)

-- Toggle Fly
local flyToggleContainer, flyToggleBtn, getFlyEnabled = createToggle(mainPanel, "✈️ Fly (Voar)", UDim2.new(0, 0, 0, 120))

-- PAINEL CONFIGURAÇÕES
local settingsPanel = createStyledFrame(screenGui, "SettingsPanel", UDim2.new(0, 250, 0, 250), UDim2.new(0, 95, 0, 65), Color3.fromRGB(35, 35, 35), 0)
settingsPanel.Visible = false

local themeLabel = Instance.new("TextLabel")
themeLabel.Name = "ThemeLabel"
themeLabel.Size = UDim2.new(1, -20, 0, 25)
themeLabel.Position = UDim2.new(0, 10, 0, 10)
themeLabel.Text = "🎨 Tema:"
themeLabel.BackgroundTransparency = 1
themeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
themeLabel.Font = Enum.Font.Gotham
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Parent = settingsPanel

-- Botão Salvar
local saveBtn = createStyledButton(settingsPanel, "SaveBtn", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 190), "💾 Salvar Configuração", function()
    Config.flyEnabled = getFlyEnabled()
    Config.speedEnabled = getSpeedEnabled()
    
    -- Salvar em arquivo (simulado)
    print("✅ Configurações salvas!")
    print("Speed: " .. tostring(Config.speedValue))
    print("Fly: " .. tostring(Config.flyEnabled))
    print("Speed Enable: " .. tostring(Config.speedEnabled))
end)

-- Função Fly
local function startFlying()
    if flying then return end
    flying = true
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = rootPart
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not flying or not bodyVelocity or bodyVelocity.Parent == nil then
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
            flying = false
            connection:Disconnect()
            return
        end
        
        local speed = Config.speedValue / 50
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + (rootPart.CFrame.LookVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - (rootPart.CFrame.LookVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - (rootPart.CFrame.RightVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + (rootPart.CFrame.RightVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        
        bodyVelocity.Velocity = moveDirection * speed
    end)
end

local function stopFlying()
    flying = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

-- Conectar toggle do Fly
flyToggleBtn.MouseButton1Click:Connect(function()
    if getFlyEnabled() then
        startFlying()
        print("✈️ Fly ativado!")
    else
        stopFlying()
        print("✈️ Fly desativado!")
    end
end)

-- Conectar toggle do Speed
speedToggleBtn.MouseButton1Click:Connect(function()
    Config.speedEnabled = getSpeedEnabled()
    print("⚡ Speed " .. (Config.speedEnabled and "ativado!" or "desativado!"))
end)

print("🐔 Menu Steal an Egg carregado! Use W, A, S, D para voar (quando ativo)")
print("Espaço para subir, Ctrl para descer")
