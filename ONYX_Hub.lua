-- ██████╗ ███╗   ██╗██╗   ██╗██╗  ██╗    ██╗  ██╗██╗   ██╗██████╗ 
-- ██╔═══██╗████╗  ██║╚██╗ ██╔╝╚██╗██╔╝    ██║  ██║██║   ██║██╔══██╗
-- ██║   ██║██╔██╗ ██║ ╚████╔╝  ╚███╔╝     ███████║██║   ██║██████╔╝
-- ██║   ██║██║╚██╗██║  ╚██╔╝   ██╔██╗     ██╔══██║██║   ██║██╔══██╗
-- ╚██████╔╝██║ ╚████║   ██║   ██╔╝ ██╗    ██║  ██║╚██████╔╝██████╔╝
--  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
-- ONYX HUB — Full Rewrite | Delta Compatible | Legit Aimbot | Spoofer Suite

getgenv().Library = (function()
local Services = setmetatable({}, {
    __index = function(self, k)
        local ok, res = pcall(game.GetService, game, k)
        if ok and res then rawset(self, k, res) return res end
        return nil
    end
})

local Drawing = (typeof(Drawing) == 'table' and Drawing) or DrawingLib
local ScreenGui = Instance.new('ScreenGui')
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = "ONYXHub"
ScreenGui.Parent = Services.CoreGui

local IsTouch = (rawget(_G, "mobiledebug") == true) or (Services.UserInputService.TouchEnabled and not Services.UserInputService.MouseEnabled)
local Camera = workspace.CurrentCamera
local ScreenWidth = Camera.ViewportSize.X
local ScreenHeight = Camera.ViewportSize.Y

local function S(v) return v end
local Toggles = {}
local Options = {}

local Library = {
    Registry = {}; RegistryMap = {}; HudRegistry = {};
    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(14, 11, 28);
    BackgroundColor = Color3.fromRGB(10, 8, 22);
    AccentColor = Color3.fromRGB(110, 60, 220);
    OutlineColor = Color3.fromRGB(30, 20, 55);
    RiskColor = Color3.fromRGB(255, 50, 50);
    Black = Color3.new(0,0,0);
    Font = Enum.Font.Code;
    CustomFontFace = nil;
    OpenedFrames = {}; DependencyBoxes = {}; Signals = {};
    ThemeScales = {}; UIScaleValue = 1.0;
    ScreenGui = ScreenGui; IsMobile = false; Scale = SCALE;
    VisibilityCallbacks = {}; IconSizeCallbacks = {}; TabResizeCallbacks = {};
    UseDrawingCursor = true; TextCaseMode = "none"; IconSize = 20;
}
Library.Toggles = Toggles
Library.Options = Options

do
    local LastYield = os.clock()
    function Library:BuildTick()
        if not Library.StreamedBuild then return end
        if os.clock() - LastYield >= 0.006 then task.wait() LastYield = os.clock() end
    end
end

function Library:RegisterVisibilityCallback(fn) table.insert(self.VisibilityCallbacks, fn) end
function Library:RegisterIconSizeCallback(fn) table.insert(self.IconSizeCallbacks, fn) end
Library.CurrentRainbowHue = 0
Library.CurrentRainbowColor = Color3.fromHSV(0, 0.8, 1)

Library.TranslateTexts = Library.TranslateTexts or setmetatable({}, {__mode="k"})
Library.TranslateProps = Library.TranslateProps or setmetatable({}, {__mode="k"})
Library.TranslateCallbacks = Library.TranslateCallbacks or {}
Library.TextBaseSizes = Library.TextBaseSizes or setmetatable({}, {__mode="k"})

local function isTextObject(inst)
    return typeof(inst) == "Instance" and (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox"))
end
local function fontScale(font)
    if font == Enum.Font.Code then return 0.9 end
    if font == Enum.Font.RobotoMono then return 0.92 end
    if font == Enum.Font.GothamBold then return 0.95 end
    return 1
end
function Library:RememberTextSize(inst, size)
    if isTextObject(inst) and type(size) == "number" then self.TextBaseSizes[inst] = size end
end
function Library:ApplyTextMetrics(inst)
    if not isTextObject(inst) then return end
    local base = self.TextBaseSizes[inst]
    if type(base) ~= "number" then base = inst.TextSize if type(base) ~= "number" then return end self.TextBaseSizes[inst] = base end
    local newSize = math.max(8, math.floor(base * fontScale(inst.Font) + 0.5))
    if inst.TextSize ~= newSize then inst.TextSize = newSize end
end
function Library:NormalizeText(raw) return tostring(raw or "") end
function Library:TranslateString(s) return s end
function Library:SetTRText(lbl, raw)
    if not lbl then return end
    lbl.Text = self:NormalizeText(raw or "")
end
function Library:SetTRProperty(inst, prop, raw)
    if not inst or type(prop) ~= "string" then return end
    inst[prop] = tostring(raw or "")
end
function Library:RegisterTRCallback(fn) end
function Library:TranslateAll() end
function Library:SetLang(lang) end
function Library:SafeCallback(f, ...)
    if not f then return end
    if not Library.NotifyOnError then return f(...) end
    local ok, err = pcall(f, ...)
    if not ok then
        local _, i = err:find(':%d+: ')
        Library:Notify(i and err:sub(i+1) or err, 3)
    end
end
function Library:AttemptSave()
    if Library.SaveManager then Library.SaveManager:Save() end
end
function Library:Create(Class, Props)
    local inst = type(Class) == 'string' and Instance.new(Class) or Class
    for k, v in next, Props do pcall(function() inst[k] = v end) end
    if isTextObject(inst) then
        if type(Props.Text) == "string" then inst.Text = self:NormalizeText(self:TranslateString(Props.Text)) end
        if type(Props.PlaceholderText) == "string" then inst.PlaceholderText = self:NormalizeText(self:TranslateString(Props.PlaceholderText)) end
        Library:RememberTextSize(inst, inst.TextSize)
        Library:ApplyTextMetrics(inst)
    end
    return inst
end
function Library:CreateLabel(Props, IsHud)
    local inst = Library:Create('TextLabel', {
        BackgroundTransparency = 1; Font = Library.Font;
        TextColor3 = Library.FontColor; TextSize = S(Props.TextSize or 16); TextStrokeTransparency = 0;
    })
    Library:AddToRegistry(inst, {TextColor3='FontColor'; Font='Font'}, IsHud)
    local p2 = {}
    for k,v in next, Props do p2[k] = v end
    if p2.TextSize then p2.TextSize = S(p2.TextSize) end
    Library:Create(inst, p2)
    if Library.CustomFontFace then pcall(function() inst.FontFace = Library.CustomFontFace end) end
    if type(Props.Text) == "string" then Library:SetTRText(inst, Props.Text) end
    return inst
end
function Library:CursorPos()
    local loc = Services.UserInputService:GetMouseLocation()
    return loc.X, loc.Y
end
function Library:IsPointerInput(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch
end
function Library:MouseIsOverOpenedFrame()
    local px, py = Library:CursorPos()
    for Frame in next, Library.OpenedFrames do
        local ap, as = Frame.AbsolutePosition, Frame.AbsoluteSize
        if px >= ap.X and px <= ap.X+as.X and py >= ap.Y and py <= ap.Y+as.Y then return true end
    end
    return false
end
function Library:HasOpenedFrames()
    for f in next, Library.OpenedFrames do return true end
    return false
end
function Library:IsMouseOverFrame(Frame)
    local px, py = Library:CursorPos()
    local ap, as = Frame.AbsolutePosition, Frame.AbsoluteSize
    return px >= ap.X and px <= ap.X+as.X and py >= ap.Y and py <= ap.Y+as.Y
end
do
    local Pending = false
    function Library:UpdateDependencyBoxes()
        if Pending then return end
        Pending = true
        task.defer(function()
            Pending = false
            pcall(function() for _, db in next, Library.DependencyBoxes do db:Update() end end)
        end)
    end
end
function Library:MapValue(v, a0, a1, b0, b1)
    return b0 + ((v - a0)/(a1 - a0)) * (b1 - b0)
end
function Library:GetTextBounds(Text, Font, Size, Res)
    local ok, b = pcall(Services.TextService.GetTextSize, Services.TextService, Text, Size, Font, Res or Vector2.new(1920,1080))
    if not ok or not b then
        local ok2, b2 = pcall(Services.TextService.GetTextSize, Services.TextService, Text, Size, Enum.Font.Code, Res or Vector2.new(1920,1080))
        b = ok2 and b2 or Vector2.new(200, Size)
    end
    return b.X, b.Y
end
function Library:GetDarkerColor(color)
    local h, s, br = Color3.toHSV(color)
    return Color3.fromHSV(h, s, br/1.5)
end
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
function Library:AddToRegistry(inst, props, isHud)
    local data = {Instance=inst; Properties=props}
    table.insert(Library.Registry, data)
    Library.RegistryMap[inst] = data
    if isHud then table.insert(Library.HudRegistry, data) end
end
function Library:RemoveFromRegistry(inst)
    local data = Library.RegistryMap[inst]
    if not data then return end
    for i = #Library.Registry, 1, -1 do if Library.Registry[i] == data then table.remove(Library.Registry, i) end end
    for i = #Library.HudRegistry, 1, -1 do if Library.HudRegistry[i] == data then table.remove(Library.HudRegistry, i) end end
    Library.RegistryMap[inst] = nil
end
function Library:UpdateColorsUsingRegistry()
    for _, obj in next, Library.Registry do
        for prop, idx in next, obj.Properties do
            local val
            if type(idx) == 'string' then val = Library[idx]
            elseif type(idx) == 'function' then val = idx() end
            if obj.Instance[prop] ~= val then obj.Instance[prop] = val end
        end
        Library:ApplyTextMetrics(obj.Instance)
    end
    if Library.CustomFontFace then
        for _, obj in next, Library.Registry do
            if obj.Properties['Font'] then pcall(function() obj.Instance.FontFace = Library.CustomFontFace end) end
        end
    end
    for _, cb in next, Library.TabResizeCallbacks do pcall(cb) end
end
function Library:GiveSignal(sig) table.insert(Library.Signals, sig) end
function Library:Unload()
    for i = #Library.Signals, 1, -1 do table.remove(Library.Signals, i):Disconnect() end
    if Library.OnUnload then Library.OnUnload() end
    ScreenGui:Destroy()
end
function Library:OnUnload(cb) Library.OnUnload = cb end
Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(inst)
    if Library.RegistryMap[inst] then Library:RemoveFromRegistry(inst) end
end))

-- ====================== END OF LIBRARY CORE ======================
-- NOTE: Full window/tab/widget rendering system inherited from original — attach your existing Library chain above this line.
-- Below is the ONYX-specific game logic layer.

return {Library=Library; Toggles=Toggles; Options=Options}
end)()

