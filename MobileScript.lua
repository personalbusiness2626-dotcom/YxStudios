-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- Mobile version - Aimlock + FOV removed + Movement/Combat tab
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Yx Studio's",
    Footer = "1.0.0 Beta | Freemium | MOBILE",
    Icon = 135416919651671,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    ["Combat"] = Window:AddTab("Combat", "swords"),
    ["Movement"] = Window:AddTab("Player", "user"),
    ESP = Window:AddTab("Visuals", "view"),
    Autofarm = Window:AddTab("Auto Farm", "tickets"),
    ["UI Settings"] = Window:AddTab("Settings", "settings"),
}

-- ==================== TAB COMBAT ====================
-- ==================== COMBAT TAB - AIMLOCK + ADVANCED FOV (MOBILE + FLOATING BUTTON) ====================
getgenv().Aimlock = {
    Enabled = false,
    Aiming = false,
    Part = "Head",
    OldPart = "Head",
    Radius = 150,
    MaxDistance = 50,
    TeamCheck = false,
    Predict = false,
    Prediction = 15,
    Smooth = 0,
    AliveCheck = false,
    Airshot = false,
    Sticky = true,
    WallCheck = false,
    TargetIndicator = false,
    AutoSwitch = false,
    ShowFloatingButton = false
}

getgenv().FOV = {
    Enabled = false,
    Radius = 150,
    Color = Color3.fromRGB(255, 0, 70),
    Thickness = 1.6,
    Transparency = 0.15,
    Filled = false,
    FillTransparency = 0.7,
    NumSides = 64,
    Glow = false,
    Rainbow = false,
    Pulse = false,
    OnlyWhenAiming = false,
    FollowMouse = true,
    TargetColor = false,
    LockedColor = Color3.fromRGB(0, 255, 100)
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Target = nil
local LockedTarget = nil

-- ==================== FOV DRAWINGS ====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = 150
FOVCircle.Color = Color3.fromRGB(255, 0, 70)
FOVCircle.Thickness = 1.6
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 0.9
FOVCircle.Visible = false
FOVCircle.ZIndex = 10

local FOVGlow = Drawing.new("Circle")
FOVGlow.Radius = 150
FOVGlow.Color = Color3.fromRGB(255, 0, 70)
FOVGlow.Thickness = 4
FOVGlow.NumSides = 64
FOVGlow.Filled = false
FOVGlow.Transparency = 0.7
FOVGlow.Visible = false
FOVGlow.ZIndex = 9

-- ==================== TARGET INDICATOR ====================
local TargetHighlight = Instance.new("Highlight")
TargetHighlight.Name = "AimlockTargetIndicator"
TargetHighlight.FillColor = Color3.fromRGB(255, 50, 50)
TargetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
TargetHighlight.FillTransparency = 0.6
TargetHighlight.OutlineTransparency = 0
TargetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
TargetHighlight.Enabled = false
TargetHighlight.Parent = CoreGui

-- ==================== ANIMATION VARIABLES ====================
local rainbowValue = 0
local pulseValue = 0
local pulseDirection = 1

-- ==================== FLOATING BUTTON ====================
local AimFloatingGui = nil

local function UpdateFloatingButtonVisual()
    if not AimFloatingGui then return end
    local frame = AimFloatingGui:FindFirstChild("AimFrame")
    local button = frame and frame:FindFirstChild("AimButton")
    if not frame or not button then return end

    if getgenv().Aimlock.Enabled and getgenv().Aimlock.Aiming then
        frame.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
        button.Text = "Aim ON"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        button.Text = "Aim OFF"
        button.TextColor3 = Color3.fromRGB(230, 230, 235)
    end
end

local function CreateAimFloatingButton()
    if AimFloatingGui then
        AimFloatingGui:Destroy()
        AimFloatingGui = nil
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimlockFloating"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "AimFrame"
    frame.Size = UDim2.new(0, 95, 0, 42)
    frame.Position = UDim2.new(1, -115, 1, -220)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = frame

    local button = Instance.new("TextButton")
    button.Name = "AimButton"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = "Aim OFF"
    button.TextColor3 = Color3.fromRGB(230, 230, 235)
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.Parent = frame

    button.MouseEnter:Connect(function()
        if not (getgenv().Aimlock.Enabled and getgenv().Aimlock.Aiming) then
            frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        end
    end)

    button.MouseLeave:Connect(function()
        UpdateFloatingButtonVisual()
    end)

    button.MouseButton1Down:Connect(function()
        if not (getgenv().Aimlock.Enabled and getgenv().Aimlock.Aiming) then
            frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end
    end)

    button.MouseButton1Up:Connect(function()
        UpdateFloatingButtonVisual()
    end)

    local dragging = false
    local dragStart = nil
    local startPos = nil

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    button.MouseButton1Click:Connect(function()
        local newState = not (getgenv().Aimlock.Enabled and getgenv().Aimlock.Aiming)
        getgenv().Aimlock.Enabled = newState
        getgenv().Aimlock.Aiming = newState

        if not newState then
            Target = nil
            LockedTarget = nil
            TargetHighlight.Enabled = false
            TargetHighlight.Adornee = nil
        end

        UpdateFloatingButtonVisual()
    end)

    AimFloatingGui = screenGui
    UpdateFloatingButtonVisual()
end

local function DestroyAimFloatingButton()
    if AimFloatingGui then
        AimFloatingGui:Destroy()
        AimFloatingGui = nil
    end
end

-- ==================== FUNCTIONS ====================
local function GetDistance(player)
    local myChar = LocalPlayer.Character
    local theirChar = player.Character
    if not myChar or not theirChar then return 999999 end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local theirRoot = theirChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not theirRoot then return 999999 end
    return (myRoot.Position - theirRoot.Position).Magnitude
end

local function IsVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar and hitChar:FindFirstChild("Humanoid") then
            return true
        end
        return false
    end
    return true
end

local function GetClosest()
    local closest = nil
    local bestScore = math.huge
    local screenCenter = Camera.ViewportSize / 2

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if getgenv().Aimlock.TeamCheck and plr.Team == LocalPlayer.Team then
                continue
            end

            local part = plr.Character:FindFirstChild(getgenv().Aimlock.Part) or plr.Character:FindFirstChild("Head")
            if part then
                local sp, onscreen = Camera:WorldToViewportPoint(part.Position)
                if onscreen then
                    local screenDist = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude

                    if screenDist > getgenv().Aimlock.Radius then
                        continue
                    end

                    local worldDist = GetDistance(plr)
                    if worldDist > getgenv().Aimlock.MaxDistance then
                        continue
                    end

                    if getgenv().Aimlock.WallCheck and not IsVisible(part) then
                        continue
                    end

                    local score = (worldDist * 2) + (screenDist * 0.35)
                    if score < bestScore then
                        bestScore = score
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

-- ==================== FOV LOOP ====================
RunService.RenderStepped:Connect(function(dt)
    local cfg = getgenv().FOV
    local shouldShow = cfg.Enabled

    if cfg.OnlyWhenAiming then
        shouldShow = shouldShow and getgenv().Aimlock.Enabled and getgenv().Aimlock.Aiming
    end

    if not shouldShow then
        FOVCircle.Visible = false
        FOVGlow.Visible = false
        return
    end

    local pos
    if cfg.FollowMouse then
        pos = Vector2.new(Mouse.X, Mouse.Y + 36)
    else
        pos = Camera.ViewportSize / 2
    end

    local finalColor = cfg.Color
    if cfg.Rainbow then
        rainbowValue = (rainbowValue + dt * 0.4) % 1
        finalColor = Color3.fromHSV(rainbowValue, 1, 1)
    elseif cfg.TargetColor and Target then
        finalColor = cfg.LockedColor
    end

    local finalRadius = cfg.Radius
    if cfg.Pulse then
        pulseValue = pulseValue + (dt * pulseDirection * 30)
        if pulseValue >= 12 then
            pulseValue = 12
            pulseDirection = -1
        elseif pulseValue <= -12 then
            pulseValue = -12
            pulseDirection = 1
        end
        finalRadius = cfg.Radius + pulseValue
    end

    FOVCircle.Position = pos
    FOVCircle.Radius = finalRadius
    FOVCircle.Color = finalColor
    FOVCircle.Thickness = cfg.Thickness
    FOVCircle.NumSides = cfg.NumSides
    FOVCircle.Filled = cfg.Filled
    FOVCircle.Transparency = cfg.Filled and cfg.FillTransparency or cfg.Transparency
    FOVCircle.Visible = true

    if cfg.Glow then
        FOVGlow.Position = pos
        FOVGlow.Radius = finalRadius
        FOVGlow.Color = finalColor
        FOVGlow.Transparency = 0.75
        FOVGlow.Visible = true
    else
        FOVGlow.Visible = false
    end
end)

-- ==================== AIMLOCK LOOP ====================
RunService.Heartbeat:Connect(function()
    if not getgenv().Aimlock.Enabled or not getgenv().Aimlock.Aiming then
        Target = nil
        LockedTarget = nil
        TargetHighlight.Enabled = false
        TargetHighlight.Adornee = nil
        return
    end

    if getgenv().Aimlock.Sticky then
        if not LockedTarget or not LockedTarget.Parent or not LockedTarget.Character or not LockedTarget.Character:FindFirstChild("Humanoid") or LockedTarget.Character.Humanoid.Health <= 0 then
            if getgenv().Aimlock.AutoSwitch or not LockedTarget then
                LockedTarget = GetClosest()
            else
                LockedTarget = nil
            end
        end
        Target = LockedTarget
    else
        Target = GetClosest()
        LockedTarget = Target
    end

    if getgenv().Aimlock.AliveCheck and Target and Target.Character and Target.Character:FindFirstChild("Humanoid") then
        if Target.Character.Humanoid.Health <= 0 then
            Target = nil
            LockedTarget = nil
        end
    end

    if getgenv().Aimlock.Airshot and Target and Target.Character and Target.Character:FindFirstChild("Humanoid") then
        if Target.Character.Humanoid.FloorMaterial == Enum.Material.Air then
            getgenv().Aimlock.Part = "RightFoot"
        else
            getgenv().Aimlock.Part = getgenv().Aimlock.OldPart
        end
    end

    if getgenv().Aimlock.TargetIndicator and Target and Target.Character then
        TargetHighlight.Adornee = Target.Character
        TargetHighlight.Enabled = true
    else
        TargetHighlight.Enabled = false
        TargetHighlight.Adornee = nil
    end

    if Target and Target.Character and Target.Character:FindFirstChild(getgenv().Aimlock.Part) then
        local part = Target.Character[getgenv().Aimlock.Part]
        local pos = part.Position

        if getgenv().Aimlock.Predict then
            pos = pos + (part.Velocity / getgenv().Aimlock.Prediction)
        end

        if getgenv().Aimlock.Smooth > 0 then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), getgenv().Aimlock.Smooth)
        else
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
        end
    end
