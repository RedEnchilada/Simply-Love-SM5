local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local pscale = (player == PLAYER_1) and 1 or -1

local radar = Def.ActorFrame{
	Name="GrooveRadar_" .. pn,
	InitCommand=cmd(xy, 26, pscale*8),
}

-- Groove radars
local radar_max_section = 139
for i,opt in ipairs({
	"Stream",
	"Voltage",
	"Air",
	"Freeze",
	"Chaos",
}) do
	radar[#radar+1] = Def.Quad{
		Name=opt.."BGQuad",
		InitCommand=cmd(zoomto, 20, radar_max_section; skewx, radar_max_section/40; x, i*_screen.h / 17; y, 0; diffuse, color("#808080"); croptop, pscale/2; cropbottom, pscale/-2 ),
	}
	for offs, col in ipairs({
		"#ffff00",
		"#ff0000",
		"#ffffff",
	}) do
		radar[#radar+1] = Def.Quad{
			Name=opt.."Quad"..offs,
			InitCommand=cmd(zoomto, 20, 100; x, i*_screen.h / 17; y, 0; diffuse, color(col); croptop, pscale/2; cropbottom, pscale/-2 ),
			StepsHaveChangedCommand=function(self)

				self:stoptweening()

				if (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong() then
					local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
					if not StepsOrTrail then return end
					
					local radar = StepsOrTrail:GetRadarValues(player)
					local value = math.max(0, math.min(radar_max_section, radar:GetValue(opt)*100 - radar_max_section*(offs-1)))
					
					self:linear(0.1):zoomto(20, value):skewx(value/40)
				else
					self:linear(0.1):zoomto(20, 0):skewx(0)
				end
			end
		}
	end
	
	radar[#radar+1] = Def.BitmapText{
		Font="_miso",
		InitCommand=cmd(
			horizalign, (player == PLAYER_1) and left or right;
			x, i*_screen.h / 17 + pscale*4;
			y, pscale*10;
			rotationz, 63;
			diffuse, color("0,0,0,1")
		),
		StepsHaveChangedCommand=function(self)
			if (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong() then
				self:settext(opt)
			else
				self:settext("")
			end
		end
	}
end

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
	
	radar,

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