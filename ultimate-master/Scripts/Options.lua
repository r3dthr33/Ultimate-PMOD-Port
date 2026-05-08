function DefaultOptionScrollerActor(fontsize,sidespacing)
    local function apply_value_style(self, style)
        if style == "focus" then
            self:diffuse(HighlightColor());
            self:strokecolor(BoostColor(HighlightColor(),0.2));
        elseif style == "disabled" then
            self:diffuse(0.6,0.6,0.6,0.5);
            self:strokecolor(0.2,0.2,0.2,0.8);
        else
            self:diffuse(1,1,1,1);
            self:strokecolor(0.2,0.2,0.2,0.8);
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
        apply_value_style(self, self.cycle_style);
        self:diffusealpha(1);
        if self.cycle_values and #self.cycle_values > 1 then
            self:queuecommand("CycleValues");
            if not suppress_sync then
                MESSAGEMAN:Broadcast("OptionsValueCycleReset", { Sender = self });
            end;
        end;
    end;

    return Def.ActorFrame{
        -- name
        Def.BitmapText{
            Name = "Name";
            Font = Fonts.options["Main"];
            InitCommand=cmd(horizalign,left;x,-sidespacing;zoom,fontsize;strokecolor,0.2,0.2,0.2,1);
            GainFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2));
            LoseFocusCommand=cmd(stoptweening;decelerate,0.15;diffuse,1,1,1,1;strokecolor,0.2,0.2,0.2,0.8);
            DisabledCommand=cmd(stoptweening;decelerate,0.15;diffuse,0.6,0.6,0.6,0.5;strokecolor,0.2,0.2,0.2,0.8);
        },
        -- value
        Def.BitmapText{
            Name = "Value";
            Font = Fonts.options["Main"];
            InitCommand=cmd(horizalign,right;x,sidespacing;zoom,fontsize;strokecolor,0.2,0.2,0.2,1);
            GainFocusCommand=function(self)
                restart_value_cycle(self, "focus", false, true);
            end;
            LoseFocusCommand=function(self)
                restart_value_cycle(self, "normal", true, true);
            end;
            DisabledCommand=function(self)
                restart_value_cycle(self, "disabled", true, true);
            end;
            OptionsValueCycleResetMessageCommand=function(self, param)
                if param and param.Sender ~= self and self.cycle_values and #self.cycle_values > 1 then
                    restart_value_cycle(self, self.cycle_style or "normal", true, true);
                end;
            end;
            CycleValuesCommand=function(self)
                local values = self.cycle_values or {};
                local index = self.cycle_index or 1;
                self:stoptweening();
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
                if self.cycle_cache_key then
                    value_cycle_state[self.cycle_cache_key] = {
                        signature = self.cycle_signature,
                        index = self.cycle_index,
                    };
                end;
                self:settext(tostring(values[self.cycle_index] or ""));
                apply_value_style(self, self.cycle_style or "normal");
                self:linear(0.18);
                self:diffusealpha(1);
                self:queuecommand("CycleValues");
            end;
        },  
    }
end;

local value_cycle_state = {};

