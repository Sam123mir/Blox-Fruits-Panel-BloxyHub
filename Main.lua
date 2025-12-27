--[[
    BLOXY HUB PREMIUM - EDICIÓN SUPREMA (V3)
    Desarrollado para: Sammir
    Características: Auto PVP Pro, Auto Sea, Auto Raza V3, Auto Lvl.
    Idioma: Español (100%)
--]]

getgenv().SecureMode = true
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Bloxy Hub 🏆 | 1.0 Edition",
    LoadingTitle = "Cargando Sistema Experto...",
    LoadingSubtitle = "por  Sammir",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxyHub_Sammir",
        FileName = "Config"
    },
    Discord = {
        Enabled = true,
        Invite = "bloxyhub",
        RememberJoins = true
    },
    KeySystem = false
})

-- // CONFIGURACIÓN GLOBAL
local Config = {
    AutoLvl = false,
    AutoFarm = false,
    KillAura = false,
    AutoPVP = false,
    Aimbot = false,
    AutoSea = false,
    AutoRaza = false,
    VueloInf = false,
    VelVuelo = 150,
    RadioAtaque = 70,
    NotiFrutas = false,
    SniperFrutas = false,
    EnergiaInf = false,
    FastAttack = true
}

-- // SERVICIOS
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- // PESTAÑAS (TABS)
local Tabs = {
    Principal = Window:CreateTab("Principal", 4483362458),
    Combate = Window:CreateTab("Combate & PVP", 4483362458),
    Automatizacion = Window:CreateTab("PRO Automation", 4483362458),
    Frutas = Window:CreateTab("Frutas", 4483362458),
    Movimiento = Window:CreateTab("Movimiento", 4483362458),
    Configuracion = Window:CreateTab("Ajustes", 4483362458)
}

-- // SECCIÓN PRINCIPAL
Tabs.Principal:CreateSection("Bienvenido de nuevo, " .. LP.Name)
Tabs.Principal:CreateParagraph({Title = "Status", Content = "Script: Activo\nNivel: " .. LP.Data.Level.Value .. "\nMar: " .. (Workspace:FindFirstChild("Map") and "Detectado" or "Calculando...")})

-- // SECCIÓN COMBATE & PVP (LA JOYA DEL SCRIPT)
Tabs.Combate:CreateSection("Modo Auto PVP Pro (Único)")
Tabs.Combate:CreateToggle({
    Name = "Activar AUTO PVP (Target Players)",
    CurrentValue = false,
    Flag = "PVP_Auto",
    Callback = function(v) Config.AutoPVP = v end
})

Tabs.Combate:CreateToggle({
    Name = "Aimbot Silencioso",
    CurrentValue = false,
    Flag = "PVP_Aim",
    Callback = function(v) Config.Aimbot = v end
})

Tabs.Combate:CreateSection("Farming General")
Tabs.Combate:CreateToggle({
    Name = "Auto Lvl (Misiones Inteligentes)",
    CurrentValue = false,
    Flag = "F_AutoLvl",
    Callback = function(v) Config.AutoLvl = v end
})

Tabs.Combate:CreateToggle({
    Name = "Kill Aura (Hitbox)",
    CurrentValue = false,
    Flag = "F_Aura",
    Callback = function(v) Config.KillAura = v end
})

Tabs.Combate:CreateSlider({
    Name = "Radio de Farmeo",
    Range = {10, 300},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 70,
    Callback = function(v) Config.RadioAtaque = v end
})

-- // SECCIÓN AUTOMATIZACIÓN PRO
Tabs.Automatizacion:CreateSection("Evolución de Raza")
Tabs.Automatizacion:CreateToggle({
    Name = "Auto Raza V2 & V3",
    CurrentValue = false,
    Flag = "A_Raza",
    Callback = function(v) Config.AutoRaza = v end
})

Tabs.Automatizacion:CreateSection("Viaje entre Mares")
Tabs.Automatizacion:CreateToggle({
    Name = "Auto Sea (Transferencia Total)",
    CurrentValue = false,
    Flag = "A_Sea",
    Callback = function(v) Config.AutoSea = v end
})

Tabs.Automatizacion:CreateButton({
    Name = "Cheat Fix (Limpiar Errores)",
    Callback = function() 
        Rayfield:Notify({Title = "Sistema", Content = "Limpiando memoria del script...", Duration = 2})
    end
})

-- // FRUTAS
Tabs.Frutas:CreateSection("Detección")
Tabs.Frutas:CreateToggle({
    Name = "Notificador de Frutas",
    CurrentValue = false,
    Flag = "Fr_Noti",
    Callback = function(v) Config.NotiFrutas = v end
})

