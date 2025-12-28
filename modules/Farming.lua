--[[
    BLOXY HUB TITANIUM - MÓDULO: FARMING
    Sistema de auto-farm - VERSIÓN ROBUSTA PROBADA
]]

local Farming = {
    CurrentQuest = nil,
    QuestEnemy = nil,
    IsGettingQuest = false
}

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

-- ═══════════════════════════════════════════════════════════════
-- OBTENER DATOS DEL JUGADOR
-- ═══════════════════════════════════════════════════════════════

function Farming:GetPlayerLevel()
    local success, result = pcall(function()
        return Services.LocalPlayer:FindFirstChild("Data"):FindFirstChild("Level").Value
    end)
    return success and result or 1
end

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE QUESTS ROBUSTO
-- ═══════════════════════════════════════════════════════════════

function Farming:GetBestQuest()
    local myLevel = self:GetPlayerLevel()
    local world, _ = Utils:GetCurrentWorld()
    local quests = QuestData[world] or {}
    
    if #quests == 0 then return nil end
    
    local best = quests[1]
    for _, q in ipairs(quests) do
        if myLevel >= q.Level then
            best = q
        end
    end
    
    return best
end

-- Verificar si hay quest activa (método robusto)
function Farming:HasQuest()
    local success, result = pcall(function()
        local plrGui = Services.LocalPlayer:FindFirstChild("PlayerGui")
        if not plrGui then return false end
        
        local main = plrGui:FindFirstChild("Main")
        if not main then return false end
        
        local quest = main:FindFirstChild("Quest")
        if quest and quest.Visible then
            return true
        end
        
        return false
    end)
    
    return success and result or false
end

-- Tomar quest usando el remote correcto
function Farming:TakeQuest()
    if self.IsGettingQuest then return false end
    if self:HasQuest() then return true end
    
    self.IsGettingQuest = true
    
    local best = self:GetBestQuest()
    if not best then 
        self.IsGettingQuest = false
        return false 
    end
    
    Session.Status = "Tomando quest: " .. (best.Quest or "Unknown")
    
    -- Teletransportar al NPC de quest
    pcall(function()
        local rootPart = Utils:GetRootPart()
        if rootPart then
            for i = 1, 10 do
                rootPart.CFrame = best.CFrame
                task.wait(0.05)
            end
        end
    end)
    
    task.wait(0.3)
    
    -- Tomar la quest usando el remote
    pcall(function()
        local remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            local comm = remote:FindFirstChild("CommF_")
            if comm then
                comm:InvokeServer("StartQuest", best.Quest, 1)
            end
        end
    end)
    
    task.wait(0.5)
    
    -- Guardar info de la quest
    self.CurrentQuest = best
    self.QuestEnemy = best.Enemy
    
    self.IsGettingQuest = false
    return self:HasQuest()
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO FARM PRINCIPAL
-- ═══════════════════════════════════════════════════════════════

function Farming:AutoLevel()
    if not Config.AutoFarm.Enabled then return end
    
    -- Primero verificar si tenemos quest
    if not self:HasQuest() then
        self:TakeQuest()
        return
    end
    
    -- Buscar enemigo de la quest actual
    local targetEnemy = self.QuestEnemy
    local enemy = nil
    
    if targetEnemy then
        enemy = Utils:GetEnemyByName(targetEnemy)
    end
    
    -- Si no hay enemigo de quest, buscar el más cercano
    if not enemy then
        enemy = Utils:GetClosestEnemy(500)
    end
    
    -- Si hay enemigo, atacar
    if enemy then
        local enemyHum = enemy:FindFirstChild("Humanoid")
        if enemyHum and enemyHum.Health > 0 then
            -- Equipar arma
            Utils:Equip("Melee")
            task.wait(0.05)
            
            -- Atacar
            Combat:AttackEnemy(enemy)
            
            -- Mastery finisher
            if Config.Mastery.Enabled then
                Combat:ExecuteMasteryFinisher(enemy)
            end
        end
    else
        -- No hay enemigos, teletransportar a la zona de la quest
        if self.CurrentQuest and self.CurrentQuest.CFrame then
            Session.Status = "Buscando: " .. (self.QuestEnemy or "enemigos")
            
            -- Teleport a zona de spawn de enemigos
            local spawnPos = self.CurrentQuest.CFrame * CFrame.new(
                math.random(-30, 30), 
                0, 
                math.random(-30, 30)
            )
            
            Utils:TeleportTo(spawnPos, false)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO MASTERY
-- ═══════════════════════════════════════════════════════════════

function Farming:AutoMastery()
    if not Config.Mastery.Enabled then return end
    
    -- Equipar arma de mastery
    local weapon = Config.AIMastery.SelectedWeapon or "Melee"
    Utils:Equip(weapon)
    
    -- Buscar enemigo
    local enemy = Utils:GetClosestEnemy(500)
    
    if enemy then
        local enemyHum = enemy:FindFirstChild("Humanoid")
        if enemyHum and enemyHum.Health > 0 then
            Session.Status = "Mastery: " .. enemy.Name
            
            -- Atacar
            Combat:AttackEnemy(enemy)
            
            -- Usar habilidades si está activo
            if Config.AIMastery.Enabled then
                Combat:UseAllSkills()
            end
        end
    else
        Session.Status = "Buscando enemigos para mastery..."
    end
end

return Farming