end)

-- ==================== UI - AIMLOCK (MOBILE) ====================
local AimBox = Tabs.Combat:AddLeftGroupbox("Aimlock (Mobile)", "sword")

AimBox:AddToggle("AimlockEnabled", {
    Text = "Aim Assist",
    Default = false,
    Tooltip = "Turn on to start aiming",
    Callback = function(Value)
        getgenv().Aimlock.Enabled = Value
        getgenv().Aimlock.Aiming = Value

        if not Value then
            Target = nil
            LockedTarget = nil
            TargetHighlight.Enabled = false
            TargetHighlight.Adornee = nil
        end

        UpdateFloatingButtonVisual()
    end
})

AimBox:AddToggle("ShowAimFloating", {
    Text = "Show Floating Button",
    Default = false,
    Tooltip = "Shows a permanent toggle button on screen",
    Callback = function(Value)
        getgenv().Aimlock.ShowFloatingButton = Value
        if Value then
            CreateAimFloatingButton()
        else
            DestroyAimFloatingButton()
        end
    end
})

AimBox:AddDropdown("AimPart", {
    Values = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
    Default = 1,
    Text = "Aim Part",
    Callback = function(v)
        getgenv().Aimlock.Part = v
        getgenv().Aimlock.OldPart = v
    end
})

AimBox:AddToggle("StickyAim", {
    Text = "Sticky Aim",
    Default = true,
    Tooltip = "Stays locked on target",
    Callback = function(v) getgenv().Aimlock.Sticky = v end
})

AimBox:AddToggle("WallCheck", {
    Text = "Wall Check",
    Default = false,
    Tooltip = "Only aims at visible players",
    Callback = function(v) getgenv().Aimlock.WallCheck = v end
})

AimBox:AddToggle("AutoSwitch", {
    Text = "Auto Switch",
    Default = false,
    Tooltip = "Switches target when they die",
    Callback = function(v) getgenv().Aimlock.AutoSwitch = v end
})

AimBox:AddToggle("TargetIndicator", {
    Text = "Target Indicator",
    Default = false,
    Tooltip = "Highlights the player you're aiming at",
    Callback = function(v)
        getgenv().Aimlock.TargetIndicator = v
        if not v then
            TargetHighlight.Enabled = false
            TargetHighlight.Adornee = nil
        end
    end
})

AimBox:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = false,
    Callback = function(v) getgenv().Aimlock.TeamCheck = v end
})

AimBox:AddToggle("AliveCheck", {
    Text = "Alive Check",
    Default = false,
    Callback = function(v) getgenv().Aimlock.AliveCheck = v end
})

AimBox:AddToggle("Prediction", {
    Text = "Prediction",
    Default = false,
    Callback = function(v) getgenv().Aimlock.Predict = v end
})

AimBox:AddToggle("Airshot", {
    Text = "Airshot Function",
    Default = false,
    Callback = function(v) getgenv().Aimlock.Airshot = v end
})

AimBox:AddSlider("Smoothness", {
    Text = "Smoothness",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v) getgenv().Aimlock.Smooth = v end
})

AimBox:AddSlider("PredictionPower", {
    Text = "Prediction Movement",
    Default = 15,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Callback = function(v) getgenv().Aimlock.Prediction = v end
})

AimBox:AddSlider("AimRadius", {
    Text = "Aim Radius (Screen)",
    Default = 150,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Tooltip = "Screen area where aim can lock (independent from FOV circle)",
    Callback = function(v)
        getgenv().Aimlock.Radius = v
    end
})

AimBox:AddInput("AimMaxDistance", {
    Default = "50",
    Numeric = true,
    Finished = true,
    Text = "Max Distance (Studs)",
    Tooltip = "Maximum world distance you can aim at",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            getgenv().Aimlock.MaxDistance = num
        end
    end
})

-- ==================== UI - FOV ====================
local FOVBox = Tabs.Combat:AddRightGroupbox("FOV", "circle")

FOVBox:AddToggle("ShowFOV", {
    Text = "Show FOV Circle",
    Default = false,
    Callback = function(v) getgenv().FOV.Enabled = v end
})

FOVBox:AddToggle("FOVFollowMouse", {
    Text = "Follow Mouse",
    Default = true,
    Tooltip = "Off = center of screen",
    Callback = function(v) getgenv().FOV.FollowMouse = v end
})

FOVBox:AddToggle("FOVOnlyWhenAiming", {
    Text = "Only When Aiming",
    Default = false,
    Tooltip = "Only shows when aimlock is active",
    Callback = function(v) getgenv().FOV.OnlyWhenAiming = v end
})

FOVBox:AddToggle("FOVFilled", {
    Text = "FOV Filled",
    Default = false,
    Callback = function(v) getgenv().FOV.Filled = v end
})

FOVBox:AddToggle("FOVGlow", {
    Text = "FOV Glow",
    Default = false,
    Tooltip = "Glow effect",
    Callback = function(v) getgenv().FOV.Glow = v end
})

FOVBox:AddToggle("FOVRainbow", {
    Text = "Rainbow FOV",
    Default = false,
    Callback = function(v) getgenv().FOV.Rainbow = v end
})

FOVBox:AddToggle("FOVPulse", {
    Text = "Pulse Effect",
    Default = false,
    Tooltip = "FOV pulsates",
    Callback = function(v) getgenv().FOV.Pulse = v end
})

FOVBox:AddToggle("FOVTargetColor", {
    Text = "Change Color on Target",
    Default = false,
    Tooltip = "Changes color when targeting",
    Callback = function(v) getgenv().FOV.TargetColor = v end
})

FOVBox:AddSlider("FOVSize", {
    Text = "FOV Radius",
    Default = 150,
    Min = 10,
    Max = 400,
    Rounding = 0,
    Callback = function(v)
        getgenv().FOV.Radius = v
    end
})

FOVBox:AddSlider("FOVThickness", {
    Text = "Thickness",
    Default = 1.6,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Callback = function(v) getgenv().FOV.Thickness = v end
})

FOVBox:AddSlider("FOVTransparency", {
    Text = "Outline Transparency",
    Default = 0.15,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v) getgenv().FOV.Transparency = v end
})

FOVBox:AddSlider("FOVFillTransparency", {
    Text = "Fill Transparency",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v) getgenv().FOV.FillTransparency = v end
})

FOVBox:AddSlider("FOVNumSides", {
    Text = "Circle Quality",
    Default = 64,
    Min = 12,
    Max = 128,
    Rounding = 0,
    Tooltip = "More sides = smoother",
    Callback = function(v) getgenv().FOV.NumSides = v end
})

FOVBox:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(255, 0, 70),
    Callback = function(v) getgenv().FOV.Color = v end
})

FOVBox:AddLabel("Locked Color"):AddColorPicker("FOVLockedColor", {
    Default = Color3.fromRGB(0, 255, 100),
    Callback = function(v) getgenv().FOV.LockedColor = v end
})

print("[COMBAT] Aimlock + FOV (Mobile + Floating Button - All Features) loaded")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

