--[[
    BLOXY HUB TITANIUM - MÓDULO: UTILS
    Funciones de utilidad general - CORREGIDO
]]

local Utils = {}

-- Dependencias (se inyectan desde el loader)
local Services, Config, I18n

function Utils:Init(deps)
    Services = deps.Services
    Config = deps.Config
    I18n = deps.I18n
end

-- ═══════════════════════════════════════════════════════════════
-- CACHÉ ESPACIAL (Optimización de CPU)
-- ═══════════════════════════════════════════════════════════════

local EnemyCache = {
    LastUpdate = 0,
    CacheTime = 0.5,
    Enemies = {}
}

function Utils:GetCharacter()
    local char = Services.LocalPlayer.Character
    if not char then
        char = Services.LocalPlayer.CharacterAdded:Wait()
    end
    return char
end

function Utils:GetHumanoid()
    local char = self:GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

function Utils:GetRootPart()
    local char = self:GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function Utils:GetClosestEnemy(maxDistance)
    maxDistance = maxDistance or 500
    local rootPart = self:GetRootPart()
    if not rootPart then return nil, math.huge end
    
    local currentTime = tick()
    
    -- Actualizar caché si expiró
    if currentTime - EnemyCache.LastUpdate > EnemyCache.CacheTime then
        EnemyCache.Enemies = {}
        
        local folder = Services.Workspace:FindFirstChild("Enemies")
        if folder then
            for _, enemy in pairs(folder:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                    if enemy.Humanoid.Health > 0 then
                        table.insert(EnemyCache.Enemies, enemy)
                    end
                end
            end
        end
        EnemyCache.LastUpdate = currentTime
    end
    
    -- Buscar el más cercano
    local closest = nil
    local closestDist = maxDistance
    
    for _, enemy in pairs(EnemyCache.Enemies) do
        if enemy and enemy.Parent and enemy:FindFirstChild("HumanoidRootPart") then
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local dist = (rootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closest = enemy
                    closestDist = dist
                end
            end
        end
    end
    
    return closest, closestDist
end

function Utils:GetEnemiesInRange(range)
    local rootPart = self:GetRootPart()
    if not rootPart then return {} end
    
    local inRange = {}
    self:GetClosestEnemy(range) -- Actualiza caché
    
    for _, enemy in pairs(EnemyCache.Enemies) do
        if enemy and enemy.Parent and enemy:FindFirstChild("HumanoidRootPart") then
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local dist = (rootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if dist <= range then
                    table.insert(inRange, enemy)
                end
            end
        end
    end
    return inRange
end

function Utils:GetEnemyByName(name)
    local enemies = Services.Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    for _, enemy in pairs(enemies:GetChildren()) do
        if enemy.Name == name then
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                return enemy
            end
        end
    end
    return nil
end

-- TELEPORT MEJORADO - Con loop para mantener posición
function Utils:TeleportTo(cframe, safeMode)
    local rootPart = self:GetRootPart()
    if not rootPart then return false end
    
    local targetCFrame = cframe
    if safeMode then
        targetCFrame = cframe * CFrame.new(0, Config.AutoFarm.Distance or 15, 0)
    end
    
    -- Teletransportar múltiples veces para evitar que el juego te regrese
    for i = 1, 5 do
        pcall(function()
            rootPart.CFrame = targetCFrame
            
            -- También mover la velocidad a 0 para evitar deslizamiento
            local humanoid = self:GetHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
        task.wait(0.05)
    end
    
    return true
end

-- Teleport continuo (para farming)
function Utils:TeleportToLoop(cframe, duration)
    duration = duration or 0.5
    local startTime = tick()
    
    while tick() - startTime < duration do
        self:TeleportTo(cframe, false)
        task.wait()
    end
end

function Utils:Equip(toolName)
    local char = self:GetCharacter()
    local humanoid = self:GetHumanoid()
    if not humanoid then return end
    
    pcall(function()
        if toolName == "Melee" or toolName == "Combat" then
            -- Buscar herramienta de melee
            for _, tool in pairs(Services.LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool.ToolTip == "Melee" or tool.Name == "Combat" or 
                       string.find(tool.Name:lower(), "combat") or
                       string.find(tool.Name:lower(), "melee") then
                        humanoid:EquipTool(tool)
                        print("[UTILS] Equipado: " .. tool.Name)
                        return
                    end
                end
            end
            
            -- Si no encuentra, equipar la primera herramienta
            local firstTool = Services.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if firstTool then
                humanoid:EquipTool(firstTool)
                print("[UTILS] Equipado (fallback): " .. firstTool.Name)
            end
        else
            -- Buscar por nombre exacto
            local tool = Services.LocalPlayer.Backpack:FindFirstChild(toolName)
            if tool then
                humanoid:EquipTool(tool)
                print("[UTILS] Equipado: " .. toolName)
            else
                -- Buscar por nombre parcial
                for _, t in pairs(Services.LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name:lower(), toolName:lower()) then
                        humanoid:EquipTool(t)
                        print("[UTILS] Equipado (parcial): " .. t.Name)
                        return
                    end
                end
            end
        end
    end)
end

function Utils:GetCurrentWorld()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1, "First Sea"
    elseif placeId == 4442272183 then return 2, "Second Sea"
    elseif placeId == 7449423635 then return 3, "Third Sea"
    else return 0, "Unknown" end
end

function Utils:IsLagging()
    local success, ping = pcall(function()
        local stats = game:GetService("Stats")
        return stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return success and ping > 500
end

function Utils:Translate(key)
    local lang = (Config and Config.UI and Config.UI.Language) or "Spanish"
    local dict = I18n.Dictionary[lang] or I18n.Dictionary["Spanish"]
    return dict[key] or key
end

-- WindUI es inyectado externamente
local WindUI = nil

function Utils:SetWindUI(ui)
    WindUI = ui
end

function Utils:Notify(title, message, duration)
    if not Config.UI.Notifications then return end
    
    if WindUI then
        WindUI:Notify({
            Title = title,
            Content = message,
            Duration = duration or 3,
            Icon = "bell"
        })
    end
    print(string.format("[NOTIFY] %s: %s", title, message))
end

-- Función para obtener info del jugador (para footer)
function Utils:GetPlayerInfo()
    local player = Services.LocalPlayer
    return {
        Name = player.DisplayName,
        Username = "@" .. player.Name,
        UserId = player.UserId,
        Thumbnail = string.format(
            "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png",
            player.UserId
        )
    }
end

return Utils