function OptionScrollerItem(spacing, actor)
    local spacing = spacing or 16;
    local move_time = 0.15;
    local item_mt = {
        __index = {
            prev_index = -1;
            create_actors = function(self, params)
                self.name = params.name;
                self.spacing = spacing;
                self.move_time = move_time;
                if actor then 
                    return actor..{
                        InitCommand=function(subself)
                            self.container = subself;
                        end;
                    } 
                else 
                    return DefaultOptionScrollerActor(self,0.5,64)..{
                        InitCommand=function(subself)
                            self.container = subself;
                        end;
                    } 
                end;
            end;

            transform = function(self, item_index, num_items, is_focus)
                self.container:stoptweening();
                self.container:y(item_index * self.spacing);
                self.prev_index = item_index;
            end;

            set = function(self, info)
                if info and info.Name then
                    self.container:GetChild("Name"):settext(tostring(info.Name));
                else
                    self.container:GetChild("Name"):settext("");
                end;
                local value_actor = self.container:GetChild("Value");
                local function reapply_value_state()
                    if value_actor.cycle_style == "focus" then
                        value_actor:playcommand("GainFocus");
                    elseif value_actor.cycle_style == "disabled" then
                        value_actor:playcommand("Disabled");
                    else
                        value_actor:playcommand("LoseFocus");
                    end;
                end;
                if info and info.ValueCycle and #info.ValueCycle > 0 then
                    local signature = table.concat(info.ValueCycle, "\30");
                    local cycle_key = info.CycleKey or info.Name or signature;
                    local cached_state = value_cycle_state[cycle_key];
                    local start_index = 1;
                    if cached_state and cached_state.signature == signature then
                        start_index = cached_state.index or 1;
                    end;
                    if value_actor.cycle_signature ~= signature then
                        value_actor:stoptweening();
                        value_actor.cycle_cache_key = cycle_key;
                        value_actor.cycle_signature = signature;
                        value_actor.cycle_values = info.ValueCycle;
                        value_actor.cycle_index = start_index;
                        value_actor:settext(tostring(info.ValueCycle[start_index] or info.ValueCycle[1] or ""));
                        value_actor:diffusealpha(1);
                        value_cycle_state[cycle_key] = {
                            signature = signature,
                            index = start_index,
                        };
                        if #info.ValueCycle > 1 then
                            value_actor:queuecommand("CycleValues");
                        end;
                    else
                        local current_values = value_actor.cycle_values or info.ValueCycle;
                        local current_index = value_actor.cycle_index or 1;
                        value_actor.cycle_cache_key = cycle_key;
                        value_actor:settext(tostring(current_values[current_index] or info.ValueCycle[1] or ""));
                    end;
                elseif info and info.Value then
                    value_actor:stoptweening();
                    value_actor.cycle_cache_key = nil;
                    value_actor.cycle_signature = nil;
                    value_actor.cycle_values = nil;
                    value_actor.cycle_index = nil;
                    value_actor:settext(tostring(info.Value));
                    value_actor:diffusealpha(1);
                else
                    value_actor:stoptweening();
                    value_actor.cycle_cache_key = nil;
                    value_actor.cycle_signature = nil;
                    value_actor.cycle_values = nil;
                    value_actor.cycle_index = nil;
                    value_actor:settext("");
                    value_actor:diffusealpha(1);
                end;
                reapply_value_state();
            end;
        }
    }
    return item_mt;
end;

--//================================================================

local speed_effect_fields = {
    expand = "SpeedExpand",
    randomvel = "SpeedRandomVel",
    accel = "SpeedAccel",
    decel = "SpeedDecel",
};

local speed_effect_labels = {
    expand = "EW",
    randomvel = "RV",
    accel = "AC",
    decel = "DC",
};

local function IsSummaryPlayer(pn)
    return pn == PLAYER_1 or pn == PLAYER_2;
end;

local function ResolveSummaryPlayer(pn)
    if IsSummaryPlayer(pn) then return pn end;

    if Global and IsSummaryPlayer(Global.master) then
        return Global.master;
    end;

    if GAMESTATE and type(GAMESTATE.GetMasterPlayerNumber) == "function" then
        local master = GAMESTATE:GetMasterPlayerNumber();
        if IsSummaryPlayer(master) then return master end;
    end;

    if GAMESTATE and type(GAMESTATE.GetHumanPlayers) == "function" then
        for player in ivalues(GAMESTATE:GetHumanPlayers()) do
            if IsSummaryPlayer(player) then return player end;
        end;
    end;

    return PLAYER_1;
end;

local function GetSpeedEffectToggleCompat(pn, effect)
    pn = ResolveSummaryPlayer(pn);

    if type(GetPMODSpeedEffectToggle) == "function" then
        return GetPMODSpeedEffectToggle(pn, effect);
    end;

    local pconf = PLAYERCONFIG and PLAYERCONFIG:get_data(pn);
    local field = speed_effect_fields[effect];
    if not pconf or not field then return false end;

    if pconf[field] ~= nil then
        return pconf[field] and true or false;
    end;

    return (pconf.SpeedEffect or "none") == effect;
end;

