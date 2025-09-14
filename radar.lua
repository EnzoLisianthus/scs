-- ⚠️ StarterPlayerScripts 안의 LocalScript로 넣으세요

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 🔵 미니맵 설정
local MAP_SIZE = 500
local MAP_RANGE = 300
local DOT_SIZE = 3

-- 🟣 중심 원 (미니맵 배경)
local minimapCircle = Drawing.new("Circle")
minimapCircle.Visible = true
minimapCircle.Color = Color3.fromRGB(40, 40, 40)
minimapCircle.Filled = true
minimapCircle.Radius = MAP_SIZE / 2
minimapCircle.Position = Vector2.new(300, 300)
minimapCircle.ZIndex = 0
minimapCircle.Transparency = 0.5

-- 🟢 내 방향 표시 화살표
local arrowLine = Drawing.new("Line")
arrowLine.Thickness = 2
arrowLine.Color = Color3.fromRGB(0, 255, 0)
arrowLine.ZIndex = 2

-- 다른 플레이어 점 저장
local dots = {}

-- 워크스페이스 Head 캐싱
local heads = {}

-- 초기 캐싱
for _, obj in ipairs(workspace:GetDescendants()) do
    if (obj:IsA("BasePart") or obj:IsA("MeshPart"))
       and obj.Name == "Head"
       and obj.Parent ~= localPlayer.Character then
        heads[obj] = true
    end
end

-- DescendantAdded: 새 Head 추가
workspace.DescendantAdded:Connect(function(obj)
    if (obj:IsA("BasePart") or obj:IsA("MeshPart"))
       and obj.Name == "Head"
       and obj.Parent ~= localPlayer.Character then
        heads[obj] = true
    end
end)

-- DescendantRemoving: Head 제거 시 dot 제거
workspace.DescendantRemoving:Connect(function(obj)
    if heads[obj] then
        heads[obj] = nil
        local dot = dots[obj]
        if dot then
            dot.Visible = false
            dots[obj] = nil
        end
    end
end)

-- 거리 -> 화면좌표 변환
local function worldToMinimap(pos, myHead, forward, right)
    local offset = pos - myHead.Position
    local localX = offset:Dot(right)
    local localZ = offset:Dot(forward)
    local scale = (MAP_SIZE / 2) / MAP_RANGE
    local minimapPos = Vector2.new(localX * scale, -localZ * scale)
    return minimapCircle.Position + minimapPos
end

-- 🔄 업데이트
RunService.RenderStepped:Connect(function()
    local myChar = localPlayer.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myHead then return end

    -- forward/right 방향
    local camCFrame = camera.CFrame
    local forward = camCFrame.LookVector * Vector3.new(1,0,1)
    forward = forward.Unit
    local right = camCFrame.RightVector * Vector3.new(1,0,1)
    right = right.Unit

    -- 🔴 캐싱된 Head 순회
    for headObj, _ in pairs(heads) do
        if headObj.Parent then
            local dot = dots[headObj] or Drawing.new("Circle")
            dots[headObj] = dot
            dot.Radius = DOT_SIZE
            dot.Color = Color3.fromRGB(255, 0, 0)
            dot.Filled = true
            dot.Visible = true
            dot.ZIndex = 1

            local pos = worldToMinimap(headObj.Position, myHead, forward, right)
            local dist = (headObj.Position - myHead.Position).Magnitude
            if dist <= MAP_RANGE then
                dot.Position = pos
            else
                dot.Position = minimapCircle.Position
            end
        end
    end
end)

