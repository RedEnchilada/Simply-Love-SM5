local t = Def.ActorFrame{}

for player in ivalues({PLAYER_1, PLAYER_2}) do
	-- StepArtist Box
	t[#t+1] = LoadActor("./StepArtist.lua", player)

	-- Step Data (Number of steps, jumps, holds, etc.)
	t[#t+1] = LoadActor("./PaneDisplay.lua", player)
end

return t