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
local maxDistance = 30000
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

-- FOV 원
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Radius = fovRadius
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

-- 마우스 초기화
task.spawn(function()
    pcall(function() mousemoverel(0,0) end)
    while task.wait(5) do
        pcall(function() mousemoverel(0,0) end)
    end
end)

-- candidateHeads 초기 캐싱
for _, obj in ipairs(Workspace:GetDescendants()) do
    if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.Name == "Head" and obj.Parent ~= localPlayer.Character then
        table.insert(candidateHeads, obj)
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.Name == "Head" and obj.Parent ~= localPlayer.Character then
        table.insert(candidateHeads, obj)
    end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    for i=#candidateHeads,1,-1 do
        if candidateHeads[i] == obj then
            table.remove(candidateHeads, i)
        end
    end
end)

-- 계산 주기
local updateInterval = 0.05
local lastUpdate = 0

-- FOV 내 타겟 찾기
local function findTarget()
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

    return closest
end

local function updateCachedTarget()
    cachedTarget = findTarget()
end

-- 마우스 이동
local function aimAtPart(part)
    if not part then return end

    -- 카메라 위치와 방향
    local camPos = cam.CFrame.Position
    local camLook = cam.CFrame.LookVector

    -- 타겟까지의 방향 벡터
    local targetDir = (part.Position - camPos).Unit

    -- 카메라 미래 방향과 타겟 방향의 각도 차이 계산
    -- yaw: 좌우, pitch: 위아래
    local delta = cam.CFrame:VectorToObjectSpace(targetDir)

    -- delta.X = 좌우 각도 차이
    -- delta.Y = 위아래 각도 차이
    local yaw = math.atan2(delta.X, delta.Z)
    local pitch = math.asin(delta.Y)

    -- 마우스 이동 반영 (감도 조절 가능)
    local factor = 500  -- 숫자 높을수록 더 빨리 회전함 (원하면 조절 가능)

    mousemoverel(
        yaw * factor,
        -pitch * factor
    )
end

-- Flick
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == aimKey then
        aiming = true

        -- ⚠ 7번 키 누른 순간의 타겟 고정
        cachedTarget = findTarget()
    elseif input.KeyCode == flickKey and not flicking and cachedTarget then
        flicking = true
        flickStartTime = tick()
        flickTarget = cachedTarget
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.KeyCode == aimKey then
        aiming = false
    end
end)

-- Flick 처리
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    fovCircle.Position = center
    fovCircle.Color = cachedTarget and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)

    if not aiming then
        -- 에이밍 중이 아닐 때만 자동 갱신
        if tick() - lastUpdate >= updateInterval then
            updateCachedTarget()
            lastUpdate = tick()
        end
    end

    if aiming and cachedTarget then
        aimAtPart(cachedTarget)
    end

    if flicking and flickTarget and flickTarget.Parent then
        aimAtPart(flickTarget)
        if tick() - flickStartTime >= flickDuration then
            mouse1click()
            flicking = false
            flickTarget = nil
        end
    end
end)

----------------------------------------------------------------
-- 🔥🔥🔥 추가: 레이캐스트 기반 텔레포트 시스템 🔥🔥🔥
----------------------------------------------------------------

local originalCFrame = nil
local teleporting = false
local teleportDistance = 10
local fixedTeleportTarget = nil
local teleportInterval = 0
local lastTeleportTick = 0

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- 7번 눌렀을 때 — 타겟 고정 + 텔레포트 준비
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == aimKey then

        -- 7번 누르는 순간의 타겟 확정
        fixedTeleportTarget = cachedTarget

        if fixedTeleportTarget then
            teleporting = true

            local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                originalCFrame = root.CFrame
                workspace.Gravity = 0
            end
        end
    end
end)

-- 7번 키 떼면 원래 위치 복귀
UserInputService.InputEnded:Connect(function(input, gp)
    if input.KeyCode == aimKey then
        teleporting = false

        if fixedTeleportTarget then
            fixedTeleportTarget = nil
            workspace.Gravity = 196
        end

        local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and originalCFrame then
            root.CFrame = originalCFrame
        end
    end
end)

-- 반복 텔레포트
RunService.RenderStepped:Connect(function()
    if teleporting and fixedTeleportTarget and fixedTeleportTarget.Parent then
        if tick() - lastTeleportTick >= teleportInterval then
            lastTeleportTick = tick()

            local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local head = fixedTeleportTarget

            if root and head then
                -- 목표 위치 계산
                local flatLookVector = Vector3.new(head.CFrame.LookVector.X, 0, head.CFrame.LookVector.Z).Unit
                local desiredPos = Vector3.new(head.Position.X, head.Position.Y, head.Position.Z) - flatLookVector * teleportDistance

                -- 레이캐스트 충돌 방지
                raycastParams.FilterDescendantsInstances = {localPlayer.Character}

                local result = Workspace:Raycast(head.Position, (desiredPos - head.Position), raycastParams)

                if result then
                    -- 벽 바로 앞에서 멈춤
                    desiredPos = result.Position - (desiredPos - head.Position).Unit * 2
                end

                root.CFrame = CFrame.new(desiredPos, head.Position)
            end
        end
    end
end)
