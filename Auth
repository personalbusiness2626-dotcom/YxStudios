--[[
    YX Studio's - Authentication System
    Version: 2.4 (MobileKey Support)
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- ==================== GLOBAL STATE ====================
getgenv().YX_Authorized = getgenv().YX_Authorized or false
getgenv().YX_Key = getgenv().YX_Key or ""
getgenv().YX_UserID = getgenv().YX_UserID or Player.UserId
getgenv().YX_Level = getgenv().YX_Level or "None"
getgenv().YX_TempExpiry = getgenv().YX_TempExpiry or nil

-- ==================== CONFIG ====================
local CONFIG = {
    DiscordWebhook = "https://discord.com/api/webhooks/1453113715200102531/TRzVhwOYlF921oHphBfNIKP0LCwxcwLBfRCD0D1L00fg07Sofj6eSv-4jgt-xSdWHj6O",
    OwnerUserId = "3665809170",
    DiscordInvite = "F3SDzkZa6U",

    -- Nuevas rutas
    TempKeysURL     = "https://raw.githubusercontent.com/personalbusiness2626-dotcom/YxStudios/refs/heads/main/TemporaryKey.json",
    PremiumKeysURL  = "https://raw.githubusercontent.com/personalbusiness2626-dotcom/YxStudios/refs/heads/main/PremiumKeys.json",
    MobileKeysURL   = "https://raw.githubusercontent.com/personalbusiness2626-dotcom/YxStudios/refs/heads/main/MobileKey.json",
    PremiumURL      = "https://raw.githubusercontent.com/personalbusiness2626-dotcom/YxStudios/refs/heads/main/Premium.lua",
    FreemiumURL     = "https://raw.githubusercontent.com/personalbusiness2626-dotcom/YxStudios/refs/heads/main/Freemium.lua",

    PublicKeyRaw = "YX-FREEMIUM.Fix",
    PublicKeyStart = "02/08/2026 00:00",
    PublicKeyEnd = "10/08/2026 23:59",
    PublicKeyEnabled = true,

    AuthFile = "YX_Auth.key",
    TempAuthFile = "YX_TempAuth.key",
    MobileAuthFile = "YX_MobileAuth.key",
    Debug = false,
}

CONFIG.PublicKeyClean = CONFIG.PublicKeyRaw:gsub("[%s%-%.]", ""):upper()

-- ==================== STATE ====================
local PremiumKeys = {}
local TemporaryKeys = {}
local MobileKeys = {}
local BannedUserIDs = {}
local USERID = tostring(Player.UserId)

-- ==================== UTILITIES ====================
local function debugPrint(...)
    if CONFIG.Debug then print("[YX]", ...) end
end

local function getExecutorName()
    if identifyexecutor then
        local name = identifyexecutor()
        return name or "Unknown"
    elseif getexecutorname then
        return getexecutorname()
    elseif syn then return "Synapse X"
    elseif KRNL_LOADED then return "Krnl"
    elseif fluxus then return "Fluxus"
    elseif gethwid then return "Solara / Codex"
    end
    return "Unknown"
end

local function formatTimeRemaining(seconds)
    if not seconds or seconds <= 0 then return "Expired" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if d > 0 then
        return string.format("%dd %02d:%02d:%02d", d, h, m, s)
    end
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function parseDate(str)
    local d, m, y, h, min = str:match("(%d%d)/(%d%d)/(%d%d%d%d) (%d%d):(%d%d)")
    if not d then return os.time() end
    return os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = tonumber(h), min = tonumber(min), sec = 0})
end

local START_TIME = parseDate(CONFIG.PublicKeyStart)
local END_TIME = parseDate(CONFIG.PublicKeyEnd)

local function isPublicValid()
    if not CONFIG.PublicKeyEnabled then return false end
    local now = os.time()
    return now >= START_TIME and now < END_TIME
end

local function getExpireTimeString()
    if not CONFIG.PublicKeyEnabled then
        return "<font color='rgb(255, 80, 80)'>Disabled</font>"
    end
    local now = os.time()
    local color = isPublicValid() and "rgb(0, 255, 150)" or "rgb(255, 80, 80)"
    local diff = now < START_TIME and (START_TIME - now) or (now >= END_TIME and 0 or (END_TIME - now))
    local d = math.floor(diff / 86400)
    local h = math.floor((diff % 86400) / 3600)
    local m = math.floor((diff % 3600) / 60)
    local s = diff % 60
    return string.format("<font color='%s'>%dd %02dh %02dm %02ds</font>", color, d, h, m, s)
