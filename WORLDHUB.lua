local gameId = game.PlaceId
local tappingGameId = 15705682243
local UtdGameId = 5902977746


if gameId == tappingGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Tapping%20Legends%20Final.lua"))()
elseif gameId == UtdGameId then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatMinhVNQ/w-hub/main/Ultimate%20Tower%20Defense.lua"))()
else
    game.Players.LocalPlayer:Kick("Game Not Supported, Join Discord, https://discord.com/invite/psE8EUa9kg")
end
