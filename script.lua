-- ===== AEZY INSTANT STEAL V2 - Improved Version with Enhanced UI =====
-- Enhanced features: Toggleable options, better visuals, auto-steal toggle, improved trap detection, customizable settings.

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
local displayAssetId = 116155168863313  -- Replace if needed
local timerAssetId = 128607699299345    -- Replace if needed
local BARRIER_OFFSET = 1                 -- Barrier expansion size
local processedTraps = {}                -- Track processed traps
local plotToTimer = {}                   -- Track plot timers
local playerHighlights = {}              -- Track player ESP highlights

-- ===== GLOBAL STATE =====
local currentHighestOverhead = nil
local currentBillboard = nil
local currentModelHighlight = nil
local currentPartHighlight = nil
local currentMaxVal = -1
local currentTopOwnerName = nil

-- Feature Toggles
local toggles = {
    instantSteal = true,
    highestHighlight = true,
    plotTimers = true,
    playerESP = true,
    trapBarriers = true,
    autoSteal = false  -- New feature: Auto-steal highest when unlocked
}

-- ===== UI SETUP (IMPROVED) =====
local AezyScriptUI = CoreGui:FindFirstChild("AezyScriptUI")
if AezyScriptUI then
    AezyScriptUI:Destroy()
end

local AezyScriptUI = Instance.new("ScreenGui")
AezyScriptUI.Name = "AezyScriptUI"
AezyScriptUI.ResetOnSpawn = false
AezyScriptUI.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = AezyScriptUI
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.1
UIStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AEZY INSTANT STEAL V2"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Parent = MainFrame
CloseButton.MouseButton1Click:Connect(function()
    AezyScriptUI.Enabled = false
end)

-- Toggle Buttons
local function createToggleButton(name, yOffset, default)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 0, 0, 40 + yOffset * 35)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = MainFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.2, 0, 1, 0)
    ToggleButton.Position = UDim2.new(0.8, 0, 0, 0)
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleButton.Text = default and "ON" or "OFF"
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 12
    ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.Parent = ToggleFrame

    local UICornerToggle = Instance.new("UICorner")
    UICornerToggle.CornerRadius = UDim.new(0, 6)
    UICornerToggle.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        toggles[name:lower():gsub(" ", "")] = not toggles[name:lower():gsub(" ", "")]
        ToggleButton.BackgroundColor3 = toggles[name:lower():gsub(" ", "")] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = toggles[name:lower():gsub(" ", "")] and "ON" or "OFF"
        -- Trigger updates if needed
        if name == "Highest Highlight" then updateHighestDisplay() end
        if name == "Player ESP" then togglePlayerESP() end
        if name == "Trap Barriers" then toggleTrapBarriers() end
    end)

    return ToggleFrame
end

createToggleButton("Instant Steal", 0, toggles.instantSteal)
createToggleButton("Highest Highlight", 1, toggles.highestHighlight)
createToggleButton("Plot Timers", 2, toggles.plotTimers)
createToggleButton("Player ESP", 3, toggles.playerESP)
createToggleButton("Trap Barriers", 4, toggles.trapBarriers)
createToggleButton("Auto Steal", 5, toggles.autoSteal)

-- Hotkey to toggle UI (e.g., Press 'P')
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        AezyScriptUI.Enabled = not AezyScriptUI.Enabled
    end
end)

-- ===== ASSET LOADING =====
local DisplayTemplate = safeLoadAsset(displayAssetId)
local TimerTemplate = safeLoadAsset(timerAssetId)

function safeLoadAsset(assetId)
    local ok, obj = pcall(function()
        return game:GetObjects("rbxassetid://" .. assetId)[1]
    end)
    return ok and obj or nil
end

-- ===== MONEY PARSING (IMPROVED) =====
local suffixes = {K=1e3, M=1e6, B=1e9, T=1e12, Qa=1e15, Qi=1e18}
function parseGeneration(text)
    if not text then return 0 end
    text = text:match("^%$(.+)") or text
    text = text:gsub("/S$", ""):gsub(",", "")
    local numberStr, suffix = text:match("^([%d%.]+)([%a]*)")
    local number = tonumber(numberStr) or 0
    if suffix and suffixes[suffix:upper()] then number = number * suffixes[suffix:upper()] end
    return number
end

