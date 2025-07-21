local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local function saveSettings()
    local settings = {
        wallhopEnabled = wallhopEnabled,
        infJumpEnabled = infJumpEnabled,
        autoWallhopEnabled = autoWallhopEnabled,
        waitTime = waitTime,
        flickStrength = flickStrength,
        flickType = flickType,
        wallhopBoundKey = wallhopBoundKey and wallhopBoundKey.Name or nil,
        infJumpBoundKey = infJumpBoundKey and infJumpBoundKey.Name or nil,
        wallhopMode = wallhopMode
    }
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONEncode(settings)
    end)
    if success then
        LocalPlayer:SetAttribute("WallhopSettings", result)
    end
end
local function loadSettings()
    local settingsJson = LocalPlayer:GetAttribute("WallhopSettings")
    if not settingsJson then return end
    local success, settings = pcall(function()
        return game:GetService("HttpService"):JSONDecode(settingsJson)
    end)
    if success then
        waitTime = settings.waitTime or 0.06
        flickStrength = settings.flickStrength or 1.5
        wallhopEnabled = settings.wallhopEnabled or false
        infJumpEnabled = settings.infJumpEnabled or false
        autoWallhopEnabled = settings.autoWallhopEnabled or false
        flickType = settings.flickType or "camera"
        wallhopMode = settings.wallhopMode or 0
        if settings.wallhopBoundKey then
            wallhopBoundKey = Enum.KeyCode[settings.wallhopBoundKey]
        end
        if settings.infJumpBoundKey then
            infJumpBoundKey = Enum.KeyCode[settings.infJumpBoundKey]
        end
    end