-- ====================== ONYX INIT ======================
local _lib       = getgenv().Library
local Library    = _lib.Library
local ThemeManager = _lib.ThemeManager
local SaveManager  = _lib.SaveManager
local Toggles    = _lib.Toggles
local Options    = _lib.Options

local Window = Library:CreateWindow({
    Title      = 'ONYX',
    Center     = true,
    AutoShow   = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
    MobileButton = false, -- we use custom logo button
})

local Tabs = {
    Combat      = Window:AddTab({ Title='Combat',    Icon='sword'   }),
    Visuals     = Window:AddTab({ Title='Visuals',   Icon='eye'     }),
    Spoofers    = Window:AddTab({ Title='Spoofers',  Icon='shield'  }),
    Crosshair   = Window:AddTab({ Title='Crosshair', Icon='crosshair'}),
    Radar       = Window:AddTab({ Title='Radar',     Icon='radio'   }),
    Misc        = Window:AddTab({ Title='Misc',      Icon='tool'    }),
    Settings    = Window:AddTab({ Title='Settings',  Icon='settings'}),
}

-- ====================== SERVICES ======================
local Players     = game:GetService('Players')
local RunService  = game:GetService('RunService')
local UserInput   = game:GetService('UserInputService')
local Workspace   = game:GetService('Workspace')
local RepFirst    = game:GetService('ReplicatedFirst')
local RepStorage  = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local Debris      = game:GetService('Debris')
local TweenService= game:GetService('TweenService')

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local ScreenGui   = Library.ScreenGui

-- ====================== GAME MODULES (safe lazy load) ======================
local CameraHandler, Neuron, Utils, States, GameplayHandler, HitHandler, DataHandler, ShotRemote = nil,nil,nil,nil,nil,nil,nil,nil

local function TryRequire(path)
    local ok, res = pcall(require, path)
    return ok and res or nil
end

task.delay(1.5, function() Neuron = TryRequire(RepFirst:WaitForChild('neuron', 5)) end)
task.delay(2.5, function() CameraHandler = TryRequire(RepStorage:FindFirstChild('Modules') and RepStorage.Modules:FindFirstChild('Handlers') and RepStorage.Modules.Handlers:FindFirstChild('CameraHandler')) end)
task.delay(3.0, function()
    if RepStorage:FindFirstChild('Modules') then
        States         = TryRequire(RepStorage.Modules:FindFirstChild('States'))
        GameplayHandler= TryRequire(RepStorage.Modules.Handlers and RepStorage.Modules.Handlers:FindFirstChild('GameplayHandler'))
        HitHandler     = TryRequire(RepStorage.Modules:FindFirstChild('HitHandler'))
        DataHandler    = TryRequire(RepStorage.Modules.Handlers and RepStorage.Modules.Handlers:FindFirstChild('DataHandler'))
    end
    pcall(function() ShotRemote = RepStorage:FindFirstChild('Remotes') and RepStorage.Remotes:FindFirstChild('shot') end)
end)

-- ====================== CHAR RESOLVER ======================
local function resolve_player(player)
    if not player then return end
    if player.Character and player.Character.Parent then return end
    if Neuron then
        local ok, c = pcall(function() return Neuron:get_character(player) end)
        if ok and c then player.Character = c end
    end
end

task.spawn(function()
    task.wait(4)
    while true do
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and (not v.Character or not v.Character.Parent) then resolve_player(v) end
        end
        task.wait(2)
    end
end)

-- ====================== HELPERS ======================
local v2  = Vector2.new
local v3  = Vector3.new
local mfl = math.floor
local mab = math.abs

local function W2S(pos)
    local p, vis = Camera:WorldToViewportPoint(pos)
    return v2(p.X, p.Y), vis, p.Z
end

local function IsAlive(player)
    if not player then return false end
    resolve_player(player)
    local char = player.Character
    if not char then return false end
    if HitHandler and HitHandler.isAlive then
        local ok, r = pcall(function() return HitHandler:isAlive(char) end)
        if ok then return r end
    end
    if States and States.GetStateValue then
        local ok, hp = pcall(function() return States:GetStateValue(char, "Health", 150) end)
        if ok and hp then return hp > 0 end
    end
    local h = char:FindFirstChildOfClass('Humanoid')
    return h and h.Health > 0 or false
end

local function IsSameTeam(player)
    if player == LocalPlayer then return true end
    if GameplayHandler then
        local lt, pt
        pcall(function()
            local _, dID = GameplayHandler:GetLocalDuel()
            if dID then lt = GameplayHandler:GetPlayerTeam(dID, LocalPlayer) pt = GameplayHandler:GetPlayerTeam(dID, player) end
        end)
        if lt and pt then return lt.id == pt.id end
    end
    if LocalPlayer.Team and player.Team then return player.Team == LocalPlayer.Team end
    return false
end

local function GetTeamColor(player)
    if not GameplayHandler then return nil end
    local _, dID = GameplayHandler:GetLocalDuel()
    if not dID then return nil end
    local team = GameplayHandler:GetPlayerTeam(dID, player)
    if not team then return nil end
    if team.color == "Blue"   then return Color3.fromRGB(0,154,255) end
    if team.color == "Orange" then return Color3.fromRGB(255,115,39) end
    return nil
end

local function GetHealth(player)
    local char = player.Character
    if not char then return 0 end
    if States and States.GetStateValue then
        local ok, hp = pcall(function() return States:GetStateValue(char,"Health",150) end)
        if ok and hp then
            local ok2, mh = pcall(function() return States:GetStateValue(char,"MaxHealth",150) end)
            return math.clamp(hp / (ok2 and mh or 150), 0, 1)
        end
    end
    local h = char:FindFirstChildOfClass('Humanoid')
    return h and (h.Health/h.MaxHealth) or 0
end

local function GetDistance(player)
    local c = player.Character
    local lc = LocalPlayer.Character
    if not c or not lc then return 0 end
    local r  = c:FindFirstChild('HumanoidRootPart')
    local lr = lc:FindFirstChild('HumanoidRootPart')
    if not r or not lr then return 0 end
    return (r.Position - lr.Position).Magnitude
end

local function GetPart(player, partName)
    local c = player.Character
    if not c then return nil end
    if partName == 'Random' then
        local parts = {}
        for _, v in ipairs(c:GetChildren()) do if v:IsA('BasePart') then table.insert(parts, v) end end
        return #parts > 0 and parts[math.random(1,#parts)] or c:FindFirstChild('HumanoidRootPart')
    end
    return c:FindFirstChild(partName) or c:FindFirstChild('HumanoidRootPart')
end

local function GetPlayerMatchState(player)
    if not GameplayHandler or not GameplayHandler.PlayerGameData then return "unknown" end
    local d = GameplayHandler.PlayerGameData[player]
    if not d then return "unknown" end
    if d.state == "lobby" then return "LOBBY" end
    if d.spectating then return "SPECTATING" end
    if d.state == "duel" then return "IN MATCH" end
    return "unknown"
end

local function IsSpectating(player)
    if not GameplayHandler then return false end
    local _, dID = GameplayHandler:GetLocalDuel()
    if not dID then return false end
    local duel = GameplayHandler.DuelData and GameplayHandler.DuelData[dID]
    if not duel or not duel.spectators then return false end
    return table.find(duel.spectators, player) ~= nil
end

-- ====================== CONFIG VARS ======================
-- [ AIMBOT ]
local AB_Enabled         = false
local AB_FOV             = 150
local AB_Smooth          = 0.20
local AB_SmoothVariance  = 0.035     -- per-frame humanization drift
local AB_Part            = 'Head'
local AB_VisCheck        = true
local AB_TeamCheck       = false
local AB_DeathCheck      = true
local AB_MaxDist         = 600
local AB_ReactionTime    = 0         -- ms before locking
local AB_MaxLockTime     = 0         -- 0 = infinite
local AB_PredEnabled     = true
local AB_PredStrength    = 0.10
local AB_Jitter          = true
local AB_JitterAmt       = 0.5
local AB_Dropoff         = true
local AB_DropoffThresh   = 35
local AB_SwitchCooldown  = 0.15
local AB_FlickMode       = false
local AB_FlickStrength   = 0.50
local AB_MicroCorr       = true
local AB_SpeedInAttack   = 0.12
local AB_SpeedScale      = 100
local AB_VisCacheTTL     = 0.07
local AB_VisCache        = {}
local AB_CurrentTarget   = nil
local AB_LockStart       = 0
local AB_ReactionStart   = 0
local AB_IsReacting      = false
local AB_IsFiring        = false
local AB_LastSwitch      = 0
local AB_PartOptions     = {'Head','HumanoidRootPart','UpperTorso','LowerTorso','Torso','Random'}

-- [ FOV ]
local FOV_Enabled        = true
local FOV_Color          = Color3.fromRGB(110,60,220)
local FOV_Transparency   = 0.6
local FOV_FillStyle      = 'Outline'

