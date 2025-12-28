--[[
    BLOXY HUB TITANIUM - MÓDULO: UTILS
    Utilidades generales - VERSIÓN ROBUSTA
]]

local Utils = {}

-- Dependencias
local Services, Config, I18n

function Utils:Init(deps)
    Services = deps.Services
    Config = deps.Config
    I18n = deps.I18n
end

-- ═══════════════════════════════════════════════════════════════
-- CACHÉ DE ENEMIGOS
-- ═══════════════════════════════════════════════════════════════

local EnemyCache = {
    LastUpdate = 0,
    CacheTime = 0.3,
    Enemies = {}
}

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES DE PERSONAJE
-- ═══════════════════════════════════════════════════════════════

function Utils:GetCharacter()
    local plr = Services.LocalPlayer
    return plr.Character or plr.CharacterAdded:Wait()
end

function Utils:GetHumanoid()
    local char = self:GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils:GetRootPart()
    local char = self:GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ═══════════════════════════════════════════════════════════════
-- BÚSQUEDA DE ENEMIGOS (ROBUSTA)
-- ═══════════════════════════════════════════════════════════════

function Utils:RefreshEnemyCache()
    EnemyCache.Enemies = {}
    
    local folder = Services.Workspace:FindFirstChild("Enemies")
    if not folder then return end
    
    for _, enemy in pairs(folder:GetChildren()) do
        local hum = enemy:FindFirstChild("Humanoid")
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp and hum.Health > 0 then
            table.insert(EnemyCache.Enemies, enemy)
        end
    end
    
    EnemyCache.LastUpdate = tick()
end

function Utils:GetClosestEnemy(maxDistance)
    maxDistance = maxDistance or 500
    
    local rootPart = self:GetRootPart()
    if not rootPart then return nil, math.huge end
    
    -- Actualizar caché si es necesario
    if tick() - EnemyCache.LastUpdate > EnemyCache.CacheTime then
        self:RefreshEnemyCache()
    end
    
    local closest = nil
    local closestDist = maxDistance
    
    for _, enemy in pairs(EnemyCache.Enemies) do
        if enemy and enemy.Parent then
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            local hum = enemy:FindFirstChild("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (rootPart.Position - hrp.Position).Magnitude
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
    
    -- Actualizar caché
    if tick() - EnemyCache.LastUpdate > EnemyCache.CacheTime then
        self:RefreshEnemyCache()
    end
    
    local inRange = {}
    
    for _, enemy in pairs(EnemyCache.Enemies) do
        if enemy and enemy.Parent then
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            local hum = enemy:FindFirstChild("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (rootPart.Position - hrp.Position).Magnitude
                if dist <= range then
                    table.insert(inRange, enemy)
                end
            end
        end
    end
    
    return inRange
end

function Utils:GetEnemyByName(name)
    local folder = Services.Workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    
    for _, enemy in pairs(folder:GetChildren()) do
        if enemy.Name == name then
            local hum = enemy:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                return enemy
            end
        end
    end
    
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- TELEPORT ROBUSTO
-- ═══════════════════════════════════════════════════════════════

function Utils:TeleportTo(cframe, safeMode)
    local rootPart = self:GetRootPart()
    if not rootPart then return false end
    
    local targetCFrame = cframe
    if safeMode then
        targetCFrame = cframe * CFrame.new(0, 15, 0)
    end
    
    -- Teleport múltiple para evitar que el servidor te regrese
    local success = pcall(function()
        for i = 1, 5 do
            rootPart.CFrame = targetCFrame
            -- Cancelar velocidad para evitar deslizamiento
            rootPart.Velocity = Vector3.new(0, 0, 0)
            if rootPart:FindFirstChild("BodyVelocity") then
                rootPart.BodyVelocity:Destroy()
            end
            task.wait()
        end
    end)
    
    return success
end

function Utils:TeleportToLoop(cframe, duration)
    local startTime = tick()
    duration = duration or 0.5
    
    while tick() - startTime < duration do
        self:TeleportTo(cframe, false)
        task.wait()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- EQUIPAR ARMA (ROBUSTO)
-- ═══════════════════════════════════════════════════════════════

function Utils:Equip(toolName)
    local humanoid = self:GetHumanoid()
    local char = self:GetCharacter()
    if not humanoid or not char then return end
    
    -- Si ya tiene el arma equipada, no hacer nada
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and string.find(currentTool.Name:lower(), toolName:lower()) then
        return
    end
    
    pcall(function()
        local backpack = Services.LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end
        
        if toolName == "Melee" or toolName == "Combat" then
            -- Buscar herramienta de combate cuerpo a cuerpo
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local tt = tool.ToolTip:lower()
                    local nm = tool.Name:lower()
                    
                    if tt == "melee" or nm == "combat" or 
                       string.find(nm, "fist") or string.find(nm, "combat") or
                       string.find(nm, "hand") then
                        humanoid:EquipTool(tool)
                        return
                    end
                end
            end
            
            -- Fallback: equipar la primera herramienta
            local first = backpack:FindFirstChildOfClass("Tool")
            if first then
                humanoid:EquipTool(first)
            end
        else
            -- Buscar por nombre exacto o parcial
            local tool = backpack:FindFirstChild(toolName)
            if tool then
                humanoid:EquipTool(tool)
            else
                for _, t in pairs(backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name:lower(), toolName:lower()) then
                        humanoid:EquipTool(t)
                        return
                    end
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- UTILIDADES GENERALES
-- ═══════════════════════════════════════════════════════════════

function Utils:GetCurrentWorld()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1, "First Sea"
    elseif placeId == 4442272183 then return 2, "Second Sea"
    elseif placeId == 7449423635 then return 3, "Third Sea"
    else return 0, "Unknown" end
end

function Utils:IsLagging()
    local success, ping = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return success and ping > 500
end

function Utils:Translate(key)
    local lang = (Config and Config.UI and Config.UI.Language) or "Spanish"
    local dict = I18n.Dictionary[lang] or I18n.Dictionary["Spanish"]
    return dict[key] or key
end

-- WindUI
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
    print(string.format("[BLOXY HUB] %s: %s", title, message))
end

-- Obtener info del jugador para el footer
function Utils:GetPlayerInfo()
    local player = Services.LocalPlayer
    return {
        Name = player.DisplayName,
        Username = player.Name,
        UserId = player.UserId,
        -- Thumbnail usando el servicio de Roblox correcto
        ThumbnailId = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    }
end

return Utils
