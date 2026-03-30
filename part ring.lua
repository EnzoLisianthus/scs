---------------------------------------------------------------------
-- 기본 서비스
---------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- 네트워크 오너 강제 함수 (필수 핵심 기능)
---------------------------------------------------------------------
local function ForceOwner(part)
    if not part or not part:IsA("BasePart") then return end
    pcall(function()
        part:SetNetworkOwner(LocalPlayer)
    end)
end

---------------------------------------------------------------------
-- BasePart 오너 가져오기 (디버그용)
---------------------------------------------------------------------
local function GetOwner(part)
    local owner = nil
    pcall(function()
        owner = part:GetNetworkOwner()
    end)
    return owner
end

---------------------------------------------------------------------
-- 소리 재생
---------------------------------------------------------------------
local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

playSound("2865227271")

---------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperRingPartsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 500)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Super Ring Parts V6 by lukas"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 204, 204)
Title.Font = Enum.Font.Fondamento
Title.TextSize = 22
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = Title

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.Text = "Ring Off"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Font = Enum.Font.Fondamento
ToggleButton.TextSize = 18
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

---------------------------------------------------------------------
-- 설정 저장/로드
---------------------------------------------------------------------
local config = {
    radius = 50,
    height = 100,
    rotationSpeed = 10,
    attractionStrength = 1000,
}

local function saveConfig()
    local configStr = HttpService:JSONEncode(config)
    writefile("SuperRingPartsConfig.txt", configStr)
end

local function loadConfig()
    if isfile("SuperRingPartsConfig.txt") then
        local configStr = readfile("SuperRingPartsConfig.txt")
        config = HttpService:JSONDecode(configStr)
    end
end

loadConfig()

---------------------------------------------------------------------
-- 값 조절 GUI 생성 함수
---------------------------------------------------------------------
local function createControl(name, positionY, color, labelText, defaultValue, callback)
    local DecreaseButton = Instance.new("TextButton")
    DecreaseButton.Size = UDim2.new(0.2, 0, 0, 40)
    DecreaseButton.Position = UDim2.new(0.1, 0, positionY, 0)
    DecreaseButton.Text = "-"
    DecreaseButton.BackgroundColor3 = color
    DecreaseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    DecreaseButton.Font = Enum.Font.Fondamento
    DecreaseButton.TextSize = 18
    DecreaseButton.Parent = MainFrame

    local IncreaseButton = Instance.new("TextButton")
    IncreaseButton.Size = UDim2.new(0.2, 0, 0, 40)
    IncreaseButton.Position = UDim2.new(0.7, 0, positionY, 0)
    IncreaseButton.Text = "+"
    IncreaseButton.BackgroundColor3 = color
    IncreaseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    IncreaseButton.Font = Enum.Font.Fondamento
    IncreaseButton.TextSize = 18
    IncreaseButton.Parent = MainFrame

    local Display = Instance.new("TextLabel")
    Display.Size = UDim2.new(0.4, 0, 0, 40)
    Display.Position = UDim2.new(0.3, 0, positionY, 0)
    Display.Text = labelText .. ": " .. defaultValue
    Display.BackgroundColor3 = Color3.fromRGB(255, 153, 51)
    Display.TextColor3 = Color3.fromRGB(0, 0, 0)
    Display.Font = Enum.Font.Fondamento
    Display.TextSize = 18
    Display.Parent = MainFrame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.8, 0, 0, 35)
    TextBox.Position = UDim2.new(0.1, 0, positionY + 0.1, 0)
    TextBox.PlaceholderText = "Enter " .. labelText
    TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.Font = Enum.Font.Fondamento
    TextBox.TextSize = 18
    TextBox.Parent = MainFrame

    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 10)
    TextBoxCorner.Parent = TextBox

    DecreaseButton.MouseButton1Click:Connect(function()
        local value = tonumber(Display.Text:match("%d+"))
        value = math.max(0, value - 10)
        Display.Text = labelText .. ": " .. value
        callback(value)
        playSound("12221967")
        saveConfig()
    end)

    IncreaseButton.MouseButton1Click:Connect(function()
        local value = tonumber(Display.Text:match("%d+"))
        value = math.min(10000, value + 10)
        Display.Text = labelText .. ": " .. value
        callback(value)
        playSound("12221967")
        saveConfig()
    end)

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newValue = tonumber(TextBox.Text)
            if newValue then
                newValue = math.clamp(newValue, 0, 10000)
                Display.Text = labelText .. ": " .. newValue
                TextBox.Text = ""
                callback(newValue)
                playSound("12221967")
                saveConfig()
            else
                TextBox.Text = ""
            end
        end
    end)
end

-- Controls
createControl("Radius", 0.2, Color3.fromRGB(153, 153, 0), "Radius", config.radius, function(v) config.radius=v end)
createControl("Height", 0.4, Color3.fromRGB(153, 0, 153), "Height", config.height, function(v) config.height=v end)
createControl("RotationSpeed", 0.6, Color3.fromRGB(0, 153, 153), "Rotation Speed", config.rotationSpeed, function(v) config.rotationSpeed=v end)
createControl("AttractionStrength", 0.8, Color3.fromRGB(153, 0, 0), "Attraction Strength", config.attractionStrength, function(v) config.attractionStrength=v end)