-- ==================== SHARED FUNCTIONS ====================
local function GetDistance(player)
    local myChar = LocalPlayer.Character
    local theirChar = player.Character
    if not myChar or not theirChar then return 999999 end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local theirRoot = theirChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not theirRoot then return 999999 end
    return (myRoot.Position - theirRoot.Position).Magnitude
end

local function IsAlive(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function IsSameTeam(player)
    if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
        return true
    end
    if LocalPlayer.TeamColor and player.TeamColor and player.TeamColor == LocalPlayer.TeamColor then
        return true
    end
    return false
end

local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ==================== TAB ESP ====================
local ESPLeftGroup = Tabs.ESP:AddLeftGroupbox("ESP - V1", "eye")
local ESP1LeftGroup = Tabs.ESP:AddLeftGroupbox("ESP - Check Team", "eye")

getgenv().FriendList = getgenv().FriendList or {}

ESPLeftGroup:AddToggle("NameESP", {
    Text = "Name ESP",
    Default = false,
}):AddColorPicker("NameESPColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Name Color",
})

ESPLeftGroup:AddToggle("NameESPAliveCheck", {
    Text = "Alive Check",
    Default = true,
})

ESPLeftGroup:AddToggle("NameESPTeamCheck", {
    Text = "Team Check",
    Default = false,
})

ESPLeftGroup:AddToggle("NameESPFriendCheck", {
    Text = "Friend Check",
    Default = true,
}):AddColorPicker("FriendESPColor", {
    Default = Color3.fromRGB(0, 255, 100),
    Title = "Friend Color",
})

ESPLeftGroup:AddDropdown("NameESPFont", {
    Values = {
        "Gotham", "GothamBold", "SourceSans", "SourceSansBold",
        "Arcade", "Code", "SciFi", "FredokaOne", "Oswald",
        "PermanentMarker", "Roboto", "SpecialElite", "Ubuntu"
    },
    Default = 2,
    Multi = false,
    Text = "Name Font",
})

ESPLeftGroup:AddSlider("NameESPSize", {
    Text = "Name Size",
    Default = 14,
    Min = 8,
    Max = 30,
    Rounding = 0,
})

ESP1LeftGroup:AddDropdown("FriendListDropdown", {
    Values = {"None"},
    Default = 1,
    Multi = false,
    Text = "Select Player to Add Friend",
})

ESP1LeftGroup:AddButton({
    Text = "Add Selected to Friends",
    Func = function()
        local dropdown = Options.FriendListDropdown
        if not dropdown then return end
        local selected = dropdown.Value
        if typeof(selected) == "number" then
            selected = dropdown.Values and dropdown.Values[selected]
        end
        if typeof(selected) ~= "string" or selected == "" or selected == "None" then
            Library:Notify("Selecciona un jugador válido", 3)
            return
        end
        for _, name in ipairs(getgenv().FriendList) do
            if name == selected then
                Library:Notify(selected .. " ya es amigo", 3)
                return
            end
        end
        table.insert(getgenv().FriendList, selected)
        Library:Notify("✓ Added: " .. selected, 4)
    end,
})

ESP1LeftGroup:AddButton({
    Text = "Clear Friends List",
    Func = function()
        table.clear(getgenv().FriendList)
        Library:Notify("Friends list cleared", 3)
    end,
})

local NameESPObjects = {}

local function IsFriend(player)
    if not player then return false end
    for _, name in ipairs(getgenv().FriendList) do
        if name == player.Name then
            return true
        end
    end
    return false
end

local function RefreshFriendDropdown()
    local list = {"None"}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    if Options and Options.FriendListDropdown then
        Options.FriendListDropdown:SetValues(list)
    end
end

local function CreateNameESP(player)
    if player == LocalPlayer then return end
    if NameESPObjects[player] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameESP_" .. player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.Enabled = false
    local label = Instance.new("TextLabel")
    label.Name = "Name"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Text = player.Name
    label.Parent = billboard
    NameESPObjects[player] = billboard
end

local function RemoveNameESP(player)
    if NameESPObjects[player] then
        NameESPObjects[player]:Destroy()
        NameESPObjects[player] = nil
    end
end

local function AttachToCharacter(player)
    local bb = NameESPObjects[player]
    if not bb then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if root then
        bb.Adornee = root
        bb.Parent = root
    end
end

RunService.RenderStepped:Connect(function()
    local enabled = Toggles and Toggles.NameESP and Toggles.NameESP.Value
    if not enabled then
        for _, bb in pairs(NameESPObjects) do
            bb.Enabled = false
        end
        return
    end
    local normalColor = (Options.NameESPColor and Options.NameESPColor.Value) or Color3.fromRGB(255, 255, 255)
    local friendColor = (Options.FriendESPColor and Options.FriendESPColor.Value) or Color3.fromRGB(0, 255, 100)
    local fontName = (Options.NameESPFont and Options.NameESPFont.Value) or "GothamBold"
    local textSize = (Options.NameESPSize and Options.NameESPSize.Value) or 14
    local aliveCheck = Toggles.NameESPAliveCheck and Toggles.NameESPAliveCheck.Value
    local teamCheck = Toggles.NameESPTeamCheck and Toggles.NameESPTeamCheck.Value
    local friendCheck = Toggles.NameESPFriendCheck and Toggles.NameESPFriendCheck.Value
    local fontEnum = Enum.Font[fontName] or Enum.Font.GothamBold

    for player, billboard in pairs(NameESPObjects) do
        local canShow = false
        local char = player.Character
        if char then
            local ok = true
            if aliveCheck and not IsAlive(player) then
                ok = false
            end
            if teamCheck and IsSameTeam(player) then
                ok = false
            end
            if ok then
                canShow = true
                if not billboard.Adornee or not billboard.Adornee.Parent then
                    AttachToCharacter(player)
                end
                local label = billboard:FindFirstChild("Name")
                if label then
                    label.Text = player.Name
                    label.TextSize = textSize
                    label.Font = fontEnum
                    if friendCheck and IsFriend(player) then
                        label.TextColor3 = friendColor
                    else
                        label.TextColor3 = normalColor
                    end
                end
            end
        end
        billboard.Enabled = canShow
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        RefreshFriendDropdown()
    end
end)

local function SetupPlayer(player)
    CreateNameESP(player)
    if player.Character then
        AttachToCharacter(player)
    end
    player.CharacterAdded:Connect(function()
        task.wait(0.4)
        CreateNameESP(player)
        AttachToCharacter(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    SetupPlayer(player)
    task.delay(0.5, RefreshFriendDropdown)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveNameESP(player)
    for i, name in ipairs(getgenv().FriendList) do
        if name == player.Name then
            table.remove(getgenv().FriendList, i)
            break
        end
    end
    task.delay(0.3, RefreshFriendDropdown)
end)

task.delay(1, RefreshFriendDropdown)
print("[SISTEMA ESP] Name ESP cargado correctamente")

-- ==================== BOX ESP (ARREGLADO) ====================
local ESPRightGroup = Tabs.ESP:AddRightGroupbox("ESP - V2", "box")

ESPRightGroup:AddToggle("BoxESP", {
    Text = "Box ESP",
    Default = false,
}):AddColorPicker("BoxESPColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "Box Color",
})

ESPRightGroup:AddToggle("BoxESP2D", {
    Text = "Change 2D BOX",
    Default = false,
})

ESPRightGroup:AddToggle("BoxESPFilled", {
    Text = "Box Filled",
    Default = false,
})

ESPRightGroup:AddSlider("BoxESPThickness", {
    Text = "Box Thickness",
    Default = 0.05,
    Min = 0.01,
    Max = 0.25,
    Rounding = 2,
})

ESPRightGroup:AddSlider("BoxESPTransparency", {
    Text = "Outline Transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
})

ESPRightGroup:AddSlider("BoxESPFillTransparency", {
    Text = "Fill Transparency",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
})

ESPRightGroup:AddToggle("BoxESPAliveCheck", {
    Text = "Alive Check",
    Default = true,
})

ESPRightGroup:AddToggle("BoxESPTeamCheck", {
    Text = "Team Check",
    Default = false,
})

ESPRightGroup:AddToggle("BoxESPFriendCheck", {
    Text = "Friend Check",
    Default = true,
}):AddColorPicker("BoxFriendColor", {
    Default = Color3.fromRGB(0, 255, 100),
    Title = "Friend Box Color",
})

ESPRightGroup:AddSlider("BoxESPMaxDistance", {
    Text = "Max Distance",
    Default = 2000,
    Min = 50,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
})

local BoxESPObjects = {}
local Box2DObjects = {}
local BoxFolder = Instance.new("Folder")
BoxFolder.Name = "BoxESPFolder"
BoxFolder.Parent = CoreGui

local function RemoveBox3D(player)
    if BoxESPObjects[player] then
        pcall(function() BoxESPObjects[player]:Destroy() end)
        BoxESPObjects[player] = nil
    end
end

local function CreateBox3D(player)
    if player == LocalPlayer then return end
    RemoveBox3D(player)
    local char = player.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "BoxESP_" .. player.Name
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = BoxFolder
    BoxESPObjects[player] = highlight
end

