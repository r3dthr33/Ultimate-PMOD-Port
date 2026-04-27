-- PMOD compatibility for SM5.2-style lua config objects used by Ultimate.
-- PMOD's own theme stores most options on profiles/preferences directly, so it
-- does not provide create_lua_config or notefield_prefs_config.

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
			if type(current[parts[i]]) ~= "table" then
				current[parts[i]] = {};
			end;
			current = current[parts[i]];
		end;
		current[parts[#parts]] = value;
	end;
end;

lua_config_registry = lua_config_registry or {};

if type(create_lua_config) ~= "function" then
	function create_lua_config(params)
		assert(type(params) == "table", "create_lua_config requires params.");
		assert(type(params.default) == "table", "create_lua_config requires a default table.");

		local config = {
			name = params.name or params.file,
			file = params.file,
			default = params.default,
			no_per_player = params.no_per_player,
			data_set = {},
			dirty_table = {},
			is_lua_config = true,
		};

		function config:sanitize_profile_slot(slot)
			return compat_slot(slot, self.no_per_player);
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
			local filename = self:get_filename(slot);
			local loaded = nil;
			if lua and type(lua.load_config_lua) == "function" and FILEMAN and FILEMAN:DoesFileExist(filename) then
				loaded = lua.load_config_lua(filename);
			end;
			self.data_set[slot] = type(loaded) == "table" and loaded or compat_deep_copy(self.default);
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
			if not self:check_dirty(slot) then return; end;
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

if type(add_standard_lua_config_save_load_hooks) ~= "function" then
	function add_standard_lua_config_save_load_hooks(config)
		add_profile_load_callback(function(profile, dir, pn)
			if pn then config:load(pn); end;
		end);
		add_profile_save_callback(function(profile, dir, pn)
			if pn then config:save(pn); end;
		end);
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

if type(reset_needs_defective_field_for_all_players) ~= "function" then
	function reset_needs_defective_field_for_all_players()
		for pn in ivalues({PLAYER_1, PLAYER_2}) do
			local pstate = GAMESTATE:GetPlayerState(pn);
			if pstate and type(pstate.set_needs_defective_field) == "function" then
				pstate:set_needs_defective_field(false);
			end;
		end;
	end;
end;
