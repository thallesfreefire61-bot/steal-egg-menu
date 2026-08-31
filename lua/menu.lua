#!/usr/bin/env lua
-- Steal an Egg Menu - Versão Lua para Android
-- Compatível com Corona SDK e Love 2D

local menu = {}
menu.version = "1.0"

-- Configurações
local config = {
    speedEnabled = false,
    speedValue = 500,
    flyEnabled = false,
    theme = "dark",
    opacity = 0.95,
    menuVisible = true,
    currentTab = "main"
}

-- Cores
local colors = {
    dark = {
        bg = {25, 25, 25},
        header = {25, 25, 25},
        content = {35, 35, 35},
        sidebar = {30, 30, 30},
        button = {45, 45, 45},
        text = {255, 255, 255},
        accent = {0, 200, 100},
        title = {255, 200, 0}
    },
    light = {
        bg = {245, 245, 245},
        header = {240, 240, 240},
        content = {250, 250, 250},
        sidebar = {235, 235, 235},
        button = {220, 220, 220},
        text = {0, 0, 0},
        accent = {0, 150, 255},
        title = {0, 100, 200}
    },
    neon = {
        bg = {10, 14, 39},
        header = {10, 14, 39},
        content = {15, 20, 50},
        sidebar = {12, 16, 45},
        button = {20, 25, 60},
        text = {0, 255, 0},
        accent = {255, 0, 255},
        title = {0, 255, 255}
    }
}

-- Posição e tamanho do menu
local menuPos = {x = 50, y = 50}
local menuSize = {width = 400, height = 600}

-- Variáveis de controle
local buttons = {}
local toggles = {}
local sliders = {}
local isDragging = false
local dragOffset = {x = 0, y = 0}

-- ==================== FUNÇÕES AUXILIARES ====================

function menu.drawText(x, y, text, size, color)
    -- Função para desenhar texto (adaptável para Corona/Love)
    if love then
        love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255)
        love.graphics.printf(text, x, y, 300, "left")
    elseif system then
        -- Corona SDK
        local textObj = display.newText(text, x, y, native.systemFont, size)
        textObj:setFillColor(color[1]/255, color[2]/255, color[3]/255)
        return textObj
    end
end

function menu.drawRect(x, y, width, height, color, fillFlag)
    if love then
        love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255)
        if fillFlag ~= false then
            love.graphics.rectangle("fill", x, y, width, height)
        else
            love.graphics.rectangle("line", x, y, width, height)
        end
    elseif system then
        local rect = display.newRect(x + width/2, y + height/2, width, height)
        rect:setFillColor(color[1]/255, color[2]/255, color[3]/255)
        return rect
    end
end

function menu.createButton(x, y, width, height, label, callback)
    local button = {
        x = x,
        y = y,
        width = width,
        height = height,
        label = label,
        callback = callback,
        hovered = false
    }
    
    table.insert(buttons, button)
    return button
end

function menu.createToggle(x, y, width, height, label, callback)
    local toggle = {
        x = x,
        y = y,
        width = width,
        height = height,
        label = label,
        enabled = false,
        callback = callback
    }
    
    table.insert(toggles, toggle)
    return toggle
end

function menu.createSlider(x, y, width, height, min, max, value, callback)
    local slider = {
        x = x,
        y = y,
        width = width,
        height = height,
        min = min,
        max = max,
        value = value or min,
        callback = callback,
        isDragging = false
    }
    
    table.insert(sliders, slider)
    return slider
end

-- ==================== DRAW FUNCTIONS ====================

function menu.drawHeader()
    local themeColors = colors[config.theme]
    
    -- Background do header
    menu.drawRect(menuPos.x, menuPos.y, menuSize.width, 60, themeColors.header)
    
    -- Título
    menu.drawText(menuPos.x + 15, menuPos.y + 15, "🐔 Steal an Egg", 20, themeColors.title)
    
    -- Botão Ocultar
    local hideBtn = menu.createButton(menuPos.x + menuSize.width - 110, menuPos.y + 10, 45, 40, "▼", function()
        config.menuVisible = not config.menuVisible
    end)
    
    -- Botão Fechar
    local closeBtn = menu.createButton(menuPos.x + menuSize.width - 60, menuPos.y + 10, 45, 40, "✕", function()
        menu.close()
    end)