end
local waitTime = 0.06
local flickStrength = 1.5
local wallhopEnabled = false
local infJumpEnabled = false
local autoWallhopEnabled = false
local wallhopBoundKey = nil
local infJumpBoundKey = nil
local jumpKeyHeld = false
local lastJumpTime = 0
local flickType = "camera"
local currentTab = "Main"
local wallhopMode = 0 
local lastWallhopTime = 0
local isWallhopping = false
local wallCheckCooldown = 0.3 
local flickTypes = {"Camera Only", "Character Only"}
local flickTypeIndex = 1
local flickTypeValues = {"camera", "character"}
local wallhopModes = {"Classic", "Mode ray"}
loadSettings()
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WallhopGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local function createHoverEffect(button)
    local originalColor = button.BackgroundColor3
    local hoverColor = Color3.new(
        math.min(originalColor.R + 0.1, 1),
        math.min(originalColor.G + 0.1, 1),
        math.min(originalColor.B + 0.1, 1)
    )
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)
end
local hub = Instance.new("Frame")
hub.Name = "MainHub"
hub.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
hub.BackgroundTransparency = 0.1
hub.Position = UDim2.new(0.5, -175, 0.5, -150)
hub.Size = UDim2.new(0, 350, 0, 300)
hub.Active = true
hub.Draggable = false
hub.Parent = screenGui
local hubCorner = Instance.new("UICorner")
hubCorner.CornerRadius = UDim.new(0, 8)
hubCorner.Parent = hub
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = -1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.Parent = hub
local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
header.Size = UDim2.new(1, 0, 0, 30)
header.Parent = hub
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header
local headerClip = Instance.new("Frame")
headerClip.Name = "HeaderClip"
headerClip.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
headerClip.Position = UDim2.new(0, 0, 0.5, 0)
headerClip.Size = UDim2.new(1, 0, 0.5, 0)
headerClip.BorderSizePixel = 0
headerClip.Parent = header
local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(1, -50, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Wallhop Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.BackgroundTransparency = 1
minimizeButton.Position = UDim2.new(1, -60, 0, 0)
minimizeButton.Size = UDim2.new(0, 30, 1, 0)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 20
minimizeButton.Parent = header
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.BackgroundTransparency = 1
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Parent = header
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.BackgroundTransparency = 1
mainContainer.Position = UDim2.new(0, 0, 0, 30)
mainContainer.Size = UDim2.new(1, 0, 1, -30)
mainContainer.Parent = hub
local tabArea = Instance.new("Frame")
tabArea.Name = "TabArea"
tabArea.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabArea.Position = UDim2.new(0, 0, 0, 0)
tabArea.Size = UDim2.new(0.2, 0, 1, 0)
tabArea.Parent = mainContainer
local tabAreaCorner = Instance.new("UICorner")
tabAreaCorner.CornerRadius = UDim.new(0, 8)
tabAreaCorner.Parent = tabArea
local tabAreaClip = Instance.new("Frame")
tabAreaClip.Name = "TabAreaClip"
tabAreaClip.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabAreaClip.Position = UDim2.new(0.5, 0, 0, 0)
tabAreaClip.Size = UDim2.new(0.5, 0, 1, 0)
tabAreaClip.BorderSizePixel = 0
tabAreaClip.Parent = tabArea
local mainTabButton = Instance.new("TextButton")
mainTabButton.Name = "MainTabButton"
mainTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
mainTabButton.Position = UDim2.new(0, 5, 0, 10)
mainTabButton.Size = UDim2.new(1, -10, 0, 25)
mainTabButton.Font = Enum.Font.GothamSemibold
mainTabButton.Text = "Main"
mainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTabButton.TextSize = 14
mainTabButton.Parent = tabArea
local mainTabCorner = Instance.new("UICorner")
mainTabCorner.CornerRadius = UDim.new(0, 6)
mainTabCorner.Parent = mainTabButton
local settingsTabButton = Instance.new("TextButton")
settingsTabButton.Name = "SettingsTabButton"
settingsTabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
settingsTabButton.Position = UDim2.new(0, 5, 0, 45)
settingsTabButton.Size = UDim2.new(1, -10, 0, 25)
settingsTabButton.Font = Enum.Font.GothamSemibold
settingsTabButton.Text = "Settings"
settingsTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
settingsTabButton.TextSize = 14
settingsTabButton.Parent = tabArea
local settingsTabCorner = Instance.new("UICorner")
settingsTabCorner.CornerRadius = UDim.new(0, 6)
settingsTabCorner.Parent = settingsTabButton
local scriptsTabButton = Instance.new("TextButton")
scriptsTabButton.Name = "ScriptsTabButton"
scriptsTabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
scriptsTabButton.Position = UDim2.new(0, 5, 0, 80)
scriptsTabButton.Size = UDim2.new(1, -10, 0, 25)
scriptsTabButton.Font = Enum.Font.GothamSemibold
scriptsTabButton.Text = "Scripts"
scriptsTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
scriptsTabButton.TextSize = 14
scriptsTabButton.Parent = tabArea
local scriptsTabCorner = Instance.new("UICorner")
scriptsTabCorner.CornerRadius = UDim.new(0, 6)
scriptsTabCorner.Parent = scriptsTabButton
createHoverEffect(mainTabButton)
createHoverEffect(settingsTabButton)
createHoverEffect(scriptsTabButton)
local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
divider.BorderSizePixel = 0
divider.Position = UDim2.new(0.2, 0, 0, 0)
divider.Size = UDim2.new(0, 1, 1, 0)
divider.Parent = mainContainer
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.BackgroundTransparency = 1
contentArea.Position = UDim2.new(0.2, 1, 0, 0)
contentArea.Size = UDim2.new(0.8, -1, 1, 0)
contentArea.Parent = mainContainer
local mainTab = Instance.new("ScrollingFrame")
mainTab.Name = "MainTab"
mainTab.BackgroundTransparency = 1
mainTab.BorderSizePixel = 0
mainTab.Position = UDim2.new(0, 0, 0, 0)
mainTab.Size = UDim2.new(1, 0, 1, 0)
mainTab.CanvasSize = UDim2.new(0, 0, 0, 300)
mainTab.ScrollBarThickness = 4
mainTab.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 75)
mainTab.Visible = true
mainTab.Parent = contentArea
local settingsTab = Instance.new("ScrollingFrame")
settingsTab.Name = "SettingsTab"
settingsTab.BackgroundTransparency = 1
settingsTab.BorderSizePixel = 0
settingsTab.Position = UDim2.new(0, 0, 0, 0)
settingsTab.Size = UDim2.new(1, 0, 1, 0)
settingsTab.CanvasSize = UDim2.new(0, 0, 0, 300)
settingsTab.ScrollBarThickness = 4
settingsTab.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 75)
settingsTab.Visible = false
settingsTab.Parent = contentArea
local scriptsTab = Instance.new("ScrollingFrame")
scriptsTab.Name = "ScriptsTab"
scriptsTab.BackgroundTransparency = 1
scriptsTab.BorderSizePixel = 0
scriptsTab.Position = UDim2.new(0, 0, 0, 0)
scriptsTab.Size = UDim2.new(1, 0, 1, 0)
scriptsTab.CanvasSize = UDim2.new(0, 0, 0, 300)
scriptsTab.ScrollBarThickness = 4
scriptsTab.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 75)
scriptsTab.Visible = false
scriptsTab.Parent = contentArea
local wallhopTitle = Instance.new("TextLabel")
wallhopTitle.Name = "WallhopTitle"
wallhopTitle.BackgroundTransparency = 1
wallhopTitle.Position = UDim2.new(0, 15, 0, 10)
wallhopTitle.Size = UDim2.new(1, -30, 0, 20)
wallhopTitle.Font = Enum.Font.GothamBold
wallhopTitle.Text = "Wallhop"
wallhopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
wallhopTitle.TextSize = 16
wallhopTitle.TextXAlignment = Enum.TextXAlignment.Left
wallhopTitle.Parent = mainTab
local toggleWallhopButton = Instance.new("TextButton")
toggleWallhopButton.Name = "ToggleWallhop"
toggleWallhopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
toggleWallhopButton.Position = UDim2.new(0, 15, 0, 35)
toggleWallhopButton.Size = UDim2.new(1, -30, 0, 30)
toggleWallhopButton.Font = Enum.Font.Gotham
toggleWallhopButton.Text = "Toggle Wallhop: OFF"
toggleWallhopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleWallhopButton.TextSize = 14
toggleWallhopButton.Parent = mainTab
local toggleWallhopCorner = Instance.new("UICorner")
toggleWallhopCorner.CornerRadius = UDim.new(0, 6)
toggleWallhopCorner.Parent = toggleWallhopButton
local autoWallhopButton = Instance.new("TextButton")
autoWallhopButton.Name = "AutoWallhopButton"
autoWallhopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
autoWallhopButton.Position = UDim2.new(0, 15, 0, 75)
autoWallhopButton.Size = UDim2.new(1, -30, 0, 30)
autoWallhopButton.Font = Enum.Font.Gotham
autoWallhopButton.Text = "Auto Wallhop: OFF"
autoWallhopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoWallhopButton.TextSize = 14
autoWallhopButton.Parent = mainTab
local autoWallhopCorner = Instance.new("UICorner")
autoWallhopCorner.CornerRadius = UDim.new(0, 6)
autoWallhopCorner.Parent = autoWallhopButton
createHoverEffect(autoWallhopButton)
local wallhopModeButton = Instance.new("TextButton")
wallhopModeButton.Name = "WallhopModeButton"
wallhopModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
wallhopModeButton.Position = UDim2.new(0, 15, 0, 115)
wallhopModeButton.Size = UDim2.new(1, -30, 0, 30)
wallhopModeButton.Font = Enum.Font.Gotham
wallhopModeButton.Text = "Auto Wallhop Mode: " .. wallhopModes[wallhopMode + 1]
wallhopModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
wallhopModeButton.TextSize = 14
wallhopModeButton.Parent = mainTab
local wallhopModeCorner = Instance.new("UICorner")
wallhopModeCorner.CornerRadius = UDim.new(0, 6)
wallhopModeCorner.Parent = wallhopModeButton
createHoverEffect(wallhopModeButton)
local separator1 = Instance.new("Frame")
separator1.Name = "Separator1"
separator1.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
separator1.BorderSizePixel = 0
separator1.Position = UDim2.new(0, 15, 0, 155)
separator1.Size = UDim2.new(1, -30, 0, 1)
separator1.Parent = mainTab
local infJumpTitle = Instance.new("TextLabel")
infJumpTitle.Name = "InfJumpTitle"
infJumpTitle.BackgroundTransparency = 1
infJumpTitle.Position = UDim2.new(0, 15, 0, 165)
infJumpTitle.Size = UDim2.new(1, -30, 0, 20)
infJumpTitle.Font = Enum.Font.GothamBold
infJumpTitle.Text = "Infinite Jump"
infJumpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
infJumpTitle.TextSize = 16
infJumpTitle.TextXAlignment = Enum.TextXAlignment.Left
infJumpTitle.Parent = mainTab
local toggleInfJumpButton = Instance.new("TextButton")
toggleInfJumpButton.Name = "ToggleInfJump"
toggleInfJumpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
toggleInfJumpButton.Position = UDim2.new(0, 15, 0, 190)
toggleInfJumpButton.Size = UDim2.new(1, -30, 0, 30)
toggleInfJumpButton.Font = Enum.Font.Gotham
toggleInfJumpButton.Text = "Toggle Inf Jump: OFF"
toggleInfJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleInfJumpButton.TextSize = 14
toggleInfJumpButton.Parent = mainTab
local toggleInfJumpCorner = Instance.new("UICorner")
toggleInfJumpCorner.CornerRadius = UDim.new(0, 6)
toggleInfJumpCorner.Parent = toggleInfJumpButton
local separator2 = Instance.new("Frame")
separator2.Name = "Separator2"
separator2.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
separator2.BorderSizePixel = 0
separator2.Position = UDim2.new(0, 15, 0, 230)
separator2.Size = UDim2.new(1, -30, 0, 1)
separator2.Parent = mainTab
local keybindsTitle = Instance.new("TextLabel")
keybindsTitle.Name = "KeybindsTitle"
keybindsTitle.BackgroundTransparency = 1
keybindsTitle.Position = UDim2.new(0, 15, 0, 240)
keybindsTitle.Size = UDim2.new(1, -30, 0, 20)
keybindsTitle.Font = Enum.Font.GothamBold
keybindsTitle.Text = "Keybinds"
keybindsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindsTitle.TextSize = 16
keybindsTitle.TextXAlignment = Enum.TextXAlignment.Left
keybindsTitle.Parent = mainTab
local keybindButton = Instance.new("TextButton")
keybindButton.Name = "WallhopKeybind"
keybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
keybindButton.Position = UDim2.new(0, 15, 0, 265)
keybindButton.Size = UDim2.new(1, -30, 0, 30)
keybindButton.Font = Enum.Font.Gotham
keybindButton.Text = "Wallhop Keybind: None"
keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindButton.TextSize = 14
keybindButton.Parent = mainTab
local keybindCorner = Instance.new("UICorner")
keybindCorner.CornerRadius = UDim.new(0, 6)
keybindCorner.Parent = keybindButton
local infJumpKeybindButton = Instance.new("TextButton")
infJumpKeybindButton.Name = "InfJumpKeybind"
infJumpKeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
infJumpKeybindButton.Position = UDim2.new(0, 15, 0, 305)
infJumpKeybindButton.Size = UDim2.new(1, -30, 0, 30)
infJumpKeybindButton.Font = Enum.Font.Gotham
infJumpKeybindButton.Text = "InfJump Keybind: None"
infJumpKeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
infJumpKeybindButton.TextSize = 14
infJumpKeybindButton.Parent = mainTab
local infJumpKeybindCorner = Instance.new("UICorner")
infJumpKeybindCorner.CornerRadius = UDim.new(0, 6)
infJumpKeybindCorner.Parent = infJumpKeybindButton
local flickSettingsTitle = Instance.new("TextLabel")
flickSettingsTitle.Name = "FlickSettingsTitle"
flickSettingsTitle.BackgroundTransparency = 1
flickSettingsTitle.Position = UDim2.new(0, 15, 0, 10)
flickSettingsTitle.Size = UDim2.new(1, -30, 0, 20)
flickSettingsTitle.Font = Enum.Font.GothamBold
flickSettingsTitle.Text = "Flick Settings"
flickSettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
flickSettingsTitle.TextSize = 16
flickSettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
flickSettingsTitle.Parent = settingsTab
local flickTypeLabel = Instance.new("TextLabel")
flickTypeLabel.Name = "FlickTypeLabel"
flickTypeLabel.BackgroundTransparency = 1
flickTypeLabel.Position = UDim2.new(0, 15, 0, 35)
flickTypeLabel.Size = UDim2.new(0.4, -20, 0, 20)
flickTypeLabel.Font = Enum.Font.Gotham
flickTypeLabel.Text = "Flick Type:"
flickTypeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
flickTypeLabel.TextSize = 14
flickTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
flickTypeLabel.Parent = settingsTab
local flickTypeButton = Instance.new("TextButton")
flickTypeButton.Name = "FlickTypeButton"
flickTypeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
flickTypeButton.Position = UDim2.new(0.4, 0, 0, 35)
flickTypeButton.Size = UDim2.new(0.6, -15, 0, 25)
flickTypeButton.Font = Enum.Font.Gotham
flickTypeButton.Text = flickTypes[flickTypeIndex]
flickTypeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flickTypeButton.TextSize = 14
flickTypeButton.Parent = settingsTab
local flickTypeCorner = Instance.new("UICorner")
flickTypeCorner.CornerRadius = UDim.new(0, 6)
flickTypeCorner.Parent = flickTypeButton
local flickStrengthLabel = Instance.new("TextLabel")
flickStrengthLabel.Name = "FlickStrengthLabel"
flickStrengthLabel.BackgroundTransparency = 1
flickStrengthLabel.Position = UDim2.new(0, 15, 0, 70)
flickStrengthLabel.Size = UDim2.new(1, -30, 0, 20)
flickStrengthLabel.Font = Enum.Font.Gotham
flickStrengthLabel.Text = "Flick Strength: " .. string.format("%.1f", flickStrength)
flickStrengthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
flickStrengthLabel.TextSize = 14
flickStrengthLabel.TextXAlignment = Enum.TextXAlignment.Left
flickStrengthLabel.Parent = settingsTab
local flickStrengthSlider = Instance.new("Frame")
flickStrengthSlider.Name = "FlickStrengthSlider"
flickStrengthSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
flickStrengthSlider.Position = UDim2.new(0, 15, 0, 95)
flickStrengthSlider.Size = UDim2.new(1, -30, 0, 6)
flickStrengthSlider.Parent = settingsTab
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 3)
sliderCorner.Parent = flickStrengthSlider
local flickStrengthKnob = Instance.new("Frame")
flickStrengthKnob.Name = "FlickStrengthKnob"
flickStrengthKnob.BackgroundColor3 = Color3.fromRGB(220, 220, 225)
flickStrengthKnob.Position = UDim2.new((flickStrength - 1) / 4, -6, 0, -4)
flickStrengthKnob.Size = UDim2.new(0, 16, 0, 16)
flickStrengthKnob.ZIndex = 2
flickStrengthKnob.Parent = flickStrengthSlider
local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = flickStrengthKnob
local waitLabel = Instance.new("TextLabel")
waitLabel.Name = "WaitLabel"
waitLabel.BackgroundTransparency = 1
waitLabel.Position = UDim2.new(0, 15, 0, 120)
waitLabel.Size = UDim2.new(0.4, -20, 0, 20)
waitLabel.Font = Enum.Font.Gotham
waitLabel.Text = "Wait Time:"
waitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
waitLabel.TextSize = 14
waitLabel.TextXAlignment = Enum.TextXAlignment.Left
waitLabel.Parent = settingsTab
local waitBox = Instance.new("TextBox")
waitBox.Name = "WaitBox"
waitBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
waitBox.Position = UDim2.new(0.4, 0, 0, 120)
waitBox.Size = UDim2.new(0.2, -10, 0, 25)
waitBox.Font = Enum.Font.Gotham
waitBox.Text = tostring(waitTime)
waitBox.TextColor3 = Color3.fromRGB(255, 255, 255)
waitBox.TextSize = 14
waitBox.PlaceholderText = "0.06"
waitBox.ClearTextOnFocus = false
waitBox.Parent = settingsTab
local waitBoxCorner = Instance.new("UICorner")
waitBoxCorner.CornerRadius = UDim.new(0, 6)
waitBoxCorner.Parent = waitBox
local waitHint = Instance.new("TextLabel")
waitHint.Name = "WaitHint"
waitHint.BackgroundTransparency = 1
waitHint.Position = UDim2.new(0.6, 0, 0, 120)
waitHint.Size = UDim2.new(0.4, -15, 0, 25)
waitHint.Font = Enum.Font.Gotham
waitHint.Text = "(0.09 for legit)"
waitHint.TextColor3 = Color3.fromRGB(150, 150, 150)
waitHint.TextSize = 12
waitHint.TextXAlignment = Enum.TextXAlignment.Left
waitHint.Parent = settingsTab
local separator3 = Instance.new("Frame")
separator3.Name = "Separator3"
separator3.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
separator3.BorderSizePixel = 0
separator3.Position = UDim2.new(0, 15, 0, 155)
separator3.Size = UDim2.new(1, -30, 0, 1)
separator3.Parent = settingsTab
local configTitle = Instance.new("TextLabel")
configTitle.Name = "ConfigTitle"
configTitle.BackgroundTransparency = 1
configTitle.Position = UDim2.new(0, 15, 0, 165)
configTitle.Size = UDim2.new(1, -30, 0, 20)
configTitle.Font = Enum.Font.GothamBold
configTitle.Text = "Configuration"
configTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
configTitle.TextSize = 16
configTitle.TextXAlignment = Enum.TextXAlignment.Left
configTitle.Parent = settingsTab
local saveButton = Instance.new("TextButton")
saveButton.Name = "SaveButton"
saveButton.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
saveButton.Position = UDim2.new(0, 15, 0, 190)
saveButton.Size = UDim2.new(0.5, -20, 0, 30)
saveButton.Font = Enum.Font.GothamSemibold
saveButton.Text = "Save Settings"
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.TextSize = 14
saveButton.Parent = settingsTab
local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = saveButton
local resetButton = Instance.new("TextButton")
resetButton.Name = "ResetButton"
resetButton.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
resetButton.Position = UDim2.new(0.5, 5, 0, 190)
resetButton.Size = UDim2.new(0.5, -20, 0, 30)
resetButton.Font = Enum.Font.GothamSemibold
resetButton.Text = "Reset Settings"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextSize = 14
resetButton.Parent = settingsTab
local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetButton
local separator4 = Instance.new("Frame")
separator4.Name = "Separator4"
separator4.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
separator4.BorderSizePixel = 0
separator4.Position = UDim2.new(0, 15, 0, 230)
separator4.Size = UDim2.new(1, -30, 0, 1)
separator4.Parent = settingsTab
local discordButton = Instance.new("TextButton")
discordButton.Name = "DiscordButton"
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) 
discordButton.Position = UDim2.new(0, 15, 0, 240)
discordButton.Size = UDim2.new(1, -30, 0, 30)
discordButton.Font = Enum.Font.GothamSemibold
discordButton.Text = "Copy Discord Link"
discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
discordButton.TextSize = 14
discordButton.Parent = settingsTab
local discordCorner = Instance.new("UICorner")
discordCorner.CornerRadius = UDim.new(0, 6)
discordCorner.Parent = discordButton
createHoverEffect(toggleWallhopButton)
createHoverEffect(toggleInfJumpButton)
createHoverEffect(keybindButton)
createHoverEffect(infJumpKeybindButton)
createHoverEffect(flickTypeButton)
createHoverEffect(saveButton)
createHoverEffect(resetButton)
createHoverEffect(discordButton)
if wallhopEnabled then
    toggleWallhopButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    toggleWallhopButton.Text = "Toggle Wallhop: ON"
