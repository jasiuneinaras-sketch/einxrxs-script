local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EinxrxsHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local squareButton = Instance.new("TextButton")
squareButton.Name = "EinxrxsMenuBtn"
squareButton.Size = UDim2.new(0, 50, 0, 50)
squareButton.Position = UDim2.new(0, 15, 0.25, 0)
squareButton.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
squareButton.Text = ""
squareButton.TextColor3 = Color3.fromRGB(255, 255, 255)
squareButton.Font = Enum.Font.GothamBold
squareButton.TextSize = 14
squareButton.Parent = screenGui

local squareCorner = Instance.new("UICorner")
squareCorner.CornerRadius = UDim.new(0, 8)
squareCorner.Parent = squareButton

local squareIcon = Instance.new("TextLabel")
squareIcon.Size = UDim2.new(1, 0, 1, 0)
squareIcon.BackgroundTransparency = 1
squareIcon.Text = "☰"
squareIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
squareIcon.Font = Enum.Font.GothamBold
squareIcon.TextSize = 24
squareIcon.Parent = squareButton

local mainPanel = Instance.new("Frame")
mainPanel.Name = "EinxrxsMainFrame"
mainPanel.Size = UDim2.new(0, 340, 0, 440) -- Slightly taller for Lagger tab
mainPanel.Position = UDim2.new(1, -355, 0.5, -220)
mainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainPanel.Visible = false
mainPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = mainPanel

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    mainPanel.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

local titleHeader = Instance.new("Frame")
titleHeader.Name = "TitleHeader"
titleHeader.Size = UDim2.new(1, 0, 0, 40)
titleHeader.Position = UDim2.new(0, 0, 0, 0)
titleHeader.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleHeader.BorderSizePixel = 0
titleHeader.Parent = mainPanel

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleHeader

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "einxrxs-scripts"
titleLabel.TextColor3 = Color3.fromRGB(59, 130, 246)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = titleHeader

titleHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainPanel.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleHeader.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 45)
tabContainer.Position = UDim2.new(0, 0, 0, 45)
tabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainPanel

-- Updated tabs with Lagger
local tabs = {"Main", "Player", "Visual", "Lagger"}
local tabButtons = {}
local contentFrames = {}

-- BK Lagger configuration (colors matched to your theme)
local LAGGER_CONFIG = {
    Accent = Color3.fromRGB(110, 90, 255),
    Dark = Color3.fromRGB(18, 18, 28),
    Corner = UDim.new(0, 10)
}

-- =============================================
--          TAB CREATION LOOP
-- =============================================

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1/#tabs, -4, 1, -10)
    tabButton.Position = UDim2.new((i-1)/#tabs, 2, 0, 5)
    tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 16
    tabButton.Parent = tabContainer
    
    local tabBtnCorner = Instance.new("UICorner")
    tabBtnCorner.CornerRadius = UDim.new(0, 6)
    tabBtnCorner.Parent = tabButton
    
    tabButtons[tabName] = tabButton
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = tabName .. "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -105)
    contentFrame.Position = UDim2.new(0, 10, 0, 95)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible = false
    contentFrame.Parent = mainPanel
    
    contentFrames[tabName] = contentFrame
    
    -- =============================================
    --               LAGGER TAB CONTENT (FULL)
    -- =============================================
    if tabName == "Lagger" then
        -- Power Slider Section
        local powerSection = Instance.new("Frame")
        powerSection.Size = UDim2.new(1, 0, 0, 90)
        powerSection.BackgroundTransparency = 1
        powerSection.Parent = contentFrame

        local powerLabel = Instance.new("TextLabel")
        powerLabel.Size = UDim2.new(0.65, 0, 0, 25)
        powerLabel.Position = UDim2.new(0, 12, 0, 8)
        powerLabel.BackgroundTransparency = 1
        powerLabel.Text = "Power: 20% (2000 pkts)"
        powerLabel.TextColor3 = Color3.fromRGB(210, 190, 255)
        powerLabel.Font = Enum.Font.GothamBold
        powerLabel.TextSize = 14
        powerLabel.TextXAlignment = Enum.TextXAlignment.Left
        powerLabel.Parent = powerSection

        local pktsLabel = Instance.new("TextLabel")
        pktsLabel.Size = UDim2.new(0.35, -12, 0, 25)
        pktsLabel.Position = UDim2.new(0.65, 0, 0, 8)
        pktsLabel.BackgroundTransparency = 1
        pktsLabel.Text = "0/s"
        pktsLabel.TextColor3 = Color3.fromRGB(120, 220, 255)
        pktsLabel.Font = Enum.Font.Gotham
        pktsLabel.TextSize = 14
        pktsLabel.TextXAlignment = Enum.TextXAlignment.Right
        pktsLabel.Parent = powerSection

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -24, 0, 20)
        sliderBg.Position = UDim2.new(0, 12, 0, 42)
        sliderBg.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        sliderBg.Parent = powerSection
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0.2, 0, 1, 0)
        sliderFill.BackgroundColor3 = LAGGER_CONFIG.Accent
        sliderFill.Parent = sliderBg
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

        local sliderKnob = Instance.new("Frame")
        sliderKnob.Size = UDim2.new(0, 22, 0, 22)
        sliderKnob.Position = UDim2.new(1, -11, 0.5, -11)
        sliderKnob.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        sliderKnob.Parent = sliderFill
        Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
        local knobStroke = Instance.new("UIStroke", sliderKnob)
        knobStroke.Color = LAGGER_CONFIG.Accent
        knobStroke.Thickness = 2

        local draggingSlider = false
        local sliderValue = 0.2

        local function UpdateSlider(input)
            local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            sliderValue = relativeX
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            
            local percent = math.floor(relativeX * 100)
            local packets = math.floor(relativeX * 10000)
            powerLabel.Text = "Power: " .. percent .. "% (" .. packets .. " pkts)"
        end

        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                UpdateSlider(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)

        -- Lag / Stop Buttons
        local lagButton = Instance.new("TextButton")
        lagButton.Size = UDim2.new(1, -24, 0, 50)
        lagButton.Position = UDim2.new(0, 12, 0, 100)
        lagButton.BackgroundColor3 = Color3.fromRGB(90, 70, 200)
        lagButton.Text = "Lag the Server!"
        lagButton.TextColor3 = Color3.fromRGB(240, 240, 255)
        lagButton.Font = Enum.Font.GothamBold
        lagButton.TextSize = 17
        lagButton.Parent = contentFrame
        Instance.new("UICorner", lagButton).CornerRadius = UDim.new(0, 12)

        local stopButton = Instance.new("TextButton")
        stopButton.Size = UDim2.new(1, -24, 0, 50)
        stopButton.Position = UDim2.new(0, 12, 0, 160)
        stopButton.BackgroundColor3 = Color3.fromRGB(160, 50, 80)
        stopButton.Text = "Stop Spamming"
        stopButton.TextColor3 = Color3.fromRGB(255, 220, 220)
        stopButton.Font = Enum.Font.GothamBold
        stopButton.TextSize = 17
        stopButton.Parent = contentFrame
        Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 12)

        local lagActive = false

        lagButton.MouseButton1Click:Connect(function()
            lagActive = true
            lagButton.Text = "Lagging..."
        end)

        stopButton.MouseButton1Click:Connect(function()
            lagActive = false
            lagButton.Text = "Lag the Server!"
            pktsLabel.Text = "0/s"
        end)

        -- Fake packet counter animation (visual only)
        task.spawn(function()
            while true do
                if lagActive then
                    local basePackets = math.floor(sliderValue * 10000)
                    pktsLabel.Text = tostring(basePackets + math.random(-500, 500)) .. "/s"
                else
                    pktsLabel.Text = "0/s"
                end
                task.wait(0.09)
            end
        end)
    end

    -- ======================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local madebyrznnq = true
