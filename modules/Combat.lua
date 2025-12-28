--[[
    BLOXY HUB TITANIUM - MÓDULO: COMBAT
    Sistema de combate - VERSIÓN ROBUSTA PROBADA
]]

local Combat = {
    LastAttack = 0,
    AttackCooldown = 0.05,
    LastSkill = {}
}

-- Dependencias
local Services, Config, Utils, Session

function Combat:Init(deps)
    Services = deps.Services
    Config = deps.Config
    Utils = deps.Utils
    Session = deps.Session
    
    -- Inicializar cooldowns de skills
    for _, key in ipairs({"Z", "X", "C", "V"}) do
        self.LastSkill[key] = 0
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MÉTODOS DE ATAQUE ROBUSTOS
-- ═══════════════════════════════════════════════════════════════

-- Método 1: Click virtual (más confiable)
function Combat:ClickAttack()
    pcall(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

-- Método 2: VirtualUser
function Combat:VirtualUserAttack()
    pcall(function()
        local VU = game:GetService("VirtualUser")
        VU:CaptureController()
        VU:Button1Down(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
        task.wait(0.01)
        VU:Button1Up(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
    end)
end

-- Método 3: Activar herramienta directamente
function Combat:ToolAttack()
    pcall(function()
        local char = Utils:GetCharacter()
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end)
end

-- Método 4: Remote de combate de Blox Fruits
function Combat:RemoteAttack()
    pcall(function()
        local args = {
            [1] = Services.Workspace.CurrentCamera.CFrame
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("LeftClick", unpack(args))
    end)
end

-- Ataque rápido combinado (usa todos los métodos)
function Combat:FastAttack()
    if not Config.Combat.FastAttack then return end
    
    local currentTime = tick()
    if currentTime - self.LastAttack < (Config.Combat.AttackSpeed or 0.05) then return end
    self.LastAttack = currentTime
    
    -- Ejecutar múltiples métodos de ataque
    self:ToolAttack()
    self:ClickAttack()
    self:RemoteAttack()
end

-- ═══════════════════════════════════════════════════════════════
-- HABILIDADES (Z, X, C, V)
-- ═══════════════════════════════════════════════════════════════

function Combat:UseSkill(key, cooldown)
    cooldown = cooldown or 0.5
    
    local currentTime = tick()
    if currentTime - (self.LastSkill[key] or 0) < cooldown then return false end
    
    pcall(function()
        local VU = game:GetService("VirtualUser")
        VU:CaptureController()
        VU:SetKeyDown(key:lower())
        task.wait(0.1)
        VU:SetKeyUp(key:lower())
    end)
    
    self.LastSkill[key] = currentTime
    return true
end

function Combat:UseAllSkills()
    for _, key in ipairs({"Z", "X", "C", "V"}) do
        if Config.AIMastery.Skills[key] then
            self:UseSkill(key, 0.3)
            task.wait(0.15)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ATACAR ENEMIGO
-- ═══════════════════════════════════════════════════════════════

function Combat:AttackEnemy(enemy)
    if not enemy then return false end
    
    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
    local enemyHum = enemy:FindFirstChild("Humanoid")
    
    if not enemyHRP or not enemyHum then return false end
    if enemyHum.Health <= 0 then 
        Session:AddMobKill()
        return false 
    end
    
    local rootPart = Utils:GetRootPart()
    if not rootPart then return false end
    
    -- Calcular distancia
    local dist = (rootPart.Position - enemyHRP.Position).Magnitude
    
    -- Actualizar status
    Session.Status = "Atacando: " .. enemy.Name
    
    -- Teletransportar cerca del enemigo si está lejos
    if dist > 15 then
        local attackPosition = enemyHRP.CFrame * CFrame.new(0, 0, -5)
        
        -- Usar tostring para hacer el teleport más robusto
        pcall(function()
            for i = 1, 3 do
                rootPart.CFrame = attackPosition
                task.wait()
            end
        end)
    end
    
    -- Mirar al enemigo
    pcall(function()
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, enemyHRP.Position)
    end)
    
    -- Atacar
    self:FastAttack()
    
    -- Usar habilidades si está activo el modo IA
    if Config.AIMastery.Enabled then
        self:UseAllSkills()
    end
    
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- KILL AURA
-- ═══════════════════════════════════════════════════════════════

function Combat:KillAura()
    if not Config.Combat.KillAura then return end
    
    local enemies = Utils:GetEnemiesInRange(Config.Combat.Range or 50)
    
    for _, enemy in ipairs(enemies) do
        if enemy and enemy:FindFirstChild("Humanoid") then
            if enemy.Humanoid.Health > 0 then
                self:AttackEnemy(enemy)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MASTERY FINISHER
-- ═══════════════════════════════════════════════════════════════

function Combat:ExecuteMasteryFinisher(enemy)
    if not Config.Mastery.Enabled or not enemy then return end
    
    local enemyHum = enemy:FindFirstChild("Humanoid")
    if not enemyHum then return end
    
    local healthPercent = (enemyHum.Health / enemyHum.MaxHealth) * 100
    
    if healthPercent <= (Config.Mastery.FinishAtHealth or 20) then
        local weapon = Config.AIMastery.SelectedWeapon or "Melee"
        Utils:Equip(weapon)
        task.wait(0.15)
        
        if Config.Mastery.UseSkills then
            self:UseSkill("Z", 0.2)
        end
    end
end

return Combat