end
if infJumpEnabled then
    toggleInfJumpButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    toggleInfJumpButton.Text = "Toggle Inf Jump: ON"
end
if wallhopBoundKey then
    keybindButton.Text = "Wallhop Keybind: " .. wallhopBoundKey.Name
end
if infJumpBoundKey then
    infJumpKeybindButton.Text = "InfJump Keybind: " .. infJumpBoundKey.Name
end
local function performWallhop()
    local character = LocalPlayer.Character
    if not character then return end
    wallhopEnabled = false
    local originalCameraCFrame = workspace.CurrentCamera.CFrame
    if flickType == "camera" or flickType == "both" then
        local origCFrame = workspace.CurrentCamera.CFrame
        local baseAngle = 15 
        local forceMultiplier = 6 
        local maxAngle = 30 
        local angle1 = math.rad(baseAngle + math.min(flickStrength * forceMultiplier, maxAngle))
        workspace.CurrentCamera.CFrame = origCFrame * CFrame.Angles(0, angle1, 0)
        wait(waitTime / 3)
        local angle2 = math.rad(-(baseAngle + math.min(flickStrength * forceMultiplier, maxAngle)))
        workspace.CurrentCamera.CFrame = origCFrame * CFrame.Angles(0, angle2, 0)
        wait(waitTime / 3)
        workspace.CurrentCamera.CFrame = origCFrame
        wait(waitTime / 3)
    end
    if flickType == "character" or flickType == "both" then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local originalCFrame = rootPart.CFrame
                local originalAutoRotate = humanoid.AutoRotate
                humanoid.AutoRotate = false
                local rotationAngle = math.rad(40 + (flickStrength * 8)) 
                rootPart.CFrame = originalCFrame * CFrame.Angles(0, rotationAngle, 0)
                wait(waitTime / 3)
                rootPart.CFrame = originalCFrame * CFrame.Angles(0, -rotationAngle, 0)
                wait(waitTime / 3)
                rootPart.CFrame = originalCFrame
                humanoid.AutoRotate = originalAutoRotate
                wait(waitTime / 3)
            end
        end
    end
    wallhopEnabled = true
