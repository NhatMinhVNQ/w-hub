local gameId = game.PlaceId
local tappingGameId = 15705682243
local bloxGameId = 2753915549


if gameId == tappingGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Tapping%20Legends%20Final.lua"))()
elseif gameId == bloxGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Blox%20Fruit.lua"))()
else
    game.Players.LocalPlayer:Kick("Bro, My Script Support Only Blox Fruits and Please Wait Me Update New Game")
end
