--[[
    BLOXY HUB TITANIUM - MÓDULO: SESSION
    Estadísticas de sesión del jugador - CORREGIDO
]]

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
    Status = "Esperando Datos..."
}

-- Dependencias
local Services

function Session:Init(deps)
    Services = deps.Services
    
    -- Inicialización segura de estadísticas
    task.spawn(function()
        task.wait(2) -- Esperar a que cargue el juego
        
        local player = Services.LocalPlayer
        local data = player:WaitForChild("Data", 30)
        
        if data then
            local levelVal = data:FindFirstChild("Level")
            local beliVal = data:FindFirstChild("Beli")
            local fragmentsVal = data:FindFirstChild("Fragments")
            
            if levelVal then self.StartLevel = levelVal.Value end
            if beliVal then self.StartBeli = beliVal.Value end
            if fragmentsVal then self.StartFragments = fragmentsVal.Value end
            
            self.Status = "Sesión Iniciada"
            print("[SESSION] Datos iniciales: Lvl=" .. self.StartLevel .. " Beli=" .. self.StartBeli)
        else
            warn("[SESSION] No se encontró carpeta Data del jugador")
        end
    end)
end

function Session:GetPlayerLevel()
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 0
end

function Session:GetPlayerBeli()
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Beli") then
        return data.Beli.Value
    end
    return 0
end

function Session:GetPlayerFragments()
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Fragments") then
        return data.Fragments.Value
    end
    return 0
end

function Session:Update()
    -- Uptime
    local elapsed = os.time() - self.StartTime
    local hours = math.floor(elapsed / 3600)
    local mins = math.floor((elapsed % 3600) / 60)
    local secs = elapsed % 60
    self.Uptime = string.format("%02d:%02d:%02d", hours, mins, secs)
    
    -- Estadísticas actuales
    local currentLevel = self:GetPlayerLevel()
    local currentBeli = self:GetPlayerBeli()
    local currentFragments = self:GetPlayerFragments()
    
    if currentLevel > 0 then
        self.LevelsGained = currentLevel - self.StartLevel
    end
    if currentBeli > 0 then
        self.BeliEarned = currentBeli - self.StartBeli
    end
    if currentFragments > 0 then
        self.FragmentsEarned = currentFragments - self.StartFragments
    end
    
    -- Ping (método más confiable)
    pcall(function()
        local stats = game:GetService("Stats")
        local networkStats = stats:FindFirstChild("Network")
        if networkStats then
            local serverStats = networkStats:FindFirstChild("ServerStatsItem")
            if serverStats then
                local pingItem = serverStats:FindFirstChild("Data Ping")
                if pingItem then
                    self.Ping = math.floor(pingItem:GetValue())
                end
            end
        end
    end)
    
    -- FPS
    pcall(function()
        self.FPS = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
    end)
end

function Session:AddMobKill()
    self.MobsKilled = self.MobsKilled + 1
end

function Session:AddBossKill()
    self.BossesKilled = self.BossesKilled + 1
end

return Session
