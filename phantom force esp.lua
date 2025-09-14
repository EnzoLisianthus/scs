local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local espLines = {}
local scannedModels = {}
local textDrawings = {}

local MAX_LINE_LENGTH = 3
local MIN_LINE_LENGTH = 1.5
local TEXT_OFFSET = Vector3.new(0, -3, 0)
local TARGET_COLOR = Color3.fromRGB(255, 10, 20)

-- Drawing 객체 생성
local function createLine()
    local line = Drawing.new("Line")
    line.Color = Color3.new(0.3, 0.7, 0.3)
    line.Thickness = 2
    line.Transparency = 0.3
    line.Visible = false
    return line
end

local function createTextDrawing(text)
    local txt = Drawing.new("Text")
    txt.Text = text
    txt.Size = 18
    txt.Color = Color3.new(1, 1, 1)
    txt.Center = true
    txt.Transparency = 0.7
    txt.Outline = true
    txt.OutlineTransparency = 0
    txt.OutlineColor = Color3.new(0, 0, 0)
    txt.Visible = false
    return txt
end

-- Dot 색상 체크
local function hasTargetColor(gui)
    local dot = gui:FindFirstChild("PlayerTag") and gui.PlayerTag:FindFirstChild("Dot")
    return dot and dot:IsA("Frame") and dot.BackgroundColor3 == TARGET_COLOR
end

-- 라인·텍스트 제거
local function clearModelESP(model)
    if espLines[model] then
        for _, data in pairs(espLines[model]) do
            data.line:Remove()
        end
        espLines[model] = nil
    end
    if textDrawings[model] then
        textDrawings[model]:Remove()
        textDrawings[model] = nil
    end
    scannedModels[model] = nil
end

-- 모델에 ESP 적용
local function applyESP(model, gui)
    if scannedModels[model] then return end
    scannedModels[model] = true

    if not hasTargetColor(gui) then
        clearModelESP(model)
        return
    end

    espLines[model] = {}
    local parts = {}
    for _, part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end

    for i = 2, #parts do
        table.insert(espLines[model], {
            line = createLine(),
            part1 = parts[i-1],
            part2 = parts[i]
        })
    end

    local playerTag = gui:FindFirstChild("PlayerTag")
    if playerTag and playerTag:IsA("TextLabel") then
        local draw = createTextDrawing(playerTag.Text)
        textDrawings[model] = draw
        playerTag:GetPropertyChangedSignal("Text"):Connect(function()
            if textDrawings[model] then
                textDrawings[model].Text = playerTag.Text
            end
        end)
    end
end

-- 라인 갱신
local function updateLines()
    local camPos = Camera.CFrame.Position
    for model, lines in pairs(espLines) do
        for _, data in ipairs(lines) do
            local p1, p2, line = data.part1, data.part2, data.line
            if p1 and p2 and p1.Parent and p2.Parent then
                local dist = (p1.Position - p2.Position).Magnitude
                if dist <= MAX_LINE_LENGTH and dist >= MIN_LINE_LENGTH then
                    local p1Pos, vis1 = Camera:WorldToViewportPoint(p1.Position)
                    local p2Pos, vis2 = Camera:WorldToViewportPoint(p2.Position)
                    if vis1 and vis2 then
                        line.From = Vector2.new(p1Pos.X, p1Pos.Y)
                        line.To = Vector2.new(p2Pos.X, p2Pos.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end
end

-- 텍스트 갱신
local function updateTexts()
    local camPos = Camera.CFrame.Position
    for model, draw in pairs(textDrawings) do
        if model and model.Parent then
            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if part then
                local pos = part.Position + TEXT_OFFSET
                local screenPos, visible = Camera:WorldToViewportPoint(pos)
                if visible then
                    local distance = (camPos - part.Position).Magnitude
                    draw.Position = Vector2.new(screenPos.X, screenPos.Y)
                    draw.Size = math.max(8, 50 / distance)
                    draw.Visible = true
                else
                    draw.Visible = false
                end
            else
                draw.Visible = false
            end
        else
            draw.Visible = false
        end
    end
end

-- 초기 스캔
for _, gui in ipairs(game:GetDescendants()) do
    if gui.Name == "NameTagGui" and gui.Parent and gui.Parent.Parent:IsA("Model") then
        applyESP(gui.Parent.Parent, gui)
    end
end

-- 변화 감지
game.DescendantAdded:Connect(function(desc)
    if desc.Name == "NameTagGui" and desc.Parent and desc.Parent.Parent:IsA("Model") then
        applyESP(desc.Parent.Parent, desc)
    end
end)

game.DescendantRemoving:Connect(function(desc)
    if desc:IsA("Model") and scannedModels[desc] then
        clearModelESP(desc)
    elseif desc.Name == "NameTagGui" and desc.Parent and desc.Parent.Parent:IsA("Model") then
        clearModelESP(desc.Parent.Parent)
    end
end)

-- 실시간 갱신
RunService.Heartbeat:Connect(function()
    task.spawn(updateLines)  -- 항상 선 갱신
    task.spawn(updateTexts)  -- 항상 텍스트 갱신
end)
