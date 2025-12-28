--[[
    BLOXY HUB TITANIUM - MÓDULO: FARMING
    Sistema de auto-farm y gestión de misiones - CORREGIDO
]]

local Farming = {}

-- Dependencias
local Services, Config, Utils, Session, Combat, QuestData

function Farming:Init(deps)
    Services = deps.Services
    Config = deps.Config
    Utils = deps.Utils
    Session = deps.Session
    Combat = deps.Combat
    QuestData = deps.QuestData
end

-- Cache de Quest
local QuestCache = {
    LastUpdate = 0,
    UpdateInterval = 3,
    ActiveQuest = nil
}

function Farming:GetPlayerLevel()
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 1
end

function Farming:GetBestQuest()
    local myLvl = self:GetPlayerLevel()
    local world, _ = Utils:GetCurrentWorld()
    local worldQuests = QuestData[world] or {}
    
    if #worldQuests == 0 then
        print("[FARMING] No hay quests para este mundo: " .. world)
        return nil
    end
    
    local best = worldQuests[1]
    for _, q in ipairs(worldQuests) do
        if myLvl >= q.Level then
            best = q
        end
    end
    
    print("[FARMING] Quest seleccionada: " .. (best.Quest or "ninguna") .. " para nivel " .. myLvl)
    return best
end

function Farming:CheckQuest()
    -- Verificar si hay quest activa
    local playerGui = Services.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    local main = playerGui:FindFirstChild("Main")
    if not main then return false end
    
    local questFrame = main:FindFirstChild("Quest")
    if questFrame and questFrame.Visible then
        return true
    end
    
    -- Método alternativo: verificar quest data
    local plrData = Services.LocalPlayer:FindFirstChild("PlayerGui")
    if plrData then
        local questData = plrData:FindFirstChild("Quest")
        if questData then
            return true
        end
    end
    
    return false
end

function Farming:TakeQuest()
    local currentTime = tick()
    
    -- Si ya hay quest activa, no hacer nada
    if self:CheckQuest() then 
        return true 
    end
    
    -- Evitar spam de peticiones
    if currentTime - QuestCache.LastUpdate < QuestCache.UpdateInterval then
        return false
    end
    
    local best = self:GetBestQuest()
    if not best then 
        Session.Status = "Sin quest disponible para tu nivel"
        return false 
    end
    
    QuestCache.LastUpdate = currentTime
    Session.Status = "Obteniendo Quest: " .. best.Quest
    
    -- Teletransportar al NPC
    print("[FARMING] Teletransportando a NPC de quest...")
    Utils:TeleportToLoop(best.CFrame, 0.5)
    task.wait(0.5)
    
    -- Tomar la quest
    pcall(function()
        local remotes = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if remotes and remotes:FindFirstChild("CommF_") then
            remotes.CommF_:InvokeServer("StartQuest", best.Quest, 1)
            print("[FARMING] Quest iniciada: " .. best.Quest)
        end
    end)
    
    task.wait(0.5)
    return self:CheckQuest()
end

function Farming:AutoLevel()
    if not Config.AutoFarm.Enabled then return end
    if Config.AutoFarm.Mode ~= "Level" then return end
    
    -- Primero verificar si tenemos quest
    if not self:CheckQuest() then
        self:TakeQuest()
        return
    end
    
    local best = self:GetBestQuest()
    if not best then return end
    
    -- Buscar enemigo de la quest o el más cercano
    local enemy = Utils:GetEnemyByName(best.Enemy)
    
    if not enemy then
        -- Si no hay enemigo de quest, teletransportar a la zona
        Session.Status = "Buscando: " .. best.Enemy
        
        -- Teletransportar cerca del NPC de quest (donde spawnean los enemigos)
        Utils:TeleportTo(best.CFrame * CFrame.new(math.random(-50, 50), 0, math.random(-50, 50)), false)
        task.wait(0.5)
        
        -- Buscar de nuevo
        enemy = Utils:GetEnemyByName(best.Enemy) or Utils:GetClosestEnemy(200)
    end
    
    if enemy then
        -- Equipar arma
        Utils:Equip("Melee")
        task.wait(0.1)
        
        -- Atacar
        Combat:AttackEnemy(enemy)
        
        -- Mastery
        if Config.Mastery.Enabled then
            Combat:ExecuteMasteryFinisher(enemy)
        end
    else
        Session.Status = "Esperando respawn de " .. best.Enemy
    end
end

function Farming:AutoMastery()
    if not Config.Mastery.Enabled then return end
    
    -- Equipar arma seleccionada
    local weapon = Config.AIMastery.SelectedWeapon or "Melee"
    Utils:Equip(weapon)
    
    local enemy = Utils:GetClosestEnemy(300)
    
    if enemy then
        Session.Status = "Mastery: " .. enemy.Name
        Combat:AttackEnemy(enemy)
        Combat:ExecuteMasteryFinisher(enemy)
    else
        Session.Status = "Buscando enemigos para mastery..."
    end
end

return Farming
