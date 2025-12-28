--[[
    BLOXY HUB TITANIUM - UI: TAB DASHBOARD
    Panel principal - VERSIÓN ROBUSTA CON PERFIL
]]

local DashboardTab = {}

function DashboardTab:Create(Window, deps)
    local Utils = deps.Utils
    local Session = deps.Session
    local Colors = deps.Colors
    local Services = deps.Services
    
    local Tab = Window:Tab({
        Title = Utils:Translate("Dashboard"),
        Icon = "solar:home-2-bold",
        IconColor = Colors.Blue,
        IconShape = "Square",
        Border = true
    })
    
    -- Bienvenida
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
    
    -- Estado del Script (Info dinámica)
    local StatusSection = Tab:Section({
        Title = Utils:Translate("EstadoScript"),
        Box = true,
        BoxBorder = true,
        Opened = true
    })
    
    StatusSection:Section({
        Title = "Estado: " .. (Session.Status or "Iniciando..."),
        TextSize = 14
    })
    
    -- Info con hora de Lima
    local limaTime = Session:GetLimaTime() or "00:00:00"
    StatusSection:Section({
        Title = string.format("FPS: %d | Ping: %dms | Hora Lima: %s", 
            Session.FPS or 60, 
            Session.Ping or 0, 
            limaTime),
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
    
    local currentLevel = Session:GetPlayerLevel() or 0
    local currentBeli = Session:GetPlayerBeli() or 0
    local currentFrags = Session:GetPlayerFragments() or 0
    local world, _ = Utils:GetCurrentWorld()
    
    -- Mostrar fragmentos según el sea
    local fragText = ""
    if world == 1 then
        fragText = "Fragmentos: Disponible en Sea 2+"
    else
        fragText = "Fragmentos: " .. currentFrags
    end
    
    StatsSection:Section({
        Title = string.format("Nivel: %d | Beli: %d", currentLevel, currentBeli),
        TextSize = 14
    })
    
    StatsSection:Section({
        Title = fragText,
        TextSize = 12,
        TextTransparency = 0.3
    })
    
    StatsSection:Space()
    
    StatsSection:Section({
        Title = string.format(
            "Ganado: +%d Niveles | +%d Beli | %d Mobs",
            Session.LevelsGained or 0, 
            Session.BeliEarned or 0, 
            Session.MobsKilled or 0
        ),
        TextSize = 12,
        TextTransparency = 0.4
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
    -- PERFIL DEL USUARIO
    -- ═══════════════════════════════════════════════════════════════
    
    local ProfileSection = Tab:Section({
        Title = "👤 Tu Perfil",
        Box = true,
        BoxBorder = true,
        Opened = true
    })
    
    local player = Services.LocalPlayer
    local playerInfo = Utils:GetPlayerInfo()
    
    -- Imagen de perfil usando el formato rbxthumb (funciona en Roblox)
    ProfileSection:Image({
        Image = playerInfo.ThumbnailId,
        AspectRatio = "1:1",
        Radius = 50
    })
    
    ProfileSection:Space()
    
    -- Nombre de display
    ProfileSection:Section({
        Title = player.DisplayName,
        TextSize = 18,
        FontWeight = Enum.FontWeight.Bold
    })
    
    -- Username con @
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

return DashboardTab
