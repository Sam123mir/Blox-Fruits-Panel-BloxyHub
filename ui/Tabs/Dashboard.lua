--[[
    BLOXY HUB TITANIUM - UI: TAB DASHBOARD
    Panel principal con estadísticas - CORREGIDO + FOOTER PERFIL
]]

local DashboardTab = {}

function DashboardTab:Create(Window, deps)
    local Utils = deps.Utils
    local Session = deps.Session
    local ThreadManager = deps.ThreadManager
    local Colors = deps.Colors
    local Services = deps.Services
    
    local Tab = Window:Tab({
        Title = Utils:Translate("Dashboard"),
        Icon = "solar:home-2-bold",
        IconColor = Colors.Blue,
        IconShape = "Square",
        Border = true
    })
    
    -- Sección de bienvenida
    Tab:Section({
        Title = Utils:Translate("BIENVENIDO"),
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold
    })
    
    Tab:Section({
        Title = Utils:Translate("WelcomeContent"),
        TextSize = 14,
        TextTransparency = 0.3
    })
    
    Tab:Space({ Columns = 2 })
    
    -- Estado del Script
    local StatusSection = Tab:Section({
        Title = Utils:Translate("EstadoScript"),
        Box = true,
        BoxBorder = true,
        Opened = true
    })
    
    StatusSection:Section({
        Title = Session.Status or "Iniciando...",
        TextSize = 16
    })
    
    StatusSection:Section({
        Title = string.format("FPS: %d | Ping: %dms | Uptime: %s", 
            Session.FPS or 60, Session.Ping or 0, Session.Uptime or "00:00:00"),
        TextSize = 12,
        TextTransparency = 0.4
    })
    
    Tab:Space()
    
    -- Estadísticas de Sesión
    local StatsSection = Tab:Section({
        Title = Utils:Translate("SesionStats"),
        Box = true,
        BoxBorder = true,
        Opened = true
    })
    
    -- Mostrar nivel actual
    local currentLevel = Session:GetPlayerLevel() or 0
    local currentBeli = Session:GetPlayerBeli() or 0
    
    StatsSection:Section({
        Title = string.format(
            "Nivel Actual: %d | Beli: %d",
            currentLevel, currentBeli
        ),
        TextSize = 14
    })
    
    StatsSection:Section({
        Title = string.format(
            "Ganado: Niveles +%d | Beli +%d | Mobs: %d",
            Session.LevelsGained or 0, Session.BeliEarned or 0, 
            Session.MobsKilled or 0
        ),
        TextSize = 12,
        TextTransparency = 0.3
    })
    
    Tab:Space()
    
    -- Mundo Actual
    local _, worldName = Utils:GetCurrentWorld()
    Tab:Section({
        Title = Utils:Translate("MundoActual") .. ": " .. worldName,
        Box = true,
        BoxBorder = true
    })
    
    Tab:Space({ Columns = 2 })
    
    -- ═══════════════════════════════════════════════════════════════
    -- FOOTER: PERFIL DEL USUARIO
    -- ═══════════════════════════════════════════════════════════════
    
    local ProfileSection = Tab:Section({
        Title = "👤 Tu Perfil",
        Box = true,
        BoxBorder = true,
        Opened = true
    })
    
    local player = Services.LocalPlayer
    local playerInfo = Utils:GetPlayerInfo()
    
    -- Imagen de perfil (WindUI soporta imágenes)
    ProfileSection:Image({
        Image = playerInfo.Thumbnail,
        AspectRatio = "1:1",
        Radius = 50
    })
    
    ProfileSection:Space()
    
    ProfileSection:Section({
        Title = player.DisplayName,
        TextSize = 18,
        FontWeight = Enum.FontWeight.Bold
    })
    
    ProfileSection:Section({
        Title = "@" .. player.Name,
        TextSize = 14,
        TextTransparency = 0.4
    })
    
    -- Guardar referencias
    DashboardTab.Session = Session
    DashboardTab.Utils = Utils
    
    return Tab
end

function DashboardTab:Update()
    -- Las actualizaciones se hacen en Session:Update()
    -- WindUI no permite actualizar secciones dinámicamente de forma sencilla
end

return DashboardTab
