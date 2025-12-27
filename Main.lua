--[[
    BLOXY HUB ELITE - VERSIÓN 5.1 (SUPREMA)
    Optimizado por Sammir | Refinamiento de Combate & UI
    Fixes: Daño de NPCs, Sincronización de Stats, Indicador MS.
--]]

getgenv().SecureMode = true
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // ESTADÍSTICAS DE SESIÓN
local Session = {
    StartTime = os.time(),
    LevelsGained = 0,
    BeliEarned = 0,
    StartBeli = game:GetService("Players").LocalPlayer.Data.Beli.Value,
    StartLvl = game:GetService("Players").LocalPlayer.Data.Level.Value
}

-- // CONFIGURACIÓN ELITE
local Config = {
    AutoLvl = false,
    AutoMastery = false,
    MasteryWeapon = "Melee", -- Melee, Sword, Fruit, Gun
    SelectiveStats = {
        Melee = false,
        Defense = false,
        Sword = false,
        Gun = false,
        BloxFruit = false
    },
    CPUMode = false,
    WhiteScreen = false,
    AdminDetector = false,
    AttackSpeed = 0.05,
    FastAttack = true,
    KillAura = false,
    AutoPVP = false
}

-- // SERVICIOS
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer

-- // VENTANA PRINCIPAL (ESTILO GLASSMORPHISM)
local Window = Rayfield:CreateWindow({
    Name = "Bloxy Hub ELITE 🏅 | v5.0",
    LoadingTitle = "Iniciando Edición de Élite...",
    LoadingSubtitle = "Protegiendo las cuentas de nuestros usuarios.",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxyHub_V5",
        FileName = "Elite_Config"
    },
    ImageId = 4483362458 -- Logo Profesional
})

-- // UTILIDAD DE PING
local function GetPing()
    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
end

-- // PESTAÑAS (CATEGORÍAS ELITE)
local Tabs = {
    Inicio = Window:CreateTab("Dashboard", 4483362458),
    Farming = Window:CreateTab("Farming & Maestría", 4483362458),
    Combate = Window:CreateTab("Combate / PVP", 4483362458),
    Stats = Window:CreateTab("Estadísticas", 4483362458),
    Seguridad = Window:CreateTab("Seguridad & Ops", 4483362458)
}

-- // PESTAÑA INICIO (DASHBOARD)
Tabs.Inicio:CreateSection("Resumen de Sesión")
local StatsLabel = Tabs.Inicio:CreateParagraph({
    Title = "Estadísticas en Tiempo Real",
    Content = "Cargando datos..."
})

task.spawn(function()
    while task.wait(1) do
        local elapsed = os.time() - Session.StartTime
        local hours = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local curLvl = LP.Data.Level.Value
        local curBeli = LP.Data.Beli.Value
        local ping = GetPing()
        
        StatsLabel:Set({
            Title = "Estadísticas en Tiempo Real | Ping: " .. ping .. "ms",
            Content = string.format("Niveles Subidos: %d\nBeli Ganado: %s\nTiempo: %02d:%02d\nSEA: %s", 
                curLvl - Session.StartLvl, 
                tostring(curBeli - Session.StartBeli),
                hours, mins,
                (Workspace:FindFirstChild("Map") and "Detectado" or "Calculando"))
        })
    end
end)

-- // PESTAÑA FARMING & MAESTRÍA
Tabs.Farming:CreateSection("Auto Leveling")
Tabs.Farming:CreateToggle({Name = "Auto Farm Level", Flag = "LvL", Callback = function(v) Config.AutoLvl = v end})

Tabs.Farming:CreateSection("Auto Maestría Pro")
Tabs.Farming:CreateDropdown({
    Name = "Arma a Farmear",
    Options = {"Melee", "Sword", "Fruit", "Gun"},
    CurrentValue = "Melee",
    Flag = "M_Weapon",
    Callback = function(v) Config.MasteryWeapon = v end
})

Tabs.Farming:CreateToggle({
    Name = "Activar Auto Maestría",
    Flag = "M_Active",
    Callback = function(v) Config.AutoMastery = v end
})