end
local function onJumpRequest()
    if wallhopEnabled then
        performWallhop()
    end
    if infJumpEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local currentTime = tick()
                local isGrounded = humanoid:GetState() == Enum.HumanoidStateType.Landed or 
                                  humanoid:GetState() == Enum.HumanoidStateType.Running or 
                                  humanoid:GetState() == Enum.HumanoidStateType.GettingUp or 
                                  humanoid:GetState() == Enum.HumanoidStateType.Swimming
                local canJump = jumpKeyPressed or (currentTime - lastJumpTime > 0.3)
                if canJump then
                    jumpKeyPressed = false
                    lastJumpTime = currentTime
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end
local isWallhopping = false
local lastWallhopTime = 0
local wallCheckDistance = 4.5  
local wallCheckCooldown = 0.12 
local function isNearWallClassic()
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local velocity = humanoidRootPart.Velocity
    local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    if horizontalVelocity < 2 then return false end
    local moveDirection = Vector3.new(velocity.X, 0, velocity.Z).Unit
    local rightDirection = Vector3.new(-moveDirection.Z, 0, moveDirection.X)
    local directions = {
        moveDirection,                
        rightDirection,               
        -rightDirection,              
        -moveDirection                
    }
    local distances = {
        wallCheckDistance * 0.7,      
        wallCheckDistance,            
        wallCheckDistance,            
        wallCheckDistance * 0.5       
    }
    for i, direction in ipairs(directions) do
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = workspace:Raycast(
            humanoidRootPart.Position,
            direction * distances[i],
            raycastParams
        )
        if raycastResult then
            local dot = raycastResult.Normal:Dot(Vector3.new(0, 1, 0))
            if math.abs(dot) < 0.3 then
                local distance = (raycastResult.Position - humanoidRootPart.Position).Magnitude
                if distance < wallCheckDistance * 0.8 then
                    return true, raycastResult.Normal
                end
            end
        end
    end
    return false
