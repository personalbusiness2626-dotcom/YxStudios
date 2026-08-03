--[[
    Rectangular Loading Screen - Yx Studio's
    With Blur and Edge Light Effect (Vignette Light)
    FIXED GAMEID VERIFIER - Only authorized for South Bronx
    Game ID: 13643807539
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- CONFIGURATION
local GITHUB_URL = "https://raw.githubusercontent.com/personalbusiness2626-dotcom/YxStudios/refs/heads/main/Auth" -- Change this URL
local LOGO_ID = "135416919651671" -- Logo ID
local AUTHORIZED_PLACE_ID = 13643807539 -- FIXED ID for South Bronx game

-- Variable to control that it only executes once
local hasLoaded = false

-- ============================================
-- FIXED GAMEID VERIFIER
-- ============================================
local function VerifyGameID()
    -- Get the game ID safely
    local currentPlaceId = game.PlaceId or game.GameId
    
    -- Display debug information
    print("🔍 Verifying Game ID...")
    print("📌 PlaceId:", game.PlaceId)
    print("📌 GameId:", game.GameId)
    print("🔑 Authorized:", AUTHORIZED_PLACE_ID)
    print("🆔 Current ID:", currentPlaceId)
    
    -- Check if the ID matches
    if currentPlaceId ~= AUTHORIZED_PLACE_ID then
        -- Create error screen
        local errorGui = Instance.new("ScreenGui")
        errorGui.Name = "ErrorScreen"
        errorGui.ResetOnSpawn = false
        errorGui.Parent = game:GetService("CoreGui")
        
        local errorFrame = Instance.new("Frame")
        errorFrame.Size = UDim2.new(1, 0, 1, 0)
        errorFrame.BackgroundColor3 = Color3.new(0, 0, 0)
        errorFrame.BackgroundTransparency = 0.85
        errorFrame.Parent = errorGui
        
        local errorBox = Instance.new("Frame")
        errorBox.Size = UDim2.new(0, 550, 0, 320)
        errorBox.Position = UDim2.new(0.5, -275, 0.5, -160)
        errorBox.BackgroundColor3 = Color3.new(0.12, 0.02, 0.02)
        errorBox.BorderSizePixel = 3
        errorBox.BorderColor3 = Color3.new(1, 0, 0)
        errorBox.BackgroundTransparency = 0.1
        errorBox.ClipsDescendants = true
        errorBox.Parent = errorFrame
        
        -- Rounded corners
        local cornerPositions = {
            {UDim2.new(0, 0, 0, 0), UDim2.new(0, 15, 0, 15)},
            {UDim2.new(1, -15, 0, 0), UDim2.new(0, 15, 0, 15)},
            {UDim2.new(0, 0, 1, -15), UDim2.new(0, 15, 0, 15)},
            {UDim2.new(1, -15, 1, -15), UDim2.new(0, 15, 0, 15)}
        }
        
        for i, pos in ipairs(cornerPositions) do
            local corner = Instance.new("Frame")
            corner.Size = pos[2]
            corner.Position = pos[1]
            corner.BackgroundColor3 = Color3.new(0.9, 0, 0)
            corner.BackgroundTransparency = 0.3
            corner.BorderSizePixel = 0
            corner.Parent = errorBox
        end
        
        -- Error icon
        local errorIcon = Instance.new("TextLabel")
        errorIcon.Size = UDim2.new(0, 80, 0, 80)
        errorIcon.Position = UDim2.new(0.5, -40, 0, 15)
        errorIcon.BackgroundTransparency = 1
        errorIcon.Text = "⛔"
        errorIcon.TextColor3 = Color3.new(1, 0, 0)
        errorIcon.TextSize = 70
        errorIcon.Font = Enum.Font.Gotham
        errorIcon.Parent = errorBox
        
        -- Error title
        local errorTitle = Instance.new("TextLabel")
        errorTitle.Size = UDim2.new(1, 0, 0, 40)
        errorTitle.Position = UDim2.new(0, 0, 0, 105)
        errorTitle.BackgroundTransparency = 1
        errorTitle.Text = "🚫 UNAUTHORIZED ACCESS"
        errorTitle.TextColor3 = Color3.new(1, 0, 0)
        errorTitle.TextSize = 24
        errorTitle.Font = Enum.Font.GothamBold
        errorTitle.TextScaled = true
        errorTitle.Parent = errorBox
        
        -- Error message
        local errorMsg = Instance.new("TextLabel")
        errorMsg.Size = UDim2.new(1, 0, 0, 50)
        errorMsg.Position = UDim2.new(0, 0, 0, 145)
        errorMsg.BackgroundTransparency = 1
        errorMsg.Text = "This script is only authorized for:\nSouth Bronx - The Trenches"
        errorMsg.TextColor3 = Color3.new(1, 0.7, 0.7)
        errorMsg.TextSize = 16
        errorMsg.Font = Enum.Font.Gotham
        errorMsg.TextScaled = true
        errorMsg.TextWrapped = true
        errorMsg.Parent = errorBox
        
        -- Current game information
        local currentGameLabel = Instance.new("TextLabel")
        currentGameLabel.Size = UDim2.new(1, 0, 0, 30)
        currentGameLabel.Position = UDim2.new(0, 0, 0, 200)
        currentGameLabel.BackgroundTransparency = 1
        currentGameLabel.Text = "Current ID: " .. tostring(currentPlaceId) .. " | Authorized: " .. tostring(AUTHORIZED_PLACE_ID)
        currentGameLabel.TextColor3 = Color3.new(0.8, 0.4, 0.4)
        currentGameLabel.TextSize = 14
        currentGameLabel.Font = Enum.Font.Gotham
        currentGameLabel.TextScaled = true
        currentGameLabel.Parent = errorBox
        
        -- Decorative line
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 300, 0, 2)
        line.Position = UDim2.new(0.5, -150, 0, 240)
        line.BackgroundColor3 = Color3.new(1, 0, 0)
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Parent = errorBox
        
        -- Countdown
        local countdownLabel = Instance.new("TextLabel")
        countdownLabel.Size = UDim2.new(0, 60, 0, 40)
        countdownLabel.Position = UDim2.new(0.5, -30, 1, -50)
        countdownLabel.BackgroundTransparency = 1
        countdownLabel.Text = "3"
        countdownLabel.TextColor3 = Color3.new(1, 0.2, 0.2)
        countdownLabel.TextSize = 32
        countdownLabel.Font = Enum.Font.GothamBold
        countdownLabel.Parent = errorBox
        
        -- Entrance animation
        errorBox.BackgroundTransparency = 1
        errorBox.Size = UDim2.new(0, 0, 0, 0)
        local errorTween = TweenService:Create(errorBox,
            TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, 550, 0, 320)
            }
        )
        errorTween:Play()
        
        -- Countdown function
        local function Countdown()
            for i = 3, 1, -1 do
                countdownLabel.Text = tostring(i)
                local pulseTween = TweenService:Create(countdownLabel,
                    TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    {Size = UDim2.new(0, 80, 0, 50)}
                )
                pulseTween:Play()
                task.wait(0.7)
                countdownLabel.Size = UDim2.new(0, 60, 0, 40)
                task.wait(0.3)
            end
        end
        
        coroutine.wrap(Countdown)()
        
        task.wait(3.5)
        
        local player = Players.LocalPlayer
        if player then
            player:Kick("⛔ Unauthorized access. This script only works in South Bronx - The Trenches.")
        end
        
        return false
    end
    
    print("✅ ID verified successfully. Welcome to South Bronx!")
    return true
