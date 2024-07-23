local Players = game:GetService("Players")
local player = Players.LocalPlayer

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
			local vehicle = humanoid.SeatPart.Parent
			if vehicle then
				print("플레이어가 탑승한 차량: " .. vehicle.Name)
				return vehicle
			end
		end
	end
end

-- 차량이 바라보는 방향으로 힘을 적용하는 함수
local function applyForceToVehicle(vehicle)
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
			-- BodyVelocity 객체를 생성하고 설정합니다.
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = vehicleDirection * 700 -- 차량이 바라보는 방향으로 설정
			bodyVelocity.P = 1 -- 힘의 강도 설정
			bodyVelocity.Parent = part
		end
	end

	-- 선택 사항: 일정 시간 후 힘을 제거합니다.
	wait(0)
	for _, part in pairs(vehicle:GetDescendants()) do
		if part:IsA("BasePart") and part:FindFirstChild("BodyVelocity") then
			part.BodyVelocity:Destroy()
		end
	end
end

-- 메인 스크립트 로직
local vehicle = getVehicleModel()
applyForceToVehicle(vehicle)
