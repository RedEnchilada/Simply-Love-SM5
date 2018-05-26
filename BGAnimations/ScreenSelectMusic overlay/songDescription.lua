local t = Def.ActorFrame{

	OnCommand=function(self)
			self:xy(_screen.cx, _screen.cy)
	end,

	-- ----------------------------------------
	-- Actorframe for Artist, BPM, and Song length
	Def.ActorFrame{
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentStepsP2ChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set"),

		-- background for Artist, BPM, and Song Length
		Def.Quad{
			InitCommand=function(self)
				self:diffuse(color("#1e282f"))
					:zoomto( 640, 128 )
			end
		},

		Def.ActorFrame{

			InitCommand=cmd(x, -110),

			-- Song Title
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign,left; xy, 100,-36; maxwidth,WideScale(225,260); zoom,1.5 ),
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()

					if song and song:GetDisplayMainTitle() then
						self:settext(song:GetDisplayMainTitle())
						
						if song:GetDisplaySubTitle() and song:GetDisplaySubTitle() ~= "" then
							self:y(-36)
						else
							self:y(-26)
						end
					else
						self:settext(SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection())
						self:y(-26)
					end
				end
			},

			-- Song Subtitle
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign,left; xy, 112,-12; maxwidth,WideScale(225,260) ),
				SetCommand=function(self)
				OnCommand=cmd(diffuse,color("0.5,0.5,0.5,1"))
					local song = GAMESTATE:GetCurrentSong()

					if song and song:GetDisplaySubTitle() then
						self:settext(song:GetDisplaySubTitle())
					else
						self:settext("")
					end
				end
			},

			-- Song Artist
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign,left; xy, 100,16; maxwidth,WideScale(225,260); zoom,1.25 ),
				SetCommand=function(self)
					if GAMESTATE:IsCourseMode() then
						local course = GAMESTATE:GetCurrentCourse()
						if course then
							self:settext( #course:GetCourseEntries() )
						else
							self:settext("")
						end
					else
						local song = GAMESTATE:GetCurrentSong()
						if song and song:GetDisplayArtist() then
							self:settext( song:GetDisplayArtist() )
						else
							self:settext("")
						end
					end
				end
			},



			-- BPM Label
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign, left; NoStroke; xy, 180, 42),
				SetCommand=function(self)
					self:diffuse(0.5,0.5,0.5,1)
					
					local text = GetDisplayBPMs()
					
					if text and text ~= "" then
						self:settext("BPM")
					else
						self:settext("SONGS")
					end
				end
			},

			-- BPM value
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign, right; NoStroke; xy, 176, 42; diffuse, color("1,1,1,1")),
				SetCommand=function(self)

					--defined in ./Scipts/SL-CustomSpeedMods.lua
					local text = GetDisplayBPMs()

					if text and text ~= "" then
						self:settext(text)
					else
						local group = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection()
						local songs = SONGMAN:GetSongsInGroup(group)
						self:settext(#songs)
					end
				end
			},

			-- Song Length Label
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign, right; xy, 284, 42),
				SetCommand=function(self)
					self:diffuse(0.5,0.5,0.5,1)

					if GAMESTATE:GetCurrentSong() or GAMESTATE:GetCurrentCourse() then
						self:settext("LENGTH")
					else
						self:settext("")
					end
				end
			},

			-- Song Length Value
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign, left; xy, 300, 42),
				SetCommand=function(self)
					local duration

					if GAMESTATE:IsCourseMode() then
						local Players = GAMESTATE:GetHumanPlayers()
						local player = Players[1]
						local trail = GAMESTATE:GetCurrentTrail(player)

						if trail then
							duration = TrailUtil.GetTotalSeconds(trail)
						end
					else
						local song = GAMESTATE:GetCurrentSong()
						if song then
							duration = song:MusicLengthSeconds()
						end
					end


					if duration then
						duration = duration / SL.Global.ActiveModifiers.MusicRate
						if duration == 105.0 then
							-- r21 lol
							self:settext( THEME:GetString("SongDescription", "r21") )
						else
							local hours = 0
							if duration > 3600 then
								hours = math.floor(duration / 3600)
								duration = duration % 3600
							end

							local finalText
							if hours > 0 then
								-- where's HMMSS when you need it?
								finalText = hours .. ":" .. SecondsToMMSS(duration)
							else
								finalText = SecondsToMSS(duration)
							end

							self:settext( finalText )
						end
					else
						self:settext("")
					end
				end
			}
		},

		Def.ActorFrame{
			OnCommand=cmd(xy, 165, 30),

			LoadActor("bubble.png")..{
				InitCommand=cmd(diffuse,GetCurrentColor(); visible, false; zoom, 0.9; y, 30),
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()

					if song then
						if song:IsLong() or song:IsMarathon() then
							self:visible(true)
						else
							self:visible(false)
						end
					else
						self:visible(false)
					end
				end
			},

			LoadFont("_miso")..{
				InitCommand=cmd(diffuse, Color.Black; zoom,0.8; y, 34),
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()

					if song then
						if song:IsLong() then
							self:settext( THEME:GetString("SongDescription", "IsLong") )
						elseif song:IsMarathon() then
							self:settext( THEME:GetString("SongDescription", "IsMarathon")  )
						else
							self:settext("")
						end
					else
						self:settext("")
					end
				end
			}
		}
	}
}

return t
