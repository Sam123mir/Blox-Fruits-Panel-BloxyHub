--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  BLOX FRUITS PANEL | BLOXY HUB TITANIUM V8.0               ║
    ║  Arquitectura Modular Profesional | Diseñado por Sammir    ║
    ║  UI: WindUI | Sistema de Módulos Separados                  ║
    ╚══════════════════════════════════════════════════════════════╝
    
    LOADER PRINCIPAL - Este archivo carga todos los módulos
    
    Para uso en ejecutores, todos los módulos deben estar en un
    repositorio de GitHub y se cargan via HttpGet.
    
    Para desarrollo local, este archivo puede ser modificado para
    usar require() directo si tienes herramientas como Rojo.
]]

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE CARGA
-- ═══════════════════════════════════════════════════════════════

-- Cambia esta URL a tu repositorio de GitHub
local BASE_URL = "https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-Panel-BloxyHub/main/"

-- Si estás en desarrollo local, puedes cambiar esto a true
-- y modificar la función loadModule para usar require
local USE_LOCAL = false

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE CARGA DE MÓDULOS
-- ═══════════════════════════════════════════════════════════════

local function loadModule(path)
    if USE_LOCAL then
        -- Para desarrollo local con Rojo o similar
        return require(script.Parent:FindFirstChild(path:gsub("/", "."):gsub(".lua", "")))
    else
        -- Carga desde GitHub
        local url = BASE_URL .. path
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        
        if success then
            return result
        else
            warn("[BLOXY HUB] Error cargando " .. path .. ": " .. tostring(result))
            return nil
        end
    end
end

print("[BLOXY HUB] ====================================")
print("[BLOXY HUB] Bloxy Hub Titanium v8.0")
print("[BLOXY HUB] Cargando sistema modular...")
print("[BLOXY HUB] ====================================")

-- ═══════════════════════════════════════════════════════════════
-- VALIDACIÓN DE JUEGO
-- ═══════════════════════════════════════════════════════════════

local VALID_PLACE_IDS = {2753915549, 4442272183, 7449423635}
if not table.find(VALID_PLACE_IDS, game.PlaceId) then
    game:GetService("Players").LocalPlayer:Kick("⚠️ BLOXY HUB: Este script solo es compatible con Blox Fruits.")
    return
end

-- ═══════════════════════════════════════════════════════════════
-- PREVENIR INSTANCIAS DUPLICADAS
-- ═══════════════════════════════════════════════════════════════

getgenv().BloxyHub = getgenv().BloxyHub or {}

if getgenv().BloxyHub.Active then
    warn("[BLOXY HUB] Ya hay una instancia activa. Cerrando anterior...")
    if getgenv().BloxyHub.Shutdown then
        pcall(getgenv().BloxyHub.Shutdown)
    end
    task.wait(1)
end

-- ═══════════════════════════════════════════════════════════════
-- CARGA DE MÓDULOS CORE
-- ═══════════════════════════════════════════════════════════════

print("[BLOXY HUB] Cargando módulos core...")

local Services = loadModule("modules/Services.lua")
local Config = loadModule("modules/Config.lua")
local I18n = loadModule("modules/I18n.lua")
local Utils = loadModule("modules/Utils.lua")
local Session = loadModule("modules/Session.lua")
local ThreadManager = loadModule("modules/ThreadManager.lua")
local LogSystem = loadModule("modules/LogSystem.lua")
local Combat = loadModule("modules/Combat.lua")
local AI = loadModule("modules/AI.lua")
local Farming = loadModule("modules/Farming.lua")
local StatsManager = loadModule("modules/StatsManager.lua")
local Performance = loadModule("modules/Performance.lua")
local Security = loadModule("modules/Security.lua")
local PlayerEnhancements = loadModule("modules/PlayerEnhancements.lua")

-- Data
local QuestData = loadModule("data/QuestData.lua")

print("[BLOXY HUB] Módulos core cargados ✓")

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZACIÓN DE DEPENDENCIAS
-- ═══════════════════════════════════════════════════════════════

print("[BLOXY HUB] Inicializando dependencias...")

