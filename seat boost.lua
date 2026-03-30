-- 완성본: 캐릭터 리셋 & 차량 재스폰 방어형 + 모멘텀 유지 + Ctrl 방향 전환 기능 추가
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 상태 변수
local character = nil
local hum = nil

local currentSeat = nil
local vehicleModel = nil
local vehicleRoot = nil
local BV = nil

local forward = false
local speed = 0
local maxSpeed = 1000
local accel = 300

-- ★ 추가됨: 전진/후진 방향 토글 변수
local direction = 1  -- 1 = 전진 / -1 = 후진

-- 연결 객체들
local seatChangedConn = nil
local modelAncestryConn = nil
local rootAncestryConn = nil
local characterRemovingConn = nil

----------------------------------------------------------------
-- BodyVelocity 생성/제거
----------------------------------------------------------------
local function attachForce()
    if not vehicleRoot then return end
    if BV then return end

    BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.Parent = vehicleRoot

    print("[VehicleFly] BodyVelocity 생성")
end

local function removeForce()
    if BV then
        BV:Destroy()
        BV = nil
        print("[VehicleFly] BodyVelocity 제거")
    end
    speed = 0
end

----------------------------------------------------------------
-- 차량 정리
----------------------------------------------------------------
local function clearVehicleReferences()
    if modelAncestryConn then
        modelAncestryConn:Disconnect()
        modelAncestryConn = nil
    end
    if rootAncestryConn then
        rootAncestryConn:Disconnect()
        rootAncestryConn = nil
    end

    vehicleModel = nil
    vehicleRoot = nil
    removeForce()
end

----------------------------------------------------------------
-- 모델 제거 감시
----------------------------------------------------------------
local function watchModelRemoval(model, rootPart)
    if model then
        modelAncestryConn = model.AncestryChanged:Connect(function(_, _)
            if not model:IsDescendantOf(game) then
                warn("[VehicleFly] 차량 모델 제거 감지 -> 정리")
                clearVehicleReferences()
            end
        end)
    end

    if rootPart then
        rootAncestryConn = rootPart.AncestryChanged:Connect(function(_, _)
            if not rootPart:IsDescendantOf(game) then
                warn("[VehicleFly] Root 파트 제거 감지 -> 정리")
                clearVehicleReferences()
            end
        end)
    end
end

----------------------------------------------------------------
-- seat → vehicleRoot 찾기
----------------------------------------------------------------
local function detectVehicle(seat)
    if not seat then
        print("[VehicleFly] Seat 없음")
        clearVehicleReferences()
        return false
    end

    print("[VehicleFly] Seat 감지:", seat.Name)

    local model = seat:FindFirstAncestorOfClass("Model")
    if not model then
        print("[VehicleFly] 상위 Model 없음")
        clearVehicleReferences()
        return false
    end

    if not model.PrimaryPart then
        for _, v in ipairs(model:GetChildren()) do
            if v:IsA("BasePart") then
                model.PrimaryPart = v
                break
            end
        end
    end

    if not model.PrimaryPart then
        print("[VehicleFly] Model.PrimaryPart 없음 -> 실패")
        clearVehicleReferences()
        return false
    end

    if vehicleModel == model and vehicleRoot == model.PrimaryPart then
        return true
    end

    clearVehicleReferences()

    vehicleModel = model
    vehicleRoot = model.PrimaryPart

    print("[VehicleFly] 차량 Root 설정:", vehicleRoot.Name)

    watchModelRemoval(vehicleModel, vehicleRoot)

    return true
end

----------------------------------------------------------------
-- SeatPart 변경 감지
----------------------------------------------------------------
local function onSeatChanged()
    currentSeat = hum.SeatPart

    if currentSeat then
        if detectVehicle(currentSeat) then
            print("[VehicleFly] 제어 가능 차량이 설정됨")
        else
            print("[VehicleFly] 차량 설정 실패")
        end
    else
        print("[VehicleFly] 플레이어가 좌석에서 벗어남")
        clearVehicleReferences()
    end
end

----------------------------------------------------------------
-- 캐릭터 정리 및 설정
----------------------------------------------------------------
local function cleanupCharacter()
    if seatChangedConn then
        seatChangedConn:Disconnect()
        seatChangedConn = nil
    end
    if characterRemovingConn then
        characterRemovingConn:Disconnect()
        characterRemovingConn = nil
    end

    hum = nil
    currentSeat = nil
    clearVehicleReferences()
end

local function setupCharacter(char)
    cleanupCharacter()

    character = char or player.Character
    if not character then return end

    hum = character:WaitForChild("Humanoid", 5)
    if not hum then
        warn("[VehicleFly] Humanoid를 찾지 못함")
        return
    end

    seatChangedConn = hum:GetPropertyChangedSignal("SeatPart"):Connect(onSeatChanged)

    characterRemovingConn = character.AncestryChanged:Connect(function()
        if not character:IsDescendantOf(game) then
            cleanupCharacter()
        end
    end)

    onSeatChanged()
end

----------------------------------------------------------------
-- 리스폰 대응
----------------------------------------------------------------
if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
    setupCharacter(char)
end)

----------------------------------------------------------------
-- 입력 처리
----------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- ★ Ctrl → 전/후진 방향 토글
    if input.KeyCode == Enum.KeyCode.LeftControl then
        direction = -direction
        print("[VehicleFly] 방향 전환됨. 현재:", direction == 1 and "전진" or "후진")
    end

    -- W 가속
    if input.KeyCode == Enum.KeyCode.W then
        forward = true

        if vehicleRoot then
            speed = vehicleRoot.AssemblyLinearVelocity.Magnitude
            print("[VehicleFly] 초기 속도:", speed)
        end

        attachForce()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.W then
        forward = false
        removeForce()
    end
end)

----------------------------------------------------------------
-- Heartbeat (가속 및 방향 적용)
----------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    if forward and vehicleRoot and BV then
        speed = math.clamp(speed + accel * dt, 0, maxSpeed)

        -- ★ 방향 적용: LookVector * direction
        BV.Velocity = vehicleRoot.CFrame.LookVector * speed * direction
    end
end)
