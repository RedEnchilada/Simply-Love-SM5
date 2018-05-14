local t = Def.ActorFrame{
	OnCommand=function(self) self:queuecommand("HideSortMenu") end,
	ChangeStepsMessageCommand=function(self, params)
		self:playcommand("StepsHaveChanged", {Direction=params.Direction, Player=params.Player})
	end
}

-- Each file contains the code for a particular screen element.
-- I've made this table ordered so that I can specificy
-- a desired draworder later below.

local files = {
	-- make the MusicWheel appear to cascade down
	--"./MusicWheelAnimation.lua",
	-- Apply player modifiers from profile
	"./PlayerModifiers.lua",
	-- Difficulty Blocks
--	"./StepsDisplayList/Grid.lua",
	-- a folder of Lua files to be loaded twice (once for each player)
	"./PerPlayer",
	-- Song Artist, BPM, Duration (Referred to in other themes as "PaneDisplay")
	"./SongDescription.lua",
	-- Graphical Banner
	"./Banner.lua",
	-- overlay for sorting the MusicWheel, hidden by default
	"./SortMenu/default.lua"
}

for index, file in ipairs(files) do
	t[#t+1] = LoadActor(file)..{
		InitCommand=cmd(draworder, index)
	}
end

-- Difficulty for each player
t[#t+1] = LoadActor("./PlayerStepsDisplay.lua", PLAYER_1)..{
	InitCommand=cmd(draworder, #t+1)
}
t[#t+1] = LoadActor("./PlayerStepsDisplay.lua", PLAYER_2)..{
	InitCommand=cmd(draworder, #t+1)
}

return t