local espConnections = {}
local function createESP(plr)
    if plr == player then return end
    if not plr.Character then return end
    if plr.Character:FindFirstChild("followme@rznnq") then return end
    local char = plr.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not (hrp and head) then return end
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "player"
    hitbox.Adornee = hrp
    hitbox.Size = Vector3.new(4, 6, 2)
    hitbox.Color3 = Color3.fromRGB(128, 0, 128)
    hitbox.Transparency = 0.6
    hitbox.ZIndex = 10
    hitbox.AlwaysOnTop = true
    hitbox.Parent = char
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "cpsito riko"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = plr.DisplayName or plr.Name
    label.TextColor3 = Color3.fromRGB(255, 0, 255)
    label.Font = Enum.Font.Arcade
    label.TextScaled = true
    label.TextStrokeTransparency = 0.7
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = billboard
end
local function removeESP(plr)
    if not plr.Character then return end
    local hitbox = plr.Character:FindFirstChild("ESP_Hitbox")
    local nameGui = plr.Character:FindFirstChild("ESP_Name")
    if hitbox then hitbox:Destroy() end
    if nameGui then nameGui:Destroy() end
end
local function enableESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            if plr.Character then
                createESP(plr)
            end
            local conn = plr.CharacterAdded:Connect(function()
                task.wait(0.1)
                if madebyrznnq then
                    createESP(plr)
                end
            end)
            table.insert(espConnections, conn)
        end
    end
    local playerAddedConn = Players.PlayerAdded:Connect(function(plr)
        if plr == player then return end

        local charAddedConn = plr.CharacterAdded:Connect(function()
            task.wait(0.1)
            if madebyrznnq then
                createESP(plr)
            end
        end)
        table.insert(espConnections, charAddedConn)
    end)
    table.insert(espConnections, playerAddedConn)
end
local function disableESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        removeESP(plr)
    end
    for _, conn in ipairs(espConnections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    espConnections = {}
end
player.CharacterAdded:Connect(function()
    task.wait(0.1)
    if madebyrznnq then
        enableESP()
    else
        disableESP()
    end
end)
if madebyrznnq then
    enableESP()
end
    -- ======================
    -- ... your existing code for Main, Player, Visual tabs ...
end

-- Tab switching
local function switchTab(tabName)
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    for name, frame in pairs(contentFrames) do
        frame.Visible = (name == tabName)
    end
end

for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

squareButton.MouseButton1Click:Connect(function()
    mainPanel.Visible = not mainPanel.Visible
    if mainPanel.Visible then
        switchTab("Main")
    end
end)

switchTab("Main")

print("GUI Loaded Successfully! (with Lagger tab)")
