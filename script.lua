local hostUserId = getgenv().Host or 1596382068 -- Host Userid
local altAccounts = getgenv().Alts or { -- Alt hesapların ID'leri
    5590716577,
    5590724729,
    5590729811,
}
local userId = game:GetService('Players').LocalPlayer.UserId -- Şu anki kullanıcı kimliği

-- Fonksiyonlar
local function loadAltAccountScripts()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/AntiAfk.Lua'))()
end

local function loadHostScript()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/CashCounter.Lua'))()
end

-- Kimlik kontrolü ve script yükleme
if userId == hostUserId then
    -- Host kullanıcısı
    loadHostScript()
elseif table.find(altAccounts, userId) then
    -- Alt hesaplar
    loadAltAccountScripts()
else
    warn("Bu scripti kullanma izniniz yok.")
end

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
            end
        end
    end
end

local function bringPlr(Target, POS)
    local TargetPlr = Target

    local c = game.Players.LocalPlayer.Character
    local Root = c.HumanoidRootPart
    local PrevCF = Root.CFrame
    local TargetChar = TargetPlr.Character
    if TargetPlr and TargetPlr.Character and TargetPlr.Character:FindFirstChild("Humanoid") and not (not c or not c:FindFirstChild("BodyEffects") or not c.BodyEffects:FindFirstChild("K.O") or not c.BodyEffects:FindFirstChild("Grabbed") or c.BodyEffects["K.O"].Value == true or c.BodyEffects.Grabbed.Value ~= nil or not TargetChar or not TargetChar:FindFirstChild("BodyEffects") or not TargetChar.BodyEffects:FindFirstChild("K.O") or TargetChar.BodyEffects["K.O"].Value == true) then
        CmdSettings["IsLocking"] = true

        c.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

        Root.CFrame = CFrame.new(TargetChar.HumanoidRootPart.Position) * CFrame.new(0, 0, 1)

        repeat
            wait()
            Root.CFrame = CFrame.new(TargetChar.HumanoidRootPart.Position) * CFrame.new(0, 0, 1)
            if not c:FindFirstChild("Combat") then
                c.Humanoid:EquipTool(game.Players.LocalPlayer.Backpack.Combat)
            end
            c.Combat:Activate()
        until not TargetPlr or not TargetChar or not c or not c:FindFirstChild("BodyEffects") or not c.BodyEffects:FindFirstChild("K.O") or not c.BodyEffects:FindFirstChild("Grabbed") or c.BodyEffects["K.O"].Value == true or c.BodyEffects.Grabbed.Value ~= nil or not TargetChar or not TargetChar:FindFirstChild("BodyEffects") or not TargetChar.BodyEffects:FindFirstChild("K.O") or TargetChar.BodyEffects["K.O"].Value == true
        Root.CFrame = CFrame.new(TargetChar.LowerTorso.Position) * CFrame.new(0, 3, 0)
        if c.BodyEffects.Grabbed.Value ~= nil then

        else
            if not (not TargetPlr or not TargetChar or not c or not c:FindFirstChild("BodyEffects") or not c.BodyEffects:FindFirstChild("K.O") or not c.BodyEffects:FindFirstChild("Grabbed") or c.BodyEffects["K.O"].Value == true or c.BodyEffects.Grabbed.Value ~= nil or not TargetChar or not TargetChar:FindFirstChild("BodyEffects") or not TargetChar.BodyEffects:FindFirstChild("K.O") or TargetChar.BodyEffects["K.O"].Value == false) then
                local args = {
                    [1] = "Grabbing",
                    [2] = false
                }

                game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(args))
            end

        end
        repeat
            wait(0.35)
            if not (not TargetPlr or not TargetChar or not c or not c:FindFirstChild("BodyEffects") or not c.BodyEffects:FindFirstChild("K.O") or not c.BodyEffects:FindFirstChild("Grabbed") or c.BodyEffects["K.O"].Value == true or c.BodyEffects.Grabbed.Value ~= nil or not TargetChar or not TargetChar:FindFirstChild("BodyEffects") or not TargetChar.BodyEffects:FindFirstChild("K.O") or TargetChar.BodyEffects["K.O"].Value == false) then
                Root.CFrame = CFrame.new(TargetChar.LowerTorso.Position) * CFrame.new(0, 3, 0)
                if c.BodyEffects.Grabbed.Value ~= nil then

                else
                    if not (not TargetPlr or not TargetChar or not c or not c:FindFirstChild("BodyEffects") or c.BodyEffects["K.O"].Value == true or c.BodyEffects.Grabbed.Value ~= nil or not TargetChar or not TargetChar:FindFirstChild("BodyEffects") or TargetChar.BodyEffects["K.O"].Value == false) then
                        local args = {
                            [1] = "Grabbing",
                            [2] = false
                        }
                        game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(args))
                    end
                end
            end
        until not TargetPlr or not TargetChar or not c or not c:FindFirstChild("BodyEffects") or not c.BodyEffects:FindFirstChild("K.O") or not c.BodyEffects:FindFirstChild("Grabbed") or c.BodyEffects["K.O"].Value == true or c.BodyEffects.Grabbed.Value ~= nil or not TargetChar or not TargetChar:FindFirstChild("BodyEffects") or not TargetChar.BodyEffects:FindFirstChild("K.O") or TargetChar.BodyEffects["K.O"].Value == false
        if POS == nil then
            Root.CFrame = Host.Character.HumanoidRootPart.CFrame
        else
            Root.CFrame = POS
        end
        CmdSettings["IsLocking"] = nil
        wait(1.5)
        local args = {
            [1] = "Grabbing",
            [2] = false
        }

        game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(args))
    end
end

local BringLocations = {
    ["bank"] = CFrame.new(-403.210052, 600.530273, -291.573334, -0.0173361916, 1.31683358e-08, -0.999849737, -1.83786355e-08, 1, 1.34889788e-08, 0.999849737, 1.86097218e-08, -0.0173361916),
    ["admin"] = CFrame.new(-871.386902, 546.130981, -652.473511, -0.999967813, -6.39340882e-08, 0.0080243554, -6.31848351e-08, 1, 9.36256015e-08, -0.0080243554, 9.31155668e-08, -0.999967813),
    ["klub"] = CFrame.new(-266.170837, 578.808716, -423.926453, -0.999792337, -5.47117693e-08, -0.0203772113, -5.37027454e-08, 1, -5.00643722e-08, 0.0203772113, -4.89596665e-08, -0.999792337),
    ["vault"] = CFrame.new(-492.928253, 601.909546, -285.616974, 0.0240757726, 4.88051128e-08, 0.999710143, -4.81243205e-08, 1, -4.7660297e-08, -0.999710143, -4.69629136e-08, 0.0240757726),
    ["train"] = CFrame.new(-422.172394, 557.530212, 22.2141819, -0.999933541, 1.72892332e-08, 0.0115311332, 1.67518728e-08, 1, -4.66974122e-08, -0.0115311332, -4.65011389e-08, -0.999933541),
}

local function onChatMessage(player, message)
    print("Prefix:", prefix)
print("Message:", message)
    if player.UserId == hostUserId then
        if message:sub(1, #prefix) == prefix then
            local command = message:sub(#prefix + 1)
            local spaceIndex = command:find(" ")
            if spaceIndex then
                local cmd = command:sub(1, spaceIndex - 1)
                local param = command:sub(spaceIndex + 1)
                if cmd == "bring" then
                    local spot
                    if param == "host" or BringLocations[param] then
                        spot = param
                        param = nil
                    end
                    bringPlr(param, spot)
                elseif cmd == "setup" then
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
