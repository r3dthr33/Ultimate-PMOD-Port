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

local timing_mapping = { 1.5, 1.33, 1.16, 1.00, 0.84, 0.66, 0.50, 0.33, 0.20 };
local life_mapping = { 1.6, 1.40, 1.20, 1.00, 0.80, 0.60, 0.40 };

local function GetClosestMappedIndex(value, mapping, fallback)
    local best_index = fallback or 1;
    local best_diff = math.huge;
    local target = tonumber(value);
    if not target then return best_index end;

    for i = 1, #mapping do
        local diff = math.abs(mapping[i] - target);
        if diff < best_diff then
            best_diff = diff;
            best_index = i;
        end;
    end;

    return best_index;
end;

local function SafeGetPreference(name)
    if not PREFSMAN or type(PREFSMAN.GetPreference) ~= "function" then return nil end;
    local ok, value = pcall(function() return PREFSMAN:GetPreference(name); end);
    if ok then return value end;
    return nil;
end;

local function SafeSetPreference(name, value)
    if not PREFSMAN or type(PREFSMAN.SetPreference) ~= "function" then return false end;
    local ok = pcall(function() PREFSMAN:SetPreference(name, value); end);
    return ok;
end;

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
    ApplyThemeSettings();
end;

--//================================================================

function ResetDisplayOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.BGBrightness = 100;
    tconf.DefaultBG = false;
    tconf.DisableBGA = false;
    tconf.CenterPlayer = false;
    THEMECONFIG:save();
    ApplyThemeSettings();
end;

function ResetSongOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.MusicRate = 1.0;
    tconf.FailType = "delayed";
    tconf.FailMissCombo = true;
    THEMECONFIG:save();
    ApplyThemeSettings();
end;

function ResetJudgmentOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.AllowW1 = true;
    tconf.TimingDifficulty = 4;
    tconf.LifeDifficulty = 4;
    THEMECONFIG:save();
    ApplyThemeSettings();
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
    -- PMOD does not use a PREFSMAN "BGBrightness" preference. Ultimate keeps
    -- this as theme-local data and reads it directly in ScreenGameplay background.
    SafeSetPreference("Center1Player", tconf.CenterPlayer);
    SafeSetPreference("AllowW1", tconf.AllowW1 and "AllowW1_Everywhere" or "AllowW1_Never");

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
    PMOD_Vanish = false,
    PMOD_Appear = false,
    PMOD_Nonstep = false,
    PMOD_Dark = false,
    PMOD_RandomNote = false,
    PMOD_Flash = false,
    PMOD_Mini = false,
    PMOD_BGA = "normal",
    PMOD_XMode = false,
    PMOD_NXMode = false,
    PMOD_UnderAttack = false,
    PMOD_Drop = false,
    PMOD_Rise = "off",
    PMOD_Snake = false,
    PMOD_ZigZag = false,
    PMOD_Mirror = false,
    PMOD_SuperShuffle = false,
    PMOD_Backwards = false,
    PMOD_JudgeDifficulty = "normal",
    SpeedModifier = 25,
    SpeedEffect = "none",
    SpeedExpand = false,
    SpeedRandomVel = false,
    SpeedAccel = false,
    SpeedDecel = false,
    PreferredSort = "TITLE",
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

local pmod_music_rate_choices = {
    0.60, 0.70, 0.80, 0.90,
    1.00, 1.10, 1.20, 1.30,
    1.40, 1.50, 1.60, 1.70,
}

local pmod_sort_choices = { "TITLE", "ARTIST", "BPM", "LENGTH", "PLAYED" }

local pmod_judgment_levels = { "normal", "hard", "veryhard", "extra", "ultra" }
local pmod_rise_choices = { "off", "sink", "rise" }
local pmod_bga_choices = { "normal", "off", "dark", "partial" }