end
local function isNearWallModeRay()
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local velocity = humanoidRootPart.Velocity
    local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    if horizontalVelocity < 2 then return false end
    local camera = workspace.CurrentCamera
    local camLook = camera.CFrame.LookVector
    local lookHorizontal = Vector3.new(camLook.X, 0, camLook.Z).Unit
    local directions = {
        lookHorizontal,                         
        Vector3.new(-lookHorizontal.Z, 0, lookHorizontal.X),  
        Vector3.new(lookHorizontal.Z, 0, -lookHorizontal.X),  
        -lookHorizontal                          
    }
    local distances = {
        wallCheckDistance * 1.0,      
        wallCheckDistance * 0.8,      
        wallCheckDistance * 0.8,      
        wallCheckDistance * 0.5       
    }
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    for i, direction in ipairs(directions) do
        local raycastResult = workspace:Raycast(
            humanoidRootPart.Position,
            direction * distances[i],
            raycastParams
        )
        if raycastResult then
            local normal = raycastResult.Normal
            local dotWithUp = normal:Dot(Vector3.new(0, 1, 0))
            if math.abs(dotWithUp) < 0.3 then
                local distance = (raycastResult.Position - humanoidRootPart.Position).Magnitude
                if distance < wallCheckDistance * 0.9 then
                    return true, normal
                end
            end
        end
    end
    return false
