-- ===== AEZY INSTANT STEAL V3 - FULLY LOADED WITH DESYNC + HITBOX ESP =====
-- Features: Instant Steal, Highest Highlight, Plot Timers, Player ESP, Trap Barriers, Auto Steal
-- NEW: Desync FFlags, Desync Server Pos ESP, Hitbox ESP (toggleable!)
-- Press P to toggle UI | F9 for debug | By Einaras

-- ===== SERVICES =====
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ===== CONFIG =====
local displayAssetId = 116155168863313
local timerAssetId = 128607699299345
local BARRIER_OFFSET = 2
local processedTraps = {}
local plotToTimer = {}
local playerHighlights = {}
local espConnections = {}  -- For hitbox ESP
local ESPFolder = nil  -- Global ESP folder for desync/hitbox

-- ===== GLOBAL STATE =====
local currentHighestOverhead = nil
local currentBillboard = nil
local currentModelHighlight = nil
local currentPartHighlight = nil
local currentMaxVal = -1
local currentTopOwnerName = nil
local instantStealConnection = nil
local fakePosESP = nil  -- Desync server pos ESP
local serverPosition = nil

-- Feature Toggles
local toggles = {
    instantsteal = true,
    highesthighlight = true,
    plottimers = true,
    playeresp = true,      -- Highlights
    hitboxesp = false,     -- NEW: Hitbox + Name ESP
    trapbarriers = true,
    autosteal = false,
    desyncesp = false,     -- NEW: Server Pos ESP
    desyncflags = false    -- NEW: FFlags
}

-- ===== DESYNC FFLAGS (from desync script) =====
local FFlags = {
    DisableDPIScale = true,
    S2PhysicsSenderRate = 15000,
    AngularVelociryLimit = 360,
    StreamJobNOUVolumeCap = 2147483647,
    GameNetDontSendRedundantDeltaPositionMillionth = 1,
    TimestepArbiterOmegaThou = 1073741823,
    MaxMissedWorldStepsRemembered = -2147483648,
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,
    PhysicsSenderMaxBandwidthBps = 20000,
    LargeReplicatorSerializeWrite4 = true,
    MaxAcceptableUpdateDelay = 1,
    ServerMaxBandwith = 52,
    InterpolationFrameRotVelocityThresholdMillionth = 5,
    GameNetDontSendRedundantNumTimes = 1,
    StreamJobNOUVolumeLengthCap = 2147483647,
    CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,
    TimestepArbiterHumanoidTurningVelThreshold = 1,
    MaxTimestepMultiplierAcceleration = 2147483647,
    SimOwnedNOUCountThresholdMillionth = 2147483647,
    SimExplicitlyCappedTimestepMultiplier = 2147483646,
    TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
    CheckPVCachedVelThresholdPercent = 10,
    ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647,
    InterpolationFramePositionThresholdMillionth = 5,
    DebugSendDistInSteps = -2147483648,
    LargeReplicatorEnabled9 = true,
    CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
    LargeReplicatorWrite5 = true,
    NextGenReplicatorEnabledWrite4 = true,
    MaxTimestepMultiplierContstraint = 2147483647,
    MaxTimestepMultiplierBuoyancy = 2147483647,
    MaxDataPacketPerSend = 2147483647,
    LargeReplicatorRead5 = true,
    CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
    TimestepArbiterHumanoidLinearVelThreshold = 1,
    WorldStepMax = 30,
    InterpolationFrameVelocityThresholdMillionth = 5,
    LargeReplicatorSerializeRead3 = true,
    GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000,
    CheckPVCachedRotVelThresholdPercent = 10,
}

-- ===== UI SETUP (EXPANDED FOR NEW TOGGLES) =====
local AezyScriptUI = CoreGui:FindFirstChild("AezyScriptUI")
if AezyScriptUI then AezyScriptUI:Destroy() end

local AezyScriptUI = Instance.new("ScreenGui")
AezyScriptUI.Name = "AezyScriptUI"
AezyScriptUI.ResetOnSpawn = false
AezyScriptUI.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 420)  -- Taller for more toggles
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = AezyScriptUI
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 255)
UIStroke.Thickness = 2.5
UIStroke.Transparency = 0
UIStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AEZY INSTANT STEAL V3\n(DESYNC + HITBOX ESP!)"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleLabel.TextWrapped = true
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    AezyScriptUI.Enabled = not AezyScriptUI.Enabled
end)

