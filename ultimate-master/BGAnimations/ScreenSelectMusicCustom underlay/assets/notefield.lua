
local curTime = -1;
local bpm = 60;
local curskin = {
    [PLAYER_1] = "",
    [PLAYER_2] = "",
}

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

local function FindFileWithPattern(directory, pattern)
    local files = FILEMAN:GetDirListing(directory, false, false) or {};
    local needle = string.lower(pattern);

    for _, file in ipairs(files) do
        if string.find(string.lower(file), needle, 1, true) then
            return directory .. file;
        end;
    end;

    return nil;
end;

local function FindNoteskinFile(skin, pattern)
    local skins = { skin, skin and string.upper(skin) or nil, "PHOENIX", "default" };

    for _, name in ipairs(skins) do
        if name and name ~= "" then
            local found = FindFileWithPattern("NoteSkins/pump/" .. name .. "/", pattern);
            if found then return found; end;
        end;
    end;

    return THEME:GetPathG("", "_blank");
end;

local function LoadNoteskinSprite(self, pn, pattern)
    local skin = GetPreferredNoteskin(pn);
    self:Load(FindNoteskinFile(skin, pattern));
end;

local columns = {
    { x = -128, receptor = "DownLeft Ready Receptor", note = "DownLeft Tap Note", rotationy = 0 },
    { x = -64, receptor = "UpLeft Ready Receptor", note = "UpLeft Tap Note", rotationy = 0 },
    { x = 0, receptor = "Center Ready Receptor", note = "Center Tap Note", rotationy = 0 },
    { x = 64, receptor = "UpLeft Ready Receptor", note = "UpLeft Tap Note", rotationy = 180 },
    { x = 128, receptor = "DownLeft Ready Receptor", note = "DownLeft Tap Note", rotationy = 180 },
};

local preview_chart = {
    {1,0,0,0,0},
    {0,0,0,0,1},
    {0,0,1,0,0},
    {0,0,0,1,0},
    {0,1,0,0,0},
    {0,0,1,0,0},
    {1,0,0,0,0},
    {0,0,0,0,1},
};

local function PositionPreview(self, pn)
    local steps = Global.pncursteps[pn];
    local st = steps and PureType(steps) or "";
    local base_x = _screen.cx;

    if GAMESTATE:GetNumSidesJoined() > 1 and st ~= "Double" and st ~= "Routine" then
        base_x = _screen.cx + 180 * pnSide(pn);
    end;

    self:xy(base_x, _screen.cy);
end;

local function BuildPreviewNoteField(pn)
    local af = Def.ActorFrame{
        InitCommand=function(self)
            self:visible(false);
            self:playcommand("Refresh");
        end;
        StepsChangedMessageCommand=cmd(playcommand,"Refresh");
        SpeedChangedMessageCommand=cmd(playcommand,"Refresh");
        FolderChangedMessageCommand=cmd(playcommand,"Refresh");
        PropertyChangedMessageCommand=cmd(playcommand,"Refresh");
        OptionsListChangedMessageCommand=cmd(playcommand,"Refresh");
        StateChangedMessageCommand=cmd(playcommand,"Refresh");
        OptionsListOpenedMessageCommand=cmd(playcommand,"Refresh");
        OptionsListClosedMessageCommand=cmd(playcommand,"Refresh");
        NoteskinChangedMessageCommand=function(self,param)
            if param and param.Player == pn then
                self:playcommand("Refresh");
            end;
        end;
        RefreshCommand=function(self)
            local show = GAMESTATE:IsSideJoined(pn) and Global.pncursteps[pn];

            if show and Global.state ~= "SelectSteps" then
                show = Global.oplist[pn];
            end;

            self:visible(show and true or false);

            if show then
                PositionPreview(self, pn);
            end;
        end;
    };

    for i, col in ipairs(columns) do
        af[#af+1] = Def.Sprite{
            InitCommand=function(self)
                self:zoom(0.9);
                self:xy(col.x, -160);
                self:rotationy(col.rotationy);
                self:pause();
            end;
            OnCommand=function(self) self:playcommand("Refresh"); end;
            RefreshCommand=function(self) LoadNoteskinSprite(self, pn, col.receptor); end;
            NoteskinChangedMessageCommand=function(self,param)
                if param and param.Player == pn then self:playcommand("Refresh"); end;
            end;
        };
    end;

    for row, data in ipairs(preview_chart) do
        for col_index, value in ipairs(data) do
            if value == 1 then
                local col = columns[col_index];
                af[#af+1] = Def.Sprite{
                    InitCommand=function(self)
                        self:zoom(0.9);
                        self:rotationy(col.rotationy);
                        self:pause();
                    end;
                    OnCommand=function(self)
                        self:playcommand("Refresh");
                        self:playcommand("UpdateNotefield");
                    end;
                    RefreshCommand=function(self) LoadNoteskinSprite(self, pn, col.note); end;
                    NoteskinChangedMessageCommand=function(self,param)
                        if param and param.Player == pn then self:playcommand("Refresh"); end;
                    end;
                    UpdateNotefieldMessageCommand=function(self)
                        local cycle = 384;
                        local scroll = (curTime * 140) % cycle;
                        local y = 190 - ((row - 1) * 48 + scroll);

                        if y < -120 then
                            y = y + cycle;
                        end;

                        self:xy(col.x, y - 160);
                    end;
                };
            end;
        end;
    end;

    return af;
end;

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    tex[#tex+1] = BuildPreviewNoteField(pn);
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
