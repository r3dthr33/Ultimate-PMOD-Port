local t = Def.ActorFrame{};

local function GetScreenName()
    if not SCREENMAN or type(SCREENMAN.GetTopScreen) ~= "function" then return "no screen" end;
    local screen = SCREENMAN:GetTopScreen();
    if not screen or type(screen.GetName) ~= "function" then return "no screen" end;
    return screen:GetName() or "unknown";
end;

local function GetProfileNoteskinText(pn)
    if not PROFILEMAN or type(PROFILEMAN.GetProfile) ~= "function" then return "none" end;
    local profile = PROFILEMAN:GetProfile(pn);
    if not profile or type(profile.GetNoteSkin) ~= "function" then return "none" end;
    local skin = profile:GetNoteSkin();
    if not skin or skin == "" then return "none" end;
    return tostring(skin);
end;

local function GetPreferredNoteskinText(pn)
    if not GAMESTATE or type(GAMESTATE.GetPlayerState) ~= "function" then return "none" end;
    local pstate = GAMESTATE:GetPlayerState(pn);
    if not pstate or type(pstate.GetPlayerOptions) ~= "function" then return "none" end;
    local poptions = pstate:GetPlayerOptions("ModsLevel_Preferred");
    if not poptions or type(poptions.NoteSkin) ~= "function" then return "none" end;
    local skin = poptions:NoteSkin();
    if not skin or skin == "" then return "none" end;
    return tostring(skin);
end;

local function GetPreferredOptionsArrayText(pn)
    if not GAMESTATE or type(GAMESTATE.GetPlayerState) ~= "function" then return "none" end;
    local pstate = GAMESTATE:GetPlayerState(pn);
    if not pstate or type(pstate.GetPlayerOptionsArray) ~= "function" then return "none" end;
    local mods = pstate:GetPlayerOptionsArray("ModsLevel_Preferred");
    if not mods or #mods == 0 then return "none" end;
    return table.concat(mods, ", ");
end;

local function BuildNoteskinDebugText(pn)
    return ToEnumShortString(pn)
        .. " | PROFILE: " .. GetProfileNoteskinText(pn)
        .. " | PREFERRED: " .. GetPreferredNoteskinText(pn)
        .. " | PREF_ARR: " .. GetPreferredOptionsArrayText(pn);
end;

t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(Center);

    Def.Quad{
        InitCommand=cmd(zoomto,860,220;diffuse,0,0,0,0.72);
    },

    Def.BitmapText{
        Font = "regen strong";
        Text = "DEBUG WINDOW";
        InitCommand=cmd(y,-20;zoomx,0.45;zoomy,0.42;diffuse,1,0.88,0.28,1;strokecolor,0,0,0,1);
    },

    Def.BitmapText{
        Font = "titillium regular";
        Text = "SCREEN: no screen";
        InitCommand=function(self)
            self:y(-8);
            self:zoom(0.56);
            self:horizalign(center);
            self:diffuse(1,1,1,0.96);
            self:strokecolor(0,0,0,0.9);
            self:settext("SCREEN: " .. GetScreenName());
            self:queuecommand("Refresh");
        end,
        RefreshCommand=function(self)
            self:settext("SCREEN: " .. GetScreenName());
            self:sleep(0.1);
            self:queuecommand("Refresh");
        end,
    },

    Def.BitmapText{
        Font = "titillium regular";
        Text = "P1";
        InitCommand=function(self)
            self:y(28);
            self:zoom(0.4);
            self:horizalign(center);
            self:diffuse(1,1,1,0.96);
            self:strokecolor(0,0,0,0.9);
            self:wrapwidthpixels(1400);
            self:settext(BuildNoteskinDebugText(PLAYER_1));
            self:queuecommand("Refresh");
        end,
        RefreshCommand=function(self)
            self:settext(BuildNoteskinDebugText(PLAYER_1));
            self:sleep(0.1);
            self:queuecommand("Refresh");
        end,
    },

    Def.BitmapText{
        Font = "titillium regular";
        Text = "P2";
        InitCommand=function(self)
            self:y(58);
            self:zoom(0.4);
            self:horizalign(center);
            self:diffuse(1,1,1,0.96);
            self:strokecolor(0,0,0,0.9);
            self:wrapwidthpixels(1400);
            self:settext(BuildNoteskinDebugText(PLAYER_2));
            self:queuecommand("Refresh");
        end,
        RefreshCommand=function(self)
            self:settext(BuildNoteskinDebugText(PLAYER_2));
            self:sleep(0.1);
            self:queuecommand("Refresh");
        end,
    },
};

return t;
