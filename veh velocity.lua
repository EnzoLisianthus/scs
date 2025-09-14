local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local vehicle -- 전역 변수로 vehicle 정의
local forceEnabled = false -- 힘 적용 상태를 추적하는 변수
local baseVelocity = 50 -- 기본 속도
local currentVelocity = baseVelocity -- 현재 속도
local increaseRate = 3 -- 증가 속도
local increaseInterval = 0.05 -- 증가 간격

-- 플레이어가 탑승하고 있는 차량 모델을 가져오는 함수
local function getVehicleModel()
    -- 캐릭터가 로드될 때까지 기다립니다.
    while not player.Character do
        wait()
    end

    local character = player.Character

    -- 캐릭터에서 Humanoid 객체를 찾습니다.
    local humanoid = character:WaitForChild("Humanoid")

    -- 플레이어가 현재 탑승하고 있는 좌석을 확인하는 루프
    while true do
        -- 성능에 미치는 영향을 줄이기 위해 짧은 시간 대기
        wait(0.1)

        -- 플레이어가 좌석에 앉아 있는지 확인합니다.
        if humanoid.SeatPart then
            -- 좌석의 부모를 통해 차량 모델을 찾습니다.
            local vehicleModel = humanoid.SeatPart.Parent
            if vehicleModel then
                print("플레이어가 탑승한 차량: " .. vehicleModel.Name)
                return vehicleModel
            end
        end
    end
end

-- 차량이 바라보는 방향으로 힘을 적용하는 함수
local function applyForceToVehicle(vehicle, velocity)
    if not vehicle then return end

    -- VehicleSeat를 찾습니다.
    local seat = vehicle:FindFirstChildOfClass("VehicleSeat")
    if not seat then
        warn("VehicleSeat을 찾을 수 없습니다.")
        return
    end

    -- 차량의 방향을 구합니다.
    local vehicleDirection = seat.CFrame.LookVector

    -- 차량의 모든 부품에 힘을 적용합니다.
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            -- BodyVelocity 객체를 찾거나 생성하고 설정합니다.
            local bodyVelocity = part:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
            bodyVelocity.Velocity = vehicleDirection * velocity -- 차량이 바라보는 방향으로 설정
            bodyVelocity.P = 1000 -- 힘의 강도 설정
            bodyVelocity.Parent = part
        end
    end
end

-- 차량의 힘을 제거하는 함수
local function removeForceFromVehicle(vehicle)
    if not vehicle then return end

    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChild("BodyVelocity") then
            part.BodyVelocity:Destroy()
        end
    end
end

local function onInputBegan(input, gameProcessedEvent)
    if gameProcessedEvent then
        return
    end

    if input.KeyCode == Enum.KeyCode.LeftShift then
        vehicle = getVehicleModel()
        forceEnabled = true
    end
end

local function onInputEnded(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        forceEnabled = false
        removeForceFromVehicle(vehicle) -- 먼저 BodyVelocity 제거
        -- 차량의 기본 속도로 설정 (Throttle 등을 설정하는 것이 필요할 수 있음)
    end
end

local function onHeartbeat()
    if forceEnabled and vehicle then
        currentVelocity = currentVelocity + increaseRate
        applyForceToVehicle(vehicle, currentVelocity)
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
RunService.Heartbeat:Connect(onHeartbeat)
