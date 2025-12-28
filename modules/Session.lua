--[[
    BLOXY HUB TITANIUM - MÓDULO: SESSION
    Estadísticas de sesión - VERSIÓN ROBUSTA
]]

local Session = {
    StartTime = os.time(),
    StartLevel = 0,
    StartBeli = 0,
    StartFragments = 0,
    
    CurrentLevel = 0,
    CurrentBeli = 0,
    CurrentFragments = 0,
    
    LevelsGained = 0,
    BeliEarned = 0,
    FragmentsEarned = 0,
    MobsKilled = 0,
    BossesKilled = 0,
    
    Uptime = "00:00:00",
    Ping = 0,
    FPS = 60,
    Status = "Iniciando..."
}

-- Dependencias
local Services
local Initialized = false

function Session:Init(deps)
    Services = deps.Services
    
    -- Esperar a que el juego cargue completamente
    task.spawn(function()
        task.wait(3)
        
        -- Obtener datos iniciales
        local success = pcall(function()
            local plr = Services.LocalPlayer
            local data = plr:WaitForChild("Data", 30)
            
            if data then
                local lvl = data:FindFirstChild("Level")
                local beli = data:FindFirstChild("Beli")
                local frags = data:FindFirstChild("Fragments")
                
                if lvl then self.StartLevel = lvl.Value end
                if beli then self.StartBeli = beli.Value end
                if frags then self.StartFragments = frags.Value end
                
                self.Status = "Sesión Iniciada"
                Initialized = true
                print("[SESSION] Inicializado - Nivel: " .. self.StartLevel)
            end
        end)
        
        if not success then
            warn("[SESSION] Error al inicializar datos")
        end
    end)
end

-- Obtener nivel actual (método robusto)
function Session:GetPlayerLevel()
    local success, result = pcall(function()
        local data = Services.LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Level") then
            return data.Level.Value
        end
        return 0
    end)
    return success and result or 0
end

-- Obtener Beli actual
function Session:GetPlayerBeli()
    local success, result = pcall(function()
        local data = Services.LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Beli") then
            return data.Beli.Value
        end
        return 0
    end)
    return success and result or 0
end

-- Obtener Fragmentos actuales
function Session:GetPlayerFragments()
    local success, result = pcall(function()
        local data = Services.LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Fragments") then
            return data.Fragments.Value
        end
        return 0
    end)
    return success and result or 0
end

-- Obtener FPS real (método probado)
function Session:GetRealFPS()
    local success, fps = pcall(function()
        local RunService = game:GetService("RunService")
        local lastTick = tick()
        RunService.RenderStepped:Wait()
        local delta = tick() - lastTick
        return math.floor(1 / delta)
    end)
    return success and fps or 60
end

-- Obtener Ping real (método probado)
function Session:GetRealPing()
    local success, ping = pcall(function()
        -- Método 1: Stats service
        local Stats = game:GetService("Stats")
        local network = Stats:FindFirstChild("Network")
        if network then
            local serverStats = network:FindFirstChild("ServerStatsItem")
            if serverStats then
                local dataPing = serverStats:FindFirstChild("Data Ping")
                if dataPing then
                    return math.floor(dataPing:GetValue())
                end
            end
        end
        
        -- Método 2: PerformanceStats
        local perfStats = Stats:FindFirstChild("PerformanceStats")
        if perfStats then
            local ping = perfStats:FindFirstChild("Ping")
            if ping then
                return math.floor(ping:GetValue())
            end
        end
        
        return 0
    end)
    return success and ping or 0
end

-- Obtener hora actual de Lima, Perú (UTC-5)
function Session:GetLimaTime()
    local utcTime = os.time()
    -- Lima está en UTC-5 (sin horario de verano en Perú)
    local limaOffset = -5 * 3600
    local limaTime = utcTime + limaOffset
    return os.date("!%H:%M:%S", limaTime)
end

-- Actualización principal
function Session:Update()
    -- Uptime (tiempo desde inicio)
    local elapsed = os.time() - self.StartTime
    local hours = math.floor(elapsed / 3600)
    local mins = math.floor((elapsed % 3600) / 60)
    local secs = elapsed % 60
    self.Uptime = string.format("%02d:%02d:%02d", hours, mins, secs)
    
    -- FPS real (dinámico)
    self.FPS = self:GetRealFPS()
    
    -- Ping real
    self.Ping = self:GetRealPing()
    
    -- Estadísticas actuales
    self.CurrentLevel = self:GetPlayerLevel()
    self.CurrentBeli = self:GetPlayerBeli()
    self.CurrentFragments = self:GetPlayerFragments()
    
    -- Calcular ganancias
    if self.CurrentLevel > 0 and self.StartLevel > 0 then
        self.LevelsGained = math.max(0, self.CurrentLevel - self.StartLevel)
    end
    if self.CurrentBeli > 0 and self.StartBeli > 0 then
        self.BeliEarned = math.max(0, self.CurrentBeli - self.StartBeli)
    end
    if self.CurrentFragments > 0 and self.StartFragments > 0 then
        self.FragmentsEarned = math.max(0, self.CurrentFragments - self.StartFragments)
    end
end

function Session:AddMobKill()
    self.MobsKilled = self.MobsKilled + 1
end

function Session:AddBossKill()
    self.BossesKilled = self.BossesKilled + 1
end

return Session