-- ===== HELPERS =====
function stripPossessive(s)
    if not s then return nil end
    return s:gsub("%s+$", ""):gsub("['’]s$", ""):gsub("%s+$", "")
end

function ieq(a, b)
    return a and b and string.lower(a) == string.lower(b)
end

function anchorAllBaseParts(root)
    for _, d in root:GetDescendants() do
        if d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
        end
    end
end

-- ===== CLEANUP =====
function clearCurrentVisuals()
    if currentBillboard then currentBillboard:Destroy() end
    if currentModelHighlight then currentModelHighlight:Destroy() end
    if currentPartHighlight then currentPartHighlight:Destroy() end
    currentBillboard, currentModelHighlight, currentPartHighlight = nil, nil, nil
end

function resetCurrentHighest(setMaxToZero)
    clearCurrentVisuals()
    currentHighestOverhead = nil
    currentTopOwnerName = nil
    currentMaxVal = setMaxToZero and 0 or -1
end

-- ===== HIGHEST GENERATION DISPLAY (IMPROVED WITH TWEENING) =====
function getOwnerFromPlot(plot)
    local multiplierPart = plot:FindFirstChild("Multiplier", true)
    local parentForSign = multiplierPart and multiplierPart.Parent or plot
    local plotSign = parentForSign:FindFirstChild("PlotSign", true) or plot:FindFirstChild("PlotSign", true)
    if not plotSign then return nil end
    local label = plotSign:FindFirstChildWhichIsA("TextLabel", true)
    return label and stripPossessive(label.Text) or nil
end

function updateHighestDisplay()
    if not toggles.highestHighlight then
        resetCurrentHighest(true)
        return
    end

    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end

    resetCurrentHighest(true)
    local bestVal, bestOverhead, bestPlot, bestOwnerName = -1, nil, nil, nil

    for _, plot in plotsFolder:GetChildren() do
        if plot:IsA("Model") or plot:IsA("Folder") then
            local plotBestVal, plotBestOverhead = -1, nil
            for _, obj in plot:GetDescendants() do
                if obj.Name == "AnimalOverhead" and obj:IsA("BillboardGui") then
                    local genLabel = obj:FindFirstChild("Generation")
                    if genLabel then
                        local val = parseGeneration(genLabel.Text)
                        if val > plotBestVal then
                            plotBestVal, plotBestOverhead = val, obj
                        end
                    end
                end
            end
            if plotBestOverhead and plotBestVal > bestVal then
                local ownerName = getOwnerFromPlot(plot)
                if ownerName and not ieq(ownerName, LocalPlayer.Name) then
                    bestVal, bestOverhead, bestPlot, bestOwnerName = plotBestVal, plotBestOverhead, plot, ownerName
                end
            end
        end
    end

    if not bestOverhead then return end

    currentTopOwnerName = bestOwnerName
    currentHighestOverhead, currentMaxVal = bestOverhead, bestVal

    local originalDisplayName = bestOverhead:FindFirstChild("DisplayName")
    if not originalDisplayName then return end

    local baseParent = bestOverhead.Parent
    for _ = 1, 4 do if baseParent then baseParent = baseParent.Parent end end
    local nameToFind = originalDisplayName.Text
    local foundTargetChild

    for extra = 0, 2 do
        local candidate = baseParent
        for _ = 1, extra do if candidate then candidate = candidate.Parent end end
        if candidate then
            local child = candidate:FindFirstChild(nameToFind)
            if child then foundTargetChild = child break end
        end
    end
    if not foundTargetChild then return end

    -- Highlight with tweening for better visuals
    local modelHighlight = Instance.new("Highlight")
    modelHighlight.Adornee = foundTargetChild
    modelHighlight.FillTransparency = 0.75
    modelHighlight.FillColor = Color3.fromRGB(255, 0, 0)
    modelHighlight.OutlineTransparency = 0
    modelHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    modelHighlight.Parent = foundTargetChild
    currentModelHighlight = modelHighlight
    TweenService:Create(modelHighlight, TweenInfo.new(1, Enum.EasingStyle.Bounce), {FillTransparency = 0.5}):Play()

    local billboardParentPart = foundTargetChild:IsA("BasePart") and foundTargetChild or foundTargetChild:FindFirstChildWhichIsA("BasePart", true)
    if not billboardParentPart then return end

    if DisplayTemplate then
        local displayBillboard = DisplayTemplate:FindFirstChild("BillboardGui", true):Clone()
        displayBillboard.AlwaysOnTop = true
        displayBillboard.MaxDistance = 0
        displayBillboard.StudsOffset = Vector3.new(0, 3, 0)
        displayBillboard.Parent = billboardParentPart
        local cloneDisplay = displayBillboard:FindFirstChild("DisplayName", true)
        if cloneDisplay then cloneDisplay.Text = originalDisplayName.Text end
        local origGen, cloneGen = bestOverhead:FindFirstChild("Generation"), displayBillboard:FindFirstChild("Generation", true)
        if cloneGen and origGen then cloneGen.Text = origGen.Text end
        currentBillboard = displayBillboard
    end

    local partHighlight = Instance.new("Highlight")
    partHighlight.Adornee = billboardParentPart
    partHighlight.FillTransparency = 0.75
    partHighlight.FillColor = Color3.fromRGB(255, 0, 0)
    partHighlight.OutlineTransparency = 0
    partHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    partHighlight.Parent = Workspace
    currentPartHighlight = partHighlight