end

function menu.drawTabsSidebar()
    local themeColors = colors[config.theme]
    local sidebarX = menuPos.x
    local sidebarY = menuPos.y + 60
    local sidebarWidth = 80
    local tabHeight = menuSize.height - 60
    
    -- Background sidebar
    menu.drawRect(sidebarX, sidebarY, sidebarWidth, tabHeight, themeColors.sidebar)
    
    -- Botão Aba Principal
    local mainTabBtn = menu.createButton(sidebarX + 5, sidebarY + 5, sidebarWidth - 10, 70, "⚙️\nPrincipal", function()
        config.currentTab = "main"
    end)
    mainTabBtn.isActive = (config.currentTab == "main")
    
    -- Botão Aba Configurações
    local settingsTabBtn = menu.createButton(sidebarX + 5, sidebarY + 80, sidebarWidth - 10, 70, "🔧\nConfig", function()
        config.currentTab = "settings"
    end)
    settingsTabBtn.isActive = (config.currentTab == "settings")
end

function menu.drawMainPanel()
    local themeColors = colors[config.theme]
    local panelX = menuPos.x + 80
    local panelY = menuPos.y + 60
    local panelWidth = menuSize.width - 80
    local panelHeight = menuSize.height - 60
    
    -- Background painel
    menu.drawRect(panelX, panelY, panelWidth, panelHeight, themeColors.content)
    
    -- Título
    menu.drawText(panelX + 15, panelY + 10, "⚙️ Funcionalidades", 16, themeColors.text)
    
    -- Toggle Speed
    local speedToggle = menu.createToggle(panelX + 10, panelY + 50, panelWidth - 20, 50, "⚡ Speed", function(enabled)
        config.speedEnabled = enabled
        print("Speed " .. (enabled and "ativado!" or "desativado!"))
    end)
    speedToggle.enabled = config.speedEnabled
    
    -- Slider Speed (100-1000)
    menu.drawText(panelX + 15, panelY + 110, "Velocidade: " .. config.speedValue, 12, themeColors.text)
    local speedSlider = menu.createSlider(panelX + 10, panelY + 135, panelWidth - 20, 20, 100, 1000, config.speedValue, function(value)
        config.speedValue = value
    end)
    
    -- Toggle Fly
    local flyToggle = menu.createToggle(panelX + 10, panelY + 180, panelWidth - 20, 50, "✈️ Fly (Voar)", function(enabled)
        config.flyEnabled = enabled
        print("Fly " .. (enabled and "ativado!" or "desativado!"))
    end)
    flyToggle.enabled = config.flyEnabled
    
    -- Info
    menu.drawText(panelX + 15, panelY + 250, "W/A/S/D - Mover", 10, themeColors.text)
    menu.drawText(panelX + 15, panelY + 270, "ESPAÇO - Subir", 10, themeColors.text)
    menu.drawText(panelX + 15, panelY + 290, "CTRL - Descer", 10, themeColors.text)
end

function menu.drawSettingsPanel()
    local themeColors = colors[config.theme]
    local panelX = menuPos.x + 80
    local panelY = menuPos.y + 60
    local panelWidth = menuSize.width - 80
    local panelHeight = menuSize.height - 60
    
    -- Background painel
    menu.drawRect(panelX, panelY, panelWidth, panelHeight, themeColors.content)
    
    -- Título
    menu.drawText(panelX + 15, panelY + 10, "🔧 Configurações", 16, themeColors.text)
    
    -- Tema
    menu.drawText(panelX + 15, panelY + 50, "🎨 Tema:", 12, themeColors.text)
    menu.drawText(panelX + 15, panelY + 70, "Tema Atual: " .. config.theme, 11, themeColors.accent)
    
    -- Botões de tema
    menu.createButton(panelX + 10, panelY + 95, 50, 30, "Escuro", function()
        config.theme = "dark"
    end)
    
    menu.createButton(panelX + 65, panelY + 95, 50, 30, "Claro", function()
        config.theme = "light"
    end)
    
    menu.createButton(panelX + 120, panelY + 95, 50, 30, "Neon", function()
        config.theme = "neon"
    end)
    
    -- Opacidade
    menu.drawText(panelX + 15, panelY + 140, "Opacidade: " .. math.floor(config.opacity * 100) .. "%", 12, themeColors.text)
    local opacitySlider = menu.createSlider(panelX + 10, panelY + 165, panelWidth - 20, 20, 0.3, 1, config.opacity, function(value)
        config.opacity = value
    end)
    
    -- Botão Salvar
    menu.createButton(panelX + 10, panelY + 480, panelWidth - 20, 50, "💾 Salvar Configuração", function()
        menu.saveConfig()
    end)
