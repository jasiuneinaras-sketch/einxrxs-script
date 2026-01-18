-- einxrxs-scripts | Ar1se Hub X Aezy style GUI
-- Last update: January 2026 vibe

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "einxrxsGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Minimalist square menu button
local squareButton = Instance.new("TextButton")
squareButton.Name = "MenuButton"
squareButton.Size = UDim2.new(0, 50, 0, 50)
squareButton.Position = UDim2.new(0, 15, 0.25, 0)
squareButton.BackgroundColor3 = Color3.fromRGB(79, 70, 229) -- nice indigo
squareButton.Text = ""
squareButton.Parent = screenGui

local squareCorner = Instance.new("UICorner")
squareCorner.CornerRadius = UDim.new(0, 10)
squareCorner.Parent = squareButton

local squareIcon = Instance.new("TextLabel")
squareIcon.Size = UDim2.new(1, 0, 1, 0)
squareIcon.BackgroundTransparency = 1
squareIcon.Text = "E"
squareIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
squareIcon.Font = Enum.Font.GothamBlack
squareIcon.TextSize = 28
squareIcon.Parent = squareButton

-- ──────────────────────────────────────────────────────────────
--                      MAIN PANEL
-- ──────────────────────────────────────────────────────────────

local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainFrame"
mainPanel.Size = UDim2.new(0, 320, 0, 380)
mainPanel.Position = UDim2.new(1, -335, 0.5, -190)
mainPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
mainPanel.Visible = false
mainPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = mainPanel

-- Dragging system
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainPanel.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainPanel

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -20, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "einxrxs-scripts"
titleText.TextColor3 = Color3.fromRGB(139, 92, 246) -- nice purple accent
titleText.Font = Enum.Font.GothamBlack
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Center
titleText.Parent = titleBar

-- Dragging logic
titleBar.InputBegan:Connect(function(input)
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

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Tab system
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabBar"
tabContainer.Size = UDim2.new(1, 0, 0, 48)
tabContainer.Position = UDim2.new(0, 0, 0, 42)
tabContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainPanel

local tabs = {"Main", "Player", "Visual"}
local tabButtons = {}
local contentFrames = {}

-- (The rest of the modules remain almost the same — only name & branding changes)

-- You can keep all the modules (ANTI_RAGDOLL, FLOOR_STEAL, INVISIBLE_WALLS, etc.)
-- just change prints / names if you want

-- Example of changed prints:
-- print("→ einxrxs-scripts | Anti Ragdoll → Activated (v1)")
-- print("→ einxrxs-scripts | 3rd Floor Steal Platform → Created")

-- At the very end instead of:
-- print("GUI Loaded Successfully!")

print("einxrxs-scripts loaded | enjoy your session ツ")

-- ... keep the rest of the code the same (tab creation, buttons, connections, etc.)

-- Just remember to change at least these places for better feeling of "new script":
-- • GUI name → "einxrxsGUI"
-- • Title text → "einxrxs-scripts"
-- • Button accent color (optional)
-- • Square button text/icon (currently "E")
-- • Some prints / notifications

-- Good luck & have fun!
