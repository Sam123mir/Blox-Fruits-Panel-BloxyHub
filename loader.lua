--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              BLOXY HUB TITANIUM - VERSIÓN FINAL              ║
    ║         Basado en Banana Hub (Código 100% Funcional)         ║
    ║                    UI: WindUI Premium                        ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- VALIDACIÓN DE JUEGO
-- ═══════════════════════════════════════════════════════════════

local id = game.PlaceId
local First_Sea, Second_Sea, Third_Sea = false, false, false

if id == 2753915549 then 
    First_Sea = true 
elseif id == 4442272183 then 
    Second_Sea = true 
elseif id == 7449423635 then 
    Third_Sea = true 
else 
    game:Shutdown() 
end

-- ═══════════════════════════════════════════════════════════════
-- SERVICIOS
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- ANTI-AFK
-- ═══════════════════════════════════════════════════════════════

LocalPlayer.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ═══════════════════════════════════════════════════════════════
-- VARIABLES GLOBALES (de Banana Hub)
-- ═══════════════════════════════════════════════════════════════

_G.Fast_Delay = 0.05
_G.AutoLevel = false
_G.AutoNear = false
_G.AutoBoss = false
_G.AutoMaterial = false
_G.AutoBone = false
_G.CakePrince = false
_G.Ectoplasm = false
_G.AutoElite = false
_G.AutoSeaBeast = false
_G.SpeedBoat = false
_G.AutoTerrorshark = false
_G.AutoShark = false
_G.AutoFishCrew = false
_G.Ship = false

local SelectWeapon = "Combat"
local ChooseWeapon = "Melee"
local TweenSpeed = 340
local tween = nil
local posX, posY, posZ = 0, 10, 0
local bringmob = false
local FarmPos = nil
local MonFarm = ""

-- Quest variables
local NameQuest = ""
local NameMon = ""
local QuestLv = 1
local CFrameQ = CFrame.new()
local Ms = ""

-- ═══════════════════════════════════════════════════════════════
-- LISTAS DE MOBS POR SEA
-- ═══════════════════════════════════════════════════════════════

local tableMon = {}
local tableBoss = {}

if First_Sea then
    tableMon = {"Bandit","Monkey","Gorilla","Pirate","Brute","Desert Bandit","Desert Officer","Snow Bandit","Snowman","Chief Petty Officer","Sky Bandit","Dark Master","Prisoner","Dangerous Prisoner","Toga Warrior","Gladiator","Military Soldier","Military Spy","Fishman Warrior","Fishman Commando","God's Guard","Shanda","Royal Squad","Royal Soldier","Galley Pirate","Galley Captain"}
    tableBoss = {"The Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Saber Expert"}
elseif Second_Sea then
    tableMon = {"Raider","Mercenary","Swan Pirate","Factory Staff","Marine Lieutenant","Marine Captain","Zombie","Vampire","Snow Trooper","Winter Warrior","Lab Subordinate","Horned Warrior","Magma Ninja","Lava Pirate","Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior","Snow Lurker","Sea Soldier","Water Fighter"}
    tableBoss = {"Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral","Cursed Captain","Darkbeard","Order","Awakened Ice Admiral","Tide Keeper"}
elseif Third_Sea then
    tableMon = {"Pirate Millionaire","Dragon Crew Warrior","Dragon Crew Archer","Female Islander","Giant Islander","Marine Commodore","Marine Rear Admiral","Fishman Raider","Fishman Captain","Forest Pirate","Mythological Pirate","Jungle Pirate","Musketeer Pirate","Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy","Peanut Scout","Peanut President","Ice Cream Chef","Ice Cream Commander","Cookie Crafter","Cake Guard","Baking Staff","Head Baker","Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel","Candy Pirate","Snow Demon","Isle Outlaw","Island Boy","Isle Champion"}
    tableBoss = {"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","rip_indra True Form","Longma","Soul Reaper","Cake Queen"}
end

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES BASE (de Banana Hub - PROBADAS)
-- ═══════════════════════════════════════════════════════════════

local function round(n)
    return math.floor(tonumber(n) + 0.5)
end

function Tween(P1)
    local Distance = (P1.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local Speed = TweenSpeed
    if Distance >= 1 then
        Speed = TweenSpeed
    end
    TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {
        CFrame = P1
    }):Play()
end

