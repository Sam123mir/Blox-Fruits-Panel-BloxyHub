--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  BLOXY HUB ELITE V6.0 - TITANIUM REBUILD                    ║
    ║  Arquitectura Modular Profesional | Thread-Safe | Auto-Clean║
    ║  Desarrollado por Sammir | Optimizado para Blox Fruits      ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE VERSIÓN Y VALIDACIÓN
-- ═══════════════════════════════════════════════════════════════

getgenv().BloxyElite = getgenv().BloxyElite or {}
local VERSION = "6.0.0"
local GITHUB_RAW = "https://raw.githubusercontent.com/yourrepo/bloxyelite/main/version.txt"

if getgenv().BloxyElite.Active then
    warn("[BLOXY ELITE] Ya hay una instancia activa. Cerrando instancia anterior...")
    getgenv().BloxyElite.Shutdown()
    task.wait(1)
end

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
local Humanoid = Character and Character:FindFirstChild("Humanoid")
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

-- Función para asegurar que las referencias del personaje estén actualizadas
local function UpdateCharacterReferences(newChar)
    Character = newChar or LocalPlayer.Character
    if Character then
        Humanoid = Character:WaitForChild("Humanoid", 10)
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
    end
end

LocalPlayer.CharacterAdded:Connect(UpdateCharacterReferences)
if not Character then 
    task.spawn(function()
        Character = LocalPlayer.CharacterAdded:Wait()
        UpdateCharacterReferences(Character)
    end)
else
    UpdateCharacterReferences(Character)
end

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: CONFIGURACIÓN ELITE
-- ═══════════════════════════════════════════════════════════════

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
        TextureQuality = "High" -- High, Medium, Low, Potato
    },
    
    Security = {
        AntiAFK = true,
        AdminDetector = false,
        AutoLeaveOnAdmin = true,
        StaffGroupId = 2440505
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
        Notifications = true,
        StatusBar = true,
        MinimizeSymbol = "−"
    }
}

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: SESIÓN Y ESTADÍSTICAS
-- ═══════════════════════════════════════════════════════════════

local Session = {
    StartTime = os.time(),
    StartLevel = LocalPlayer.Data.Level.Value,
    StartBeli = LocalPlayer.Data.Beli.Value,
    StartFragments = LocalPlayer.Data.Fragments.Value,
    
    LevelsGained = 0,
    BeliEarned = 0,
    FragmentsEarned = 0,
    MobsKilled = 0,
    BossesKilled = 0,
    
    Uptime = "00:00:00",
    Ping = 0,
    FPS = 60,
    Status = "Inicializando..."
}

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
        self.UIElement:Set({
            Title = "Registro de Actividad (Últimos 50)",
            Content = content == "" and "No hay logs registrados." or content
        })
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

function Session:Update()
    local elapsed = os.time() - self.StartTime
    local hours = math.floor(elapsed / 3600)
    local mins = math.floor((elapsed % 3600) / 60)
    local secs = elapsed % 60
    
    self.Uptime = string.format("%02d:%02d:%02d", hours, mins, secs)
    self.LevelsGained = LocalPlayer.Data.Level.Value - self.StartLevel
    self.BeliEarned = LocalPlayer.Data.Beli.Value - self.StartBeli
    self.FragmentsEarned = LocalPlayer.Data.Fragments.Value - self.StartFragments
    self.Ping = math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    self.FPS = math.floor(Services.Stats.FrameRateManager.RenderAverage:GetValue())
end

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

function Utils:GetCurrentWorld()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1, "First Sea"
    elseif placeId == 4442272183 then return 2, "Second Sea"
    elseif placeId == 7449423635 then return 3, "Third Sea"
    else return 0, "Unknown" end
end