local function GetPreferredOptionValueCompat(pn, method, default)
    pn = ResolveSummaryPlayer(pn);

    local pstate = GAMESTATE and GAMESTATE:GetPlayerState(pn);
    if not pstate then return default end;

    local poptions = nil;
    if type(GetPreferredPlayerOptionsCompat) == "function" then
        poptions = GetPreferredPlayerOptionsCompat(pstate);
    elseif type(pstate.GetPlayerOptions) == "function" then
        poptions = pstate:GetPlayerOptions("ModsLevel_Preferred");
    end;

    if poptions and type(poptions[method]) == "function" then
        local value = poptions[method](poptions);
        if value ~= nil then
            return value;
        end;
    end;

    return default;
end;

local function IsEnabledBoolLike(value)
    if type(value) == "boolean" then return value end;
    if type(value) == "number" then return math.abs(value) > 0.0001 end;
    if type(value) == "string" then
        local lowered = string.lower(value);
        return lowered == "true" or lowered == "on" or lowered == "1";
    end;
    return false;
end;

local function BuildSpeedMenuSummary(pn)
    pn = ResolveSummaryPlayer(pn);

    local nconf = NOTESCONFIG and NOTESCONFIG:get_data(pn);
    if not nconf then return "" end;

    local speed_type = nconf.speed_type or "multiple";
    if type(NormalizeSpeedTypeForPMOD) == "function" then
        speed_type = NormalizeSpeedTypeForPMOD(speed_type);
    end;

    local speed_mod = nconf.speed_mod or 200;
    local parts = {};

    if type(FormatSpeed) == "function" then
        parts[#parts+1] = FormatSpeed(speed_mod, speed_type);
    else
        parts[#parts+1] = tostring(speed_mod);
    end;

    for _, effect in ipairs{ "expand", "randomvel", "accel", "decel" } do
        if GetSpeedEffectToggleCompat(pn, effect) then
            parts[#parts+1] = speed_effect_labels[effect];
        end;
    end;

    return parts;
end;

local function BuildDisplayMenuSummary(pn)
    pn = ResolveSummaryPlayer(pn);

    local parts = {};
    local nconf = NOTESCONFIG and NOTESCONFIG:get_data(pn);
    local pconf = PLAYERCONFIG and PLAYERCONFIG:get_data(pn);

    local bga = type(GetPMODBGAChoice) == "function" and GetPMODBGAChoice(pn) or "normal";
    if bga ~= "normal" then
        local bga_labels = {
            off = "BGA Off",
            dark = "BGA Dark",
            partial = "BGA Partial",
        };
        parts[#parts+1] = bga_labels[bga] or tostring(bga);
    end;

    local display_flags = {
        { method = "Vanish", label = "V" },
        { method = "Appear", label = "AP" },
        { method = "Nonstep", label = "NS" },
        { method = "Dark", label = "DARK" },
        { method = "RandomNote", label = "RN" },
        { method = "Flash", label = "FL" },
    };

    for _, entry in ipairs(display_flags) do
        local value = GetPreferredOptionValueCompat(pn, entry.method, 0);
        if IsEnabledBoolLike(value) then
            parts[#parts+1] = entry.label;
        end;
    end;

    local mini = GetPreferredOptionValueCompat(pn, "Mini", 0);
    if type(mini) == "number" and mini > 0 then
        parts[#parts+1] = "MN";
    end;

    if nconf then
        if nconf.hidden then parts[#parts+1] = "HD" end;
        if nconf.sudden then parts[#parts+1] = "SD" end;
    end;

    if pconf then
        if tonumber(pconf.ScreenFilter or 0) and tonumber(pconf.ScreenFilter or 0) > 0 then
            parts[#parts+1] = "SF" .. tostring(pconf.ScreenFilter);
        end;
        if pconf.ShowEarlyLate then parts[#parts+1] = "EL" end;
        if pconf.ShowJudgmentList then parts[#parts+1] = "JL" end;
        if pconf.ShowOffsetMeter then parts[#parts+1] = "OM" end;
    end;

    return parts;
end;

local function BuildPathMenuSummary(pn)
    pn = ResolveSummaryPlayer(pn);

    local parts = {};

    local path_flags = {
        { method = "Xmode", label = "X" },
        { method = "NXMode", label = "NX" },
        { method = "UnderAttack", label = "UA" },
        { method = "Drop", label = "DR" },
        { method = "Snake", label = "SN" },
        { method = "ZigZag", label = "ZZ" },
    };

    for _, entry in ipairs(path_flags) do
        local value = GetPreferredOptionValueCompat(pn, entry.method, 0);
        if IsEnabledBoolLike(value) then
            parts[#parts+1] = entry.label;
        end;
    end;

    local rise = type(GetPMODRiseMode) == "function" and GetPMODRiseMode(pn) or "off";
    if rise == "sink" then
        parts[#parts+1] = "SI";
    elseif rise == "rise" then
        parts[#parts+1] = "RI";
    end;

    return parts;
end;

local function BuildAlternateMenuSummary(pn)
    pn = ResolveSummaryPlayer(pn);

    local parts = {};
    local alternate_flags = {
        { method = "Mirror", label = "M" },
        { method = "SuperShuffle", label = "SS" },
        { method = "Backwards", label = "BW" },
    };

    for _, entry in ipairs(alternate_flags) do
        local value = GetPreferredOptionValueCompat(pn, entry.method, false);
        if IsEnabledBoolLike(value) then
            parts[#parts+1] = entry.label;
        end;
    end;

    return parts;
end;

local function BuildJudgeMenuSummary(pn)
    pn = ResolveSummaryPlayer(pn);

    local difficulty = type(GetPMODJudgeDifficulty) == "function" and GetPMODJudgeDifficulty(pn) or "normal";
    local difficulty_labels = {
        normal = "Normal",
        hard = "Hard",
        veryhard = "Very Hard",
        extra = "Extra Hard",
        ultra = "Ultra Hard",
    };

    local parts = {};

    if difficulty ~= "normal" then
        parts[#parts+1] = difficulty_labels[difficulty] or tostring(difficulty);
    end;

    local pconf = PLAYERCONFIG and PLAYERCONFIG:get_data(pn);
    if pconf and pconf.ReverseJudgment then
        parts[#parts+1] = "JR";
    end;

    return parts;
end;

--//================================================================

function GetCurrentStackInfo(stack, pn)
    if not stack then return {} end;
    pn = ResolveSummaryPlayer(pn);

    if pn == nil then
        if Global and Global.master then
            pn = Global.master;
        elseif GAMESTATE and type(GAMESTATE.GetMasterPlayerNumber) == "function" then
            pn = GAMESTATE:GetMasterPlayerNumber();
        end;
    end;

    if pn and stack[pn] then
        stack = stack[pn];
    end;

    if not stack or #stack == 0 then return {} end;

    local infotable = {};
    local cur = stack[#stack];
    if not cur then return infotable end;

    for i=1,#cur do
        local info = {}
        info.Name = cur[i].Name;
        local cycle_values = nil;
        if cur[i].Type ~= "noteskin" then
            if cur[i].Type == "action" then
                info.Value = "";
            elseif cur[i].Options then
                if info.Name == "Speed" then
                    cycle_values = BuildSpeedMenuSummary(pn);
                    info.Value = cycle_values[1] or "";
                elseif info.Name == "Display" then
                    cycle_values = BuildDisplayMenuSummary(pn);
                    info.Value = cycle_values[1] or "";
                elseif info.Name == "Path" then
                    cycle_values = BuildPathMenuSummary(pn);
                    info.Value = cycle_values[1] or "";
                elseif info.Name == "Alternate" then
                    cycle_values = BuildAlternateMenuSummary(pn);
                    info.Value = cycle_values[1] or "";
                elseif info.Name == "Judge" then
                    cycle_values = BuildJudgeMenuSummary(pn);
                    info.Value = cycle_values[1] or "";
                else
                    info.Value = "";
                end;
            elseif cur[i].Type then
                local optiondata = { 
                    Option = cur[i],
                    Player = pn,
                }
                info.Value = GetConfig(optiondata);
            else
                info.Value = "";
            end;
        end;

        info = FormatOptionConfigs(info.Name, info.Value, pn);
        info.ValueCycle = cycle_values;
        table.insert(infotable, info);
    end
    return infotable;
end

--//================================================================

function ScrollerFocus(s, index, currentoption)
    local function play_focus_state(container, command)
        if not container then return end;
        container:playcommand(command);
        if type(container.GetChild) == "function" then
            local name_actor = container:GetChild("Name");
            local value_actor = container:GetChild("Value");
            if name_actor then name_actor:playcommand(command) end;
            if value_actor then value_actor:playcommand(command) end;
        end;
    end;

    local focused = s:get_items_by_info_index(index)[1];
    for i=1,#s.items do
        if s.items[i] == focused then
            play_focus_state(s.items[i].container, "GainFocus");
        else
            play_focus_state(s.items[i].container, currentoption ~= nil and "Disabled" or "LoseFocus");
        end;
    end;
    return focused;
end;

--//================================================================
--[[
        param.Input = "Prev", "Next"
        param.Player = PLAYER_1, PLAYER_2
        param.Option = {
            Type = "pref", "config", "options"
            Field = field name
            Config = config file (if needed)
            Default = "baz", 0, etc
            Choices = { true, false, "foo", "bar", 5 }
            Range = { Min = 0, Max = 10, Step = 1 }
        };
]]--
--//================================================================

function ConfigRange(conf, field, default, min, max, step)
    return {
        Name = field,
        Type = "range",
        Field = field, 
        Config = conf, 
        Default = default, 
        Range = { Min = min, Max = max, Step = step } ,
    }
end;

function ConfigChoices(conf, field, default, choices)
    return { 
        Name = field,
        Type = "choices",
        Field = field, 
        Config = conf, 
        Default = default, 
        Choices = choices,
    }
end;

function ConfigBool(conf, field, default, choices)
    return { 
        Name = field,
        Type = "bool",
        Field = field, 
        Config = conf, 
        Default = default, 
        Choices = choices or { true, false },
    }
end;

function ConfigCustomRange(name, default, min, max, step, getter, setter)
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

function ConfigCustomChoices(name, default, choices, getter, setter)
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

function ConfigCustomBool(name, default, getter, setter, choices)
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

function ConfigNoteskin(name)
    return {
        Name = name,
        Field = name,
        Type = "noteskin",
    }
end;

function ConfigAction(label, func)
    return { 
        Name = label,
        Type = "action",
        Action = func,
    }
end;

function ConfigExit(label)
    return { 
        Name = label
    }
end;

function GetConfig(param)
    if param and param.Option and type(param.Option.Get) == "function" then
        return param.Option.Get(param and param.Player or nil, param.Option);
    end;

    local pn = param and param.Player or nil;
    local conf = param.Option.Config;
    local field = param.Option.Field;
    local ret = get_element_by_path(conf:get_data(pn), field)
    return ((ret ~= nil or ret == 0) and ret) or false
end;

local function ChangeConfig(param)
    local pn = param.Player or nil;
    local conf = param.Option.Config;
    local field = param.Option.Field;
    local default = param.Option.Default;
    local current;

    current = GetConfig(param);
    if type(current) == "number" then
        current = math.round(current * 100000)/100000
    end;

    if param.Option.Choices and #param.Option.Choices > 1 then
        local choices = param.Option.Choices;
        local entry = GetEntry(current,choices);
        if param.Input == "Prev" then entry = entry-1; end;
        if param.Input == "Next" then entry = entry+1; end;
        if entry < 1 then entry = #choices; end;
        if entry > #choices then entry = 1; end;
        newvalue = choices[entry];

    elseif param.Option.Range then
        local min = param.Option.Range.Min;
        local max = param.Option.Range.Max;
        local step = param.Option.Range.Step;
        if param.Input == "Prev" then newvalue = current - step; end;
        if param.Input == "Next" then 
            if current < step and min >= 0 then newvalue = step else newvalue = current + step; end;
        end;
        newvalue = clamp(newvalue, min, max);
        newvalue = math.round(newvalue * 100000)/100000
    else
        LuaError("Invalid option choices/range");
    end;

    if type(param.Option.Set) == "function" then
        param.Option.Set(pn, newvalue, param.Option);
        return;
    end;

    set_element_by_path(conf:get_data(pn), field, newvalue);
    conf:set_dirty(pn);
end;

--//================================================================

function PropertyActor()
    return Def.ActorFrame{
        ChangePropertyMessageCommand=function(self,param)
            if param and param.Input then
                ChangeConfig(param);
                MESSAGEMAN:Broadcast("PropertyChanged", param);
            end;
        end;
    };
end;
