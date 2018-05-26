local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local pscale = (player == PLAYER_1) and 1 or -1

return Def.ActorFrame{
	Name="StepArtistAF_" .. pn,
	InitCommand=cmd(draworder,1),

	-- song and course changes
	OnCommand=cmd(queuecommand, "StepsHaveChanged"),
	CurrentSongChangedMessageCommand=cmd(queuecommand, "StepsHaveChanged"),
	CurrentCourseChangedMessageCommand=cmd(queuecommand, "StepsHaveChanged"),

	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Appear" .. pn)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:ease(0.5, 275):addy(scale(p,0,1,1,-1) * 30):diffusealpha(0)
		end
	end,

	-- depending on the value of pn, this will either become
	-- an AppearP1Command or an AppearP2Command when the screen initializes
	["Appear"..pn.."Command"]=function(self) self:visible(true):ease(0.5, 275):addy(scale(p,0,1,-1,1) * -30) end,

	InitCommand=function(self)
		self:visible( false ):halign( p )

		self:y(_screen.cy + 42*pscale)
		self:x( _screen.cx - (IsUsingWideScreen() and 236 or 200)*pscale - 113)

		if GAMESTATE:IsHumanPlayer(player) then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- colored background quad
	Def.Quad{
		Name="BackgroundQuad",
		InitCommand=cmd(zoomto, 175, _screen.h/28; x, 113; diffuse, DifficultyIndexColor(1) ),
		StepsHaveChangedCommand=function(self)
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			if StepsOrTrail then
				local difficulty = StepsOrTrail:GetDifficulty()
				self:diffuse( DifficultyColor(difficulty) )
			else
				self:diffuse( PlayerColor(player) )
			end
		end
	},

	--STEPS label
	Def.BitmapText{
		Font="_miso",
		OnCommand=cmd(diffuse, color("0,0,0,1"); horizalign, left; x, 30; settext, Screen.String("STEPS")),
		StepsHaveChangedCommand=function(self)

			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
			
			if StepsOrTrail then
				local difficulty = StepsOrTrail:GetDifficulty()
				difficulty = ToEnumShortString(difficulty)
				if GAMESTATE:IsCourseMode() then
					self:settext( THEME:GetString("Difficulty", difficulty) )
				else
					self:settext( StepsOrTrail:IsAnEdit() and StepsOrTrail:GetChartName() or THEME:GetString("Difficulty", difficulty) )
				end
			else
				self:settext( "" )
			end
		end
	},

	--stepartist text
	Def.BitmapText{
		Font="_miso",
		InitCommand=cmd(diffuse,color("#1e282f"); horizalign, right; x, 192; maxwidth, 115; zoom, 0.7),
		StepsHaveChangedCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSteps(player)

			-- if we're hovering over a group title, clear the stepartist text
			if not SongOrCourse then
				self:settext("")
			elseif StepsOrCourse then
				local stepartist = GAMESTATE:IsCourseMode() and StepsOrCourse:GetScripter() or StepsOrCourse:GetAuthorCredit()
				self:settext(stepartist and stepartist:len() and ("(steps: "..stepartist..")") or "")
			end
		end
	}
}