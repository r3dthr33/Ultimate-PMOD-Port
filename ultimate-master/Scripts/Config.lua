--//================================================================

local theme_conf_default = {
    BGBrightness = 100,
    DefaultBG = false,
    DisableBGA = false,
    CenterPlayer = false,
    MusicRate = 1.0,
    FailType = "delayed",
    FailMissCombo = true,
    AllowW1 = true,
    TimingDifficulty = 4,
    LifeDifficulty = 4,
}

THEMECONFIG = create_lua_config{
    name = "THEMECONFIG", 
    file = "theme_config.lua",
    default = theme_conf_default,
}

THEMECONFIG:load("ProfileSlot_Invalid");
THEMECONFIG:set_dirty("ProfileSlot_Invalid");
THEMECONFIG:save("ProfileSlot_Invalid");

--//================================================================

function ResetThemeSettings()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.BGBrightness = 100;
    tconf.DefaultBackground = false;
    tconf.DisableBGA = false;
    tconf.CenterPlayer = false;
    tconf.MusicRate = 1.0;
    tconf.FailType = "delayed";
    tconf.FailMissCombo = true;
    tconf.AllowW1 = true;
    tconf.TimingDifficulty = 4;
    tconf.LifeDifficulty = 4;
    THEMECONFIG:save();
end;

--//================================================================

function ResetDisplayOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.BGBrightness = 100;
    tconf.DefaultBG = false;
    tconf.DisableBGA = false;
    tconf.CenterPlayer = false;
    THEMECONFIG:save();
end;

function ResetSongOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.MusicRate = 1.0;
    tconf.FailType = "delayed";
    tconf.FailMissCombo = true;
    THEMECONFIG:save();
end;

function ResetJudgmentOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.AllowW1 = true;
    tconf.TimingDifficulty = 4;
    tconf.LifeDifficulty = 4;
    THEMECONFIG:save();
end;

--//================================================================

function ApplyThemeSettings()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");

    tconf.BGBrightness      = clamp(tconf.BGBrightness,0,100);
    tconf.MusicRate         = clamp(tconf.MusicRate,0.5,2.0);
    tconf.TimingDifficulty  = clamp(tconf.TimingDifficulty,1,9);
    tconf.LifeDifficulty    = clamp(tconf.LifeDifficulty,1,7);
    if string.lower(tconf.FailType) ~= "delayed" and
       string.lower(tconf.FailType) ~= "immediate" and
       string.lower(tconf.FailType) ~= "off" then
       tconf.FailType = "delayed";
    end;

    -------------------------------------------------------------------------------------------------------
    local timing_mapping = { 1.5, 1.33, 1.16, 1.00, 0.84, 0.66, 0.50, 0.33, 0.20 };
    local life_mapping = { 1.6, 1.40, 1.20, 1.00, 0.80, 0.60, 0.40 };

    PREFSMAN:SetPreference("BGBrightness",          tconf.DefaultBG and 0 or math.round(tconf.BGBrightness*100)/10000);
    PREFSMAN:SetPreference("Center1Player",         tconf.CenterPlayer);
    PREFSMAN:SetPreference("TimingWindowScale",     timing_mapping[tconf.TimingDifficulty] );
    PREFSMAN:SetPreference("LifeDifficultyScale",   life_mapping[tconf.LifeDifficulty] );
    PREFSMAN:SetPreference("AllowW1",               tconf.AllowW1 and "AllowW1_Everywhere" or "AllowW1_Never" );

    -------------------------------------------------------------------------------------------------------
    local sops= GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred");
    sops:MusicRate(tconf.MusicRate);
    sops:StaticBackground(tconf.DisableBGA);
    GAMESTATE:ApplyPreferredSongOptionsToOtherLevels();

    -------------------------------------------------------------------------------------------------------
    local fail_mapping  = {
        ["immediate"]   = "FailType_Immediate",
        ["delayed"]     = "FailType_ImmediateContinue",
        ["off"]         = "FailType_Off",
    };

    for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
        local pstate = GAMESTATE:GetPlayerState(pn);
        local plops = GetPreferredPlayerOptionsCompat(pstate);
        if plops then
            plops:FailSetting(fail_mapping[string.lower(tconf.FailType)])
        end;
        ApplyPlayerOptionsFromThemeConfig(pn);
        pstate:ApplyPreferredOptionsToOtherLevels();
    end;

end;

--//================================================================

local player_conf_default= {
    ShowOffsetMeter = false,
    ShowEarlyLate = false,
    ShowJudgmentList = false,
    ShowPacemaker = "off",
    ReverseJudgment = false,
    ScreenFilter = 0,
    SpeedModifier = 25,
}

NOTESCONFIG = notefield_prefs_config;
PLAYERCONFIG = create_lua_config{
    name = "PLAYERCONFIG", 
    file = "player_config.lua",
    default = player_conf_default,
}

