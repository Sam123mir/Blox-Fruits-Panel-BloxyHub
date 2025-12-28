--[[
    BLOXY HUB TITANIUM - MÓDULO: PLAYER ENHANCEMENTS
    Mejoras del jugador - CORREGIDO
]]

local PlayerEnhancements = {
    SkyjumpConnected = false,
    SpeedConnection = nil
}

-- Dependencias
local Services, Config, Utils

function PlayerEnhancements:Init(deps)
    Services = deps.Services
    Config = deps.Config
    Utils = deps.Utils
end

function PlayerEnhancements:AutoAura()
    if not Config.Player.AutoAura then return end
    
    pcall(function()
        local remotes = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if remotes and remotes:FindFirstChild("CommF_") then
            remotes.CommF_:InvokeServer("Buso")
        end
    end)
end

function PlayerEnhancements:SetupInfiniteSkyjump()
    if self.SkyjumpConnected then return end
    
    Services.UserInputService.JumpRequest:Connect(function()
        if Config.Player.InfiniteSkyjump then
            local humanoid = Utils:GetHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    self.SkyjumpConnected = true
    print("[PLAYER] Infinite Skyjump configurado")
end

function PlayerEnhancements:ApplySpeed()
    local humanoid = Utils:GetHumanoid()
    if not humanoid then return end
    
    -- Aplicar WalkSpeed
    if Config.Player.WalkSpeed and Config.Player.WalkSpeed > 16 then
        humanoid.WalkSpeed = Config.Player.WalkSpeed
    end
    
    -- Aplicar JumpPower
    if Config.Player.JumpPower and Config.Player.JumpPower > 50 then
        humanoid.JumpPower = Config.Player.JumpPower
    end
end

function PlayerEnhancements:SetupSpeedLoop()
    -- Usar un loop constante para mantener la velocidad
    -- porque el juego puede resetearla
    if self.SpeedConnection then return end
    
    self.SpeedConnection = Services.RunService.Heartbeat:Connect(function()
        if Config.Player.WalkSpeed > 16 or Config.Player.JumpPower > 50 then
            self:ApplySpeed()
        end
    end)
    
    print("[PLAYER] Speed loop configurado")
end

function PlayerEnhancements:Update()
    -- Auto Aura
    if Config.Player.AutoAura then
        self:AutoAura()
    end
    
    -- La velocidad se aplica en el loop de Heartbeat
end

function PlayerEnhancements:Cleanup()
    if self.SpeedConnection then
        self.SpeedConnection:Disconnect()
        self.SpeedConnection = nil
    end
end

return PlayerEnhancements