end

-- ===== TIMER LOOP =====
task.spawn(function()
    while true do
        if not toggles.plotTimers then task.wait(1) continue end
        local plotsFolder = Workspace:FindFirstChild("Plots")
        if not plotsFolder or not TimerTemplate then task.wait(1) continue end

        for _, plot in plotsFolder:GetChildren() do
            if not plotToTimer[plot] then
                local multiplierPart = plot:FindFirstChild("Multiplier", true)
                if multiplierPart and multiplierPart:IsA("BasePart") then
                    local timerClone = TimerTemplate:Clone()
                    timerClone.Parent = plot
                    anchorAllBaseParts(timerClone)

                    if timerClone.PrimaryPart then
                        timerClone:SetPrimaryPartCFrame(multiplierPart.CFrame)
                    elseif timerClone:IsA("BasePart") then
                        timerClone.CFrame = multiplierPart.CFrame
                    else
                        local anyBase = timerClone:FindFirstChildWhichIsA("BasePart", true)
                        if anyBase then anyBase.CFrame = multiplierPart.CFrame end
                    end

                    local timerBillboard = timerClone:FindFirstChild("BillboardGui", true)
                    local timerTextLabel = timerBillboard and timerBillboard:FindFirstChild("Timer", true)
                    if timerBillboard and timerTextLabel then
                        timerBillboard.AlwaysOnTop = true
                        plotToTimer[plot] = {timerClone = timerClone, targetTextLabel = timerTextLabel}
                    else
                        timerClone:Destroy()
                    end
                end
            end

            local entry = plotToTimer[plot]
            if entry and entry.targetTextLabel then
                local remainingTimeLabel = plot:FindFirstChild("RemainingTime", true)
                local sourceText = remainingTimeLabel and remainingTimeLabel.Text or ""
                if sourceText == "0" or ieq(sourceText, "0s") then
                    entry.targetTextLabel.Text = "UNLOCKED"
                    entry.targetTextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif sourceText == "" then
                    entry.targetTextLabel.Text = "60s"
                    entry.targetTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    entry.targetTextLabel.Text = sourceText
                    entry.targetTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
        task.wait(1)
    end
end)

-- ===== PLAYER ESP =====
function addPlayerHighlight(plr)
    local function highlightCharacter(char)
        if playerHighlights[plr] then playerHighlights[plr]:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(173, 216, 230)
        highlight.FillTransparency = 0.75
        highlight.OutlineTransparency = 0
        highlight.OutlineColor = Color3.fromRGB(173, 216, 230)
        highlight.Parent = char
        playerHighlights[plr] = highlight
    end

    if plr.Character then highlightCharacter(plr.Character) end
    plr.CharacterAdded:Connect(highlightCharacter)
end

function togglePlayerESP()
    if not toggles.playerESP then
        for _, hl in playerHighlights do hl:Destroy() end
        playerHighlights = {}
        return
    end
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer then addPlayerHighlight(plr) end
    end
end

-- Force visible
RunService.RenderStepped:Connect(function()
    if not toggles.playerESP then return end
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer then
            local char = Workspace:FindFirstChild(plr.Name)
            if char then
                for _, part in char:GetDescendants() do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.LocalTransparencyModifier = part.Name == "HumanoidRootPart" and 1 or 0
                    end
                end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer and toggles.playerESP then addPlayerHighlight(plr) end
end)

