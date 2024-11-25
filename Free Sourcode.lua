local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function checkForPlayer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == "VoMinh132" then

            local chatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
                chatRemote.SayMessageRequest:FireServer("Hi VoMinh132 ! :3", "All")
            end
            break
        end
    end
end

checkForPlayer()

Players.PlayerAdded:Connect(function(player)
    if player.Name == "VoMinh132" then
        local chatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
            chatRemote.SayMessageRequest:FireServer("Hi VoMinh132 ! :3", "All")
        end
    end
end)