end

-- ==================== HTTP ====================
local function httpRequest(options)
    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if not req then return false end
    local success = pcall(req, options)
    return success
end

-- ==================== COMPACT WEBHOOK ====================
local function sendLog(title, color, level, key, extra)
    local fields = {
        {
            name = "User",
            value = string.format("%s (`%s`)\n`%s`", Player.DisplayName, Player.Name, USERID),
            inline = true
        },
        {
            name = "Level",
            value = level or "None",
            inline = true
        },
        {
            name = "Executor",
            value = getExecutorName(),
            inline = true
        }
    }

    if key and key ~= "N/A" and key ~= "Public" and key ~= "Owner" then
        table.insert(fields, {
            name = "Key",
            value = "`" .. key .. "`",
            inline = false
        })
    end

    if extra then
        for _, f in ipairs(extra) do
            table.insert(fields, f)
        end
    end

    local embed = {
        title = title,
        color = color,
        fields = fields,
        footer = { text = "YX Studio's • " .. os.date("%d/%m/%Y %H:%M:%S") },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    task.spawn(function()
        httpRequest({
            Url = CONFIG.DiscordWebhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ embeds = { embed } })
        })
    end)
end

-- ==================== KEY LOADING ====================
local function loadPremiumKeys()
    local success, response = pcall(game.HttpGet, game, CONFIG.PremiumKeysURL)
    if success and response then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
        if ok and type(data) == "table" then
            PremiumKeys = data
            return true
        end
    end
    return false
end

local function loadTemporaryKeys()
    local success, response = pcall(game.HttpGet, game, CONFIG.TempKeysURL)
    if success and response then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
        if ok and type(data) == "table" then
            TemporaryKeys = data
            return true
        end
    end
    return false
end

local function loadMobileKeys()
    local success, response = pcall(game.HttpGet, game, CONFIG.MobileKeysURL)
    if success and response then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
        if ok and type(data) == "table" then
            MobileKeys = data
            return true
        end
    end
    return false
end

local function loadAllKeys()
    loadPremiumKeys()
    loadTemporaryKeys()
    loadMobileKeys()
end

-- ==================== KEY VERIFICATION ====================
local function verifyPremiumKey(key, userId)
    local data = PremiumKeys[key]
    if not data or type(data) ~= "table" then return false end
    return tostring(data.UserID) == tostring(userId)
end

local function verifyMobileKey(key, userId)
    local data = MobileKeys[key]
    if not data or type(data) ~= "table" then return false end
    return tostring(data.UserID) == tostring(userId)
end

local function isUserIDInTempKeys(userId)
    local uid = tostring(userId)
    for key, data in pairs(TemporaryKeys) do
        if data.UserID and tostring(data.UserID) == uid then
            if data.ExpiresAt and os.time() < data.ExpiresAt then
                return true, key
            end
        end
    end
    return false, nil
end

-- ==================== LOCAL AUTH ====================
local function saveAuth(key)
    if writefile then
        writefile(CONFIG.AuthFile, key .. "|" .. USERID)
    end
end

local function deleteAuth()
    if delfile and isfile(CONFIG.AuthFile) then
        delfile(CONFIG.AuthFile)
    end
end

local function loadAuth()
    if not (isfile and isfile(CONFIG.AuthFile) and readfile) then return nil end
    local data = readfile(CONFIG.AuthFile)
    local key, linked = data:match("^(.-)|(.+)$")
    if not key or linked ~= USERID then return nil end

    loadPremiumKeys()
    if verifyPremiumKey(key, USERID) then
        return key
    end
    deleteAuth()
    return nil
end

local function saveTempAuth(key, expiry)
    if writefile then
        writefile(CONFIG.TempAuthFile, HttpService:JSONEncode({
            key = key,
            userid = USERID,
            expiry = expiry
        }))
    end
end

local function loadTempAuth()
    if not (isfile and isfile(CONFIG.TempAuthFile) and readfile) then return nil end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG.TempAuthFile))
    end)
    if not ok or not data or data.userid ~= USERID then return nil end
    if data.expiry and os.time() < data.expiry then
        return data.key, data.expiry
    end
    if delfile then delfile(CONFIG.TempAuthFile) end
    return nil
end

local function saveMobileAuth(key)
    if writefile then
        writefile(CONFIG.MobileAuthFile, key .. "|" .. USERID)
    end
end