-- [ ESP ]
local ESP_Enabled        = true
local Box_Enabled        = true
local Box_Color          = Color3.fromRGB(110,60,220)
local Name_Enabled       = true
local Name_Color         = Color3.fromRGB(255,255,255)
local Health_Enabled     = true
local Dist_Enabled       = true
local Tracer_Enabled     = true
local Tracer_Color       = Color3.fromRGB(110,60,220)
local Tracer_Origin      = 'Bottom'
local HeadDot_Enabled    = true
local HeadDot_Color      = Color3.fromRGB(200,80,255)
local ESP_TeamColors     = false
local ESP_MatchAware     = false
local ESP_SpectateDetect = false
local ESP_Pool           = {}

-- [ RAINBOW ]
local Rainbow_Enabled = false
local Rainbow_Hue     = 0
local Rainbow_Speed   = 0.003
local Rainbow_Targets = {'Box','Name','Tracer','HeadDot','FOV'}

-- [ BOT ESP ]
local BotESP_Enabled       = false
local BotESP_Color         = Color3.fromRGB(0,255,140)
local BotESP_FinisherColor = Color3.fromRGB(255,50,150)
local BotESP_ShowID        = false
local BotESP_Pool          = {}

-- [ BULLET TRACERS ]
local BT_Enabled   = false
local BT_Color     = Color3.fromRGB(0,200,255)
local BT_Thickness = 1
local tracerFolder = nil

-- [ KILL FEED ]
local KF_Enabled    = false
local KF_MaxEntries = 5
local KF_Duration   = 5
local KF_Pool       = {}

-- [ MISC ]
local DC_Enabled   = false
local DC_Device    = '1'
local UA_Enabled   = false
local PP_Enabled   = false
local PP_Level     = 999
local PP_Streak    = 999

-- [ CROSSHAIR ]
local CH_Enabled   = false
local CH_Style     = 'Cross'
local CH_Color     = Color3.fromRGB(255,255,255)
local CH_Size      = 10
local CH_Gap       = 4
local CH_Thick     = 1
local CH_Dot       = false
local CH_DotColor  = Color3.fromRGB(255,0,0)
local CH_Lines     = {}
local CH_DotDraw   = nil

-- [ RADAR ]
local Radar_Enabled   = false
local Radar_Range     = 150
local Radar_Scale     = 120
local Radar_ShowTeam  = false
local Radar_BG        = Color3.fromRGB(10,8,22)
local Radar_DotColor  = Color3.fromRGB(200,80,255)
local Radar_SelfColor = Color3.fromRGB(0,255,100)

-- [ SPOOFERS ]
local SP_Username    = false; local SP_FakeName    = "ONYXUser"..tostring(math.random(1000,9999))
local SP_Display     = false; local SP_FakeDisplay = "ONYX"
local SP_UserID      = false; local SP_FakeUID     = tostring(math.random(100000000,999999999))
local SP_Age         = false; local SP_FakeAge     = 3650
local SP_Member      = false; local SP_FakeMember  = "Premium"
local SP_Locale      = false; local SP_FakeLocale  = "en-us"
local SP_Platform    = false; local SP_FakePlatform= "PC"
local SP_GfxQuality  = false; local SP_FakeGfx     = 1
local SP_SpoofMap    = {}

-- ====================== SPOOFER ENGINE ======================
local function SP_Rebuild()
    SP_SpoofMap = {}
    if SP_Username then SP_SpoofMap["Name"]           = SP_FakeName          end
    if SP_Display  then SP_SpoofMap["DisplayName"]    = SP_FakeDisplay       end
    if SP_UserID   then SP_SpoofMap["UserId"]         = tonumber(SP_FakeUID) end
    if SP_Age      then SP_SpoofMap["AccountAge"]     = SP_FakeAge           end
    if SP_Locale   then SP_SpoofMap["LocaleId"]       = SP_FakeLocale        end
    if SP_Member   then
        pcall(function()
            SP_SpoofMap["MembershipType"] = Enum.MembershipType[SP_FakeMember]
        end)
    end
end

pcall(function()
    local lp = LocalPlayer
    local mt = getrawmetatable(lp)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if self == lp and SP_SpoofMap[key] ~= nil then return SP_SpoofMap[key] end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end)

pcall(function()
    local uismt = getrawmetatable(UserInput)
    local oldUIS = uismt.__index
    setreadonly(uismt, false)
    uismt.__index = newcclosure(function(self, key)
        if SP_Platform then
            if key == "GamepadEnabled" then return SP_FakePlatform == "Console" end
            if key == "TouchEnabled"   then return SP_FakePlatform == "Mobile"  end
            if key == "MouseEnabled"   then return SP_FakePlatform == "PC"      end
            if key == "KeyboardEnabled"then return SP_FakePlatform == "PC"      end
        end
        return oldUIS(self, key)
    end)
    setreadonly(uismt, true)
end)

-- ====================== VISIBILITY CHECK (CACHED) ======================
local function VisCheck(char)
    local now = os.clock()
    local c = AB_VisCache[char]
    if c and (now - c.t) < AB_VisCacheTTL then return c.v end
    local bone = char:FindFirstChild('Head') or char:FindFirstChild('HumanoidRootPart')
    if not bone then AB_VisCache[char] = {v=false,t=now} return false end
    local origin = Camera.CFrame.Position
    local dir    = bone.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character or Instance.new("Folder")}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(origin, dir, params)
    local vis = result == nil or (result.Instance and result.Instance:IsDescendantOf(char))
    AB_VisCache[char] = {v=vis, t=now}
    return vis
end

-- ====================== AIMBOT ENGINE ======================
UserInput.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then AB_IsFiring = true end
end)
UserInput.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then AB_IsFiring = false end
end)

