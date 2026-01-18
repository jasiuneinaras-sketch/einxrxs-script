-- einxrxs-scripts | with BK Lagger Panel
-- Modified: January 2026

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
mainPanel.Size = UDim2.new(0, 340, 0, 420) -- slightly taller for new tab
mainPanel.Position = UDim2.new(1, -355, 0.5, -210)
mainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainPanel.Visible = false
mainPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = mainPanel

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Dragging
local dragging, dragInput, dragStart, startPos

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

-- Updated tabs (added Lagger)
local tabs = {"Main", "Player", "Visual", "Lagger"}
local tabButtons = {}
local contentFrames = {}

-- =============================================
--          BK LAGGER PANEL (Integrated)
-- =============================================

local UI_CONFIG = {
    MainColor = Color3.fromRGB(20, 15, 30),
    StrokeColor = Color3.fromRGB(130, 50, 210),
    TextColor = Color3.fromRGB(100, 150, 255),
    SubTextColor = Color3.fromRGB(180, 180, 180),
    AccentColor = Color3.fromRGB(140, 40, 220),
    ToggleOn = Color3.fromRGB(100, 255, 160),
    ToggleOff = Color3.fromRGB(60, 60, 60),
    Font = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 12)
}

local function Create(className, properties, children)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do instance[k] = v end
    for _, child in pairs(children or {}) do child.Parent = instance end
    return instance
end

local function CreateSectionFrame(height)
    return Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(25, 20, 35),
        Size = UDim2.new(1, 0, 0, height or 50),
        BackgroundTransparency = 0.5
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = UI_CONFIG.StrokeColor, Thickness = 1, Transparency = 0.5})
    })
end

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
    --               LAGGER TAB CONTENT
    -- =============================================
    if tabName == "Lagger" then
        -- Power Slider Section
        local PowerSection = CreateSectionFrame(70)
        PowerSection.Parent = contentFrame

        local PowerLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 8),
            Size = UDim2.new(0.6, 0, 0, 22),
            Font = UI_CONFIG.Font,
            Text = "Power: 20% (2000 pkts)",
            TextColor3 = Color3.fromRGB(200, 180, 255),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = PowerSection
        })

        local PktsLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.6, 0, 0, 8),
            Size = UDim2.new(0.4, -12, 0, 22),
            Font = UI_CONFIG.Font,
            Text = "0/s",
            TextColor3 = Color3.fromRGB(100, 200, 255),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = PowerSection
        })

        local SliderBg = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(10, 10, 15),
            Position = UDim2.new(0, 12, 0, 38),
            Size = UDim2.new(1, -24, 0, 18),
            Parent = PowerSection
        }, { Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

        local SliderFill = Create("Frame", {
            BackgroundColor3 = UI_CONFIG.AccentColor,
            Size = UDim2.new(0.2, 0, 1, 0),
            Parent = SliderBg
        }, { Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

        local SliderKnob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(20, 15, 30),
            Position = UDim2.new(1, -10, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18),
            Parent = SliderFill
        }, {
            Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
            Create("UIStroke", {Color = UI_CONFIG.AccentColor, Thickness = 1.5})
        })

        local draggingSlider = false
        local sliderValue = 0.2

        local function UpdateSlider(input)
            local relativeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            sliderValue = relativeX
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            
            local percent = math.floor(relativeX * 100)
            local packets = math.floor(relativeX * 10000)
            PowerLabel.Text = string.format("Power: %d%% (%d pkts)", percent, packets)
        end

        SliderBg.InputBegan:Connect(function(input)
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

        -- Lag & Stop Buttons
        local LagBtn = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(80, 50, 140),
            Size = UDim2.new(1, -24, 0, 45),
            Position = UDim2.new(0, 12, 0, 70),
            Font = UI_CONFIG.Font,
            Text = "Lag the Server!",
            TextColor3 = Color3.fromRGB(220, 220, 255),
            TextSize = 16,
            Parent = contentFrame
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Create("UIStroke", {Color = Color3.fromRGB(180, 100, 255), Thickness = 1.5})
        })

        local StopBtn = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(120, 40, 60),
            Size = UDim2.new(1, -24, 0, 45),
            Position = UDim2.new(0, 12, 0, 125),
            Font = UI_CONFIG.Font,
            Text = "Stop the Spamming",
            TextColor3 = Color3.fromRGB(255, 220, 220),
            TextSize = 16,
            Parent = contentFrame
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Create("UIStroke", {Color = Color3.fromRGB(220, 80, 100), Thickness = 1.5})
        })

        local LagEnabled = false

        LagBtn.MouseButton1Click:Connect(function()
            LagEnabled = true
            LagBtn.Text = "Lagging..."
        end)

        StopBtn.MouseButton1Click:Connect(function()
            LagEnabled = false
            LagBtn.Text = "Lag the Server!"
            PktsLabel.Text = "0/s"
        end)

        -- Simple fake packet counter animation
        task.spawn(function()
            while true do
                if LagEnabled then
                    local base = math.floor(sliderValue * 10000)
                    PktsLabel.Text = tostring(base + math.random(-300, 300)) .. "/s"
                else
                    PktsLabel.Text = "0/s"
                end
                task.wait(0.12)
            end
        end)
    end

    -- (Your original Main, Player, Visual tab contents go here - unchanged)
    -- ... paste your existing tab content code for "Main", "Player", "Visual" ...
end

-- Tab switching
local function switchTab(tabName)
    for name, button in pairs(tabButtons) do
        button.BackgroundColor3 = (name == tabName) and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(50, 50, 50)
        button.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
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

print("einxrxs-scripts + BK Lagger loaded!")
