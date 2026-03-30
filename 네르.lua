local RunService = game:GetService("RunService")
local Event = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Event")

RunService.RenderStepped:Connect(function()
	Event:FireServer("Click")
	Event:FireServer("Purchase", "NerPerClick")
end)