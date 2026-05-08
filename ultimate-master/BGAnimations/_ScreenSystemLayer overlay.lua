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

local function GetPlayerOptionValueText(pn, level, getter)
    if not GAMESTATE or type(GAMESTATE.GetPlayerState) ~= "function" then return "none" end;
    local pstate = GAMESTATE:GetPlayerState(pn);
    if not pstate or type(pstate.GetPlayerOptions) ~= "function" then return "none" end;
    local poptions = pstate:GetPlayerOptions(level);
    if not poptions or type(poptions[getter]) ~= "function" then return "none" end;
    local value = poptions[getter](poptions);
    if value == nil or value == "" then return "none" end;
    return tostring(value);
end;

local function GetPreferredNoteskinText(pn)
    return GetPlayerOptionValueText(pn, "ModsLevel_Preferred", "NoteSkin");
end;

local function GetCurrentNoteskinText(pn)
    return GetPlayerOptionValueText(pn, "ModsLevel_Current", "NoteSkin");
end;

local function GetPreferredRandomNoteText(pn)
    return GetPlayerOptionValueText(pn, "ModsLevel_Preferred", "RandomNote");
end;

local function GetPreferredOptionsArrayText(pn)
    if not GAMESTATE or type(GAMESTATE.GetPlayerState) ~= "function" then return "none" end;
    local pstate = GAMESTATE:GetPlayerState(pn);
    if not pstate or type(pstate.GetPlayerOptionsArray) ~= "function" then return "none" end;
    local mods = pstate:GetPlayerOptionsArray("ModsLevel_Preferred");
    if not mods or #mods == 0 then return "none" end;
    return table.concat(mods, ", ");
end;

local function GetCurrentSteps(pn)
    if not GAMESTATE or type(GAMESTATE.GetCurrentSteps) ~= "function" then return nil end;
    return GAMESTATE:GetCurrentSteps(pn);
end;

local function GetPreloadNoteskinText(pn)
    local steps = GetCurrentSteps(pn);
    if not steps or type(steps.GetPreloadNoteSkin) ~= "function" then return "none" end;
    local skin = steps:GetPreloadNoteSkin();
    if not skin or skin == "" then return "none" end;
    return tostring(skin);
end;

local function GetStepsText(pn)
    local steps = GetCurrentSteps(pn);
    if not steps then return "none" end;

    local parts = {};

    if type(steps.GetStepsType) == "function" then
        local stype = steps:GetStepsType();
        if stype and stype ~= "" then
            parts[#parts+1] = tostring(stype);
        end;
    end;

    if type(steps.GetMeter) == "function" then
        local meter = steps:GetMeter();
        if meter ~= nil then
            parts[#parts+1] = tostring(meter);
        end;
    end;

    if type(steps.GetChartName) == "function" then
        local chart = steps:GetChartName();
        if chart and chart ~= "" then
            parts[#parts+1] = tostring(chart);
        end;
    end;

    if #parts == 0 then return "loaded" end;
    return table.concat(parts, " | ");
end;

local function BuildNoteskinSummaryText(pn)
    return ToEnumShortString(pn)
        .. " | PROFILE: " .. GetProfileNoteskinText(pn)
        .. " | PREFERRED: " .. GetPreferredNoteskinText(pn)
        .. " | CURRENT: " .. GetCurrentNoteskinText(pn);
end;

local function BuildNoteskinDetailText(pn)
    return "PREF_ARR: " .. GetPreferredOptionsArrayText(pn)
        .. " | PRELOAD: " .. GetPreloadNoteskinText(pn)
        .. " | RANDOMNOTE: " .. GetPreferredRandomNoteText(pn)
        .. " | STEPS: " .. GetStepsText(pn);
end;

t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(Center);

    Def.Quad{
        InitCommand=cmd(zoomto,920,250;diffuse,0,0,0,0.72);
    },

    Def.BitmapText{
        Font = "regen strong";
        Text = "NOTESKIN TRACE";
        InitCommand=cmd(y,-88;zoomx,0.45;zoomy,0.42;diffuse,1,0.88,0.28,1;strokecolor,0,0,0,1);
    },

    Def.BitmapText{
        Font = "titillium regular";
        Text = "SCREEN: no screen";
        InitCommand=function(self)
            self:y(-58);
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
            self:y(-16);
            self:zoom(0.39);
            self:horizalign(center);
            self:diffuse(1,1,1,0.96);
            self:strokecolor(0,0,0,0.9);
            self:wrapwidthpixels(1450);
            self:settext(BuildNoteskinSummaryText(PLAYER_1));
            self:queuecommand("Refresh");
        end,
        RefreshCommand=function(self)
            self:settext(BuildNoteskinSummaryText(PLAYER_1));
            self:sleep(0.1);
            self:queuecommand("Refresh");
        end,
    },

    Def.BitmapText{
        Font = "titillium regular";
        Text = "P1 DETAIL";
        InitCommand=function(self)
            self:y(12);
            self:zoom(0.35);
            self:horizalign(center);
            self:diffuse(0.82,0.9,1,0.96);
            self:strokecolor(0,0,0,0.9);
            self:wrapwidthpixels(1450);
            self:settext(BuildNoteskinDetailText(PLAYER_1));
            self:queuecommand("Refresh");
        end,
        RefreshCommand=function(self)
            self:settext(BuildNoteskinDetailText(PLAYER_1));
            self:sleep(0.1);
            self:queuecommand("Refresh");
        end,
    },

    Def.BitmapText{
        Font = "titillium regular";
        Text = "P2";
        InitCommand=function(self)
            self:y(58);
            self:zoom(0.39);
            self:horizalign(center);
            self:diffuse(1,1,1,0.96);
            self:strokecolor(0,0,0,0.9);
            self:wrapwidthpixels(1450);
            self:settext(BuildNoteskinSummaryText(PLAYER_2));
            self:queuecommand("Refresh");
        end,
        RefreshCommand=function(self)
            self:settext(BuildNoteskinSummaryText(PLAYER_2));
            self:sleep(0.1);
            self:queuecommand("Refresh");
        end,
    },

    Def.BitmapText{
        Font = "titillium regular";
        Text = "P2 DETAIL";
        InitCommand=function(self)
            self:y(86);
            self:zoom(0.35);
            self:horizalign(center);
            self:diffuse(0.82,0.9,1,0.96);
            self:strokecolor(0,0,0,0.9);
            self:wrapwidthpixels(1450);
            self:settext(BuildNoteskinDetailText(PLAYER_2));
            self:queuecommand("Refresh");
        end,
        RefreshCommand=function(self)
            self:settext(BuildNoteskinDetailText(PLAYER_2));
            self:sleep(0.1);
            self:queuecommand("Refresh");
        end,
    },
};

return t;