end

function menu.drawSlider(slider)
    local themeColors = colors[config.theme]
    
    -- Background slider
    menu.drawRect(slider.x, slider.y, slider.width, slider.height, themeColors.button)
    
    -- Calcular posição do handle
    local range = slider.max - slider.min
    local percent = (slider.value - slider.min) / range
    local handleX = slider.x + (percent * slider.width)
    
    -- Draw fill
    menu.drawRect(slider.x, slider.y, percent * slider.width, slider.height, themeColors.accent)
    
    -- Draw handle
    menu.drawRect(handleX - 5, slider.y - 5, 10, slider.height + 10, themeColors.title)
end

function menu.drawToggle(toggle)
    local themeColors = colors[config.theme]
    
    -- Background
    menu.drawRect(toggle.x, toggle.y, toggle.width, toggle.height, themeColors.button)
    
    -- Label
    menu.drawText(toggle.x + 10, toggle.y + 12, toggle.label, 14, themeColors.text)
    
    -- Switch
    local switchX = toggle.x + toggle.width - 50
    local switchY = toggle.y + (toggle.height - 25) / 2
    menu.drawRect(switchX, switchY, 45, 25, toggle.enabled and themeColors.accent or {100, 100, 100})
    
    -- Circle
    local circleX = toggle.enabled and (switchX + 25) or (switchX + 10)
    menu.drawRect(circleX - 7, switchY + 2, 14, 21, {255, 255, 255})
end

function menu.drawButton(button)
    local themeColors = colors[config.theme]
    
    -- Background
    local bgColor = button.hovered and themeColors.accent or themeColors.button
    if button.isActive then
        bgColor = themeColors.accent
    end
    menu.drawRect(button.x, button.y, button.width, button.height, bgColor)
    
    -- Text
    menu.drawText(button.x + 5, button.y + 10, button.label, 12, themeColors.text)
end

function menu.draw()
    if not config.menuVisible then return end
    
    local themeColors = colors[config.theme]
    
    -- Background principal com transparência
    menu.drawRect(menuPos.x, menuPos.y, menuSize.width, menuSize.height, themeColors.bg)
    
    -- Header
    menu.drawHeader()
    
    -- Sidebar de abas
    menu.drawTabsSidebar()
    
    -- Painel de conteúdo
    if config.currentTab == "main" then
        menu.drawMainPanel()
    else
        menu.drawSettingsPanel()
    end
    
    -- Draw buttons
    for _, button in ipairs(buttons) do
        menu.drawButton(button)
    end
    
    -- Draw toggles
    for _, toggle in ipairs(toggles) do
        menu.drawToggle(toggle)
    end
    
    -- Draw sliders
    for _, slider in ipairs(sliders) do
        menu.drawSlider(slider)
    end
end

-- ==================== INPUT HANDLING ====================

function menu.mousepressed(x, y)
    -- Checar se clicou em um botão
    for _, button in ipairs(buttons) do
        if x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height then
            if button.callback then
                button.callback()
            end
        end
    end
    
    -- Checar se clicou em um toggle
    for _, toggle in ipairs(toggles) do
        if x >= toggle.x and x <= toggle.x + toggle.width and
           y >= toggle.y and y <= toggle.y + toggle.height then
            toggle.enabled = not toggle.enabled
            if toggle.callback then
                toggle.callback(toggle.enabled)
            end
        end
    end
    
    -- Checar se clicou em um slider
    for _, slider in ipairs(sliders) do
        if x >= slider.x and x <= slider.x + slider.width and
           y >= slider.y and y <= slider.y + slider.height then
            slider.isDragging = true
            local range = slider.max - slider.min
            local percent = (x - slider.x) / slider.width
            slider.value = slider.min + (percent * range)
            if slider.callback then
                slider.callback(slider.value)
            end
        end
    end
    
    -- Checar se está arrastando o menu (no header)
    if x >= menuPos.x and x <= menuPos.x + menuSize.width and
       y >= menuPos.y and y <= menuPos.y + 60 then
        isDragging = true
        dragOffset.x = x - menuPos.x
        dragOffset.y = y - menuPos.y
    end