local pmod_bool_fields = {
    Vanish = "PMOD_Vanish",
    Appear = "PMOD_Appear",
    Nonstep = "PMOD_Nonstep",
    Dark = "PMOD_Dark",
    RandomNote = "PMOD_RandomNote",
    Flash = "PMOD_Flash",
    Mini = "PMOD_Mini",
    XMode = "PMOD_XMode",
    NXMode = "PMOD_NXMode",
    UnderAttack = "PMOD_UnderAttack",
    Drop = "PMOD_Drop",
    Snake = "PMOD_Snake",
    ZigZag = "PMOD_ZigZag",
    Mirror = "PMOD_Mirror",
    SuperShuffle = "PMOD_SuperShuffle",
    Backwards = "PMOD_Backwards",
}

function GetStoredPMODBool(pn, name, fallback)
    local pconf = PLAYERCONFIG:get_data(pn);
    local field = pmod_bool_fields[name];
    if pconf and field and pconf[field] ~= nil then
        return pconf[field] and true or false;
    end;
    if fallback == nil then return nil end;
    return fallback and true or false;
end;

function SetStoredPMODBool(pn, name, value)
    local pconf = PLAYERCONFIG:get_data(pn);
    local field = pmod_bool_fields[name];
    if not pconf or not field then return end;
    pconf[field] = value and true or false;
    PLAYERCONFIG:set_dirty(pn);
end;

--//================================================================

function GetPlayerProfileCompat(pn)
    if not pn then return nil end;
    return PROFILEMAN and PROFILEMAN:GetProfile(pn) or nil;
end;

function GetProfileBGAOptionCompat(pn)
    local profile = GetPlayerProfileCompat(pn);
    if profile and type(profile.GetBGAOption) == "function" then
        return profile:GetBGAOption() or 0;
    end;
    return 0;
end;

function SetProfileBGAOptionCompat(pn, value)
    local profile = GetPlayerProfileCompat(pn);
    if profile and type(profile.SetBGAOption) == "function" then
        profile:SetBGAOption(value or 0);
    end;
end;

function GetProfileCustomOptionCompat(pn, key, default)
    local profile = GetPlayerProfileCompat(pn);
    if profile and type(profile.GetCustomOptionValue) == "function" then
        local value = profile:GetCustomOptionValue(key);
        if value ~= nil then return value end;
    end;
    return default;
end;

function SetProfileCustomOptionCompat(pn, key, value)
    local profile = GetPlayerProfileCompat(pn);
    if profile and type(profile.SetCustomOptionValue) == "function" then
        profile:SetCustomOptionValue(key, value);
    end;
end;

function GetPreferredSongOptionsCompat()
    if type(GAMESTATE.GetSongOptionsObject) == "function" then
        return GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred");
    end;
    return nil;
end;

function GetCenterPlayerCompat()
    local value = SafeGetPreference("Center1Player");
    if value ~= nil then return value and true or false end;
    return THEMECONFIG:get_data("ProfileSlot_Invalid").CenterPlayer and true or false;
end;

function SetCenterPlayerCompat(value)
    local enabled = value and true or false;
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.CenterPlayer = enabled;
    THEMECONFIG:set_dirty("ProfileSlot_Invalid");
    THEMECONFIG:save("ProfileSlot_Invalid");
    SafeSetPreference("Center1Player", enabled);
end;

function GetDisableBGACompat()
    local sops = GetPreferredSongOptionsCompat();
    if sops and type(sops.StaticBackground) == "function" then
        local value = sops:StaticBackground();
        if value ~= nil then return value and true or false end;
    end;
    return THEMECONFIG:get_data("ProfileSlot_Invalid").DisableBGA and true or false;
end;

function SetDisableBGACompat(value)
    local enabled = value and true or false;
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.DisableBGA = enabled;
    THEMECONFIG:set_dirty("ProfileSlot_Invalid");
    THEMECONFIG:save("ProfileSlot_Invalid");
    local sops = GetPreferredSongOptionsCompat();
    if sops and type(sops.StaticBackground) == "function" then
        sops:StaticBackground(enabled);
        if type(GAMESTATE.ApplyPreferredSongOptionsToOtherLevels) == "function" then
            GAMESTATE:ApplyPreferredSongOptionsToOtherLevels();
        end;
    end;
end;

