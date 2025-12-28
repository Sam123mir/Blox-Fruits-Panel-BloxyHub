--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  BLOX FRUITS PANEL | BLOXY HUB TITANIUM V7.1               ║
    ║  Arquitectura Modular Profesional | Diseñado por Sammir    ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE VERSIÓN Y VALIDACIÓN
-- ═══════════════════════════════════════════════════════════════

getgenv().BloxyHub = getgenv().BloxyHub or {}
local VERSION = "6.0.0"
-- Reemplaza este link con tu link RAW de GitHub (donde esté tu versión escrita)
local GITHUB_RAW = "https://raw.githubusercontent.com/Sam123mir/BloxyHub/refs/heads/main/version.txt"

-- ═══════════════════════════════════════════════════════════════
-- FEEDBACK INICIAL (MÓVIL / PC)
-- ═══════════════════════════════════════════════════════════════

print("[BLOXY HUB] Iniciando sistema...")

-- Destruir pantalla de carga residual de ejecuciones previas
pcall(function()
    local player = game:GetService("Players").LocalPlayer
    local gui = player:FindFirstChild("PlayerGui"):FindFirstChild("BloxyLoading")
    if gui then gui:Destroy() end
end)

local function UpdateLoading(text)
    -- Deprecated: Now prints instead of updating UI
    print("[BLOXY HUB] " .. text)
end

if getgenv().BloxyHub.Active then
    warn("[BLOXY HUB] Ya hay una instancia activa. Cerrando instancia anterior...")
    if getgenv().BloxyHub.Shutdown then
        pcall(getgenv().BloxyHub.Shutdown)
    end
    task.wait(1)
end

UpdateLoading("Servicios...")

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: THREAD MANAGER (Gestión de Ciclo de Vida)
-- ═══════════════════════════════════════════════════════════════

local ThreadManager = {
    Threads = {},
    Active = true
}

function ThreadManager:Register(name, func)
    if not self.Active then return end
    
    local thread = task.spawn(function()
        local success, err = pcall(function()
            while self.Active and self.Threads[name] do
                local s, e = pcall(func)
                if not s then
                    local errorMsg = string.format("[THREAD ERROR: %s] %s", name, tostring(e))
                    warn(errorMsg)
                    if LogSystem then LogSystem:Add(tostring(e), "FATAL:"..name) end
                end
                task.wait()
            end
        end)
        
        if not success then
            warn(string.format("[THREAD FATAL: %s] %s", name, tostring(err)))
        end
    end)
    
    self.Threads[name] = {
        thread = thread,
        startTime = os.time(),
        status = "running"
    }
    
    return name
end

function ThreadManager:Stop(name)
    if self.Threads[name] then
        self.Threads[name].status = "stopped"
        self.Threads[name] = nil
    end
end

function ThreadManager:StopAll()
    self.Active = false
    for name, data in pairs(self.Threads) do
        data.status = "stopped"
    end
    self.Threads = {}
end

function ThreadManager:GetStatus()
    local active = 0
    for _, data in pairs(self.Threads) do
        if data.status == "running" then
            active = active + 1
        end
    end
    return active
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: SERVICIOS Y VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════════

local Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TeleportService = game:GetService("TeleportService"),
    RunService = game:GetService("RunService"),
    Stats = game:GetService("Stats"),
    VirtualUser = game:GetService("VirtualUser"),
    UserInputService = game:GetService("UserInputService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid, HumanoidRootPart

-- Función para asegurar que las referencias del personaje estén actualizadas
local function UpdateCharacterReferences(newChar)
    Character = newChar or LocalPlayer.Character
    if Character then
        Humanoid = Character:WaitForChild("Humanoid", 10)
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
    end
end

-- UpdateLoading("Personaje...")
task.spawn(function()
    if not Character then 
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    UpdateCharacterReferences(Character)
end)

LocalPlayer.CharacterAdded:Connect(UpdateCharacterReferences)

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: CONFIGURACIÓN ELITE
-- ═══════════════════════════════════════════════════════════════

-- UpdateLoading("Configuración...")
local Config = {
    -- Auto Farming
    AutoFarm = {
        Enabled = false,
        Mode = "Level", -- Level, Mastery, Boss
        Distance = 15,
        SafeMode = true,
        FastMode = false
    },
    
    -- Auto Mastery
    Mastery = {
        Enabled = false,
        Weapon = "Combat", -- Combat, Sword, Fruit, Gun
        FinishAtHealth = 20, -- Porcentaje
        UseSkills = true
    },
    
    -- Auto Stats
    Stats = {
        Enabled = false,
        Distribution = {
            Melee = false,
            Defense = false,
            Sword = false,
            Gun = false,
            ["Blox Fruit"] = false
        },
        SmartMode = true -- Distribuir equitativamente
    },
    
    -- Combat Settings
    Combat = {
        FastAttack = false,
        AttackSpeed = 0.05,
        KillAura = false,
        Range = 50,
        AutoEquipWeapon = true,
        ClickSimulation = true
    },
    
    -- Performance & Security
    Performance = {
        CPUMode = false,
        WhiteScreen = false,
        FPSBoost = false,
        UIRefreshRate = 1.0, -- Throttling suggested in report
    },

    Quest = {
        CurrentQuest = nil,
        CurrentNPC = nil,
        QuestName = nil,
        QuestEnemy = nil,
        TargetLvl = 1
    },

    Security = {
        AntiAFK = true,
        AdminDetector = false,
        AutoLeaveOnAdmin = true,
        StaffGroupId = 2440505
    },
    
    -- PvP & AI Settings
    PvP = {
        Enabled = false,
        AutoPvP = false,
        MaxKills = 1,
        TargetPlayer = nil,
        KillCount = 0
    },
    
    -- AI Mastery Settings
    AIMastery = {
        Enabled = false,
        Mode = "IA", -- IA, Manual
        SelectedWeapon = "Combat",
        Skills = {Z = true, X = true, C = true, V = true}
    },
    
    -- Player Settings
    Player = {
        AutoAura = false,
        InfiniteSkyjump = false,
        WalkSpeed = 16,
        JumpPower = 50
    },
    
    -- UI Settings
    UI = {
        Theme = "Dark", -- Dark, Light, Amoled
        Language = "Spanish", -- Spanish, English, Portuguese
        Notifications = true,
        StatusBar = true,
        MinimizeSymbol = "−"
    }
}

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: LOCALIZACIÓN (i18n)
-- ═══════════════════════════════════════════════════════════════

local I18n = {
    Dictionary = {
        ["Spanish"] = {
            ["Dashboard"] = "Dashboard",
            ["Farming"] = "Farming",
            ["Combate"] = "Combate",
            ["Personaje"] = "Personaje",
            ["Stats"] = "Stats",
            ["Rendimiento"] = "Rendimiento",
            ["Seguridad"] = "Seguridad",
            ["Historial"] = "Historial",
            ["Ajustes"] = "Ajustes",
            ["BIENVENIDO"] = "💎 BIENVENIDO A TITANIUM ELITE",
            ["WelcomeContent"] = "El script de Blox Fruits más avanzado y con IA profesional.",
            ["EstadoScript"] = "Estado del Script",
            ["SesionStats"] = "Estadísticas de Sesión",
            ["MundoActual"] = "Mundo Actual",
            ["AutoFarm"] = "🔥 Auto Farmear",
            ["AutoFarmLvl"] = "Auto Farmear (Nivel)",
            ["SeleccionarArma"] = "Seleccionar Arma",
            ["ModoIA"] = "Modo IA (Habilidades Inteligentes)",
            ["Habilidades"] = "Selección de Habilidades",
            ["UsarHabilidad"] = "Usar Habilidad",
            ["PvPPro"] = "⚔️ Modo PvP Profesional",
            ["ActivarPvP"] = "Activar Modo PvP",
            ["AutoPvPIA"] = "Auto PvP (IA Pro)",
            ["MaxObjects"] = "Número de Objetivos a Eliminar",
            ["TeleportPlayer"] = "📍 Teletransporte a Jugador",
            ["SelectPlayer"] = "Seleccionar Jugador",
            ["TPToPlayer"] = "🚀 Teletransportarse al Jugador",
            ["RefreshPlayers"] = "🔄 Actualizar Lista de Jugadores",
            ["MobilityEnhancements"] = "Mejoras de Combate y Movilidad",
            ["AutoAura"] = "✨ Auto Aura (Haki)",
            ["InfiniteSkyjump"] = "🕊️ Salto Infinito (Skyjump)",
            ["SpeedJump"] = "Velocidad y Salto",
            ["WalkSpeed"] = "Velocidad de Caminado",
            ["JumpPower"] = "Poder de Salto",
            ["StatDistribution"] = "Distribución de Estadísticas",
            ["AutoStatsLoop"] = "📊 Auto Stats (Bucle)",
            ["ApplyPoints"] = "⚡ Aplicar Puntos Ahora",
            ["PerformanceOptimization"] = "Optimización de Rendimiento",
            ["CPUMode"] = "💻 Modo CPU (Remover Texturas)",
            ["WhiteScreen"] = "⚪ Pantalla Blanca (Máximo FPS)",
            ["FPSBoost"] = "🚀 FPS Boost",
            ["ProtectionAntiBan"] = "Protección y Anti-Ban",
            ["AntiAFK"] = "🔄 Anti-AFK",
            ["AdminDetector"] = "👁️ Detector de Admins",
            ["AutoLeaveAdmin"] = "🚪 Auto-Leave al Detectar Admin",
            ["SystemDebug"] = "Depuración del Sistema",
            ["ActivityLog"] = "Registro de Actividad",
            ["ClearHistory"] = "🧹 Limpiar Historial",
            ["CopyClipboard"] = "📋 Copiar Logs al Portapapeles",
            ["Configuracion"] = "Configuración General",
            ["Tema"] = "Tema de la UI",
            ["Idioma"] = "Idioma del Panel",
            ["Notificaciones"] = "Notificaciones",
            ["Transparencia"] = "Efecto de Transparencia (Acrylic)",
            ["ReiniciarPanel"] = "Reiniciar Bloxy Hub",
            ["CerrarScript"] = "Cerrar Script por Completo",
            ["IdiomaCambiado"] = "Idioma cambiado correctamente. Reinicia para aplicar todos los cambios.",
            ["RestartRequired"] = "Reinicio Requerido",
            ["WaitingData"] = "Esperando Datos...",
            ["SessionStarted"] = "Sesión Iniciada",
            ["ReadyFarm"] = "Listo para farmear",
            ["Restating3s"] = "Reiniciando en 3 segundos...",
            ["LoadedSuccess"] = "Blox Fruits Panel cargado con éxito. ¡Buen farm!"
        },
        ["English"] = {
            ["Dashboard"] = "Dashboard",
            ["Farming"] = "Farming",
            ["Combate"] = "Combat",
            ["Personaje"] = "Player",
            ["Stats"] = "Stats",
            ["Rendimiento"] = "Performance",
            ["Seguridad"] = "Security",
            ["Historial"] = "Logs",
            ["Ajustes"] = "Settings",
            ["BIENVENIDO"] = "💎 WELCOME TO TITANIUM ELITE",
            ["WelcomeContent"] = "The most advanced Blox Fruits script with professional AI.",
            ["EstadoScript"] = "Script Status",
            ["SesionStats"] = "Session Statistics",
            ["MundoActual"] = "Current World",
            ["AutoFarm"] = "🔥 Auto Farming",
            ["AutoFarmLvl"] = "Auto Farm (Level)",
            ["SeleccionarArma"] = "Select Weapon",
            ["ModoIA"] = "AI Mode (Smart Skills)",
            ["Habilidades"] = "Skill Selection",
            ["UsarHabilidad"] = "Use Skill",
            ["PvPPro"] = "⚔️ Professional PvP Mode",
            ["ActivarPvP"] = "Enable PvP Mode",
            ["AutoPvPIA"] = "Auto PvP (Pro AI)",
            ["MaxObjects"] = "Number of Targets to Eliminate",
            ["TeleportPlayer"] = "📍 Player Teleport",
            ["SelectPlayer"] = "Select Player",
            ["TPToPlayer"] = "🚀 Teleport to Player",
            ["RefreshPlayers"] = "🔄 Refresh Player List",
            ["MobilityEnhancements"] = "Combat & Mobility Enhancements",
            ["AutoAura"] = "✨ Auto Aura (Haki)",
            ["InfiniteSkyjump"] = "🕊️ Infinite Skyjump",
            ["SpeedJump"] = "Speed & Jump",
            ["WalkSpeed"] = "Walk Speed",
            ["JumpPower"] = "Jump Power",
            ["StatDistribution"] = "Stat Distribution",
            ["AutoStatsLoop"] = "📊 Auto Stats (Loop)",
            ["ApplyPoints"] = "⚡ Apply Points Now",
            ["PerformanceOptimization"] = "Performance Optimization",
            ["CPUMode"] = "💻 CPU Mode (Remove Textures)",
            ["WhiteScreen"] = "⚪ White Screen (Max FPS)",
            ["FPSBoost"] = "🚀 FPS Boost",
            ["ProtectionAntiBan"] = "Protection & Anti-Ban",
            ["AntiAFK"] = "🔄 Anti-AFK",
            ["AdminDetector"] = "👁️ Admin Detector",
            ["AutoLeaveAdmin"] = "🚪 Auto-Leave on Admin Detected",
            ["SystemDebug"] = "System Debug",
            ["ActivityLog"] = "Activity Log",
            ["ClearHistory"] = "🧹 Clear History",
            ["CopyClipboard"] = "📋 Copy Logs to Clipboard",
            ["Configuracion"] = "General Configuration",
            ["Tema"] = "UI Theme",
            ["Idioma"] = "Panel Language",
            ["Notificaciones"] = "Notifications",
            ["Transparencia"] = "Transparency Effect (Acrylic)",
            ["ReiniciarPanel"] = "Restart Bloxy Hub",
            ["CerrarScript"] = "Close Script Completely",
            ["IdiomaCambiado"] = "Language changed successfully. Restart to apply all changes.",
            ["RestartRequired"] = "Restart Required",
            ["WaitingData"] = "Waiting for Data...",
            ["SessionStarted"] = "Session Started",
            ["ReadyFarm"] = "Ready to farm",
            ["Restating3s"] = "Restarting in 3 seconds...",
            ["LoadedSuccess"] = "Blox Fruits Panel loaded successfully. Happy farming!"
        },
        ["Portuguese"] = {
            ["Dashboard"] = "Dashboard",
            ["Farming"] = "Farming",
            ["Combate"] = "Combate",
            ["Personaje"] = "Personagem",
            ["Stats"] = "Stats",
            ["Rendimiento"] = "Desempenho",
            ["Seguridad"] = "Segurança",
            ["Historial"] = "Histórico",
            ["Ajustes"] = "Ajustes",
            ["BIENVENIDO"] = "💎 BEM-VINDO AO TITANIUM ELITE",
            ["WelcomeContent"] = "O script de Blox Fruits mais avançado com IA profissional.",
            ["EstadoScript"] = "Status do Script",
            ["SesionStats"] = "Estatísticas da Sessão",
            ["MundoActual"] = "Mundo Atual",
            ["AutoFarm"] = "🔥 Auto Farmar",
            ["AutoFarmLvl"] = "Auto Farmar (Nível)",
            ["SeleccionarArma"] = "Selecionar Arma",
            ["ModoIA"] = "Modo IA (Habilidades Inteligentes)",
            ["Habilidades"] = "Seleção de Habilidades",
            ["UsarHabilidad"] = "Usar Habilidade",
            ["PvPPro"] = "⚔️ Modo PvP Profissional",
            ["ActivarPvP"] = "Ativar Modo PvP",
            ["AutoPvPIA"] = "Auto PvP (IA Pro)",
            ["MaxObjects"] = "Número de Objetivos a Eliminar",
            ["TeleportPlayer"] = "📍 Teletransporte para Jogador",
            ["SelectPlayer"] = "Selecionar Jogador",
            ["TPToPlayer"] = "🚀 Teletransporte para Jogador",
            ["RefreshPlayers"] = "🔄 Atualizar Lista de Jogadores",
            ["MobilityEnhancements"] = "Melhorias de Combate e Mobilidade",
            ["AutoAura"] = "✨ Auto Aura (Haki)",
            ["InfiniteSkyjump"] = "🕊️ Salto Infinito (Skyjump)",
            ["SpeedJump"] = "Velocidade e Salto",
            ["WalkSpeed"] = "Velocidade de Caminhada",
            ["JumpPower"] = "Poder de Salto",
            ["StatDistribution"] = "Distribuição de Estatísticas",
            ["AutoStatsLoop"] = "📊 Auto Stats (Loop)",
            ["ApplyPoints"] = "⚡ Aplicar Pontos Agora",
            ["PerformanceOptimization"] = "Otimização de Desempenho",
            ["CPUMode"] = "💻 Modo CPU (Remover Texturas)",
            ["WhiteScreen"] = "⚪ Tela Branca (FPS Máximo)",
            ["FPSBoost"] = "🚀 FPS Boost",
            ["ProtectionAntiBan"] = "Proteção e Anti-Ban",
            ["AntiAFK"] = "🔄 Anti-AFK",
            ["AdminDetector"] = "👁️ Detector de Admins",
            ["AutoLeaveAdmin"] = "🚪 Auto-Sair ao Detectar Admin",
            ["SystemDebug"] = "Depuração do Sistema",
            ["ActivityLog"] = "Registro de Atividade",
            ["ClearHistory"] = "🧹 Limpar Histórico",
            ["CopyClipboard"] = "📋 Copiar Logs para a Área de Transferência",
            ["Configuracion"] = "Configuração Geral",
            ["Tema"] = "Tema da UI",
            ["Idioma"] = "Idioma do Painel",
            ["Notificaciones"] = "Notificações",
            ["Transparencia"] = "Efeito de Transparência (Acrylic)",
            ["ReiniciarPanel"] = "Reiniciar Bloxy Hub",
            ["CerrarScript"] = "Fechar Script Completamente",
            ["IdiomaCambiado"] = "Idioma alterado com sucesso. Reinicie para aplicar todas as mudanças.",
            ["RestartRequired"] = "Reinicialização Necesária",
            ["WaitingData"] = "Aguardando Dados...",
            ["SessionStarted"] = "Sessão Iniciada",
            ["ReadyFarm"] = "Pronto para farmar",
            ["Restating3s"] = "Reiniciando em 3 segundos...",
            ["LoadedSuccess"] = "Blox Fruits Panel carregado com sucesso. Bom farm!"
        }
    }
}

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: SESIÓN Y ESTADÍSTICAS
-- ═══════════════════════════════════════════════════════════════

-- UpdateLoading("Módulos...")
local Farming = {}
local Session = {
    StartTime = os.time(),
    StartLevel = 0,
    StartBeli = 0,
    StartFragments = 0,
    
    LevelsGained = 0,
    BeliEarned = 0,
    FragmentsEarned = 0,
    MobsKilled = 0,
    BossesKilled = 0,
    
    Uptime = "00:00:00",
    Ping = 0,
    FPS = 60,
    Status = Utils:Translate("WaitingData")
}

-- Inicialización segura de estadísticas (Móvil)
task.spawn(function()
    local data = LocalPlayer:WaitForChild("Data", 20)
    if data then
        Session.StartLevel = data:WaitForChild("Level", 10).Value
        Session.StartBeli = data:WaitForChild("Beli", 10).Value
        Session.StartFragments = data:WaitForChild("Fragments", 10).Value
        Session.Status = Utils:Translate("SessionStarted")
    end
end)

function Session:Update()
    pcall(function()
        local elapsed = os.time() - self.StartTime
        local hours = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local secs = elapsed % 60
        
        self.Uptime = string.format("%02d:%02d:%02d", hours, mins, secs)
        
        if LocalPlayer:FindFirstChild("Data") then
            if LocalPlayer.Data:FindFirstChild("Level") then self.LevelsGained = LocalPlayer.Data.Level.Value - self.StartLevel end
            if LocalPlayer.Data:FindFirstChild("Beli") then self.BeliEarned = LocalPlayer.Data.Beli.Value - self.StartBeli end
            if LocalPlayer.Data:FindFirstChild("Fragments") then self.FragmentsEarned = LocalPlayer.Data.Fragments.Value - self.StartFragments end
        end
        
        -- Ping y FPS ultra-seguros
        local successPing, pingVal = pcall(function() return Services.Stats.Network.ServerStatsItem:FindFirstChild("Data Ping"):GetValue() end)
        if successPing then self.Ping = math.floor(pingVal) end
        
        local successFPS, fpsVal = pcall(function() return Services.Stats.FrameRateManager:FindFirstChild("RenderAverage"):GetValue() end)
        if successFPS then self.FPS = math.floor(fpsVal) end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: SISTEMA DE LOGS (Depuración Pro)
-- ═══════════════════════════════════════════════════════════════

local LogSystem = {
    Entries = {},
    MaxEntries = 50,
    UIElement = nil
}

function LogSystem:Add(msg, logType)
    logType = logType or "INFO"
    local timestamp = os.date("%H:%M:%S")
    local entry = string.format("[%s] [%s] %s", timestamp, logType, msg)
    
    table.insert(self.Entries, 1, entry)
    if #self.Entries > self.MaxEntries then
        table.remove(self.Entries)
    end
    
    if self.UIElement then
        self:RefreshUI()
    end
end

function LogSystem:RefreshUI()
    if self.UIElement then
        local content = table.concat(self.Entries, "\n")
        self.UIElement:SetTitle("Registro de Actividad (Últimos 50)")
        self.UIElement:SetContent(content == "" and "No hay logs registrados." or content)
    end
end

function LogSystem:Clear()
    self.Entries = {}
    self:RefreshUI()
end

-- Captura automática de errores del script
game:GetService("LogService").MessageOut:Connect(function(msg, messageType)
    if messageType == Enum.MessageType.MessageError then
        if string.find(msg, "Bloxy") or string.find(msg, "Titanium") then
            LogSystem:Add(msg, "ERROR")
        end
    end
end)

-- Redundancia eliminada

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: UTILIDADES Y HELPERS
-- ═══════════════════════════════════════════════════════════════

local Utils = {}

function Utils:GetClosestEnemy(maxDistance)
    maxDistance = maxDistance or 500
    local closest = nil
    local closestDist = maxDistance
    
    for _, enemy in pairs(Services.Workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
            local dist = (HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closest = enemy
                closestDist = dist
            end
        end
    end
    
    return closest, closestDist
end

function Utils:GetEnemiesInRange(range)
    local enemies = {}
    for _, enemy in pairs(Services.Workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
            local dist = (HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if dist <= range then
                table.insert(enemies, enemy)
            end
        end
    end
    return enemies
end

function Utils:TeleportTo(cframe, safeMode)
    if not HumanoidRootPart then return end
    
    if safeMode then
        -- Teletransporte seguro con offset Y
        local targetCFrame = cframe * CFrame.new(0, Config.AutoFarm.Distance, 0)
        HumanoidRootPart.CFrame = targetCFrame
    else
        HumanoidRootPart.CFrame = cframe
    end
end

function Utils:GetEnemyByName(name)
    local enemies = game:GetService("Workspace").Enemies:GetChildren()
    for _, enemy in ipairs(enemies) do
        if enemy.Name == name and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            return enemy
        end
    end
    return nil
end

function Utils:IsLagging()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    return ping > 500 -- Lag extremo
end

function Utils:Equip(toolName)
    pcall(function()
        if toolName == "Melee" then
            for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                if t:IsA("Tool") and (t.ToolTip == "Melee" or t.Name == "Combat" or t:FindFirstChild("Combat")) then
                    Humanoid:EquipTool(t)
                    return
                end
            end
            for _, t in pairs(Character:GetChildren()) do
                if t:IsA("Tool") and (t.ToolTip == "Melee" or t.Name == "Combat" or t:FindFirstChild("Combat")) then
                    return
                end
            end
        else
            local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or Character:FindFirstChild(toolName)
            if tool then
                Humanoid:EquipTool(tool)
            else
                -- Búsqueda por tipo si no encuentra el nombre exacto
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name, toolName) then
                        Humanoid:EquipTool(t)
                        return
                    end
                end
            end
        end
    end)
end

function Utils:GetCurrentWorld()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1, "First Sea"
    elseif placeId == 4442272183 then return 2, "Second Sea"
    elseif placeId == 7449423635 then return 3, "Third Sea"
    else return 0, "Unknown" end
end

function Utils:Notify(title, message, duration)
    if not Config.UI.Notifications then return end
    
    if Fluent then
        Fluent:Notify({
            Title = title,
            Content = message,
            Duration = duration or 3
        })
    end
end

function Utils:Translate(key)
    local lang = Config.UI.Language or "Spanish"
    local dict = I18n.Dictionary[lang] or I18n.Dictionary["Spanish"]
    return dict[key] or key
end

-- // MÓDULO: INTELIGENCIA ARTIFICIAL (COMBATE PRO)
local AI = {
    IsUsingSkill = false,
    CurrentSkillIndex = 1,
    SkillKeys = {"z", "x", "c", "v"}
}

function AI:UseSkills(targetType)
    if not Config.AIMastery.Enabled and not Config.PvP.AutoPvP then return end
    if self.IsUsingSkill then return end
    
    task.spawn(function()
        self.IsUsingSkill = true
        
        -- Rotación profesional de habilidades
        for _, key in ipairs(self.SkillKeys) do
            local upperKey = key:upper()
            if Config.AIMastery.Skills[upperKey] then
                Session.Status = "IA: Usando habilidad " .. upperKey
                -- Usar habilidad de forma profesional
                Services.VirtualUser:SetKeyDown(key)
                task.wait(0.15)
                Services.VirtualUser:SetKeyUp(key)
                task.wait(0.1) -- Delay entre habilidades para no buguear
            end
        end
        
        Session.Status = "IA: Recargando habilidades..."
        task.wait(0.5) -- Cool-down global de la IA
        self.IsUsingSkill = false
    end)
end

function AI:HandlePvP()
    if not Config.PvP.AutoPvP then return end
    
    local targetName = Config.PvP.TargetPlayer
    local target = targetName and Services.Players:FindFirstChild(targetName)
    
    if target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
        local targetHRP = target.Character.HumanoidRootPart
        
        -- Movimiento profesional (IA STRAFE)
        -- Orbita alrededor del objetivo para evitar ataques
        local time = tick()
        local orbitDistance = 8
        local orbitSpeed = 4
        local offset = Vector3.new(math.cos(time * orbitSpeed) * orbitDistance, 5, math.sin(time * orbitSpeed) * orbitDistance)
        
        Utils:TeleportTo(CFrame.new(targetHRP.Position + offset, targetHRP.Position))
        
        -- Ataque y Habilidades
        Session.Status = "PvP IA: Atacando a " .. target.Name
        Combat:FastAttack()
        self:UseSkills("PvP")
        
        -- Verificar si murió para el contador
        if target.Character.Humanoid.Health <= 0 then
            Config.PvP.KillCount = Config.PvP.KillCount + 1
            Utils:Notify("PvP", "Objetivo eliminado (" .. Config.PvP.KillCount .. "/" .. Config.PvP.MaxKills .. ")", 3)
            
            if Config.PvP.KillCount >= Config.PvP.MaxKills then
                Config.PvP.AutoPvP = false
                Config.PvP.Enabled = false
                Config.PvP.KillCount = 0
                Utils:Notify("PvP", "Límite de bajas alcanzado. Modo PvP desactivado.", 5)
            end
        end
    else
        Session.Status = "Buscando objetivo PvP..."
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: COMBAT SYSTEM (Sistema de Combate Avanzado)
-- ═══════════════════════════════════════════════════════════════

local Combat = {}

function Combat:FastAttack()
    if not Config.Combat.FastAttack then return end
    
    pcall(function()
        local combat = Services.ReplicatedStorage.Remotes:FindFirstChild("Validator")
        local commF = Services.ReplicatedStorage.Remotes.CommF_
        
        if combat then
            combat:FireServer("Combat", Character)
        end
        
        if commF and Config.Combat.ClickSimulation then
            Services.VirtualUser:CaptureController()
            Services.VirtualUser:Button1Down(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
        end
    end)
end

function Combat:AttackEnemy(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return end
    if Utils:IsLagging() then 
        Session.Status = "Lag detectado - Pausando..."
        return 
    end
    
    pcall(function()
        local enemyHRP = enemy.HumanoidRootPart
        local dist = (Character.HumanoidRootPart.Position - enemyHRP.Position).Magnitude
        
        -- Solo teletransportar si estamos lejos (Optimización Reporte Técnico)
        if dist > 15 then
            Utils:TeleportTo(enemyHRP.CFrame * CFrame.new(0, 10, 0), Config.AutoFarm.SafeMode)
        end
        
        -- Ejecutar ataques rápidos (Throttling)
        self:FastAttack()
        
        -- Actualizar estadísticas al morir
        if enemy.Humanoid.Health <= 0 then
            Session.MobsKilled = Session.MobsKilled + 1
        end
    end)
end

function Combat:ExecuteMasteryFinisher(enemy)
    if not Config.Mastery.Enabled or not enemy then return end
    
    pcall(function()
        local healthPercent = (enemy.Humanoid.Health / enemy.Humanoid.MaxHealth) * 100
        
        if healthPercent <= Config.Mastery.FinishAtHealth then
            local weaponName = Config.Mastery.Weapon
            local weapon = LocalPlayer.Backpack:FindFirstChild(weaponName) or Character:FindFirstChild(weaponName)
            
            if weapon and Humanoid then
                Humanoid:EquipTool(weapon)
                task.wait(0.1)
                
                if Config.Mastery.UseSkills then
                    Services.VirtualUser:SetKeyDown("z")
                    task.wait(0.15)
                    Services.VirtualUser:SetKeyUp("z")
                end
            end
        end
    end)
end

function Combat:KillAura()
    if not Config.Combat.KillAura then return end
    
    local enemies = Utils:GetEnemiesInRange(Config.Combat.Range)
    for _, enemy in ipairs(enemies) do
        self:AttackEnemy(enemy)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: QUEST DATA (Base de Datos de Misiones)
-- ═══════════════════════════════════════════════════════════════

local QuestData = {
    [1] = { -- First Sea
        {NPC = "Bandit Quest Giver", Quest = "BanditQuest1", Enemy = "Bandit", Level = 0, CFrame = CFrame.new(1059, 15, 1549)},
        {NPC = "Monkey Quest Giver", Quest = "MonkeyQuest1", Enemy = "Monkey", Level = 10, CFrame = CFrame.new(-1598, 37, 153)},
        {NPC = "Monkey Quest Giver", Quest = "GorillaQuest1", Enemy = "Gorilla", Level = 15, CFrame = CFrame.new(-1598, 37, 153)},
        {NPC = "Pirate Quest Giver", Quest = "PirateQuest1", Enemy = "Pirate", Level = 35, CFrame = CFrame.new(-1140, 4, 3828)},
        {NPC = "Pirate Quest Giver", Quest = "BruteQuest1", Enemy = "Brute", Level = 45, CFrame = CFrame.new(-1140, 4, 3828)},
        {NPC = "Desert Quest Giver", Quest = "DesertQuest1", Enemy = "Desert Bandit", Level = 60, CFrame = CFrame.new(894, 6, 4390)},
        {NPC = "Desert Quest Giver", Quest = "DesertQuest2", Enemy = "Desert Officer", Level = 75, CFrame = CFrame.new(894, 6, 4390)},
        {NPC = "Snow Quest Giver", Quest = "SnowQuest1", Enemy = "Snow Bandit", Level = 90, CFrame = CFrame.new(1389, 7, -1297)},
        {NPC = "Snow Quest Giver", Quest = "SnowQuest2", Enemy = "Snowman", Level = 100, CFrame = CFrame.new(1389, 7, -1297)},
        {NPC = "Chef Shipwright Quest Giver", Quest = "ShipwrightQuest1", Enemy = "Shipwright Cook", Level = 120, CFrame = CFrame.new(-1154, 7, -2708)},
    },
    [2] = { -- Second Sea
        {NPC = "Quest Giver", Quest = "RaiderQuest1", Enemy = "Raider", Level = 700, CFrame = CFrame.new(-426, 73, 1836)},
        {NPC = "Quest Giver", Quest = "RaiderQuest2", Enemy = "Mercenary", Level = 725, CFrame = CFrame.new(-426, 73, 1836)},
        {NPC = "Quest Giver", Quest = "SwanQuest1", Enemy = "Swan Pirate", Level = 775, CFrame = CFrame.new(-628, 15, 1572)},
        {NPC = "Quest Giver", Quest = "SwanQuest2", Enemy = "Factory Worker", Level = 800, CFrame = CFrame.new(-628, 15, 1572)},
        {NPC = "Quest Giver", Quest = "MagmaQuest1", Enemy = "Military Soldier", Level = 1100, CFrame = CFrame.new(-5437, 56, -4296)},
    },
    [3] = { -- Third Sea
        {NPC = "Quest Giver", Quest = "MarineQuest1", Enemy = "Marine Cadet", Level = 1500, CFrame = CFrame.new(-9506, 164, 5786)},
        {NPC = "Quest Giver", Quest = "MarineQuest2", Enemy = "Marine Captain", Level = 1525, CFrame = CFrame.new(-9506, 164, 5786)},
        {NPC = "Quest Giver", Quest = "SnakeQuest1", Enemy = "Dragon Crew Warrior", Level = 1600, CFrame = CFrame.new(-10524, 75, -7860)},
    }
}

function Farming:GetBestQuest()
    local myLvl = LocalPlayer.Data.Level.Value
    local world, _ = Utils:GetCurrentWorld()
    local worldQuests = QuestData[world] or {}
    
    local best = worldQuests[1]
    for _, q in ipairs(worldQuests) do
        if myLvl >= q.Level then
            best = q
        end
    end
    return best
end

function Farming:CheckQuest()
    local questName = LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
    if questName and questName.Visible then
        return true
    end
    return false
end

function Farming:TakeQuest()
    if self:CheckQuest() then return end
    
    local best = self:GetBestQuest()
    if not best then return end
    
    Session.Status = "Viajando a NPC: " .. best.NPC
    Utils:TeleportTo(best.CFrame)
    
    -- Interactuar con NPC (Simplificado por Remoto si es posible o Click)
    pcall(function()
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", best.Quest, 1)
    end)
end

function Farming:AutoLevel()
    if not Config.AutoFarm.Enabled or Config.AutoFarm.Mode ~= "Level" then return end
    
    if not self:CheckQuest() then
        self:TakeQuest()
        return
    end
    
    local best = self:GetBestQuest()
    local enemy = Utils:GetEnemyByName(best.Enemy) or Utils:GetClosestEnemy(1000)
    
    if enemy then
        Utils:Equip("Melee")
        Combat:AttackEnemy(enemy)
        
        if Config.Mastery.Enabled then
            Combat:ExecuteMasteryFinisher(enemy)
        end
    else
        Session.Status = "Esperando respawn de " .. best.Enemy
    end
end

function Farming:AutoMastery()
    if not Config.Mastery.Enabled then return end
    
    local enemy = Utils:GetClosestEnemy(500)
    
    if enemy then
        Combat:AttackEnemy(enemy)
        Combat:ExecuteMasteryFinisher(enemy)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: AUTO STATS SYSTEM
-- ═══════════════════════════════════════════════════════════════

local StatsManager = {}

function StatsManager:DistributePoints(manual)
    if not Config.Stats.Enabled and not manual then return end
    
    local success, err = pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if not data then return end
        
        local pointsVal = data:FindFirstChild("StatsPoints") or data:FindFirstChild("Points")
        if not pointsVal or pointsVal.Value <= 0 then 
            if manual then Utils:Notify("Stats", "No tienes puntos disponibles", 2) end
            return 
        end
        
        local activeStats = {}
        for stat, enabled in pairs(Config.Stats.Distribution) do
            if enabled then table.insert(activeStats, stat) end
        end
        
        if #activeStats == 0 then 
            if manual then Utils:Notify("Stats", "Selecciona al menos una estadística", 2) end
            return 
        end
        
        local points = pointsVal.Value
        local pointsPerStat = math.floor(points / #activeStats)
        
        if pointsPerStat > 0 then
            for _, stat in ipairs(activeStats) do
                Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, pointsPerStat)
            end
            Utils:Notify("Stats", "Puntos distribuidos correctamente", 2)
        end
    end)
    
    if not success then
        warn("[STATS ERROR] " .. tostring(err))
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: PERFORMANCE OPTIMIZER
-- ═══════════════════════════════════════════════════════════════

local Performance = {}

function Performance:ApplyCPUMode()
    if not Config.Performance.CPUMode then return end
    
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end)
    end
    
    Utils:Notify("Performance", "Modo CPU activado - Texturas optimizadas", 3)
end

function Performance:ToggleWhiteScreen(enabled)
    Config.Performance.WhiteScreen = enabled
    Services.RunService:Set3dRenderingEnabled(not enabled)
    
    if enabled then
        Utils:Notify("Performance", "Pantalla blanca activada - FPS máximo", 3)
    end
end

function Performance:ApplyFPSBoost()
    if not Config.Performance.FPSBoost then return end
    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    for _, effect in pairs(game:GetService("Lighting"):GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: SECURITY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local Security = {}

function Security:AntiAFK()
    if not Config.Security.AntiAFK then return end
    
    Services.VirtualUser:CaptureController()
    Services.VirtualUser:ClickButton2(Vector2.new())
end

function Security:DetectAdmin()
    if not Config.Security.AdminDetector then return end
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local success, rank = pcall(function()
                return player:GetRankInGroup(Config.Security.StaffGroupId)
            end)
            
            if success and rank and rank >= 1 then
                Utils:Notify("⚠️ ALERTA", string.format("Admin detectado: %s", player.Name), 5)
                
                if Config.Security.AutoLeaveOnAdmin then
                    task.wait(1)
                    LocalPlayer:Kick(string.format("🛡️ BLOXY ELITE: Admin detectado (%s). Desconexión segura.", player.Name))
                end
                
                return true
            end
        end
    end
    
    return false
end

-- // MÓDULO: MEJORAS DEL JUGADOR
local PlayerExp = {}

function PlayerExp:AutoAura()
    if not Config.Player.AutoAura then return end
    
    pcall(function()
        local hasAura = false
        if Character and Character:FindFirstChild("HasBuso") then
            -- En algunas versiones de Blox Fruits hay un tag
            hasAura = true
        end
        
        -- Si no tiene el efecto visual o queremos asegurar, disparamos el remote
        -- El remote usualmente alterna el estado
        if not Character:FindFirstChild("IronBody") then -- IronBody es el nombre del efecto de Aura
            Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end
    end)
end

function PlayerExp:InfiniteSkyjump()
    if not Config.Player.InfiniteSkyjump then return end
    
    -- Escuchar saltos
    Services.UserInputService.JumpRequest:Connect(function()
        if Config.Player.InfiniteSkyjump and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: UI FLUENT (Interfaz Premium Titanium)
-- ═══════════════════════════════════════════════════════════════

-- UpdateLoading("Descargando Interfaz...")
local Fluent = nil
print("[BLOXY HUB] Intentando cargar Fluent UI...")
local s, e = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"))()
end)

if s and e then
    Fluent = e
    getgenv().Fluent = Fluent
    print("[BLOXY HUB] Fluent UI cargado correctamente.")
else
    print("[BLOXY HUB] Falló carga primaria de Fluent, intentando alternativa...")
    local s2, e2 = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)
    if s2 and e2 then
        Fluent = e2
        getgenv().Fluent = Fluent
        print("[BLOXY HUB] Fluent UI cargado desde link alternativo.")
    else
        warn("[BLOXY HUB] ERROR FATAL: No se pudo cargar Fluent UI. Revisa tu conexión.")
        return
    end
end

print("[BLOXY HUB] Cargando Addons...")
local SaveManager, InterfaceManager
pcall(function()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

print("[BLOXY HUB] Creando ventana...")
local Window
local successWindow, errorWindow = pcall(function()
    return Fluent:CreateWindow({
        Title = "Blox Fruits Panel 🏴‍☠️ | Bloxy Hub",
        SubTitle = "Titanium v7.4 by Sammir",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false, -- Desactivar acrílico globalmente para evitar fallos en algunos dispositivos
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl
    })
end)

if not successWindow then
    warn("[BLOXY HUB] Error al crear la ventana: " .. tostring(errorWindow))
    return
end
Window = errorWindow -- pcall returns result as second value if successful

-- ═══════════════════════════════════════════════════════════════
-- PESTAÑAS DE LA UI
-- ═══════════════════════════════════════════════════════════════

local Tabs = {
    Dashboard = Window:AddTab({ Title = Utils:Translate("Dashboard"), Icon = "layout" }),
    Farming = Window:AddTab({ Title = Utils:Translate("Farming"), Icon = "sword" }),
    Combat = Window:AddTab({ Title = Utils:Translate("Combate"), Icon = "zap" }),
    Player = Window:AddTab({ Title = Utils:Translate("Personaje"), Icon = "user" }),
    Stats = Window:AddTab({ Title = Utils:Translate("Stats"), Icon = "bar-chart" }),
    Performance = Window:AddTab({ Title = Utils:Translate("Rendimiento"), Icon = "cpu" }),
    Security = Window:AddTab({ Title = Utils:Translate("Seguridad"), Icon = "shield" }),
    Logs = Window:AddTab({ Title = Utils:Translate("Historial"), Icon = "file-text" }),
    Settings = Window:AddTab({ Title = Utils:Translate("Ajustes"), Icon = "settings" })
}

-- ═══════════════════════════════════════════════════════════════
-- TAB: DASHBOARD
-- ═══════════════════════════════════════════════════════════════

Tabs.Dashboard:AddParagraph({
    Title = Utils:Translate("BIENVENIDO"),
    Content = Utils:Translate("WelcomeContent")
})

local StatusLabel = Tabs.Dashboard:AddParagraph({
    Title = Utils:Translate("EstadoScript"),
    Content = "Cargando..."
})

local StatsLabel = Tabs.Dashboard:AddParagraph({
    Title = Utils:Translate("SesionStats"),
    Content = "Cargando..."
})

local WorldInfo = Tabs.Dashboard:AddParagraph({
    Title = Utils:Translate("MundoActual"),
    Content = "Detectando..."
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: FARMING
-- ═══════════════════════════════════════════════════════════════

local FarmingSection = Tabs.Farming:AddSection(Utils:Translate("AutoFarm"))

FarmingSection:AddToggle("AutoFarmToggle", {
    Title = Utils:Translate("AutoFarmLvl"),
    Default = Config.AutoFarm.Enabled,
    Callback = function(value)
        Config.AutoFarm.Enabled = value
        Config.AutoFarm.Mode = "Level"
    end
})

local MasterySection = Tabs.Farming:AddSection("----- Maestría -----")

MasterySection:AddToggle("MasteryToggle", {
    Title = "Auto Mastery",
    Default = Config.Mastery.Enabled,
    Callback = function(value)
        Config.Mastery.Enabled = value
    end
})

local MasteryWeaponDropdown = MasterySection:AddDropdown("MasteryWeaponSelect", {
    Title = Utils:Translate("SeleccionarArma"),
    Values = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Default = "Melee",
    Callback = function(option)
        Config.AIMastery.SelectedWeapon = option
    end
})

MasterySection:AddToggle("MasteryIA", {
    Title = Utils:Translate("ModoIA"),
    Default = Config.AIMastery.Enabled,
    Callback = function(value)
        Config.AIMastery.Enabled = value
    end
})

local SkillsSection = Tabs.Farming:AddSection(Utils:Translate("Habilidades"))

for _, key in ipairs({"Z", "X", "C", "V"}) do
    SkillsSection:AddToggle("Skill"..key, {
        Title = Utils:Translate("UsarHabilidad") .. " " .. key,
        Default = true,
        Callback = function(v) Config.AIMastery.Skills[key] = v end
    })
end

-- ═══════════════════════════════════════════════════════════════
-- TAB: COMBATE
-- ═══════════════════════════════════════════════════════════════

local PvPSection = Tabs.Combat:AddSection(Utils:Translate("PvPPro"))

PvPSection:AddToggle("PvPEnabled", {
    Title = Utils:Translate("ActivarPvP"),
    Default = Config.PvP.Enabled,
    Callback = function(value)
        Config.PvP.Enabled = value
    end
})

PvPSection:AddToggle("PvPAI", {
    Title = Utils:Translate("AutoPvPIA"),
    Default = Config.PvP.AutoPvP,
    Callback = function(value)
        Config.PvP.AutoPvP = value
    end
})

PvPSection:AddSlider("MaxKillsSlider", {
    Title = Utils:Translate("MaxObjects"),
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(v) Config.PvP.MaxKills = v end
})

local TeleportSection = Tabs.Combat:AddSection(Utils:Translate("TeleportPlayer"))

local PlayerList = {}
local function UpdatePlayerList()
    PlayerList = {}
    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(PlayerList, p.Name) end
    end
end
UpdatePlayerList()

local PlayerDropdown = TeleportSection:AddDropdown("PlayerTPSelect", {
    Title = Utils:Translate("SelectPlayer"),
    Values = PlayerList,
    Callback = function(pName)
        Config.PvP.TargetPlayer = pName
    end
})

TeleportSection:AddButton({
    Title = Utils:Translate("TPToPlayer"),
    Callback = function()
        if Config.PvP.TargetPlayer then
            local target = Services.Players:FindFirstChild(Config.PvP.TargetPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                Utils:TeleportTo(target.Character.HumanoidRootPart.CFrame)
                Utils:Notify("Teleport", "Teleported to " .. target.Name, 2)
            end
        end
    end
})

TeleportSection:AddButton({
    Title = Utils:Translate("RefreshPlayers"),
    Callback = function()
        UpdatePlayerList()
        PlayerDropdown:SetValues(PlayerList)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: PERSONAJE
-- ═══════════════════════════════════════════════════════════════

local MobilitySection = Tabs.Player:AddSection(Utils:Translate("MobilityEnhancements"))

MobilitySection:AddToggle("AutoAura", {
    Title = Utils:Translate("AutoAura"),
    Default = Config.Player.AutoAura,
    Callback = function(value)
        Config.Player.AutoAura = value
        if value then PlayerExp:AutoAura() end
    end
})

MobilitySection:AddToggle("InfiniteSkyjump", {
    Title = Utils:Translate("InfiniteSkyjump"),
    Default = Config.Player.InfiniteSkyjump,
    Callback = function(value)
        Config.Player.InfiniteSkyjump = value
        if value then PlayerExp:InfiniteSkyjump() end
    end
})

local SpeedSection = Tabs.Player:AddSection(Utils:Translate("SpeedJump"))

SpeedSection:AddSlider("WalkSpeed", {
    Title = Utils:Translate("WalkSpeed"),
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        Config.Player.WalkSpeed = value
    end
})

SpeedSection:AddSlider("JumpPower", {
    Title = Utils:Translate("JumpPower"),
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        Config.Player.JumpPower = value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: STATS
-- ═══════════════════════════════════════════════════════════════

local StatsSection = Tabs.Stats:AddSection(Utils:Translate("StatDistribution"))

StatsSection:AddToggle("StatMelee", {
    Title = "🥊 Melee",
    Default = Config.Stats.Distribution.Melee,
    Callback = function(value) Config.Stats.Distribution.Melee = value end
})

StatsSection:AddToggle("StatDefense", {
    Title = "🛡️ Defense",
    Default = Config.Stats.Distribution.Defense,
    Callback = function(value) Config.Stats.Distribution.Defense = value end
})

StatsSection:AddToggle("StatSword", {
    Title = "⚔️ Sword",
    Default = Config.Stats.Distribution.Sword,
    Callback = function(value) Config.Stats.Distribution.Sword = value end
})

StatsSection:AddToggle("StatGun", {
    Title = "🔫 Gun",
    Default = Config.Stats.Distribution.Gun,
    Callback = function(value) Config.Stats.Distribution.Gun = value end
})

StatsSection:AddToggle("StatFruit", {
    Title = "🍎 Blox Fruit",
    Default = Config.Stats.Distribution["Blox Fruit"],
    Callback = function(value) Config.Stats.Distribution["Blox Fruit"] = value end
})

StatsSection:AddToggle("AutoStatsToggle", {
    Title = Utils:Translate("AutoStatsLoop"),
    Default = Config.Stats.Enabled,
    Callback = function(value)
        Config.Stats.Enabled = value
    end
})

StatsSection:AddButton({
    Title = Utils:Translate("ApplyPoints"),
    Callback = function()
        StatsManager:DistributePoints(true)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: PERFORMANCE
-- ═══════════════════════════════════════════════════════════════

local PerfSection = Tabs.Performance:AddSection(Utils:Translate("PerformanceOptimization"))

PerfSection:AddToggle("CPUMode", {
    Title = Utils:Translate("CPUMode"),
    Default = Config.Performance.CPUMode,
    Callback = function(value)
        Config.Performance.CPUMode = value
        if value then Performance:ApplyCPUMode() end
    end
})

PerfSection:AddToggle("WhiteScreen", {
    Title = Utils:Translate("WhiteScreen"),
    Default = Config.Performance.WhiteScreen,
    Callback = function(value)
        Performance:ToggleWhiteScreen(value)
    end
})

PerfSection:AddToggle("FPSBoost", {
    Title = Utils:Translate("FPSBoost"),
    Default = Config.Performance.FPSBoost,
    Callback = function(value)
        Config.Performance.FPSBoost = value
        if value then Performance:ApplyFPSBoost() end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: SEGURIDAD
-- ═══════════════════════════════════════════════════════════════

local SecuritySection = Tabs.Security:AddSection(Utils:Translate("ProtectionAntiBan"))

SecuritySection:AddToggle("AntiAFK", {
    Title = Utils:Translate("AntiAFK"),
    Default = Config.Security.AntiAFK,
    Callback = function(value)
        Config.Security.AntiAFK = value
    end
})

SecuritySection:AddToggle("AdminDetector", {
    Title = Utils:Translate("AdminDetector"),
    Default = Config.Security.AdminDetector,
    Callback = function(value)
        Config.Security.AdminDetector = value
    end
})

SecuritySection:AddToggle("AutoLeave", {
    Title = Utils:Translate("AutoLeaveAdmin"),
    Default = Config.Security.AutoLeaveOnAdmin,
    Callback = function(value)
        Config.Security.AutoLeaveOnAdmin = value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: LOGS
-- ═══════════════════════════════════════════════════════════════

local LogSection = Tabs.Logs:AddSection(Utils:Translate("SystemDebug"))

LogSystem.UIElement = LogSection:AddParagraph({
    Title = Utils:Translate("ActivityLog"),
    Content = "Starting log system..."
})

LogSection:AddButton({
    Title = Utils:Translate("ClearHistory"),
    Callback = function()
        LogSystem:Clear()
    end
})

LogSection:AddButton({
    Title = Utils:Translate("CopyClipboard"),
    Callback = function()
        pcall(function()
            local allLogs = table.concat(LogSystem.Entries, "\n")
            
            -- Fix Portapapeles Robusto (Multi-método con fallback visual)
            local success = false
            local methods = {
                setclipboard, 
                toclipboard, 
                set_clipboard, 
                (Clipboard and Clipboard.set),
                function(text) -- Fallback para algunos ejecutores móviles
                    local box = Instance.new("TextBox")
                    box.Parent = game.CoreGui
                    box.Text = text
                    box.Visible = false
                    box:CaptureFocus()
                    return true
                end
            }
            
            for _, method in ipairs(methods) do
                if method then
                    local s, _ = pcall(function() method(allLogs) end)
                    if s then success = true break end
                end
            end
            
            if success then
                Utils:Notify("Logs", "Historial copiado al portapapeles", 2)
            else
                Utils:Notify("Error", "No se pudo copiar. Intenta manualmente.", 3)
            end
        end)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: AJUSTES
-- ═══════════════════════════════════════════════════════════════

local ConfigSection = Tabs.Settings:AddSection(Utils:Translate("Configuracion"))

ConfigSection:AddDropdown("LanguageSelect", {
    Title = Utils:Translate("Idioma"),
    Values = {"Spanish", "English", "Portuguese"},
    Default = Config.UI.Language,
    Callback = function(option)
        Config.UI.Language = option
        Utils:Notify(Utils:Translate("RestartRequired"), Utils:Translate("IdiomaCambiado"), 5)
    end
})

ConfigSection:AddParagraph({
    Title = "Blox Fruits Panel",
    Content = "Brand: BLOXY HUB\nCategory: Premium Titanium\nDeveloped by Sammir"
})

ConfigSection:AddButton({
    Title = Utils:Translate("ReiniciarPanel"),
    Callback = function()
        Utils:Notify("System", Utils:Translate("Restating3s"), 3)
        task.wait(3)
        getgenv().BloxyHub.Restart()
    end
})

ConfigSection:AddButton({
    Title = Utils:Translate("CerrarScript"),
    Callback = function()
        getgenv().BloxyHub.Shutdown()
    end
})

-- Inicialización de Guardado
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BloxyHub/BloxFruits")
SaveManager:SetFolder("BloxyHub/BloxFruits/Titanium")

SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE LOOPS PRINCIPALES (Thread-Safe)
-- ═══════════════════════════════════════════════════════════════

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
    task.wait(5) -- No es necesario actualizar stats cada milisegundo
end)

-- Loop: Seguridad y Admin Detector
ThreadManager:Register("SecurityManager", function()
    Security:AntiAFK()
    if Config.Security.AdminDetector then
        Security:DetectAdmin()
    end
    -- Mantenimiento del jugador
    if Config.Player.AutoAura then
        PlayerExp:AutoAura()
    end
    if Humanoid then
        if Humanoid.WalkSpeed ~= Config.Player.WalkSpeed then Humanoid.WalkSpeed = Config.Player.WalkSpeed end
        if Humanoid.JumpPower ~= Config.Player.JumpPower then Humanoid.JumpPower = Config.Player.JumpPower end
    end
    task.wait(2)
end)

-- Loop: Actualización de UI (Dashboard) - Prioridad Baja
ThreadManager:Register("UIUpdate", function()
    pcall(function()
        Session:Update()
        
        local _, worldName = Utils:GetCurrentWorld()
        if WorldInfo then 
            WorldInfo:SetTitle(Utils:Translate("MundoActual"))
            WorldInfo:SetContent(worldName) 
        end
        
        if StatusLabel then
            StatusLabel:SetTitle(Utils:Translate("EstadoScript") .. ": " .. Session.Status)
            StatusLabel:SetContent(string.format(
                "FPS: %d | Ping: %dms\nUptime: %s\nActive Threads: %d",
                Session.FPS, Session.Ping, Session.Uptime, ThreadManager:GetStatus()
            ))
        end
        
        if StatsLabel then
            StatsLabel:SetTitle(Utils:Translate("SesionStats"))
            StatsLabel:SetContent(string.format(
                "Levels Gained: %d\nBeli Gained: %d\nFragments: %d\nEnemies Defeated: %d",
                Session.LevelsGained, Session.BeliEarned, Session.FragmentsEarned, Session.MobsKilled
            ))
        end
    end)
    task.wait(Config.Performance.UIRefreshRate or 1.5) -- Throttling dinámico
end)

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: GESTIÓN DE CIERRE (SHUTDOWN)
-- ═══════════════════════════════════════════════════════════════

getgenv().BloxyHub.Shutdown = function()
    getgenv().BloxyHub.Active = false
    ThreadManager:StopAll()
    
    -- Restaurar configuración de renderizado si estaba en White Screen
    Performance:ToggleWhiteScreen(false)
    
    -- Destruir Interfaz
    pcall(function()
        if Fluent then
            Fluent:Destroy()
        end
    end)
    
    warn("[BLOXY HUB] Sistema Titanium cerrado correctamente.")
end

getgenv().BloxyHub.Restart = function()
    getgenv().BloxyHub.Shutdown()
    task.wait(1)
    -- Aquí podrías volver a ejecutar el loadstring del script original
    warn("[BLOXY HUB] Reiniciando...")
end

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZACIÓN FINAL
-- ═══════════════════════════════════════════════════════════════

-- Botón Flotante para Móvil (Floating Action Button)
local function CreateFloatingButton()
    local ScreenGui = Instance.new("ScreenGui")
    local Button = Instance.new("ImageButton")
    local Corner = Instance.new("UICorner")
    
    ScreenGui.Name = "TitaniumMobileToggle"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false
    
    Button.Name = "ToggleButton"
    Button.Parent = ScreenGui
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Button.BackgroundTransparency = 0.4
    Button.Position = UDim2.new(0, 20, 0.5, -25)
    Button.Size = UDim2.new(0, 50, 0, 50)
    Button.Image = "rbxassetid://4483362458" -- Logo del Hub
    Button.Draggable = true -- Soporte básico para moverlo
    
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        if Window then
            Window:Minimize() 
        end
    end)
    
    -- Lógica de Arrastre Manual Profesional
    local dragging, dragInput, dragStart, startPos
    
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Eliminar Loading Screen visual inmediatamente al estar listo
    pcall(function()
        if LocalPlayer.PlayerGui:FindFirstChild("BloxyLoading") then
            LocalPlayer.PlayerGui.BloxyLoading:Destroy()
        end
    end)
end

if Services.UserInputService.TouchEnabled then
    pcall(CreateFloatingButton)
else
    -- Si es PC, también eliminamos el loading al terminar de cargar
    pcall(function()
        task.delay(1, function()
            if LocalPlayer.PlayerGui:FindFirstChild("BloxyLoading") then
                LocalPlayer.PlayerGui.BloxyLoading:Destroy()
            end
        end)
    end)
end

getgenv().BloxyHub.Active = true

-- Función de Verificación de Versión
task.spawn(function()
    local success, currentVersion = pcall(function()
        return game:HttpGet(GITHUB_RAW .. "?t=" .. tick())
    end)
    
    if success then
        currentVersion = currentVersion:gsub("%s+", "") -- Limpiar espacios
        if currentVersion ~= VERSION then
            Utils:Notify("Actualización", "¡Hay una nueva versión disponible (" .. currentVersion .. ")!", 10)
            warn("[BLOXY HUB] NUEVA VERSIÓN DETECTADA: " .. currentVersion)
        end
    end
end)

-- Manejo de cambio de personaje (Re-bind de variables)
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

Utils:Notify("Bloxy Hub", Utils:Translate("LoadedSuccess"), 5)
Session.Status = Utils:Translate("ReadyFarm")

-- Mensaje de consola para depuración profesional
print([[
    ____  _      ____  __  ____   __   _    _ _    _ ____  
    | __ )| |    / __ \ \ \/ / \ \ / /  | |  | | |  | | __ ) 
    |  _ \| |   | |  | | \  /   \ V /   | |__| | |  | |  _ \ 
    | |_) | |___| |__| | /  \    | |    |  __  | |  | | |_) |
    |____/|_____|\____/ /_/\_\   |_|    |_|  |_|\____/|____/ 
    BLOX FRUITS PANEL - BLOXY HUB TITANIUM V7.0
]])