-- // PESTAÑA STATS (SELECTIVO)
Tabs.Stats:CreateSection("Distribución Inteligente")
Tabs.Stats:CreateToggle({Name = "Melee (Combate)", Callback = function(v) Config.SelectiveStats.Melee = v end})
Tabs.Stats:CreateToggle({Name = "Defense (Defensa)", Callback = function(v) Config.SelectiveStats.Defense = v end})
Tabs.Stats:CreateToggle({Name = "Sword (Espada)", Callback = function(v) Config.SelectiveStats.Sword = v end})
Tabs.Stats:CreateToggle({Name = "Gun (Pistola)", Callback = function(v) Config.SelectiveStats.Gun = v end})
Tabs.Stats:CreateToggle({Name = "Blox Fruit (Fruta)", Callback = function(v) Config.SelectiveStats.BloxFruit = v end})

-- // PESTAÑA SEGURIDAD & RENDIMIENTO
Tabs.Seguridad:CreateSection("Optimización FPS")
Tabs.Seguridad:CreateToggle({
    Name = "Modo CPU (Remover Texturas)",
    Callback = function(v) 
        Config.CPUMode = v 
        if v then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Material = Enum.Material.SmoothPlastic
                    if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 end
                end
            end
        end
    end
})

Tabs.Seguridad:CreateToggle({
    Name = "Modo Pantalla Blanca (Máximo FPS)",
    Callback = function(v)
        Config.WhiteScreen = v
        game:GetService("RunService"):Set3dRenderingEnabled(not v)
    end
})

Tabs.Seguridad:CreateSection("Anti-Ban / Admin")
Tabs.Seguridad:CreateToggle({
    Name = "Detector de Admins (Auto-Leave)",
    Callback = function(v) Config.AdminDetector = v end
})

-- // LÓGICA DE MAESTRÍA (V5.0)
-- // LÓGICA DE MAESTRÍA (V5.1)
task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoMastery then
            pcall(function()
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        local hrp = LP.Character.HumanoidRootPart
                        local eHrp = enemy.HumanoidRootPart
                        
                        -- Teletransportar justo encima para evitar daño
                        hrp.CFrame = eHrp.CFrame * CFrame.new(0, 11, 0)
                        
                        -- LÓGICA DE GOLPE REAL (Fix para daño)
                        local combat = ReplicatedStorage.Remotes:FindFirstChild("Validator")
                        if combat then
                            combat:FireServer("Combat", LP.Character) -- Registro de animación
                            combat:FireServer(enemy) -- Registro de daño directo
                        end
                        
                        -- Auto-Clicker Simulado
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        
                        -- REMATE DE MAESTRÍA
                        if enemy.Humanoid.Health / enemy.Humanoid.MaxHealth <= 0.20 then
                            local weapon = LP.Backpack:FindFirstChild(Config.MasteryWeapon) or LP.Character:FindFirstChild(Config.MasteryWeapon)
                            if weapon then
                                LP.Character.Humanoid:EquipTool(weapon)
                                VirtualUser:SetKeyDown("z")
                                task.wait(0.1)
                                VirtualUser:SetKeyUp("z")
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- // LÓGICA AUTO STATS SELECTIVO
task.spawn(function()
    while task.wait(1) do
        local points = LP.Data.StatsPoints.Value
        if points > 0 then
            local targets = {}
            for k, v in pairs(Config.SelectiveStats) do if v then table.insert(targets, k) end end
            
            if #targets > 0 then
                local perStat = math.floor(points / #targets)
                for _, stat in ipairs(targets) do
                    local name = stat == "BloxFruit" and "Blox Fruit" or stat
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", name, perStat)
                end
            end
        end
    end
end)

-- // DETECTOR DE ADMINS REAL
task.spawn(function()
    while task.wait(5) do
        if Config.AdminDetector then
            for _, player in pairs(Players:GetPlayers()) do
                if player:GetRankInGroup(2440505) >= 1 then
                    LP:Kick("¡BLOXY HUB: ADMIN DETECTADO! (" .. player.Name .. ")")
                end
            end
        end
    end
end)

-- // ULTIMATE FAST ATTACK (SAMMIR EDITION)
task.spawn(function()
    while task.wait(Config.AttackSpeed) do
        if Config.FastAttack and (Config.AutoLvl or Config.AutoMastery or Config.KillAura) then
            pcall(function()
                local combat = ReplicatedStorage.Remotes:FindFirstChild("Validator")
                if combat then
                    -- Triple registro para asegurar daño incluso con lag
                    combat:FireServer("Combat", LP.Character)
                    combat:FireServer("Combat", LP.Character)
                    -- Forzar click si es necesario
                end
            end)
        end
    end
end)

Rayfield:LoadConfiguration()