local function RemoveBox2D(player)
    if Box2DObjects[player] then
        pcall(function()
            if Box2DObjects[player].Square then
                Box2DObjects[player].Square:Remove()
            end
        end)
        Box2DObjects[player] = nil
    end
end

local function CreateBox2D(player)
    if player == LocalPlayer then return end
    RemoveBox2D(player)
    local square = Drawing.new("Square")
    square.Visible = false
    square.Thickness = 1
    square.Filled = false
    square.Color = Color3.fromRGB(255, 0, 0)
    square.Transparency = 1
    square.ZIndex = 1
    Box2DObjects[player] = { Square = square }
end

local function Get2DBox(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not root then return nil end

    local topPos = head and (head.Position + Vector3.new(0, 0.5, 0)) or (root.Position + Vector3.new(0, 2.8, 0))
    local bottomPos = root.Position - Vector3.new(0, 3.2, 0)

    local top, topOnScreen = Camera:WorldToViewportPoint(topPos)
    local bottom, bottomOnScreen = Camera:WorldToViewportPoint(bottomPos)

    if not topOnScreen and not bottomOnScreen then
        return nil
    end

    local height = math.abs(top.Y - bottom.Y)
    local width = height / 1.7
    local size = Vector2.new(width, height)
    local position = Vector2.new(top.X - width / 2, top.Y)

    return position, size, top.Z > 0
end

RunService.RenderStepped:Connect(function()
    local enabled = Toggles and Toggles.BoxESP and Toggles.BoxESP.Value == true
    local use2D = Toggles and Toggles.BoxESP2D and Toggles.BoxESP2D.Value == true

    if not enabled then
        for _, box in pairs(BoxESPObjects) do
            if box then box.Enabled = false end
        end
        for _, data in pairs(Box2DObjects) do
            if data and data.Square then data.Square.Visible = false end
        end
        return
    end

    local normalColor = (Options and Options.BoxESPColor and Options.BoxESPColor.Value) or Color3.fromRGB(255, 0, 0)
    local friendColor = (Options and Options.BoxFriendColor and Options.BoxFriendColor.Value) or Color3.fromRGB(0, 255, 100)
    local thickness = (Options and Options.BoxESPThickness and Options.BoxESPThickness.Value) or 0.05
    local outlineTrans = (Options and Options.BoxESPTransparency and Options.BoxESPTransparency.Value) or 0
    local fillTrans = (Options and Options.BoxESPFillTransparency and Options.BoxESPFillTransparency.Value) or 0.7
    local filled = Toggles.BoxESPFilled and Toggles.BoxESPFilled.Value == true
    local maxDist = (Options and Options.BoxESPMaxDistance and Options.BoxESPMaxDistance.Value) or 2000
    local aliveCheck = Toggles.BoxESPAliveCheck and Toggles.BoxESPAliveCheck.Value == true
    local teamCheck = Toggles.BoxESPTeamCheck and Toggles.BoxESPTeamCheck.Value == true
    local friendCheck = Toggles.BoxESPFriendCheck and Toggles.BoxESPFriendCheck.Value == true

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local char = player.Character
        local canShow = true

        if not char then
            canShow = false
        else
            if aliveCheck and not IsAlive(player) then canShow = false end
            if teamCheck and IsSameTeam(player) then canShow = false end
            if GetDistance(player) > maxDist then canShow = false end
        end

        local color = normalColor
        if canShow and friendCheck and IsFriend(player) then
            color = friendColor
        end

        if use2D then
            -- Ocultar 3D
            if BoxESPObjects[player] then
                BoxESPObjects[player].Enabled = false
            end

            if not Box2DObjects[player] then
                CreateBox2D(player)
            end

            local data = Box2DObjects[player]
            if data and data.Square then
                if canShow then
                    local pos, size, onScreen = Get2DBox(char)
                    if pos and size and onScreen then
                        data.Square.Position = pos
                        data.Square.Size = size
                        data.Square.Color = color
                        data.Square.Thickness = math.clamp(thickness * 20, 1, 5)
                        data.Square.Filled = filled
                        data.Square.Transparency = filled and (1 - fillTrans) or (1 - outlineTrans)
                        data.Square.Visible = true
                    else
                        data.Square.Visible = false
                    end
                else
                    data.Square.Visible = false
                end
            end
        else
            -- Ocultar 2D
            if Box2DObjects[player] and Box2DObjects[player].Square then
                Box2DObjects[player].Square.Visible = false
            end

            local box = BoxESPObjects[player]
            if char and (not box or not box.Parent or box.Adornee ~= char) then
                CreateBox3D(player)
                box = BoxESPObjects[player]
            end

            if box then
                if canShow then
                    box.FillColor = color
                    box.OutlineColor = color
                    box.FillTransparency = filled and fillTrans or 1
                    box.OutlineTransparency = outlineTrans
                    box.Enabled = true
                else
                    box.Enabled = false
                end
            end
        end
    end
end)

local function SetupBoxPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then
        task.defer(function()
            CreateBox3D(player)
            CreateBox2D(player)
        end)
    end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        CreateBox3D(player)
        CreateBox2D(player)
    end)
    player.CharacterRemoving:Connect(function()
        RemoveBox3D(player)
        RemoveBox2D(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupBoxPlayer(player)
end
Players.PlayerAdded:Connect(SetupBoxPlayer)
Players.PlayerRemoving:Connect(function(player)
    RemoveBox3D(player)
    RemoveBox2D(player)
end)

print("[SISTEMA ESP] Box ESP 3D + 2D cargado")

-- ==================== UI SETTINGS ====================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})

MenuGroup:AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = Library.CornerRadius or 0,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(value)
        Window:SetCornerRadius(value)
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", {
        Default = "M",
        NoUI = true,
        Text = "Menu keybind",
    })

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        for _, toggle in pairs(Toggles) do
            if toggle.Value == true then
                pcall(function()
                    toggle:SetValue(false)
                end)
            end
        end
        Library:Unload()
    end,
    Tooltip = "Cierra el menú y desactiva todas las funciones",
})

-- ==================== MOVEMENT TAB ====================
local MovementTab = Tabs.Movement

-- ==================== PRESS FAST ====================
getgenv().PressFast = {
    Enabled = false,
    HoldTime = 0.15,
    DiedPoint = nil,
    TeleportOnRespawn = false
}

local OriginalPrompts = {}
local PromptConnection = nil
local DiedConnection = nil

local function ApplyFastPrompts()
    if not getgenv().PressFast.Enabled then return end
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if OriginalPrompts[prompt] == nil then
                OriginalPrompts[prompt] = prompt.HoldDuration
            end
            pcall(function()
                prompt.HoldDuration = getgenv().PressFast.HoldTime
            end)
        end
    end
end

local function RestorePrompts()
    for prompt, originalTime in pairs(OriginalPrompts) do
        if prompt and prompt.Parent then
            pcall(function()
                prompt.HoldDuration = originalTime
            end)
        end
    end
    table.clear(OriginalPrompts)
end

local function StartPromptListener()
    if PromptConnection then return end
    PromptConnection = workspace.DescendantAdded:Connect(function(obj)
        if not getgenv().PressFast.Enabled then return end
        if obj:IsA("ProximityPrompt") then
            if OriginalPrompts[obj] == nil then
                OriginalPrompts[obj] = obj.HoldDuration
            end
            pcall(function()
                obj.HoldDuration = getgenv().PressFast.HoldTime
            end)
        end
    end)
end

local function StopPromptListener()
    if PromptConnection then
        PromptConnection:Disconnect()
        PromptConnection = nil
    end
end

local function ForceRespawn()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
end

local function TeleportToDiedPoint()
    if not getgenv().PressFast.DiedPoint then return end
    local root = GetRoot()
    if root then
        root.CFrame = CFrame.new(getgenv().PressFast.DiedPoint)
        Library:Notify("Teleported to Died Point", 3)
    end
end

local function SetupDiedConnection()
    if DiedConnection then
        DiedConnection:Disconnect()
        DiedConnection = nil
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    DiedConnection = hum.Died:Connect(function()
        if getgenv().PressFast.TeleportOnRespawn and getgenv().PressFast.DiedPoint then
            task.wait(0.8)
            TeleportToDiedPoint()
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    SetupDiedConnection()
    if getgenv().PressFast.TeleportOnRespawn and getgenv().PressFast.DiedPoint then
        task.wait(0.6)
        TeleportToDiedPoint()
    end
end)

local PressBox = MovementTab:AddLeftGroupbox("Press Fast", "zap")

PressBox:AddToggle("PressFastEnabled", {
    Text = "Fast Proximity Prompt",
    Default = false,
    Tooltip = "Reduce el tiempo de hold de todos los ProximityPrompts",
    Callback = function(v)
        getgenv().PressFast.Enabled = v
        if v then
            ApplyFastPrompts()
            StartPromptListener()
        else
            RestorePrompts()
            StopPromptListener()
        end
    end
})

