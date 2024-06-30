local hostUserId = getgenv().Host or 1596382068 -- Host Userid
local fpsCap = getgenv().Fps or 5 -- FpsCap for Alts
local prefix = getgenv().Prefix or '!' -- Example Prefix "!" "?" "/" "."
local altAccounts = getgenv().Alts or { -- Alt hesaplarin ID'leri
    5590716577,
    5590724729,
    5590729811,
}
local userId = game:GetService('Players').LocalPlayer.UserId

local function loadAltAccountScripts()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/AntiAfk.Lua'))()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/Optimization.Lua'))()
end

local function loadHostScript()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/CashCounter.Lua'))()
end

if userId == hostUserId then
    loadHostScript()
elseif table.find(altAccounts, userId) then
    loadAltAccountScripts()
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
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/bring'))()
end

local function startDroppingCash()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/drop'))()
end

local function stopDroppingCash()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/stop'))()
end

local function airlock()
  loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/airlock'))()
end

local function resetAlts()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/reset'))()
end

local function showWallets()
   loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/wallet'))()
end 

local function redeemPromoCode(code)
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/redeem'))()
end

local function unWallet()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/unwallet'))()
end

local function bringPlr(Target, POS)
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ethz07/stuff/main/cmd/bringplr'))()
end

local function onChatMessage(player, message)
    if player.UserId == hostUserId then
        return  -- Host kullanıcı sadece alt hesaplar üzerinde komut kullanabilir
    end
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