end

-- ============================================
-- CREATE BLUR WITH EDGE LIGHT EFFECT
-- ============================================
local function CreateVignetteBlur()
    local blurGui = Instance.new("ScreenGui")
    blurGui.Name = "BlurGui"
    blurGui.ResetOnSpawn = false
    blurGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    blurGui.Parent = game:GetService("CoreGui")
    
    -- Frame that will contain the light effect
    local lightFrame = Instance.new("Frame")
    lightFrame.Name = "LightFrame"
    lightFrame.Size = UDim2.new(1, 0, 1, 0)
    lightFrame.BackgroundTransparency = 1
    lightFrame.Parent = blurGui
    
    -- Edge light effect (vignette)
    local vignette = Instance.new("ImageLabel")
    vignette.Name = "Vignette"
    vignette.Size = UDim2.new(1, 0, 1, 0)
    vignette.BackgroundTransparency = 1
    vignette.Image = "rbxassetid://2384054348"
    vignette.ImageColor3 = Color3.new(0.3, 0.1, 0.1)
    vignette.ImageTransparency = 0.4
    vignette.ScaleType = Enum.ScaleType.Fit
    vignette.Parent = lightFrame
    
    -- Soft red light layer in the center
    local centerLight = Instance.new("Frame")
    centerLight.Name = "CenterLight"
    centerLight.Size = UDim2.new(0.6, 0, 0.6, 0)
    centerLight.Position = UDim2.new(0.2, 0, 0.2, 0)
    centerLight.BackgroundColor3 = Color3.new(0.4, 0.05, 0.05)
    centerLight.BackgroundTransparency = 0.7
    centerLight.BorderSizePixel = 0
    centerLight.Parent = lightFrame
    
    -- Radial gradient for central light
    local centerGradient = Instance.new("UIGradient")
    centerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0.5, 0.5, 0.5)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
    })
    centerGradient.Rotation = 0
    centerGradient.Parent = centerLight
    
    -- REAL Roblox Blur (value 30)
    local blur = Instance.new("BlurEffect")
    blur.Name = "ScreenBlur"
    blur.Size = 30
    blur.Parent = Lighting
    
    -- Soft darkening
    local darkOverlay = Instance.new("Frame")
    darkOverlay.Name = "DarkOverlay"
    darkOverlay.Size = UDim2.new(1, 0, 1, 0)
    darkOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    darkOverlay.BackgroundTransparency = 0.15
    darkOverlay.BorderSizePixel = 0
    darkOverlay.Parent = lightFrame
    
    -- Gradient to darken edges
    local darkGradient = Instance.new("UIGradient")
    darkGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 0, 0)),
        ColorSequenceKeypoint.new(0.7, Color3.new(0.5, 0.5, 0.5)),
        ColorSequenceKeypoint.new(0.85, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    })
    darkGradient.Parent = darkOverlay
    
    -- Edge glow layer
    local lightLeak = Instance.new("ImageLabel")
    lightLeak.Name = "LightLeak"
    lightLeak.Size = UDim2.new(1, 0, 1, 0)
    lightLeak.BackgroundTransparency = 1
    lightLeak.Image = "rbxassetid://162114293"
    lightLeak.ImageColor3 = Color3.new(0.8, 0.2, 0.1)
    lightLeak.ImageTransparency = 0.6
    lightLeak.ScaleType = Enum.ScaleType.Fit
    lightLeak.Parent = lightFrame
    
    -- Light animation
    coroutine.wrap(function()
        local startTime = tick()
        while blurGui.Parent do
            local elapsed = tick() - startTime
            local offsetX = math.sin(elapsed * 0.3) * 0.05
            local offsetY = math.cos(elapsed * 0.4) * 0.05
            lightLeak.Position = UDim2.new(0.5 + offsetX, 0, 0.5 + offsetY, 0)
            lightLeak.Rotation = math.sin(elapsed * 0.1) * 5
            task.wait(0.03)
        end
    end)()
    
    return blurGui, blur, lightFrame, darkOverlay, vignette, centerLight, lightLeak
