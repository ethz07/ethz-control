local UserInputService = game:GetService("UserInputService")
local Drop = game.Workspace.Ignored:WaitForChild("Drop")
local totalCash = 0
local CashLabel
local MainFrame

function setGUI()
    local HermesGUI = Instance.new("ScreenGui")
    MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local TextLabel = Instance.new("TextLabel")

    HermesGUI.Name = "HermesGUI"
    HermesGUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    HermesGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = HermesGUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -103, 0.5, -34)
    MainFrame.Size = UDim2.new(0, 206, 0, 68)

    UICorner.Parent = MainFrame

    TextLabel.Name = "CashLabel"
    TextLabel.Parent = MainFrame
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Position = UDim2.new(0, 0, 0.5, -25)
    TextLabel.Size = UDim2.new(1, 0, 0, 50)
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.Text = "$0"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 24.000
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Center

    return TextLabel
end

local function createGUIIfNeeded()
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui:FindFirstChild("HermesGUI") then
        return setGUI()
    else
        return playerGui.HermesGUI.MainFrame.CashLabel
    end
end

local function updateCashLabel()
    if CashLabel then
        CashLabel.Text = "$" .. string.format("%d", totalCash):gsub('(%d)(%d%d%d)$', '%1,%2')
    else
        warn("CashLabel is nil")
    end
end

local function extractCashAmount(text)
    local amount = string.match(text, "%$%d+[,%.]?%d*")
    if amount then
        local number = amount:match("%d+[,%.]?%d*"):gsub(",", "")
        return tonumber(number)
    else
        return 0
    end
end

local function updateTotalCash()
    totalCash = 0
    for _, drop in ipairs(Drop:GetChildren()) do
        if drop:IsA("Part") and drop.Name == "MoneyDrop" then
            local billboardGui = drop:FindFirstChild("BillboardGui")
            if billboardGui then
                local text = billboardGui.TextLabel.Text
                local cashAmount = extractCashAmount(text)
                totalCash = totalCash + cashAmount
            end
        end
    end
    updateCashLabel()
end

Drop.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name == "MoneyDrop" then
        local billboardGui = child:WaitForChild("BillboardGui")
        if billboardGui then
            local text = billboardGui.TextLabel.Text
            local cashAmount = extractCashAmount(text)
            totalCash = totalCash + cashAmount
            updateCashLabel()
        end
    end
end)

Drop.ChildRemoved:Connect(function(child)
    if child:IsA("Part") and child.Name == "MoneyDrop" then
        local billboardGui = child:FindFirstChild("BillboardGui")
        if billboardGui then
            local text = billboardGui.TextLabel.Text
            local cashAmount = extractCashAmount(text)
            totalCash = totalCash - cashAmount
            updateCashLabel()
        end
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    CashLabel = createGUIIfNeeded()
    updateTotalCash()
end)

CashLabel = createGUIIfNeeded()
updateTotalCash()

local dragging = false
local dragStartPos
local startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStartPos = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStartPos
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
