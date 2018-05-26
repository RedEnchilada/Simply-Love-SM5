local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local GridColumns = 20
local GridRows = 5
local GridZoomX = IsUsingWideScreen() and 0.435 or 0.39
local BlockZoomY = 0.275
local StepsToDisplay, SongOrCourse, StepsOrTrails

local side = player == PLAYER_1 and 1 or -1

local t = Def.ActorFrame{
	Name="StepsDisplayList",
	InitCommand=cmd(xy, (_screen.cx-20)*-side + _screen.cx - 9, _screen.cy - side*39-1; zoom, 1.25),
	-- - - - - - - - - - - - - -

	OnCommand=cmd(queuecommand, "RedrawStepsDisplay"),
	CurrentSongChangedMessageCommand=cmd(queuecommand, "RedrawStepsDisplay"),
	CurrentCourseChangedMessageCommand=cmd(queuecommand, "RedrawStepsDisplay"),
	StepsHaveChangedCommand=cmd(queuecommand, "RedrawStepsDisplay"),

	-- - - - - - - - - - - - - -

	RedrawStepsDisplayCommand=function(self)
		if not GAMESTATE:IsHumanPlayer(player) then
			self:visible(false)
			return
		else
			self:visible(true)
		end

		SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()

		if SongOrCourse then
			StepsOrTrails = (GAMESTATE:IsCourseMode() and SongOrCourse:GetAllTrails()) or SongUtil.GetPlayableSteps( SongOrCourse )

			if StepsOrTrails then

				StepsToDisplay = GetStepsToDisplay(StepsOrTrails, player)
				
				local CurrentStepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player))

				for RowNumber=1,GridRows do
					if StepsToDisplay[RowNumber] then
						-- if this particular song has a stepchart for this row, update the Meter
						-- and BlockRow coloring appropriately
						local meter = StepsToDisplay[RowNumber]:GetMeter()
						local difficulty = StepsToDisplay[RowNumber]:GetDifficulty()
						self:GetChild("Grid"):GetChild("Meter_"..RowNumber):playcommand("Set", {Current=StepsToDisplay[RowNumber]==CurrentStepsOrTrail, Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("BG_"..RowNumber):playcommand("Set", {Current=StepsToDisplay[RowNumber]==CurrentStepsOrTrail, Difficulty=difficulty})
					else
						-- otherwise, set the meter to "?" and hide this particular colored BlockRow
						self:GetChild("Grid"):GetChild("Meter_"..RowNumber):playcommand("Unset")
						self:GetChild("Grid"):GetChild("BG_"..RowNumber):playcommand("Unset")
					end
				end
			end
		else
			StepsOrTrails, StepsToDisplay = nil
			self:playcommand("Unset")
		end
	end,

	-- - - - - - - - - - - - - -

	--[[ background
	Def.Quad{
		Name="Background",
		InitCommand=function(self)
			self:diffuse(color("#1e282f"))
			self:zoomto(320, 96)
			if ThemePrefs.Get("RainbowMode") then
				self:diffusealpha(0.75)
			end
		end
	},]]
}


local Grid = Def.ActorFrame{
	Name="Grid",
	InitCommand=cmd(horizalign, left; vertalign, top; xy, 8, -52 ),
}

for RowNumber=1,GridRows do

	Grid[#Grid+1] = Def.Quad{
		Name="BG_"..RowNumber,

		InitCommand=function(self)
			self:zoomto(80, 33)
			self:y((RowNumber-1.4) * 120 * BlockZoomY)
			self:x( 0 )
			self:skewx(0.25)
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:stoptweening()
			self:diffuse( DifficultyColor(params.Difficulty) )
			if params.Current then
				self:glow(0,0,0,0)
				self:linear(0.1):x(side * 10)
			else
				self:glow(0,0,0,0.6)
				self:linear(0.2):x(side * -15)
			end
		end,
		UnsetCommand=cmd(diffuse,color("#303030");glow, 0,0,0,0;linear,0.2;x,side*-15),
	}
	
	Grid[#Grid+1] = Def.BitmapText{
		Name="Meter_"..RowNumber,
		Font="_wendy small",

		InitCommand=function(self)
			local height = 120
			self:horizalign(center)
			self:y((RowNumber-1.4) * height * BlockZoomY)
			self:x( 0 )
			self:zoom(0.6)
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:settext(params.Meter)
			if params.Current then
				self:diffuse( Color.White )
			else
				self:diffuse( color("#808080") )
			end
		end,
		UnsetCommand=cmd(settext, ""; diffuse,color("#182025")),
	}
end

t[#t+1] = Grid

return t