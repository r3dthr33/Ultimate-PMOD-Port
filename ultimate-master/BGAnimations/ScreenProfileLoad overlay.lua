local t = Def.ActorFrame{
	Def.ActorFrame{
		InitCommand=cmd(diffusealpha,0);
		OnCommand=cmd(sleep,0.15;linear,0.2;diffusealpha,1);
		ExitMessageCommand=cmd(sleep,0.15;linear,0.2;diffusealpha,0;sleep,0.1;queuemessage,"Next");

		LoadActor(THEME:GetPathG("","cursor"))..{
			InitCommand=cmd(x,_screen.cx;y,_screen.cy + 48;animate,false;setstate,5;zoom,0.4;spin;effectmagnitude,0,0,720);
		},

		Def.BitmapText{
        	Font = Fonts.common["Loading"];
			Text="Loading Profiles";
			InitCommand=cmd(Center;diffuse,1,1,1,1;shadowlength,1);
			NextMessageCommand=function(self) MESSAGEMAN:Broadcast("Load"); end;
		},
		Def.BitmapText{
        	Font = Fonts.common["Loading"];
			InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+88;zoom,0.35;diffuse,1,0.25,0.25,1;shadowlength,1;settext,"debug: profile load waiting");
			LoadQueuedMessageCommand=function(self,param)
				self:settext("debug: queued Load, next="..tostring(param.NextScreen));
			end;
			ContinueMessageCommand=function(self)
				self:settext("debug: calling Continue()");
			end;
		},
	}
};

t[#t+1] = LoadActor(THEME:GetPathB("ScreenWithMenuElements","overlay"));

t[#t+1] = Def.Actor{
	BeginCommand=function(self)
		if GAMESTATE:GetNumSidesJoined() == 0 then
			GAMESTATE:JoinPlayer(PLAYER_1);
		end;
		SCREENMAN:SystemMessage("Ultimate ScreenProfileLoad begin; next="..SCREENMAN:GetTopScreen():GetNextScreenName());
		if SCREENMAN:GetTopScreen():HaveProfileToLoad() then 
			self:sleep(1); 
		end;
		MESSAGEMAN:Broadcast("LoadQueued", { NextScreen = SCREENMAN:GetTopScreen():GetNextScreenName() });
		self:queuecommand("Load");
	end;
	LoadCommand=function()
		SCREENMAN:SystemMessage("Ultimate ScreenProfileLoad continue");
		MESSAGEMAN:Broadcast("Continue");
		SCREENMAN:GetTopScreen():Continue();
	end;
};

return t;