local function loadMobileAuth()
    if not (isfile and isfile(CONFIG.MobileAuthFile) and readfile) then return nil end
    local data = readfile(CONFIG.MobileAuthFile)
    local key, linked = data:match("^(.-)|(.+)$")
    if not key or linked ~= USERID then return nil end

    loadMobileKeys()
    if verifyMobileKey(key, USERID) then
        return key
    end
    if delfile then delfile(CONFIG.MobileAuthFile) end
    return nil
end

-- ==================== TEMPORARY KEY ====================
local function activateTemporaryKey(key)
    local data = TemporaryKeys[key]
    if not data then return false, "Key not found" end

    if data.ActivatedAt then
        if data.ExpiresAt and os.time() > data.ExpiresAt then
            return false, "Key expired"
        end
    else
        data.ActivatedAt = os.time()
        data.ExpiresAt = os.time() + (data.Duration or 86400)
    end

    saveTempAuth(key, data.ExpiresAt)
    return true, data.ExpiresAt
end

local function checkTemporaryAccess()
    if getgenv().YX_Level ~= "Temporal" or not getgenv().YX_TempExpiry then
        return false, "No temporal"
    end

    if os.time() >= getgenv().YX_TempExpiry then
        getgenv().YX_Level = "None"
        getgenv().YX_TempExpiry = nil
        if delfile and isfile(CONFIG.TempAuthFile) then delfile(CONFIG.TempAuthFile) end
        return false, "Expired"
    end

    loadTemporaryKeys()
    if not isUserIDInTempKeys(USERID) then
        getgenv().YX_Level = "None"
        getgenv().YX_TempExpiry = nil
        if delfile and isfile(CONFIG.TempAuthFile) then delfile(CONFIG.TempAuthFile) end
        return false, "Removed"
    end

    return true, getgenv().YX_TempExpiry - os.time()
end

-- ==================== SCRIPT LOADER ====================
local function loadScript(isPremium, isTemporal, isMobile)
    task.wait(1)
    local url = (isPremium or isTemporal or isMobile) and CONFIG.PremiumURL or CONFIG.FreemiumURL

    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)

    if not success then
        Library:Notify("Error loading script", 8)
        debugPrint(err)
    end

    task.wait(1.2)
    if not Library.Unloaded then
        Library:Unload()
    end
end

-- ==================== SEQUENCES ====================
local function temporaryAuthSequence(expiryTime)
    Library:Notify("Temporal activated • " .. formatTimeRemaining(expiryTime - os.time()), 8)

    task.spawn(function()
        while getgenv().YX_Level == "Temporal" and not Library.Unloaded do
            local ok, reason = checkTemporaryAccess()
            if not ok then
                getgenv().YX_Level = "None"
                Library:Notify("Temporal revoked: " .. tostring(reason), 8)
                sendLog("Temporal Revoked", 16711680, "None", "N/A", {
                    { name = "Reason", value = tostring(reason), inline = false }
                })
                break
            end
            task.wait(10)
        end
    end)
end

