local gameId = game.PlaceId
local tappingGameId = 15705682243
local UtdGameId = 5902977746
local ADSGameId = 15968393246
local w1GameId = 2753915549
local w2GameId = 4442272183
local w3GameId = 7449423635

if gameId == tappingGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Tapping%20Legends%20Final.lua"))()
elseif gameId == UtdGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Ultimate%20Tower%20Defense.lua"))()
elseif gameId == ADSGameId then
    loadstring(game:HttpGet(""))()
elseif gameId == w1GameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TrumMocBoc/VnWorldHub/main/Vn%20World%20Hub.lua"))()
elseif gameId == w2GameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TrumMocBoc/VnWorldHub/main/Vn%20World%20Hub.lua"))()
elseif gameId == w3GameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TrumMocBoc/VnWorldHub/main/Vn%20World%20Hub.lua"))()
else
    game.Players.LocalPlayer:Kick("Game Not Support,")
end