end
local function isNearWall()
    if wallhopMode == 0 then
        return isNearWallClassic()
    else
        return isNearWallModeRay()
    end
end
local function autoWallhop()
    if not autoWallhopEnabled or isWallhopping then return end
    local currentTime = tick()
    if currentTime - lastWallhopTime < 0.4 then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local isInAir = humanoid:GetState() == Enum.HumanoidStateType.Jumping or
                    humanoid:GetState() == Enum.HumanoidStateType.Freefall
    local wallDetected, wallNormal = isNearWall()
    if wallDetected then
        isWallhopping = true
        lastWallhopTime = currentTime
        local character = LocalPlayer.Character
        if not character then 
            isWallhopping = false
            return 
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then 
            isWallhopping = false
            return 
        end
        local camera = workspace.CurrentCamera
        local originalCameraCFrame = camera.CFrame
        local numFlicks = 1  
        for i = 1, numFlicks do
            local angleMultiplier = (i % 2 == 0) and 1 or -1
            local baseAngle = 20 
            local forceMultiplier = 7 
            local angle = math.rad(angleMultiplier * (baseAngle + math.min(flickStrength * forceMultiplier, 45)))
            camera.CFrame = originalCameraCFrame * CFrame.Angles(0, angle, 0)
            if flickType == "character" or flickType == "both" then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local originalCFrame = rootPart.CFrame
                    local originalAutoRotate = humanoid.AutoRotate
                    humanoid.AutoRotate = false
                    local rotationAngle = math.rad(angleMultiplier * (45 + (flickStrength * 10)))
                    rootPart.CFrame = originalCFrame * CFrame.Angles(0, rotationAngle, 0)
                    wait(waitTime / 3)
                    rootPart.CFrame = originalCFrame
                    humanoid.AutoRotate = originalAutoRotate
                end
            else
                wait(waitTime / 3)
            end
        end
        camera.CFrame = originalCameraCFrame
        wait(waitTime / 3)
        isWallhopping = false
    end
end
local isDraggingSlider = false
local function updateSliderPosition(input)
    local sliderPosition = math.clamp((input.Position.X - flickStrengthSlider.AbsolutePosition.X) / flickStrengthSlider.AbsoluteSize.X, 0, 1)
    flickStrengthKnob.Position = UDim2.new(sliderPosition, -6, 0, -4)
    flickStrength = 1.0 + (sliderPosition * 4.0)
    flickStrengthLabel.Text = "Flick Strength: " .. string.format("%.1f", flickStrength)
end
local function switchTab(tabName)
    currentTab = tabName
    mainTabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    settingsTabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    settingsTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    scriptsTabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    scriptsTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    mainTab.Visible = false
    settingsTab.Visible = false
    scriptsTab.Visible = false
    if tabName == "Main" then
        mainTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        mainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        mainTab.Visible = true
    elseif tabName == "Settings" then
        settingsTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        settingsTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        settingsTab.Visible = true
    elseif tabName == "Scripts" then
        scriptsTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        scriptsTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        scriptsTab.Visible = true
    end
end
local function toggleMinimize()
    local minimized = minimizeButton.Text == "-"
    local newSize
    local newText
    if minimized then
        newSize = UDim2.new(0, 350, 0, 30)
        newText = "+"
        contentArea.Visible = false
        tabArea.Visible = false
        divider.Visible = false
    else
        newSize = UDim2.new(0, 350, 0, 300)
        newText = "-"
        contentArea.Visible = true
        tabArea.Visible = true
        divider.Visible = true
    end
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hub, tweenInfo, { Size = newSize })
    tween:Play()
    minimizeButton.Text = newText
