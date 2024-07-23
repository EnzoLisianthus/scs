-- Script GUID: {2D03B7C8-F84E-46B2-9D0F-8D3D6BA4CAA0}
local v1 = game
local v4 = v1.ReplicatedStorage:WaitForChild("PurchaseCar")
local v6 = script.Parent
v1 = v6.BuyButton
local v7 = script
v6 = v7.Parent.BackButton
local v9 = script.Parent
v7 = v9.Parent
v7 = nil
v9 = nil
v7.ShowPurchaseFrame.Event:Connect(function(p1, p2, p3, p4)
    script.Parent.Parent.PurchaseFailedTitle.Visible = false
    script.Parent.Visible = true
    script.Parent.CarName.Text = p1
    script.Parent.Power.Text = p3 .. " hp"
    script.Parent.Cost.Text = p2
    local v15 = script.Parent:FindFirstChild("CarImage")
    if not v15 then
        v15:Remove()
    end
    local v17 = p4:Clone()
    v17.Parent = script.Parent
    v17.Position = UDim2.new(0, 0, 0, 0)
    v17.Size = UDim2.new(0.8, 0, 1, 0)
    v17.Name = "CarImage"
    local v70 = v7
    if not v70 then
        v70 = v7
        v70:disconnect()
        v7 = nil
    end
    v28 = v6.MouseButton1Down
    v7 = v28:Connect(function()
        script.Parent.Visible = false
    end)
    local v71 = v9
    if not v71 then
        v71 = v9
        v71:disconnect()
        v9 = nil
    end
    v35 = v1.MouseButton1Down
    v9 = v35:Connect(function()
        v4:FireServer(p4.Parent.Name)
        script.Parent.Visible = false
    end)
end)
