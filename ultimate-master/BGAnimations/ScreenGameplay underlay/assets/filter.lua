local t = Def.ActorFrame{}
local notefield = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if SideJoined(pn) then

        t[#t+1] = Def.Quad{
            InitCommand=cmd(vertalign,top);
            OnCommand=function(self)

                local gameplay = SCREENMAN:GetTopScreen();
                local player = gameplay:GetChild("Player"..ToEnumShortString(pn))
                local conf = PLAYERCONFIG:get_data(pn);
                notefield[pn] = player:GetChild("NoteField");
                local field_width = nil;

                if notefield[pn] and type(notefield[pn].GetWidth) == "function" then
                    field_width = notefield[pn]:GetWidth();
                elseif player and type(player.GetWidth) == "function" then
                    field_width = player:GetWidth();
                else
                    field_width = (_screen.w * 0.5) - 48;
                end;

                self:x(player:GetX());
                self:zoomto(field_width + 48,_screen.h);
                self:diffuse(0.05,0.05,0.05,conf.ScreenFilter/100);

            end;
        }
 
    end;
end;

return t;
