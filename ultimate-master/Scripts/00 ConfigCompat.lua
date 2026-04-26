-- Compatibility layer for SM5.2 themes running on PMOD fallback.
-- Ultimate expects these helpers from the SM5.2 fallback lua config system.

local function compat_deep_copy(value)
    if type(DeepCopy) == "function" then
        return DeepCopy(value);
    end;
    if type(value) ~= "table" then
        return value;
    end;
    local copy = {};
    for k, v in pairs(value) do
        copy[compat_deep_copy(k)] = compat_deep_copy(v);
    end;
    return copy;
end;

local function compat_slot(slot, no_per_player)
    if no_per_player or not slot then
        return "ProfileSlot_Invalid";
    end;
    if slot == PLAYER_1 then
        return "ProfileSlot_Player1";
    elseif slot == PLAYER_2 then
        return "ProfileSlot_Player2";
    end;
    return slot;
end;

if type(get_element_by_path) ~= "function" then
    function get_element_by_path(container, path)
        local current = container;
        for part in string.gmatch(path, "[^%.]+") do
            if type(current) ~= "table" then return current; end;
            current = current[part];
        end;
        return current;
    end;
end;

if type(set_element_by_path) ~= "function" then
    function set_element_by_path(container, path, value)
        local current = container;
        local parts = {};
        for part in string.gmatch(path, "[^%.]+") do
            parts[#parts+1] = part;
        end;
        for i = 1, #parts - 1 do
            if not current[parts[i]] and value ~= nil then
                current[parts[i]] = {};
            end;
            current = current[parts[i]];
            if type(current) ~= "table" then return; end;
        end;
        current[parts[#parts]] = value;
    end;
end;

if not lua_config_registry then
    lua_config_registry = {};
end;

if type(create_lua_config) ~= "function" then
    function create_lua_config(params)
        assert(type(params) == "table", "create_lua_config requires a params table.");
        assert(type(params.default) == "table", "create_lua_config requires a default table.");

        local config = {
            name = params.name or params.file,
            file = params.file,
            default = params.default,
            data_set = {},
            dirty_table = {},
            no_per_player = params.no_per_player,
            is_lua_config = true,
        };

        function config:sanitize_profile_slot(slot)
            return compat_slot(slot, self.no_per_player);
        end;

        function config:get_default()
            return self.default;
        end;

        function config:get_filename(slot)
            slot = self:sanitize_profile_slot(slot);
            local dir = "Save/";
            if slot ~= "ProfileSlot_Invalid" and PROFILEMAN then
                local profile_dir = PROFILEMAN:GetProfileDir(slot);
                if profile_dir and profile_dir ~= "" then
                    dir = profile_dir;
                end;
            end;
            return dir .. THEME:GetCurThemeName() .. "_config/" .. self.file;
        end;

        function config:load(slot)
            slot = self:sanitize_profile_slot(slot);
            local loaded;
            local filename = self:get_filename(slot);
            if lua and type(lua.load_config_lua) == "function" and FILEMAN and FILEMAN:DoesFileExist(filename) then
                loaded = lua.load_config_lua(filename);
            end;
            if type(loaded) == "table" then
                self.data_set[slot] = loaded;
            else
                self.data_set[slot] = compat_deep_copy(self.default);
            end;
            return self.data_set[slot];
        end;

        function config:get_data(slot)
            slot = self:sanitize_profile_slot(slot);
            if not self.data_set[slot] then
                self:load(slot);
            end;
            return self.data_set[slot];
        end;

        function config:set_data(slot, data)
            slot = self:sanitize_profile_slot(slot);
            self.data_set[slot] = data;
            self:set_dirty(slot);
        end;

        function config:set_dirty(slot)
            slot = self:sanitize_profile_slot(slot);
            self.dirty_table[slot] = true;
        end;

        function config:check_dirty(slot)
            slot = self:sanitize_profile_slot(slot);
            return self.dirty_table[slot];
        end;

        function config:save(slot)
            slot = self:sanitize_profile_slot(slot);
            if not self:check_dirty(slot) then return end;
            if lua and type(lua.save_lua_table) == "function" then
                lua.save_lua_table(self:get_filename(slot), self:get_data(slot));
            end;
            self.dirty_table[slot] = nil;
        end;

        function config:save_all()
            for slot in pairs(self.data_set) do
                self:save(slot);
            end;
        end;

        function config:clear_all_slots()
            self.data_set = {};
            self.dirty_table = {};
        end;

        lua_config_registry[config.name] = config;
        return config;
    end;
end;

if type(add_profile_load_callback) ~= "function" then
    function add_profile_load_callback() end;
end;

if type(add_profile_save_callback) ~= "function" then
    function add_profile_save_callback() end;
end;

if type(add_gamestate_reset_callback) ~= "function" then
    function add_gamestate_reset_callback() end;
end;

if type(standard_lua_config_profile_load) ~= "function" then
    function standard_lua_config_profile_load(config)
        return function(profile, dir, pn)
            if pn then config:load(pn); end;
        end;
    end;
end;

if type(standard_lua_config_profile_save) ~= "function" then
    function standard_lua_config_profile_save(config)
        return function(profile, dir, pn)
            if pn then config:save(pn); end;
        end;
    end;
end;

if type(add_standard_lua_config_save_load_hooks) ~= "function" then
    function add_standard_lua_config_save_load_hooks(config)
        add_profile_load_callback(standard_lua_config_profile_load(config));
        add_profile_save_callback(standard_lua_config_profile_save(config));
    end;
end;

if type(GetMachineName) ~= "function" then
    function GetMachineName()
        local name = PREFSMAN:GetPreference("MachineName");
        if name and name ~= "" then
            return name;
        end;
        return "UNKNOWN";
    end;
end;

local notefield_default_prefs = {
    speed_step = 10,
    speed_mod = 250,
    speed_type = "maximum",
    hidden = false,
    hidden_offset = 120,
    sudden = false,
    sudden_offset = 190,
    fade_dist = 40,
    fade_distance = 40,
    glow_during_fade = true,
    fov = 45,
    reverse = 1,
    rotation_x = 0,
    rotation_y = 0,
    rotation_z = 0,
    vanish_x = 0,
    vanish_y = 0,
    yoffset = 130,
    zoom = 1,
    zoom_x = 1,
    zoom_y = 1,
    zoom_z = 1,
};

if not notefield_prefs_config then
    notefield_prefs_config = create_lua_config{
        name = "notefield_prefs",
        file = "notefield_prefs.lua",
        default = notefield_default_prefs,
    };
    add_standard_lua_config_save_load_hooks(notefield_prefs_config);
end;

if type(set_notefield_default_yoffset) ~= "function" then
    function set_notefield_default_yoffset(yoff)
        notefield_default_prefs.yoffset = yoff;
        if notefield_prefs_config and notefield_prefs_config.default then
            notefield_prefs_config.default.yoffset = yoff;
        end;
    end;
end;