end

-- ============================================
-- CREATE LOADING INTERFACE
-- ============================================
local function CreateLoadingScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Main rectangular loading frame
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Name = "LoadingFrame"
    loadingFrame.Size = UDim2.new(0, 450, 0, 350)
    loadingFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    loadingFrame.BackgroundColor3 = Color3.new(0.12, 0.04, 0.04)
    loadingFrame.BackgroundTransparency = 1
    loadingFrame.BorderSizePixel = 0
    loadingFrame.BorderColor3 = Color3.new(1, 0, 0)
    loadingFrame.ClipsDescendants = true
    loadingFrame.Parent = screenGui
    
    -- Frame shadow
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundColor3 = Color3.new(1, 0, 0)
    shadow.BackgroundTransparency = 0.85
    shadow.ZIndex = -1
    shadow.BorderSizePixel = 0
    shadow.Parent = loadingFrame
    
    -- Rounded corners
    local corners = {}
    local cornerPositions = {
        {UDim2.new(0, 0, 0, 0), UDim2.new(0, 15, 0, 15)},
        {UDim2.new(1, -15, 0, 0), UDim2.new(0, 15, 0, 15)},
        {UDim2.new(0, 0, 1, -15), UDim2.new(0, 15, 0, 15)},
        {UDim2.new(1, -15, 1, -15), UDim2.new(0, 15, 0, 15)}
    }
    
    for i, pos in ipairs(cornerPositions) do
        local corner = Instance.new("Frame")
        corner.Name = "Corner" .. i
        corner.Size = pos[2]
        corner.Position = pos[1]
        corner.BackgroundColor3 = Color3.new(0.9, 0, 0)
        corner.BackgroundTransparency = 0.4
        corner.BorderSizePixel = 0
        corner.Parent = loadingFrame
    end
    
    -- LOGO
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 100, 0, 100)
    logo.Position = UDim2.new(0.5, -50, 0, 20)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://" .. LOGO_ID
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = loadingFrame
    
    -- Logo glow
    local logoGlow = Instance.new("Frame")
    logoGlow.Name = "LogoGlow"
    logoGlow.Size = UDim2.new(0, 120, 0, 120)
    logoGlow.Position = UDim2.new(0.5, -60, 0, 10)
    logoGlow.BackgroundColor3 = Color3.new(1, 0, 0)
    logoGlow.BackgroundTransparency = 0.9
    logoGlow.BorderSizePixel = 2
    logoGlow.BorderColor3 = Color3.new(1, 0, 0)
    logoGlow.ZIndex = -1
    logoGlow.Parent = loadingFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 125)
    title.BackgroundTransparency = 1
    title.Text = "Yx Studio's"
    title.TextColor3 = Color3.new(1, 0, 0)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = loadingFrame
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 175)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Starting..."
    subtitle.TextColor3 = Color3.new(1, 0.3, 0.3)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextScaled = true
    subtitle.Parent = loadingFrame
    
    -- Decorative line
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(0, 0, 0, 2)
    line.Position = UDim2.new(0.5, -150, 0, 210)
    line.BackgroundColor3 = Color3.new(1, 0, 0)
    line.BorderSizePixel = 0
    line.Parent = loadingFrame
    
    -- Progress bar
    local progressBackground = Instance.new("Frame")
    progressBackground.Name = "ProgressBackground"
    progressBackground.Size = UDim2.new(0, 0, 0, 22)
    progressBackground.Position = UDim2.new(0.5, -160, 0, 225)
    progressBackground.BackgroundColor3 = Color3.new(0.3, 0.05, 0.05)
    progressBackground.BorderSizePixel = 2
    progressBackground.BorderColor3 = Color3.new(1, 0, 0)
    progressBackground.Parent = loadingFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.new(1, 0, 0)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBackground
    
    -- Glow effect on bar
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(0, 0, 1, 0)
    glow.Position = UDim2.new(0, 0, 0, 0)
    glow.BackgroundColor3 = Color3.new(1, 0.3, 0.3)
    glow.BackgroundTransparency = 0.5
    glow.BorderSizePixel = 0
    glow.Parent = progressBar
    
    -- Loading percentage
    local percentLabel = Instance.new("TextLabel")
    percentLabel.Name = "PercentLabel"
    percentLabel.Size = UDim2.new(0, 70, 0, 30)
    percentLabel.Position = UDim2.new(0.5, -35, 0, 260)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.new(1, 0, 0)
    percentLabel.TextSize = 20
    percentLabel.Font = Enum.Font.GothamBold
    percentLabel.Parent = loadingFrame
    
    -- Status
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 25)
    statusText.Position = UDim2.new(0, 0, 0, 295)
    statusText.BackgroundTransparency = 1
    statusText.Text = ""
    statusText.TextColor3 = Color3.new(0.8, 0.3, 0.3)
    statusText.TextSize = 13
    statusText.Font = Enum.Font.Gotham
    statusText.TextScaled = true
    statusText.Parent = loadingFrame
    
    -- ENTRANCE ANIMATION
    local function PlayEntranceAnimation(blurGui, blur, lightFrame, darkOverlay)
        lightFrame.BackgroundTransparency = 1
        local lightTween = TweenService:Create(lightFrame,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0}
        )
        lightTween:Play()
        
        if darkOverlay then
            darkOverlay.BackgroundTransparency = 1
            local darkTween = TweenService:Create(darkOverlay,
                TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = 0.15}
            )
            darkTween:Play()
        end
        
        loadingFrame.BackgroundTransparency = 1
        loadingFrame.Size = UDim2.new(0, 300, 0, 200)
        loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
        
        local frameTween = TweenService:Create(loadingFrame,
            TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, 450, 0, 350),
                Position = UDim2.new(0.5, -225, 0.5, -175)
            }
        )
        frameTween:Play()
        
        task.wait(0.3)
        local borderTween = TweenService:Create(loadingFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BorderSizePixel = 3}
        )
        borderTween:Play()
        
        logo.Size = UDim2.new(0, 0, 0, 0)
        local logoAnim = TweenService:Create(logo,
            TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 100, 0, 100)}
        )
        logoAnim:Play()
        
        title.Position = UDim2.new(0, 0, 0, 180)
        title.TextTransparency = 1
        local titleTween = TweenService:Create(title,
            TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(0, 0, 0, 125),
                TextTransparency = 0
            }
        )
        titleTween:Play()
        
        local lineTween = TweenService:Create(line,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 300, 0, 2)}
        )
        lineTween:Play()
        
        local progressTween = TweenService:Create(progressBackground,
            TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 320, 0, 22)}
        )
        progressTween:Play()
        
        subtitle.TextTransparency = 1
        local subTween = TweenService:Create(subtitle,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {TextTransparency = 0}
        )
        subTween:Play()
        
        percentLabel.TextTransparency = 1
        local percentTween = TweenService:Create(percentLabel,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {TextTransparency = 0}
        )
        percentTween:Play()
        
        for _, corner in ipairs(loadingFrame:GetChildren()) do
            if corner.Name:match("Corner") then
                local cornerTween = TweenService:Create(corner,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.3}
                )
                cornerTween:Play()
            end
        end
    end
    
    -- EXIT ANIMATION
    local function PlayExitAnimation(blurGui, blur, lightFrame, darkOverlay)
        local lightTween = TweenService:Create(lightFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {BackgroundTransparency = 1}
        )
        lightTween:Play()
        
        if darkOverlay then
            local darkTween = TweenService:Create(darkOverlay,
                TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {BackgroundTransparency = 1}
            )
            darkTween:Play()
        end
        
        local animations = {}
        
        table.insert(animations, TweenService:Create(loadingFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }
        ))
        
        table.insert(animations, TweenService:Create(logo,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0)}
        ))
        
        table.insert(animations, TweenService:Create(title,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                TextTransparency = 1,
                Position = UDim2.new(0, 0, 0, 100)
            }
        ))
        
        table.insert(animations, TweenService:Create(subtitle,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {TextTransparency = 1}
        ))
        
        table.insert(animations, TweenService:Create(progressBackground,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0)}
        ))
        
        table.insert(animations, TweenService:Create(percentLabel,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {TextTransparency = 1}
        ))
        
        for _, tween in ipairs(animations) do
            tween:Play()
        end
        
        task.wait(0.6)
        
        screenGui:Destroy()
        if blurGui then blurGui:Destroy() end
        if blur then blur:Destroy() end
    end
    
    return screenGui, loadingFrame, progressBar, percentLabel, subtitle, statusText, glow, PlayEntranceAnimation, PlayExitAnimation, logo, logoGlow