PressBox:AddSlider("PressFastHoldTime", {
    Text = "Prompt Hold Time",
    Default = 0.15,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Suffix = "s",
    Callback = function(v)
        getgenv().PressFast.HoldTime = v
        if getgenv().PressFast.Enabled then
            ApplyFastPrompts()
        end
    end
})

PressBox:AddDivider()

PressBox:AddButton({
    Text = "Force Respawn",
    Func = function()
        ForceRespawn()
        Library:Notify("Respawn forzado", 2)
    end,
    Tooltip = "Te mata para respawnear"
})

PressBox:AddToggle("PressFastTeleportOnRespawn", {
    Text = "Teleport on Respawn",
    Default = false,
    Tooltip = "Al respawnear te lleva automáticamente al Died Point",
    Callback = function(v)
        getgenv().PressFast.TeleportOnRespawn = v
    end
})

if LocalPlayer.Character then
    SetupDiedConnection()
end

print("[PRESS FAST] Cargado en Movement")

-- ==================== MINI SKIP ====================
getgenv().MiniSkip = {
    Distance = 5,
    Cooldown = 0.3,
    ShowFloatingButton = false
}

local lastSkip = 0
local FloatingButtonGui = nil

local function DoMiniSkip()
    if tick() - lastSkip < (getgenv().MiniSkip.Cooldown or 0.3) then return end
    lastSkip = tick()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local look = root.CFrame.LookVector
    local dist = getgenv().MiniSkip.Distance or 5
    local newPos = root.Position + (look * dist)
    root.CFrame = CFrame.new(newPos, newPos + look)
end

local function CreateFloatingButton()
    if FloatingButtonGui then
        FloatingButtonGui:Destroy()
        FloatingButtonGui = nil
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MiniSkipFloating"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "SkipFrame"
    frame.Size = UDim2.new(0, 95, 0, 42)
    frame.Position = UDim2.new(1, -115, 1, -160)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = frame

    local button = Instance.new("TextButton")
    button.Name = "SkipButton"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = "Mini Skip"
    button.TextColor3 = Color3.fromRGB(230, 230, 235)
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.Parent = frame

    button.MouseEnter:Connect(function()
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    end)
    button.MouseLeave:Connect(function()
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end)
    button.MouseButton1Down:Connect(function()
        frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end)
    button.MouseButton1Up:Connect(function()
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    end)

    local dragging = false
    local dragStart = nil
    local startPos = nil

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    button.MouseButton1Click:Connect(function()
        DoMiniSkip()
    end)

    FloatingButtonGui = screenGui
end

local function DestroyFloatingButton()
    if FloatingButtonGui then
        FloatingButtonGui:Destroy()
        FloatingButtonGui = nil
    end
end

local SkipBox = MovementTab:AddLeftGroupbox("Mini Skip", "move")

SkipBox:AddSlider("MiniSkipDistance", {
    Text = "Distance",
    Default = 5,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        getgenv().MiniSkip.Distance = Value
    end
})

SkipBox:AddToggle("MiniSkipFloating", {
    Text = "Show Floating Button",
    Default = false,
    Tooltip = "Muestra un botón permanente con el estilo de la Library",
    Callback = function(Value)
        getgenv().MiniSkip.ShowFloatingButton = Value
        if Value then
            CreateFloatingButton()
        else
            DestroyFloatingButton()
        end
    end
})

SkipBox:AddButton({
    Text = "Skip Now",
    Func = function()
        DoMiniSkip()
    end,
    Tooltip = "Te mueve un poco hacia adelante"
})

print("[MINI SKIP] Cargado en Movement")

-- ==================== AUTO LOOT + AUTO PRESS ====================
getgenv().AutoLoot = {
    Enabled = false,
    AutoPressAny = false,
    MaxDistance = 14,
    OnlyDead = true,
    Key = Enum.KeyCode.E
}

local IsHolding = false
local CachedPrompts = {}
local LastCacheUpdate = 0

local function IsDead(character)
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health <= 0
end

local function UpdatePromptCache()
    table.clear(CachedPrompts)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            table.insert(CachedPrompts, obj)
        end
    end
    LastCacheUpdate = tick()
end

local function HoldPrompt(prompt)
    if IsHolding or not prompt then return end
    IsHolding = true

    local holdTime = math.max(prompt.HoldDuration or 0.5, 0.05)

    VIM:SendKeyEvent(true, getgenv().AutoLoot.Key, false, game)
    task.wait(holdTime)
    VIM:SendKeyEvent(false, getgenv().AutoLoot.Key, false, game)

    task.wait(0.08)
    IsHolding = false
end