function Utils:Notify(title, message, duration)
    if not Config.UI.Notifications then return end
    
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = duration or 3,
        Image = 4483362458
    })
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
    
    pcall(function()
        -- Posicionamiento estratégico
        local enemyHRP = enemy.HumanoidRootPart
        Utils:TeleportTo(enemyHRP.CFrame, Config.AutoFarm.SafeMode)
        
        -- Sistema de ataque múltiple
        for i = 1, 3 do
            self:FastAttack()
            task.wait(Config.Combat.AttackSpeed)
        end
        
        -- Actualizar estadísticas
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
-- MÓDULO: AUTO FARM SYSTEM
-- ═══════════════════════════════════════════════════════════════

local Farming = {}

function Farming:AutoLevel()
    if not Config.AutoFarm.Enabled or Config.AutoFarm.Mode ~= "Level" then return end
    
    local enemy, distance = Utils:GetClosestEnemy(500)
    
    if enemy then
        Combat:AttackEnemy(enemy)
        
        if Config.Mastery.Enabled then
            Combat:ExecuteMasteryFinisher(enemy)
        end
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

function StatsManager:DistributePoints()
    if not Config.Stats.Enabled then return end
    
    pcall(function()
        local points = LocalPlayer.Data.StatsPoints.Value
        if points <= 0 then return end
        
        local activeStats = {}
        for stat, enabled in pairs(Config.Stats.Distribution) do
            if enabled then
                table.insert(activeStats, stat)
            end
        end
        
        if #activeStats == 0 then return end
        
        local pointsPerStat = math.floor(points / #activeStats)
        
        for _, stat in ipairs(activeStats) do
            local success = Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, pointsPerStat)
            if success then
                Utils:Notify("Stats", string.format("+%d puntos en %s", pointsPerStat, stat), 2)
            end
        end
    end)
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
-- MÓDULO: UI RAYFIELD (Interfaz Profesional)
-- ═══════════════════════════════════════════════════════════════

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Bloxy Hub ELITE 🏆 | v6.0 Titanium",
    LoadingTitle = "Iniciando Sistema Titanium...",
    LoadingSubtitle = "Cargando módulos profesionales",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxyElite_V6",
        FileName = "TitaniumConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvite",
        RememberJoins = true
    },
    KeySystem = false
})

-- ═══════════════════════════════════════════════════════════════
-- PESTAÑAS DE LA UI
-- ═══════════════════════════════════════════════════════════════

local Tabs = {
    Dashboard = Window:CreateTab("📊 Dashboard", 4483362458),
    Farming = Window:CreateTab("⚔️ Farming", 4483362458),
    Combat = Window:CreateTab("💥 Combate", 4483362458),
    Player = Window:CreateTab("🏃 Personaje", 4483362458),
    Stats = Window:CreateTab("📈 Stats", 4483362458),
    Performance = Window:CreateTab("⚡ Performance", 4483362458),
    Security = Window:CreateTab("🛡️ Seguridad", 4483362458),
    Logs = Window:CreateTab("📋 Historial", 4483362458),
    Settings = Window:CreateTab("⚙️ Ajustes", 4483362458)
}

-- ═══════════════════════════════════════════════════════════════
-- TAB: DASHBOARD
-- ═══════════════════════════════════════════════════════════════

Tabs.Dashboard:CreateSection("Información del Sistema")

local StatusLabel = Tabs.Dashboard:CreateParagraph({
    Title = "Estado del Script",
    Content = "Cargando..."
})

local StatsLabel = Tabs.Dashboard:CreateParagraph({
    Title = "Estadísticas de Sesión",
    Content = "Cargando..."
})

local WorldInfo = Tabs.Dashboard:CreateLabel("Mundo: Detectando...")

-- ═══════════════════════════════════════════════════════════════
-- TAB: FARMING
-- ═══════════════════════════════════════════════════════════════

Tabs.Farming:CreateSection("Auto Farm Settings")

Tabs.Farming:CreateToggle({
    Name = "🔥 Auto Farm Level",
    CurrentValue = Config.AutoFarm.Enabled,
    Flag = "AutoFarmToggle",
    Callback = function(value)
        Config.AutoFarm.Enabled = value
        Config.AutoFarm.Mode = "Level"
        Session.Status = value and "Farming activo" or "En espera"
        Utils:Notify("Auto Farm", value and "Activado" or "Desactivado", 2)
    end
})

