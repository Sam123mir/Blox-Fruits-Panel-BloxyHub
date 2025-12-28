--[[
    BLOXY HUB TITANIUM - MÓDULO: PLAYER ENHANCEMENTS
    Mejoras del jugador - VERSIÓN ROBUSTA
]]

local PlayerEnhancements = {
    SkyjumpConnected = false,
    SpeedConnection = nil,
    AuraConnection = nil
}

-- Dependencias
local Services, Config, Utils

function PlayerEnhancements:Init(deps)
    Services = deps.Services
    Config = deps.Config
    Utils = deps.Utils
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO AURA (HAKI)
-- ═══════════════════════════════════════════════════════════════

function PlayerEnhancements:AutoAura()
    if not Config.Player.AutoAura then return end
    
    pcall(function()
        local remote = Services.ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            local comm = remote:FindFirstChild("CommF_")
            if comm then
                comm:InvokeServer("Buso")
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- INFINITE SKYJUMP
-- ═══════════════════════════════════════════════════════════════

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
end

-- ═══════════════════════════════════════════════════════════════
-- SPEED/JUMP LOOP (ROBUSTO)
-- ═══════════════════════════════════════════════════════════════

function PlayerEnhancements:SetupSpeedLoop()
    if self.SpeedConnection then return end
    
    -- Loop constante para mantener velocidad/salto
    -- El juego de Blox Fruits resetea estos valores constantemente
    self.SpeedConnection = Services.RunService.Heartbeat:Connect(function()
        pcall(function()
            local humanoid = Utils:GetHumanoid()
            if humanoid then
                -- Aplicar velocidad si es mayor que la default
                if Config.Player.WalkSpeed and Config.Player.WalkSpeed > 16 then
                    if humanoid.WalkSpeed ~= Config.Player.WalkSpeed then
                        humanoid.WalkSpeed = Config.Player.WalkSpeed
                    end
                end
                
                -- Aplicar poder de salto si es mayor que la default
                if Config.Player.JumpPower and Config.Player.JumpPower > 50 then
                    if humanoid.JumpPower ~= Config.Player.JumpPower then
                        humanoid.JumpPower = Config.Player.JumpPower
                    end
                end
            end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ACTUALIZACIÓN PRINCIPAL
-- ═══════════════════════════════════════════════════════════════

function PlayerEnhancements:Update()
    -- Auto Aura cada actualización (el juego la desactiva)
    if Config.Player.AutoAura then
        self:AutoAura()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- LIMPIEZA
-- ═══════════════════════════════════════════════════════════════

function PlayerEnhancements:Cleanup()
    if self.SpeedConnection then
        self.SpeedConnection:Disconnect()
        self.SpeedConnection = nil
    end
    
    if self.AuraConnection then
        self.AuraConnection:Disconnect()
        self.AuraConnection = nil
    end
end

return PlayerEnhancements