end
local function resetSettings()
    waitTime = 0.06
    flickStrength = 1.5
    wallhopEnabled = false
    infJumpEnabled = false
    autoWallhopEnabled = false
    flickType = "camera"
    flickTypeIndex = 1
    wallhopBoundKey = nil
    infJumpBoundKey = nil
    wallhopMode = 0  
    waitBox.Text = tostring(waitTime)
    flickStrengthLabel.Text = "Flick Strength: " .. string.format("%.1f", flickStrength)
    flickStrengthKnob.Position = UDim2.new(0.125, -6, 0, -4)
    flickTypeButton.Text = "Camera Only"
    toggleWallhopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggleWallhopButton.Text = "Toggle Wallhop: OFF"
    toggleInfJumpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggleInfJumpButton.Text = "Toggle Inf Jump: OFF"
    autoWallhopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    autoWallhopButton.Text = "Auto Wallhop: OFF"
    wallhopModeButton.Text = "Wallhop Mode: Classic"
    keybindButton.Text = "Wallhop Keybind: None"
    infJumpKeybindButton.Text = "InfJump Keybind: None"
    saveSettings()
end
local jumpKeyPressed = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
        jumpKeyHeld = true
        jumpKeyPressed = true  
        onJumpRequest()
    end
    if not gameProcessed then
        if wallhopBoundKey and input.KeyCode == wallhopBoundKey then
            wallhopEnabled = not wallhopEnabled
            toggleWallhopButton.Text = "Toggle Wallhop: " .. (wallhopEnabled and "ON" or "OFF")
            toggleWallhopButton.BackgroundColor3 = wallhopEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)
        end
        if infJumpBoundKey and input.KeyCode == infJumpBoundKey then
            infJumpEnabled = not infJumpEnabled
            toggleInfJumpButton.Text = "Toggle Inf Jump: " .. (infJumpEnabled and "ON" or "OFF")
            toggleInfJumpButton.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
        jumpKeyHeld = false
        lastJumpTime = tick()
    end
end)
UserInputService.JumpRequest:Connect(onJumpRequest)
mainTabButton.MouseButton1Click:Connect(function()
    switchTab("Main")
end)
settingsTabButton.MouseButton1Click:Connect(function()
    switchTab("Settings")
end)
scriptsTabButton.MouseButton1Click:Connect(function()
    switchTab("Scripts")
end)
minimizeButton.MouseButton1Click:Connect(toggleMinimize)
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
toggleWallhopButton.MouseButton1Click:Connect(function()
    wallhopEnabled = not wallhopEnabled
    toggleWallhopButton.Text = "Toggle Wallhop: " .. (wallhopEnabled and "ON" or "OFF")
    toggleWallhopButton.BackgroundColor3 = wallhopEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)
end)
autoWallhopButton.MouseButton1Click:Connect(function()
    autoWallhopEnabled = not autoWallhopEnabled
    autoWallhopButton.Text = "Auto Wallhop: " .. (autoWallhopEnabled and "ON" or "OFF")
    autoWallhopButton.BackgroundColor3 = autoWallhopEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)
end)
toggleInfJumpButton.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    toggleInfJumpButton.Text = "Toggle Inf Jump: " .. (infJumpEnabled and "ON" or "OFF")
    toggleInfJumpButton.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)
end)
wallhopModeButton.MouseButton1Click:Connect(function()
    wallhopMode = (wallhopMode + 1) % 2
    wallhopModeButton.Text = "Wallhop Mode: " .. wallhopModes[wallhopMode + 1]
    if wallhopMode == 0 then
        wallhopModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    else
        wallhopModeButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
    end
    saveSettings()
end)
keybindButton.MouseButton1Click:Connect(function()
    keybindButton.Text = "Press a key..."
    local binding = true
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if binding and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            wallhopBoundKey = input.KeyCode
            keybindButton.Text = "Wallhop Keybind: " .. wallhopBoundKey.Name
            binding = false
            connection:Disconnect()
        end
    end)
end)
infJumpKeybindButton.MouseButton1Click:Connect(function()
    infJumpKeybindButton.Text = "Press a key..."
    local binding = true
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if binding and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            infJumpBoundKey = input.KeyCode
            infJumpKeybindButton.Text = "InfJump Keybind: " .. infJumpBoundKey.Name
            binding = false
            connection:Disconnect()
        end
    end)
end)
flickStrengthSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = true
        updateSliderPosition(input)
    end
end)
flickStrengthKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDraggingSlider then
        isDraggingSlider = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSliderPosition(input)
    end
