--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              BLOXY HUB TITANIUM V2.0                         ║
    ║         Código Completo (Basado en Banana Hub)               ║
    ║                    UI: WindUI Premium                        ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- VALIDACIÓN
-- ═══════════════════════════════════════════════════════════════

local id = game.PlaceId
local First_Sea, Second_Sea, Third_Sea = false, false, false

if id == 2753915549 then First_Sea = true 
elseif id == 4442272183 then Second_Sea = true 
elseif id == 7449423635 then Third_Sea = true 
else 
    warn("[BLOXY HUB] Este script solo funciona en Blox Fruits")
    return 
end

print("[BLOXY HUB] Iniciando...")

-- ═══════════════════════════════════════════════════════════════
-- SERVICIOS
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ═══════════════════════════════════════════════════════════════
-- VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════════

_G.FastDelay = 0.05
_G.AutoLevel = false
_G.AutoNear = false
_G.AutoBoss = false
_G.SafeMode = true
_G.InfiniteJump = false
_G.AutoBuso = false
_G.AutoTerrorshark = false
_G.AutoShark = false
_G.AutoFishCrew = false
_G.AutoSeaBeast = false

local SelectWeapon = "Combat"
local ChooseWeapon = "Melee"
local TweenSpeed = 340
local posY = 10
local SelectedBoss = ""
local WalkSpeedValue = 16
local JumpPowerValue = 50

-- Quest vars
local NameQuest, NameMon, QuestLv, CFrameQ, Ms = "", "", 1, CFrame.new(), ""

-- Session
local SessionStart = os.time()
local StartLevel = 0
pcall(function() StartLevel = LocalPlayer.Data.Level.Value end)

-- ═══════════════════════════════════════════════════════════════
-- LISTAS
-- ═══════════════════════════════════════════════════════════════

local tableMon, tableBoss, IslandList = {}, {}, {}

if First_Sea then
    tableMon = {"Bandit","Monkey","Gorilla","Pirate","Brute","Desert Bandit","Desert Officer","Snow Bandit","Snowman","Chief Petty Officer","Sky Bandit","Dark Master","Prisoner","Dangerous Prisoner","Toga Warrior","Gladiator","Military Soldier","Military Spy","Fishman Warrior","Fishman Commando","God's Guard","Shanda","Royal Squad","Royal Soldier","Galley Pirate","Galley Captain"}
    tableBoss = {"The Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Saber Expert"}
    IslandList = {"Jungle","Buggy","Desert","Snow","Marine","Sky","Prison","Colosseum","Magma","Fishman","Sky Island","Fountain"}
elseif Second_Sea then
    tableMon = {"Raider","Mercenary","Swan Pirate","Factory Staff","Marine Lieutenant","Marine Captain","Zombie","Vampire","Snow Trooper","Winter Warrior","Lab Subordinate","Horned Warrior","Magma Ninja","Lava Pirate","Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior","Snow Lurker","Sea Soldier","Water Fighter"}
    tableBoss = {"Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral","Cursed Captain","Darkbeard","Order","Awakened Ice Admiral","Tide Keeper"}
    IslandList = {"Area 1","Area 2","Zombie","Marine","Snow Mountain","Ice fire","Ship","Frost","Forgotten"}
elseif Third_Sea then
    tableMon = {"Pirate Millionaire","Dragon Crew Warrior","Dragon Crew Archer","Female Islander","Giant Islander","Marine Commodore","Marine Rear Admiral","Fishman Raider","Fishman Captain","Forest Pirate","Mythological Pirate","Jungle Pirate","Musketeer Pirate","Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy","Peanut Scout","Peanut President","Ice Cream Chef","Ice Cream Commander","Cookie Crafter","Cake Guard","Baking Staff","Head Baker","Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel","Candy Pirate","Snow Demon","Isle Outlaw","Island Boy","Isle Champion"}
    tableBoss = {"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","rip_indra True Form","Longma","Soul Reaper","Cake Queen"}
    IslandList = {"Pirate Port","Amazon","Marine Tree","Deep Forest","Haunted Castle","Nut Island","Ice Cream Island","Cake Island","Choco Island","Candy Island","Tiki Outpost"}
end

SelectedBoss = tableBoss[1] or ""

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES HELPER
-- ═══════════════════════════════════════════════════════════════

local function GetWorld()
    if First_Sea then return "First Sea"
    elseif Second_Sea then return "Second Sea"
    elseif Third_Sea then return "Third Sea"
    else return "Unknown" end
