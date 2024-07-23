--//  Made By Jake11price

--// If you use any scripts in this gui, i would appreciate if you leave credit ;)


local playerchar = (game.Players.LocalPlayer.Character)
local gui = Instance.new("ScreenGui")
local main = Instance.new("Frame")
local Bringmain = Instance.new("Frame")
local Bringtext = Instance.new("TextBox")
local Credits = Instance.new("TextLabel")
local Bringoffmain = Instance.new("Frame")
local Bringoff = Instance.new("TextButton")
local Bringonmain = Instance.new("Frame")
local Bringon = Instance.new("TextButton")

gui.Name = "gui"
gui.Parent = game.CoreGui

main.Name = "main"
main.Parent = gui
main.BackgroundColor3 = Color3.new(0, 0, 0)
main.Position = UDim2.new(0.132017255, 0, 0.617936134, 0)
main.Size = UDim2.new(0, 161, 0, 100)
main.Active = true
main.Draggable = true

Bringmain.Name = "Bringmain"
Bringmain.Parent = main
Bringmain.BackgroundColor3 = Color3.new(0, 0, 0)
Bringmain.Position = UDim2.new(0, 0, -0.100000001, 0)
Bringmain.Size = UDim2.new(0, 161, 0, 110)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function RemoveSpaces(String)
	return String:gsub("%s+", "") or String
end

local function FindPlayer(String)
	String = RemoveSpaces(String)
	for _, _Player in pairs(Players:GetPlayers()) do
		if _Player.Name:lower():match('^'.. String:lower()) then
			return _Player
		end
	end
	return nil
end

Bringtext.Name = "Bringtext"
Bringtext.Parent = Bringmain
Bringtext.BackgroundColor3 = Color3.new(1, 1, 1)
Bringtext.Position = UDim2.new(0, 0, 0.232727259, 0)
Bringtext.Size = UDim2.new(0, 161, 0, 41)
Bringtext.Font = Enum.Font.SciFi
Bringtext.Text = ""
Bringtext.TextColor3 = Color3.new(0, 0, 0)
Bringtext.TextSize = 14

Credits.Name = "Credits"
Credits.Parent = Bringmain
Credits.BackgroundColor3 = Color3.new(0.333333, 1, 0)
Credits.Size = UDim2.new(0, 161, 0, 25)
Credits.Font = Enum.Font.GothamBold
Credits.Text = "JAKE11PRICE"
Credits.TextColor3 = Color3.new(0, 0, 0)
Credits.TextSize = 14

Bringoffmain.Name = "Bringoffmain"
Bringoffmain.Parent = Bringmain
Bringoffmain.BackgroundColor3 = Color3.new(1, 1, 1)
Bringoffmain.Position = UDim2.new(0, 0, 0.609090924, 0)
Bringoffmain.Size = UDim2.new(0, 161, 0, 43)

Bringoff.Name = "Bringoff"
Bringoff.Parent = Bringoffmain
Bringoff.BackgroundColor3 = Color3.new(1, 0, 0)
Bringoff.Position = UDim2.new(-0.00621099072, 0, 0, 0)
Bringoff.Size = UDim2.new(0, 161, 0, 43)
Bringoff.Font = Enum.Font.Highway
Bringoff.Text = "Loop Bring (OFF)"
Bringoff.TextColor3 = Color3.new(0, 0, 0)
Bringoff.TextSize = 14
Bringoff.MouseButton1Down:connect(function()
Bringoffmain.Visible = false
Bringonmain.Visible = true
_G.Bringplr = true
local player = FindPlayer(Bringtext.Text)
Players.PlayerRemoving:Connect(function(playerleft)
if playerleft.Name == (player.Name) then
_G.Bringplr = false
Bringonmain.Visible = false
Bringoffmain.Visible = true
end
end)
if player and player.Character then
NOW = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
repeat local player = FindPlayer(Bringtext.Text)
game.Players.LocalPlayer.Character.Humanoid.Sit = false

for i,v in pairs(Workspace.Prison_ITEMS.giver:GetChildren()) do
	if v.Name == "M9" then
       lol = Workspace.Remote.ItemHandler:InvokeServer(v.ITEMPICKUP)
	end
end
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW
game.Players.LocalPlayer.Character.Humanoid.Name = 1
local l = game.Players.LocalPlayer.Character["1"]:Clone()
if game.Players.LocalPlayer.Character["1"] then
l.Parent = game.Players.LocalPlayer.Character
l.Name = "Humanoid"
wait()
game.Players.LocalPlayer.Character["1"]:Destroy()
game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character
game.Players.LocalPlayer.Character.Animate.Disabled = true
end
wait()
game.Players.LocalPlayer.Character.Animate.Disabled = false
game.Players.LocalPlayer.Character.Humanoid.DisplayDistanceType = "None"
for i,v in pairs(game:GetService'Players'.LocalPlayer.Backpack:GetChildren())do
	if v.Name == "M9" then
game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
end
end
player.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame 
wait(0.3)
local A_1 = "\66\114\111\121\111\117\98\97\100\100"
local Event = game:GetService("Workspace").Remote.loadchar
Event:InvokeServer(A_1)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW
		until _G.Bringplr == false
end
end)

Bringonmain.Name = "Bringonmain"
Bringonmain.Parent = Bringmain
Bringonmain.BackgroundColor3 = Color3.new(1, 1, 1)
Bringonmain.Position = UDim2.new(0, 0, 0.609090805, 0)
Bringonmain.Size = UDim2.new(0, 161, 0, 43)
Bringonmain.Visible = false

Bringon.Name = "Bringon"
Bringon.Parent = Bringonmain
Bringon.BackgroundColor3 = Color3.new(0.333333, 1, 0)
Bringon.Position = UDim2.new(-0.0062110424, 0, -1.11758709e-08, 0)
Bringon.Size = UDim2.new(0, 161, 0, 43)
Bringon.Font = Enum.Font.Highway
Bringon.Text = "Loop Bring (ON)"
Bringon.TextColor3 = Color3.new(0, 0, 0)
Bringon.TextSize = 14
Bringon.MouseButton1Down:connect(function()
Bringonmain.Visible = false
Bringoffmain.Visible = true
_G.Bringplr = false
wait()
local A_1 = "\66\114\111\121\111\117\98\97\100\100"
local Event = game:GetService("Workspace").Remote.loadchar
Event:InvokeServer(A_1)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW
end)

game:GetService('RunService').Stepped:connect(function()
if _G.Bringplr == true then
game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
local player = FindPlayer(Bringtext.Text)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW
player.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW * CFrame.new(0,1,0)
end
end)