local deps = {
    Services = Services,
    Config = Config,
    I18n = I18n,
    Utils = Utils,
    Session = Session,
    ThreadManager = ThreadManager,
    LogSystem = LogSystem,
    Combat = Combat,
    AI = AI,
    Farming = Farming,
    StatsManager = StatsManager,
    Performance = Performance,
    Security = Security,
    PlayerEnhancements = PlayerEnhancements,
    QuestData = QuestData
}

-- Inicializar módulos que requieren dependencias
if Utils.Init then Utils:Init(deps) end
if Session.Init then Session:Init(deps) end
if LogSystem.Init then LogSystem:Init(deps) end
if Combat.Init then Combat:Init(deps) end
if AI.Init then AI:Init(deps) end
if Farming.Init then Farming:Init(deps) end
if StatsManager.Init then StatsManager:Init(deps) end
if Performance.Init then Performance:Init(deps) end
if Security.Init then Security:Init(deps) end
if PlayerEnhancements.Init then PlayerEnhancements:Init(deps) end

print("[BLOXY HUB] Dependencias inicializadas ✓")

-- ═══════════════════════════════════════════════════════════════
-- CARGA DE UI (WindUI)
-- ═══════════════════════════════════════════════════════════════

print("[BLOXY HUB] Cargando WindUI...")

local UIInit = loadModule("ui/Init.lua")
if UIInit.Init then UIInit:Init(deps) end

local WindUI = UIInit:LoadWindUI()
if not WindUI then
    warn("[BLOXY HUB] ERROR FATAL: No se pudo cargar WindUI")
    return
end

-- Inyectar WindUI en Utils para notificaciones
Utils:SetWindUI(WindUI)

local Window = UIInit:CreateWindow(WindUI)
if not Window then
    warn("[BLOXY HUB] ERROR FATAL: No se pudo crear la ventana")
    return
end

print("[BLOXY HUB] WindUI cargado ✓")

-- Agregar WindUI y colores a deps
deps.WindUI = WindUI
deps.Window = Window
deps.Colors = UIInit.Colors
deps.Services = Services -- Importante para Dashboard

-- Configurar speed loop para mantener velocidad/salto
PlayerEnhancements:SetupSpeedLoop()

-- ═══════════════════════════════════════════════════════════════
-- CARGA DE TABS
-- ═══════════════════════════════════════════════════════════════

print("[BLOXY HUB] Creando interfaz...")

local DashboardTab = loadModule("ui/Tabs/Dashboard.lua")
local FarmingTab = loadModule("ui/Tabs/Farming.lua")
local CombatTab = loadModule("ui/Tabs/Combat.lua")
local PlayerTab = loadModule("ui/Tabs/Player.lua")
local StatsTab = loadModule("ui/Tabs/Stats.lua")
local PerformanceTab = loadModule("ui/Tabs/Performance.lua")
local SecurityTab = loadModule("ui/Tabs/Security.lua")
local LogsTab = loadModule("ui/Tabs/Logs.lua")
local SettingsTab = loadModule("ui/Tabs/Settings.lua")

-- Agregar referencia a BloxyHub para settings
deps.BloxyHub = getgenv().BloxyHub

-- Crear tabs
DashboardTab:Create(Window, deps)
FarmingTab:Create(Window, deps)
CombatTab:Create(Window, deps)
PlayerTab:Create(Window, deps)
StatsTab:Create(Window, deps)
PerformanceTab:Create(Window, deps)
SecurityTab:Create(Window, deps)
LogsTab:Create(Window, deps)
SettingsTab:Create(Window, deps)

print("[BLOXY HUB] Interfaz creada ✓")

-- ═══════════════════════════════════════════════════════════════
-- BOTÓN FLOTANTE MÓVIL
-- ═══════════════════════════════════════════════════════════════

local FloatingButton = loadModule("ui/Components/FloatingButton.lua")
local mobileButton = FloatingButton:Create(deps)

-- ═══════════════════════════════════════════════════════════════
-- LOOPS PRINCIPALES
-- ═══════════════════════════════════════════════════════════════

print("[BLOXY HUB] Registrando loops...")

-- Loop: Auto Farm
ThreadManager:Register("AutoFarm", function()
    if Config.AutoFarm.Enabled then
        Farming:AutoLevel()
    end
    task.wait(0.1)
end)

