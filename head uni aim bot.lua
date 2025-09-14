-- 서비스
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- 변수
local cam = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

-- 설정
local aimKey = Enum.KeyCode.Seven
local flickKey = Enum.KeyCode.Eight
local fovRadius = 250
local maxDistance = 300
local minDistance = 0.5
local aimSpeed = 4
local flickDuration = 0.06 -- Flick 시간

-- 상태 변수
local candidateHeads = {}
local cachedTarget = nil
local aiming = false
local flicking = false
local flickStartTime = 0
local flickTarget = nil

-- FOV 원 표시
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Radius = fovRadius
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

-- 함수 로딩 (마우스 호출 초기화)
task.spawn(function()
    pcall(function()
        mousemoverel(0,0)
    end)
    while task.wait(5) do
        pcall(function()
            mousemoverel(0,0)
        end)
    end
end)

-- candidateHeads 초기 캐싱
for _, obj in ipairs(Workspace:GetDescendants()) do
    if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.Name == "Head" and obj.Parent ~= localPlayer.Character then
        table.insert(candidateHeads, obj)
    end
end

-- 새로 생기는 헤드 추가
Workspace.DescendantAdded:Connect(function(obj)
    if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.Name == "Head" and obj.Parent ~= localPlayer.Character then
        table.insert(candidateHeads, obj)
    end
end)

-- 제거되는 헤드 삭제
Workspace.DescendantRemoving:Connect(function(obj)
    for i=#candidateHeads,1,-1 do
        if candidateHeads[i] == obj then
            table.remove(candidateHeads, i)
        end
    end
end)

-- 후보 갱신 주기 설정
local updateInterval = 0.05 -- 20Hz
local lastUpdate = 0

-- 후보 계산 (초당 20회)
local function updateCachedTarget()
    local closest = nil
    local minDist = math.huge
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

    for _, head in ipairs(candidateHeads) do
        if head and head.Parent and head.Parent ~= localPlayer.Character then
            local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
            local worldDist = (cam.CFrame.Position - head.Position).Magnitude

            if onScreen and worldDist <= maxDistance and worldDist >= minDistance then
                local delta = Vector2.new(screenPos.X, screenPos.Y) - center
                local dist = delta.Magnitude
                if dist <= fovRadius and dist < minDist and cam.CFrame.LookVector:Dot((head.Position - cam.CFrame.Position).Unit) > 0.5 then
                    minDist = dist
                    closest = head
                end
            end
        end
    end

    cachedTarget = closest
end

-- 마우스 이동
local function aimAtPart(part)
    if not part then return end
    local headPos = cam:WorldToViewportPoint(part.Position)
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local delta = Vector2.new(headPos.X, headPos.Y) - center
    mousemoverel(delta.X * aimSpeed, delta.Y * aimSpeed)
end

-- 입력 이벤트
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == aimKey then
        aiming = true
    elseif input.KeyCode == flickKey and not flicking and cachedTarget then
        -- Flick 시작
        flicking = true
        flickStartTime = tick()
        flickTarget = cachedTarget -- flick 시작 시점의 타겟 고정
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.KeyCode == aimKey then
        aiming = false
    end
end)

-- 메인 루프
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    fovCircle.Position = center
    fovCircle.Color = cachedTarget and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)

    -- 후보 갱신 (초당 20회)
    if tick() - lastUpdate >= updateInterval then
        updateCachedTarget()
        lastUpdate = tick()
    end

    -- 에임 적용
    if aiming and cachedTarget then
        aimAtPart(cachedTarget)
    end

    -- Flick 처리 (고정된 타겟만 사용)
    if flicking and flickTarget and flickTarget.Parent then
        aimAtPart(flickTarget)
        if tick() - flickStartTime >= flickDuration then
            mouse1click()
            flicking = false
            flickTarget = nil -- 완전 초기화
        end
    end
end)