end

local function Tween(cf)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (cf.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(dist/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = cf}):Play()
        end
    end)
end

local function CancelTween()
    pcall(function()
        Tween(LocalPlayer.Character.HumanoidRootPart.CFrame)
    end)
end

local function EquipWeapon()
    pcall(function()
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == ChooseWeapon then
                SelectWeapon = tool.Name
                LocalPlayer.Character.Humanoid:EquipTool(tool)
                return
            end
        end
        -- Fallback: equip any melee
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == "Melee" then
                SelectWeapon = tool.Name
                LocalPlayer.Character.Humanoid:EquipTool(tool)
                return
            end
        end
    end)
end

local function AutoHaki()
    pcall(function()
        if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- COMBATFRAMEWORK
-- ═══════════════════════════════════════════════════════════════

local CbFw, CbFw2

pcall(function()
    CbFw = debug.getupvalues(require(LocalPlayer.PlayerScripts.CombatFramework))
    CbFw2 = CbFw[2]
end)

local function GetBlade()
    local success, result = pcall(function()
        local p13 = CbFw2.activeController
        local ret = p13.blades[1]
        if not ret then return nil end
        while ret.Parent ~= LocalPlayer.Character do ret = ret.Parent end
        return ret
    end)
    return success and result or nil
end

local function AttackNoCoolDown()
    local success = pcall(function()
        local AC = CbFw2.activeController
        local bladehit = require(ReplicatedStorage.CombatFramework.RigLib).getBladeHits(LocalPlayer.Character, {LocalPlayer.Character.HumanoidRootPart}, 60)
        local cac, hash = {}, {}
        for _, v in pairs(bladehit) do
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
            pcall(function() for _, v in pairs(AC.animator.anims.basic) do v:Play() end end)
            local blade = GetBlade()
            if LocalPlayer.Character:FindFirstChildOfClass("Tool") and AC.blades and AC.blades[1] and blade then
                ReplicatedStorage.RigControllerEvent:FireServer("weaponChange", tostring(blade))
                ReplicatedStorage.Remotes.Validator:FireServer(math.floor(u12 / 1099511627776 * 16777215), u10)
                ReplicatedStorage.RigControllerEvent:FireServer("hit", bladehit, 1, "")
            end
        end
    end)
    if not success then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- CARGAR QUEST DATA
-- ═══════════════════════════════════════════════════════════════

print("[BLOXY HUB] Cargando sistema de quests...")
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NGUYENVUDUY1/Opfile/main/Ch%C6%B0a%20c%C3%B3%20ti%C3%AAu%20%C4%91%E1%BB%81.txt"))()
end)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NGUYENVUDUY1/Tptv/main/Gpat.txt"))()
end)

-- ═══════════════════════════════════════════════════════════════
-- LOOPS DE FARMING
-- ═══════════════════════════════════════════════════════════════

-- Noclip
spawn(function()
    RunService.Stepped:Connect(function()
        if _G.AutoLevel or _G.AutoNear or _G.AutoBoss then
            pcall(function()
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end)
        end
    end)
end)

-- BodyClip
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoLevel or _G.AutoNear or _G.AutoBoss then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                        local bc = Instance.new("BodyVelocity")
                        bc.Name = "BodyClip"
                        bc.MaxForce = Vector3.new(100000, 100000, 100000)
                        bc.Velocity = Vector3.new(0, 0, 0)
                        bc.Parent = LocalPlayer.Character.HumanoidRootPart
                    end
                end
            else
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local bc = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip")
                    if bc then bc:Destroy() end
                end
            end
        end)
    end
end)

