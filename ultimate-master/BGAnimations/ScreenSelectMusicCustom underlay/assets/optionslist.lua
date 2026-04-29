local maxitems = 9;
local selection = {
    [PLAYER_1] = 1,
    [PLAYER_2] = 1,
};

local currentoption = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
};

local option_stack = {
    [PLAYER_1] = {},
    [PLAYER_2] = {},
};

local selection_stack = {
    [PLAYER_1] = {},
    [PLAYER_2] = {},
};

local ConfigCustomRangeCompat = ConfigCustomRange or function(name, default, min, max, step, getter, setter)
    return {
        Name = name,
        Type = "range",
        Field = name,
        Default = default,
        Range = { Min = min, Max = max, Step = step },
        Get = getter,
        Set = setter,
    }
end;

local ConfigCustomChoicesCompat = ConfigCustomChoices or function(name, default, choices, getter, setter)
    return {
        Name = name,
        Type = "choices",
        Field = name,
        Default = default,
        Choices = choices,
        Get = getter,
        Set = setter,
    }
end;

local ConfigCustomBoolCompat = ConfigCustomBool or function(name, default, getter, setter, choices)
    return {
        Name = name,
        Type = "bool",
        Field = name,
        Default = default,
        Choices = choices or { true, false },
        Get = getter,
        Set = setter,
    }
end;

local local_speed_effect_fields = {
    expand = "SpeedExpand",
    randomvel = "SpeedRandomVel",
    accel = "SpeedAccel",
    decel = "SpeedDecel",
};

local function GetPMODSpeedEffectToggleCompat(pn, effect)
    if type(GetPMODSpeedEffectToggle) == "function" then
        return GetPMODSpeedEffectToggle(pn, effect);
    end;

    local pconf = PLAYERCONFIG:get_data(pn);
    local field = local_speed_effect_fields[effect];
    if not pconf or not field then return false end;
    if pconf[field] ~= nil then
        return pconf[field] and true or false;
    end;
    return (pconf.SpeedEffect or "none") == effect;
end;

local function SetPMODSpeedEffectToggleCompat(pn, effect, enabled)
    if type(SetPMODSpeedEffectToggle) == "function" then
        SetPMODSpeedEffectToggle(pn, effect, enabled);
        return;
    end;

    local pconf = PLAYERCONFIG:get_data(pn);
    local field = local_speed_effect_fields[effect];
    if not pconf or not field then return end;

    for name, key in pairs(local_speed_effect_fields) do
        if enabled then
            pconf[key] = (name == effect);
        elseif name == effect then
            pconf[key] = false;
        end;
    end;

    pconf.SpeedEffect = "none";
    for name, key in pairs(local_speed_effect_fields) do
        if pconf[key] then
            pconf.SpeedEffect = name;
            break;
        end;
    end;

    PLAYERCONFIG:set_dirty(pn);
end;

local function SaveOptionListState(pn)
    SavePlayerOptionsFromThemeConfig(pn);
end;

local function ApplyPreferredOptionsNow(pn)
    local pstate = GAMESTATE:GetPlayerState(pn);
    if pstate and type(pstate.ApplyPreferredOptionsToOtherLevels) == "function" then
        pstate:ApplyPreferredOptionsToOtherLevels();
    end;
end;

local function GetPreferredOptionMethod(pn, method, default)
    local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
    if poptions and type(poptions[method]) == "function" then
        local value = poptions[method](poptions);
        if value ~= nil then return value end;
    end;
    return default;
end;

