-- LocalScript in StarterPlayerScripts or StarterCharacterScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Function to get the vehicle the player is seated in
local function getVehicleModel()
	-- Wait until the character is loaded
	while not player.Character do
		wait()
	end

	local character = player.Character

	-- Find the Humanoid object in the character
	local humanoid = character:WaitForChild("Humanoid")

	-- Loop to check the current seat of the player
	while true do
		-- Wait for a short period to reduce performance impact
		wait(0.1)

		-- Check if the player is seated
		if humanoid.SeatPart then
			-- Find the vehicle model by getting the parent of the seat part
			local vehicle = humanoid.SeatPart.Parent
			if vehicle then
				print("Player is in vehicle: " .. vehicle.Name)
				return vehicle
			end
		end
	end
end

-- Function to get the Drive script from A-Chassis Interface
local function getDriveScript(vehicleModel)
	if vehicleModel then
		-- Find the A-Chassis Interface ScreenGui within the vehicle model
		local aChassisInterface = vehicleModel:FindFirstChild("A-Chassis Interface", true)

		if aChassisInterface then
			local driveScript = aChassisInterface:FindFirstChild("Drive")
			if driveScript and driveScript:IsA("LocalScript") then
				print("Found Drive script")
				return driveScript
			else
				warn("Drive script not found in A-Chassis Interface")
			end
		else
			warn("A-Chassis Interface not found in vehicle model")
		end
	end

	return nil
end

-- Function to modify the tune settings via the Drive script
local function modifyTuneSettings(driveScript)
	if driveScript then
		-- Get the script environment
		local car = driveScript.Parent.Parent.Parent

		if car then
			print("Car found: " .. car.Name)
			local aChassisTuneModule = car:FindFirstChild("A-Chassis Tune")

			if aChassisTuneModule then
				print("Found A-Chassis Tune module in car: " .. aChassisTuneModule.Name)
				local _Tune = require(aChassisTuneModule)

				if _Tune then
					-- Modify the tune settings
					_Tune.Horsepower = 120
					_Tune.IdleRPM = 1000
					_Tune.PeakRPM = 7000
					_Tune.Redline = 18000

					print("Tune settings have been modified:")
					print("Horsepower:", _Tune.Horsepower)
					print("IdleRPM:", _Tune.IdleRPM)
					print("PeakRPM:", _Tune.PeakRPM)
					print("Redline:", _Tune.Redline)
				else
					warn("Failed to require _Tune from A-Chassis Tune module")
				end
			else
				warn("A-Chassis Tune module not found in car")
			end
		else
			warn("Car object not found in Drive script")
		end
	end
end

-- 사용자 입력 서비스를 가져옵니다.
local UserInputService = game:GetService("UserInputService")

-- 키 입력 이벤트를 연결합니다.
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	-- gameProcessedEvent가 true이면, 게임 내부의 다른 GUI나 기능에 의해 입력이 처리된 상태입니다.
	if gameProcessedEvent then
		return
	end

	-- 입력된 키가 "E"인지 확인합니다.
	if input.KeyCode == Enum.KeyCode.E then
		-- 여기에서 실행하고자 하는 코드를 작성합니다.
		print("E 키가 눌렸습니다!")
		-- Main execution starts here
		local vehicleModel = getVehicleModel()

		-- Do something with the vehicle model (e.g., print its name)
		if vehicleModel then
			print("The player's vehicle model is: " .. vehicleModel.Name)

			-- Call the function to get the Drive script
			local driveScript = getDriveScript(vehicleModel)

			-- Call the function to modify the tune settings via the Drive script
			modifyTuneSettings(driveScript)
		end
		-- 원하는 기능을 여기에 추가합니다.
	end
end)