-- Auto Level
spawn(function()
    while task.wait() do
        if _G.AutoLevel then
            pcall(function()
                CheckLevel()
                local questGui = LocalPlayer.PlayerGui.Main.Quest
                if not questGui.Visible or not string.find(questGui.Container.QuestTitle.Title.Text, NameMon) then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                    Tween(CFrameQ)
                    if (CFrameQ.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestLv)
                    end
                else
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == Ms and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait(_G.FastDelay)
                                AttackNoCoolDown()
                                AutoHaki()
                                EquipWeapon()
                                Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, posY, 0))
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                            until not _G.AutoLevel or not v.Parent or v.Humanoid.Health <= 0 or not questGui.Visible
                        end
                    end
                    for _, v in pairs(Workspace["_WorldOrigin"].EnemySpawns:GetChildren()) do
                        if string.find(v.Name, NameMon) then
                            if (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude >= 10 then
                                Tween(v.CFrame * CFrame.new(0, posY, 0))
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Near
spawn(function()
    while task.wait(0.1) do
        if _G.AutoNear then
            pcall(function()
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        if (LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 5000 then
                            repeat task.wait(_G.FastDelay)
                                AttackNoCoolDown()
                                AutoHaki()
                                EquipWeapon()
                                Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, posY, 0))
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                            until not _G.AutoNear or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Boss
spawn(function()
    while task.wait() do
        if _G.AutoBoss and SelectedBoss ~= "" then
            pcall(function()
                if Workspace.Enemies:FindFirstChild(SelectedBoss) then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == SelectedBoss and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait(_G.FastDelay)
                                AttackNoCoolDown()
                                AutoHaki()
                                EquipWeapon()
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                                Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                                pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                            until not _G.AutoBoss or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                else
                    if ReplicatedStorage:FindFirstChild(SelectedBoss) then
                        Tween(ReplicatedStorage[SelectedBoss].HumanoidRootPart.CFrame * CFrame.new(5, 10, 7))
                    end
                end
            end)
        end
    end
end)

-- Safe Mode
spawn(function()
    while task.wait() do
        if _G.SafeMode then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local hp = LocalPlayer.Character.Humanoid.Health / LocalPlayer.Character.Humanoid.MaxHealth * 100
                    if hp < 25 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 150, 0)
                    end
                end
            end)
        end
    end
end)

-- Movement Loop
RunService.Heartbeat:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if WalkSpeedValue > 16 then LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue end
            if JumpPowerValue > 50 then LocalPlayer.Character.Humanoid.JumpPower = JumpPowerValue end
        end
    end)
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

