--!strict

local Library = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local WINDOW_NAME = "LiquidGlassDynamic"

local function safeDisconnect(conn)
	if conn and typeof(conn) == "RBXScriptConnection" then
		pcall(function()
			conn:Disconnect()
		end)
	end
end

local function tween(instance, info, props)
	local t = TweenService:Create(instance, info, props)
	t:Play()
	return t
end

function Library:CreateWindow(title)
	local playerGui = player:WaitForChild("PlayerGui")

	local existing = playerGui:FindFirstChild(WINDOW_NAME)
	if existing then
		existing:Destroy()
	end

	local connections = {}
	local destroyed = false
	local minimized = false
	local maximized = false
	local dragging = false

	local baseSize = UDim2.fromOffset(780, 500)
	local maxSize = UDim2.fromOffset(1030, 650)
	local minimizedSize = UDim2.fromOffset(78, 78)

	local baseCornerRadius = 40
	local minimizedPosition = UDim2.new(0.5, -39, 0.82, -39)
	local restorePosition = UDim2.new(0.5, -390, 0.5, -250)

	local lightingTargets = {}

	local function registerConnection(conn)
		table.insert(connections, conn)
		return conn
	end

	local function cleanup(screen)
		if destroyed then
			return
		end

		destroyed = true

		for _, conn in ipairs(connections) do
			safeDisconnect(conn)
		end

		table.clear(connections)
		table.clear(lightingTargets)

		if screen and screen.Parent then
			screen:Destroy()
		end
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = WINDOW_NAME
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = playerGui

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Parent = screen

	local holder = Instance.new("Frame")
	holder.Name = "Holder"
	holder.Size = baseSize
	holder.Position = restorePosition
	holder.BackgroundTransparency = 1
	holder.Parent = root

	local window = Instance.new("Frame")
	window.Name = "Window"
	window.Size = UDim2.fromScale(1, 1)
	window.BackgroundColor3 = Color3.fromRGB(210, 220, 235)
	window.BackgroundTransparency = 0.56
	window.BorderSizePixel = 0
	window.ZIndex = 2
	window.Parent = holder

	local windowCorner = Instance.new("UICorner")
	windowCorner.CornerRadius = UDim.new(0, baseCornerRadius)
	windowCorner.Parent = window

	local windowBaseStroke = Instance.new("UIStroke")
	windowBaseStroke.Name = "BaseStroke"
	windowBaseStroke.Thickness = 1.2
	windowBaseStroke.Color = Color3.fromRGB(255, 255, 255)
	windowBaseStroke.Transparency = 0.62
	windowBaseStroke.Parent = window

	local windowDynamicStroke = Instance.new("UIStroke")
	windowDynamicStroke.Name = "DynamicStroke"
	windowDynamicStroke.Thickness = 2
	windowDynamicStroke.Color = Color3.fromRGB(255, 255, 255)
	windowDynamicStroke.Transparency = 0.10
	windowDynamicStroke.Parent = window

	local windowEdgeGrad = Instance.new("UIGradient")
	windowEdgeGrad.Rotation = 0
	windowEdgeGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 1.00),
		NumberSequenceKeypoint.new(0.43, 0.24),
		NumberSequenceKeypoint.new(0.50, 0.00),
		NumberSequenceKeypoint.new(0.57, 0.24),
		NumberSequenceKeypoint.new(1.00, 1.00),
	}
	windowEdgeGrad.Parent = windowDynamicStroke

	local windowFillGrad = Instance.new("UIGradient")
	windowFillGrad.Rotation = 90
	windowFillGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 0.40),
		NumberSequenceKeypoint.new(0.45, 0.56),
		NumberSequenceKeypoint.new(1.00, 0.74),
	}
	windowFillGrad.Parent = window

	table.insert(lightingTargets, {
		target = window,
		gradient = windowEdgeGrad,
		offset = 0,
	})

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 236, 1, 0)
	sidebar.BackgroundTransparency = 1
	sidebar.ZIndex = 4
	sidebar.Parent = window

	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, 16)
	sidebarPadding.PaddingBottom = UDim.new(0, 16)
	sidebarPadding.PaddingLeft = UDim.new(0, 16)
	sidebarPadding.PaddingRight = UDim.new(0, 14)
	sidebarPadding.Parent = sidebar

	local split = Instance.new("Frame")
	split.Name = "Split"
	split.Size = UDim2.new(0, 1, 1, -24)
	split.Position = UDim2.new(0, 236, 0, 12)
	split.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	split.BackgroundTransparency = 0.80
	split.BorderSizePixel = 0
	split.ZIndex = 4
	split.Parent = window

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -237, 1, 0)
	content.Position = UDim2.new(0, 237, 0, 0)
	content.BackgroundTransparency = 1
	content.ZIndex = 4
	content.Parent = window

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 18)
	contentPadding.PaddingBottom = UDim.new(0, 18)
	contentPadding.PaddingLeft = UDim.new(0, 18)
	contentPadding.PaddingRight = UDim.new(0, 18)
	contentPadding.Parent = content

	local iconShell = Instance.new("TextButton")
	iconShell.Name = "MinimizedIcon"
	iconShell.AnchorPoint = Vector2.new(0.5, 0.5)
	iconShell.Size = UDim2.fromOffset(minimizedSize.X.Offset, minimizedSize.Y.Offset)
	iconShell.Position = UDim2.new(
	holder.Position.X.Scale,
	holder.Position.X.Offset + holder.Size.X.Offset/2,
	holder.Position.Y.Scale,
	holder.Position.Y.Offset + holder.Size.Y.Offset/2
	)
	iconShell.BackgroundColor3 = Color3.fromRGB(210, 220, 235)
	iconShell.BackgroundTransparency = 0.46
	iconShell.Text = ""
	iconShell.AutoButtonColor = false
	iconShell.Visible = false
	iconShell.ZIndex = 12
	iconShell.Parent = screen

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(1, 0)
	iconCorner.Parent = iconShell

	local iconBaseStroke = Instance.new("UIStroke")
	iconBaseStroke.Thickness = 1.2
	iconBaseStroke.Color = Color3.fromRGB(255, 255, 255)
	iconBaseStroke.Transparency = 0.60
	iconBaseStroke.Parent = iconShell

	local iconDynamicStroke = Instance.new("UIStroke")
	iconDynamicStroke.Thickness = 2
	iconDynamicStroke.Color = Color3.fromRGB(255, 255, 255)
	iconDynamicStroke.Transparency = 0.10
	iconDynamicStroke.Parent = iconShell

	local iconEdgeGrad = Instance.new("UIGradient")
	iconEdgeGrad.Rotation = 0
	iconEdgeGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 1.00),
		NumberSequenceKeypoint.new(0.43, 0.24),
		NumberSequenceKeypoint.new(0.50, 0.00),
		NumberSequenceKeypoint.new(0.57, 0.24),
		NumberSequenceKeypoint.new(1.00, 1.00),
	}
	iconEdgeGrad.Parent = iconDynamicStroke

	local iconFillGrad = Instance.new("UIGradient")
	iconFillGrad.Rotation = 90
	iconFillGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 0.36),
		NumberSequenceKeypoint.new(1.00, 0.70),
	}
	iconFillGrad.Parent = iconShell

	table.insert(lightingTargets, {
		target = iconShell,
		gradient = iconEdgeGrad,
		offset = 0,
	})

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "IconLabel"
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = "♡"
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextScaled = true
	iconLabel.TextColor3 = Color3.fromRGB(42, 42, 42)
	iconLabel.TextTransparency = 1
	iconLabel.ZIndex = 13
	iconLabel.Parent = iconShell

	local function registerLightingTarget(targetObject: GuiObject, gradient: UIGradient)
		table.insert(lightingTargets, {
			target = targetObject,
			gradient = gradient,
			offset = 0,
		})
	end

	local function createGlassBlock(parent, name, size, position, cornerRadius, zindex)
		local frame = Instance.new("Frame")
		frame.Name = name or "GlassBlock"
		if size then
			frame.Size = size
		end
		if position then
			frame.Position = position
		end
		frame.BackgroundColor3 = Color3.fromRGB(210, 220, 235)
		frame.BackgroundTransparency = 0.58
		frame.BorderSizePixel = 0
		frame.ZIndex = zindex or 4
		frame.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, cornerRadius or 18)
		corner.Parent = frame

		local base = Instance.new("UIStroke")
		base.Thickness = 1
		base.Color = Color3.fromRGB(255, 255, 255)
		base.Transparency = 0.70
		base.Parent = frame

		local dyn = Instance.new("UIStroke")
		dyn.Thickness = 1.7
		dyn.Color = Color3.fromRGB(255, 255, 255)
		dyn.Transparency = 0.18
		dyn.Parent = frame

		local dynGrad = Instance.new("UIGradient")
		dynGrad.Rotation = 0
		dynGrad.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0.00, 1.00),
			NumberSequenceKeypoint.new(0.43, 0.36),
			NumberSequenceKeypoint.new(0.50, 0.03),
			NumberSequenceKeypoint.new(0.57, 0.36),
			NumberSequenceKeypoint.new(1.00, 1.00),
		}
		dynGrad.Parent = dyn

		local inner = Instance.new("UIGradient")
		inner.Rotation = 90
		inner.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0.00, 0.44),
			NumberSequenceKeypoint.new(1.00, 0.72),
		}
		inner.Parent = frame

		registerLightingTarget(frame, dynGrad)

		return frame
	end

	local topControls = Instance.new("Frame")
	topControls.Name = "TopControls"
	topControls.Size = UDim2.new(1, 0, 0, 18)
	topControls.BackgroundTransparency = 1
	topControls.ZIndex = 8
	topControls.Parent = sidebar

	local function createMacDot(parent, name, color, x)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.fromOffset(14, 14)
		btn.Position = UDim2.new(0, x, 0, 2)
		btn.BackgroundColor3 = color
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 9
		btn.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Transparency = 0.55
		stroke.Parent = btn

		return btn
	end

	local closeBtn = createMacDot(topControls, "Close", Color3.fromRGB(255, 95, 87), 0)
	local minimizeBtn = createMacDot(topControls, "Minimize", Color3.fromRGB(255, 189, 46), 24)
	local maximizeBtn = createMacDot(topControls, "Maximize", Color3.fromRGB(40, 200, 64), 48)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -90, 0, 34)
	titleLabel.Position = UDim2.new(0, 0, 0, 28)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = tostring(title or "Window")
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextSize = 24
	titleLabel.TextColor3 = Color3.fromRGB(42, 42, 42)
	titleLabel.ZIndex = 8
	titleLabel.Parent = sidebar

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "SubtitleLabel"
	subtitleLabel.Size = UDim2.new(1, -10, 0, 18)
	subtitleLabel.Position = UDim2.new(0, 0, 0, 58)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Text = "Liquid Glass Interface"
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 13
	subtitleLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
	subtitleLabel.ZIndex = 8
	subtitleLabel.Parent = sidebar

	local tabHost = createGlassBlock(sidebar, "TabHost", UDim2.new(1, 0, 1, -96), UDim2.new(0, 0, 0, 92), 24, 6)

	local tabHostPadding = Instance.new("UIPadding")
	tabHostPadding.PaddingTop = UDim.new(0, 10)
	tabHostPadding.PaddingBottom = UDim.new(0, 10)
	tabHostPadding.PaddingLeft = UDim.new(0, 10)
	tabHostPadding.PaddingRight = UDim.new(0, 10)
	tabHostPadding.Parent = tabHost

	local tabList = Instance.new("ScrollingFrame")
	tabList.Name = "TabList"
	tabList.Size = UDim2.fromScale(1, 1)
	tabList.BackgroundTransparency = 1
	tabList.BorderSizePixel = 0
	tabList.ScrollBarThickness = 0
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabList.CanvasSize = UDim2.new()
	tabList.ZIndex = 7
	tabList.Parent = tabHost

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.Parent = tabList

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 58)
	header.BackgroundTransparency = 1
	header.ZIndex = 6
	header.Parent = content

	local headerTitle = Instance.new("TextLabel")
	headerTitle.Name = "HeaderTitle"
	headerTitle.Size = UDim2.new(1, 0, 0, 30)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Text = tostring(title or "Window")
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	headerTitle.Font = Enum.Font.GothamSemibold
	headerTitle.TextSize = 26
	headerTitle.TextColor3 = Color3.fromRGB(52, 52, 52)
	headerTitle.ZIndex = 7
	headerTitle.Parent = header

	local headerDesc = Instance.new("TextLabel")
	headerDesc.Name = "HeaderDesc"
	headerDesc.Size = UDim2.new(1, 0, 0, 18)
	headerDesc.Position = UDim2.new(0, 0, 0, 33)
	headerDesc.BackgroundTransparency = 1
	headerDesc.Text = "Select a category from the sidebar."
	headerDesc.TextXAlignment = Enum.TextXAlignment.Left
	headerDesc.Font = Enum.Font.Gotham
	headerDesc.TextSize = 13
	headerDesc.TextColor3 = Color3.fromRGB(108, 108, 108)
	headerDesc.ZIndex = 7
	headerDesc.Parent = header

	local pageContainer = Instance.new("Frame")
	pageContainer.Name = "PageContainer"
	pageContainer.Size = UDim2.new(1, 0, 1, -70)
	pageContainer.Position = UDim2.new(0, 0, 0, 70)
	pageContainer.BackgroundTransparency = 1
	pageContainer.ZIndex = 6
	pageContainer.Parent = content

	local dragArea = Instance.new("TextButton")
	dragArea.Name = "DragArea"
	dragArea.Size = UDim2.new(1, -86, 0, 72)
	dragArea.Position = UDim2.new(0, 86, 0, 0)
	dragArea.BackgroundTransparency = 1
	dragArea.Text = ""
	dragArea.AutoButtonColor = false
	dragArea.ZIndex = 3
	dragArea.Parent = window

	local pages = {}
	local selectedPage = nil
	local selectedButton = nil

	local target = Vector2.new(holder.Position.X.Offset, holder.Position.Y.Offset)
	local current = target
	local dragStartMouse = Vector2.zero
	local dragStartPos = Vector2.zero

	local function setChromeVisible(visible)
		sidebar.Visible = visible
		split.Visible = visible
		content.Visible = visible
		dragArea.Visible = visible
	end

	local function setTabVisual(button, active)
		local body = button:FindFirstChild("Body")
		local label = button:FindFirstChild("Label")
		local accent = button:FindFirstChild("Accent")

		if body and body:IsA("Frame") then
			body.BackgroundTransparency = active and 0.36 or 0.58
		end

		if label and label:IsA("TextLabel") then
			label.TextColor3 = active and Color3.fromRGB(36, 36, 36) or Color3.fromRGB(76, 76, 76)
		end

		if accent and accent:IsA("Frame") then
			accent.BackgroundTransparency = active and 0.10 or 1
		end
	end

	local function switchToPage(page, button, tabTitle)
		if destroyed or minimized then
			return
		end

		if selectedPage then
			selectedPage.Visible = false
		end

		if selectedButton then
			setTabVisual(selectedButton, false)
		end

		selectedPage = page
		selectedButton = button

		page.Visible = true
		page.CanvasPosition = Vector2.zero
		setTabVisual(button, true)

		headerTitle.Text = tostring(tabTitle)
		headerDesc.Text = "Manage " .. tostring(tabTitle) .. " options."
	end

	local function createSection(titleText)
		local section = createGlassBlock(pageContainer, "Section", nil, nil, 24, 6)
		section.AutomaticSize = Enum.AutomaticSize.Y
		section.Size = UDim2.new(1, 0, 0, 0)
		section.BackgroundTransparency = 0.52

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 14)
		pad.PaddingBottom = UDim.new(0, 14)
		pad.PaddingLeft = UDim.new(0, 16)
		pad.PaddingRight = UDim.new(0, 16)
		pad.Parent = section

		local titleObj = Instance.new("TextLabel")
		titleObj.Name = "SectionTitle"
		titleObj.Size = UDim2.new(1, 0, 0, 22)
		titleObj.BackgroundTransparency = 1
		titleObj.Text = titleText
		titleObj.TextXAlignment = Enum.TextXAlignment.Left
		titleObj.Font = Enum.Font.GothamSemibold
		titleObj.TextSize = 18
		titleObj.TextColor3 = Color3.fromRGB(46, 46, 46)
		titleObj.ZIndex = 7
		titleObj.Parent = section

		local stack = Instance.new("Frame")
		stack.Name = "Stack"
		stack.Size = UDim2.new(1, 0, 0, 0)
		stack.Position = UDim2.new(0, 0, 0, 30)
		stack.BackgroundTransparency = 1
		stack.AutomaticSize = Enum.AutomaticSize.Y
		stack.Parent = section

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 10)
		layout.Parent = stack

		return section, stack
	end

	local function createControlShell(parent, height)
		local shell = createGlassBlock(parent, "ControlShell", UDim2.new(1, 0, 0, height), nil, 18, 8)
		shell.BackgroundTransparency = 0.50
		return shell
	end

	local function createText(parent, text, size, font, color, pos, sizeUDim, zindex)
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextYAlignment = Enum.TextYAlignment.Center
		lbl.Font = font
		lbl.TextSize = size
		lbl.TextColor3 = color
		lbl.Position = pos
		lbl.Size = sizeUDim
		lbl.ZIndex = zindex
		lbl.Parent = parent
		return lbl
	end

	local Window = {}

	function Window:CreateTab(name)
		local tabButton = Instance.new("TextButton")
		tabButton.Name = tostring(name) .. "_TabButton"
		tabButton.Size = UDim2.new(1, 0, 0, 48)
		tabButton.BackgroundTransparency = 1
		tabButton.AutoButtonColor = false
		tabButton.Text = ""
		tabButton.ZIndex = 8
		tabButton.Parent = tabList

		local body = createGlassBlock(tabButton, "Body", UDim2.fromScale(1, 1), UDim2.new(), 16, 8)
		body.BackgroundTransparency = 0.58

		local accent = Instance.new("Frame")
		accent.Name = "Accent"
		accent.Size = UDim2.new(0, 4, 1, -14)
		accent.Position = UDim2.new(0, 8, 0, 7)
		accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		accent.BackgroundTransparency = 1
		accent.BorderSizePixel = 0
		accent.ZIndex = 9
		accent.Parent = body

		local accentCorner = Instance.new("UICorner")
		accentCorner.CornerRadius = UDim.new(1, 0)
		accentCorner.Parent = accent

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(1, -26, 1, 0)
		label.Position = UDim2.new(0, 20, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = tostring(name)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 16
		label.TextColor3 = Color3.fromRGB(76, 76, 76)
		label.ZIndex = 10
		label.Parent = body

		local page = Instance.new("ScrollingFrame")
		page.Name = tostring(name) .. "_Page"
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 0
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.CanvasSize = UDim2.new()
		page.Visible = false
		page.ZIndex = 6
		page.Parent = pageContainer

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingTop = UDim.new(0, 2)
		pagePadding.PaddingBottom = UDim.new(0, 2)
		pagePadding.PaddingLeft = UDim.new(0, 2)
		pagePadding.PaddingRight = UDim.new(0, 2)
		pagePadding.Parent = page

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 12)
		pageLayout.Parent = page

		table.insert(pages, page)

		registerConnection(tabButton.MouseButton1Click:Connect(function()
			switchToPage(page, tabButton, name)
		end))

		if #pages == 1 then
			switchToPage(page, tabButton, name)
		else
			setTabVisual(tabButton, false)
		end

		local tab = {}

		function tab:AddSection(sectionTitle)
			local section, stack = createSection(sectionTitle)
			section.Parent = page

			local api = {}

			function api:AddLabel(text)
				local shell = createControlShell(stack, 44)
				return createText(
					shell,
					text,
					15,
					Enum.Font.GothamMedium,
					Color3.fromRGB(46, 46, 46),
					UDim2.new(0, 14, 0, 0),
					UDim2.new(1, -28, 1, 0),
					9
				)
			end

			function api:AddParagraph(head, body)
				local shell = createControlShell(stack, 78)

				createText(
					shell,
					head,
					15,
					Enum.Font.GothamSemibold,
					Color3.fromRGB(42, 42, 42),
					UDim2.new(0, 14, 0, 10),
					UDim2.new(1, -28, 0, 20),
					9
				)

				local bodyLabel = Instance.new("TextLabel")
				bodyLabel.BackgroundTransparency = 1
				bodyLabel.Text = body
				bodyLabel.TextWrapped = true
				bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
				bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
				bodyLabel.Font = Enum.Font.Gotham
				bodyLabel.TextSize = 13
				bodyLabel.TextColor3 = Color3.fromRGB(92, 92, 92)
				bodyLabel.Position = UDim2.new(0, 14, 0, 34)
				bodyLabel.Size = UDim2.new(1, -28, 0, 32)
				bodyLabel.ZIndex = 9
				bodyLabel.Parent = shell

				return bodyLabel
			end

			function api:AddButton(text, callback)
				local shell = createControlShell(stack, 48)

				local button = Instance.new("TextButton")
				button.Size = UDim2.fromScale(1, 1)
				button.BackgroundTransparency = 1
				button.Text = ""
				button.AutoButtonColor = false
				button.ZIndex = 10
				button.Parent = shell

				createText(
					shell,
					text,
					15,
					Enum.Font.GothamMedium,
					Color3.fromRGB(40, 40, 40),
					UDim2.new(0, 14, 0, 0),
					UDim2.new(1, -44, 1, 0),
					9
				)

				local arrow = createText(
					shell,
					"›",
					22,
					Enum.Font.GothamSemibold,
					Color3.fromRGB(92, 92, 92),
					UDim2.new(1, -24, 0, -1),
					UDim2.new(0, 14, 1, 0),
					9
				)
				arrow.TextXAlignment = Enum.TextXAlignment.Center

				registerConnection(button.MouseEnter:Connect(function()
					tween(shell, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.42
					})
				end))

				registerConnection(button.MouseLeave:Connect(function()
					tween(shell, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.50
					})
				end))

				registerConnection(button.MouseButton1Click:Connect(function()
					if callback then
						callback()
					end
				end))

				return button
			end

			function api:AddToggle(text, callback, defaultValue)
				local state = defaultValue == true
				local shell = createControlShell(stack, 54)

				createText(
					shell,
					text,
					15,
					Enum.Font.GothamMedium,
					Color3.fromRGB(40, 40, 40),
					UDim2.new(0, 14, 0, 0),
					UDim2.new(1, -96, 1, 0),
					9
				)

				local track = createGlassBlock(shell, "ToggleTrack", UDim2.fromOffset(56, 30), UDim2.new(1, -70, 0.5, -15), 15, 9)

				local knob = Instance.new("Frame")
				knob.Name = "Knob"
				knob.Size = UDim2.fromOffset(24, 24)
				knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				knob.BackgroundTransparency = 0.06
				knob.BorderSizePixel = 0
				knob.ZIndex = 11
				knob.Parent = track

				local knobCorner = Instance.new("UICorner")
				knobCorner.CornerRadius = UDim.new(1, 0)
				knobCorner.Parent = knob

				local knobStroke = Instance.new("UIStroke")
				knobStroke.Thickness = 1
				knobStroke.Color = Color3.fromRGB(255, 255, 255)
				knobStroke.Transparency = 0.35
				knobStroke.Parent = knob

				local button = Instance.new("TextButton")
				button.Size = UDim2.fromScale(1, 1)
				button.BackgroundTransparency = 1
				button.Text = ""
				button.AutoButtonColor = false
				button.ZIndex = 12
				button.Parent = shell

				local function renderToggle(animated)
					local trackTransparency = state and 0.30 or 0.48
					local knobPos = state and UDim2.new(0, 29, 0, 3) or UDim2.new(0, 3, 0, 3)

					if animated then
						tween(track, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundTransparency = trackTransparency
						})
						tween(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Position = knobPos
						})
					else
						track.BackgroundTransparency = trackTransparency
						knob.Position = knobPos
					end
				end

				renderToggle(false)

				registerConnection(button.MouseButton1Click:Connect(function()
					state = not state
					renderToggle(true)
					if callback then
						callback(state)
					end
				end))

				local apiToggle = {}

				function apiToggle:Set(value)
					state = value == true
					renderToggle(true)
					if callback then
						callback(state)
					end
				end

				function apiToggle:Get()
					return state
				end

				return apiToggle
			end

			function api:AddInput(text, callback, placeholder)
				local shell = createControlShell(stack, 54)

				createText(
					shell,
					text,
					15,
					Enum.Font.GothamMedium,
					Color3.fromRGB(40, 40, 40),
					UDim2.new(0, 14, 0, 0),
					UDim2.new(0.42, -8, 1, 0),
					9
				)

				local inputGlass = createGlassBlock(shell, "InputGlass", UDim2.new(0.58, -18, 0, 38), UDim2.new(0.42, 6, 0.5, -19), 14, 9)
				inputGlass.BackgroundTransparency = 0.48

				local box = Instance.new("TextBox")
				box.Name = "InputBox"
				box.Size = UDim2.new(1, -18, 1, 0)
				box.Position = UDim2.new(0, 9, 0, 0)
				box.BackgroundTransparency = 1
				box.ClearTextOnFocus = false
				box.PlaceholderText = placeholder or ""
				box.Text = ""
				box.TextXAlignment = Enum.TextXAlignment.Left
				box.TextYAlignment = Enum.TextYAlignment.Center
				box.Font = Enum.Font.Gotham
				box.TextSize = 14
				box.TextColor3 = Color3.fromRGB(44, 44, 44)
				box.PlaceholderColor3 = Color3.fromRGB(124, 124, 124)
				box.ZIndex = 10
				box.Parent = inputGlass

				registerConnection(box.Focused:Connect(function()
					tween(inputGlass, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.40
					})
				end))

				registerConnection(box.FocusLost:Connect(function(enterPressed)
					tween(inputGlass, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.48
					})
					if callback then
						callback(box.Text, enterPressed)
					end
				end))

				local apiInput = {}

				function apiInput:Set(value)
					box.Text = tostring(value)
				end

				function apiInput:Get()
					return box.Text
				end

				return apiInput
			end

			return api
		end

		function tab:AddLabel(text)
			local section = tab:AddSection("Info")
			return section:AddLabel(text)
		end

		function tab:AddParagraph(head, body)
			local section = tab:AddSection("Description")
			return section:AddParagraph(head, body)
		end

		function tab:AddButton(text, callback)
			local section = tab:AddSection("Actions")
			return section:AddButton(text, callback)
		end

		function tab:AddToggle(text, callback, defaultValue)
			local section = tab:AddSection("Options")
			return section:AddToggle(text, callback, defaultValue)
		end

		function tab:AddInput(text, callback, placeholder)
			local section = tab:AddSection("Input")
			return section:AddInput(text, callback, placeholder)
		end

		return tab
	end

	function Window:Destroy()
		cleanup(screen)
	end

	function Window:Maximize(state)
		if destroyed then
			return
		end

		if minimized then
			self:Minimize(false)
		end

		if typeof(state) == "boolean" then
			maximized = state
		else
			maximized = not maximized
		end

		local nextSize = maximized and maxSize or baseSize

		tween(holder, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = nextSize
		})
	end

	function Window:Minimize(state)
		if destroyed then
			return
		end

		local nextState
		if typeof(state) == "boolean" then
			nextState = state
		else
			nextState = not minimized
		end

		if nextState == minimized then
			return
		end

		minimized = nextState

		if minimized then
			restorePosition = holder.Position

			setChromeVisible(false)

			iconShell.Visible = true

			iconShell.Position = holder.Position

			tween(iconShell, TweenInfo.new(0.25), {
				Size = minimizedSize
			})

			tween(holder, TweenInfo.new(0.25), {
				Size = minimizedSize
			})

			tween(iconLabel, TweenInfo.new(0.2), {
				TextTransparency = 0
			})

		else
			setChromeVisible(true)

			tween(holder, TweenInfo.new(0.25), {
				Size = maximized and maxSize or baseSize,
				Position = restorePosition
			})

			tween(iconShell, TweenInfo.new(0.25), {
				Size = UDim2.fromOffset(0,0)
			})

			iconShell.Position = holder.Position

			tween(iconLabel, TweenInfo.new(0.2), {
				TextTransparency = 1
			})

			task.delay(0.2,function()
				if not minimized then
					iconShell.Visible = false
				end
			end)
		end
	end

	registerConnection(closeBtn.MouseButton1Click:Connect(function()
		Window:Destroy()
	end))

	registerConnection(minimizeBtn.MouseButton1Click:Connect(function()
		Window:Minimize()
	end))

	registerConnection(maximizeBtn.MouseButton1Click:Connect(function()
		Window:Maximize()
	end))

	registerConnection(iconShell.MouseButton1Click:Connect(function()
		Window:Minimize(false)
	end))

	registerConnection(dragArea.InputBegan:Connect(function(input)
		if destroyed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStartMouse = UserInputService:GetMouseLocation()
			dragStartPos = target
		end
	end))

	registerConnection(dragArea.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))

	registerConnection(UserInputService.InputChanged:Connect(function(input)
		if destroyed then
			return
		end

		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UserInputService:GetMouseLocation() - dragStartMouse
			target = dragStartPos + delta
			restorePosition = UDim2.new(0.5, target.X, 0.5, target.Y)
		end
	end))

	registerConnection(RunService.RenderStepped:Connect(function(dt)
		if minimized then
			iconShell.Position = holder.Position
		end
		if destroyed then
			return
		end

		local follow = 1 - math.exp(-dt * 12)
		current = current:Lerp(target, follow)

		if not minimized then
			holder.Position = UDim2.new(0.5, current.X, 0.5, current.Y)
		end

		local mouse = UserInputService:GetMouseLocation()

		for _, item in ipairs(lightingTargets) do
			local targetObject = item.target
			local gradient = item.gradient

			if targetObject and gradient and targetObject.Parent and gradient.Parent then
				local absPos = targetObject.AbsolutePosition
				local absSize = targetObject.AbsoluteSize

				local relX = (mouse.X - absPos.X) / math.max(absSize.X, 1)
				local relY = (mouse.Y - absPos.Y) / math.max(absSize.Y, 1)

				relX = math.clamp(relX, 0, 1)
				relY = math.clamp(relY, 0, 1)

				local center = Vector2.new(0.5, 0.5)
				local dir = Vector2.new(relX, relY) - center

				local angle = math.atan2(dir.Y, dir.X)
				local normalized = (angle / math.pi + 1) / 2

				local targetOffset = normalized - 0.5
				local smoothFactor = 1 - math.exp(-dt * 2.2)

				item.offset = item.offset + (targetOffset - item.offset) * smoothFactor
				gradient.Offset = Vector2.new(item.offset, 0)
			end
		end
	end))

	return Window
end

return function()
	return Library
end