local function ConfigPMODBool(name, getter_name, setter_name, default, true_value, false_value)
    return ConfigCustomBoolCompat(name, default,
        function(pn)
            local stored = type(GetStoredPMODBool) == "function" and GetStoredPMODBool(pn, name, nil) or nil;
            if stored ~= nil then return stored and true or false end;
            local value = GetPreferredOptionMethod(pn, getter_name, default);
            if type(value) == "number" then return value ~= 0 end;
            return value and true or false;
        end,
        function(pn, newvalue)
            if type(SetStoredPMODBool) == "function" then
                SetStoredPMODBool(pn, name, newvalue);
            end;
            local poptions = GetPreferredPlayerOptionsCompat(GAMESTATE:GetPlayerState(pn));
            if not poptions or type(poptions[setter_name]) ~= "function" then return end;
            local on_value = true_value;
            local off_value = false_value;
            if on_value == nil then on_value = true end;
            if off_value == nil then
                if type(on_value) == "number" then off_value = 0 else off_value = false end;
            end;
            poptions[setter_name](poptions, newvalue and on_value or off_value);
            ApplyPreferredOptionsNow(pn);
        end
    );
end;

local function ConfigProfileBool(name, key, default)
    return ConfigCustomBoolCompat(name, default,
        function(pn) return GetProfileCustomOptionCompat(pn, key, default) and true or false end,
        function(pn, newvalue)
            SetProfileCustomOptionCompat(pn, key, newvalue and true or false);
            if key == "gameplay_fastslow" then ApplyGameplayFastSlowCompat(pn) end;
        end
    );
end;

local function ConfigProfileRange(name, key, default, min, max, step)
    return ConfigCustomRangeCompat(name, default, min, max, step,
        function(pn) return GetProfileCustomOptionCompat(pn, key, default) end,
        function(pn, newvalue) SetProfileCustomOptionCompat(pn, key, newvalue) end
    );
end;

local function ConfigProfileChoices(name, key, default, choices)
    return ConfigCustomChoicesCompat(name, default, choices,
        function(pn) return GetProfileCustomOptionCompat(pn, key, default) end,
        function(pn, newvalue) SetProfileCustomOptionCompat(pn, key, newvalue) end
    );
end;

local function PrepareSpeedOption(option, pn)
    local nconf = NOTESCONFIG:get_data(pn);
    local mode = NormalizeSpeedTypeForPMOD(nconf.speed_type);
    nconf.speed_type = mode;

    if option and option.Field == "speed_mod" then
        local range = GetPMODSpeedRange(pn, mode);
        option.Range.Min = range.Min;
        option.Range.Max = range.Max;
        option.Range.Step = range.Step;
    elseif option and option.Field == "speed_type" then
        option.Choices = { "multiple", "maximum" };
    end;
end;

local function NoteskinMenu(pn)
    local noteskins = GetNoteskins();
    local noteskin_stack = {};
    for i=1,#noteskins do 
        table.insert(noteskin_stack, ConfigNoteskin(noteskins[i]) );
    end
    table.insert(noteskin_stack, ConfigExit("Back"));
    table.insert(selection_stack[pn], selection[pn]);
    table.insert(option_stack[pn], noteskin_stack);
    selection[pn] = GetNoteskinSelection(pn);
    MESSAGEMAN:Broadcast("OptionsListSelected", { Player = pn, silent = true });
    MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
end;

local function NoteskinChoices()
    local noteskins = GetNoteskins() or {};
    if #noteskins == 0 then
        return { NOTESKIN:GetDefaultGameNoteSkin() };
    end;
    return noteskins;
end;