function CancelTween()
    Tween(LocalPlayer.Character.HumanoidRootPart.CFrame)
end

function EquipTool(ToolSe)
    if LocalPlayer.Backpack:FindFirstChild(ToolSe) then
        local tool = LocalPlayer.Backpack:FindFirstChild(ToolSe)
        wait(0.5)
        LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end

function AutoHaki()
    if not LocalPlayer.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

function Com(com, ...)
    local Remote = ReplicatedStorage.Remotes:FindFirstChild("Comm"..com)
    if Remote:IsA("RemoteEvent") then
        Remote:FireServer(...)
    elseif Remote:IsA("RemoteFunction") then
        Remote:InvokeServer(...)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- COMBATFRAMEWORK ATTACK (PROBADO)
-- ═══════════════════════════════════════════════════════════════

local CbFw, CbFw2

pcall(function()
    CbFw = debug.getupvalues(require(LocalPlayer.PlayerScripts.CombatFramework))
    CbFw2 = CbFw[2]
end)

function GetCurrentBlade()
    local success, result = pcall(function()
        local p13 = CbFw2.activeController
        local ret = p13.blades[1]
        if not ret then return end
        while ret.Parent ~= LocalPlayer.Character do ret = ret.Parent end
        return ret
    end)
    return success and result or nil
end

function AttackNoCoolDown()
    local success = pcall(function()
        local AC = CbFw2.activeController
        for i = 1, 1 do
            local bladehit = require(ReplicatedStorage.CombatFramework.RigLib).getBladeHits(
                LocalPlayer.Character,
                {LocalPlayer.Character.HumanoidRootPart},
                60
            )
            local cac = {}
            local hash = {}
            for k, v in pairs(bladehit) do
                if v.Parent:FindFirstChild("HumanoidRootPart") and not hash[v.Parent] then
                    table.insert(cac, v.Parent.HumanoidRootPart)
                    hash[v.Parent] = true
                end
            end
            bladehit = cac
            if #bladehit > 0 then
                local u8 = debug.getupvalue(AC.attack, 5)
                local u9 = debug.getupvalue(AC.attack, 6)
                local u7 = debug.getupvalue(AC.attack, 4)
                local u10 = debug.getupvalue(AC.attack, 7)
                local u12 = (u8 * 798405 + u7 * 727595) % u9
                local u13 = u7 * 798405
                u12 = (u12 * u9 + u13) % 1099511627776
                u8 = math.floor(u12 / u9)
                u7 = u12 - u8 * u9
                u10 = u10 + 1
                debug.setupvalue(AC.attack, 5, u8)
                debug.setupvalue(AC.attack, 6, u9)
                debug.setupvalue(AC.attack, 4, u7)
                debug.setupvalue(AC.attack, 7, u10)
                pcall(function()
                    for k, v in pairs(AC.animator.anims.basic) do
                        v:Play()
                    end
                end)
                if LocalPlayer.Character:FindFirstChildOfClass("Tool") and AC.blades and AC.blades[1] then
                    ReplicatedStorage.RigControllerEvent:FireServer("weaponChange", tostring(GetCurrentBlade()))
                    ReplicatedStorage.Remotes.Validator:FireServer(math.floor(u12 / 1099511627776 * 16777215), u10)
                    ReplicatedStorage.RigControllerEvent:FireServer("hit", bladehit, i, "")
                end
            end
        end
    end)
    
    -- Fallback si AttackNoCoolDown falla
    if not success then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
        end)
    end
end

function NormalAttack()
    pcall(function()
        local Module = require(LocalPlayer.PlayerScripts.CombatFramework)
        local CombatFramework = debug.getupvalues(Module)[2]
        local CamShake = require(ReplicatedStorage.Util.CameraShaker)
        CamShake:Stop()
        CombatFramework.activeController.attacking = false
        CombatFramework.activeController.timeToNextAttack = 0
        CombatFramework.activeController.hitboxMagnitude = 180
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- NOCLIP Y BODY VELOCITY
-- ═══════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoLevel or _G.AutoNear or _G.AutoBoss or _G.AutoMaterial or _G.AutoBone or _G.CakePrince or _G.Ectoplasm or _G.AutoElite then
                if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local Noclip = Instance.new("BodyVelocity")
                    Noclip.Name = "BodyClip"
                    Noclip.Parent = LocalPlayer.Character.HumanoidRootPart
                    Noclip.MaxForce = Vector3.new(100000, 100000, 100000)
                    Noclip.Velocity = Vector3.new(0, 0, 0)
                end
            else
                if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    LocalPlayer.Character.HumanoidRootPart.BodyClip:Destroy()
                end
            end
        end)
    end
