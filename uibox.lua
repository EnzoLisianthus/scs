--!strict

local Library = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local WINDOW_NAME = "LiquidGlassDynamic"

local function safeDisconnect(conn)
	if conn and typeof(conn) == "RBXScriptConnection" then
		pcall(function()
			conn:Disconnect()
		end)
	end
end

function Library:CreateWindow(title)
	local playerGui = player:WaitForChild("PlayerGui")

	local existing = playerGui:FindFirstChild(WINDOW_NAME)
	if existing then
		existing:Destroy()
	end

	local connections = {}
	local edgeGradients = {}
	local destroyed = false
	local minimized = false
	local maximized = false

	local baseSize = UDim2.fromOffset(860, 560)
	local maxSize = UDim2.fromOffset(1120, 720)
	local minSize = UDim2.fromOffset(300, 92)

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
	holder.Position = UDim2.new(0.5, -430, 0.5, -280)
	holder.BackgroundTransparency = 1
	holder.Parent = root

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.fromScale(0.5, 0.5)
	shadow.Size = UDim2.new(1, 34, 1, 34)
	shadow.BackgroundColor3 = Color3.fromRGB(160, 175, 200)
	shadow.BackgroundTransparency = 0.88
	shadow.ZIndex = 0
	shadow.Parent = holder

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 38)
	shadowCorner.Parent = shadow

	local shadowGrad = Instance.new("UIGradient")
	shadowGrad.Rotation = 90
	shadowGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 0.18),
		NumberSequenceKeypoint.new(0.45, 0.45),
		NumberSequenceKeypoint.new(1.00, 0.85),
	}
	shadowGrad.Parent = shadow

	local window = Instance.new("Frame")
	window.Name = "Window"
	window.Size = UDim2.fromScale(1, 1)
	window.BackgroundColor3 = Color3.fromRGB(210, 220, 235)
	window.BackgroundTransparency = 0.58
	window.BorderSizePixel = 0
	window.ZIndex = 1
	window.Parent = holder

	local windowCorner = Instance.new("UICorner")
	windowCorner.CornerRadius = UDim.new(0, 34)
	windowCorner.Parent = window

	local baseStroke = Instance.new("UIStroke")
	baseStroke.Name = "BaseStroke"
	baseStroke.Thickness = 1.25
	baseStroke.Color = Color3.fromRGB(255, 255, 255)
	baseStroke.Transparency = 0.62
	baseStroke.Parent = window

	local dynamicStroke = Instance.new("UIStroke")
	dynamicStroke.Name = "DynamicStroke"
	dynamicStroke.Thickness = 2
	dynamicStroke.Color = Color3.fromRGB(255, 255, 255)
	dynamicStroke.Transparency = 0.12
	dynamicStroke.Parent = window

	local edgeGrad = Instance.new("UIGradient")
	edgeGrad.Rotation = 0
	edgeGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 1.00),
		NumberSequenceKeypoint.new(0.42, 0.28),
		NumberSequenceKeypoint.new(0.50, 0.00),
		NumberSequenceKeypoint.new(0.58, 0.28),
		NumberSequenceKeypoint.new(1.00, 1.00),
	}
	edgeGrad.Parent = dynamicStroke
	table.insert(edgeGradients, edgeGrad)

	local windowGrad = Instance.new("UIGradient")
	windowGrad.Rotation = 90
	windowGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 0.42),
		NumberSequenceKeypoint.new(0.55, 0.58),
		NumberSequenceKeypoint.new(1.00, 0.76),
	}
	windowGrad.Parent = window

	local verticalSplit = Instance.new("Frame")
	verticalSplit.Name = "VerticalSplit"
	verticalSplit.Size = UDim2.new(0, 1, 1, -22)
	verticalSplit.Position = UDim2.new(0, 248, 0, 11)
	verticalSplit.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	verticalSplit.BackgroundTransparency = 0.78
	verticalSplit.BorderSizePixel = 0
	verticalSplit.ZIndex = 2
	verticalSplit.Parent = window

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 248, 1, 0)
	sidebar.BackgroundTransparency = 1
	sidebar.ZIndex = 2
	sidebar.Parent = window

	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, 16)
	sidebarPadding.PaddingLeft = UDim.new(0, 16)
	sidebarPadding.PaddingRight = UDim.new(0, 14)
	sidebarPadding.PaddingBottom = UDim.new(0, 16)
	sidebarPadding.Parent = sidebar

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.new(0, 249, 0, 0)
	content.Size = UDim2.new(1, -249, 1, 0)
	content.BackgroundTransparency = 1
	content.ZIndex = 2
	content.Parent = window

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 16)
	contentPadding.PaddingLeft = UDim.new(0, 18)
	contentPadding.PaddingRight = UDim.new(0, 18)
	contentPadding.PaddingBottom = UDim.new(0, 18)
	contentPadding.Parent = content

	local function registerConnection(conn)
		table.insert(connections, conn)
		return conn
	end

	local function cleanup()
		if destroyed then
			return
		end
		destroyed = true

		for _, conn in ipairs(connections) do
			safeDisconnect(conn)
		end
		table.clear(connections)
		table.clear(edgeGradients)

		if screen then
			screen:Destroy()
		end
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
		frame.BackgroundTransparency = 0.60
		frame.BorderSizePixel = 0
		frame.ZIndex = zindex or 3
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
		dyn.Thickness = 1.8
		dyn.Color = Color3.fromRGB(255, 255, 255)
		dyn.Transparency = 0.20
		dyn.Parent = frame

		local gradDyn = Instance.new("UIGradient")
		gradDyn.Rotation = 0
		gradDyn.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0.00, 1.00),
			NumberSequenceKeypoint.new(0.43, 0.38),
			NumberSequenceKeypoint.new(0.50, 0.02),
			NumberSequenceKeypoint.new(0.57, 0.38),
			NumberSequenceKeypoint.new(1.00, 1.00),
		}
		gradDyn.Parent = dyn
		table.insert(edgeGradients, gradDyn)

		local fillGrad = Instance.new("UIGradient")
		fillGrad.Rotation = 90
		fillGrad.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0.00, 0.45),
			NumberSequenceKeypoint.new(1.00, 0.72),
		}
		fillGrad.Parent = frame

		return frame
	end

	local topControls = Instance.new("Frame")
	topControls.Name = "TopControls"
	topControls.Size = UDim2.new(1, 0, 0, 18)
	topControls.BackgroundTransparency = 1
	topControls.ZIndex = 4
	topControls.Parent = sidebar

	local function createMacDot(parent, name, color, x)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.fromOffset(14, 14)
		btn.Position = UDim2.new(0, x, 0, 2)
		btn.BackgroundColor3 = color
		btn.AutoButtonColor = false
		btn.Text = ""
		btn.ZIndex = 5
		btn.Parent = parent

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = btn

		local s = Instance.new("UIStroke")
		s.Thickness = 1
		s.Color = Color3.fromRGB(255, 255, 255)
		s.Transparency = 0.55
		s.Parent = btn

		return btn
	end

	local closeBtn = createMacDot(topControls, "Close", Color3.fromRGB(255, 95, 87), 0)
	local minimizeBtn = createMacDot(topControls, "Minimize", Color3.fromRGB(255, 189, 46), 24)
	local maximizeBtn = createMacDot(topControls, "Maximize", Color3.fromRGB(40, 200, 64), 48)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -86, 0, 34)
	titleLabel.Position = UDim2.new(0, 0, 0, 28)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = tostring(title or "Window")
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextSize = 24
	titleLabel.TextColor3 = Color3.fromRGB(42, 42, 42)
	titleLabel.ZIndex = 4
	titleLabel.Parent = sidebar

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "SubtitleLabel"
	subtitleLabel.Size = UDim2.new(1, -10, 0, 20)
	subtitleLabel.Position = UDim2.new(0, 0, 0, 58)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Text = "Liquid Glass Interface"
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 13
	subtitleLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
	subtitleLabel.ZIndex = 4
	subtitleLabel.Parent = sidebar

	local tabListHost = createGlassBlock(sidebar, "TabListHost", UDim2.new(1, 0, 1, -98), UDim2.new(0, 0, 0, 92), 22, 3)

	local tabListPadding = Instance.new("UIPadding")
	tabListPadding.PaddingTop = UDim.new(0, 12)
	tabListPadding.PaddingBottom = UDim.new(0, 12)
	tabListPadding.PaddingLeft = UDim.new(0, 10)
	tabListPadding.PaddingRight = UDim.new(0, 10)
	tabListPadding.Parent = tabListHost

	local tabList = Instance.new("ScrollingFrame")
	tabList.Name = "TabList"
	tabList.Size = UDim2.fromScale(1, 1)
	tabList.BackgroundTransparency = 1
	tabList.BorderSizePixel = 0
	tabList.ScrollBarThickness = 0
	tabList.CanvasSize = UDim2.new()
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabList.ZIndex = 4
	tabList.Parent = tabListHost

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Padding = UDim.new(0, 8)
	tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabListLayout.Parent = tabList

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 58)
	header.BackgroundTransparency = 1
	header.ZIndex = 3
	header.Parent = content

	local headerTitle = Instance.new("TextLabel")
	headerTitle.Name = "HeaderTitle"
	headerTitle.Size = UDim2.new(1, -8, 0, 30)
	headerTitle.Position = UDim2.new(0, 0, 0, 0)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Text = tostring(title or "Window")
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	headerTitle.Font = Enum.Font.GothamSemibold
	headerTitle.TextSize = 26
	headerTitle.TextColor3 = Color3.fromRGB(52, 52, 52)
	headerTitle.ZIndex = 4
	headerTitle.Parent = header

	local headerDesc = Instance.new("TextLabel")
	headerDesc.Name = "HeaderDesc"
	headerDesc.Size = UDim2.new(1, -8, 0, 20)
	headerDesc.Position = UDim2.new(0, 0, 0, 31)
	headerDesc.BackgroundTransparency = 1
	headerDesc.Text = "Select a category from the sidebar."
	headerDesc.TextXAlignment = Enum.TextXAlignment.Left
	headerDesc.Font = Enum.Font.Gotham
	headerDesc.TextSize = 13
	headerDesc.TextColor3 = Color3.fromRGB(108, 108, 108)
	headerDesc.ZIndex = 4
	headerDesc.Parent = header

	local pageContainer = Instance.new("Frame")
	pageContainer.Name = "PageContainer"
	pageContainer.Size = UDim2.new(1, 0, 1, -66)
	pageContainer.Position = UDim2.new(0, 0, 0, 66)
	pageContainer.BackgroundTransparency = 1
	pageContainer.ZIndex = 3
	pageContainer.Parent = content

	local pages = {}
	local tabButtons = {}
	local selectedPage = nil
	local selectedButton = nil

	local dragArea = Instance.new("TextButton")
	dragArea.Name = "DragArea"
	dragArea.Size = UDim2.new(1, 0, 0, 72)
	dragArea.BackgroundTransparency = 1
	dragArea.Text = ""
	dragArea.AutoButtonColor = false
	dragArea.ZIndex = 6
	dragArea.Parent = window

	local target = Vector2.new(holder.Position.X.Offset, holder.Position.Y.Offset)
	local current = target
	local dragging = false
	local dragStartMouse = Vector2.zero
	local dragStartPos = Vector2.zero

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
		end
	end))

	local function setTabVisual(button, active)
		local body = button:FindFirstChild("Body")
		local label = button:FindFirstChild("Label")
		local accent = button:FindFirstChild("Accent")

		if body and body:IsA("Frame") then
			body.BackgroundTransparency = active and 0.38 or 0.58
		end

		if label and label:IsA("TextLabel") then
			label.TextColor3 = active and Color3.fromRGB(36, 36, 36) or Color3.fromRGB(76, 76, 76)
			label.TextTransparency = active and 0 or 0.04
		end

		if accent and accent:IsA("Frame") then
			accent.BackgroundTransparency = active and 0.12 or 1
		end
	end

	local function switchToPage(page, button, tabTitle)
		if destroyed then
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
		local section = createGlassBlock(pageContainer, "UnusedSection", nil, nil, 24, 3)
		section.AutomaticSize = Enum.AutomaticSize.Y
		section.Size = UDim2.new(1, 0, 0, 0)
		section.BackgroundTransparency = 0.54

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
		titleObj.ZIndex = 5
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
		local shell = createGlassBlock(parent, "ControlShell", UDim2.new(1, 0, 0, height), nil, 18, 5)
		shell.BackgroundTransparency = 0.52
		return shell
	end

	local function createText(parent, text, size, weight, color, pos, width, z)
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextYAlignment = Enum.TextYAlignment.Center
		lbl.Font = weight
		lbl.TextSize = size
		lbl.TextColor3 = color
		lbl.Position = pos
		lbl.Size = width
		lbl.ZIndex = z
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
		tabButton.ZIndex = 5
		tabButton.Parent = tabList

		local body = createGlassBlock(tabButton, "Body", UDim2.fromScale(1, 1), UDim2.new(), 16, 5)
		body.BackgroundTransparency = 0.58

		local accent = Instance.new("Frame")
		accent.Name = "Accent"
		accent.Size = UDim2.new(0, 4, 1, -14)
		accent.Position = UDim2.new(0, 8, 0, 7)
		accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		accent.BackgroundTransparency = 1
		accent.BorderSizePixel = 0
		accent.ZIndex = 6
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
		label.ZIndex = 7
		label.Parent = body

		local page = Instance.new("ScrollingFrame")
		page.Name = tostring(name) .. "_Page"
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 0
		page.CanvasSize = UDim2.new()
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.ZIndex = 3
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
		table.insert(tabButtons, tabButton)

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

				local labelObj = createText(
					shell,
					text,
					15,
					Enum.Font.GothamMedium,
					Color3.fromRGB(46, 46, 46),
					UDim2.new(0, 14, 0, 0),
					UDim2.new(1, -28, 1, 0),
					6
				)

				return labelObj
			end

			function api:AddParagraph(head, body)
				local shell = createControlShell(stack, 74)

				createText(
					shell,
					head,
					15,
					Enum.Font.GothamSemibold,
					Color3.fromRGB(42, 42, 42),
					UDim2.new(0, 14, 0, 10),
					UDim2.new(1, -28, 0, 20),
					6
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
				bodyLabel.Position = UDim2.new(0, 14, 0, 32)
				bodyLabel.Size = UDim2.new(1, -28, 0, 30)
				bodyLabel.ZIndex = 6
				bodyLabel.Parent = shell

				return bodyLabel
			end

			function api:AddButton(text, callback)
				local shell = createControlShell(stack, 48)

				local button = Instance.new("TextButton")
				button.Name = "ActionButton"
				button.Size = UDim2.new(1, 0, 1, 0)
				button.BackgroundTransparency = 1
				button.AutoButtonColor = false
				button.Text = ""
				button.ZIndex = 7
				button.Parent = shell

				local labelObj = createText(
					shell,
					text,
					15,
					Enum.Font.GothamMedium,
					Color3.fromRGB(40, 40, 40),
					UDim2.new(0, 14, 0, 0),
					UDim2.new(1, -42, 1, 0),
					6
				)

				local arrow = createText(
					shell,
					"›",
					22,
					Enum.Font.GothamSemibold,
					Color3.fromRGB(92, 92, 92),
					UDim2.new(1, -24, 0, -1),
					UDim2.new(0, 14, 1, 0),
					6
				)
				arrow.TextXAlignment = Enum.TextXAlignment.Center

				registerConnection(button.MouseEnter:Connect(function()
					shell.BackgroundTransparency = 0.44
				end))

				registerConnection(button.MouseLeave:Connect(function()
					shell.BackgroundTransparency = 0.52
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
					UDim2.new(1, -92, 1, 0),
					6
				)

				local track = createGlassBlock(shell, "ToggleTrack", UDim2.fromOffset(56, 30), UDim2.new(1, -70, 0.5, -15), 15, 6)
				track.BackgroundTransparency = state and 0.32 or 0.48

				local knob = Instance.new("Frame")
				knob.Name = "Knob"
				knob.Size = UDim2.fromOffset(24, 24)
				knob.Position = state and UDim2.new(0, 29, 0, 3) or UDim2.new(0, 3, 0, 3)
				knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				knob.BackgroundTransparency = 0.06
				knob.BorderSizePixel = 0
				knob.ZIndex = 8
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
				button.AutoButtonColor = false
				button.Text = ""
				button.ZIndex = 9
				button.Parent = shell

				local function renderToggle()
					track.BackgroundTransparency = state and 0.30 or 0.48
					knob.Position = state and UDim2.new(0, 29, 0, 3) or UDim2.new(0, 3, 0, 3)
				end

				renderToggle()

				registerConnection(button.MouseButton1Click:Connect(function()
					state = not state
					renderToggle()
					if callback then
						callback(state)
					end
				end))

				local apiToggle = {}

				function apiToggle:Set(value)
					state = value == true
					renderToggle()
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
					6
				)

				local boxShell = createGlassBlock(shell, "InputGlass", UDim2.new(0.58, -18, 0, 38), UDim2.new(0.42, 6, 0.5, -19), 14, 6)
				boxShell.BackgroundTransparency = 0.50

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
				box.ZIndex = 7
				box.Parent = boxShell

				registerConnection(box.FocusLost:Connect(function(enterPressed)
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
		cleanup()
	end

	function Window:Minimize(state)
		if destroyed then
			return
		end

		if typeof(state) == "boolean" then
			minimized = state
		else
			minimized = not minimized
		end

		if minimized then
			content.Visible = false
			verticalSplit.Visible = false
			holder.Size = minSize
		else
			content.Visible = true
			verticalSplit.Visible = true
			holder.Size = maximized and maxSize or baseSize
		end
	end

	function Window:Maximize(state)
		if destroyed then
			return
		end

		if typeof(state) == "boolean" then
			maximized = state
		else
			maximized = not maximized
		end

		if minimized then
			minimized = false
			content.Visible = true
			verticalSplit.Visible = true
		end

		holder.Size = maximized and maxSize or baseSize
	end

	registerConnection(closeBtn.MouseButton1Click:Connect(function()
		cleanup()
	end))

	registerConnection(minimizeBtn.MouseButton1Click:Connect(function()
		Window:Minimize()
	end))

	registerConnection(maximizeBtn.MouseButton1Click:Connect(function()
		Window:Maximize()
	end))

	local smoothOffset = 0

	registerConnection(RunService.RenderStepped:Connect(function(dt)
		if destroyed then
			return
		end

		local a = 1 - math.exp(-dt * 12)
		current = current:Lerp(target, a)

		holder.Position = UDim2.new(0.5, current.X, 0.5, current.Y)

		local mouse = UserInputService:GetMouseLocation()
		local absPos = window.AbsolutePosition
		local absSize = window.AbsoluteSize

		local relX = (mouse.X - absPos.X) / math.max(absSize.X, 1)
		local relY = (mouse.Y - absPos.Y) / math.max(absSize.Y, 1)

		relX = math.clamp(relX, 0, 1)
		relY = math.clamp(relY, 0, 1)

		local center = Vector2.new(0.5, 0.5)
		local dir = Vector2.new(relX, relY) - center

		local angle = math.atan2(dir.Y, dir.X)
		local normalized = (angle / math.pi + 1) / 2

		local targetOffset = normalized - 0.5
		local smoothFactor = 1 - math.exp(-dt * 8)
		smoothOffset = smoothOffset + (targetOffset - smoothOffset) * smoothFactor

		for _, gradient in ipairs(edgeGradients) do
			if gradient and gradient.Parent then
				gradient.Offset = Vector2.new(smoothOffset, 0)
			end
		end
	end))

	return Window
end

return function()
	return Library
end