end)
flickTypeButton.MouseButton1Click:Connect(function()
    flickTypeIndex = (flickTypeIndex % #flickTypes) + 1
    flickTypeButton.Text = flickTypes[flickTypeIndex]
    flickType = flickTypeValues[flickTypeIndex]
end)
waitBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newWait = tonumber(waitBox.Text)
        if newWait and newWait > 0 then
            waitTime = newWait
        else
            waitBox.Text = tostring(waitTime)
        end
    end
end)
saveButton.MouseButton1Click:Connect(saveSettings)
resetButton.MouseButton1Click:Connect(resetSettings)
discordButton.MouseButton1Click:Connect(function()
    local discordLink = "https://discord.gg/seudiscord"
    local success = pcall(function()
        setclipboard(discordLink)
    end)
    local originalText = discordButton.Text
    local originalColor = discordButton.BackgroundColor3
    discordButton.Text = "Discord Link Copied!"
    discordButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
    delay(2, function()
        discordButton.Text = originalText
        discordButton.BackgroundColor3 = originalColor
    end)
end)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    hub.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = hub.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
local scriptsGroup = Instance.new("Frame")
scriptsGroup.Name = "ScriptsGroup"
scriptsGroup.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
scriptsGroup.Position = UDim2.new(0, 10, 0, 10)
scriptsGroup.Size = UDim2.new(1, -20, 0, 280)
scriptsGroup.Parent = scriptsTab
local scriptsGroupCorner = Instance.new("UICorner")
scriptsGroupCorner.CornerRadius = UDim.new(0, 6)
scriptsGroupCorner.Parent = scriptsGroup
local scriptsTitle = Instance.new("TextLabel")
scriptsTitle.Name = "ScriptsTitle"
scriptsTitle.BackgroundTransparency = 1
scriptsTitle.Position = UDim2.new(0, 10, 0, 5)
scriptsTitle.Size = UDim2.new(1, -20, 0, 20)
scriptsTitle.Font = Enum.Font.GothamSemibold
scriptsTitle.Text = "Execute Scripts"
scriptsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptsTitle.TextSize = 14
scriptsTitle.TextXAlignment = Enum.TextXAlignment.Left
scriptsTitle.Parent = scriptsGroup
local scriptTextBox = Instance.new("TextBox")
scriptTextBox.Name = "ScriptTextBox"
scriptTextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
scriptTextBox.Position = UDim2.new(0, 10, 0, 30)
scriptTextBox.Size = UDim2.new(1, -20, 0, 200)
scriptTextBox.Font = Enum.Font.Code
scriptTextBox.PlaceholderText = "Paste your script here..."
scriptTextBox.Text = ""
scriptTextBox.TextColor3 = Color3.fromRGB(200, 200, 200)
scriptTextBox.TextSize = 14
scriptTextBox.ClearTextOnFocus = false
scriptTextBox.TextXAlignment = Enum.TextXAlignment.Left
scriptTextBox.TextYAlignment = Enum.TextYAlignment.Top
scriptTextBox.TextWrapped = true
scriptTextBox.MultiLine = true
scriptTextBox.Parent = scriptsGroup
local scriptBoxCorner = Instance.new("UICorner")
scriptBoxCorner.CornerRadius = UDim.new(0, 6)
scriptBoxCorner.Parent = scriptTextBox
local executeButton = Instance.new("TextButton")
executeButton.Name = "ExecuteButton"
executeButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
executeButton.Position = UDim2.new(0, 10, 0, 240)
executeButton.Size = UDim2.new(1, -20, 0, 30)
executeButton.Font = Enum.Font.GothamSemibold
executeButton.Text = "Execute Script"
executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
executeButton.TextSize = 14
executeButton.Parent = scriptsGroup
local executeButtonCorner = Instance.new("UICorner")
executeButtonCorner.CornerRadius = UDim.new(0, 6)
executeButtonCorner.Parent = executeButton
executeButton.MouseButton1Click:Connect(function()
    local scriptText = scriptTextBox.Text
    if scriptText and scriptText ~= "" then
        local originalText = executeButton.Text
        local originalColor = executeButton.BackgroundColor3
        executeButton.Text = "Executing..."
        executeButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
        local success, errorMsg = pcall(function()
            loadstring(scriptText)()
        end)
        if success then
            executeButton.Text = "Executed Successfully!"
            executeButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
        else
            executeButton.Text = "Error: Check Console (F9)"
            executeButton.BackgroundColor3 = Color3.fromRGB(179, 60, 60)
            warn("Script execution error: " .. tostring(errorMsg))
        end
        delay(2, function()
            executeButton.Text = originalText
            executeButton.BackgroundColor3 = originalColor
        end)
    end
end)
loadSettings()
if autoWallhopEnabled then
    autoWallhopButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    autoWallhopButton.Text = "Auto Wallhop: ON"
end
wallhopModeButton.Text = "Wallhop Mode: " .. wallhopModes[wallhopMode + 1]
if wallhopMode == 1 then 
    wallhopModeButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
end
local isWallNearby = false
local visualFeedbackActive = false
local wallNearbyFrame = nil
local function createWallDetectionFeedback()
    if wallNearbyFrame then return end
    wallNearbyFrame = Instance.new("Frame")
    wallNearbyFrame.Size = UDim2.new(0, 10, 0, 10)
    wallNearbyFrame.Position = UDim2.new(0, 15, 0, 15)
    wallNearbyFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    wallNearbyFrame.BorderSizePixel = 0
    wallNearbyFrame.Visible = false
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 5)
    uiCorner.Parent = wallNearbyFrame
    wallNearbyFrame.Parent = screenGui
end
local function updateWallDetectionFeedback()
    if not wallNearbyFrame then
        createWallDetectionFeedback()
    end
    if isWallNearby and not visualFeedbackActive then
        visualFeedbackActive = true
        wallNearbyFrame.Visible = true
        wallNearbyFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        spawn(function()
            for i = 1, 3 do
                local targetSize = UDim2.new(0, 12, 0, 12)
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                local tween = TweenService:Create(wallNearbyFrame, tweenInfo, {Size = targetSize})
                tween:Play()
                wait(0.2)
                local originalSize = UDim2.new(0, 10, 0, 10)
                local tween2 = TweenService:Create(wallNearbyFrame, tweenInfo, {Size = originalSize})
                tween2:Play()
                wait(0.2)
            end
        end)
    elseif not isWallNearby and visualFeedbackActive then
        visualFeedbackActive = false
        wallNearbyFrame.Visible = false
    end
end
RunService.RenderStepped:Connect(function()
    if autoWallhopEnabled then
        isWallNearby = isNearWall()
        updateWallDetectionFeedback()
        autoWallhop()
    else
        if wallNearbyFrame and wallNearbyFrame.Visible then
            wallNearbyFrame.Visible = false
            visualFeedbackActive = false
        end
    end
end)