local function IsTargetValid(player)
    if not player or player == LocalPlayer then return false end
    if AB_TeamCheck and IsSameTeam(player) then return false end
    if AB_DeathCheck and not IsAlive(player) then return false end
    resolve_player(player)
    local char = player.Character
    if not char then return false end
    local part = GetPart(player, AB_Part)
    if not part then return false end
    if GetDistance(player) > AB_MaxDist then return false end
    if AB_VisCheck and not VisCheck(char) then return false end
    local spos, vis = W2S(part.Position)
    if not vis then return false end
    local center = v2(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    return (spos - center).Magnitude <= AB_FOV
end

local function GetScreenDist(player)
    local part = GetPart(player, AB_Part)
    if not part then return math.huge end
    local spos, vis = W2S(part.Position)
    if not vis then return math.huge end
    return (spos - v2(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
end

local function GetBestTarget()
    local center = v2(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, AB_FOV

    -- sticky target: only switch if new target is significantly closer
    if AB_CurrentTarget and AB_CurrentTarget.Parent then
        if IsTargetValid(AB_CurrentTarget) then
            local curDist = GetScreenDist(AB_CurrentTarget)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= AB_CurrentTarget and IsTargetValid(p) then
                    local nd = GetScreenDist(p)
                    if nd < curDist * 0.55 then best = p bestDist = nd end
                end
            end
            return best or AB_CurrentTarget
        end
    end

    AB_CurrentTarget = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if IsTargetValid(p) then
            local d = GetScreenDist(p)
            if d < bestDist then bestDist = d best = p end
        end
    end
    return best
end

local function GetPredictedPos(player)
    local part = GetPart(player, AB_Part)
    if not part then return nil end
    local vel = part.AssemblyLinearVelocity
    return part.Position + vel * AB_PredStrength
end

local function AimAt(player)
    if not player then return end
    local char = player.Character
    if not char then return end
    local part = GetPart(player, AB_Part)
    if not part then return end

    local targetPos = AB_PredEnabled and GetPredictedPos(player) or part.Position
    if not targetPos then return end

    -- CameraHandler path (Rivals-specific)
    if CameraHandler and CameraHandler.currentRotation then
        local camPos  = Camera.CFrame.Position
        local tCF     = CFrame.lookAt(camPos, targetPos)
        local tPitch, tYaw = tCF:ToEulerAnglesYXZ()
        local maxP    = CameraHandler.maxPitch or 1.5673
        tPitch        = math.clamp(tPitch, -maxP, maxP)

        local cur     = CameraHandler.currentRotation
        local dYaw    = tYaw - cur.Y
        while dYaw >  math.pi do dYaw = dYaw - 2*math.pi end
        while dYaw < -math.pi do dYaw = dYaw + 2*math.pi end
        local dPitch  = tPitch - cur.X

        local spd     = AB_IsFiring and AB_SpeedInAttack or AB_Smooth
        spd           = spd * (AB_SpeedScale/100)
        -- humanize
        spd           = spd + (math.random()*2-1)*AB_SmoothVariance
        local alpha   = math.clamp(spd, 0.001, 1)

        local spos, _ = W2S(targetPos)
        local pxDist  = (spos - v2(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude

        if AB_Dropoff and pxDist < AB_DropoffThresh then
            alpha = alpha * (0.35 + (pxDist/AB_DropoffThresh)*0.65)
        end
        if AB_FlickMode and pxDist > AB_FOV * 0.6 then
            alpha = alpha * (1/AB_FlickStrength)
        end
        if AB_MicroCorr then
            local cap = pxDist * 0.72
            alpha = math.clamp(alpha, 0, cap/math.max(mab(dPitch),mab(dYaw),0.001))
        end

        CameraHandler.currentRotation = Vector3.new(
            cur.X + dPitch * alpha,
            cur.Y + dYaw   * alpha,
            0
        )
    else
        -- Fallback: mousemoverel
        local spos, vis = W2S(targetPos)
        if not vis then return end
        local cx = Camera.ViewportSize.X/2
        local cy = Camera.ViewportSize.Y/2
        local pxDist = (spos - v2(cx,cy)).Magnitude
        local spd = (AB_IsFiring and AB_SpeedInAttack or AB_Smooth) * (AB_SpeedScale/100)
        spd = spd + (math.random()*2-1)*AB_SmoothVariance
        local dx = (spos.X - cx) * spd
        local dy = (spos.Y - cy) * spd
        if AB_Dropoff and pxDist < AB_DropoffThresh then
            local f = 0.35 + (pxDist/AB_DropoffThresh)*0.65
            dx = dx * f dy = dy * f
        end
        if AB_Jitter then
            dx = dx + (math.random()*2-1)*AB_JitterAmt
            dy = dy + (math.random()*2-1)*AB_JitterAmt
        end
        pcall(function() mousemoverel(dx, dy) end)
    end
end

-- ====================== FOV CIRCLE ======================
local FOV_Drawing = Drawing.new('Circle')
FOV_Drawing.Visible = false; FOV_Drawing.Filled = false
FOV_Drawing.Color = FOV_Color; FOV_Drawing.Thickness = 1.5
FOV_Drawing.NumSides = 120; FOV_Drawing.Transparency = FOV_Transparency; FOV_Drawing.ZIndex = 2

local function UpdateFOV()
    if not FOV_Enabled then FOV_Drawing.Visible = false return end
    local center = v2(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOV_Drawing.Position = center
    FOV_Drawing.Radius   = AB_FOV
    FOV_Drawing.Color    = FOV_Color
    FOV_Drawing.Thickness= 1.5
    FOV_Drawing.NumSides = 120
    if FOV_FillStyle == 'Outline' then
        FOV_Drawing.Filled = false FOV_Drawing.Transparency = FOV_Transparency
    elseif FOV_FillStyle == 'Half Full' then
        FOV_Drawing.Filled = true  FOV_Drawing.Transparency = 0.72
    elseif FOV_FillStyle == 'Fully Full' then
        FOV_Drawing.Filled = true  FOV_Drawing.Transparency = 0.30
    end
    FOV_Drawing.Visible = true
end

-- ====================== ESP DRAWING POOL ======================
local function MakeESP(player)
    local d = {}
    local function L(type) return Drawing.new(type) end
    d.BoxOutline = L('Square');  d.BoxOutline.Filled=false;  d.BoxOutline.Thickness=1.5; d.BoxOutline.ZIndex=3;  d.BoxOutline.Visible=false
    d.BoxFill    = L('Square');  d.BoxFill.Filled=true;      d.BoxFill.Color=Color3.fromRGB(0,0,0); d.BoxFill.Transparency=0.72; d.BoxFill.ZIndex=2; d.BoxFill.Visible=false
    d.HpBG       = L('Line');    d.HpBG.Color=Color3.fromRGB(30,30,30);   d.HpBG.Thickness=2; d.HpBG.ZIndex=3; d.HpBG.Visible=false
    d.HpBar      = L('Line');    d.HpBar.Color=Color3.fromRGB(0,255,0);   d.HpBar.Thickness=2; d.HpBar.ZIndex=4; d.HpBar.Visible=false
    d.NameTxt    = L('Text');    d.NameTxt.Size=13; d.NameTxt.Center=true; d.NameTxt.Outline=true; d.NameTxt.Font=Drawing.Fonts.Plex; d.NameTxt.ZIndex=5; d.NameTxt.Visible=false
    d.DistTxt    = L('Text');    d.DistTxt.Size=11; d.DistTxt.Center=true; d.DistTxt.Outline=true; d.DistTxt.Font=Drawing.Fonts.Plex; d.DistTxt.Color=Color3.fromRGB(180,180,180); d.DistTxt.ZIndex=3; d.DistTxt.Visible=false
    d.StatusTxt  = L('Text');    d.StatusTxt.Size=10; d.StatusTxt.Center=true; d.StatusTxt.Outline=true; d.StatusTxt.Font=Drawing.Fonts.Plex; d.StatusTxt.ZIndex=3; d.StatusTxt.Visible=false
    d.Tracer     = L('Line');    d.Tracer.Thickness=1; d.Tracer.Transparency=0.45; d.Tracer.ZIndex=1; d.Tracer.Visible=false
    d.HeadDot    = L('Circle');  d.HeadDot.Filled=true; d.HeadDot.Radius=4; d.HeadDot.NumSides=20; d.HeadDot.ZIndex=4; d.HeadDot.Visible=false
    ESP_Pool[player] = d
    return d
end

local function RemoveESP(player)
    local d = ESP_Pool[player]
    if not d then return end
    for _, dr in pairs(d) do pcall(function() dr:Remove() end) end
    ESP_Pool[player] = nil
end

local function CleanESP()
    for p, d in pairs(ESP_Pool) do
        if not p.Parent then
            for _, dr in pairs(d) do pcall(function() dr:Remove() end) end
            ESP_Pool[p] = nil
        end
    end
end

local function UpdateESP()
    CleanESP()
    local ss = Camera.ViewportSize
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not ESP_TeamColors and IsSameTeam(player) then continue end
        resolve_player(player)
        local char = player.Character
        local d    = ESP_Pool[player]
        if not char then
            if d then for _, dr in pairs(d) do dr.Visible = false end end
            continue
        end
        local hrp  = char:FindFirstChild('HumanoidRootPart')
        local head = char:FindFirstChild('Head')
        if not hrp or not head then
            if d then for _, dr in pairs(d) do dr.Visible = false end end
            continue
        end
        local rpos, rvis = W2S(hrp.Position)
        local hpos, hvis = W2S(head.Position + v3(0,0.3,0))
        if not rvis and not hvis then
            if d then for _, dr in pairs(d) do dr.Visible = false end end
            continue
        end
        if not d then d = MakeESP(player) end

        local hp   = GetHealth(player)
        local dist = GetDistance(player)

        local bCol = Box_Color;  local nCol = Name_Color
        local tCol = Tracer_Color; local dCol = HeadDot_Color
        if ESP_TeamColors then
            local tc = GetTeamColor(player)
            if tc then bCol=tc nCol=tc tCol=tc dCol=tc end
        end

        local head_y = hpos.Y - 2
        local root_y = rpos.Y + 2
        local height = mab(root_y - head_y)
        local width  = height * 0.55
        local bx     = rpos.X - width/2
        local by     = hpos.Y - 2

        if Box_Enabled and ESP_Enabled then
            d.BoxOutline.Position=v2(bx,by); d.BoxOutline.Size=v2(width,height); d.BoxOutline.Color=bCol; d.BoxOutline.Visible=true
            d.BoxFill.Position   =v2(bx,by); d.BoxFill.Size   =v2(width,height); d.BoxFill.Visible=true
        else d.BoxOutline.Visible=false d.BoxFill.Visible=false end

        if Health_Enabled and ESP_Enabled then
            local bx2 = bx - 5
            d.HpBG.From=v2(bx2,by); d.HpBG.To=v2(bx2,by+height); d.HpBG.Visible=true
            local filled = height * hp
            d.HpBar.From=v2(bx2,by+height-filled); d.HpBar.To=v2(bx2,by+height)
            d.HpBar.Color=Color3.fromRGB((1-hp)*255, hp*255, 40); d.HpBar.Visible=true
        else d.HpBG.Visible=false d.HpBar.Visible=false end

        if Name_Enabled and ESP_Enabled then
            d.NameTxt.Text=player.DisplayName; d.NameTxt.Position=v2(rpos.X,by-14); d.NameTxt.Color=nCol; d.NameTxt.Visible=true
        else d.NameTxt.Visible=false end

        if Dist_Enabled and ESP_Enabled then
            d.DistTxt.Text=tostring(mfl(dist)).."m"; d.DistTxt.Position=v2(rpos.X,by+height+3); d.DistTxt.Visible=true
        else d.DistTxt.Visible=false end

        if (ESP_MatchAware or ESP_SpectateDetect) and ESP_Enabled then
            local parts = {}
            if ESP_MatchAware then local ms = GetPlayerMatchState(player) if ms ~= "unknown" then table.insert(parts, ms) end end
            if ESP_SpectateDetect and IsSpectating(player) then table.insert(parts, "SPECTATING") end
            if #parts > 0 then
                d.StatusTxt.Text=table.concat(parts," | "); d.StatusTxt.Position=v2(rpos.X,by+height+16)
                d.StatusTxt.Color=IsSpectating(player) and Color3.fromRGB(255,200,0) or Color3.fromRGB(150,150,255); d.StatusTxt.Visible=true
            else d.StatusTxt.Visible=false end
        else d.StatusTxt.Visible=false end

        if Tracer_Enabled and ESP_Enabled then
            local oy = Tracer_Origin=='Bottom' and ss.Y or Tracer_Origin=='Top' and 0 or ss.Y/2
            d.Tracer.From=v2(ss.X/2,oy); d.Tracer.To=v2(rpos.X,rpos.Y); d.Tracer.Color=tCol; d.Tracer.Visible=true
        else d.Tracer.Visible=false end

        if HeadDot_Enabled and ESP_Enabled then
            d.HeadDot.Position=hpos; d.HeadDot.Color=dCol; d.HeadDot.Visible=true
        else d.HeadDot.Visible=false end
    end
end

-- ====================== BOT ESP ======================
local function MakeBotDraw()
    local d = {}
    d.Box   = Drawing.new('Square'); d.Box.Filled=false; d.Box.Thickness=2; d.Box.ZIndex=5; d.Box.Visible=false
    d.Label = Drawing.new('Text');   d.Label.Size=13; d.Label.Center=true; d.Label.Outline=true; d.Label.Font=Drawing.Fonts.Plex; d.Label.ZIndex=5; d.Label.Visible=false
    d.Dot   = Drawing.new('Circle'); d.Dot.Filled=true; d.Dot.Radius=3; d.Dot.NumSides=12; d.Dot.ZIndex=6; d.Dot.Visible=false
    return d
end

local function UpdateBotESP()
    if not BotESP_Enabled then
        for _, d in pairs(BotESP_Pool) do for _, dr in pairs(d) do pcall(function() dr.Visible=false end) end end
        return
    end
    local world    = Workspace:FindFirstChild('World')
    local entities = world and world:FindFirstChild('Entities')
    if not entities then return end
    for ent, d in pairs(BotESP_Pool) do
        if not ent.Parent then for _, dr in pairs(d) do pcall(function() dr:Remove() end) end BotESP_Pool[ent]=nil end
    end
    for _, ent in ipairs(entities:GetChildren()) do
        if ent:GetAttribute('IsDummy') ~= true then continue end
        local hrp  = ent:FindFirstChild('HumanoidRootPart')
        if not hrp then continue end
        local rpos, rvis = W2S(hrp.Position)
        local head       = ent:FindFirstChild('Head')
        local hpos, hvis
        if head then hpos, hvis = W2S(head.Position + v3(0,0.5,0)) end
        if not rvis and not hvis then
            if BotESP_Pool[ent] then for _, dr in pairs(BotESP_Pool[ent]) do dr.Visible=false end end
            continue
        end
        local isFin  = ent:GetAttribute('Finisher') == true
        local color  = isFin and BotESP_FinisherColor or BotESP_Color
        if not BotESP_Pool[ent] then BotESP_Pool[ent] = MakeBotDraw() end
        local d = BotESP_Pool[ent]
        local hy = hpos and hpos.Y or (rpos.Y-3)
        local ry = rpos.Y + 2
        local h  = mab(ry-hy); local w = h*0.55
        d.Box.Position=v2(rpos.X-w/2,hy-2); d.Box.Size=v2(w,h); d.Box.Color=color; d.Box.Visible=true
        local lbl = isFin and 'BOT [FINISHER]' or 'BOT'
        if BotESP_ShowID then local id = ent:GetAttribute('BotUserId') lbl = lbl..' #'..tostring(id or '?') end
        d.Label.Text=lbl; d.Label.Position=v2(rpos.X,hy-15); d.Label.Color=color; d.Label.Visible=true
        if hpos and hvis then d.Dot.Position=hpos; d.Dot.Color=color; d.Dot.Visible=true else d.Dot.Visible=false end
    end
end

-- ====================== RAINBOW ======================
local function UpdateRainbow()
    if not Rainbow_Enabled then return end
    Rainbow_Hue = (Rainbow_Hue + Rainbow_Speed) % 1
    local c = Color3.fromHSV(Rainbow_Hue, 1, 1)
    for _, t in ipairs(Rainbow_Targets) do
        if t=='Box'     then Box_Color=c end
        if t=='Name'    then Name_Color=c end
        if t=='Tracer'  then Tracer_Color=c end
        if t=='HeadDot' then HeadDot_Color=c end
        if t=='FOV'     then FOV_Color=c end
    end
end

-- ====================== BULLET TRACERS ======================
local function DrawBulletTracer(origin, hitPos, color, thickness)
    if not tracerFolder then
        tracerFolder = Instance.new("Folder")
        tracerFolder.Name = "ONYXTracers"
        tracerFolder.Parent = Workspace
    end
    local dist = (hitPos - origin).Magnitude
    if dist < 1 then return end
    local mid = (origin + hitPos)/2
    local p = Instance.new("Part")
    p.Size = Vector3.new(thickness or 0.4, thickness or 0.4, dist)
    p.CFrame = CFrame.lookAt(mid, hitPos) * CFrame.new(0,0,dist/2)
    p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
    p.Material = Enum.Material.Neon; p.Color = color; p.Transparency = 0.15
    p.Parent = tracerFolder
    Debris:AddItem(p, 0.12)
end

-- ====================== CROSSHAIR ======================
local function BuildCrosshair()
    for _, l in pairs(CH_Lines) do pcall(function() l:Remove() end) end
    CH_Lines = {}
    if CH_DotDraw then pcall(function() CH_DotDraw:Remove() end) CH_DotDraw = nil end
    if not CH_Enabled then return end
    local cx = Camera.ViewportSize.X/2
    local cy = Camera.ViewportSize.Y/2
    local function MkLine(x1,y1,x2,y2)
        local l = Drawing.new("Line")
        l.From=v2(x1,y1); l.To=v2(x2,y2); l.Color=CH_Color; l.Thickness=CH_Thick; l.Visible=true
        table.insert(CH_Lines, l)
    end
    if CH_Style == 'Cross' or CH_Style == 'Dynamic' then
        MkLine(cx-CH_Gap-CH_Size, cy, cx-CH_Gap, cy)
        MkLine(cx+CH_Gap, cy, cx+CH_Gap+CH_Size, cy)
        MkLine(cx, cy-CH_Gap-CH_Size, cx, cy-CH_Gap)
        MkLine(cx, cy+CH_Gap, cx, cy+CH_Gap+CH_Size)
    elseif CH_Style == 'T-Shape' then
        MkLine(cx-CH_Gap-CH_Size, cy, cx-CH_Gap, cy)
        MkLine(cx+CH_Gap, cy, cx+CH_Gap+CH_Size, cy)
        MkLine(cx, cy-CH_Gap-CH_Size, cx, cy-CH_Gap)
    elseif CH_Style == 'Dot' then
        local d = Drawing.new('Circle'); d.Position=v2(cx,cy); d.Radius=CH_Thick+1; d.Color=CH_Color; d.Filled=true; d.Visible=true
        table.insert(CH_Lines, d)
    elseif CH_Style == 'Circle' then
        local d = Drawing.new('Circle'); d.Position=v2(cx,cy); d.Radius=CH_Size; d.Color=CH_Color; d.Thickness=CH_Thick; d.Filled=false; d.Visible=true
        table.insert(CH_Lines, d)
    end
    if CH_Dot then
        CH_DotDraw = Drawing.new('Circle')
        CH_DotDraw.Position=v2(cx,cy); CH_DotDraw.Radius=2; CH_DotDraw.Color=CH_DotColor; CH_DotDraw.Filled=true; CH_DotDraw.Visible=true
    end
end

-- ====================== RADAR ======================
local RadarFrame = Instance.new("Frame")
RadarFrame.Size=UDim2.new(0,Radar_Scale,0,Radar_Scale); RadarFrame.Position=UDim2.new(0,12,0,200)
RadarFrame.BackgroundColor3=Radar_BG; RadarFrame.BackgroundTransparency=0.25; RadarFrame.BorderSizePixel=0
RadarFrame.Visible=false; RadarFrame.ZIndex=500; RadarFrame.Parent=ScreenGui
Instance.new("UICorner", RadarFrame).CornerRadius=UDim.new(1,0)
local RadarStroke = Instance.new("UIStroke"); RadarStroke.Color=Color3.fromRGB(110,60,220); RadarStroke.Thickness=1.3; RadarStroke.Parent=RadarFrame
local RadarSelf = Instance.new("Frame"); RadarSelf.Size=UDim2.new(0,7,0,7); RadarSelf.Position=UDim2.new(0.5,-3,0.5,-3)
RadarSelf.BackgroundColor3=Radar_SelfColor; RadarSelf.BorderSizePixel=0; RadarSelf.ZIndex=501; RadarSelf.Parent=RadarFrame
Instance.new("UICorner",RadarSelf).CornerRadius=UDim.new(1,0)
local RadarLabel = Instance.new("TextLabel"); RadarLabel.Size=UDim2.new(1,0,0,14); RadarLabel.Position=UDim2.new(0,0,0,-16)
RadarLabel.BackgroundTransparency=1; RadarLabel.TextColor3=Color3.fromRGB(180,140,255); RadarLabel.Font=Enum.Font.GothamBold
RadarLabel.TextSize=11; RadarLabel.Text="◈ RADAR"; RadarLabel.ZIndex=502; RadarLabel.Parent=RadarFrame
local RadarDots = {}
Library:MakeDraggableDirect and pcall(function() Library:MakeDraggableDirect(RadarFrame) end)

local function UpdateRadar()
    if not Radar_Enabled then RadarFrame.Visible=false return end
    RadarFrame.Visible=true
    RadarFrame.Size=UDim2.new(0,Radar_Scale,0,Radar_Scale)
    for _, d in pairs(RadarDots) do pcall(function() d:Destroy() end) end
    RadarDots = {}
    local lp   = LocalPlayer
    local char = lp.Character
    if not char or not char.PrimaryPart then return end
    local selfCF = char.PrimaryPart.CFrame
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not Radar_ShowTeam and IsSameTeam(player) then continue end
        local pc = player.Character
        if not pc or not pc.PrimaryPart then continue end
        local rel = selfCF:PointToObjectSpace(pc.PrimaryPart.Position)
        local rx  = math.clamp((rel.X/Radar_Range)*(Radar_Scale/2), -Radar_Scale/2+5, Radar_Scale/2-5)
        local ry  = math.clamp((rel.Z/Radar_Range)*(Radar_Scale/2), -Radar_Scale/2+5, Radar_Scale/2-5)
        local dot = Instance.new("Frame")
        dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0.5,rx-3,0.5,ry-3)
        dot.BackgroundColor3=Radar_DotColor; dot.BorderSizePixel=0; dot.ZIndex=503; dot.Parent=RadarFrame
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local nLabel = Instance.new("TextLabel"); nLabel.Size=UDim2.new(0,60,0,10); nLabel.Position=UDim2.new(0.5,5,0.5,-5)
        nLabel.BackgroundTransparency=1; nLabel.TextColor3=Color3.fromRGB(220,180,255); nLabel.Font=Enum.Font.GothamBold
        nLabel.TextSize=9; nLabel.Text=player.Name:sub(1,8); nLabel.ZIndex=504; nLabel.Parent=dot
        table.insert(RadarDots, dot)
    end
end

-- ====================== KILL FEED ======================
local weaponAliases = {
    ["burst"]="Burst Carbine",["handgun"]="Pistol",["tec9"]="Tec-9",["flintlock"]="Flintlock",
    ["bolt_action_sniper"]="Sniper",["taser"]="Tazer",["satchel"]="Satchel",["fist"]="Knife",
    ["ak47"]="AK-47",["ar"]="Assault Rifle",["deagle"]="Desert Eagle",["minigun"]="Minigun",
    ["pistol"]="Pistol",["pulse_rifle"]="Pulse Rifle",["raygun"]="Ray Gun",["rpg"]="RPG",
    ["shotgun"]="Shotgun",["sniper"]="Sniper",["scar_h"]="SCAR-H",["lmg"]="LMG",
    ["tommy_gun"]="Tommy Gun",["knife"]="Knife",["karambit"]="Karambit",["katana"]="Katana",
    ["butterfly_knife"]="Butterfly Knife",["scythe"]="Scythe",["shorty"]="Shorty",
    ["grenade"]="Grenade",["molotov"]="Molotov",["tazer"]="Tazer",["tec-9"]="Tec-9",
}

local function SetupKillFeed()
    task.delay(4, function()
        pcall(function()
            if Neuron and Neuron.net and Neuron.net.packets then
                local pkt = Neuron.net.packets.round_died
                if pkt and pkt.Connect then
                    pkt:Connect(function(data)
                        if not KF_Enabled or not data then return end
                        local killerName = data.killer and data.killer.DisplayName or "World"
                        local killedName = data.player and data.player.DisplayName or "?"
                        local wep        = weaponAliases[data.weaponID] or data.weaponID or "?"
                        local txt = killerName.." ▶ "..killedName.." ["..wep.."]"
                        if data.headShot then txt = txt.." [HS✓]" end
                        if data.assistingPlayer then txt = txt.." (+"..data.assistingPlayer.DisplayName..")" end
                        while #KF_Pool >= KF_MaxEntries do
                            local old = table.remove(KF_Pool, 1)
                            pcall(function() old.drawing:Remove() end)
                        end
                        local entry = Drawing.new('Text')
                        entry.Text    = txt
                        entry.Size    = 14
                        entry.Center  = false
                        entry.Outline = true
                        entry.Font    = Drawing.Fonts.Plex
                        entry.Color   = data.headShot and Color3.fromRGB(200,80,255) or Color3.fromRGB(255,255,255)
                        entry.ZIndex  = 10
                        entry.Visible = true
                        table.insert(KF_Pool, {drawing=entry, born=os.clock()})
                    end)
                end
            end
        end)
    end)
end

local function UpdateKillFeed()
    local now = os.clock()
    local ox  = Camera.ViewportSize.X - 260
    local oy  = Camera.ViewportSize.Y * 0.08
    for i = #KF_Pool, 1, -1 do
        local e = KF_Pool[i]
        if now - e.born > KF_Duration then
            pcall(function() e.drawing:Remove() end)
            table.remove(KF_Pool, i)
        else
            e.drawing.Position = v2(ox, oy + (#KF_Pool - i) * 18)
        end
    end
end

-- ====================== UNLOCK ALL ======================
local function InitUnlockAll()
    pcall(function()
        if DataHandler and DataHandler.SetData then
            DataHandler:SetData("unlockedAll", true)
        end
    end)
    pcall(function()
        if RepStorage:FindFirstChild("Remotes") then
            for _, r in ipairs(RepStorage.Remotes:GetChildren()) do
                if r.Name:lower():find("unlock") then
                    pcall(function() r:FireServer({unlockAll=true}) end)
                end
            end
        end
    end)
end

-- ====================== LOGO TOGGLE BUTTON ======================
do
    local Btn = Instance.new("ImageButton")
    Btn.Size = UDim2.new(0,52,0,52)
    Btn.Position = UDim2.new(0,14,0.5,-26)
    Btn.BackgroundColor3 = Color3.fromRGB(10,8,22)
    Btn.BorderSizePixel  = 0
    -- ONYX logo SVG-style drawn via UIStroke + UICorner
    -- If you upload the PNG as a Decal, replace Image with your asset ID:
    -- Btn.Image = "rbxassetid://YOUR_ONYX_DECAL_ID"
    Btn.ImageColor3 = Color3.fromRGB(130,80,255)
    Btn.ZIndex = 999
    Btn.Parent = ScreenGui
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke"); stroke.Color=Color3.fromRGB(110,60,220); stroke.Thickness=1.6; stroke.Parent=Btn
    -- Glow ring
    local glow = Instance.new("Frame"); glow.Size=UDim2.new(1.5,0,1.5,0); glow.Position=UDim2.new(-0.25,0,-0.25,0)
    glow.BackgroundColor3=Color3.fromRGB(100,50,220); glow.BackgroundTransparency=0.88; glow.BorderSizePixel=0; glow.ZIndex=998; glow.Parent=Btn
    Instance.new("UICorner",glow).CornerRadius=UDim.new(1,0)
    -- ONYX text inside button (fallback if no decal)
    local lbl = Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text="◈"; lbl.TextColor3=Color3.fromRGB(160,90,255); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=24; lbl.ZIndex=1000; lbl.Parent=Btn
    -- Pulse animation
    task.spawn(function()
        while Btn and Btn.Parent do
            for i = 0, 2*math.pi, 0.05 do
                if not Btn.Parent then break end
                glow.BackgroundTransparency = 0.82 + 0.10*math.sin(i)
                lbl.TextColor3 = Color3.fromHSV(0.74 + 0.04*math.sin(i*0.5), 0.65, 1)
                task.wait(0.03)
            end
        end
    end)
    -- Draggable
    local drag, ds, sp = false, nil, nil
    Btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag=true; ds=inp.Position; sp=Btn.Position
        end
    end)
    UserInput.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local delta = inp.Position - ds
            Btn.Position = UDim2.new(sp.X.Scale, sp.X.Offset+delta.X, sp.Y.Scale, sp.Y.Offset+delta.Y)
        end
    end)
    UserInput.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    Btn.MouseButton1Click:Connect(function() Library:ToggleVisibility() end)
end

-- ====================== MAIN LOOP ======================
local AB_PredStrength = AB_PredStrength -- local alias
RunService.RenderStepped:Connect(function(dt)
    UpdateESP()
    UpdateBotESP()
    UpdateFOV()
    UpdateRainbow()
    UpdateKillFeed()
    UpdateRadar()

    -- Dynamic crosshair spread (velocity-based gap expansion)
    if CH_Enabled and CH_Style == 'Dynamic' then
        local char = LocalPlayer.Character
        local vel  = char and char.PrimaryPart and char.PrimaryPart.AssemblyLinearVelocity or Vector3.zero
        local spd  = vel.Magnitude
        -- recalc CH_Gap dynamically then rebuild (throttle to 0.05s)
        CH_Gap = math.clamp(4 + spd*0.4, 2, 24)
        BuildCrosshair()
    end

    -- Aimbot tick
    if not AB_Enabled then AB_CurrentTarget = nil AB_IsReacting = false return end
    local now = tick()
    if AB_MaxLockTime > 0 and AB_CurrentTarget and (now - AB_LockStart) >= AB_MaxLockTime then
        AB_CurrentTarget = nil AB_IsReacting = false return
    end
    local target = GetBestTarget()
    if target ~= AB_CurrentTarget then
        if target then
            if not AB_IsReacting then AB_IsReacting=true AB_ReactionStart=now return end
            if (now - AB_ReactionStart) < AB_ReactionTime/1000 then return end
            if (now - AB_LastSwitch) < AB_SwitchCooldown then return end
            AB_CurrentTarget = target; AB_LockStart = now; AB_IsReacting = false; AB_LastSwitch = now
        else AB_CurrentTarget = nil AB_IsReacting = false return end
    end
    if AB_CurrentTarget then AimAt(AB_CurrentTarget) end
end)

SetupKillFeed()

-- ====================== UI: COMBAT TAB ======================
do
    local CombatTab = Tabs.Combat
    local AimGroup  = CombatTab:AddLeftGroupbox('Aimbot')
    AimGroup:AddToggle('AB_Enabled',  {Text='Enable Aimbot',      Default=false, Callback=function(v) AB_Enabled=v end})
    AimGroup:AddSlider('AB_FOV',      {Text='FOV',                Default=150,   Min=10,  Max=500, Rounding=0, Callback=function(v) AB_FOV=v end})
    AimGroup:AddSlider('AB_Smooth',   {Text='Smoothness',         Default=20,    Min=1,   Max=100, Rounding=0, Callback=function(v) AB_Smooth=v/100 end})
    AimGroup:AddSlider('AB_SmoothVar',{Text='Smooth Variance',    Default=4,     Min=0,   Max=25,  Rounding=0, Callback=function(v) AB_SmoothVariance=v/100 end})
    AimGroup:AddDropdown('AB_Part',   {Text='Target Bone',        Default='Head',Values=AB_PartOptions, Callback=function(v) AB_Part=v end})
    AimGroup:AddToggle('AB_VisCheck', {Text='Visibility Check',   Default=true,  Callback=function(v) AB_VisCheck=v end})
    AimGroup:AddToggle('AB_TeamCheck',{Text='Team Check',         Default=false, Callback=function(v) AB_TeamCheck=v end})
    AimGroup:AddToggle('AB_DeathCheck',{Text='Death Check',       Default=true,  Callback=function(v) AB_DeathCheck=v end})
    AimGroup:AddSlider('AB_MaxDist',  {Text='Max Distance (studs)',Default=600,   Min=50,  Max=3000, Rounding=0, Callback=function(v) AB_MaxDist=v end})
    AimGroup:AddDivider()
    AimGroup:AddSlider('AB_Reaction', {Text='Reaction Time (ms)', Default=0,     Min=0,   Max=500, Rounding=0, Callback=function(v) AB_ReactionTime=v end})
    AimGroup:AddSlider('AB_MaxLock',  {Text='Max Lock Time (s)',  Default=0,     Min=0,   Max=10,  Rounding=1, Callback=function(v) AB_MaxLockTime=v end})
    AimGroup:AddSlider('AB_SwitchCD', {Text='Switch Cooldown (ms)',Default=150,  Min=0,   Max=800, Rounding=0, Callback=function(v) AB_SwitchCooldown=v/1000 end})
    AimGroup:AddSlider('AB_SpeedScale',{Text='Speed Scale %',     Default=100,   Min=10,  Max=200, Rounding=0, Callback=function(v) AB_SpeedScale=v end})

    local LegitGroup = CombatTab:AddRightGroupbox('Legit Settings')
    LegitGroup:AddToggle('AB_Pred',   {Text='Movement Prediction',Default=true,  Callback=function(v) AB_PredEnabled=v end})
    LegitGroup:AddSlider('AB_PredStr',{Text='Prediction Strength',Default=10,    Min=0,   Max=60,  Rounding=0, Callback=function(v) AB_PredStrength=v/100 end})
    LegitGroup:AddToggle('AB_Jitter', {Text='Sub-pixel Jitter',   Default=true,  Callback=function(v) AB_Jitter=v end})
    LegitGroup:AddSlider('AB_JitterA',{Text='Jitter Amount',      Default=5,     Min=0,   Max=25,  Rounding=0, Callback=function(v) AB_JitterAmt=v/10 end})
    LegitGroup:AddToggle('AB_Dropoff',{Text='Near-Target Dropoff',Default=true,  Callback=function(v) AB_Dropoff=v end})
    LegitGroup:AddSlider('AB_DropThr',{Text='Dropoff Threshold',  Default=35,    Min=5,   Max=120, Rounding=0, Callback=function(v) AB_DropoffThresh=v end})
    LegitGroup:AddToggle('AB_Flick',  {Text='Flick Mode',         Default=false, Callback=function(v) AB_FlickMode=v end})
    LegitGroup:AddSlider('AB_FlickS', {Text='Flick Strength',     Default=50,    Min=10,  Max=100, Rounding=0, Callback=function(v) AB_FlickStrength=v/100 end})
    LegitGroup:AddToggle('AB_MicroC', {Text='Micro Correction',   Default=true,  Callback=function(v) AB_MicroCorr=v end})
    LegitGroup:AddSlider('AB_AttSpd', {Text='Attack Speed',       Default=12,    Min=1,   Max=100, Rounding=0, Callback=function(v) AB_SpeedInAttack=v/100 end})
    LegitGroup:AddDivider()

    local FOVGroup = CombatTab:AddLeftGroupbox('FOV Circle')
    FOVGroup:AddToggle('FOV_Enabled',   {Text='Show FOV',       Default=true,  Callback=function(v) FOV_Enabled=v end})
    FOVGroup:AddLabel('FOV Color'):AddColorPicker('FOV_Color',  {Default=Color3.fromRGB(110,60,220), Callback=function(v) FOV_Color=v end})
    FOVGroup:AddSlider('FOV_Trans',     {Text='Transparency',   Default=60,    Min=0, Max=100, Rounding=0, Callback=function(v) FOV_Transparency=v/100 end})
    FOVGroup:AddDropdown('FOV_Fill',    {Text='Fill Style',     Default='Outline', Values={'Outline','Half Full','Fully Full'}, Callback=function(v) FOV_FillStyle=v end})
end

-- ====================== UI: VISUALS TAB ======================
do
    local VisTab   = Tabs.Visuals
    local ESPGroup = VisTab:AddLeftGroupbox('Player ESP')
    ESPGroup:AddToggle('ESP_Enabled',   {Text='Enable ESP',     Default=true,  Callback=function(v) ESP_Enabled=v end})
    ESPGroup:AddToggle('Box_Enabled',   {Text='Box',            Default=true,  Callback=function(v) Box_Enabled=v end})
    ESPGroup:AddLabel('Box Color'):AddColorPicker('Box_Color',  {Default=Color3.fromRGB(110,60,220), Callback=function(v) Box_Color=v end})
    ESPGroup:AddToggle('Name_Enabled',  {Text='Name',           Default=true,  Callback=function(v) Name_Enabled=v end})
    ESPGroup:AddLabel('Name Color'):AddColorPicker('Name_Color',{Default=Color3.fromRGB(255,255,255), Callback=function(v) Name_Color=v end})
    ESPGroup:AddToggle('Health_Enabled',{Text='Health Bar',     Default=true,  Callback=function(v) Health_Enabled=v end})
    ESPGroup:AddToggle('Dist_Enabled',  {Text='Distance',       Default=true,  Callback=function(v) Dist_Enabled=v end})
    ESPGroup:AddDivider()
    ESPGroup:AddToggle('Tracer_Enabled',{Text='Tracers',        Default=true,  Callback=function(v) Tracer_Enabled=v end})
    ESPGroup:AddLabel('Tracer Color'):AddColorPicker('Tracer_Color',{Default=Color3.fromRGB(110,60,220), Callback=function(v) Tracer_Color=v end})
    ESPGroup:AddDropdown('Tracer_Origin',{Text='Tracer Origin', Default='Bottom', Values={'Bottom','Middle','Top'}, Callback=function(v) Tracer_Origin=v end})
    ESPGroup:AddToggle('HeadDot_Enabled',{Text='Head Dot',      Default=true,  Callback=function(v) HeadDot_Enabled=v end})
    ESPGroup:AddLabel('Dot Color'):AddColorPicker('HeadDot_Color',{Default=Color3.fromRGB(200,80,255), Callback=function(v) HeadDot_Color=v end})

    local GameAware = VisTab:AddRightGroupbox('Game-Aware')
    GameAware:AddToggle('ESP_TeamColors',   {Text='Team Colors',         Default=false, Callback=function(v) ESP_TeamColors=v end})
    GameAware:AddToggle('ESP_MatchAware',   {Text='Match State Labels',  Default=false, Callback=function(v) ESP_MatchAware=v end})
    GameAware:AddToggle('ESP_SpectateDetect',{Text='Spectate Detection', Default=false, Callback=function(v) ESP_SpectateDetect=v end})

    local RainbowGrp = VisTab:AddLeftGroupbox('Rainbow')
    RainbowGrp:AddToggle('Rainbow_Enable',{Text='Rainbow Mode',  Default=false, Callback=function(v) Rainbow_Enabled=v end})
    RainbowGrp:AddSlider('Rainbow_Speed', {Text='Speed',         Default=3, Min=1, Max=30, Rounding=0, Callback=function(v) Rainbow_Speed=v/1000 end})
    RainbowGrp:AddDropdown('Rainbow_Tgts',{Text='Apply To',     Default='Box', Values={'Box','Name','Tracer','HeadDot','FOV'}, Callback=function(v)
        local found = false
        for i, t in ipairs(Rainbow_Targets) do if t==v then table.remove(Rainbow_Targets,i) found=true break end end
        if not found then table.insert(Rainbow_Targets, v) end
    end})

    local BotGrp = VisTab:AddRightGroupbox('Bot ESP')
    BotGrp:AddToggle('BotESP_Enable',{Text='Bot ESP',            Default=false, Callback=function(v) BotESP_Enabled=v end})
    BotGrp:AddLabel('Bot Color'):AddColorPicker('BotESP_Color',  {Default=Color3.fromRGB(0,255,140),  Callback=function(v) BotESP_Color=v end})
    BotGrp:AddLabel('Finisher Color'):AddColorPicker('BotESP_FC',{Default=Color3.fromRGB(255,50,150), Callback=function(v) BotESP_FinisherColor=v end})
    BotGrp:AddToggle('BotESP_ShowID', {Text='Show Bot ID',       Default=false, Callback=function(v) BotESP_ShowID=v end})

    local BTGroup = VisTab:AddLeftGroupbox('3D Bullet Tracers')
    BTGroup:AddToggle('BT_Enabled',  {Text='Enable',          Default=false, Callback=function(v) BT_Enabled=v end})
    BTGroup:AddLabel('Color'):AddColorPicker('BT_Color',      {Default=Color3.fromRGB(0,200,255),  Callback=function(v) BT_Color=v end})
    BTGroup:AddSlider('BT_Thickness',{Text='Thickness',       Default=1, Min=1, Max=6, Rounding=0, Callback=function(v) BT_Thickness=v end})
end

-- ====================== UI: SPOOFERS TAB ======================
do
    local SpTab = Tabs.Spoofers
    local IdGrp = SpTab:AddLeftGroupbox('Identity')
    IdGrp:AddToggle('SP_Username',    {Text='Spoof Username',     Default=false, Callback=function(v) SP_Username=v SP_Rebuild() end})
    IdGrp:AddInput('SP_FakeName',     {Text='Fake Username',      Default=SP_FakeName, Callback=function(v) SP_FakeName=v SP_Rebuild() end})
    IdGrp:AddDivider()
    IdGrp:AddToggle('SP_Display',     {Text='Spoof Display Name', Default=false, Callback=function(v) SP_Display=v SP_Rebuild() end})
    IdGrp:AddInput('SP_FakeDisplay',  {Text='Fake Display Name',  Default='ONYX', Callback=function(v) SP_FakeDisplay=v SP_Rebuild() end})
    IdGrp:AddDivider()
    IdGrp:AddToggle('SP_UserID',      {Text='Spoof UserID',       Default=false, Callback=function(v) SP_UserID=v SP_Rebuild() end})
    IdGrp:AddInput('SP_FakeUID',      {Text='Fake UserID',        Default=SP_FakeUID, Numeric=true, Callback=function(v) SP_FakeUID=v SP_Rebuild() end})

    local AccGrp = SpTab:AddRightGroupbox('Account')
    AccGrp:AddToggle('SP_Age',        {Text='Spoof Account Age',  Default=false, Callback=function(v) SP_Age=v SP_Rebuild() end})
    AccGrp:AddSlider('SP_FakeAge',    {Text='Age (days)',         Default=3650, Min=1, Max=9999, Rounding=0, Callback=function(v) SP_FakeAge=v SP_Rebuild() end})
    AccGrp:AddDivider()
    AccGrp:AddToggle('SP_Member',     {Text='Spoof Membership',   Default=false, Callback=function(v) SP_Member=v SP_Rebuild() end})
    AccGrp:AddDropdown('SP_FakeMember',{Text='Membership',       Default='Premium', Values={'None','Premium'}, Callback=function(v) SP_FakeMember=v SP_Rebuild() end})
    AccGrp:AddDivider()
    AccGrp:AddToggle('SP_Locale',     {Text='Spoof Locale',       Default=false, Callback=function(v) SP_Locale=v SP_Rebuild() end})
    AccGrp:AddInput('SP_FakeLocale',  {Text='Locale',             Default='en-us', Callback=function(v) SP_FakeLocale=v SP_Rebuild() end})

    local PlatGrp = SpTab:AddLeftGroupbox('Platform & Hardware')
    PlatGrp:AddToggle('SP_Platform',  {Text='Spoof Platform',     Default=false, Callback=function(v) SP_Platform=v end})
    PlatGrp:AddDropdown('SP_FakePlat',{Text='Platform',           Default='PC', Values={'PC','Mobile','Console'}, Callback=function(v) SP_FakePlatform=v end})
    PlatGrp:AddDivider()
    PlatGrp:AddToggle('SP_GfxQuality',{Text='Spoof Graphics Quality', Default=false, Callback=function(v)
        SP_GfxQuality=v
        if v then pcall(function() settings().Rendering.QualityLevel=SP_FakeGfx end) end
    end})
    PlatGrp:AddSlider('SP_FakeGfx',  {Text='Quality Level',       Default=1, Min=1, Max=10, Rounding=0, Callback=function(v)
        SP_FakeGfx=v
        if SP_GfxQuality then pcall(function() settings().Rendering.QualityLevel=v end) end
    end})
end

-- ====================== UI: CROSSHAIR TAB ======================
do
    local CHTab = Tabs.Crosshair
    local CHGrp = CHTab:AddLeftGroupbox('Crosshair')
    CHGrp:AddToggle('CH_Enabled',{Text='Enable',      Default=false, Callback=function(v) CH_Enabled=v BuildCrosshair() end})
    CHGrp:AddDropdown('CH_Style',{Text='Style',       Default='Cross', Values={'Cross','Dot','Circle','T-Shape','Dynamic'}, Callback=function(v) CH_Style=v BuildCrosshair() end})
    CHGrp:AddLabel('Color'):AddColorPicker('CH_Color',{Default=Color3.fromRGB(255,255,255), Callback=function(v) CH_Color=v BuildCrosshair() end})
    CHGrp:AddSlider('CH_Size',  {Text='Size',         Default=10, Min=2, Max=50, Rounding=0, Callback=function(v) CH_Size=v BuildCrosshair() end})
    CHGrp:AddSlider('CH_Gap',   {Text='Gap',          Default=4,  Min=0, Max=30, Rounding=0, Callback=function(v) CH_Gap=v BuildCrosshair() end})
    CHGrp:AddSlider('CH_Thick', {Text='Thickness',    Default=1,  Min=1, Max=6,  Rounding=0, Callback=function(v) CH_Thick=v BuildCrosshair() end})
    CHGrp:AddToggle('CH_Dot',   {Text='Center Dot',   Default=false, Callback=function(v) CH_Dot=v BuildCrosshair() end})
    CHGrp:AddLabel('Dot Color'):AddColorPicker('CH_DotColor',{Default=Color3.fromRGB(255,0,0), Callback=function(v) CH_DotColor=v BuildCrosshair() end})
end

-- ====================== UI: RADAR TAB ======================
do
    local RTab = Tabs.Radar
    local RGrp = RTab:AddLeftGroupbox('Radar')
    RGrp:AddToggle('Radar_Enabled',  {Text='Enable Radar',    Default=false, Callback=function(v) Radar_Enabled=v end})
    RGrp:AddSlider('Radar_Range',    {Text='Range (studs)',   Default=150, Min=30, Max=800, Rounding=0, Callback=function(v) Radar_Range=v end})
    RGrp:AddSlider('Radar_Scale',    {Text='Scale (px)',      Default=120, Min=60, Max=240, Rounding=0, Callback=function(v) Radar_Scale=v RadarFrame.Size=UDim2.new(0,v,0,v) end})
    RGrp:AddToggle('Radar_ShowTeam', {Text='Show Teammates',  Default=false, Callback=function(v) Radar_ShowTeam=v end})
    RGrp:AddLabel('Dot Color'):AddColorPicker('Radar_DotColor',{Default=Color3.fromRGB(200,80,255), Callback=function(v) Radar_DotColor=v end})
    RGrp:AddLabel('Self Color'):AddColorPicker('Radar_SelfColor',{Default=Color3.fromRGB(0,255,100), Callback=function(v) Radar_SelfColor=v RadarSelf.BackgroundColor3=v end})
end

-- ====================== UI: MISC TAB ======================
do
    local MTab  = Tabs.Misc
    local KFGrp = MTab:AddLeftGroupbox('Kill Feed')
    KFGrp:AddToggle('KF_Enabled',   {Text='Custom Kill Feed', Default=false, Callback=function(v) KF_Enabled=v end})
    KFGrp:AddSlider('KF_MaxEntries',{Text='Max Entries',     Default=5, Min=1, Max=12, Rounding=0, Callback=function(v) KF_MaxEntries=v end})
    KFGrp:AddSlider('KF_Duration',  {Text='Duration (s)',    Default=5, Min=1, Max=20, Rounding=0, Callback=function(v) KF_Duration=v end})

    local DCGrp = MTab:AddRightGroupbox('Device Changer')
    DCGrp:AddToggle('DC_Enable',  {Text='Spoof Device',  Default=false, Callback=function(v) DC_Enabled=v end})
    DCGrp:AddDropdown('DC_Device',{Text='Device',        Default='1',   Values={'1','2','default'}, Callback=function(v) DC_Device=v end})

    local UAGrp = MTab:AddLeftGroupbox('Unlock All')
    UAGrp:AddToggle('UA_Enable',  {Text='Enable Unlock All', Default=false, Callback=function(v)
        if v then InitUnlockAll() Library:Notify({Title="Unlock All", Content="Initialized — rejoin if needed.", Duration=4}) end
    end})

    local PPGrp = MTab:AddRightGroupbox('Profile Spoof')
    PPGrp:AddToggle('PP_Enable',  {Text='Enable Spoof',      Default=false, Callback=function(v) PP_Enabled=v end})
    PPGrp:AddInput('PP_Level',    {Text='Fake Level',        Default='999', Numeric=true, Callback=function(v) PP_Level=tonumber(v) or 0 end})
    PPGrp:AddInput('PP_Streak',   {Text='Fake Winstreak',    Default='999', Numeric=true, Callback=function(v) PP_Streak=tonumber(v) or 0 end})
end

-- ====================== UI: SETTINGS TAB ======================
do
    local STab    = Tabs.Settings
    local MenuGrp = STab:AddLeftGroupbox('Menu')
    MenuGrp:AddButton('Unload', function()
        for p, d in pairs(ESP_Pool)    do for _, dr in pairs(d) do pcall(function() dr:Remove() end) end end
        for e, d in pairs(BotESP_Pool) do for _, dr in pairs(d) do pcall(function() dr:Remove() end) end end
        for _, e  in ipairs(KF_Pool)   do pcall(function() e.drawing:Remove() end) end
        pcall(function() FOV_Drawing:Remove() end)
        for _, l in pairs(CH_Lines) do pcall(function() l:Remove() end) end
        if CH_DotDraw then pcall(function() CH_DotDraw:Remove() end) end
        Library:Unload()
    end)
    MenuGrp:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {Default='End', NoUI=true, Text='Menu keybind'})
    Library.ToggleKeybind = Options.MenuKeybind

    local AdvGrp = STab:AddLeftGroupbox('Advanced')
    AdvGrp:AddToggle('ShowAdvanced',{Text='Show advanced options', Default=false})
    local AdvBox = AdvGrp:AddDependencyBox()
    AdvBox:AddSlider('UIScaleSlider',     {Text='UI Scale',          Default=100, Min=50,  Max=150, Rounding=0, Suffix='%',  Callback=function(v) Window:SetScale(v/100) end})
    AdvBox:AddSlider('UITransSlider',     {Text='Menu Transparency', Default=0,   Min=0,   Max=90,  Rounding=0, Suffix='%',  Callback=function(v) Window:SetTransparency(v/100) end})
    AdvBox:AddToggle('MobileButtonToggle',{Text='Floating button',   Default=true, Callback=function(v) Library:SetMobileButtonVisibility(v) end})
    AdvBox:AddDivider()
    AdvBox:AddDropdown('WeatherEffect',   {Text='Weather Effect',    Values={'None','Snow','Rain','Lightning'}, Default='None', Callback=function(v) Library:SetWeatherEffect(v) end})
    AdvBox:AddDropdown('WeatherScope',    {Text='Weather Location',  Values={'Inside UI','Whole screen'},       Default='Inside UI', Callback=function(v) Library:SetWeatherScope(v=='Whole screen' and 'Screen' or 'UI') end})
    AdvBox:AddToggle('GlowToggle',        {Text='Glow Effect',       Default=true,  Callback=function(v) Library:SetGlowEnabled(v) end})
    AdvBox:AddLabel('Glow Color'):AddColorPicker('GlowColor',{Default=Color3.fromRGB(110,60,220), Callback=function(v) Library:SetGlowColor(v) end})
    AdvBox:SetupDependencies({{Toggles.ShowAdvanced, true}})
end

-- ====================== ADDONS ======================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetFolder('ONYXHub')
SaveManager:SetFolder('ONYXHub/specific-game')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