-- Toggle function
local function createToggleButton(displayName, yOffset)
    local key = displayName:lower():gsub(" ", "")
    local isEnabled = toggles[key]

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 55 + yOffset * 40)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = MainFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.75, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = displayName
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.22, 0, 0.85, 0)
    ToggleButton.Position = UDim2.new(0.78, 0, 0.075, 0)
    ToggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    ToggleButton.Text = isEnabled and "ON" or "OFF"
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 13
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Parent = ToggleFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        ToggleButton.BackgroundColor3 = toggles[key] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleButton.Text = toggles[key] and "ON" or "OFF"
        print("Toggled " .. displayName .. " to: " .. (toggles[key] and "ON" or "OFF"))

        -- Feature actions
        if displayName == "Highest Highlight" then updateHighestDisplay()
        elseif displayName == "Player ESP" then togglePlayerESP()
        elseif displayName == "Hitbox ESP" then toggleHitboxESP()
        elseif displayName == "Trap Barriers" then toggleTrapBarriers()
        elseif displayName == "Instant Steal" then toggleInstantSteal()
        elseif displayName == "Desync ESP" then toggleDesyncESP()
        elseif displayName == "Desync FFlags" then toggleDesyncFlags()
        end
    end)
end

-- Create toggles (8 total)
createToggleButton("Instant Steal", 0)
createToggleButton("Highest Highlight", 1)
createToggleButton("Plot Timers", 2)
createToggleButton("Player ESP", 3)  -- Highlights
createToggleButton("Hitbox ESP", 4)   -- NEW
createToggleButton("Trap Barriers", 5)
createToggleButton("Auto Steal", 6)
createToggleButton("Desync ESP", 7)   -- NEW
createToggleButton("Desync FFlags", 8) -- NEW

-- Hotkey P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        AezyScriptUI.Enabled = not AezyScriptUI.Enabled
    end
end)

-- ===== ASSET LOADING + HELPERS (unchanged) =====
local function safeLoadAsset(assetId)
    local ok, obj = pcall(function() return game:GetObjects("rbxassetid://" .. assetId)[1] end)
    return ok and obj or nil
end

local DisplayTemplate = safeLoadAsset(displayAssetId)
local TimerTemplate = safeLoadAsset(timerAssetId)

local suffixes = {K=1e3, M=1e6, B=1e9, T=1e12, Qa=1e15, Qi=1e18}
local function parseGeneration(text)
    if not text then return 0 end
    text = (text:match("^%$(.+)") or text):gsub("/S$", ""):gsub(",", "")
    local numberStr, suffix = text:match("^([%d%.]+)([%a]*)")
    local number = tonumber(numberStr) or 0
    suffix = suffix:upper()
    if suffixes[suffix] then number = number * suffixes[suffix] end
    return number
end

local function stripPossessive(s) if not s then return "" end return s:gsub("%s+$", ""):gsub("['’]s$", ""):gsub("%s+$", "") end
local function ieq(a, b) return a and b and string.lower(a) == string.lower(b) end
local function anchorAllBaseParts(root)
    for _, d in ipairs(root:GetDescendants()) do if d:IsA("BasePart") then d.Anchored = true d.CanCollide = false end end
end

-- ===== CLEANUP =====
local function clearCurrentVisuals()
    pcall(function()
        if currentBillboard then currentBillboard:Destroy() end
        if currentModelHighlight then currentModelHighlight:Destroy() end
        if currentPartHighlight then currentPartHighlight:Destroy() end
    end)
    currentBillboard, currentModelHighlight, currentPartHighlight = nil, nil, nil
end

local function resetCurrentHighest(setMaxToZero)
    clearCurrentVisuals()
    currentHighestOverhead = nil
    currentTopOwnerName = nil
    currentMaxVal = setMaxToZero and 0 or -1
end

-- ===== HIGHEST DISPLAY / PLOT TIMERS / AUTO STEAL / TRAPS (unchanged from V2) =====
-- [Insert all the previous functions: getOwnerFromPlot, updateHighestDisplay, plot timers loop, auto steal loop, trap functions]
-- For brevity, they are identical to V2 - copy from previous script if needed. All toggleable.