Tabs.Farming:CreateToggle({
    Name = "🎯 Modo Seguro (Anti-Daño)",
    CurrentValue = Config.AutoFarm.SafeMode,
    Flag = "SafeModeToggle",
    Callback = function(value)
        Config.AutoFarm.SafeMode = value
    end
})

Tabs.Farming:CreateSection("Auto Mastery")

Tabs.Farming:CreateDropdown({
    Name = "Seleccionar Arma",
    Options = {"Combat", "Sword", "Blox Fruit", "Gun"},
    CurrentOption = Config.Mastery.Weapon,
    Flag = "MasteryWeapon",
    Callback = function(option)
        Config.Mastery.Weapon = option
    end
})

Tabs.Farming:CreateToggle({
    Name = "✨ Auto Mastery",
    CurrentValue = Config.Mastery.Enabled,
    Flag = "MasteryToggle",
    Callback = function(value)
        Config.Mastery.Enabled = value
        Utils:Notify("Mastery", value and "Activado" or "Desactivado", 2)
    end
})

Tabs.Farming:CreateSlider({
    Name = "HP para Rematar (%)",
    Range = {10, 50},
    Increment = 5,
    CurrentValue = Config.Mastery.FinishAtHealth,
    Flag = "MasteryHP",
    Callback = function(value)
        Config.Mastery.FinishAtHealth = value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: COMBATE
-- ═══════════════════════════════════════════════════════════════

Tabs.Combat:CreateSection("Sistema de Combate")

Tabs.Combat:CreateToggle({
    Name = "⚡ Fast Attack",
    CurrentValue = Config.Combat.FastAttack,
    Flag = "FastAttackToggle",
    Callback = function(value)
        Config.Combat.FastAttack = value
    end
})

Tabs.Combat:CreateSlider({
    Name = "Velocidad de Ataque",
    Range = {0.01, 0.2},
    Increment = 0.01,
    CurrentValue = Config.Combat.AttackSpeed,
    Flag = "AttackSpeed",
    Callback = function(value)
        Config.Combat.AttackSpeed = value
    end
})

Tabs.Combat:CreateToggle({
    Name = "🌀 Kill Aura",
    CurrentValue = Config.Combat.KillAura,
    Flag = "KillAuraToggle",
    Callback = function(value)
        Config.Combat.KillAura = value
    end
})

Tabs.Combat:CreateSlider({
    Name = "Rango de Kill Aura",
    Range = {10, 100},
    Increment = 5,
    CurrentValue = Config.Combat.Range,
    Flag = "KillAuraRange",
    Callback = function(value)
        Config.Combat.Range = value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: PERSONAJE
-- ═══════════════════════════════════════════════════════════════

Tabs.Player:CreateSection("Mejoras de Combate y Movilidad")

Tabs.Player:CreateToggle({
    Name = "✨ Auto Aura (Haki)",
    CurrentValue = Config.Player.AutoAura,
    Flag = "AutoAura",
    Callback = function(value)
        Config.Player.AutoAura = value
        if value then PlayerExp:AutoAura() end
    end
})

Tabs.Player:CreateToggle({
    Name = "🕊️ Salto Infinito (Skyjump)",
    CurrentValue = Config.Player.InfiniteSkyjump,
    Flag = "InfiniteSkyjump",
    Callback = function(value)
        Config.Player.InfiniteSkyjump = value
        if value then PlayerExp:InfiniteSkyjump() end
    end
})

Tabs.Player:CreateSection("Velocidad y Salto")

Tabs.Player:CreateSlider({
    Name = "Velocidad de Caminado",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = Config.Player.WalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(value)
        Config.Player.WalkSpeed = value
        if Humanoid then Humanoid.WalkSpeed = value end
    end
})

Tabs.Player:CreateSlider({
    Name = "Poder de Salto",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = Config.Player.JumpPower,
    Flag = "JumpPower",
    Callback = function(value)
        Config.Player.JumpPower = value
        if Humanoid then Humanoid.JumpPower = value end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: STATS
-- ═══════════════════════════════════════════════════════════════

Tabs.Stats:CreateSection("Distribución de Estadísticas")

Tabs.Stats:CreateToggle({
    Name = "🥊 Melee",
    CurrentValue = Config.Stats.Distribution.Melee,
    Flag = "StatMelee",
    Callback = function(value)
        Config.Stats.Distribution.Melee = value
    end
})

Tabs.Stats:CreateToggle({
    Name = "🛡️ Defense",
    CurrentValue = Config.Stats.Distribution.Defense,
    Flag = "StatDefense",
    Callback = function(value)
        Config.Stats.Distribution.Defense = value
    end
})

Tabs.Stats:CreateToggle({
    Name = "⚔️ Sword",
    CurrentValue = Config.Stats.Distribution.Sword,
    Flag = "StatSword",
    Callback = function(value)
        Config.Stats.Distribution.Sword = value
    end
})

Tabs.Stats:CreateToggle({
    Name = "🔫 Gun",
    CurrentValue = Config.Stats.Distribution.Gun,
    Flag = "StatGun",
    Callback = function(value)
        Config.Stats.Distribution.Gun = value
    end
})

Tabs.Stats:CreateToggle({
    Name = "🍎 Blox Fruit",
    CurrentValue = Config.Stats.Distribution["Blox Fruit"],
    Flag = "StatFruit",
    Callback = function(value)
        Config.Stats.Distribution["Blox Fruit"] = value
    end
})

Tabs.Stats:CreateToggle({
    Name = "📊 Auto Stats (Activar)",
    CurrentValue = Config.Stats.Enabled,
    Flag = "AutoStatsToggle",
    Callback = function(value)
        Config.Stats.Enabled = value
        Utils:Notify("Auto Stats", value and "Activado" or "Desactivado", 2)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: PERFORMANCE
-- ═══════════════════════════════════════════════════════════════

Tabs.Performance:CreateSection("Optimización de Rendimiento")

Tabs.Performance:CreateToggle({
    Name = "💻 Modo CPU (Remover Texturas)",
    CurrentValue = Config.Performance.CPUMode,
    Flag = "CPUMode",
    Callback = function(value)
        Config.Performance.CPUMode = value
        if value then Performance:ApplyCPUMode() end
    end
})

Tabs.Performance:CreateToggle({
    Name = "⚪ Pantalla Blanca (Máximo FPS)",
    CurrentValue = Config.Performance.WhiteScreen,
    Flag = "WhiteScreen",
    Callback = function(value)
        Performance:ToggleWhiteScreen(value)
    end
})

Tabs.Performance:CreateToggle({
    Name = "🚀 FPS Boost",
    CurrentValue = Config.Performance.FPSBoost,
    Flag = "FPSBoost",
    Callback = function(value)
        Config.Performance.FPSBoost = value
        if value then Performance:ApplyFPSBoost() end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: SEGURIDAD
-- ═══════════════════════════════════════════════════════════════

Tabs.Security:CreateSection("Protección y Anti-Ban")

Tabs.Security:CreateToggle({
    Name = "🔄 Anti-AFK",
    CurrentValue = Config.Security.AntiAFK,
    Flag = "AntiAFK",
    Callback = function(value)
        Config.Security.AntiAFK = value
    end
})

Tabs.Security:CreateToggle({
    Name = "👁️ Detector de Admins",
    CurrentValue = Config.Security.AdminDetector,
    Flag = "AdminDetector",
    Callback = function(value)
        Config.Security.AdminDetector = value
    end
})

Tabs.Security:CreateToggle({
    Name = "🚪 Auto-Leave al Detectar Admin",
    CurrentValue = Config.Security.AutoLeaveOnAdmin,
    Flag = "AutoLeave",
    Callback = function(value)
        Config.Security.AutoLeaveOnAdmin = value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: LOGS
-- ═══════════════════════════════════════════════════════════════

Tabs.Logs:CreateSection("Depuración del Sistema")

LogSystem.UIElement = Tabs.Logs:CreateParagraph({
    Title = "Registro de Actividad",
    Content = "Iniciandolo sistema de logs..."
})

Tabs.Logs:CreateButton({
    Name = "🧹 Limpiar Historial",
    Callback = function()
        LogSystem:Clear()
    end
})

Tabs.Logs:CreateButton({
    Name = "📋 Copiar Logs al Portapapeles",
    Callback = function()
        local allLogs = table.concat(LogSystem.Entries, "\n")
        if setclipboard then
            setclipboard(allLogs)
            Utils:Notify("Logs", "Historial copiado al portapapeles", 2)
        else
            Utils:Notify("Logs", "Tu ejecutor no soporta setclipboard", 2)
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: AJUSTES
-- ═══════════════════════════════════════════════════════════════

Tabs.Settings:CreateSection("Información del Script")

Tabs.Settings:CreateParagraph({
    Title = "Bloxy Hub Elite v6.0",
    Content = "Arquitectura Titanium\nDesarrollado con módulos profesionales\nThread-safe & Auto-cleanup\n\nGracias por usar Bloxy Elite! 🏆"
})

Tabs.Settings:CreateButton({
    Name = "🔄 Reiniciar Script",
    Callback = function()
        Utils:Notify("Sistema", "Reiniciando en 3 segundos...", 3)
        task.wait(3)
        getgenv().BloxyElite.Restart()
    end
})

Tabs.Settings:CreateButton({
    Name = "❌ Cerrar Script",
    Callback = function()
        getgenv().BloxyElite.Shutdown()
    end
})

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
        Farming:AutoMastery()
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

-- Loop: Actualización de UI (Dashboard)
ThreadManager:Register("UIUpdate", function()
    Session:Update()
    
    local _, worldName = Utils:GetCurrentWorld()
    WorldInfo:Set("Mundo: " .. worldName)
    
    StatusLabel:SetTitle("Estado: " .. Session.Status)
    StatusLabel:SetContent(string.format(
        "FPS: %d | Ping: %dms\nUptime: %s\nHilos Activos: %d",
        Session.FPS, Session.Ping, Session.Uptime, ThreadManager:GetStatus()
    ))
    
    StatsLabel:SetContent(string.format(
        "Niveles Ganados: %d\nBeli Ganado: %d\nFragmentos: %d\nEnemigos Derrotados: %d",
        Session.LevelsGained, Session.BeliEarned, Session.FragmentsEarned, Session.MobsKilled
    ))
    
    task.wait(1)
end)

-- ═══════════════════════════════════════════════════════════════
-- MÓDULO: GESTIÓN DE CIERRE (SHUTDOWN)
-- ═══════════════════════════════════════════════════════════════

getgenv().BloxyElite.Shutdown = function()
    getgenv().BloxyElite.Active = false
    ThreadManager:StopAll()
    
    -- Restaurar configuración de renderizado si estaba en White Screen
    Performance:ToggleWhiteScreen(false)
    
    -- Destruir Interfaz
    pcall(function()
        Rayfield:Destroy()
    end)
    
    warn("[BLOXY ELITE] Sistema Titanium cerrado correctamente.")
end

getgenv().BloxyElite.Restart = function()
    getgenv().BloxyElite.Shutdown()
    task.wait(1)
    -- Aquí podrías volver a ejecutar el loadstring del script original
    warn("[BLOXY ELITE] Reiniciando...")
end

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZACIÓN FINAL
-- ═══════════════════════════════════════════════════════════════

getgenv().BloxyElite.Active = true

-- Manejo de cambio de personaje (Re-bind de variables)
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

Utils:Notify("Sistema Titanium", "Bloxy Hub v6.0 cargado con éxito. ¡Buen farm!", 5)
Session.Status = "Listo para farmear"

-- Mensaje de consola para depuración profesional
print([[
    ____  _      ____  __  ____   __   _    _ _    _ ____  
    | __ )| |    / __ \ \ \/ / \ \ / /  | |  | | |  | | __ ) 
    |  _ \| |   | |  | | \  /   \ V /   | |__| | |  | |  _ \ 
    | |_) | |___| |__| | /  \    | |    |  __  | |  | | |_) |
    |____/|_____|\____/ /_/\_\   |_|    |_|  |_|\____/|____/ 
    TITANIUM REBUILD V6.0 - BY SAMMIR
]])
