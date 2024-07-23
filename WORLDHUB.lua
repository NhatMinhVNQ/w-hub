local gameId = game.PlaceId
local tappingGameId = 15705682243
local UtdGameId = 5902977746
local w1GameId = 2753915549
local w2GameId = 4442272183
local w3GameId = 7449423635

if gameId == tappingGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Tapping%20Legends%20Final.lua"))()
if gameId == w1GameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TrumMocBoc/VnWorldHub/main/Vn%20World%20Hub.lua"))()
if gameId == w2GameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TrumMocBoc/VnWorldHub/main/Vn%20World%20Hub.lua"))()
if gameId == w3GameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TrumMocBoc/VnWorldHub/main/Vn%20World%20Hub.lua"))()
elseif gameId == UtdGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Ultimate%20Tower%20Defense.lua"))()
else
    game.Players.LocalPlayer:Kick("Game Not Supported, Join Discord, https://discord.com/invite/psE8EUa9kg")
end