-- Auto Buso
spawn(function()
    while task.wait(1) do
        if _G.AutoBuso then AutoHaki() end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- CARGAR UI
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

-- ═══════════════════════════════════════════════════════════════
-- TAB: DASHBOARD
-- ═══════════════════════════════════════════════════════════════

local DashTab = Window:Tab({ Title = "Dashboard", Icon = "home" })
DashTab:Section({ Title = "🎮 BLOXY HUB TITANIUM" })
DashTab:Section({ Title = "Script profesional para Blox Fruits" })

local StateSection = DashTab:Section({ Title = "📊 Info", Box = true })

StateSection:Button({
    Title = "📊 Ver Stats",
    Callback = function()
        local lvl = 0; pcall(function() lvl = LocalPlayer.Data.Level.Value end)
        local beli = 0; pcall(function() beli = LocalPlayer.Data.Beli.Value end)
        local frags = "N/A"; pcall(function() if not First_Sea then frags = tostring(LocalPlayer.Data.Fragments.Value) end end)
        local uptime = os.date("!%H:%M:%S", os.time() - SessionStart)
        WindUI:Notify({
            Title = "Stats",
            Content = string.format("Nivel: %d | Beli: %d | Frags: %s\nMundo: %s | Uptime: %s", lvl, beli, frags, GetWorld(), uptime),
            Duration = 5
        })
    end
})

local ProfileSection = DashTab:Section({ Title = "👤 " .. LocalPlayer.DisplayName, Box = true })
ProfileSection:Section({ Title = "@" .. LocalPlayer.Name })

-- ═══════════════════════════════════════════════════════════════
-- TAB: AUTO FARM
-- ═══════════════════════════════════════════════════════════════

local FarmTab = Window:Tab({ Title = "Auto Farm", Icon = "zap" })
FarmTab:Section({ Title = "⚙️ Configuración" })

FarmTab:Dropdown({
    Title = "Fast Attack Speed",
    Values = {"0.01", "0.05", "0.015", "0.001", "0.1", "0.005", "0", "0.02"},
    Value = "0.05",
    Callback = function(v) _G.FastDelay = tonumber(v) or 0.05 end
})

FarmTab:Dropdown({
    Title = "Weapon Type",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Value = "Melee",
    Callback = function(v) ChooseWeapon = v end
})

FarmTab:Section({ Title = "🎯 Auto Farm" })

FarmTab:Toggle({
    Title = "Auto Farm Level",
    Default = false,
    Callback = function(v) _G.AutoLevel = v if not v then CancelTween() end end
})

FarmTab:Toggle({
    Title = "Kill Near Mobs",
    Default = false,
    Callback = function(v) _G.AutoNear = v if not v then CancelTween() end end
})

FarmTab:Toggle({
    Title = "Safe Mode (run at low HP)",
    Default = true,
    Callback = function(v) _G.SafeMode = v end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: BOSS
-- ═══════════════════════════════════════════════════════════════

local BossTab = Window:Tab({ Title = "Boss Farm", Icon = "skull" })
BossTab:Section({ Title = "👹 Boss Farm" })

BossTab:Dropdown({
    Title = "Select Boss",
    Values = tableBoss,
    Callback = function(v) SelectedBoss = v end
})

BossTab:Toggle({
    Title = "Auto Kill Boss",
    Default = false,
    Callback = function(v) _G.AutoBoss = v if not v then CancelTween() end end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: SEA EVENTS (Third Sea)
-- ═══════════════════════════════════════════════════════════════

local SeaTab = Window:Tab({ Title = "Sea Events", Icon = "anchor" })

if Third_Sea then
    SeaTab:Section({ Title = "🌊 Rough Sea" })
    SeaTab:Toggle({ Title = "Auto Terrorshark", Default = false, Callback = function(v) _G.AutoTerrorshark = v end })
    SeaTab:Toggle({ Title = "Auto Shark", Default = false, Callback = function(v) _G.AutoShark = v end })
    SeaTab:Toggle({ Title = "Auto Fish Crew", Default = false, Callback = function(v) _G.AutoFishCrew = v end })
    SeaTab:Section({ Title = "🦊 Kitsune" })
    SeaTab:Button({
        Title = "Teleport to Kitsune Island",
        Callback = function()
            pcall(function()
                if Workspace.Map:FindFirstChild("KitsuneIsland") then
                    for _, v in pairs(Workspace.Map.KitsuneIsland:GetDescendants()) do
                        if v:IsA("BasePart") and v.Name:find("NeonShrinePart") then
                            Tween(v.CFrame); break
                        end
                    end
                end
            end)
        end
    })
    
    -- Sea loops
    spawn(function()
        while task.wait() do
            if _G.AutoTerrorshark or _G.AutoShark or _G.AutoFishCrew then
                pcall(function()
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        local target = (_G.AutoTerrorshark and v.Name == "Terrorshark") or (_G.AutoShark and v.Name == "Shark") or (_G.AutoFishCrew and v.Name == "Fish Crew Member")
                        if target and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            repeat task.wait(_G.FastDelay)
                                AttackNoCoolDown()
                                AutoHaki()
                                EquipWeapon()
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                            until (not _G.AutoTerrorshark and not _G.AutoShark and not _G.AutoFishCrew) or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                end)
            end
        end
    end)
else
    SeaTab:Section({ Title = "⚠️ Solo disponible en Third Sea" })
end

-- ═══════════════════════════════════════════════════════════════
-- TAB: STATS
-- ═══════════════════════════════════════════════════════════════

local StatsTab = Window:Tab({ Title = "Stats", Icon = "plus-circle" })
StatsTab:Section({ Title = "📈 Auto Stats" })

local StatToggles = { Melee = false, Defense = false, Sword = false, Gun = false, ["Blox Fruit"] = false }

StatsTab:Toggle({ Title = "Melee", Default = false, Callback = function(v) StatToggles.Melee = v end })
StatsTab:Toggle({ Title = "Defense", Default = false, Callback = function(v) StatToggles.Defense = v end })
StatsTab:Toggle({ Title = "Sword", Default = false, Callback = function(v) StatToggles.Sword = v end })
StatsTab:Toggle({ Title = "Gun", Default = false, Callback = function(v) StatToggles.Gun = v end })
StatsTab:Toggle({ Title = "Blox Fruit", Default = false, Callback = function(v) StatToggles["Blox Fruit"] = v end })

StatsTab:Button({
    Title = "Apply Stats Now",
    Callback = function()
        pcall(function()
            for stat, enabled in pairs(StatToggles) do
                if enabled then
                    local pts = LocalPlayer.Data.Points.Value
                    if pts > 0 then ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, pts) end
                end
            end
            WindUI:Notify({ Title = "Stats", Content = "Puntos distribuidos!", Duration = 3 })
        end)
    end
})

StatsTab:Button({
    Title = "Buy Stats Reset (2500 Frags)",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "1")
            WindUI:Notify({ Title = "Stats", Content = "Reset comprado!", Duration = 3 })
        end)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: PLAYER
-- ═══════════════════════════════════════════════════════════════

local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
PlayerTab:Section({ Title = "🏃 Movement" })

PlayerTab:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(v) WalkSpeedValue = v end
})

PlayerTab:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(v) JumpPowerValue = v end
})