-- Loop: Auto Mastery
ThreadManager:Register("AutoMastery", function()
    if Config.Mastery.Enabled then
        if Config.AIMastery.Enabled then
            local enemy = Utils:GetClosestEnemy(500)
            if enemy then
                Utils:Equip(Config.AIMastery.SelectedWeapon)
                Combat:AttackEnemy(enemy)
                AI:UseSkills("Mastery")
            end
        else
            Farming:AutoMastery()
        end
    end
    task.wait(0.1)
end)

-- Loop: PvP IA
ThreadManager:Register("PvPIA", function()
    if Config.PvP.AutoPvP then
        AI:HandlePvP()
    end
    task.wait(0.1)
end)

-- Loop: Fast Attack
ThreadManager:Register("FastAttack", function()
    if Config.Combat.FastAttack and (Config.AutoFarm.Enabled or Config.Mastery.Enabled or Config.Combat.KillAura) then
        Combat:FastAttack()
    end
    task.wait(Config.Combat.AttackSpeed)
end)

-- Loop: Kill Aura
ThreadManager:Register("KillAura", function()
    if Config.Combat.KillAura then
        Combat:KillAura()
    end
    task.wait(0.2)
end)

-- Loop: Auto Stats
ThreadManager:Register("AutoStats", function()
    if Config.Stats.Enabled then
        StatsManager:DistributePoints()
    end
    task.wait(5)
end)

-- Loop: Seguridad
ThreadManager:Register("SecurityManager", function()
    -- Anti-AFK
    Security:RunAntiAFK()
    
    -- Detector de Admins
    if Config.Security.AdminDetector then
        Security:DetectAdmin()
    end
    
    -- Mejoras del jugador
    PlayerEnhancements:Update()
    
    task.wait(2)
end)

-- Loop: UI Update
ThreadManager:Register("UIUpdate", function()
    Session:Update()
    task.wait(Config.Performance.UIRefreshRate or 1.5)
end)

print("[BLOXY HUB] Loops registrados ✓")

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES DE CIERRE
-- ═══════════════════════════════════════════════════════════════

getgenv().BloxyHub.Shutdown = function()
    getgenv().BloxyHub.Active = false
    ThreadManager:StopAll()
    Performance:RestoreDefaults()
    
    pcall(function()
        if Window then Window:Destroy() end
        if mobileButton then FloatingButton:Destroy(mobileButton) end
    end)
    
    warn("[BLOXY HUB] Sistema cerrado correctamente.")
end

getgenv().BloxyHub.Restart = function()
    getgenv().BloxyHub.Shutdown()
    task.wait(1)
    warn("[BLOXY HUB] Reiniciando...")
    -- Aquí podrías volver a ejecutar el loadstring del loader
end

-- ═══════════════════════════════════════════════════════════════
-- FINALIZACIÓN
-- ═══════════════════════════════════════════════════════════════

-- Configurar Infinite Skyjump
PlayerEnhancements:SetupInfiniteSkyjump()

-- Marcar como activo
getgenv().BloxyHub.Active = true

-- Notificación de éxito
Utils:Notify("Bloxy Hub", Utils:Translate("LoadedSuccess"), 5)
Session.Status = Utils:Translate("ReadyFarm")
LogSystem:Add("Sistema iniciado correctamente", "SUCCESS")

print([[

    ____  _      ____  __  ____   __   _    _ _    _ ____  
    | __ )| |    / __ \ \ \/ / \ \ / /  | |  | | |  | | __ ) 
    |  _ \| |   | |  | | \  /   \ V /   | |__| | |  | |  _ \ 
    | |_) | |___| |__| | /  \    | |    |  __  | |  | | |_) |
    |____/|_____|____/ /_/\_\   |_|    |_|  |_|\____/|____/ 
    
    BLOX FRUITS PANEL - BLOXY HUB TITANIUM V8.0 PROFESSIONAL
    Arquitectura Modular con WindUI
    
]])

print("[BLOXY HUB] ====================================")
print("[BLOXY HUB] ¡Script cargado exitosamente!")
print("[BLOXY HUB] Threads activos: " .. ThreadManager:GetStatus())
print("[BLOXY HUB] ====================================")