local function JudgmentSkinChoices()
    local raw = GetPMODJudgmentSkinList();
    local choices = {};
    for i = 1, #raw do
        local fixed = string.gsub(raw[i], "^i_", "");
        fixed = string.gsub(fixed, "^e_", "");
        choices[#choices+1] = fixed;
    end;
    if #choices == 0 then return { "phoenix" } end;
    return choices;
end;

local function LifebarSkinChoices()
    local choices = GetPMODLifeBarSkinList();
    if #choices == 0 then return { "i_default" } end;
    return choices;
end;

local option_tree = { 
    {
        Name = "Speed",
        Options = {
            ConfigRange(NOTESCONFIG, "speed_mod", 200, 100, 600, 25),
            ConfigChoices(PLAYERCONFIG, "SpeedModifier", 25, { 1, 10, 25, 50, 100 }),
            ConfigChoices(NOTESCONFIG, "speed_type", "multiple", { "multiple", "maximum" }),
            ConfigCustomBoolCompat("Expand", false,
                function(pn) return GetPMODSpeedEffectToggleCompat(pn, "expand") end,
                function(pn, newvalue) SetPMODSpeedEffectToggleCompat(pn, "expand", newvalue) end
            ),
            ConfigCustomBoolCompat("RandomVel", false,
                function(pn) return GetPMODSpeedEffectToggleCompat(pn, "randomvel") end,
                function(pn, newvalue) SetPMODSpeedEffectToggleCompat(pn, "randomvel", newvalue) end
            ),
            ConfigCustomBoolCompat("Accel", false,
                function(pn) return GetPMODSpeedEffectToggleCompat(pn, "accel") end,
                function(pn, newvalue) SetPMODSpeedEffectToggleCompat(pn, "accel", newvalue) end
            ),
            ConfigCustomBoolCompat("Decel", false,
                function(pn) return GetPMODSpeedEffectToggleCompat(pn, "decel") end,
                function(pn, newvalue) SetPMODSpeedEffectToggleCompat(pn, "decel", newvalue) end
            ),
            ConfigAction("Reset", function(pn) ResetPlayerSpeed(pn) end),
            ConfigExit("Back"),
        },
    },
    ConfigCustomChoicesCompat("Noteskin", NOTESKIN:GetDefaultGameNoteSkin(), NoteskinChoices(),
        function(pn) return GetPreferredNoteskin(pn) end,
        function(pn, newvalue) SetNoteskin(pn, newvalue) end
    ),
    {
        Name = "Display",
        Options = {
            ConfigPMODBool("Vanish", "Vanish", "Vanish", false, 1, 0),
            ConfigPMODBool("Appear", "Appear", "Appear", false, 1, 0),
            ConfigPMODBool("Nonstep", "Nonstep", "Nonstep", false, 1, 0),
            ConfigPMODBool("Dark", "Dark", "Dark", false, 1, 0),
            ConfigPMODBool("RandomNote", "RandomNote", "RandomNote", false),
            ConfigPMODBool("Flash", "Flash", "Flash", false, 1, 0),
            ConfigPMODBool("Mini", "Mini", "Mini", false, 0.5, 0.0),
            ConfigCustomChoicesCompat("BGA", "normal", { "normal", "off", "dark", "partial" },
                function(pn) return GetPMODBGAChoice(pn) end,
                function(pn, newvalue) SetPMODBGAChoice(pn, newvalue) end
            ),
            ConfigBool(NOTESCONFIG, "hidden", false),
            ConfigBool(NOTESCONFIG, "sudden", false),
            ConfigBool(NOTESCONFIG, "glow_during_fade", true),
            {
                Name = "Extras",
                Options = {
                    ConfigRange(PLAYERCONFIG, "ScreenFilter", 0, 0, 100, 5),
                    ConfigBool(PLAYERCONFIG, "ShowEarlyLate", false),
                    ConfigBool(PLAYERCONFIG, "ShowJudgmentList", false),
                    ConfigBool(PLAYERCONFIG, "ShowOffsetMeter", false),
                    ConfigExit("Back"),
                }
            },
            ConfigAction("Reset", function(pn)
                ResetPlayerDisplay(pn);
                ResetPMODDisplay(pn);
            end),
            ConfigExit("Back"),
        },
    },
    {
        Name = "Path",
        Options = {
            ConfigPMODBool("XMode", "Xmode", "Xmode", false, 1, 0),
            ConfigPMODBool("NXMode", "NXMode", "NXMode", false),
            ConfigPMODBool("UnderAttack", "UnderAttack", "UnderAttack", false),
            ConfigPMODBool("Drop", "Drop", "Drop", false),
            ConfigCustomChoicesCompat("Rise", "off", { "off", "sink", "rise" },
                function(pn) return GetPMODRiseMode(pn) end,
                function(pn, newvalue) SetPMODRiseMode(pn, newvalue) end
            ),
            ConfigPMODBool("Snake", "Snake", "Snake", false),
            ConfigPMODBool("ZigZag", "ZigZag", "ZigZag", false),
            ConfigExit("Back"),
        },
    },
    {
        Name = "Alternate",
        Options = {
            ConfigPMODBool("Mirror", "Mirror", "Mirror", false),
            ConfigPMODBool("SuperShuffle", "SuperShuffle", "SuperShuffle", false),
            ConfigPMODBool("Backwards", "Backwards", "Backwards", false),
            ConfigAction("Reset", function(pn) ResetPMODAlternate(pn) end),
            ConfigExit("Back"),
        },
    },
    {
        Name = "Judge",
        Options = {
            ConfigCustomChoicesCompat("JudgeDifficulty", "normal", { "normal", "hard", "veryhard", "extra", "ultra" },
                function(pn) return GetPMODJudgeDifficulty(pn) end,
                function(pn, newvalue) SetPMODJudgeDifficulty(pn, newvalue) end
            ),
            ConfigBool(PLAYERCONFIG, "ReverseJudgment", false),
            ConfigAction("Reset", function(pn) ResetPMODJudge(pn) end),
            ConfigExit("Back"),
        },
    },
    ConfigCustomChoicesCompat("Rush", 1.0, { 0.60, 0.70, 0.80, 0.90, 1.00, 1.10, 1.20, 1.30, 1.40, 1.50, 1.60, 1.70 },
        function() return GetMusicRateCompat() end,
        function(_, newvalue) SetMusicRateCompat(newvalue) end
    ),
    ConfigAction("Reset All", function(pn) 
        ResetPlayerSpeed(pn);
        ResetPlayerZoom(pn);
        ResetPlayerRotation(pn);
        ResetPlayerView(pn);
        ResetPlayerDisplay(pn);
        ResetPlayerTransform(pn);
        ResetPMODDisplay(pn);
        ResetPMODPath(pn);
        ResetPMODAlternate(pn);
        ResetPMODJudge(pn);
        ResetPMODGameplayUI(pn);
        ResetPMODVisualSkins(pn);
        SetMusicRateCompat(1.0);
        SetPreferredSortCompat("TITLE");
    end),

    ConfigExit("Exit"),
};

--//================================================================

function OptionsListController(self,param)
    local pn = param.Player;
    local stacksize = #option_stack[pn][#option_stack[pn]]
    param.Target = "OptionsList"

    if param.Input == "Prev" then
        if currentoption[pn] then
            PrepareSpeedOption(currentoption[pn], pn);
            MESSAGEMAN:Broadcast("ChangeProperty", { Player = pn, Input = param.Input, Option = currentoption[pn] });
            SaveOptionListState(pn);
            MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, Direction = "Prev", silent = true });
            return;
        else
            selection[pn] = selection[pn]-1;
            if selection[pn] < 1 then selection[pn] = stacksize end;
            if selection[pn] > stacksize then selection[pn] = 1 end;

            local topstack = option_stack[pn][#option_stack[pn]][selection[pn]]
            if topstack and topstack.Type and topstack.Type == "noteskin" then
                MESSAGEMAN:Broadcast("NoteskinChanged", { Player = pn, noteskin = GetNoteskins()[selection[pn]], silent = true });
            end;

            MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, Direction = "Prev", silent = false });
            return;
        end;
    end;
    
    if param.Input == "Next" then
        if currentoption[pn] then
            PrepareSpeedOption(currentoption[pn], pn);
            MESSAGEMAN:Broadcast("ChangeProperty", { Player = pn, Input = param.Input, Option = currentoption[pn] });
            SaveOptionListState(pn);
            MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, Direction = "Next", silent = true });
            return;
        else
            selection[pn] = selection[param.Player]+1;
            if selection[pn] > stacksize then selection[pn] = 1 end;
            if selection[pn] < 1 then selection[pn] = stacksize end;

            local topstack = option_stack[pn][#option_stack[pn]][selection[pn]];
            if topstack and topstack.Type and topstack.Type == "noteskin" then
                MESSAGEMAN:Broadcast("NoteskinChanged", { Player = pn, noteskin = GetNoteskins()[selection[pn]], silent = true });
            end;

            MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, Direction = "Next", silent = false });
            return;
        end;
    end;

    if param.Input == "Cancel" or param.Input == "Back" then

        if currentoption[pn] then
            selection[pn] = GetEntry(currentoption[pn], option_stack[pn][#option_stack[pn]]);
            currentoption[pn] = nil;
            MESSAGEMAN:Broadcast("Return", param);
            MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
            return;

        elseif #option_stack[pn] > 1 then
            selection[pn] = selection_stack[pn][#selection_stack[pn]];
            table.remove(selection_stack[pn], #selection_stack[pn]);
            table.remove(option_stack[pn], #option_stack[pn]);
            MESSAGEMAN:Broadcast("Return", param);
            MESSAGEMAN:Broadcast("NoteskinChanged", { Player = pn, noteskin = GetNoteskins()[GetNoteskinSelection(pn)], silent = true });
            MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
            return;

        else
            Global.oplist[param.Player] = false
            MESSAGEMAN:Broadcast("OptionsListClosed", param);
            return;
            
        end;
    end;

end;

function SelectOptionsList(param)
    local pn = param and param.Player or nil

    if currentoption[pn] ~= nil then
        currentoption[pn] = nil;
        MESSAGEMAN:Broadcast("OptionsListSelected", { Player = pn });
        MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
    else

        local topstack = option_stack[pn][#option_stack[pn]][selection[pn]];
        if topstack.Options and #topstack.Options > 0 then 
            table.insert(selection_stack[pn], selection[pn]);
            table.insert(option_stack[pn], topstack.Options);
            selection[pn] = 1;
            MESSAGEMAN:Broadcast("OptionsListSelected", { Player = pn });
            MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
            return;

        elseif topstack.Type then

            if topstack.Action then
                topstack.Action(pn);
                SaveOptionListState(pn);
                MESSAGEMAN:Broadcast("OptionsListSelected", { Player = pn });
                MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
                return;

            elseif topstack.Type == "bool" then
                MESSAGEMAN:Broadcast("ChangeProperty", { Player = pn, Input = "Next", Option = topstack, silent = true });
                SaveOptionListState(pn);
                MESSAGEMAN:Broadcast("OptionsListSelected", { Player = pn });
                MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
                return;

            elseif topstack.Type == "noteskin" then
                local n = SetNoteskinByIndex(pn, selection[pn]);
                SaveOptionListState(pn);
                selection[pn] = selection_stack[pn][#selection_stack[pn]];
                table.remove(selection_stack[pn], #selection_stack[pn]);
                table.remove(option_stack[pn], #option_stack[pn]);
                MESSAGEMAN:Broadcast("NoteskinChanged", { Player = pn, noteskin = n, silent = true });
                MESSAGEMAN:Broadcast("OptionsListSelected", { Player = pn });
                MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
                return;

            else
                currentoption[pn] = topstack;
                PrepareSpeedOption(currentoption[pn], pn);
                MESSAGEMAN:Broadcast("OptionsListSelected", { Player = pn });
                MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
                return;
            end
        else

            if #option_stack[pn] > 1 then
                selection[pn] = selection_stack[pn][#selection_stack[pn]];
                table.remove(selection_stack[pn], #selection_stack[pn]);
                table.remove(option_stack[pn], #option_stack[pn]);
                MESSAGEMAN:Broadcast("Return", param);
                MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
                return;
            else
                Global.oplist[param.Player] = false
                MESSAGEMAN:Broadcast("OptionsListClosed", param);
                return;
            end

        end;

    end
end;

--//================================================================

function ResetOptionStack(pn)
    option_stack[pn] = {}
    selection_stack[pn] = {}
    currentoption[pn] = nil;
    selection[pn] = 1;
    table.insert(option_stack[pn], option_tree);
    MESSAGEMAN:Broadcast("OptionsListChanged", { Player = pn, silent = true });
end;

--//================================================================

local t = Def.ActorFrame{};

local fontsize = 0.45;
local lineheight = 17;
local spacing = 186;
local sidespacing = 170;

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if SideJoined(pn) then

        ResetOptionStack(pn);
        local function apply_value_style(self, style)
            if style == "focus" then
                self:diffuse(1,0.85,0.4,1);
                self:strokecolor(BoostColor({1,0.85,0.4,1},0.4));
            elseif style == "disabled" then
                self:diffuse(0.6,0.6,0.6,0.5);
                self:strokecolor(0.2,0.2,0.2,0);
            else
                self:diffuse(1,1,1,1);
                self:strokecolor(0.25,0.25,0.25,0.8);
            end;
        end;

        local function restart_value_cycle(self, style, suppress_sync, force_reset)
            local target_style = style or "normal";
            if not force_reset and self.cycle_style == target_style and self.cycle_values and #self.cycle_values > 1 and self.cycle_index then
                apply_value_style(self, target_style);
                return;
            end;
            self.cycle_style = target_style;
            self:stoptweening();
            self:x(10);
            apply_value_style(self, self.cycle_style);
            self:diffusealpha(1);
            if self.cycle_values and #self.cycle_values > 1 then
                self:queuecommand("CycleValues");
                if not suppress_sync then
                    MESSAGEMAN:Broadcast("OptionsValueCycleReset", { Player = pn, Sender = self });
                end;
            end;
        end;

        local scroller_actor = Def.ActorFrame{
            -- name
            Def.BitmapText{
                Name = "Name";
                Font = Fonts.options["Main"];
                InitCommand=cmd(horizalign,pnAlign(OtherPlayer[pn]);zoom,fontsize;skewx,-0.12;textglowmode,"TextGlowMode_Inner";playcommand,"LoseFocus");
                GainFocusCommand=function(self)
                    self:stoptweening();
                    self:glowshift();
                    self:decelerate(0.15);
                    if self.is_exit then
                        self:diffuse(0.75,0.45,0.45,1);
                        self:strokecolor(0.65,0.08,0.08,1);
                    elseif self.is_reset_all then
                        self:diffuse(0.45,0.75,0.45,1);
                        self:strokecolor(0.08,0.55,0.08,1);
                    else
                        self:diffuse(BoostColor(PlayerColor(pn),1.2));
                        self:strokecolor(BoostColor(PlayerColor(pn),0.45));
                    end;
                    self:effectperiod(0.25);
                end;
                LoseFocusCommand=function(self)
                    self:stoptweening();
                    self:stopeffect();
                    self:decelerate(0.15);
                    if self.is_exit then
                        self:diffuse(0.95,0.25,0.25,1);
                        self:strokecolor(0.45,0.06,0.06,1);
                    elseif self.is_reset_all then
                        self:diffuse(0.25,0.9,0.25,1);
                        self:strokecolor(0.06,0.35,0.06,1);
                    else
                        self:diffuse(BoostColor(PlayerColor(pn),1.0));
                        self:strokecolor(BoostColor(PlayerColor(pn),0.4));
                    end;
                end;
                DisabledCommand=function(self)
                    self:stoptweening();
                    self:stopeffect();
                    self:decelerate(0.15);
                    if self.is_exit then
                        self:diffuse(0.55,0.18,0.18,0.5);
                        self:strokecolor(0.3,0.05,0.05,0);
                    elseif self.is_reset_all then
                        self:diffuse(0.2,0.55,0.2,0.5);
                        self:strokecolor(0.05,0.25,0.05,0);
                    else
                        self:diffuse(BoostColor(PlayerColor(pn,0.5),1.0));
                        self:strokecolor(BoostColor(PlayerColor(pn,0),0));
                    end;
                end;
                OptionsListClosedMessageCommand=function(self,param) if param and param.Player == pn then self:stopeffect() end; end;
            },
            -- value
            Def.BitmapText{
                Name = "Value";
                Font = Fonts.options["Main"];
                InitCommand=cmd(x,10*-pnSide(pn);horizalign,pnAlign(pn);zoom,fontsize*0.95;playcommand,"LoseFocus");
                GainFocusCommand=function(self)
                    restart_value_cycle(self, "focus", false, true);
                end;
                LoseFocusCommand=function(self)
                    restart_value_cycle(self, "normal", true, true);
                end;
                DisabledCommand=function(self)
                    restart_value_cycle(self, "disabled", true, true);
                end;
                OptionsListClosedMessageCommand=function(self,param) if param and param.Player == pn then self:stopeffect() end; end;
                OptionsValueCycleResetMessageCommand=function(self, param)
                    if param and param.Player == pn and param.Sender ~= self and self.cycle_values and #self.cycle_values > 1 then
                        restart_value_cycle(self, self.cycle_style or "normal", true, true);
                    end;
                end;
                CycleValuesCommand=function(self)
                    local values = self.cycle_values or {};
                    local index = self.cycle_index or 1;
                    self:stoptweening();
                    self:x(10);
                    if #values <= 1 then return end;
                    self:sleep(1.0);
                    self:linear(0.18);
                    self:diffusealpha(0);
                    self:queuecommand("AdvanceCycle");
                end;
                AdvanceCycleCommand=function(self)
                    local values = self.cycle_values or {};
                    local index = self.cycle_index or 1;
                    if #values <= 1 then return end;
                    self.cycle_index = (index % #values) + 1;
                    self:settext(tostring(values[self.cycle_index] or ""));
                    apply_value_style(self, self.cycle_style or "normal");
                    self:x(20);
                    self:diffusealpha(0);
                    self:linear(0.18);
                    self:x(10);
                    self:diffusealpha(1);
                    self:queuecommand("CycleValues");
                end;
            },  
        }

        
        local scroller = setmetatable({disable_wrapping = true}, item_scroller_mt)
        local scroller_item = OptionScrollerItem(lineheight,scroller_actor);
        local base_set = scroller_item.__index.set;
        scroller_item.__index.set = function(self, info)
            base_set(self, info);
            local is_exit = info and info.Name == "Exit";
            local is_reset_all = info and info.Name == "Reset All";
            local name_actor = self.container:GetChild("Name");
            local value_actor = self.container:GetChild("Value");
            if name_actor then
                name_actor.is_exit = is_exit;
                name_actor.is_reset_all = is_reset_all;
            end;
            if value_actor then
                value_actor.is_exit = is_exit;
                value_actor.is_reset_all = is_reset_all;
            end;
            if is_exit then
                if name_actor then name_actor:playcommand("LoseFocus") end;
                if value_actor then value_actor:playcommand("LoseFocus") end;
            elseif is_reset_all then
                if name_actor then name_actor:playcommand("LoseFocus") end;
                if value_actor then value_actor:playcommand("LoseFocus") end;
            end;
        end;
        scroller_item.__index.transform = function(self, item_index, num_items, is_focus)
            self.container:stoptweening();
            self.container:x(item_index * (1+(1/3)) * pnSide(pn));
            self.container:y(item_index * self.spacing);
            self.prev_index = item_index;
        end;


        t[#t+1] = Def.ActorFrame{
            InitCommand=cmd(diffusealpha,0);
            OptionsListOpenedMessageCommand=function(self,param) if param.Player == pn then self:stoptweening():decelerate(0.4):diffusealpha(1); ResetOptionStack(pn); end; end;
            OptionsListClosedMessageCommand=function(self,param) if param.Player == pn then self:stoptweening():decelerate(0.3):diffusealpha(0); end; end;
            OptionsListSelectedMessageCommand=function(self,param) self:playcommand("Refresh", param) end;
            OptionsListChangedMessageCommand=function(self,param) self:playcommand("Refresh", param) end;
            ReturnMessageCommand=function(self,param) self:playcommand("Refresh", param) end;
            RefreshCommand=function(self,param)
                if param and param.Player == pn then
                    local pn = param.Player;
                    scroller:set_info_set(GetCurrentStackInfo(option_stack[pn], pn), selection[pn]);
                    ScrollerFocus(scroller, selection[pn], currentoption[pn]);
                end;
            end;


            -- QUADS BG
            Def.ActorFrame{

                Def.Quad{
                    InitCommand=cmd(Center;skewx,-0.075;zoomto,_screen.h*(16/9)*-pnSide(pn)*0.45,_screen.h;halign,1.2;
                        diffuse,BoostColor(Global.bgcolor,0.5);diffusebottomedge,BoostColor(AlphaColor(Global.bgcolor,0),0.5);cropbottom,1/3;faderight,0.75);
                },
                Def.Quad{
                    InitCommand=cmd(Center;skewx,-0.075;zoomto,_screen.h*(16/9)*-pnSide(pn)*0.45,_screen.h;halign,1.2;
                        diffuse,BoostColor(PlayerColor(pn,1),0.5);diffusebottomedge,PlayerColor(pn,0);cropbottom,1/3;faderight,0.75);
                },
                LoadActor(THEME:GetPathG("","_pattern"))..{
                    InitCommand=cmd(Center;skewx,-0.075;zoomto,_screen.h*(16/9)*-pnSide(pn)*0.45,_screen.h;halign,1.2;
                        diffuse,BoostColor(PlayerColor(pn,0.2),0.5);diffusebottomedge,PlayerColor(pn,0);cropbottom,1/3;
                            customtexturerect,0,0,(_screen.h*(16/9)) / 384 * 2 *0.45,_screen.h / 384 * 2;texcoordvelocity,-0.125,-0.075;faderight,0.75;blend,Blend.Add);
                },
            },

            Def.Quad{
                InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-140;zoomto,_screen.w * 0.5 * pnSide(pn),1;horizalign,left;fadeleft,0.75;cropleft,0.15;diffuse,PlayerColor(pn));
            },

            -- TEXT
            Def.ActorFrame{
                InitCommand=cmd(x,SCREEN_CENTER_X + (pnSide(pn)*(spacing+32));y,SCREEN_CENTER_Y-140);
                OptionsListOpenedMessageCommand=function(self,param) if param.Player == pn then self:stoptweening():decelerate(0.4):x(SCREEN_CENTER_X + (pnSide(pn)*(spacing-8))); end; end;
                OptionsListClosedMessageCommand=function(self,param) if param.Player == pn then self:stoptweening():decelerate(0.3):x(SCREEN_CENTER_X + (pnSide(pn)*(spacing+8))); end; end;

                -- title
                Def.BitmapText{
                    Font = "regen strong";
                    Text = string.upper("Player  Options");
                    InitCommand=cmd(x,4*-pnSide(pn);zoomy,0.31;zoomx,0.3075;horizalign,pnAlign(OtherPlayer[pn]);strokecolor,BoostColor(PlayerColor(pn,0.9),1/3);diffusealpha,0);
                    OptionsListOpenedMessageCommand=function(self,param)
                        if param and param.Player == pn then
                            self:stoptweening();
                            self:decelerate(0.2);
                            self:diffusealpha(0.75);
                        end;
                    end;
                    OptionsListClosedMessageCommand=function(self,param)
                        if param and param.Player == pn then
                            self:stoptweening();
                            self:accelerate(0.3);
                            self:diffusealpha(0);
                        end;
                    end;
                },

                -- main scroller
                scroller:create_actors("OptionsList", maxitems, scroller_item, 0, 0)..{
                    InitCommand=cmd(y,4;x,16*pnSide(pn);diffusealpha,0);
                    OptionsListOpenedMessageCommand=function(self,param)
                        if param and param.Player == pn then
                            self:stoptweening();
                            self:decelerate(0.3);
                            self:diffusealpha(1);
                            self:x(0);
                        end;
                    end;

                    OptionsListClosedMessageCommand=function(self,param)
                        if param and param.Player == pn then
                            self:stoptweening();
                            self:accelerate(0.2);
                            self:diffusealpha(0);
                            self:x(16*pnSide(pn));
                        end;
                    end;

                },
            }

        }

    end;
end;

return t;
