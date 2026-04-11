--!strict

local Library = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

function Library:CreateWindow(title)

	if player.PlayerGui:FindFirstChild("LiquidGlassDynamic") then
		player.PlayerGui.LiquidGlassDynamic:Destroy()
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = "LiquidGlassDynamic"
	screen.IgnoreGuiInset = true
	screen.Parent = player:WaitForChild("PlayerGui")

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1,1)
	root.BackgroundTransparency = 1
	root.Parent = screen

	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(340, 460)
	holder.Position = UDim2.new(0.5, -170, 0.5, -230)
	holder.BackgroundTransparency = 1
	holder.Parent = root

	local glass = Instance.new("Frame")
	glass.Size = UDim2.fromScale(1,1)
	glass.BackgroundColor3 = Color3.fromRGB(210,220,235)
	glass.BackgroundTransparency = 0.6
	glass.Parent = holder

	Instance.new("UICorner", glass).CornerRadius = UDim.new(0, 48)

	-- Stroke
	local baseStroke = Instance.new("UIStroke", glass)
	baseStroke.Thickness = 1.4
	baseStroke.Transparency = 0.65

	local dynamicStroke = Instance.new("UIStroke", glass)
	dynamicStroke.Thickness = 2
	dynamicStroke.Transparency = 0.1

	local edgeGrad = Instance.new("UIGradient", dynamicStroke)
	edgeGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0,1),
		NumberSequenceKeypoint.new(0.5,0),
		NumberSequenceKeypoint.new(1,1),
	}

	-- 내부 그라데이션
	local grad = Instance.new("UIGradient", glass)
	grad.Rotation = 90
	grad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0,0.5),
		NumberSequenceKeypoint.new(1,0.75)
	}

	-- =====================
	-- 🔴🟡🟢 맥 버튼
	-- =====================
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1,0,0,36)
	topBar.BackgroundTransparency = 1
	topBar.Parent = glass

	local function makeDot(color, x)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(12,12)
		b.Position = UDim2.new(0,x,0,12)
		b.BackgroundColor3 = color
		b.Text = ""
		b.Parent = topBar
		Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
		return b
	end

	local close = makeDot(Color3.fromRGB(255,95,87),10)
	local mini = makeDot(Color3.fromRGB(255,189,46),30)
	local max = makeDot(Color3.fromRGB(40,200,64),50)

	close.MouseButton1Click:Connect(function()
		screen:Destroy()
	end)

	mini.MouseButton1Click:Connect(function()
		glass.Visible = not glass.Visible
	end)

	max.MouseButton1Click:Connect(function()
		holder.Size = holder.Size == UDim2.fromOffset(340,460)
			and UDim2.fromOffset(500,600)
			or UDim2.fromOffset(340,460)
	end)

	-- =====================
	-- 탭바
	-- =====================
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1,0,0,40)
	tabBar.Position = UDim2.new(0,0,0,36)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = glass

	local layout = Instance.new("UIListLayout", tabBar)
	layout.FillDirection = Enum.FillDirection.Horizontal

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1,0,1,-76)
	content.Position = UDim2.new(0,0,0,76)
	content.BackgroundTransparency = 1
	content.Parent = glass

	local pages = {}
	local buttons = {}

	function Library:AddTab(name)
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(90,28)
		button.Text = name
		button.BackgroundTransparency = 0.6
		button.BackgroundColor3 = Color3.fromRGB(255,255,255)
		button.TextColor3 = Color3.new(0,0,0)
		button.Parent = tabBar
		Instance.new("UICorner", button).CornerRadius = UDim.new(0,10)

		local page = Instance.new("Frame")
		page.Size = UDim2.fromScale(1,1)
		page.Visible = false
		page.BackgroundTransparency = 1
		page.Parent = content

		local l = Instance.new("UIListLayout", page)
		l.Padding = UDim.new(0,6)

		button.MouseButton1Click:Connect(function()
			for _,p in pairs(pages) do p.Visible = false end
			for _,b in pairs(buttons) do b.BackgroundTransparency = 0.6 end

			page.Visible = true
			button.BackgroundTransparency = 0.2
		end)

		table.insert(pages,page)
		table.insert(buttons,button)

		if #pages == 1 then
			page.Visible = true
			button.BackgroundTransparency = 0.2
		end

		local tab = {}

		local function style(obj)
			obj.BackgroundTransparency = 0.6
			obj.BackgroundColor3 = Color3.fromRGB(255,255,255)
			obj.TextColor3 = Color3.new(0,0,0)
			Instance.new("UICorner", obj).CornerRadius = UDim.new(0,12)
		end

		function tab:AddButton(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,-10,0,32)
			btn.Text = text
			btn.Parent = page
			style(btn)

			btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
		end

		function tab:AddToggle(text, callback)
			local state = false
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,-10,0,32)
			btn.Text = text.." : OFF"
			btn.Parent = page
			style(btn)

			btn.MouseButton1Click:Connect(function()
				state = not state
				btn.Text = text.." : "..(state and "ON" or "OFF")
				if callback then callback(state) end
			end)
		end

		function tab:AddInput(text, callback)
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1,-10,0,32)
			box.PlaceholderText = text
			box.Parent = page
			style(box)

			box.FocusLost:Connect(function()
				if callback then callback(box.Text) end
			end)
		end

		return tab
	end

	local Window = {}
	function Window:CreateTab(name)
		return Library:AddTab(name)
	end

	-- 드래그
	local drag = Instance.new("TextButton")
	drag.Size = UDim2.fromScale(1,1)
	drag.BackgroundTransparency = 1
	drag.Text = ""
	drag.Parent = glass

	local dragging = false
	local startMouse = Vector2.zero
	local startPos = Vector2.zero

	local target = Vector2.new(holder.Position.X.Offset, holder.Position.Y.Offset)
	local current = target

	drag.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startMouse = UserInputService:GetMouseLocation()
			startPos = target
		end
	end)

	drag.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UserInputService:GetMouseLocation() - startMouse
			target = startPos + delta
		end
	end)

	local smoothOffset = 0

	RunService.RenderStepped:Connect(function(dt)
		local a = 1 - math.exp(-dt*12)
		current = current:Lerp(target, a)

		holder.Position = UDim2.new(0.5, current.X, 0.5, current.Y)

		local mouse = UserInputService:GetMouseLocation()
		local absPos = glass.AbsolutePosition
		local absSize = glass.AbsoluteSize

		local relX = (mouse.X - absPos.X) / absSize.X
		local relY = (mouse.Y - absPos.Y) / absSize.Y

		relX = math.clamp(relX, 0, 1)
		relY = math.clamp(relY, 0, 1)

		local center = Vector2.new(0.5,0.5)
		local dir = Vector2.new(relX, relY) - center

		local angle = math.atan2(dir.Y, dir.X)
		local normalized = (angle / math.pi + 1) / 2

		local targetOffset = normalized - 0.5
		local smoothFactor = 1 - math.exp(-dt * 8)

		smoothOffset = smoothOffset + (targetOffset - smoothOffset) * smoothFactor
		edgeGrad.Offset = Vector2.new(smoothOffset, 0)
	end)

	return Window
end

return function()
	return Library
end
