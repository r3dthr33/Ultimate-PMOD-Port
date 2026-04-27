
local curTime = -1;
local bpm = 60;
local curskin = {
    [PLAYER_1] = "",
    [PLAYER_2] = "",
}

local columns = {
    {receptor = "DownLeft Ready Receptor", tap = "DownLeft Tap Note", x = -104, rotationy = 0},
    {receptor = "UpLeft Ready Receptor", tap = "UpLeft Tap Note", x = -52, rotationy = 0},
    {receptor = "Center Ready Receptor", tap = "Center Tap Note", x = 0, rotationy = 0},
    {receptor = "UpRight Ready Receptor", tap = "UpRight Tap Note", x = 52, rotationy = 0, mirror = "UpLeft Tap Note", mirror_receptor = "UpLeft Ready Receptor"},
    {receptor = "DownRight Ready Receptor", tap = "DownRight Tap Note", x = 104, rotationy = 0, mirror = "DownLeft Tap Note", mirror_receptor = "DownLeft Ready Receptor"},
}

local preview_pattern = {
    {1,0,0,0,0},
    {0,0,1,0,0},
    {0,0,0,0,1},
    {0,1,0,1,0},
    {0,0,1,0,0},
    {1,0,0,0,1},
    {0,1,0,0,0},
    {0,0,0,1,0},
}

local function FindFileWithPattern(directory, pattern)
    if not directory or not pattern then return nil end;

    local files = FILEMAN:GetDirListing(directory, false, false);
    if not files then return nil end;

    local lower_pattern = string.lower(pattern);
    for _, file in ipairs(files) do
        if string.find(string.lower(file), lower_pattern, 1, true) then
            return directory .. file;
        end;
    end;

    return nil;
end;

local function NoteskinPath(skin, pattern)
    local skins = {
        skin,
        skin and string.upper(skin) or nil,
        skin and string.lower(skin) or nil,
        "PHOENIX",
        "phoenix",
        "default",
        "basic",
    }

    for _, candidate in ipairs(skins) do
        if candidate and candidate ~= "" then
            local path = FindFileWithPattern("NoteSkins/pump/" .. candidate .. "/", pattern);
            if path then return path end;
        end;
    end;

    return nil;
end;

local function LoadNoteskinSprite(sprite, skin, primary, fallback, mirror)
    local path = NoteskinPath(skin, primary) or NoteskinPath(skin, fallback);
    if path then
        sprite:Load(path);
        sprite:visible(true);
        sprite:rotationy(mirror and 180 or 0);
    else
        sprite:visible(false);
    end;
end;

local function GetColumnLayout(steps)
    local st = steps and PureType(steps) or "Single";
    if st == "Double" or st == "Routine" then
        return {
            {-234, columns[1]}, {-182, columns[2]}, {-130, columns[3]}, {-78, columns[4]}, {-26, columns[5]},
            {26, columns[1]}, {78, columns[2]}, {130, columns[3]}, {182, columns[4]}, {234, columns[5]},
        };
    end;

    return {
        {columns[1].x, columns[1]},
        {columns[2].x, columns[2]},
        {columns[3].x, columns[3]},
        {columns[4].x, columns[4]},
        {columns[5].x, columns[5]},
    };
end;

local function ApplyFieldPlacement(self, pn, steps, prefs)
    local st = steps and PureType(steps) or "Single";
    local width = (st == "Double" or st == "Routine") and 520 or 260;
    local zoom = prefs and prefs.zoom or 1;

    if (st == "Double" or st == "Routine") or GAMESTATE:GetNumSidesJoined() == 1 then
        self:xy(_screen.cx, _screen.cy);
    else
        self:xy(_screen.cx + ((width + 32) * 0.5 * pnSide(pn)), _screen.cy);
    end;

    self:zoom(zoom);
end;

local function UpdateTime(self, delta)
    curTime = GAMESTATE:GetCurMusicSeconds();
    MESSAGEMAN:Broadcast("UpdateNotefield");
end

local function CanShowNotefield()
    if Global.state == "SelectSteps" or Global.oplist[PLAYER_1] or Global.oplist[PLAYER_2] then return true end;
    return false;
end;

local t = Def.ActorFrame{
    InitCommand=function(self) self:SetUpdateFunction(UpdateTime); self:diffusealpha(0); end;
    OnCommand=cmd(playcommand,"Refresh");
    StateChangedMessageCommand=cmd(playcommand,"Refresh");
    OptionsListOpenedMessageCommand=cmd(playcommand,"Refresh");
    OptionsListClosedMessageCommand=cmd(playcommand,"Refresh");
    RefreshCommand=function(self)
        self:stoptweening();
        self:linear(0.15);
        if CanShowNotefield() then
            self:diffusealpha(1);
        else
            self:diffusealpha(0);
        end;
    end;
} 

local tex = Def.ActorFrameTexture{
    InitCommand= function(self)
        self:setsize(_screen.w, _screen.h)
        self:SetTextureName("notefield_overlay")
        self:EnableAlphaBuffer(true);
        self:EnablePreserveTexture(false)
        self:Create();
    end;
}

