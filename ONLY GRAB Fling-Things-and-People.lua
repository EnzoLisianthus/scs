--[[ Settings ]]
local DefaultReachLimit = 33
local IncreasedReachDistance = 100
local PowerTable = {
   ["BombMissile"] = 1200,
   ["Others"] = 600,
   ["Players"] = 1600,
}

--[[ Variables ]]
local PS = game:GetService("Players")
local Player = PS.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RS = game:GetService("ReplicatedStorage")
local CE = RS:WaitForChild("CharacterEvents")
local BeingHeld = Player:WaitForChild("IsHeld")
local PlayerScripts = Player:WaitForChild("PlayerScripts")

--[[ Remotes ]]
local StruggleEvent = CE:WaitForChild("Struggle")

--[[ Anti-Explosion ]]
workspace.DescendantAdded:Connect(function(v)
   if v:IsA("Explosion") then
       v.BlastPressure = 0
   end
end)

--[[ Anti-grab ]]
local RS = game:GetService("RunService")
BeingHeld.Changed:Connect(function(C)
   if C == true then
       if BeingHeld.Value == true then
           local Event;
           Event = RS.RenderStepped:Connect(function()
               if BeingHeld.Value == true then
                   StruggleEvent:FireServer(Player)
               elseif BeingHeld.Value == false then
                   Event:Disconnect()
               end
           end)
       end
   end
end)