local function TryAutoInteract()
    if IsHolding then return end
    if not getgenv().AutoLoot.Enabled and not getgenv().AutoLoot.AutoPressAny then
        return
    end

    local myRoot = GetRoot()
    if not myRoot then return end

    if tick() - LastCacheUpdate > 1.2 then
        UpdatePromptCache()
    end

    local closestPrompt = nil
    local closestDist = getgenv().AutoLoot.MaxDistance

    if getgenv().AutoLoot.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                if getgenv().AutoLoot.OnlyDead and not IsDead(char) then
                    continue
                end

                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        local part = obj.Parent
                        if part and part:IsA("BasePart") then
                            local dist = (myRoot.Position - part.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestPrompt = obj
                            end
                        end
                    end
                end
            end
        end
    end

    if getgenv().AutoLoot.AutoPressAny and not closestPrompt then
        for _, prompt in ipairs(CachedPrompts) do
            if prompt and prompt.Parent and prompt.Enabled then
                local part = prompt.Parent
                if part:IsA("BasePart") then
                    local dist = (myRoot.Position - part.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPrompt = prompt
                    end
                end
            end
        end
    end

    if closestPrompt then
        HoldPrompt(closestPrompt)
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(TryAutoInteract)
    end
end)

local LootBox = MovementTab:AddRightGroupbox("Auto Loot / Press", "backpack")

LootBox:AddToggle("AutoLootEnabled", {
    Text = "Auto Loot (Muertos)",
    Default = false,
    Tooltip = "Lootear automáticamente jugadores muertos cercanos",
    Callback = function(v)
        getgenv().AutoLoot.Enabled = v
        Library:Notify(v and "Auto Loot activado" or "Auto Loot desactivado", 2)
    end
})

LootBox:AddToggle("AutoPressAny", {
    Text = "Auto Press Any Prompt",
    Default = false,
    Tooltip = "Mantiene presionada la E el tiempo completo del prompt y vuelve a hacerlo",
    Callback = function(v)
        getgenv().AutoLoot.AutoPressAny = v
        if v then
            UpdatePromptCache()
        end
        Library:Notify(v and "Auto Press Any activado" or "Auto Press Any desactivado", 2)
    end
})

LootBox:AddDivider()

LootBox:AddSlider("AutoLootDistance", {
    Text = "Max Distance",
    Default = 14,
    Min = 6,
    Max = 25,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(v)
        getgenv().AutoLoot.MaxDistance = v
    end
})

LootBox:AddToggle("AutoLootOnlyDead", {
    Text = "Only Dead Players",
    Default = true,
    Callback = function(v)
        getgenv().AutoLoot.OnlyDead = v
    end
})

print("[AUTO LOOT + AUTO PRESS] Cargado en Movement")

-- ==================== AUTOFARM - MARSHMALLOW (se queda en Auto Farm) ====================
getgenv().MarshFarm = {
    Enabled = false,
    Running = false,
    WaitAfterWater = 20,
    WaitAfterGelatin = 45,
    NotifyEnabled = true,
    NotifyCooldown = 0.8,
    Water = "Water",
    SugarBlock = "Sugar Block Bag",
    Gelatin = "Gelatin",
    EmptyBag = "Empty Bag"
}

local lastNotify = 0

local function Notify(title, text, time)
    if not getgenv().MarshFarm.NotifyEnabled then return end
    if tick() - lastNotify < (getgenv().MarshFarm.NotifyCooldown or 0.8) then return end
    lastNotify = tick()
    if Library and Library.Notify then
        Library:Notify({ Title = title, Description = text, Time = time or 3 })
    else
        print("[AutoFarm]", title, "-", text)
    end
end

local function PlaySuccessSound()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://6026984224"
    s.Volume = 1.5
    s.Parent = game:GetService("SoundService")
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end

local function PressE()
    for i = 1, 3 do
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        end)
        task.wait(0.07)
        pcall(function()
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        task.wait(0.06)
    end
end

local function FindTool(name)
    local char = LocalPlayer.Character
    local bag = LocalPlayer:FindFirstChild("Backpack")
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower() == name:lower() then
                return v
            end
        end
    end
    if bag then
        for _, v in ipairs(bag:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower() == name:lower() then
                return v
            end
        end
    end
    return nil
end

local function CountTool(name)
    local count = 0
    local char = LocalPlayer.Character
    local bag = LocalPlayer:FindFirstChild("Backpack")
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower() == name:lower() then
                count += 1
            end
        end
    end
    if bag then
        for _, v in ipairs(bag:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower() == name:lower() then
                count += 1
            end
        end
    end
    return count
end

local function EquipTool(name)
    for attempt = 1, 3 do
        local tool = FindTool(name)
        if not tool then return false end
        local char = LocalPlayer.Character
        local bag = LocalPlayer:FindFirstChild("Backpack")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not bag or not hum then return false end
        if tool.Parent == char then return true end
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then v.Parent = bag end
        end
        task.wait(0.12)
        tool.Parent = char
        task.wait(0.2)
        if tool.Parent == char then return true end
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.2)
        if tool.Parent == char then return true end
    end
    return false
end

local function HasItems()
    local missing = {}
    if not FindTool(getgenv().MarshFarm.Water) then table.insert(missing, "Water") end
    if not FindTool(getgenv().MarshFarm.SugarBlock) then table.insert(missing, "Sugar Block Bag") end
    if not FindTool(getgenv().MarshFarm.Gelatin) then table.insert(missing, "Gelatin") end
    return #missing == 0, missing
end

local function GetMaxCycles()
    local water = CountTool(getgenv().MarshFarm.Water)
    local sugar = CountTool(getgenv().MarshFarm.SugarBlock)
    local gelatin = CountTool(getgenv().MarshFarm.Gelatin)
    return math.min(water, sugar, gelatin)
end

local function FormatTime(seconds)
    seconds = math.floor(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    if mins > 0 then
        return string.format("%d min %d seg", mins, secs)
    else
        return string.format("%d seg", secs)
    end
end

local function GetTimePerCycle()
    return getgenv().MarshFarm.WaitAfterWater + getgenv().MarshFarm.WaitAfterGelatin + 3
end

local function FarmLoop()
    if getgenv().MarshFarm.Running then return end
    getgenv().MarshFarm.Running = true
    local cycle = 0
    local maxCycles = GetMaxCycles()
    local timePerCycle = GetTimePerCycle()
    local totalSeconds = maxCycles * timePerCycle
    local startTime = tick()

    Notify("Auto Farm", "Farm iniciado | " .. maxCycles .. " ciclos | " .. FormatTime(totalSeconds), 5)

    while getgenv().MarshFarm.Enabled and getgenv().MarshFarm.Running do
        local ok, missing = HasItems()
        if not ok then
            Notify("Auto Farm", "Intentando recuperar ciclo...", 3)
            local recovered = false

            if FindTool(getgenv().MarshFarm.EmptyBag) then
                if EquipTool(getgenv().MarshFarm.EmptyBag) then
                    task.wait(0.35)
                    PressE()
                    task.wait(0.5)
                    Notify("Auto Farm", "Empty Bag usado (recuperación)", 2)
                    recovered = true
                end
            end

            if not recovered and FindTool(getgenv().MarshFarm.SugarBlock) then
                if EquipTool(getgenv().MarshFarm.SugarBlock) then
                    task.wait(0.35)
                    PressE()
                    task.wait(0.4)
                    Notify("Auto Farm", "Sugar Block Bag usado (recuperación)", 2)
                    recovered = true
                end
            end

            if not recovered and FindTool(getgenv().MarshFarm.Water) then
                if EquipTool(getgenv().MarshFarm.Water) then
                    task.wait(0.35)
                    PressE()
                    Notify("Auto Farm", "Water usado (recuperación) → esperando " .. getgenv().MarshFarm.WaitAfterWater .. "s", 3)
                    local waterEnd = tick() + getgenv().MarshFarm.WaitAfterWater
                    while tick() < waterEnd do
                        if not getgenv().MarshFarm.Enabled or not getgenv().MarshFarm.Running then break end
                        task.wait(0.3)
                    end
                    recovered = true
                end
            end

            if not recovered and FindTool(getgenv().MarshFarm.Gelatin) then
                if EquipTool(getgenv().MarshFarm.Gelatin) then
                    task.wait(0.35)
                    PressE()
                    Notify("Auto Farm", "Gelatin usado (recuperación) → esperando " .. getgenv().MarshFarm.WaitAfterGelatin .. "s", 3)
                    local gelEnd = tick() + getgenv().MarshFarm.WaitAfterGelatin
                    while tick() < gelEnd do
                        if not getgenv().MarshFarm.Enabled or not getgenv().MarshFarm.Running then break end
                        task.wait(0.3)
                    end
                    recovered = true
                end
            end

            if not recovered then
                Notify("Auto Farm", "No quedan items: " .. table.concat(missing, ", "), 5)
                break
            end
            task.wait(0.8)
        else
            cycle += 1
            local remainingCycles = math.max(maxCycles - cycle, 0)
            local remainingTime = remainingCycles * timePerCycle

            Notify("Auto Farm", string.format(
                "Ciclo #%d / %d\nTiempo restante: %s",
                cycle, maxCycles, FormatTime(remainingTime)
            ), 3)

            if EquipTool(getgenv().MarshFarm.Water) then
                task.wait(0.35)
                PressE()
                Notify("Auto Farm", "Water → esperando " .. getgenv().MarshFarm.WaitAfterWater .. "s", 3)
                local waterEnd = tick() + getgenv().MarshFarm.WaitAfterWater
                while tick() < waterEnd do
                    if not getgenv().MarshFarm.Enabled or not getgenv().MarshFarm.Running then break end
                    task.wait(0.3)
                end
            end

            if not getgenv().MarshFarm.Enabled or not getgenv().MarshFarm.Running then break end

            if EquipTool(getgenv().MarshFarm.SugarBlock) then
                task.wait(0.35)
                PressE()
                Notify("Auto Farm", "Sugar Block Bag usado", 2)
                task.wait(0.4)
            end

            if not getgenv().MarshFarm.Enabled or not getgenv().MarshFarm.Running then break end

            if EquipTool(getgenv().MarshFarm.Gelatin) then
                task.wait(0.35)
                PressE()
                Notify("Auto Farm", "Gelatin → esperando " .. getgenv().MarshFarm.WaitAfterGelatin .. "s", 3)
                local gelEnd = tick() + getgenv().MarshFarm.WaitAfterGelatin
                while tick() < gelEnd do
                    if not getgenv().MarshFarm.Enabled or not getgenv().MarshFarm.Running then break end
                    task.wait(0.3)
                end
            end

            if not getgenv().MarshFarm.Enabled or not getgenv().MarshFarm.Running then break end

            if FindTool(getgenv().MarshFarm.EmptyBag) then
                if EquipTool(getgenv().MarshFarm.EmptyBag) then
                    task.wait(0.35)
                    PressE()
                    task.wait(0.45)
                end
            end

            PlaySuccessSound()
            Notify("Marshmallow ✓", "Ciclo #" .. cycle .. " completado", 3)
            task.wait(0.8)
        end
    end

    local elapsed = tick() - startTime
    getgenv().MarshFarm.Running = false
    Notify("Auto Farm", "Farm detenido | Ciclos: " .. cycle .. " | Tiempo real: " .. FormatTime(elapsed), 5)
end

local function StartFarm()
    if not getgenv().MarshFarm.Enabled then
        Notify("Auto Farm", "Debes activar 'Auto Farm Enabled' primero", 3)
        return
    end
    if getgenv().MarshFarm.Running then
        Notify("Auto Farm", "Ya está corriendo", 2)
        return
    end
    local ok, missing = HasItems()
    if not ok then
        Notify("Auto Farm", "Faltan items: " .. table.concat(missing, ", "), 4)
        return
    end
    local maxCycles = GetMaxCycles()
    local totalSeconds = maxCycles * GetTimePerCycle()
    Notify("Auto Farm", string.format(
        "Ingredientes detectados → %d ciclos\nTiempo estimado: %s",
        maxCycles, FormatTime(totalSeconds)
    ), 6)
    task.spawn(FarmLoop)
end

local function StopFarm()
    if not getgenv().MarshFarm.Running then
        Notify("Auto Farm", "No está corriendo", 2)
        return
    end
    getgenv().MarshFarm.Running = false
    Notify("Auto Farm", "Deteniendo farm...", 2)
end

local AutoFarmTab = Tabs.Autofarm
local MarshTabBox = AutoFarmTab:AddLeftTabbox()
local ControlsTab = MarshTabBox:AddTab("Controls", "play")
local SettingsTab = MarshTabBox:AddTab("Settings", "settings")

ControlsTab:AddToggle("MarshFarmToggle", {
    Text = "Auto Farm Enabled",
    Default = false,
    Tooltip = "DEBES activar esto para poder usar Start, Stop o el Keybind",
    Callback = function(Value)
        getgenv().MarshFarm.Enabled = Value
        if not Value then
            getgenv().MarshFarm.Running = false
        end
    end
})

ControlsTab:AddDivider()

ControlsTab:AddButton({
    Text = "Start",
    Func = function()
        StartFarm()
    end
})

ControlsTab:AddButton({
    Text = "Stop",
    Func = function()
        StopFarm()
    end
})

ControlsTab:AddDivider()

ControlsTab:AddLabel("Keybind"):AddKeyPicker("MarshFarmKey", {
    Default = "None",
    Mode = "Press",
    Text = "Start / Stop Farm",
    NoUI = false,
    SyncToggleState = false,
    Callback = function()
        if not getgenv().MarshFarm.Enabled then
            Notify("Auto Farm", "Debes activar 'Auto Farm Enabled' primero", 2)
            return
        end
        if getgenv().MarshFarm.Running then
            StopFarm()
        else
            StartFarm()
        end
    end
})

SettingsTab:AddSlider("WaitWater", {
    Text = "Espera después de Water",
    Default = 20,
    Min = 5,
    Max = 60,
    Rounding = 0,
    Suffix = "s",
    Callback = function(Value)
        getgenv().MarshFarm.WaitAfterWater = Value
    end
})

SettingsTab:AddSlider("WaitGelatin", {
    Text = "Espera después de Gelatin",
    Default = 45,
    Min = 10,
    Max = 120,
    Rounding = 0,
    Suffix = "s",
    Callback = function(Value)
        getgenv().MarshFarm.WaitAfterGelatin = Value
    end
})

SettingsTab:AddDivider()

SettingsTab:AddToggle("MarshNotifyToggle", {
    Text = "Enable Notifications",
    Default = true,
    Callback = function(Value)
        getgenv().MarshFarm.NotifyEnabled = Value
    end
})

SettingsTab:AddSlider("NotifyCooldown", {
    Text = "Notify Cooldown",
    Default = 0.8,
    Min = 0.3,
    Max = 5,
    Rounding = 1,
    Suffix = "s",
    Callback = function(Value)
        getgenv().MarshFarm.NotifyCooldown = Value
    end
})

SettingsTab:AddDivider()
SettingsTab:AddLabel("1. Water → E → espera")
SettingsTab:AddLabel("2. Sugar Block Bag → E (instantáneo)")
SettingsTab:AddLabel("3. Gelatin → E → espera")
SettingsTab:AddLabel("4. Empty Bag → E → listo")

print("[AUTOFARM] Marshmallow completo cargado")

-- ==================== ANTI AFK ====================
getgenv().AntiAFK = {
    Enabled = true
}

-- Method 1: When the game detects idle
LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK.Enabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Method 2: Safety loop (more reliable)
task.spawn(function()
    while true do
        task.wait(math.random(45, 75)) -- Every 45-75 seconds
        if getgenv().AntiAFK.Enabled then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                
                -- Small extra mouse movement
                VIM:SendMouseMoveEvent(math.random(-2, 2), math.random(-2, 2), game)
            end)
        end
    end
end)

local AntiAFKBox = MovementTab:AddLeftGroupbox("Anti AFK", "shield")

AntiAFKBox:AddToggle("AntiAFKEnabled", {
    Text = "Anti AFK",
    Default = true,
    Tooltip = "Prevents getting kicked for being AFK",
    Callback = function(v)
        getgenv().AntiAFK.Enabled = v
        Library:Notify(v and "Anti AFK enabled" or "Anti AFK disabled", 2)
    end
})

print("[ANTI AFK] Loaded")

-- ==================== WALK SPEED + EXTRAS (Obsidian Tabbox) ====================
getgenv().WalkSpeed = {
    Enabled = false,
    Speed = 16,

    BoostEnabled = false,
    BoostSpeed = 32,

    AntiSit = false
}

local RunService = game:GetService("RunService")

local WalkConnection = nil
local AntiSitConnection = nil

-- ==================== FUNCTIONS ====================
local function StartWalkSpeed()
    if WalkConnection then
        WalkConnection:Disconnect()
        WalkConnection = nil
    end

    WalkConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude < 0.05 then return end

        local targetSpeed = 16

        if getgenv().WalkSpeed.Enabled then
            targetSpeed = getgenv().WalkSpeed.Speed
        end

        if getgenv().WalkSpeed.BoostEnabled then
            targetSpeed = getgenv().WalkSpeed.BoostSpeed
        end

        local currentVel = root.AssemblyLinearVelocity
        local desiredVel = moveDir * targetSpeed
        local newVel = Vector3.new(currentVel.X, 0, currentVel.Z):Lerp(desiredVel, 0.30)

        root.AssemblyLinearVelocity = Vector3.new(newVel.X, currentVel.Y, newVel.Z)
    end)
end

local function StopWalkSpeed()
    if WalkConnection then
        WalkConnection:Disconnect()
        WalkConnection = nil
    end
end

local function SetupAntiSit(char)
    if AntiSitConnection then
        AntiSitConnection:Disconnect()
        AntiSitConnection = nil
    end

    local hum = char:WaitForChild("Humanoid", 4)
    if not hum then return end

    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    AntiSitConnection = hum.Seated:Connect(function(active)
        if active and getgenv().WalkSpeed.AntiSit then
            hum.Sit = false
            task.defer(function()
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.35)
    if getgenv().WalkSpeed.AntiSit then
        SetupAntiSit(char)
    end
    if getgenv().WalkSpeed.Enabled or getgenv().WalkSpeed.BoostEnabled then
        StartWalkSpeed()
    end
end)

if LocalPlayer.Character and getgenv().WalkSpeed.AntiSit then
    SetupAntiSit(LocalPlayer.Character)
end

-- ==================== UI (Obsidian Tabbox Style) ====================
local SpeedTabBox = MovementTab:AddRightTabbox()

--==================== TAB 1 - SPEED ====================
local SpeedTab = SpeedTabBox:AddTab("Speed", "gauge")

SpeedTab:AddToggle("WalkSpeedEnabled", {
    Text = "Walk Speed",
    Default = false,
    Tooltip = "Applies while walking (stealth velocity)",
    Callback = function(v)
        getgenv().WalkSpeed.Enabled = v
        if v or getgenv().WalkSpeed.BoostEnabled then
            StartWalkSpeed()
        else
            StopWalkSpeed()
        end
    end
})

SpeedTab:AddSlider("WalkSpeedValue", {
    Text = "Walk Speed Value",
    Default = 16,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Tooltip = "Speed when walking",
    Callback = function(v)
        getgenv().WalkSpeed.Speed = v
    end
})

SpeedTab:AddDivider()

SpeedTab:AddToggle("SpeedBoostEnabled", {
    Text = "Speed Boost",
    Default = false,
    Tooltip = "Higher speed when enabled",
    Callback = function(v)
        getgenv().WalkSpeed.BoostEnabled = v
        if v or getgenv().WalkSpeed.Enabled then
            StartWalkSpeed()
        else
            StopWalkSpeed()
        end
    end
})

SpeedTab:AddSlider("SpeedBoostValue", {
    Text = "Boost Speed Value",
    Default = 32,
    Min = 16,
    Max = 55,
    Rounding = 0,
    Tooltip = "Speed when Boost is enabled",
    Callback = function(v)
        getgenv().WalkSpeed.BoostSpeed = v
    end
})

--==================== TAB 2 - EXTRAS ====================
local ExtrasTab = SpeedTabBox:AddTab("Extras", "shield")

ExtrasTab:AddToggle("AntiSitEnabled", {
    Text = "Anti Sit",
    Default = false,
    Tooltip = "Prevents being forced to sit",
    Callback = function(v)
        getgenv().WalkSpeed.AntiSit = v
        if v and LocalPlayer.Character then
            SetupAntiSit(LocalPlayer.Character)
        end
    end
})

print("[WALK SPEED + EXTRAS] Loaded")

-- ==================== SHOW GUN (REAL-TIME + HIGH PERFORMANCE) ====================
getgenv().ShowGun = {
    Enabled = false,
    MaxItems = 8,
    TextSize = 13,
    OffsetY = 2.7,
    MaxDistance = 3000,

    Highlight = {
        -- ["NombreExacto"] = Color3.fromRGB(255, 215, 0),
    },

    Blacklist = {
        "Phone", "Fist",
        "Water", "Sugar Block Bag", "Gelatin", "Extended Clip", "Standard Clip", "Lock Pick", "Ghost Skull Face Half Mask", "Crate",
        "Drum Magazine", "Large Marshmallow Bag", "Small Marshmallow Bag", "Black Gloves", "Shipmentbox", "Black Dripping Sorrow Mask",
        "Empty Bag", "Medium Marshmallow Bag", "Crowbar", "Heavy Magazine", "Potato Chips", "Flour", "Potato", "Bandana", "Speed Loader",
    },

    Keywords = {
        "Drum",
    },

    Rarity = {
        Common     = Color3.fromRGB(255, 255, 255),
        Epic       = Color3.fromRGB(170, 0, 255),
        Destacado  = Color3.fromRGB(255, 50, 50),
        Legendary  = Color3.fromRGB(135, 206, 250),
    },

    ItemRarity = {
      ["PLR-16"] = "Legendary", ["ARP9"] = "Legendary", ["MPX"] = "Legendary", ["Honey Badger Pistol"] = "Legendary", ["DDM4 V7 Pistol"] = "Legendary",
      ["AR Pistol"] = "Legendary", ["Draco"] = "Legendary", ["Tec-9"] = "Legendary", ["MCX"] = "Legendary", ["HK416"] = "Legendary", ["AK104 Pistol"] = "Legendary",
      
    }
}

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Limpia folder viejo si existe (evita duplicados al re-ejecutar)
local old = CoreGui:FindFirstChild("ShowGunESP")
if old then old:Destroy() end

local Folder = Instance.new("Folder")
Folder.Name = "ShowGunESP"
Folder.Parent = CoreGui

local Billboards = {}
local ItemLists = {}
local Connections = {}

-------------------------------------------------
-- Utils
-------------------------------------------------
local function IsBlacklisted(name)
    local lower = string.lower(tostring(name))
    for _, v in ipairs(getgenv().ShowGun.Blacklist) do
        if lower == string.lower(v) then return true end
    end
    return false
end

local function GetColor(items)
    local best = getgenv().ShowGun.Rarity.Common
    local prio = 0

    for _, name in ipairs(items) do
        for hName, color in pairs(getgenv().ShowGun.Highlight) do
            if string.lower(name) == string.lower(hName) then
                return color
            end
        end

        for _, word in ipairs(getgenv().ShowGun.Keywords) do
            if string.find(string.lower(name), string.lower(word)) and prio < 3 then
                best = getgenv().ShowGun.Rarity.Destacado
                prio = 3
            end
        end

        local r = getgenv().ShowGun.ItemRarity[name]
        if r == "Legendary" and prio < 2 then
            best = getgenv().ShowGun.Rarity.Legendary
            prio = 2
        elseif r == "Epic" and prio < 1 then
            best = getgenv().ShowGun.Rarity.Epic
            prio = 1
        elseif r == "Destacado" and prio < 3 then
            best = getgenv().ShowGun.Rarity.Destacado
            prio = 3
        end
    end
    return best
end

local function BuildText(items)
    if #items == 0 then return "" end
    local text = "[ " .. table.concat(items, ", ") .. " ]"
    if #text > 78 then
        text = string.sub(text, 1, 75) .. "... ]"
    end
    return text
end

-------------------------------------------------
-- Destroy (IMPORTANTE)
-------------------------------------------------
local function DestroyPlayer(player)
    if Connections[player] then
        for _, conn in ipairs(Connections[player]) do
            pcall(function() conn:Disconnect() end)
        end
        Connections[player] = nil
    end

    if Billboards[player] then
        pcall(function() Billboards[player]:Destroy() end)
        Billboards[player] = nil
    end

    ItemLists[player] = nil
end

local function DestroyAll()
    for player in pairs(Billboards) do
        DestroyPlayer(player)
    end
    -- por si quedó algo suelto
    for _, child in ipairs(Folder:GetChildren()) do
        child:Destroy()
    end
end

-------------------------------------------------
-- Billboard
-------------------------------------------------
local function CreateBillboard(player)
    if Billboards[player] then
        Billboards[player]:Destroy()
    end

    local bb = Instance.new("BillboardGui")
    bb.Name = "SG_" .. player.Name
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(300, 20)
    bb.StudsOffset = Vector3.new(0, getgenv().ShowGun.OffsetY, 0)
    bb.MaxDistance = getgenv().ShowGun.MaxDistance
    bb.Enabled = false
    bb.Parent = Folder

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = getgenv().ShowGun.TextSize
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.4
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Text = ""
    label.Parent = bb

    Billboards[player] = bb
    return bb
end

local function RefreshLabel(player)
    if not getgenv().ShowGun.Enabled then return end

    local bb = Billboards[player]
    if not bb or not bb.Parent then return end

    local items = ItemLists[player] or {}
    local label = bb:FindFirstChild("Label")
    if not label then return end

    if #items == 0 then
        bb.Enabled = false
        label.Text = ""
        return
    end

    label.Text = BuildText(items)
    label.TextColor3 = GetColor(items)
    label.TextSize = getgenv().ShowGun.TextSize
    bb.StudsOffset = Vector3.new(0, getgenv().ShowGun.OffsetY, 0)
    bb.MaxDistance = getgenv().ShowGun.MaxDistance
    bb.Enabled = true
end

-------------------------------------------------
-- Inventory
-------------------------------------------------
local function RebuildItems(player)
    if not getgenv().ShowGun.Enabled then return end

    local list = {}
    local seen = {}

    local function add(name)
        if not name or IsBlacklisted(name) then return end
        local key = string.lower(name)
        if seen[key] then return end
        seen[key] = true
        table.insert(list, name)
    end

    local char = player.Character
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then add(obj.Name) end
        end
    end

    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, obj in ipairs(bp:GetChildren()) do
            if obj:IsA("Tool") then add(obj.Name) end
        end
    end

    local max = getgenv().ShowGun.MaxItems or 8
    if #list > max then
        local limited = {}
        for i = 1, max do limited[i] = list[i] end
        list = limited
    end

    ItemLists[player] = list

    if not Billboards[player] then
        CreateBillboard(player)
        local head = player.Character and (player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart"))
        if head and Billboards[player] then
            Billboards[player].Adornee = head
        end
    end

    RefreshLabel(player)
end

local function SetupPlayer(player)
    if player == LocalPlayer then return end
    DestroyPlayer(player)

    local conns = {}

    local function onToolChanged()
        if getgenv().ShowGun.Enabled then
            RebuildItems(player)
        end
    end

    local function hookCharacter(char)
        table.insert(conns, char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then onToolChanged() end
        end))
        table.insert(conns, char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then onToolChanged() end
        end))
        onToolChanged()
    end

    if player.Character then
        hookCharacter(player.Character)
    end
    table.insert(conns, player.CharacterAdded:Connect(function(char)
        task.wait(0.25)
        hookCharacter(char)
        local bb = Billboards[player]
        if bb then
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if head then bb.Adornee = head end
        end
        onToolChanged()
    end))

    local function hookBackpack()
        local bp = player:FindFirstChild("Backpack")
        if not bp then return end
        table.insert(conns, bp.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then onToolChanged() end
        end))
        table.insert(conns, bp.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then onToolChanged() end
        end))
    end

    hookBackpack()
    table.insert(conns, player.ChildAdded:Connect(function(child)
        if child.Name == "Backpack" then
            hookBackpack()
            onToolChanged()
        end
    end))

    Connections[player] = conns

    if getgenv().ShowGun.Enabled then
        CreateBillboard(player)
        local head = player.Character and (player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart"))
        if head and Billboards[player] then
            Billboards[player].Adornee = head
        end
        RebuildItems(player)
    end
end

-------------------------------------------------
-- Init
-------------------------------------------------
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(SetupPlayer, player)
end

Players.PlayerAdded:Connect(function(player)
    task.defer(SetupPlayer, player)
end)

Players.PlayerRemoving:Connect(DestroyPlayer)

-------------------------------------------------
-- Enable / Disable (ARREGLADO)
-------------------------------------------------
local function SetEnabled(state)
    getgenv().ShowGun.Enabled = state

    if not state then
        -- Destruir TODO al desactivar
        DestroyAll()
        return
    end

    -- Al activar: recrear para todos
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            SetupPlayer(player)
        end
    end
end

-------------------------------------------------
-- UI
-------------------------------------------------
local ShowGunBox = Tabs.ESP:AddLeftGroupbox("Show Gun", "gun")

ShowGunBox:AddToggle("ShowGunEnabled", {
    Text = "Show Gun / Items",
    Default = false,
    Callback = function(v)
        SetEnabled(v)
    end
})

ShowGunBox:AddSlider("ShowGunMax", {
    Text = "Max Items",
    Default = 8,
    Min = 1,
    Max = 12,
    Rounding = 0,
    Callback = function(v) getgenv().ShowGun.MaxItems = v end
})

ShowGunBox:AddSlider("ShowGunSize", {
    Text = "Text Size",
    Default = 13,
    Min = 10,
    Max = 18,
    Rounding = 0,
    Callback = function(v)
        getgenv().ShowGun.TextSize = v
        for _, bb in pairs(Billboards) do
            local label = bb:FindFirstChild("Label")
            if label then label.TextSize = v end
        end
    end
})

ShowGunBox:AddSlider("ShowGunOffset", {
    Text = "Height Offset",
    Default = 2.7,
    Min = 1.8,
    Max = 4.5,
    Rounding = 1,
    Callback = function(v)
        getgenv().ShowGun.OffsetY = v
        for _, bb in pairs(Billboards) do
            bb.StudsOffset = Vector3.new(0, v, 0)
        end
    end
})

ShowGunBox:AddSlider("ShowGunDistance", {
    Text = "Max Distance",
    Default = 300,
    Min = 80,
    Max = 800,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(v)
        getgenv().ShowGun.MaxDistance = v
        for _, bb in pairs(Billboards) do
            bb.MaxDistance = v
        end
    end
})

-- Limpieza extra cuando se descarga la library
if Library and Library.Unload then
    local oldUnload = Library.Unload
    Library.Unload = function(...)
        getgenv().ShowGun.Enabled = false
        DestroyAll()
        if Folder and Folder.Parent then
            Folder:Destroy()
        end
        return oldUnload(...)
    end
end

print("[VISUALS] Show Gun Real-Time fixed cleanup loaded")
-- ==================== FINAL ====================
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