end

function menu.mousemoved(x, y)
    -- Verificar botões com hover
    for _, button in ipairs(buttons) do
        button.hovered = (x >= button.x and x <= button.x + button.width and
                         y >= button.y and y <= button.y + button.height)
    end
    
    -- Arrastar menu
    if isDragging then
        menuPos.x = x - dragOffset.x
        menuPos.y = y - dragOffset.y
    end
    
    -- Arrastar sliders
    for _, slider in ipairs(sliders) do
        if slider.isDragging then
            local range = slider.max - slider.min
            local percent = (x - slider.x) / slider.width
            percent = math.max(0, math.min(1, percent))
            slider.value = slider.min + (percent * range)
            if slider.callback then
                slider.callback(slider.value)
            end
        end
    end
end

function menu.mousereleased(x, y)
    isDragging = false
    for _, slider in ipairs(sliders) do
        slider.isDragging = false
    end
end

-- ==================== SAVE/LOAD ====================

function menu.saveConfig()
    local configStr = "-- Steal an Egg Config\n"
    configStr = configStr .. "return {\n"
    configStr = configStr .. "  speedEnabled = " .. tostring(config.speedEnabled) .. ",\n"
    configStr = configStr .. "  speedValue = " .. config.speedValue .. ",\n"
    configStr = configStr .. "  flyEnabled = " .. tostring(config.flyEnabled) .. ",\n"
    configStr = configStr .. "  theme = '" .. config.theme .. "',\n"
    configStr = configStr .. "  opacity = " .. config.opacity .. "\n"
    configStr = configStr .. "}"
    
    -- Salvar em arquivo (adaptável para Corona/Love)
    if love and love.filesystem then
        love.filesystem.write("steal_egg_config.lua", configStr)
        print("✅ Configurações salvas!")
    elseif system then
        -- Corona SDK
        local path = system.DocumentsDirectory
        local file = io.open(path .. "/steal_egg_config.lua", "w")
        file:write(configStr)
        file:close()
        print("✅ Configurações salvas em: " .. path)
    end
end

function menu.loadConfig()
    local ok, result = pcall(function()
        if love and love.filesystem and love.filesystem.getInfo("steal_egg_config.lua") then
            local configStr = love.filesystem.read("steal_egg_config.lua")
            return loadstring("return " .. configStr)()
        elseif system then
            local path = system.DocumentsDirectory .. "/steal_egg_config.lua"
            local file = io.open(path, "r")
            if file then
                local configStr = file:read("*a")
                file:close()
                return loadstring("return " .. configStr)()
            end
        end
        return nil
    end)
    
    if ok and result then
        for key, value in pairs(result) do
            config[key] = value
        end
        print("✅ Configurações carregadas!")
    end
end

function menu.close()
    print("Menu fechado!")
    os.exit()
end

-- ==================== INICIALIZAÇÃO ====================

function menu.init()
    print("🐔 Steal an Egg Menu v" .. menu.version)
    print("Inicializando menu...")
    menu.loadConfig()
    print("Menu pronto!")
end

-- ==================== LOVE 2D INTEGRATION ====================

if love then
    function love.load()
        menu.init()
    end
    
    function love.draw()
        love.graphics.clear(0.1, 0.1, 0.1)
        menu.draw()
    end
    
    function love.mousepressed(x, y, button)
        if button == 1 then
            menu.mousepressed(x, y)
        end
    end
    
    function love.mousemoved(x, y)
        menu.mousemoved(x, y)
    end
    
    function love.mousereleased(x, y, button)
        if button == 1 then
            menu.mousereleased(x, y)
        end
    end
end

-- ==================== RETORNAR MODULE ====================

return menu