-- ===== INSTANT STEAL =====
if toggles.instantSteal then
    ProximityPromptService.PromptButtonHoldEnded:Connect(function(Prompt, PlayerWhoTriggered)
        if PlayerWhoTriggered == LocalPlayer then
            local targetPos = Vector3.new(-363.87, -7.71, 104.71) + Vector3.new(0, 5, 0)
            LocalPlayer.Character:MoveTo(targetPos)
        end
    end)
end

-- ===== AUTO STEAL (NEW FEATURE) =====
task.spawn(function()
    while true do
        if toggles.autoSteal and currentHighestOverhead then
            -- Check if the plot is unlocked (timer == 0)
            local plot = currentHighestOverhead.Parent.Parent.Parent.Parent  -- Adjust based on hierarchy
            local remainingTimeLabel = plot:FindFirstChild("RemainingTime", true)
            if remainingTimeLabel and (remainingTimeLabel.Text == "0" or ieq(remainingTimeLabel.Text, "0s")) then
                -- Auto-teleport and interact (assuming interaction via fireproximityprompt or similar)
                local char = LocalPlayer.Character
                if char then
                    char:MoveTo(currentHighestOverhead.Parent.Position)
                    task.wait(0.5)
                    -- Find and fire prompt if exists
                    local prompt = currentHighestOverhead.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then fireproximityprompt(prompt) end
                end
            end
        end
        task.wait(1)
    end
end)

-- ===== TRAP DETECTION + BARRIER =====
function isTrapPlaced(model)
    local pp = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if pp and pp.Anchored then return true end
    for _, p in model:GetDescendants() do
        if p:IsA("BasePart") and p.Anchored then return true end
    end
    return false
end

function createTrapBarrier(trap)
    if processedTraps[trap] then return end
    processedTraps[trap] = true

    local cf, size = trap:GetBoundingBox()
    local barrier = Instance.new("Part")
    barrier.Name = "AEZY_TrapBarrier"
    barrier.Size = size + Vector3.new(BARRIER_OFFSET * 2, BARRIER_OFFSET * 2, BARRIER_OFFSET * 2)  -- Improved expansion
    barrier.CFrame = cf
    barrier.Anchored = true
    barrier.CanCollide = true
    barrier.Transparency = 0.7  -- Slightly less transparent
    barrier.Material = Enum.Material.ForceField
    barrier.Color = Color3.fromRGB(0, 255, 0)
    barrier.Parent = Workspace
    barrier.CanTouch = false
    barrier.CanQuery = false

    local hl = Instance.new("Highlight")
    hl.Adornee = barrier
    hl.FillColor = Color3.fromRGB(0, 255, 0)
    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
    hl.FillTransparency = 0.8
    hl.Parent = barrier

    trap.AncestryChanged:Connect(function(_, parent)
        if not parent then
            processedTraps[trap] = nil
            if barrier then barrier:Destroy() end
        end
    end)
end

function scanForTraps()
    for _, obj in Workspace:GetDescendants() do
        if obj:IsA("Model") and obj.Name:lower():find("trap") and isTrapPlaced(obj) then
            createTrapBarrier(obj)
        end
    end
end

function toggleTrapBarriers()
    if not toggles.trapBarriers then
        for trap in processedTraps do
            local barrier = Workspace:FindFirstChild("AEZY_TrapBarrier", true)
            if barrier then barrier:Destroy() end
        end
        processedTraps = {}
        return
    end
    scanForTraps()
end

task.spawn(function()
    while true do
        if toggles.trapBarriers then scanForTraps() end
        task.wait(2)
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    if toggles.trapBarriers and obj:IsA("Model") and obj.Name:lower():find("trap") then
        task.wait(0.5)
        if isTrapPlaced(obj) then createTrapBarrier(obj) end
    end
end)

-- ===== INITIAL EXECUTION =====
updateHighestDisplay()
togglePlayerESP()
toggleTrapBarriers()

task.spawn(function()
    while true do
        updateHighestDisplay()
        task.wait(2)
    end
end)

Players.PlayerAdded:Connect(updateHighestDisplay)
Players.PlayerRemoving:Connect(function()
    clearCurrentVisuals()
    for plot, entry in plotToTimer do if entry.timerClone then entry.timerClone:Destroy() end end
    plotToTimer = {}
    resetCurrentHighest(true)
    updateHighestDisplay()
end)