function GetMusicRateCompat()
    local sops = GetPreferredSongOptionsCompat();
    if sops and type(sops.MusicRate) == "function" then
        return sops:MusicRate();
    end;
    return THEMECONFIG:get_data("ProfileSlot_Invalid").MusicRate or 1.0;
end;

function SetMusicRateCompat(rate)
    local clamped = clamp(tonumber(rate) or 1.0, 0.5, 2.0);
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.MusicRate = clamped;
    THEMECONFIG:set_dirty("ProfileSlot_Invalid");
    THEMECONFIG:save("ProfileSlot_Invalid");

    local sops = GetPreferredSongOptionsCompat();
    if sops and type(sops.MusicRate) == "function" then
        sops:MusicRate(clamped);
        if type(GAMESTATE.ApplyPreferredSongOptionsToOtherLevels) == "function" then
            GAMESTATE:ApplyPreferredSongOptionsToOtherLevels();
        end;
    end;
end;

function GetAllowW1Compat()
    local value = SafeGetPreference("AllowW1");
    if value == "AllowW1_Never" then return false end;
    if value == "AllowW1_Everywhere" then return true end;
    return THEMECONFIG:get_data("ProfileSlot_Invalid").AllowW1 and true or false;
end;

function SetAllowW1Compat(value)
    local enabled = value and true or false;
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.AllowW1 = enabled;
    THEMECONFIG:set_dirty("ProfileSlot_Invalid");
    THEMECONFIG:save("ProfileSlot_Invalid");
    SafeSetPreference("AllowW1", enabled and "AllowW1_Everywhere" or "AllowW1_Never");
end;

function GetTimingDifficultyCompat()
    return THEMECONFIG:get_data("ProfileSlot_Invalid").TimingDifficulty or 4;
end;

