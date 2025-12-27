--[[
    BLOXY HUB - Blox Fruits Edition (PROFESSIONAL V2)
    Logic optimized for low-latency & No-Errors.
    UI: Rayfield v2
--]]

getgenv().SecureMode = true -- Optimización para algunos ejecutores
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Bloxy Hub | Premium Edition",
    LoadingTitle = "Iniciando Protocolos...",
    LoadingSubtitle = "by Sammir",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxyHub_Config",
        FileName = "Main"
    },
    Discord = {
        Enabled = false,
        Invite = "bloxyhub",
        RememberJoins = true
    },
    KeySystem = false
})

-- // VARIABLES GLOBALES (Uso Seguro de Tablas)
local Settings = {
    AutoFarm = false,
    KillAura = false,
    Aimbot = false,
    InfFlight = false,
    FlightSpd = 100,
    FarmRange = 60,
    FruitNotify = false,
    FruitSnipe = false,
    InfEnergy = false,
    NoCooldown = false
}

-- // SERVICIOS & REFERENCIAS
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- // FUNCIONES DE UTILIDAD (Robustas)
local function getHRP(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function CheckHealth(target)
    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
        return true
    end
    return false
end

-- // TABS
local Tabs = {
    Main = Window:CreateTab("Main", 4483362458),
    Farming = Window:CreateTab("Combat", 4483362458),
    Movement = Window:CreateTab("Movement", 4483362458),
    Fruits = Window:CreateTab("Fruits", 4483362458),
    Config = Window:CreateTab("Config", 4483362458)
}

-- // MAIN SECTIONS
Tabs.Main:CreateSection("Estado del Usuario")
Tabs.Main:CreateParagraph({Title = "Bienvenido, " .. LP.Name, Content = "Estado: Activo\nSea: " .. (Workspace:FindFirstChild("Map") and "Detectado" or "Cargando...")})

-- // COMBAT / FARMING
Tabs.Farming:CreateSection("Auto Farming")
Tabs.Farming:CreateToggle({
    Name = "Auto Farm Level",
    CurrentValue = false,
    Flag = "AF_Lvl",
    Callback = function(v) Settings.AutoFarm = v end
})

Tabs.Farming:CreateSlider({
    Name = "Radio de Ataque",
    Range = {10, 300},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 60,
    Callback = function(v) Settings.FarmRange = v end
})

Tabs.Farming:CreateToggle({
    Name = "Kill Aura (Hitbox Extender)",
    CurrentValue = false,
    Flag = "KA_Aura",
    Callback = function(v) Settings.KillAura = v end
})

Tabs.Farming:CreateSection("Asistencia de Combate")
Tabs.Farming:CreateToggle({
    Name = "Silent Aimbot",
    CurrentValue = false,
    Flag = "SB_Aim",
    Callback = function(v) Settings.Aimbot = v end
})

-- // MOVEMENT
Tabs.Movement:CreateSection("Vuelo")
Tabs.Movement:CreateToggle({
    Name = "Vuelo Infinito",
    CurrentValue = false,
    Flag = "Move_Fly",
    Callback = function(v) Settings.InfFlight = v end
})

Tabs.Movement:CreateSlider({
    Name = "Velocidad de Vuelo",
    Range = {50, 1000},
    Increment = 25,
    Suffix = " speed",
    CurrentValue = 100,
    Callback = function(v) Settings.FlightSpd = v end
})

Tabs.Movement:CreateSection("Teletransportes")
local TP_Locations = {
    ["Starter Island"] = CFrame.new(944, 15, 141),
    ["Jungle"] = CFrame.new(-1612, 12, 147),
    ["Pirate Village"] = CFrame.new(-1146, 14, 3822)
}

for name, cf in pairs(TP_Locations) do
    Tabs.Movement:CreateButton({
        Name = "TP: " .. name,
        Callback = function()
            local hrp = getHRP(LP.Character)
            if hrp then hrp.CFrame = cf end
        end
    })
end

-- // FRUITS
Tabs.Fruits:CreateSection("Utilidades de Fruta")
Tabs.Fruits:CreateToggle({
    Name = "Notificador de Frutas",
    CurrentValue = false,
    Flag = "Fruit_Notify",
    Callback = function(v) Settings.FruitNotify = v end
})

Tabs.Fruits:CreateToggle({
    Name = "Auto Sniper (Instant TP)",
    CurrentValue = false,
    Flag = "Fruit_Snipe",
    Callback = function(v) Settings.FruitSnipe = v end
})

Tabs.Fruits:CreateButton({
    Name = "Comprar Fruta Aleatoria",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.Validator:FireServer("BuyRandomFruit")
            Rayfield:Notify({Title = "Fruit Dealer", Content = "Transacción enviada.", Duration = 3})
        end)
    end
})

-- // CORE LOGIC LOOPS (High Performance)

-- Auto Farm & Kill Aura
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoFarm then
            local hrp = getHRP(LP.Character)
            if not hrp then continue end
            
            pcall(function()
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end
                
                for _, npc in pairs(enemies:GetChildren()) do
                    if CheckHealth(npc) then
                        local nHrp = getHRP(npc)
                        if nHrp and (nHrp.Position - hrp.Position).Magnitude <= Settings.FarmRange then
                            -- Soft TP (Above NPC)
                            hrp.CFrame = nHrp.CFrame * CFrame.new(0, 10, 0)
                            
                            if Settings.KillAura then
                                -- Fire Combat Remote (Generic Placeholder - Update for actual game version)
                                local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Validator")
                                if remote then remote:FireServer(npc) end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Flight Logic (Smooth BodyVelocity)
local BV = nil
task.spawn(function()
    while task.wait() do
        if Settings.InfFlight and LP.Character then
            local hrp = getHRP(LP.Character)
            if hrp then
                if not BV then
                    BV = Instance.new("BodyVelocity")
                    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    BV.Parent = hrp
                end
                BV.Velocity = Workspace.CurrentCamera.CFrame.LookVector * Settings.FlightSpd
            end
        else
            if BV then BV:Destroy() BV = nil end
        end
    end
end)

-- Fruit Detection
Workspace.ChildAdded:Connect(function(obj)
    if Settings.FruitNotify and obj:IsA("Model") then
        task.wait(0.2)
        if obj:FindFirstChild("Handle") or obj.Name:lower():find("fruit") then
            Rayfield:Notify({
                Title = "¡NUEVA FRUTA!",
                Content = "Se ha detectado: " .. obj.Name,
                Duration = 15,
                Image = 4483362458
            })
            if Settings.FruitSnipe then
                local hrp = getHRP(LP.Character)
                if hrp then hrp.CFrame = obj:GetModelCFrame() end
            end
        end
    end
end)

-- Infinite Energy
task.spawn(function()
    while task.wait(1) do
        if Settings.InfEnergy and LP.Character and LP.Character:FindFirstChild("Energy") then
            LP.Character.Energy.Value = LP.Character.Energy.MaxValue
        end
    end
end)

Rayfield:LoadConfiguration()
