local gameId = game.PlaceId
local tappingGameId = 15705682240
local UtdGameId = 5902977740

if gameId == tappingGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Tapping%20Legends%20Final.lua"))()
elseif gameId == UtdGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Ultimate%20Tower%20Defense.lua"))()
    
        game.Players.LocalPlayer:Kick("Not Support Game")
end
