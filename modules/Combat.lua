--[[
    BLOXY HUB TITANIUM - MÓDULO: COMBAT
    Sistema de combate avanzado - CORREGIDO
]]

local Combat = {
    LastAttack = 0,
    AttackCooldown = 0.05
}

-- Dependencias
local Services, Config, Utils, Session

function Combat:Init(deps)
    Services = deps.Services
    Config = deps.Config
    Utils = deps.Utils
    Session = deps.Session
end

function Combat:FastAttack()
    if not Config.Combat.FastAttack then return end
    
    local currentTime = tick()
    if currentTime - self.LastAttack < self.AttackCooldown then return end
    self.LastAttack = currentTime
    
    local char = Utils:GetCharacter()
    if not char then return end
    
    -- Método 1: Activar herramienta equipada
    pcall(function()
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end)
    
    -- Método 2: Click virtual
    pcall(function()
        local VirtualUser = Services.VirtualUser
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
        task.wait(0.01)
        VirtualUser:Button1Up(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
    end)
    
    -- Método 3: Fireclient combat (Blox Fruits específico)
    pcall(function()
        local args = {
            [1] = "SwingSword"
        }
        local remotes = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local remote = remotes:FindFirstChild("CommF_")
            if remote then
                remote:InvokeServer(unpack(args))
            end
        end
    end)
end

function Combat:AttackEnemy(enemy)
    if not enemy then return end
    
    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
    local enemyHum = enemy:FindFirstChild("Humanoid")
    
    if not enemyHRP or not enemyHum then return end
    if enemyHum.Health <= 0 then return end
    
    -- Verificar lag
    if Utils:IsLagging() then 
        Session.Status = "Lag detectado - Pausando..."
        return 
    end
    
    local rootPart = Utils:GetRootPart()
    if not rootPart then return end
    
    local dist = (rootPart.Position - enemyHRP.Position).Magnitude
    
    -- Actualizar status
    Session.Status = "Atacando: " .. enemy.Name .. " (" .. math.floor(dist) .. "m)"
    
    -- Teletransportar cerca del enemigo
    local attackPos = enemyHRP.CFrame * CFrame.new(0, 0, -3)
    Utils:TeleportTo(attackPos, false)
    
    -- Mirar al enemigo
    pcall(function()
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, enemyHRP.Position)
    end)
    
    -- Atacar
    self:FastAttack()
    
    -- Verificar si murió
    task.delay(0.1, function()
        if enemyHum.Health <= 0 then
            Session:AddMobKill()
        end
    end)
end

function Combat:ExecuteMasteryFinisher(enemy)
    if not Config.Mastery.Enabled or not enemy then return end
    
    local enemyHum = enemy:FindFirstChild("Humanoid")
    if not enemyHum then return end
    
    local healthPercent = (enemyHum.Health / enemyHum.MaxHealth) * 100
    
    if healthPercent <= Config.Mastery.FinishAtHealth then
        -- Equipar arma de mastery
        local weaponName = Config.AIMastery.SelectedWeapon or Config.Mastery.Weapon
        Utils:Equip(weaponName)
        
        task.wait(0.1)
        
        -- Usar habilidades si está habilitado
        if Config.Mastery.UseSkills then
            pcall(function()
                Services.VirtualUser:SetKeyDown("z")
                task.wait(0.15)
                Services.VirtualUser:SetKeyUp("z")
            end)
        end
    end
end

function Combat:KillAura()
    if not Config.Combat.KillAura then return end
    
    local enemies = Utils:GetEnemiesInRange(Config.Combat.Range)
    
    for _, enemy in ipairs(enemies) do
        self:AttackEnemy(enemy)
        task.wait(0.05)
    end
end

return Combat