---------------------------------------------------------------------
-- 최소화 버튼
---------------------------------------------------------------------
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
MinimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
MinimizeButton.Font = Enum.Font.Fondamento
MinimizeButton.TextSize = 15
MinimizeButton.Parent = MainFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 15)
MinimizeCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 40), "Out", "Quad", 0.3)
        MinimizeButton.Text = "+"
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") and child ~= Title and child ~= MinimizeButton then
                child.Visible = false
            end
        end
    else
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 500), "Out", "Quad", 0.3)
        MinimizeButton.Text = "-"
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
    end
    playSound("12221967")
end)

---------------------------------------------------------------------
-- GUI 드래그
---------------------------------------------------------------------
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        update(input)
    end
end)

---------------------------------------------------------------------
-- 네트워크 베이스 (SetNetworkOwner + Radius 무한)
---------------------------------------------------------------------
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14, 14, 14)
    }

    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
            return true
        end
        return false
    end

    -----------------------------------------------------------------
    -- 네트워크 control 강화
    -----------------------------------------------------------------
    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(LocalPlayer, "MaximumSimulationRadius", math.huge)

            for _, part in pairs(Network.BaseParts) do
                if part and part:IsDescendantOf(Workspace) then
                    ForceOwner(part)
                    part.Velocity = Network.Velocity
                end
            end
        end)
    end

    EnablePartControl()
end

---------------------------------------------------------------------
-- MeshPart & Part 물리 객체 제거 + Align 연결
---------------------------------------------------------------------
local function ForcePart(v)
    if (v:IsA("Part") or v:IsA("MeshPart"))
        and not v.Anchored
        and not v.Parent:FindFirstChild("Humanoid")
        and not v.Parent:FindFirstChild("Head")
        and v.Name ~= "Handle" then

        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyAngularVelocity")
                or x:IsA("BodyForce")
                or x:IsA("BodyGyro")
                or x:IsA("BodyPosition")
                or x:IsA("BodyThrust")
                or x:IsA("BodyVelocity")
                or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end

        v.CanCollide = false
        ForceOwner(v)

        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)

        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2

        local AlignPosition = Instance.new("AlignPosition", v)
        AlignPosition.MaxForce = 9e30
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
    end
end

---------------------------------------------------------------------
-- Tornado 기능
---------------------------------------------------------------------
local ringPartsEnabled = false
local parts = {}

local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false
        end
        Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Part.CanCollide = false
        ForceOwner(Part)
        return true
    end
    return false
end

local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) then
            table.insert(parts, part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
end

for _, part in pairs(workspace:GetDescendants()) do
    addPart(part)
end

workspace.DescendantAdded:Connect(function(p)
    addPart(p)
    if p:IsA("BasePart") then ForceOwner(p) end
end)

workspace.DescendantRemoving:Connect(removePart)

---------------------------------------------------------------------
-- Tornado 회전 처리
---------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end

    local character = LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local center = hrp.Position

    for _, part in pairs(parts) do
        if part and part.Parent and not part.Anchored then
            ForceOwner(part)

            local pos = part.Position
            local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
            local newAngle = angle + math.rad(config.rotationSpeed)

            local targetPos = Vector3.new(
                center.X + math.cos(newAngle) * config.radius,
                center.Y + math.sin((pos.Y - center.Y) / config.height) * config.height,
                center.Z + math.sin(newAngle) * config.radius
            )

            local direction = (targetPos - pos).Unit
            part.Velocity = direction * config.attractionStrength
        end
    end
end)

---------------------------------------------------------------------
-- 버튼 기능
---------------------------------------------------------------------
ToggleButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    ToggleButton.Text = ringPartsEnabled and "Tornado On" or "Tornado Off"
    ToggleButton.BackgroundColor3 = ringPartsEnabled and Color3.fromRGB(50,205,50) or Color3.fromRGB(160,82,45)
    playSound("12221967")
end)

---------------------------------------------------------------------
-- 알림
---------------------------------------------------------------------
local userId = Players:GetUserIdFromNameAsync("Robloxlukasgames")
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, ready = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

StarterGui:SetCore("SendNotification", { Title="Hey", Text="Enjoy the Script!", Icon=content, Duration=5 })
StarterGui:SetCore("SendNotification", { Title="TIPS", Text="Click Textbox To edit Any of them", Icon=content, Duration=5 })
StarterGui:SetCore("SendNotification", { Title="Credits", Text="On scriptblox!", Icon=content, Duration=5 })

---------------------------------------------------------------------
-- 레인보우 효과
---------------------------------------------------------------------
local hue = 0
RunService.Heartbeat:Connect(function()
    hue = (hue + 0.01) % 1
    MainFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
end)

local textHue = 0
RunService.Heartbeat:Connect(function()
    textHue = (textHue + 0.01) % 1
    Title.TextColor3 = Color3.fromHSV(textHue, 1, 1)
end)