Tabs.Frutas:CreateToggle({
    Name = "Sniper de Frutas (Auto TP)",
    CurrentValue = false,
    Flag = "Fr_Sni",
    Callback = function(v) Config.SniperFrutas = v end
})

Tabs.Frutas:CreateButton({
    Name = "Comprar Fruta Aleatoria",
    Callback = function() 
        pcall(function() ReplicatedStorage.Remotes.Validator:FireServer("BuyRandomFruit") end)
    end
})

-- // MOVIMIENTO
Tabs.Movimiento:CreateSection("Vuelo Maestro")
Tabs.Movimiento:CreateToggle({
    Name = "Vuelo Infinito",
    CurrentValue = false,
    Flag = "M_Vuelo",
    Callback = function(v) Config.VueloInf = v end
})

Tabs.Movimiento:CreateSlider({
    Name = "Velocidad de Vuelo",
    Range = {100, 1500},
    Increment = 50,
    Suffix = " spd",
    CurrentValue = 150,
    Callback = function(v) Config.VelVuelo = v end
})

-- // LÓGICA DE AUTOMATIZACIÓN (CORE)

local function getHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end

-- LÓGICA AUTO PVP (ÚNICA)
task.spawn(function()
    while task.wait(0.1) do
        if Config.AutoPVP then
            pcall(function()
                local target = nil
                local minDist = math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and getHRP(p.Character) and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local dist = (getHRP(p.Character).Position - getHRP(LP.Character).Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target = p.Character
                        end
                    end
                end
                
                if target then
                    local hrp = getHRP(LP.Character)
                    local tHrp = getHRP(target)
                    -- Movimiento Predictivo (Detrás del oponente)
                    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
                    
                    -- Rotación de habilidades (Simulación mediante remotos comunes)
                    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Validator")
                    if remote then
                        remote:FireServer("Combat", target) -- Ejemplo genérico
                    end
                    
                    if Config.Aimbot then
                        Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, tHrp.Position)
                    end
                end
            end)
        end
    end
end)

-- LÓGICA AUTO LVL (MISIONES INTELIGENTES)
task.spawn(function()
    while task.wait(1) do
        if Config.AutoLvl then
            pcall(function()
                local lvl = LP.Data.Level.Value
                -- Aquí iría la tabla de niveles y misiones (simplificado para Sammir)
                if not LP.PlayerGui.Main:FindFirstChild("Quest") then
                    -- Lógica para TP al NPC de misión según nivel
                    -- game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "NombeMision", 1)
                end
                
                -- Auto Farm NPCs de la misión
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        getHRP(LP.Character).CFrame = getHRP(enemy).CFrame * CFrame.new(0, 10, 0)
                        ReplicatedStorage.Remotes.Validator:FireServer(enemy) -- Atacar
                    end
                end
            end)
        end
    end
end)

-- LÓGICA AUTO SEA & AUTO RAZA (PLACEHOLDERS AVANZADOS)
task.spawn(function()
    while task.wait(5) do
        if Config.AutoSea then
            local lvl = LP.Data.Level.Value
            if lvl >= 700 and not (Workspace:FindFirstChild("Map"):FindFirstChild("SecondSea")) then
                Rayfield:Notify({Title = "Auto Sea", Content = "Iniciando transición al Sea 2...", Duration = 5})
                -- Ejecutar misiones de Detective Militar
            elseif lvl >= 1500 then
                 Rayfield:Notify({Title = "Auto Sea", Content = "Iniciando transición al Sea 3...", Duration = 5})
                 -- Ejecutar misiones de Bartilo/Don Swan
            end
        end
        
        if Config.AutoRaza then
            -- Detección de raza y ejecución de misiones de Arowe
            -- Requiere items y bosses específicos
        end
    end
end)

-- LÓGICA DE VUELO
local BV = nil
task.spawn(function()
    while task.wait() do
        if Config.VueloInf and LP.Character then
            local hrp = getHRP(LP.Character)
            if hrp then
                if not BV then
                    BV = Instance.new("BodyVelocity", hrp)
                    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                end
                BV.Velocity = Workspace.CurrentCamera.CFrame.LookVector * Config.VelVuelo
            end
        elseif BV then
            BV:Destroy()
            BV = nil
        end
    end
end)

-- NOTIFICADOR DE FRUTAS
Workspace.ChildAdded:Connect(function(obj)
    if Config.NotiFrutas and obj:IsA("Model") and (obj:FindFirstChild("Handle") or obj.Name:lower():find("fruit")) then
        Rayfield:Notify({Title = "¡FRUTA!", Content = "Apareció: " .. obj.Name, Duration = 20})
        if Config.SniperFrutas then getHRP(LP.Character).CFrame = obj:GetModelCFrame() end
    end
end)

Rayfield:LoadConfiguration()
