--[[
    BLOXY HUB TITANIUM - UI: TAB STATS
    Distribución de estadísticas - CORREGIDO + RESET
]]

local StatsTab = {}

function StatsTab:Create(Window, deps)
    local Utils = deps.Utils
    local Config = deps.Config
    local StatsManager = deps.StatsManager
    local Colors = deps.Colors
    
    local Tab = Window:Tab({
        Title = Utils:Translate("Stats"),
        Icon = "solar:chart-bold",
        IconColor = Colors.Green,
        IconShape = "Square",
        Border = true
    })
    
    -- Sección Distribución
    local DistSection = Tab:Section({
        Title = Utils:Translate("StatDistribution"),
        Box = true,
        BoxBorder = true,
        Opened = true
    })
    
    DistSection:Toggle({
        Title = "🥊 Melee",
        Default = Config.Stats.Distribution.Melee,
        Flag = "StatMelee",
        Callback = function(value)
            Config.Stats.Distribution.Melee = value
        end
    })
    
    DistSection:Space()
    
    DistSection:Toggle({
        Title = "🛡️ Defense",
        Default = Config.Stats.Distribution.Defense,
        Flag = "StatDefense",
        Callback = function(value)
            Config.Stats.Distribution.Defense = value
        end
    })
    
    DistSection:Space()
    
    DistSection:Toggle({
        Title = "⚔️ Sword",
        Default = Config.Stats.Distribution.Sword,
        Flag = "StatSword",
        Callback = function(value)
            Config.Stats.Distribution.Sword = value
        end
    })
    
    DistSection:Space()
    
    DistSection:Toggle({
        Title = "🔫 Gun",
        Default = Config.Stats.Distribution.Gun,
        Flag = "StatGun",
        Callback = function(value)
            Config.Stats.Distribution.Gun = value
        end
    })
    
    DistSection:Space()
    
    DistSection:Toggle({
        Title = "🍎 Blox Fruit",
        Default = Config.Stats.Distribution["Blox Fruit"],
        Flag = "StatFruit",
        Callback = function(value)
            Config.Stats.Distribution["Blox Fruit"] = value
        end
    })
    
    Tab:Space({ Columns = 2 })
    
    -- Controles
    local ControlSection = Tab:Section({
        Title = "⚙️ Controles",
        Box = true,
        BoxBorder = true,
        Opened = true
    })
    
    ControlSection:Toggle({
        Title = Utils:Translate("AutoStatsLoop"),
        Desc = "Distribuye puntos automáticamente cada 5 segundos",
        Default = Config.Stats.Enabled,
        Flag = "AutoStats",
        Callback = function(value)
            Config.Stats.Enabled = value
        end
    })
    
    ControlSection:Space()
    
    ControlSection:Button({
        Title = Utils:Translate("ApplyPoints"),
        Color = Colors.Green,
        Icon = "zap",
        Callback = function()
            StatsManager:DistributePoints(true)
        end
    })
    
    Tab:Space({ Columns = 2 })
    
    -- Sección Reset de Stats
    local ResetSection = Tab:Section({
        Title = "🔄 Resetear Estadísticas",
        Box = true,
        BoxBorder = true,
        Opened = true
    })
    
    ResetSection:Section({
        Title = "Costo: 2500 Fragmentos",
        TextSize = 12,
        TextTransparency = 0.4
    })
    
    ResetSection:Space()
    
    ResetSection:Button({
        Title = "💎 Comprar Reset de Stats",
        Color = Colors.Purple,
        Icon = "refresh-cw",
        Callback = function()
            StatsManager:BuyStatsReset()
        end
    })
    
    return Tab
end

return StatsTab