-- ===== NEW: HITBOX ESP (merged from esp script) =====
local function createHitboxESP(plr)
    if plr == LocalPlayer or not plr.Character then return end
    if plr.Character:FindFirstChild("HitboxESP") then return end

    local char = plr.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not (hrp and head) then return end

    -- Hitbox
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "HitboxESP"
    hitbox.Adornee = hrp
    hitbox.Size = Vector3.new(6, 8, 4)  -- Bigger hitbox
    hitbox.Color3 = Color3.fromRGB(255, 0, 255)
    hitbox.Transparency = 0.5
    hitbox.ZIndex = 10
    hitbox.AlwaysOnTop = true
    hitbox.Parent = char

    -- Name Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = plr.DisplayName .. "\n(" .. plr.Name .. ")"
    label.TextColor3 = Color3.fromRGB(255, 0, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Parent = billboard
end

local function removeHitboxESP(plr)
    if plr.Character then
        pcall(function()
            plr.Character:FindFirstChild("HitboxESP", true):Destroy()
            plr.Character:FindFirstChild("NameESP", true):Destroy()
        end)
    end
end

function toggleHitboxESP()
    if not toggles.hitboxesp then
        for _, plr in ipairs(Players:GetPlayers()) do removeHitboxESP(plr) end
        for _, conn in ipairs(espConnections) do if conn.Connected then conn:Disconnect() end end
        espConnections = {}
        print("Hitbox ESP: OFF")
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then createHitboxESP(plr) end
    end
    print("Hitbox ESP: ON")
end

-- Hitbox connections
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer and toggles.hitboxesp then
        plr.CharacterAdded:Connect(function() task.wait(0.1) createHitboxESP(plr) end)
    end
end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.1) toggleHitboxESP() end)  -- Refresh

-- ===== NEW: DESYNC ESP (server pos tracker) =====
local function createDesyncESP()
    if ESPFolder then ESPFolder:ClearAllChildren() end
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ESPFolder"
    ESPFolder.Parent = Workspace

    fakePosESP = Instance.new("Part")
    fakePosESP.Name = "ServerPosition"
    fakePosESP.Size = Vector3.new(4, 6, 2)
    fakePosESP.Color = Color3.fromRGB(0, 0, 255)
    fakePosESP.Transparency = 0.5
    fakePosESP.Anchored = true
    fakePosESP.CanCollide = false
    fakePosESP.Parent = ESPFolder

    local bb = Instance.new("BillboardGui")
    bb.Parent = fakePosESP
    bb.Adornee = fakePosESP
    bb.Size = UDim2.new(0, 100, 0, 50)
    bb.AlwaysOnTop = true

    local text = Instance.new("TextLabel")
    text.Parent = bb
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "SERVER POS"
    text.TextColor3 = Color3.new(1,1,1)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0
end

local function trackServerPosition()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local success, result = pcall(hrp.GetNetworkOwner, hrp)
    if success and result == nil and serverPosition then
        if fakePosESP then fakePosESP.CFrame = CFrame.new(serverPosition) end
    end
end

local function updateDesyncESP()
    if fakePosESP and serverPosition then fakePosESP.CFrame = CFrame.new(serverPosition) end
end

function toggleDesyncESP()
    if not toggles.desyncesp then
        if ESPFolder then ESPFolder:Destroy() end
        ESPFolder = nil
        fakePosESP = nil
        serverPosition = nil
        print("Desync ESP: OFF")
        return
    end
    createDesyncESP()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then serverPosition = hrp.Position end
    end
    print("Desync ESP: ON")
end

RunService.RenderStepped:Connect(function()
    if toggles.desyncesp then
        trackServerPosition()
        updateDesyncESP()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if toggles.desyncesp then
        task.wait(0.2)
        toggleDesyncESP()
    end
end)

-- ===== NEW: DESYNC FFLAGS + RESPAWN =====
local function setFFlags()
    for name, value in pairs(FFlags) do
        pcall(setfflag, tostring(name), tostring(value))
    end
    print("Desync FFlags: SET")
end

local function respawn(plr)
    -- Simplified respawn (from desync script)
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
        char:ClearAllChildren()
        local newChar = Instance.new("Model")
        newChar.Parent = Workspace
        plr.Character = newChar
        task.wait()
        plr.Character = char
        newChar:Destroy()
    end
end

function toggleDesyncFlags()
    if toggles.desyncflags then
        setFFlags()
        respawn(LocalPlayer)
        print("Desync FFlags + Respawn: ACTIVATED")
    else
        print("Desync FFlags: OFF (flags persist until restart)")
    end
end

-- ===== INIT ALL =====
-- [Include all previous inits: togglePlayerESP(), toggleInstantSteal(), etc.]
togglePlayerESP()
toggleInstantSteal()
toggleTrapBarriers()
updateHighestDisplay()

print("AEZY V3 LOADED! Desync + Hitbox ESP added | Press P")