-- ==================== UI ====================
local function createAuthUI()
    local Window = Library:CreateWindow({
        Title = "YX Studio's",
        Icon = 94564569718126,
        Footer = "Auth System • YX Studio's",
        AutoShow = true,
        ShowCustomCursor = false,
        NotifySide = "Right"
    })

    -- Auto close 60s
    task.spawn(function()
        local start = tick()
        while not Library.Unloaded do
            local left = math.max(0, 60 - math.floor(tick() - start))
            if left <= 0 then break end
            pcall(function() Window:SetFooter("Closing in " .. left .. "s...") end)
            task.wait(1)
        end
        if not Library.Unloaded then
            sendLog("Timeout", 16711680, "None", "N/A")
            Library:Unload()
        end
    end)

    local isOwner = (USERID == CONFIG.OwnerUserId)

    -- ==================== OWNER ====================
    if isOwner then
        getgenv().YX_Level = "Owner"
        sendLog("Owner Login", 16755200, "Owner", "Owner")
        Library:Notify("Welcome back, Owner", 8)

        local AdminTab = Window:AddTab("Admin", "shield")

        local BanBox = AdminTab:AddLeftGroupbox("Ban System", "ban")
        local BanInput = BanBox:AddInput("BanID", { Text = "UserID to ban", Placeholder = "UserID..." })
        BanBox:AddButton("Ban", function()
            local id = BanInput.Value:match("^%s*(.-)%s*$")
            if id == "" then return Library:Notify("Invalid UserID", 5) end
            BannedUserIDs[id] = true
            Library:Notify("Banned: " .. id, 6)
            sendLog("User Banned", 16711680, "Owner", "N/A", {
                { name = "Banned", value = "`" .. id .. "`", inline = false }
            })
        end)

        local UnbanInput = BanBox:AddInput("UnbanID", { Text = "UserID to unban", Placeholder = "UserID..." })
        BanBox:AddButton("Unban", function()
            local id = UnbanInput.Value:match("^%s*(.-)%s*$")
            if id == "" then return Library:Notify("Invalid UserID", 5) end
            BannedUserIDs[id] = nil
            Library:Notify("Unbanned: " .. id, 6)
            sendLog("User Unbanned", 65280, "Owner", "N/A", {
                { name = "Unbanned", value = "`" .. id .. "`", inline = false }
            })
        end)

        local Tools = AdminTab:AddRightGroupbox("Tools", "tools")
        Tools:AddButton("Reload Keys", function()
            loadAllKeys()
            Library:Notify("Keys reloaded", 5)
        end)
        Tools:AddButton("Disable Public", function()
            CONFIG.PublicKeyEnabled = false
            Library:Notify("Public disabled", 6)
            sendLog("Public Disabled", 16711680, "Owner", "N/A")
        end)
        Tools:AddButton("Enable Public", function()
            CONFIG.PublicKeyEnabled = true
            Library:Notify("Public enabled", 6)
            sendLog("Public Enabled", 65280, "Owner", "N/A")
        end)

        local Loader = AdminTab:AddRightGroupbox("Loader", "upload")
        Loader:AddButton("Load Premium", function()
            getgenv().YX_Level = "Premium"
            sendLog("Owner → Premium", 65280, "Owner", "Owner")
            task.wait(1)
            loadScript(true)
        end)
        Loader:AddButton("Load Freemium", function()
            if isPublicValid() then
                getgenv().YX_Level = "Freemium"
                sendLog("Owner → Freemium", 3447003, "Owner", "Public")
                task.wait(1)
                loadScript(false)
            else
                Library:Notify("Public key disabled/expired", 6)
            end
        end)
        Loader:AddButton("Load Temporal", function()
            getgenv().YX_Level = "Temporal"
            getgenv().YX_TempExpiry = os.time() + 86400
            sendLog("Owner → Temporal", 10181046, "Owner", "Temporal")
            task.wait(1)
            loadScript(false, true)
        end)
        Loader:AddButton("Load Mobile", function()
            getgenv().YX_Level = "Mobile"
            sendLog("Owner → Mobile", 3447003, "Owner", "Mobile")
            task.wait(1)
            loadScript(false, false, true)
        end)
    end

    -- ==================== AUTH TAB ====================
    local AuthTab = Window:AddTab("Auth", "key")
    local AuthBox = AuthTab:AddLeftGroupbox("Key System", "lock")

    local ActiveKeyLabel = AuthBox:AddLabel("Active Key: Loading...")
    local ExpireLabel = AuthBox:AddLabel("Expires: Calculating...")
    local TempLabel = AuthBox:AddLabel("<font color='rgb(255,80,80)'>Temporal: None</font>")

    -- Temporal updater
    task.spawn(function()
        while not Library.Unloaded do
            if getgenv().YX_Level == "Temporal" then
                local ok, timeLeft = checkTemporaryAccess()
                if ok then
                    local color = timeLeft > 3600 and "rgb(0,255,150)" or (timeLeft < 300 and "rgb(255,80,80)" or "rgb(255,165,0)")
                    TempLabel:SetText("Temporal: <font color='" .. color .. "'>" .. formatTimeRemaining(timeLeft) .. "</font>")
                else
                    getgenv().YX_Level = "None"
                    TempLabel:SetText("<font color='rgb(255,80,80)'>Temporal: Revoked</font>")
                    Library:Notify("Temporal access revoked", 8)
                end
            else
                TempLabel:SetText("<font color='rgb(255,80,80)'>Temporal: None</font>")
            end
            task.wait(5)
        end
    end)

    -- Public key status
    task.spawn(function()
        local last = 0
        while not Library.Unloaded do
            local txt = CONFIG.PublicKeyEnabled and CONFIG.PublicKeyRaw or "Disabled"
            local col = CONFIG.PublicKeyEnabled and "rgb(0,255,150)" or "rgb(255,80,80)"
            ActiveKeyLabel:SetText("Active Key: <font color='" .. col .. "'>" .. txt .. "</font>")
            ExpireLabel:SetText("Expires: " .. getExpireTimeString())

            if tick() - last > 30 then
                loadAllKeys()
                last = tick()
            end
            task.wait(1)
        end
    end)

    local KeyInput = AuthBox:AddInput("KeyInput", {
        Text = "Enter Key",
        Placeholder = "Premium / Temporal / Mobile key..."
    })

    AuthBox:AddButton("Verify & Load", function()
        local input = KeyInput.Value:match("^%s*(.-)%s*$")

        if input == "" then
            Library:Notify("Enter a key", 4)
            return
        end

        if BannedUserIDs[USERID] then
            Library:Notify("You are banned", 8)
            sendLog("Banned Attempt", 16711680, "Banned", "N/A")
            return
        end

        loadAllKeys()

        -- 1. Temporary
        if TemporaryKeys[input] then
            local data = TemporaryKeys[input]
            if data.UserID and tostring(data.UserID) ~= USERID then
                Library:Notify("Key not assigned to you", 7)
                sendLog("Wrong Temp Key", 16711680, "None", input)
                return
            end

            local ok, expiry = activateTemporaryKey(input)
            if ok then
                getgenv().YX_Level = "Temporal"
                getgenv().YX_TempExpiry = expiry
                temporaryAuthSequence(expiry)
                sendLog("Temporal Activated", 10181046, "Temporal", input, {
                    { name = "Expires", value = formatTimeRemaining(expiry - os.time()), inline = true }
                })
                task.wait(1.5)
                loadScript(false, true)
                return
            else
                Library:Notify("Temporal key expired/invalid", 7)
                sendLog("Invalid Temp Key", 16711680, "None", input)
                return
            end
        end

        -- 2. Mobile
        if verifyMobileKey(input, USERID) then
            saveMobileAuth(input)
            getgenv().YX_Level = "Mobile"
            Library:Notify("Mobile key activated", 8)
            sendLog("Mobile Login", 3447003, "Mobile", input)
            task.wait(1.5)
            loadScript(false, false, true)
            return

        elseif MobileKeys[input] then
            BannedUserIDs[USERID] = true
            Library:Notify("Shared Mobile key • Banned", 12)
            local reg = (type(MobileKeys[input]) == "table" and MobileKeys[input].UserID) or "Unknown"
            sendLog("Mobile Key Share → Ban", 16711680, "Banned", input, {
                { name = "Registered", value = "`" .. reg .. "`", inline = true }
            })
            task.wait(2.5)
            Library:Unload()
            return
        end

        -- 3. Premium
        if verifyPremiumKey(input, USERID) then
            saveAuth(input)
            getgenv().YX_Level = "Premium"
            Library:Notify("Premium activated", 8)
            sendLog("Premium Login", 65280, "Premium", input)
            task.wait(1.5)
            loadScript(true)
            return

        elseif PremiumKeys[input] then
            BannedUserIDs[USERID] = true
            Library:Notify("Shared key detected • Banned", 12)
            local reg = (type(PremiumKeys[input]) == "table" and PremiumKeys[input].UserID) or "Unknown"
            sendLog("Key Share → Ban", 16711680, "Banned", input, {
                { name = "Registered", value = "`" .. reg .. "`", inline = true }
            })
            task.wait(2.5)
            Library:Unload()
            return
        end

        -- 4. Public
        local clean = input:gsub("[%s%-%.]", ""):upper()
        if clean == CONFIG.PublicKeyClean and isPublicValid() then
            getgenv().YX_Level = "Freemium"
            Library:Notify("Freemium activated", 7)
            sendLog("Freemium Login", 3447003, "Freemium", "Public")
            task.wait(1.2)
            loadScript(false)
            return
        end

        -- Invalid
        Library:Notify("Invalid or expired key", 7)
        sendLog("Invalid Key", 16711680, "None", input)
    end)

    AuthBox:AddButton("Close", function()
        sendLog("Manual Close", 10181046, getgenv().YX_Level or "None", "N/A")
        Library:Unload()
    end)

    AuthBox:AddButton("Join Discord", function()
        pcall(function()
            httpRequest({
                Url = "http://127.0.0.1:6463/rpc?v=1",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json", ["Origin"] = "https://discord.com" },
                Body = HttpService:JSONEncode({
                    cmd = "INVITE_BROWSER",
                    args = { code = CONFIG.DiscordInvite },
                    nonce = HttpService:GenerateGUID(false)
                })
            })
        end)
        if setclipboard then setclipboard("https://discord.gg/" .. CONFIG.DiscordInvite) end
        Library:Notify("Discord invite copied", 5)
    end)

    -- Info
    local InfoBox = AuthTab:AddRightGroupbox("Account", "fingerprint")
    InfoBox:AddButton("Copy UserID", function()
        if setclipboard then setclipboard(USERID) end
        Library:Notify("UserID copied", 5)
    end)
    InfoBox:AddLabel("UserID: " .. USERID)
    InfoBox:AddLabel("User: " .. Player.Name)
    InfoBox:AddLabel("Display: " .. Player.DisplayName)

    InfoBox:AddDivider()
    InfoBox:AddLabel("<font color='rgb(0,255,150)'><b>PREMIUM ACCESS</b></font>")
    InfoBox:AddLabel("• 80k Cash (South Bronx)")
    InfoBox:AddLabel("• Invite 6+ active users")
    InfoBox:AddLabel("• Nitro Boost (2x)")
    InfoBox:AddLabel("<font color='rgb(255,165,0)'>Temporal: 1d / 3d / 7d / 14d</font>")
    InfoBox:AddLabel("<font color='rgb(100,149,237)'>Mobile Keys disponibles</font>")
    InfoBox:AddLabel("<font color='rgb(255,80,80)'>No refunds</font>")

    -- Suggest
    local SuggestTab = Window:AddTab("Suggest", "lightbulb")
    local SuggestBox = SuggestTab:AddLeftGroupbox("Suggestion", "message")
    local SuggestInput = SuggestBox:AddInput("Text", {
        Text = "Your suggestion",
        Placeholder = "Min 20 • Max 300 characters"
    })
    SuggestBox:AddButton("Send", function()
        local text = SuggestInput.Value:match("^%s*(.-)%s*$")
        if #text < 20 then return Library:Notify("Too short (min 20)", 5) end
        if #text > 300 then return Library:Notify("Too long (max 300)", 5) end
        sendLog("New Suggestion", 16776960, getgenv().YX_Level or "None", "N/A", {
            { name = "Text", value = text, inline = false }
        })
        Library:Notify("Suggestion sent", 6)
        SuggestInput:SetValue("")
    end)
