--[[
    BLOXY HUB TITANIUM - MÓDULO: STATS MANAGER
    Sistema de distribución de stats - CORREGIDO + OPCIÓN DE RESET
]]

local StatsManager = {}

-- Dependencias
local Services, Config, Utils

function StatsManager:Init(deps)
    Services = deps.Services
    Config = deps.Config
    Utils = deps.Utils
end

function StatsManager:GetAvailablePoints()
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if not data then return 0 end
    
    -- Intentar diferentes nombres de la variable
    local pointsVal = data:FindFirstChild("Points") or 
                      data:FindFirstChild("StatsPoints") or
                      data:FindFirstChild("StatPoints")
    
    return pointsVal and pointsVal.Value or 0
end

function StatsManager:DistributePoints(manual)
    if not Config.Stats.Enabled and not manual then return end
    
    local points = self:GetAvailablePoints()
    
    if points <= 0 then 
        if manual then 
            Utils:Notify("Stats", "No tienes puntos disponibles", 2) 
        end
        return 
    end
    
    -- Contar stats activos
    local activeStats = {}
    for stat, enabled in pairs(Config.Stats.Distribution) do
        if enabled then 
            table.insert(activeStats, stat) 
        end
    end
    
    if #activeStats == 0 then 
        if manual then 
            Utils:Notify("Stats", "Selecciona al menos una estadística", 2) 
        end
        return 
    end
    
    local pointsPerStat = math.floor(points / #activeStats)
    
    if pointsPerStat > 0 then
        pcall(function()
            local remotes = Services.ReplicatedStorage:FindFirstChild("Remotes")
            if remotes and remotes:FindFirstChild("CommF_") then
                for _, stat in ipairs(activeStats) do
                    remotes.CommF_:InvokeServer("AddPoint", stat, pointsPerStat)
                    print("[STATS] Agregado " .. pointsPerStat .. " puntos a " .. stat)
                end
            end
        end)
        
        Utils:Notify("Stats", "+" .. (pointsPerStat * #activeStats) .. " puntos distribuidos", 2)
    end
end

-- Función para comprar reset de stats con fragmentos
function StatsManager:BuyStatsReset()
    local fragments = 0
    
    -- Obtener fragmentos actuales
    pcall(function()
        local data = Services.LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Fragments") then
            fragments = data.Fragments.Value
        end
    end)
    
    -- El reset cuesta 2500 fragmentos en Blox Fruits
    local resetCost = 2500
    
    if fragments < resetCost then
        Utils:Notify("Stats", "Necesitas " .. resetCost .. " fragmentos. Tienes: " .. fragments, 3)
        return false
    end
    
    -- Intentar comprar el reset
    local success = pcall(function()
        local remotes = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if remotes and remotes:FindFirstChild("CommF_") then
            remotes.CommF_:InvokeServer("BlackbeardReward", "Reset", "Stats")
            -- Alternativa:
            -- remotes.CommF_:InvokeServer("BuyItem", "StatsRefund")
        end
    end)
    
    if success then
        Utils:Notify("Stats", "¡Stats reseteados!", 3)
        return true
    else
        Utils:Notify("Stats", "Error al resetear stats", 3)
        return false
    end
end

return StatsManager