PlayerTab:Section({ Title = "✨ Extras" })
PlayerTab:Toggle({ Title = "Infinite Sky Jump", Default = false, Callback = function(v) _G.InfiniteJump = v end })
PlayerTab:Toggle({ Title = "Auto Buso (Haki)", Default = false, Callback = function(v) _G.AutoBuso = v end })

-- ═══════════════════════════════════════════════════════════════
-- TAB: TELEPORT
-- ═══════════════════════════════════════════════════════════════

local TPTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
TPTab:Section({ Title = "🗺️ Islands" })

local SelectedIsland = IslandList[1] or ""

TPTab:Dropdown({
    Title = "Select Island",
    Values = IslandList,
    Callback = function(v) SelectedIsland = v end
})

TPTab:Button({
    Title = "Teleport to Island",
    Callback = function()
        pcall(function()
            for _, v in pairs(Workspace["_WorldOrigin"].Locations:GetChildren()) do
                if v.Name == SelectedIsland then Tween(v.CFrame); break end
            end
        end)
    end
})

TPTab:Section({ Title = "👤 Players" })

local SelectedPlayer = ""
local PlayerList = {}
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(PlayerList, p.Name) end end

TPTab:Dropdown({
    Title = "Select Player",
    Values = PlayerList,
    Callback = function(v) SelectedPlayer = v end
})

TPTab:Button({
    Title = "Teleport to Player",
    Callback = function()
        pcall(function()
            local t = Players:FindFirstChild(SelectedPlayer)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                for i = 1, 5 do LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame; wait() end
            end
        end)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- TAB: SETTINGS
-- ═══════════════════════════════════════════════════════════════

local SetTab = Window:Tab({ Title = "Settings", Icon = "settings" })
SetTab:Section({ Title = "⚙️ Performance" })

SetTab:Toggle({
    Title = "FPS Boost",
    Default = false,
    Callback = function(v)
        if v then
            pcall(function()
                game.Lighting.GlobalShadows = false
                game.Lighting.FogEnd = 9e9
                settings().Rendering.QualityLevel = "Level01"
                for _, x in pairs(game:GetDescendants()) do
                    if x:IsA("ParticleEmitter") or x:IsA("Trail") then x.Lifetime = NumberRange.new(0) end
                    if x:IsA("Fire") or x:IsA("Smoke") or x:IsA("Sparkles") then x.Enabled = false end
                end
            end)
        end
    end
})

SetTab:Section({ Title = "🔄 Server" })
SetTab:Button({ Title = "Rejoin", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end })
SetTab:Button({ Title = "Leave", Callback = function() LocalPlayer:Kick("Goodbye!") end })

SetTab:Section({ Title = "📋 Info" })
SetTab:Section({ Title = "Version: 2.0" })
SetTab:Section({ Title = "Mundo: " .. GetWorld() })

-- ═══════════════════════════════════════════════════════════════
-- FINALIZAR
-- ═══════════════════════════════════════════════════════════════

-- Remover efectos
pcall(function()
    if ReplicatedStorage.Effect.Container:FindFirstChild("Death") then ReplicatedStorage.Effect.Container.Death:Destroy() end
    if ReplicatedStorage.Effect.Container:FindFirstChild("Respawn") then ReplicatedStorage.Effect.Container.Respawn:Destroy() end
end)

-- Mobile button
local sg = Instance.new("ScreenGui", game.CoreGui)
local ib = Instance.new("ImageButton", sg)
ib.Size = UDim2.new(0, 50, 0, 50)
ib.Position = UDim2.new(0.12, 0, 0.1, 0)
ib.BackgroundColor3 = Color3.new(0, 0, 0)
ib.Draggable = true
ib.Image = "http://www.roblox.com/asset/?id=16601446273"
ib.MouseButton1Down:Connect(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.End, false, game) end)

Window:SelectTab(1)

print("[BLOXY HUB] ✅ Cargado exitosamente!")
WindUI:Notify({ Title = "Bloxy Hub Titanium", Content = "Cargado! Mundo: " .. GetWorld(), Duration = 5 })