function SetTimingDifficultyCompat(value)
    local index = clamp(tonumber(value) or 4, 1, #timing_mapping);
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.TimingDifficulty = index;
    THEMECONFIG:set_dirty("ProfileSlot_Invalid");
    THEMECONFIG:save("ProfileSlot_Invalid");
end;

function GetLifeDifficultyCompat()
    return THEMECONFIG:get_data("ProfileSlot_Invalid").LifeDifficulty or 4;
end;

function SetLifeDifficultyCompat(value)
    local index = clamp(tonumber(value) or 4, 1, #life_mapping);
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.LifeDifficulty = index;
    THEMECONFIG:set_dirty("ProfileSlot_Invalid");
    THEMECONFIG:save("ProfileSlot_Invalid");
end;

function GetPreferredSortCompat()
    if type(GAMESTATE.GetMusicSort) == "function" then
        local current = GAMESTATE:GetMusicSort();
        if current and current ~= "" then return string.upper(current) end;
    end;
    return PLAYERCONFIG:get_data(Global.master or PLAYER_1).PreferredSort or "TITLE";
end;

function SetPreferredSortCompat(value)
    local normalized = string.upper(tostring(value or "TITLE"));
    local pconf = PLAYERCONFIG:get_data(Global.master or PLAYER_1);
    pconf.PreferredSort = normalized;
    PLAYERCONFIG:set_dirty(Global.master or PLAYER_1);
    PLAYERCONFIG:save(Global.master or PLAYER_1);

    if type(GAMESTATE.SetMusicSort) == "function" then
        pcall(function() GAMESTATE:SetMusicSort(normalized); end);
    end;

    if SCREENMAN and type(SCREENMAN.GetTopScreen) == "function" then
        local screen = SCREENMAN:GetTopScreen();
        if screen then
            if type(screen.SetMusicSort) == "function" then
                pcall(function() screen:SetMusicSort(normalized); end);
            elseif type(screen.SortBy) == "function" then
                pcall(function() screen:SortBy(normalized); end);
            end;
        end;
    end;
end;

function GetPMODRiseMode(pn)
    local pconf = PLAYERCONFIG:get_data(pn);
    if pconf and pconf.PMOD_Rise and pconf.PMOD_Rise ~= "" then
        return pconf.PMOD_Rise;
    end;
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    local rise = poptions and type(poptions.Rise) == "function" and poptions:Rise() or 0;
    if rise == -1 or rise == -1.0 then return "sink" end;
    if rise == 1 or rise == 1.0 then return "rise" end;
    return "off";
end;

function SetPMODRiseMode(pn, value)
    local pconf = PLAYERCONFIG:get_data(pn);
    if pconf then
        pconf.PMOD_Rise = value or "off";
        PLAYERCONFIG:set_dirty(pn);
    end;
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    if not poptions or type(poptions.Rise) ~= "function" then return end;
    if value == "sink" then
        poptions:Rise(-1.0);
    elseif value == "rise" then
        poptions:Rise(1.0);
    else
        poptions:Rise(0.0);
    end;
    GAMESTATE:GetPlayerState(pn):ApplyPreferredOptionsToOtherLevels();
end;

function GetPMODJudgeDifficulty(pn)
    local pconf = PLAYERCONFIG:get_data(pn);
    if pconf and pconf.PMOD_JudgeDifficulty and pconf.PMOD_JudgeDifficulty ~= "" then
        return pconf.PMOD_JudgeDifficulty;
    end;
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    if not poptions then return "normal" end;
    if type(poptions.UltraHardJudgement) == "function" and poptions:UltraHardJudgement() then return "ultra" end;
    if type(poptions.ExtraJudgement) == "function" and poptions:ExtraJudgement() then return "extra" end;
    if type(poptions.VeryHardJudgement) == "function" and poptions:VeryHardJudgement() then return "veryhard" end;
    if type(poptions.HardJudgement) == "function" and poptions:HardJudgement() then return "hard" end;
    return "normal";
end;

function SetPMODJudgeDifficulty(pn, value)
    local pconf = PLAYERCONFIG:get_data(pn);
    if pconf then
        pconf.PMOD_JudgeDifficulty = value or "normal";
        PLAYERCONFIG:set_dirty(pn);
    end;
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    if not poptions then return end;
    if type(poptions.HardJudgement) == "function" then poptions:HardJudgement(false) end;
    if type(poptions.VeryHardJudgement) == "function" then poptions:VeryHardJudgement(false) end;
    if type(poptions.ExtraJudgement) == "function" then poptions:ExtraJudgement(false) end;
    if type(poptions.UltraHardJudgement) == "function" then poptions:UltraHardJudgement(false) end;

    if value == "hard" and type(poptions.HardJudgement) == "function" then poptions:HardJudgement(true) end;
    if value == "veryhard" and type(poptions.VeryHardJudgement) == "function" then poptions:VeryHardJudgement(true) end;
    if value == "extra" and type(poptions.ExtraJudgement) == "function" then poptions:ExtraJudgement(true) end;
    if value == "ultra" and type(poptions.UltraHardJudgement) == "function" then poptions:UltraHardJudgement(true) end;
    GAMESTATE:GetPlayerState(pn):ApplyPreferredOptionsToOtherLevels();
end;

function GetPMODBGAChoice(pn)
    local pconf = PLAYERCONFIG:get_data(pn);
    if pconf and pconf.PMOD_BGA and pconf.PMOD_BGA ~= "" then
        return pconf.PMOD_BGA;
    end;
    local value = GetProfileBGAOptionCompat(pn);
    if value == 1 then return "off" end;
    if value == 2 then return "dark" end;
    if value == 3 then return "partial" end;
    return "normal";
end;

function SetPMODBGAChoice(pn, value)
    local pconf = PLAYERCONFIG:get_data(pn);
    if pconf then
        pconf.PMOD_BGA = value or "normal";
        PLAYERCONFIG:set_dirty(pn);
    end;
    local mapping = {
        normal = 0,
        off = 1,
        dark = 2,
        partial = 3,
    };
    SetProfileBGAOptionCompat(pn, mapping[value] or 0);
end;

function GetPMODJudgmentSkinList()
    local folders = {};
    local themeName = THEME:GetCurThemeName();
    local internal = FILEMAN:GetDirListing("/Themes/" .. themeName .. "/Graphics/Player judgment/skins/", true, false) or {};
    for _, entry in ipairs(internal) do
        folders[#folders+1] = "i_" .. entry;
    end;
    if FolderExists("/judgmentSkins/") then
        local external = FILEMAN:GetDirListing("/judgmentSkins/", true, false) or {};
        for _, entry in ipairs(external) do
            folders[#folders+1] = "e_" .. entry;
        end;
    end;
    return folders;
end;

function GetPMODLifeBarSkinList()
    local folders = {};
    local themeName = THEME:GetCurThemeName();
    local internal = FILEMAN:GetDirListing("/Themes/" .. themeName .. "/Graphics/ScreenGamePlay_ui/lifebar/", true, false) or {};
    for _, entry in ipairs(internal) do
        folders[#folders+1] = "i_" .. entry;
    end;
    if FolderExists("/lifebarSkins/") then
        local external = FILEMAN:GetDirListing("/lifebarSkins/", true, false) or {};
        for _, entry in ipairs(external) do
            folders[#folders+1] = "e_" .. entry;
        end;
    end;
    return folders;
end;

function ApplyGameplayFastSlowCompat(pn)
    if type(GAMESTATE.SetExtraJudgment) == "function" then
        GAMESTATE:SetExtraJudgment(pn, GetProfileCustomOptionCompat(pn, "gameplay_fastslow", true));
    end;
end;

function ResetPMODDisplay(pn)
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    if not poptions then return end;
    SetStoredPMODBool(pn, "Vanish", false);
    SetStoredPMODBool(pn, "Appear", false);
    SetStoredPMODBool(pn, "Nonstep", false);
    SetStoredPMODBool(pn, "Dark", false);
    SetStoredPMODBool(pn, "RandomNote", false);
    SetStoredPMODBool(pn, "Flash", false);
    SetStoredPMODBool(pn, "Mini", false);
    if type(poptions.Vanish) == "function" then poptions:Vanish(0) end;
    if type(poptions.Appear) == "function" then poptions:Appear(0) end;
    if type(poptions.Nonstep) == "function" then poptions:Nonstep(0) end;
    if type(poptions.Dark) == "function" then poptions:Dark(0) end;
    if type(poptions.RandomNote) == "function" then poptions:RandomNote(false) end;
    if type(poptions.Flash) == "function" then poptions:Flash(0) end;
    if type(poptions.Mini) == "function" then poptions:Mini(0.0) end;
    SetPMODBGAChoice(pn, "normal");
    GAMESTATE:GetPlayerState(pn):ApplyPreferredOptionsToOtherLevels();
end;

function ResetPMODPath(pn)
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    if not poptions then return end;
    SetStoredPMODBool(pn, "XMode", false);
    SetStoredPMODBool(pn, "NXMode", false);
    SetStoredPMODBool(pn, "UnderAttack", false);
    SetStoredPMODBool(pn, "Drop", false);
    local pconf = PLAYERCONFIG:get_data(pn);
    if pconf then
        pconf.PMOD_Rise = "off";
        PLAYERCONFIG:set_dirty(pn);
    end;
    SetStoredPMODBool(pn, "Snake", false);
    SetStoredPMODBool(pn, "ZigZag", false);
    if type(poptions.Xmode) == "function" then poptions:Xmode(0) end;
    if type(poptions.NXMode) == "function" then poptions:NXMode(false) end;
    if type(poptions.UnderAttack) == "function" then poptions:UnderAttack(false) end;
    if type(poptions.Drop) == "function" then poptions:Drop(false) end;
    if type(poptions.Rise) == "function" then poptions:Rise(0.0) end;
    if type(poptions.Snake) == "function" then poptions:Snake(false) end;
    if type(poptions.ZigZag) == "function" then poptions:ZigZag(false) end;
    GAMESTATE:GetPlayerState(pn):ApplyPreferredOptionsToOtherLevels();
end;

function ResetPMODAlternate(pn)
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    if not poptions then return end;
    SetStoredPMODBool(pn, "Mirror", false);
    SetStoredPMODBool(pn, "SuperShuffle", false);
    SetStoredPMODBool(pn, "Backwards", false);
    if type(poptions.Mirror) == "function" then poptions:Mirror(false) end;
    if type(poptions.SuperShuffle) == "function" then poptions:SuperShuffle(false) end;
    if type(poptions.Backwards) == "function" then poptions:Backwards(false) end;
    GAMESTATE:GetPlayerState(pn):ApplyPreferredOptionsToOtherLevels();
end;

function ResetPMODJudge(pn)
    SetPMODJudgeDifficulty(pn, "normal");
    local pconf = PLAYERCONFIG:get_data(pn);
    pconf.ReverseJudgment = false;
    pconf.PMOD_JudgeDifficulty = "normal";
    PLAYERCONFIG:set_dirty(pn);
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    if poptions and type(poptions.JudgeReverse) == "function" then
        poptions:JudgeReverse(false);
        GAMESTATE:GetPlayerState(pn):ApplyPreferredOptionsToOtherLevels();
    end;
end;

function ResetPMODGameplayUI(pn)
    SetProfileCustomOptionCompat(pn, "gameplay_fastslow", true);
    SetProfileCustomOptionCompat(pn, "gameplay_break_icon_ui", true);
    SetProfileCustomOptionCompat(pn, "gameplay_score_ui", true);
    SetProfileCustomOptionCompat(pn, "gameplay_stats_ui", true);
    SetProfileCustomOptionCompat(pn, "gameplay_song_time_ui", true);
    SetProfileCustomOptionCompat(pn, "gameplay_lv_ui", true);
    ApplyGameplayFastSlowCompat(pn);
end;

function ResetPMODVisualSkins(pn)
    SetProfileCustomOptionCompat(pn, "judgmentSkin", "phoenix");
    SetProfileCustomOptionCompat(pn, "judgmentZoom", 100);
    SetProfileCustomOptionCompat(pn, "lifebarSkin", "i_default");
end;

--//================================================================

function ResetPlayerSpeed(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    local pconf = PLAYERCONFIG:get_data(pn);
    nconf.speed_mod = 200;
    pconf.SpeedModifier = 25;
    pconf.SpeedEffect = "none";
    pconf.SpeedExpand = false;
    pconf.SpeedRandomVel = false;
    pconf.SpeedAccel = false;
    pconf.SpeedDecel = false;
    nconf.speed_type = "multiple";

    NOTESCONFIG:set_dirty(pn);
    PLAYERCONFIG:set_dirty(pn);
end;

local pmod_speed_effect_fields = {
    expand = "SpeedExpand",
    randomvel = "SpeedRandomVel",
    accel = "SpeedAccel",
    decel = "SpeedDecel",
}

function GetPMODSpeedEffectToggle(pn, effect)
    local pconf = PLAYERCONFIG:get_data(pn);
    local field = pmod_speed_effect_fields[effect];
    if not pconf or not field then return false end;
    if pconf[field] ~= nil then
        return pconf[field] and true or false;
    end;
    return (pconf.SpeedEffect or "none") == effect;
end;

function SetPMODSpeedEffectToggle(pn, effect, enabled)
    local pconf = PLAYERCONFIG:get_data(pn);
    local field = pmod_speed_effect_fields[effect];
    if not pconf or not field then return end;

    for name, key in pairs(pmod_speed_effect_fields) do
        if enabled then
            pconf[key] = (name == effect);
        elseif name == effect then
            pconf[key] = false;
        end;
    end;

    pconf.SpeedEffect = "none";
    for name, key in pairs(pmod_speed_effect_fields) do
        if pconf[key] then
            pconf.SpeedEffect = name;
            break;
        end;
    end;

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
    local profile = GetPlayerProfileCompat(pn);
    local speed_type = NormalizeSpeedTypeForPMOD(nconf.speed_type);
    local speed_expand = GetPMODSpeedEffectToggle(pn, "expand");
    local speed_randomvel = GetPMODSpeedEffectToggle(pn, "randomvel");
    local speed_accel = GetPMODSpeedEffectToggle(pn, "accel");
    local speed_decel = GetPMODSpeedEffectToggle(pn, "decel");
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

    if speed_expand then
        poptions:Expand(1);
        poptions:MMod(nil);
        poptions:XMod(2, 1000);
    elseif speed_randomvel then
        poptions:RandomVel(true);
        poptions:MMod(nil);
        poptions:XMod(2, 1000);
    elseif speed_accel then
        poptions:Accel(1);
        poptions:MMod(nil);
        poptions:XMod(2, 1000);
    elseif speed_decel then
        poptions:Decel(1);
        poptions:MMod(nil);
        poptions:XMod(2, 1000);
    end;

    if type(poptions.Vanish) == "function" then poptions:Vanish(GetStoredPMODBool(pn, "Vanish", false) and 1 or 0) end;
    if type(poptions.Appear) == "function" then poptions:Appear(GetStoredPMODBool(pn, "Appear", false) and 1 or 0) end;
    if type(poptions.Nonstep) == "function" then poptions:Nonstep(GetStoredPMODBool(pn, "Nonstep", false) and 1 or 0) end;
    if type(poptions.Dark) == "function" then poptions:Dark(GetStoredPMODBool(pn, "Dark", false) and 1 or 0) end;
    if type(poptions.RandomNote) == "function" then poptions:RandomNote(GetStoredPMODBool(pn, "RandomNote", false)) end;
    if type(poptions.Flash) == "function" then poptions:Flash(GetStoredPMODBool(pn, "Flash", false) and 1 or 0) end;
    if type(poptions.Mini) == "function" then poptions:Mini(GetStoredPMODBool(pn, "Mini", false) and 0.5 or 0.0) end;

    if type(poptions.Xmode) == "function" then poptions:Xmode(GetStoredPMODBool(pn, "XMode", false) and 1 or 0) end;
    if type(poptions.NXMode) == "function" then poptions:NXMode(GetStoredPMODBool(pn, "NXMode", false)) end;
    if type(poptions.UnderAttack) == "function" then poptions:UnderAttack(GetStoredPMODBool(pn, "UnderAttack", false)) end;
    if type(poptions.Drop) == "function" then poptions:Drop(GetStoredPMODBool(pn, "Drop", false)) end;
    if type(poptions.Rise) == "function" then
        local rise = GetPMODRiseMode(pn);
        if rise == "sink" then
            poptions:Rise(-1.0);
        elseif rise == "rise" then
            poptions:Rise(1.0);
        else
            poptions:Rise(0.0);
        end;
    end;
    if type(poptions.Snake) == "function" then poptions:Snake(GetStoredPMODBool(pn, "Snake", false)) end;
    if type(poptions.ZigZag) == "function" then poptions:ZigZag(GetStoredPMODBool(pn, "ZigZag", false)) end;

    if type(poptions.Mirror) == "function" then poptions:Mirror(GetStoredPMODBool(pn, "Mirror", false)) end;
    if type(poptions.SuperShuffle) == "function" then poptions:SuperShuffle(GetStoredPMODBool(pn, "SuperShuffle", false)) end;
    if type(poptions.Backwards) == "function" then poptions:Backwards(GetStoredPMODBool(pn, "Backwards", false)) end;

    if type(poptions.HardJudgement) == "function" then poptions:HardJudgement(false) end;
    if type(poptions.VeryHardJudgement) == "function" then poptions:VeryHardJudgement(false) end;
    if type(poptions.ExtraJudgement) == "function" then poptions:ExtraJudgement(false) end;
    if type(poptions.UltraHardJudgement) == "function" then poptions:UltraHardJudgement(false) end;
    local judge = GetPMODJudgeDifficulty(pn);
    if judge == "hard" and type(poptions.HardJudgement) == "function" then poptions:HardJudgement(true) end;
    if judge == "veryhard" and type(poptions.VeryHardJudgement) == "function" then poptions:VeryHardJudgement(true) end;
    if judge == "extra" and type(poptions.ExtraJudgement) == "function" then poptions:ExtraJudgement(true) end;
    if judge == "ultra" and type(poptions.UltraHardJudgement) == "function" then poptions:UltraHardJudgement(true) end;

    SetProfileBGAOptionCompat(pn, ({ normal = 0, off = 1, dark = 2, partial = 3 })[GetPMODBGAChoice(pn)] or 0);

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
