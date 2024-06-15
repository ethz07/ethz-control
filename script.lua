local hostUserId = getgenv().Host or 1596382068 -- Userid
local fpsCap = getgenv().Fps or 5 -- FpsCap for Alts
local prefix = getgenv().Prefix or '!' -- Example Prefix "!" "?" "/" "."

local altAccounts = getgenv().Alts or { -- 38 Alts max.
    5590716577,
    5590724729,
    5590729811,
}

-- Lokasyonlar
local locations = {
    bank = {
        Vector3.new(-386.3853454589844, 21.24999237060547, -338.0519104003906), -- 1. Alt Hesap
        Vector3.new(-374.25830078125, 21.24999237060547, -338.2541198730469), -- 2. Alt Hesap
        Vector3.new(-361.12103271484375, 21.24999237060547, -338.4696960449219), -- 3. Alt Hesap
    },
    club = Vector3.new(0, 0, 0),
    basketball = Vector3.new(0, 0, 0),
    school = Vector3.new(0, 0, 0)
}

local isDropping = false

local function teleportAltsToLocation(location)
    for i, altId in ipairs(altAccounts) do
        local altPlayer = game.Players:GetPlayerByUserId(altId)
        if altPlayer and altPlayer.Character and altPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if type(location) == "table" and location[i] then
                altPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(location[i])
            else
                altPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(location)
            end
        end
    end
end

local function bringAltsToOwner()
    local ownerPlayer = game.Players:GetPlayerByUserId(hostUserId)
    if ownerPlayer and ownerPlayer.Character and ownerPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local ownerPosition = ownerPlayer.Character.HumanoidRootPart.Position
        teleportAltsToLocation(ownerPosition)
    end
end

local function startDroppingCash()
    isDropping = true
    for _, altId in ipairs(altAccounts) do
        local altPlayer = game.Players:GetPlayerByUserId(altId)
        if altPlayer then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Started Dropping.", "All")
            game.ReplicatedStorage.MainEvent:FireServer('Block', true)
        end
    end
    while isDropping do
        for _, altId in ipairs(altAccounts) do
            local altPlayer = game.Players:GetPlayerByUserId(altId)
            if altPlayer then
                game.ReplicatedStorage.MainEvent:FireServer('DropMoney', '10000')
                task.wait(0.5)
            end
        end
    end
end

local function stopDroppingCash()
    if isDropping then
        isDropping = false
        for _, altId in ipairs(altAccounts) do
            local altPlayer = game.Players:GetPlayerByUserId(altId)
            if altPlayer then
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Stopped Dropping.", "All")
                game.ReplicatedStorage.MainEvent:FireServer('Block', false)
            end
        end
    end
end

local function airlock()
    if workspace:FindFirstChild("AirlockPart") then 
        workspace:FindFirstChild("AirlockPart"):Destroy() 
    end
    local Part = Instance.new("Part", workspace)
    Part.Name = "AirlockPart"
    Part.Size = Vector3.new(4, 1.2, 4)
    Part.Transparency = 1
    Part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
    Part.Anchored = true

    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Part.CFrame + Vector3.new(0, 2.5, 0)
    wait(0.25)
end

local function unlock()
    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false

    if workspace:FindFirstChild("AirlockPart") then
        workspace:FindFirstChild("AirlockPart"):Destroy()
    end
end

local function resetAlts()
    for _, altId in ipairs(altAccounts) do
        local altPlayer = game.Players:GetPlayerByUserId(altId)
        if altPlayer and altPlayer.Character and altPlayer.Character:FindFirstChild("Humanoid") then
            altPlayer.Character.Humanoid.Health = 0
        end
    end
end

local function showWallets()
    for _, altId in ipairs(altAccounts) do
        local altPlayer = game.Players:GetPlayerByUserId(altId)
        if altPlayer and altPlayer.Backpack then
            local walletItem = altPlayer.Backpack:FindFirstChild("Wallet")
            if walletItem then
                altPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(walletItem)
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Wallet equipped.", "All")
            else
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Wallet not found in Backpack.", "All")
            end
        end
    end
end

local function redeemPromoCode(code)
    local MainEvent = game.ReplicatedStorage.MainEvent
    for _, altId in ipairs(altAccounts) do
        local altPlayer = game.Players:GetPlayerByUserId(altId)
        if altPlayer then
            MainEvent:FireServer('EnterPromoCode', code)
            task.wait(2)
        end
    end
end

local function unWallet()
    for _, altId in ipairs(altAccounts) do
        local altPlayer = game.Players:GetPlayerByUserId(altId)
        if altPlayer and altPlayer.Character then
            local humanoid = altPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Wallet unequipped.", "All")
            else
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Humanoid not found.", "All")
            end
        else
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Alt player or character not found.", "All")
        end
    end
end

local function onChatMessage(player, message)
    if player.UserId == hostUserId then
        if message:sub(1, #prefix) == prefix then
            local command = message:sub(#prefix + 1)
            local spaceIndex = command:find(" ")
            if spaceIndex then
                local cmd = command:sub(1, spaceIndex - 1)
                local param = command:sub(spaceIndex + 1)
                if cmd == "setup" then
                    local location = locations[param]
                    if location then
                        teleportAltsToLocation(location)
                    end
                elseif cmd == "redeem" then
                    redeemPromoCode(param)
                end
            else
                if command == "setup bank" then
                    teleportAltsToLocation(locations.bank)
                elseif command == "setup club" then
                    teleportAltsToLocation(locations.club)
                elseif command == "setup basketball" then
                    teleportAltsToLocation(locations.basketball)
                elseif command == "setup school" then
                    teleportAltsToLocation(locations.school)
                elseif command == "bring" then
                    bringAltsToOwner()
                elseif command == "drop" then
                    startDroppingCash()
                elseif command == "stop" then
                    stopDroppingCash()
                elseif command == "airlock" then
                    airlock()
                elseif command == "unlock" then
                    unlock()
                elseif command == "reset" then
                    resetAlts()
                elseif command == "wallet" then
                    showWallets()
                elseif command == "unwallet" then
                    unWallet()
                end
            end
        end
    end
end

local function setupChatListeners(player)
    player.Chatted:Connect(function(message)
        onChatMessage(player, message)
    end)
end

game.Players.PlayerAdded:Connect(function(player)
    setupChatListeners(player)
end)

for _, player in ipairs(game.Players:GetPlayers()) do
    setupChatListeners(player)
end

print("Script loaded successfully.")
