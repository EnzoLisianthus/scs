--!strict

local Library = {}

-- =========================
-- 서비스
-- =========================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- 생성
-- =========================
function Library:CreateWindow(title)

	if game:GetService("CoreGui"):FindFirstChild("LiquidGlassDynamic") then
		game:GetService("CoreGui").LiquidGlassDynamic:Destroy()
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = "LiquidGlassDynamic"
	screen.IgnoreGuiInset = true
	screen.Parent = player:WaitForChild("PlayerGui")

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1,1)
	root.BackgroundTransparency = 1
	root.Parent = screen

	-- =========================
	-- 컨테이너
	-- =========================
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(320, 420)
	holder.Position = UDim2.new(0.5, -160, 0.5, -210)
	holder.BackgroundTransparency = 1
	holder.Parent = root

	-- =========================
	-- 유리 본체
	-- =========================
	local glass = Instance.new("Frame")
	glass.Size = UDim2.fromScale(1,1)
	glass.BackgroundColor3 = Color3.fromRGB(210,220,235)
	glass.BackgroundTransparency = 0.6
	glass.BorderSizePixel = 0
	glass.Parent = holder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 48)
	corner.Parent = glass

	-- =========================
	-- 기본 림
	-- =========================
	local baseStroke = Instance.new("UIStroke")
	baseStroke.Thickness = 1.4
	baseStroke.Color = Color3.fromRGB(255,255,255)
	baseStroke.Transparency = 0.65
	baseStroke.Parent = glass

	-- =========================
	-- 동적 림
	-- =========================
	local dynamicStroke = Instance.new("UIStroke")
	dynamicStroke.Thickness = 2
	dynamicStroke.Color = Color3.fromRGB(255,255,255)
	dynamicStroke.Transparency = 0.1
	dynamicStroke.Parent = glass

	local edgeGrad = Instance.new("UIGradient")
	edgeGrad.Parent = dynamicStroke
	edgeGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.0, 1),
		NumberSequenceKeypoint.new(0.45, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.0),
		NumberSequenceKeypoint.new(0.55, 0.2),
		NumberSequenceKeypoint.new(1.0, 1),
	}

	-- =========================
	-- 내부 그라데이션
	-- =========================
	local grad = Instance.new("UIGradient")
	grad.Rotation = 90
	grad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0.75)
	}
	grad.Parent = glass

	-- =========================
	-- 탭 바
	-- =========================
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1,0,0,40)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = glass

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Parent = tabBar

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1,0,1,-40)
	content.Position = UDim2.new(0,0,0,40)
	content.BackgroundTransparency = 1
	content.Parent = glass

	local pages = {}

	-- =========================
	-- 탭 생성 함수 (원본 그대로)
	-- =========================
	function Library:AddTab(name)
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(80,30)
		button.Text = name
		button.BackgroundTransparency = 1
		button.TextColor3 = Color3.new(1,1,1)
		button.Parent = tabBar

		local page = Instance.new("Frame")
		page.Size = UDim2.fromScale(1,1)
		page.Visible = false
		page.BackgroundTransparency = 1
		page.Parent = content

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0,6)
		layout.Parent = page

		button.MouseButton1Click:Connect(function()
			for _,p in pairs(pages) do
				p.Visible = false
			end
			page.Visible = true
		end)

		table.insert(pages, page)
		if #pages == 1 then
			page.Visible = true
		end

		local tab = {}

		function tab:AddButton(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,-10,0,32)
			btn.Text = text
			btn.BackgroundTransparency = 0.7
			btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
			btn.TextColor3 = Color3.new(0,0,0)
			btn.Parent = page

			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

			btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
		end

		function tab:AddToggle(text, callback)
			local state = false

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,-10,0,32)
			btn.Text = text .. " : OFF"
			btn.BackgroundTransparency = 0.7
			btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
			btn.TextColor3 = Color3.new(0,0,0)
			btn.Parent = page

			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

			btn.MouseButton1Click:Connect(function()
				state = not state
				btn.Text = text .. " : " .. (state and "ON" or "OFF")
				if callback then callback(state) end
			end)
		end

		function tab:AddInput(text, callback)
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1,-10,0,32)
			box.PlaceholderText = text
			box.BackgroundTransparency = 0.7
			box.BackgroundColor3 = Color3.fromRGB(255,255,255)
			box.TextColor3 = Color3.new(0,0,0)
			box.Parent = page

			Instance.new("UICorner", box).CornerRadius = UDim.new(0,12)

			box.FocusLost:Connect(function()
				if callback then callback(box.Text) end
			end)
		end

		return tab
	end

	-- =========================
	-- 🔥 추가된 부분 (핵심)
	-- =========================
	local Window = {}

	function Window:CreateTab(name)
		return Library:AddTab(name)
	end

	-- =========================
	-- 드래그 + 림 (원본 그대로)
	-- =========================
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