add_standard_lua_config_save_load_hooks(PLAYERCONFIG);
set_notefield_default_yoffset(170)

--//================================================================

pacemaker_targets = {
    "off",
    "no target", 
    "best score", 
    "grade: D", 
    "grade: C", 
    "grade: B", 
    "grade: A", 
    "grade: AA", 
    "grade: AAA"
}

--//================================================================

function ResetPlayerSpeed(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    local pconf = PLAYERCONFIG:get_data(pn);
    nconf.speed_mod = 200;
    pconf.SpeedModifier = 25;
    nconf.speed_type = "multiple";

    NOTESCONFIG:set_dirty(pn);
    PLAYERCONFIG:set_dirty(pn);
end;

function ResetPlayerZoom(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.zoom = 1;
    nconf.zoom_x = 1;
    nconf.zoom_y = 1;
    nconf.zoom_z = 1;

    NOTESCONFIG:set_dirty(pn);
end;

function ResetPlayerRotation(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.rotation_x = 0;
    nconf.rotation_y = 0;
    nconf.rotation_z = 0;

    NOTESCONFIG:set_dirty(pn);
end;

function ResetPlayerView(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.reverse = 1;
    nconf.yoffset = 170;
    nconf.fov = 60;

    NOTESCONFIG:set_dirty(pn);
end;

function ResetPlayerDisplay(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    local pconf = PLAYERCONFIG:get_data(pn);
    nconf.hidden = false;
    nconf.sudden = false;
    nconf.hidden_offset = 120;
    nconf.sudden_offset = 190;
    nconf.fade_distance = 40;
    nconf.glow_during_fade = true;
    pconf.ReverseJudgment = false;

    NOTESCONFIG:set_dirty(pn);
    PLAYERCONFIG:set_dirty(pn);
end;

function ResetPlayerTransform(pn)
    ResetPlayerZoom(pn)
    ResetPlayerRotation(pn)
    ResetPlayerView(pn)
end;

--//================================================================

function NormalizeSpeedTypeForPMOD(speed_type)
    if speed_type == "multiple" or speed_type == "maximum" then
        return speed_type;
    end;
    if speed_type == "constant" then
        return "maximum";
    end;
    return "multiple";
end;

function GetPMODSpeedRange(pn, speed_type)
    local pconf = PLAYERCONFIG:get_data(pn);
    local step = (pconf and pconf.SpeedModifier) or 25;
    local mode = NormalizeSpeedTypeForPMOD(speed_type);

    if mode == "maximum" then
        return { Min = 100, Max = 1500, Step = step };
    end;

    return { Min = 100, Max = 600, Step = step };
end;

--//================================================================

function GetPreferredPlayerOptionsCompat(pstate)
    if not pstate then return nil end;

    if type(pstate.get_player_options_no_defect) == "function" then
        return pstate:get_player_options_no_defect("ModsLevel_Preferred");
    end;

    if type(pstate.GetPlayerOptions) == "function" then
        return pstate:GetPlayerOptions("ModsLevel_Preferred");
    end;

    return nil;
end;

--//================================================================

function ApplyPlayerOptionsFromThemeConfig(pn)
    if not pn then return end;

    local nconf = NOTESCONFIG:get_data(pn);
    local pconf = PLAYERCONFIG:get_data(pn);
    local pstate = GAMESTATE:GetPlayerState(pn);
    if not pstate then return end;

    local poptions = GetPreferredPlayerOptionsCompat(pstate);
    if not poptions then return end;
    local speed_type = NormalizeSpeedTypeForPMOD(nconf.speed_type);
    nconf.speed_type = speed_type;
    local speed_range = GetPMODSpeedRange(pn, speed_type);
    nconf.speed_mod = clamp(nconf.speed_mod, speed_range.Min, speed_range.Max);

    poptions:Expand(0);
    poptions:RandomVel(false);
    poptions:Accel(0);
    poptions:Decel(0);

    if speed_type == "maximum" then
        poptions:MMod(nconf.speed_mod, 1000);
    else
        poptions:MMod(nil);
        poptions:XMod(nconf.speed_mod / 100, 1000);
    end;

    poptions:JudgeReverse(pconf.ReverseJudgment and true or false);
    poptions:Reverse(nconf.reverse == -1 and 1 or 0);
    pstate:ApplyPreferredOptionsToOtherLevels();
end;

function SavePlayerOptionsFromThemeConfig(pn)
    if not pn then return end;

    NOTESCONFIG:set_dirty(pn);
    PLAYERCONFIG:set_dirty(pn);
    NOTESCONFIG:save(pn);
    PLAYERCONFIG:save(pn);
    ApplyPlayerOptionsFromThemeConfig(pn);
end;