end

-- ============================================
-- SIMULATE LOADING
-- ============================================
local function SimulateLoading()
    if hasLoaded then return end
    hasLoaded = true
    
    -- Create blur with edge light effect
    local blurGui, blur, lightFrame, darkOverlay, vignette, centerLight, lightLeak = CreateVignetteBlur()
    
    -- Create loading screen
    local screenGui, loadingFrame, progressBar, percentLabel, subtitle, statusText, glow, PlayEntranceAnimation, PlayExitAnimation, logo, logoGlow = CreateLoadingScreen()
    
    -- Play entrance animation
    PlayEntranceAnimation(blurGui, blur, lightFrame, darkOverlay)
    task.wait(1)
    
    local totalSteps = 100
    local currentStep = 0
    
    -- Loading tasks
    local loadTasks = {
        {name = "Loading routes...", weight = 20},
        {name = "Loading key.json...", weight = 20},
        {name = "Loading config.json...", weight = 15},
        {name = "Loading scripts...", weight = 15},
        {name = "Loading sounds...", weight = 10},
        {name = "Setting up environment...", weight = 10},
        {name = "Finishing preparations...", weight = 10}
    }
    
    local currentTask = 1
    local taskProgress = 0
    
    -- LOGO ANIMATION
    local function AnimateLogo()
        while screenGui.Parent do
            for i = 1, 30 do
                if not screenGui.Parent then break end
                local alpha = 0.9 - (i / 30 * 0.7)
                logoGlow.BackgroundTransparency = alpha
                logoGlow.Rotation = logoGlow.Rotation + 0.5
                task.wait(0.02)
            end
            for i = 1, 30 do
                if not screenGui.Parent then break end
                local alpha = 0.2 + (i / 30 * 0.7)
                logoGlow.BackgroundTransparency = alpha
                logoGlow.Rotation = logoGlow.Rotation + 0.5
                task.wait(0.02)
            end
        end
    end
    
    coroutine.wrap(AnimateLogo)()
    
    -- Particles
    local function CreateParticle()
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, 4, 0, 4)
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = Color3.new(1, math.random() * 0.5, math.random() * 0.5)
        particle.BackgroundTransparency = 0.3
        particle.BorderSizePixel = 0
        particle.Parent = loadingFrame
        
        local xPos = particle.Position.X.Scale
        local yPos = particle.Position.Y.Scale
        
        local moveTween = TweenService:Create(particle,
            TweenInfo.new(2 + math.random() * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(xPos + (math.random() - 0.5) * 0.4, 0, yPos + (math.random() - 0.5) * 0.4, 0),
                BackgroundTransparency = 1
            }
        )
        moveTween:Play()
        moveTween.Completed:Connect(function()
            particle:Destroy()
        end)
    end
    
    local particleCount = 0
    local function SpawnParticles()
        while currentStep < totalSteps and screenGui.Parent do
            CreateParticle()
            particleCount = particleCount + 1
            if particleCount > 30 then break end
            task.wait(0.1)
        end
    end
    coroutine.wrap(SpawnParticles)()
    
    -- Main loading loop
    while currentStep < totalSteps do
        if currentTask <= #loadTasks then
            local task = loadTasks[currentTask]
            subtitle.Text = task.name
            statusText.Text = "Loading " .. string.lower(task.name) .. " " .. string.rep(".", (currentStep % 3) + 1)
            taskProgress = taskProgress + 1
            
            if taskProgress >= task.weight then
                taskProgress = 0
                currentTask = currentTask + 1
            end
        end
        
        currentStep = currentStep + 1
        local progress = currentStep / totalSteps
        
        local targetSize = UDim2.new(progress, 0, 1, 0)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local tween = TweenService:Create(progressBar, tweenInfo, {Size = targetSize})
        tween:Play()
        
        percentLabel.Text = string.format("%d%%", math.floor(progress * 100))
        
        local glowWidth = 20 + (progress * 100)
        local glowPos = (progress * 100) - 10
        glow.Size = UDim2.new(0, glowWidth, 1, 0)
        glow.Position = UDim2.new(0, glowPos, 0, 0)
        
        local r = 0.5 + (progress * 0.5)
        progressBar.BackgroundColor3 = Color3.new(r, 0, 0)
        
        local title = loadingFrame:FindFirstChild("Title")
        if title then
            local alpha = 0.8 + (math.sin(tick() * 3) * 0.2)
            title.TextColor3 = Color3.new(1, 0.2 * alpha, 0.2 * alpha)
        end
        
        task.wait(0.03)
    end
    
    -- Finish loading
    subtitle.Text = "Ready!"
    statusText.Text = "Opening destination..."
    percentLabel.Text = "100%"
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    
    for i = 1, 5 do
        progressBar.BackgroundColor3 = Color3.new(1, 0, 0)
        glow.BackgroundColor3 = Color3.new(1, 0.5, 0.5)
        task.wait(0.1)
        progressBar.BackgroundColor3 = Color3.new(0.5, 0, 0)
        glow.BackgroundColor3 = Color3.new(0.5, 0.1, 0.1)
        task.wait(0.1)
    end
    
    task.wait(0.5)
    
    -- Show redirect message
    local redirectFrame = Instance.new("Frame")
    redirectFrame.Size = UDim2.new(0, 450, 0, 130)
    redirectFrame.Position = UDim2.new(0.5, -225, 0.5, -65)
    redirectFrame.BackgroundColor3 = Color3.new(0.15, 0.05, 0.05)
    redirectFrame.BorderSizePixel = 3
    redirectFrame.BorderColor3 = Color3.new(1, 0, 0)
    redirectFrame.BackgroundTransparency = 0.3
    redirectFrame.Parent = screenGui
    
    redirectFrame.Size = UDim2.new(0, 0, 0, 0)
    local redirectTween = TweenService:Create(redirectFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 450, 0, 130)}
    )
    redirectTween:Play()
    
    local checkIcon = Instance.new("TextLabel")
    checkIcon.Size = UDim2.new(0, 50, 0, 50)
    checkIcon.Position = UDim2.new(0.5, -25, 0, 10)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Text = "✅"
    checkIcon.TextColor3 = Color3.new(1, 0, 0)
    checkIcon.TextSize = 40
    checkIcon.Font = Enum.Font.Gotham
    checkIcon.Parent = redirectFrame
    
    local redirectText = Instance.new("TextLabel")
    redirectText.Size = UDim2.new(1, 0, 0, 40)
    redirectText.Position = UDim2.new(0, 0, 0, 65)
    redirectText.BackgroundTransparency = 1
    redirectText.Text = "🚀 Loading complete!\nOpening: " .. GITHUB_URL
    redirectText.TextColor3 = Color3.new(1, 0.8, 0.8)
    redirectText.TextSize = 14
    redirectText.Font = Enum.Font.Gotham
    redirectText.TextScaled = true
    redirectText.TextWrapped = true
    redirectText.Parent = redirectFrame
    
    -- Open URL
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow(GITHUB_URL)
    end)
    
    task.wait(2)
    
    -- EXIT ANIMATION
    PlayExitAnimation(blurGui, blur, lightFrame, darkOverlay)
end

-- ============================================
-- SCRIPT START - GAMEID VERIFICATION
-- ============================================

-- Verify GameID before executing anything
local isValid = VerifyGameID()

if isValid then
    -- Start loading ONLY ONCE if GameID is valid
    game:GetService("Players").PlayerAdded:Connect(function(player)
        if not hasLoaded then
            task.wait(0.5)
            coroutine.wrap(SimulateLoading)()
        end
    end)

    if #game:GetService("Players"):GetPlayers() > 0 and not hasLoaded then
        task.wait(0.5)
        coroutine.wrap(SimulateLoading)()
    end
end