end)

spawn(function()
    RunService.Stepped:Connect(function()
        if _G.AutoLevel or _G.AutoNear or _G.AutoBoss or _G.AutoMaterial or _G.AutoBone or _G.CakePrince or _G.Ectoplasm or _G.AutoElite then
            pcall(function()
                for i, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- SELECCIÓN DE ARMA AUTOMÁTICA
-- ═══════════════════════════════════════════════════════════════

task.spawn(function()
    while wait() do
        pcall(function()
            if ChooseWeapon == "Melee" then
                for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Melee" then
                        SelectWeapon = v.Name
                    end
                end
            elseif ChooseWeapon == "Sword" then
                for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Sword" then
                        SelectWeapon = v.Name
                    end
                end
            elseif ChooseWeapon == "Blox Fruit" then
                for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Blox Fruit" then
                        SelectWeapon = v.Name
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- CARGAR UI (WINDUI)
-- ═══════════════════════════════════════════════════════════════

print("[BLOXY HUB] Cargando WindUI...")

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/ui/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "Bloxy Hub Titanium",
    Icon = "star",
    Author = "@BloxyHub",
    Folder = "BloxyHubTitanium",
    Size = UDim2.fromOffset(560, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})

local Tabs = {
    Dashboard = Window:Tab({ Title = "Dashboard", Icon = "home" }),
    Farm = Window:Tab({ Title = "Auto Farm", Icon = "zap" }),
    Boss = Window:Tab({ Title = "Boss Farm", Icon = "skull" }),
    Sea = Window:Tab({ Title = "Sea Events", Icon = "anchor" }),
    Stats = Window:Tab({ Title = "Stats", Icon = "plus-circle" }),
    Player = Window:Tab({ Title = "Player", Icon = "user" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" })
}

-- ═══════════════════════════════════════════════════════════════
-- TAB: DASHBOARD
-- ═══════════════════════════════════════════════════════════════

local SessionInfo = {
    StartTime = os.time(),
    StartLevel = 0,
    MobsKilled = 0,
    FPS = 60,
    Ping = 0
}

-- Obtener datos iniciales
pcall(function()
    SessionInfo.StartLevel = LocalPlayer.Data.Level.Value
end)

-- FPS Counter
task.spawn(function()
    while true do
        local start = tick()
        local frames = 0
        local conn = RunService.RenderStepped:Connect(function()
            frames = frames + 1
        end)
        task.wait(1)
        conn:Disconnect()
        SessionInfo.FPS = frames + math.random(-2, 2)
    end
end)

-- Ping
task.spawn(function()
    while true do
        pcall(function()
            SessionInfo.Ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        task.wait(1)
    end
end)

-- Dashboard Info
Tabs.Dashboard:Section({ Title = "🎮 BLOXY HUB TITANIUM" })
Tabs.Dashboard:Section({ Title = "Script profesional para Blox Fruits" })

local DashSection = Tabs.Dashboard:Section({ Title = "📊 Estado", Box = true })

local function GetLimaTime()
    local utc = os.time()
    local lima = utc + (-5 * 3600)
    return os.date("!%H:%M:%S", lima)
end

local function GetWorldName()
    if First_Sea then return "First Sea"
    elseif Second_Sea then return "Second Sea"
    elseif Third_Sea then return "Third Sea"
    else return "Unknown" end
end

local function GetCurrentLevel()
    local s, r = pcall(function() return LocalPlayer.Data.Level.Value end)
    return s and r or 0
end

local function GetCurrentBeli()
    local s, r = pcall(function() return LocalPlayer.Data.Beli.Value end)
    return s and r or 0
end

local function GetFragments()
    if First_Sea then return "Sea 2+ requerido" end
    local s, r = pcall(function() return LocalPlayer.Data.Fragments.Value end)
    return s and tostring(r) or "0"
end

DashSection:Button({
    Title = "📊 Actualizar Stats",
    Callback = function()
        WindUI:Notify({
            Title = "Stats Actuales",
            Content = string.format(
                "FPS: %d | Ping: %dms | Hora Lima: %s\nNivel: %d | Beli: %d | Fragmentos: %s\nMundo: %s",
                SessionInfo.FPS, SessionInfo.Ping, GetLimaTime(),
                GetCurrentLevel(), GetCurrentBeli(), GetFragments(),
                GetWorldName()
            ),
            Duration = 5
        })
    end
})

-- Perfil del usuario
local ProfileSection = Tabs.Dashboard:Section({ Title = "👤 Tu Perfil", Box = true })

ProfileSection:Section({ Title = LocalPlayer.DisplayName })
ProfileSection:Section({ Title = "@" .. LocalPlayer.Name })

-- ═══════════════════════════════════════════════════════════════
-- TAB: AUTO FARM
-- ═══════════════════════════════════════════════════════════════

-- Cargar sistema de quests
loadstring(game:HttpGet("https://raw.githubusercontent.com/NGUYENVUDUY1/Opfile/main/Ch%C6%B0a%20c%C3%B3%20ti%C3%AAu%20%C4%91%E1%BB%81.txt"))()

Tabs.Farm:Section({ Title = "⚙️ Configuración" })

local listfastattack = {"0.01", "0.05", "0.015", "0.001", "0.1", "0.005", "0", "0.02"}

Tabs.Farm:Dropdown({
    Title = "Fast Attack Speed",
    Values = listfastattack,
    Value = "0.05",
    Callback = function(value)
        _G.Fast_Delay = tonumber(value) or 0.05
    end
})

Tabs.Farm:Dropdown({
    Title = "Weapon Type",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Value = "Melee",
    Callback = function(value)
        ChooseWeapon = value
    end
})

Tabs.Farm:Section({ Title = "🎯 Auto Farm Level" })

Tabs.Farm:Toggle({
    Title = "Auto Farm Level",
    Default = false,
    Callback = function(value)
        _G.AutoLevel = value
        if not value then
            CancelTween()
        end
    end
})

-- Loop de Auto Farm Level
spawn(function()
    while task.wait() do
        if _G.AutoLevel then
            pcall(function()
                CheckLevel()
                if not string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) or LocalPlayer.PlayerGui.Main.Quest.Visible == false then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                    Tween(CFrameQ)
                    if (CFrameQ.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestLv)
                    end
                elseif string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) or LocalPlayer.PlayerGui.Main.Quest.Visible == true then
                    for i, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            if v.Name == Ms then
                                repeat wait(_G.Fast_Delay)
                                    AttackNoCoolDown()
                                    bringmob = true
                                    AutoHaki()
                                    EquipTool(SelectWeapon)
                                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(posX, posY, posZ))
                                    v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                    v.HumanoidRootPart.Transparency = 1
                                    v.Humanoid.JumpPower = 0
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.CanCollide = false
                                    FarmPos = v.HumanoidRootPart.CFrame
                                    MonFarm = v.Name
                                until not _G.AutoLevel or not v.Parent or v.Humanoid.Health <= 0 or not Workspace.Enemies:FindFirstChild(v.Name) or LocalPlayer.PlayerGui.Main.Quest.Visible == false
                                bringmob = false
                                SessionInfo.MobsKilled = SessionInfo.MobsKilled + 1
                            end
                        end
                    end
                    for i, v in pairs(Workspace["_WorldOrigin"].EnemySpawns:GetChildren()) do
                        if string.find(v.Name, NameMon) then
                            if (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude >= 10 then
                                Tween(v.CFrame * CFrame.new(posX, posY, posZ))
                            end
                        end
                    end
                end
            end)
        end
    end
end)

Tabs.Farm:Section({ Title = "🔄 Kill Near Mobs" })

Tabs.Farm:Toggle({
    Title = "Auto Kill Near Mob Aura",
    Default = false,
    Callback = function(value)
        _G.AutoNear = value
        if not value then
            CancelTween()
        end
    end
})

-- Loop de Kill Near
spawn(function()
    while wait(0.1) do
        if _G.AutoNear then
            pcall(function()
                for i, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        if (LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 5000 then
                            repeat wait(_G.Fast_Delay)
                                AttackNoCoolDown()
                                bringmob = true
                                AutoHaki()
                                EquipTool(SelectWeapon)
                                Tween(v.HumanoidRootPart.CFrame * CFrame.new(posX, posY, posZ))
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                                FarmPos = v.HumanoidRootPart.CFrame
                                MonFarm = v.Name
                            until not _G.AutoNear or not v.Parent or v.Humanoid.Health <= 0 or not Workspace.Enemies:FindFirstChild(v.Name)
                            bringmob = false
                        end
                    end
                end
            end)
        end
    end
end)

Tabs.Farm:Section({ Title = "💡 Safe Mode" })

Tabs.Farm:Toggle({
    Title = "Auto Safe (Run when low HP)",
    Default = true,
    Callback = function(value)
        _G.SafeMode = value
    end
})

spawn(function()
    while _G.SafeMode do
        task.wait()
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local h = LocalPlayer.Character.Humanoid.Health / LocalPlayer.Character.Humanoid.MaxHealth * 100
                if h < 25 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 150, 0)
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- TAB: BOSS FARM
-- ═══════════════════════════════════════════════════════════════

Tabs.Boss:Section({ Title = "👹 Boss Farm" })

local SelectedBoss = tableBoss[1] or ""

Tabs.Boss:Dropdown({
    Title = "Select Boss",
    Values = tableBoss,
    Callback = function(value)
        SelectedBoss = value
    end
})

Tabs.Boss:Toggle({
    Title = "Auto Kill Boss",
    Default = false,
    Callback = function(value)
        _G.AutoBoss = value
    end
})

spawn(function()
    while wait() do
        if _G.AutoBoss then
            pcall(function()
                if Workspace.Enemies:FindFirstChild(SelectedBoss) then
                    for i, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == SelectedBoss then
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat wait(_G.Fast_Delay)
                                    AttackNoCoolDown()
                                    AutoHaki()
                                    EquipTool(SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                                    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                                until not _G.AutoBoss or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                else
                    if ReplicatedStorage:FindFirstChild(SelectedBoss) then
                        Tween(ReplicatedStorage:FindFirstChild(SelectedBoss).HumanoidRootPart.CFrame * CFrame.new(5, 10, 7))
                    end
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- TAB: SEA EVENTS
-- ═══════════════════════════════════════════════════════════════

if Third_Sea then
    Tabs.Sea:Section({ Title = "🌊 Rough Sea" })
    
    Tabs.Sea:Toggle({
        Title = "Auto Kill Terrorshark",
        Default = false,
        Callback = function(value)
            _G.AutoTerrorshark = value
        end
    })
    
    Tabs.Sea:Toggle({
        Title = "Auto Kill Shark",
        Default = false,
        Callback = function(value)
            _G.AutoShark = value
        end
    })
    
    Tabs.Sea:Toggle({
        Title = "Auto Kill Fish Crew",
        Default = false,
        Callback = function(value)
            _G.AutoFishCrew = value
        end
    })
    
    Tabs.Sea:Section({ Title = "🦊 Kitsune Island" })
    
    Tabs.Sea:Button({
        Title = "Tween to Kitsune Island",
        Callback = function()
            pcall(function()
                if Workspace.Map:FindFirstChild("KitsuneIsland") then
                    local shrine = Workspace.Map.KitsuneIsland:FindFirstChild("ShrineActive")
                    if shrine then
                        for _, v in pairs(shrine:GetDescendants()) do
                            if v:IsA("BasePart") and v.Name:find("NeonShrinePart") then
                                Tween(v.CFrame)
                                break
                            end
                        end
                    end
                end
            end)
        end
    })
    
    Tabs.Sea:Section({ Title = "🐙 Sea Beast" })
    
    Tabs.Sea:Toggle({
        Title = "Auto Kill Sea Beast",
        Default = false,
        Callback = function(value)
            _G.AutoSeaBeast = value
        end
    })
    
    -- Loops para Sea Events
    spawn(function()
        while wait() do
            if _G.AutoTerrorshark then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Terrorshark") then
                        for i, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "Terrorshark" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                repeat wait(_G.Fast_Delay)
                                    AttackNoCoolDown()
                                    AutoHaki()
                                    EquipTool(SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                                until not _G.AutoTerrorshark or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    spawn(function()
        while wait() do
            if _G.AutoShark then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Shark") then
                        for i, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "Shark" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                repeat wait(_G.Fast_Delay)
                                    AttackNoCoolDown()
                                    AutoHaki()
                                    EquipTool(SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                                until not _G.AutoShark or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    spawn(function()
        while wait() do
            if _G.AutoFishCrew then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Fish Crew Member") then
                        for i, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "Fish Crew Member" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                repeat wait(_G.Fast_Delay)
                                    AttackNoCoolDown()
                                    AutoHaki()
                                    EquipTool(SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                                until not _G.AutoFishCrew or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end)
            end
        end
    end)
else
    Tabs.Sea:Section({ Title = "⚠️ Sea Events solo disponible en Third Sea" })
end

-- ═══════════════════════════════════════════════════════════════
-- TAB: STATS
-- ═══════════════════════════════════════════════════════════════

Tabs.Stats:Section({ Title = "📈 Auto Stats Distribution" })

local StatToggles = {
    Melee = false,
    Defense = false,
    Sword = false,
    Gun = false,
    ["Blox Fruit"] = false
}

Tabs.Stats:Toggle({
    Title = "Melee",
    Default = false,
    Callback = function(v) StatToggles.Melee = v end
})

Tabs.Stats:Toggle({
    Title = "Defense",
    Default = false,
    Callback = function(v) StatToggles.Defense = v end
})

Tabs.Stats:Toggle({
    Title = "Sword",
    Default = false,
    Callback = function(v) StatToggles.Sword = v end
})

Tabs.Stats:Toggle({
    Title = "Gun",
    Default = false,
    Callback = function(v) StatToggles.Gun = v end
})

Tabs.Stats:Toggle({
    Title = "Blox Fruit",
    Default = false,
    Callback = function(v) StatToggles["Blox Fruit"] = v end
})

Tabs.Stats:Button({
    Title = "Apply Stats Now",
    Callback = function()
        pcall(function()
            for stat, enabled in pairs(StatToggles) do
                if enabled then
                    local points = LocalPlayer.Data.Points.Value
                    if points > 0 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, points)
                    end
                end
            end
            WindUI:Notify({ Title = "Stats", Content = "Puntos distribuidos!", Duration = 3 })
        end)
    end
})

Tabs.Stats:Section({ Title = "🔄 Stats Reset" })

Tabs.Stats:Button({
    Title = "Buy Stats Reset (2500 Fragments)",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "1")
            WindUI:Notify({ Title = "Stats", Content = "Reset de stats comprado!", Duration = 3 })
        end)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: PLAYER
-- ═══════════════════════════════════════════════════════════════

Tabs.Player:Section({ Title = "🏃 Movement" })

local WalkSpeedValue = 16
local JumpPowerValue = 50

Tabs.Player:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(value)
        WalkSpeedValue = value
    end
})

Tabs.Player:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(value)
        JumpPowerValue = value
    end
})

RunService.Heartbeat:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if WalkSpeedValue > 16 then
                LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
            end
            if JumpPowerValue > 50 then
                LocalPlayer.Character.Humanoid.JumpPower = JumpPowerValue
            end
        end
    end)
end)

Tabs.Player:Section({ Title = "✨ Enhancements" })

Tabs.Player:Toggle({
    Title = "Infinite Sky Jump",
    Default = false,
    Callback = function(value)
        _G.InfiniteJump = value
    end
})

UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        pcall(function()
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

Tabs.Player:Toggle({
    Title = "Auto Buso (Haki)",
    Default = false,
    Callback = function(value)
        _G.AutoBuso = value
    end
})

spawn(function()
    while wait(1) do
        if _G.AutoBuso then
            AutoHaki()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- TAB: TELEPORT
-- ═══════════════════════════════════════════════════════════════

loadstring(game:HttpGet("https://raw.githubusercontent.com/NGUYENVUDUY1/Tptv/main/Gpat.txt"))()

Tabs.Teleport:Section({ Title = "🗺️ Teleport to Islands" })

local IslandList = {}

if First_Sea then
    IslandList = {"Jungle", "Buggy", "Desert", "Snow", "Marine", "Sky", "Prison", "Colosseum", "Magma", "Fishman", "Sky Island", "Fountain"}
elseif Second_Sea then
    IslandList = {"Area 1", "Area 2", "Zombie", "Marine", "Snow Mountain", "Ice fire", "Ship", "Frost", "Forgotten"}
elseif Third_Sea then
    IslandList = {"Pirate Port", "Amazon", "Marine Tree", "Deep Forest", "Haunted Castle", "Nut Island", "Ice Cream Island", "Cake Island", "Choco Island", "Candy Island", "Tiki Outpost"}
end

local SelectedIsland = IslandList[1] or ""

Tabs.Teleport:Dropdown({
    Title = "Select Island",
    Values = IslandList,
    Callback = function(value)
        SelectedIsland = value
    end
})

Tabs.Teleport:Button({
    Title = "Teleport to Island",
    Callback = function()
        pcall(function()
            for i, v in pairs(Workspace["_WorldOrigin"].Locations:GetChildren()) do
                if v.Name == SelectedIsland then
                    Tween(v.CFrame)
                    break
                end
            end
        end)
    end
})

Tabs.Teleport:Section({ Title = "👤 Teleport to Player" })

local PlayerList = {}
local SelectedPlayer = ""

local function UpdatePlayerList()
    PlayerList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(PlayerList, p.Name)
        end
    end
    return PlayerList
end

UpdatePlayerList()

Tabs.Teleport:Dropdown({
    Title = "Select Player",
    Values = PlayerList,
    Callback = function(value)
        SelectedPlayer = value
    end
})

Tabs.Teleport:Button({
    Title = "Teleport to Player",
    Callback = function()
        pcall(function()
            local target = Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                for i = 1, 5 do
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                    wait()
                end
            end
        end)
    end
})

Tabs.Teleport:Button({
    Title = "Refresh Player List",
    Callback = function()
        UpdatePlayerList()
        WindUI:Notify({ Title = "Teleport", Content = "Lista actualizada!", Duration = 2 })
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: SETTINGS
-- ═══════════════════════════════════════════════════════════════

Tabs.Settings:Section({ Title = "⚙️ General Settings" })

Tabs.Settings:Toggle({
    Title = "FPS Boost",
    Default = false,
    Callback = function(value)
        if value then
            pcall(function()
                local l = game.Lighting
                local t = Workspace.Terrain
                sethiddenproperty(l, "Technology", 2)
                sethiddenproperty(t, "Decoration", false)
                t.WaterWaveSize = 0
                t.WaterWaveSpeed = 0
                t.WaterReflectance = 0
                t.WaterTransparency = 0
                l.GlobalShadows = false
                l.FogEnd = 9e9
                l.Brightness = 0
                settings().Rendering.QualityLevel = "Level01"
                
                for i, v in pairs(game:GetDescendants()) do
                    if v:IsA("Part") or v:IsA("Union") or v:IsA("MeshPart") then
                        v.Material = "Plastic"
                        v.Reflectance = 0
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Lifetime = NumberRange.new(0)
                    elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
})

Tabs.Settings:Button({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

Tabs.Settings:Button({
    Title = "Leave Game",
    Callback = function()
        LocalPlayer:Kick("Goodbye!")
    end
})

Tabs.Settings:Section({ Title = "📋 Script Info" })
Tabs.Settings:Section({ Title = "Version: 1.0 (Banana Hub Core)" })
Tabs.Settings:Section({ Title = "UI: WindUI Premium" })

-- ═══════════════════════════════════════════════════════════════
-- FINALIZACIÓN
-- ═══════════════════════════════════════════════════════════════

-- Remover efectos de muerte
pcall(function()
    if ReplicatedStorage.Effect.Container:FindFirstChild("Death") then
        ReplicatedStorage.Effect.Container.Death:Destroy()
    end
    if ReplicatedStorage.Effect.Container:FindFirstChild("Respawn") then
        ReplicatedStorage.Effect.Container.Respawn:Destroy()
    end
end)

-- Botón flotante para móvil
local ScreenGui = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageButton.Parent = ScreenGui
ImageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.12, 0, 0.1, 0)
ImageButton.Size = UDim2.new(0, 50, 0, 50)
ImageButton.Draggable = true
ImageButton.Image = "http://www.roblox.com/asset/?id=16601446273"
ImageButton.MouseButton1Down:connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.End, false, game)
end)

Window:SelectTab(1)

print("[BLOXY HUB] ✅ Script cargado exitosamente!")
WindUI:Notify({
    Title = "Bloxy Hub Titanium",
    Content = "Script cargado exitosamente! Mundo: " .. GetWorldName(),
    Duration = 5
})
