local function FindGameplayPlayerActor(screen_gameplay, pn)
    if not screen_gameplay or type(screen_gameplay.GetChild) ~= "function" then
        return nil;
    end;

    local actor = screen_gameplay:GetChild("Player" .. ToEnumShortString(pn));
    if actor then return actor end;

    return screen_gameplay:GetChild("Player");
end;

return Def.ActorFrame{
    OnCommand=function(self)
        -- PMOD gameplay uses the engine's native player/notefield state
        -- directly.  Ultimate already applies preferred player options before
        -- gameplay, so this actor only keeps the routine-specific visibility
        -- behavior that Ultimate expected from the old helper layer.
        if IsRoutine() then
            local screen = SCREENMAN:GetTopScreen();
            local other = OtherPlayer[Global.master];
            local other_actor = FindGameplayPlayerActor(screen, other);
            if other_actor then
                other_actor:hibernate(math.huge);
            end;
        end;
    end;
};
