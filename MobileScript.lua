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
    Title = "mspaint",
    Footer = "version: mobile (no aimlock)",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    ["Combat"] = Window:AddTab("Combat", "sword"),
    ["Movement"] = Window:AddTab("Movement", "footprints"),
    ESP = Window:AddTab("Player", "eye"),
    Autofarm = Window:AddTab("Auto Farm", "package"),
    ["UI Settings"] = Window:AddTab("Settings", "settings"),
}

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