-- <Kyzentun> Luizsan: Yeah, it's touchy about the order.  I tried to make it less 
-- touchy in the notefield_targets branch, but good luck finding someone to build that.
for pn in ivalues({PLAYER_1, PLAYER_2}) do

    local field = Def.ActorFrame{

        OnCommand=cmd(playcommand,"Refresh");
        StepsChangedMessageCommand=cmd(playcommand,"Refresh");
        SpeedChangedMessageCommand=cmd(playcommand,"Refresh");
        FolderChangedMessageCommand=cmd(playcommand,"Refresh");
        PropertyChangedMessageCommand=cmd(playcommand,"Refresh");
        OptionsListChangedMessageCommand=cmd(playcommand,"Refresh");
        NoteskinChangedMessageCommand=function(self,param)
            if param and param.noteskin and param.Player == pn then
                self:playcommand("Refresh");
            end;
        end;

        RefreshCommand=function(self)
            if GAMESTATE:IsSideJoined(pn) and Global.pncursteps[pn] then
                if Global.state ~= "SelectSteps" then
                    self:visible(Global.oplist[pn]);
                else
                    self:visible(true);
                end;

                local steps = Global.pncursteps[pn];
                local skin = GetPreferredNoteskin(pn);
                local prefs = notefield_prefs_config:get_data(pn);
                if Global.song then
                    local bpms = Global.song:GetDisplayBpms();
                    bpm = (bpms and (bpms[2] or bpms[1])) or bpm;
                end;

                curskin[pn] = skin;
                ApplyFieldPlacement(self, pn, steps, prefs);
                self:playcommand("LayoutChildren", {skin = skin, steps = steps, prefs = prefs});
                MESSAGEMAN:Broadcast("UltimateNotefieldPreviewLayout", {Player = pn, skin = skin, steps = steps, prefs = prefs});
            else
                self:visible(false);
            end;
        end;

        UpdateNotefieldMessageCommand=function(self)
            if GAMESTATE:IsSideJoined(pn) and Global.pncursteps[pn] then
                self:playcommand("ScrollNotes");
            end;
        end;
    };

    for col = 1, 10 do
        field[#field+1] = Def.Sprite{
            Name = "Receptor" .. col;
            InitCommand=cmd(zoom,0.6;y,-118;pause);
            LayoutChildrenCommand=function(self, param)
                local layout = GetColumnLayout(param.steps);
                local entry = layout[col];
                if not entry then
                    self:visible(false);
                    return;
                end;

                local data = entry[2];
                self:x(entry[1]);
                LoadNoteskinSprite(self, param.skin, data.receptor, data.mirror_receptor, data.mirror_receptor ~= nil);
            end;
            UltimateNotefieldPreviewLayoutMessageCommand=function(self, param)
                if param and param.Player == pn then
                    self:playcommand("LayoutChildren", param);
                end;
            end;
        }
    end;

    for row = 1, #preview_pattern do
        for col = 1, 10 do
            field[#field+1] = Def.Sprite{
                InitCommand=cmd(zoom,0.6;pause);
                LayoutChildrenCommand=function(self, param)
                    local layout = GetColumnLayout(param.steps);
                    local entry = layout[col];
                    local pattern_col = ((col - 1) % 5) + 1;

                    if not entry or preview_pattern[row][pattern_col] ~= 1 then
                        self:visible(false);
                        return;
                    end;

                    local data = entry[2];
                    self:x(entry[1]);
                    LoadNoteskinSprite(self, param.skin, data.tap, data.mirror, data.mirror ~= nil);
                    self:playcommand("ScrollNotes");
                end;
                UltimateNotefieldPreviewLayoutMessageCommand=function(self, param)
                    if param and param.Player == pn then
                        self:playcommand("LayoutChildren", param);
                    end;
                end;
                UpdateNotefieldMessageCommand=cmd(playcommand,"ScrollNotes");
                ScrollNotesCommand=function(self)
                    local beat_len = 60 / math.max(bpm, 1);
                    local phase = ((curTime / beat_len) + ((row - 1) * 0.45)) % #preview_pattern;
                    local distance = 34;
                    self:y(-118 + (phase * distance));
                    self:diffusealpha(phase > 0.25 and phase < 6.6 and 1 or 0);
                    self:zoom(0.6 + (phase * 0.006));
                end;
            }
        end;
    end;

    tex[#tex+1] = field;

end;

t[#t+1] = tex;

t[#t+1] = Def.Sprite{
    Texture = "notefield_overlay";
    InitCommand=cmd(zoom,0.515;xy,_screen.cx,_screen.cy-177;vertalign,top;diffusealpha,0);
    OnCommand=cmd(playcommand,"Reload");
    MusicWheelMessageCommand=cmd(playcommand,"Reload");
    StepsChangedMessageCommand=cmd(stoptweening;diffusealpha,0;linear,0.15;diffusealpha,1);
    ReloadCommand=cmd(stoptweening;diffusealpha,0;sleep,0.6;linear,0.25;diffusealpha,1);
    StateChangedMessageCommand=cmd(finishtweening;linear,0.15;fadebottom,Global.state == "GroupSelect" and 0.2 or 0);
}


return t;