end

-- ==================== AUTO LOGIN ====================
local function tryAutoLogin()
    -- Temporal
    local tempKey, tempExpiry = loadTempAuth()
    if tempKey and tempExpiry and os.time() < tempExpiry and not BannedUserIDs[USERID] then
        loadTemporaryKeys()
        if isUserIDInTempKeys(USERID) then
            getgenv().YX_Level = "Temporal"
            getgenv().YX_TempExpiry = tempExpiry
            temporaryAuthSequence(tempExpiry)
            sendLog("Temporal AutoLogin", 10181046, "Temporal", tempKey)
            task.wait(2)
            loadScript(false, true)
            return true
        else
            if delfile and isfile(CONFIG.TempAuthFile) then delfile(CONFIG.TempAuthFile) end
            getgenv().YX_Level = "None"
            Library:Notify("Temporal revoked", 8)
            sendLog("Temporal Revoked", 16711680, "None", "N/A")
        end
    end

    -- Mobile
    local mobileKey = loadMobileAuth()
    if mobileKey and not BannedUserIDs[USERID] then
        loadMobileKeys()
        if verifyMobileKey(mobileKey, USERID) then
            getgenv().YX_Level = "Mobile"
            Library:Notify("Mobile AutoLogin", 8)
            sendLog("Mobile AutoLogin", 3447003, "Mobile", mobileKey)
            task.wait(2)
            loadScript(false, false, true)
            return true
        end
    end

    -- Premium
    local saved = loadAuth()
    if saved and not BannedUserIDs[USERID] then
        loadPremiumKeys()
        if verifyPremiumKey(saved, USERID) then
            getgenv().YX_Level = "Premium"
            Library:Notify("Premium AutoLogin", 8)
            sendLog("Premium AutoLogin", 65280, "Premium", saved)
            task.wait(2)
            loadScript(true)
            return true
        else
            getgenv().YX_Level = "None"
            Library:Notify("Premium revoked", 8)
            sendLog("Premium Revoked", 16711680, "None", "N/A")
        end
    end

    return false
end

-- ==================== INIT ====================
loadAllKeys()
debugPrint("UserID:", USERID)

if not tryAutoLogin() then
    pcall(createAuthUI)
end
