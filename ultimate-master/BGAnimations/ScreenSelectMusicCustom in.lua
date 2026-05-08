return Def.ActorFrame{
    OnCommand=cmd(queuecommand,"ProfileUpdate";sleep,1);
    ProfileUpdateCommand=function(self)
        for pn in ivalues({PLAYER_1, PLAYER_2}) do
            if GAMESTATE:IsHumanPlayer(pn) and PROFILEMAN and type(PROFILEMAN.SaveProfile) == "function" then
                local profile = PROFILEMAN:GetProfile(pn);
                if profile and string.upper(tostring(profile:GetDisplayName())) ~= "PUMPITUP" then
                    pcall(function() PROFILEMAN:SaveProfile(pn); end);
                end;
            end;
        end;
    end;
};
