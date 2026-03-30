--// 7 Key Hold Teleport (Client-Side)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Holding = false
local SavedCFrame = nil
local Connection = nil

-- 캐릭터 리스폰 대응
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Seven and not Holding then
        Holding = true
        SavedCFrame = HumanoidRootPart.CFrame

        Connection = RunService.RenderStepped:Connect(function()
            if not Holding or not HumanoidRootPart then return end
            
            local currentPos = HumanoidRootPart.Position
            local lookDir = Camera.CFrame.LookVector
            
            local newPos = currentPos + (lookDir * 10) + Vector3.new(0, 100, 0)
            HumanoidRootPart.CFrame = CFrame.new(newPos)
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.Seven and Holding then
        Holding = false
        
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
        
        if SavedCFrame and HumanoidRootPart then
            HumanoidRootPart.CFrame = SavedCFrame
        end
    end
end)