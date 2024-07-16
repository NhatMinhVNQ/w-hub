local gameId = game.PlaceId
local tappingGameId = 15705682243
local bloxGameId = 2753915549


if gameId == tappingGameId then
    loadstring(game:HttpGet(""))()
elseif gameId == bloxGameId then
    loadstring(game:HttpGet(""))()
else
    warn("Sorry this game not supported. try to join supported games. More in discord.")
end
