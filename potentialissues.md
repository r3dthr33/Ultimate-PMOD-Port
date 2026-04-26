# Potential PMOD Port Issues

These notes summarize the first comparison between the SM5.2 Ultimate theme, the PMOD default theme, and PMOD fallback.

## Baseline Finding

- `ultimate-master` currently matches `_sm5.2themes/ultimate-master` in file list and `metrics.ini`.
- This means the current working theme still appears to be the SM5.2 source theme, not a PMOD-adapted variant.
- The main risk is therefore not missing files yet, but SM5.2 assumptions colliding with PMOD's flow, fallback metrics, noteskins, and Pump-specific game logic.

## Main Risk Areas

1. Screen flow mismatch
   - Ultimate routes play through custom screens:
     - `ScreenProfileLoad`
     - `ScreenSelectMusicCustom`
     - `ScreenEvaluationCustom`
   - PMOD expects a flow closer to:
     - `ScreenRandomWall`
     - `ScreenSelectMusic`
     - `ScreenStageInformation`
     - `ScreenGameplay`
     - `ScreenEvaluation`
   - PMOD-specific modes like WorldMax, QuestWorld, Infinity, random wall loading, stage transitions, and game-over routing may be skipped or broken.

2. PMOD gameplay and evaluation logic may be bypassed
   - PMOD uses screens and branches such as:
     - `ScreenLoadSong`
     - `ScreenStageBreak`
     - `ScreenEvaluation`
     - `ScreenEvaluationQuest`
     - `Branch.AfterGameplay()`
     - `Branch.AfterEvaluation()`
   - Ultimate jumps to its own custom evaluation and profile save flow, so PMOD stage handling may not run correctly.

3. Noteskin defaults are incompatible
   - Ultimate uses:
     - `DefaultNoteSkinName="default"`
     - `RoutineNoteSkinP1="delta-routine-p1"`
     - `RoutineNoteSkinP2="delta-routine-p2"`
   - PMOD uses Phoenix/Pump noteskins:
     - `PHOENIX`
     - `PHOENIX-P1`
     - `PHOENIX-P2`
     - additional player-specific Phoenix skins
   - Possible symptoms: missing noteskin warnings, wrong receptor graphics, routine skin errors, or fallback to an unwanted noteskin.

4. Pump style handling may be wrong
   - Ultimate's `FixStyleForSteps()` sets Double charts to `"single"` and uses `"versus"` when two sides are joined.
   - This is likely incompatible with PMOD Pump styles such as single, double, halfdouble, and routine.
   - Possible symptoms: wrong notefield layout, double charts loading as single, or joined sides behaving unexpectedly.

5. Step filtering may reject valid Pump charts
   - Ultimate's `EligibleSteps()` filters by game name and pad count.
   - The pad-count logic around Pump double, couple, and routine charts looks suspicious.
   - Possible symptoms: valid charts missing from `ScreenSelectMusicCustom`, especially double/routine-style charts.

6. Custom music wheel bypasses PMOD music selection behavior
   - Ultimate builds its own group, song, and steps lists in Lua.
   - PMOD has its own `ScreenSelectMusic`, channel wheel, banned groups, game modes, and extra filtering.
   - Possible symptoms: PMOD channels/modes not respected, banned groups still visible, PMOD-specific song flow missing.

7. Scoring may disagree with PMOD
   - Ultimate has its own PIU scoring logic in `Scripts/PIU.lua`.
   - PMOD uses `ScoreKeeperPrime`.
   - Possible symptoms: gameplay score, evaluation score, high scores, and grades disagreeing with PMOD's expected Prime-style scoring.

8. Fallback dependency differences
   - Ultimate depends on SM5.2 fallback behavior and custom helpers.
   - PMOD `_fallback` provides many helpers too, but its branch flow, metrics, scorekeeping, and noteskin handling are different.
   - Possible symptoms: Lua functions exist but behave differently than expected, causing subtle behavior bugs instead of obvious crashes.

9. Missing PMOD theme metadata
   - `pmod` includes `ThemeInfo.ini`.
   - `ultimate-master` does not currently include one.
   - Possible symptoms: incomplete theme metadata/version display or theme selection information.

10. Resolution and layout mismatch risk
    - PMOD is explicitly configured around `1280x720`.
    - Ultimate uses many older hardcoded positions and SM5.2-era layout assumptions.
    - Possible symptoms: off-screen or overlapping UI in gameplay, music select, evaluation, profile screens, and overlays.

11. Edit/profile/service routing may differ
    - Ultimate title choices go directly to profile load, edit menu, and service options.
    - PMOD title flow includes random wall, PMOD main options, service branches, and profile/game-mode handling.
    - Possible symptoms: screens load but return to unexpected places, or PMOD-specific options are skipped.

## Files Worth Reviewing First During Port Work

- `ultimate-master/metrics.ini`
- `ultimate-master/Scripts/Master.lua`
- `ultimate-master/Scripts/SSM.lua`
- `ultimate-master/Scripts/PIU.lua`
- `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/default.lua`
- `ultimate-master/BGAnimations/ScreenGameplay overlay/default.lua`
- `ultimate-master/BGAnimations/ScreenEvaluationCustom underlay/default.lua`
- `pmod/metrics.ini`
- `pmod/Scripts/Branches.lua`
- `_fallback/metrics.ini`
- `_fallback/Scripts/02 Branches.lua`

## Working Rule

Use `pmod` and `_fallback` as references only. Do not modify them unless explicitly instructed. Port changes should be made inside `ultimate-master`.

## Runtime Errors Found

1. `Scripts/Config.lua:16: attempt to call global 'create_lua_config'`
   - Cause: Ultimate expects SM5.2 fallback's Lua config system, but PMOD fallback does not expose `create_lua_config`.
   - Local fix: added `ultimate-master/Scripts/00 ConfigCompat.lua` so the expected config API and `notefield_prefs_config` exist before `Config.lua` loads.
   - Follow-up: if later errors mention config persistence, profile load/save hooks, or notefield prefs, revisit this compatibility layer.

2. `Metric "ScoreKeeperPrime :: PercentScoreWeightCheckpointHit" is missing`
   - Cause: PMOD uses `ScoreKeeperPrime`, while Ultimate only defined checkpoint weight overrides under `ScoreKeeperNormal`.
   - Local fix: added a `[ScoreKeeperPrime]` block to `ultimate-master/metrics.ini` with PMOD-style percent and grade weights.
   - Follow-up: scoring display may still need deeper review because Ultimate has its own PIU score helpers while PMOD uses Prime scoring.

3. `Metric "Common :: DefaultGameNoteSkin" is missing`
   - Cause: PMOD's noteskin code expects PMOD-specific default noteskin metrics that Ultimate did not define.
   - Local fix: added `DefaultGameNoteSkin` and player-specific Phoenix noteskin defaults under Ultimate's `[Common]`.
   - Follow-up: Ultimate still has `DefaultNoteSkinName="default"` and `DefaultModifiers="m500"` for now. Review noteskin behavior once the theme boots farther.

4. `The theme element "Other/option.json" is missing`
   - Cause: PMOD expects a theme-local option schema file used by its option/gameplay systems. Ultimate did not have an `Other` folder.
   - Local fix: added `ultimate-master/Other/option.json` based on PMOD's default theme schema.
   - Follow-up: once gameplay boots, verify whether these PMOD option defaults should be customized for Ultimate's own gameplay overlay.

5. `The theme element "Graphics/Common nopreview" is missing`
   - Cause: PMOD expects a theme-local no-preview placeholder image. Ultimate only had `Common fallback preview.png`.
   - Local fix: copied PMOD's `Graphics/Common nopreview.jpg` into `ultimate-master/Graphics/Common nopreview.jpg`.
   - Follow-up: replace with an Ultimate-styled placeholder later if the stock PMOD image looks out of place.

6. `The theme element "Graphics/Common nobanner" is missing`
   - Cause: PMOD expects a theme-local no-banner placeholder image. Ultimate only had `Common fallback banner.png`.
   - Local fix: copied PMOD's `Graphics/Common nobanner.png` into `ultimate-master/Graphics/Common nobanner.png`.
   - Follow-up: replace with an Ultimate-styled placeholder later if the stock PMOD image looks out of place.

7. `Metric "CodeDetector :: FullMode" is missing`
   - Cause: PMOD expects extra code detector metrics for Pump/PMOD menu commands. Ultimate did not define `[CodeDetector]`, so fallback metrics were missing PMOD-only codes.
   - Local fix: added PMOD's `[CodeDetector]` block to `ultimate-master/metrics.ini`.
   - Follow-up: once music select works, verify whether these PMOD input codes conflict with Ultimate's custom input handling.

8. `The theme element "Fonts/xolonium 20px" is missing`
   - Cause: PMOD references the Xolonium 20px bitmap font, which Ultimate did not include.
   - Local fix: copied PMOD's `xolonium 20px` `.ini`, `[main]`, and `[alt]` font image files into `ultimate-master/Fonts`.
   - Follow-up: verify text styling later; this is currently a compatibility font, not an Ultimate-styled font choice.

9. `_fallback/BGAnimations/ScreenInit overlay/default.lua:84: attempt to call global 'GetMachineName'`
   - Cause: PMOD's default theme defines `GetMachineName()` in `pmod/Scripts/01 EXTRA.lua`, but that script is not loaded when Ultimate is the active theme.
   - Local fix: added a compatible `GetMachineName()` helper to `ultimate-master/Scripts/00 ConfigCompat.lua`.
   - Follow-up: if more PMOD theme-local helpers are referenced from fallback screens, add narrowly scoped compatibility shims inside Ultimate.

10. Fallback `ScreenInit overlay` appears over Ultimate's init/title flow
   - Cause: Ultimate provides `ScreenInit background.lua` but no `ScreenInit overlay.lua`, so PMOD fallback supplies its own system-options overlay.
   - Local fix: added `ultimate-master/BGAnimations/ScreenInit overlay.lua` as an empty overlay to preserve Ultimate's original init presentation.
   - Follow-up: do not bypass original Ultimate screens to work around this. Keep `Play Game -> ScreenProfileLoad -> ScreenSelectMusicCustom` intact and fix screen compatibility in place.

11. `ScreenProfileLoad` does not continue to music select
   - Cause: Ultimate's profile load/save overlays used a broadcast `Load` message plus `LoadMessageCommand`, while PMOD/fallback profile screens use a queued `LoadCommand`.
   - Local fix: changed Ultimate's `ScreenProfileLoad overlay.lua` and `ScreenProfileSave overlay.lua` to queue `Load` from `BeginCommand` and call `Continue()` from `LoadCommand`.
   - Local fix: added P1 auto-join before `ScreenProfileLoad` continues, matching Ultimate's existing mouse-navigation join behavior.
   - Local fix: removed Ultimate's SM5.2 coin-mode branch restrictions so the theme always returns its intended flow screens.
   - Local fix: removed `playmode,regular` from the title `Play Game` command so PMOD does not route through its own playmode branch before `ScreenProfileLoad`.
   - Local fix: added PMOD-compatible named title choices (`GameStart`, `Edit`, `Options`) while keeping the original numeric choices for Ultimate compatibility.
   - Local fix: added named title icon metrics (`IconChoiceGameStartX/Y`, `IconChoiceEditX/Y`, `IconChoiceOptionsX/Y`) matching Ultimate's original numeric icon positions.
   - Local fix: updated `Graphics/ScreenTitleMenu scroll.lua` to map named choices back to Ultimate's original numeric icon states.
   - Local fix: set `ScreenTitleMenu` `NextScreen` and `StartScreen` to `ScreenProfileLoad` to remove ambiguity in PMOD's title-menu class.
   - Follow-up: verify both profile loading and profile saving still display enough feedback once the flow reaches gameplay/evaluation.
   - Debugging: temporary `SCREENMAN:SystemMessage` traces were added to `ToSelectMusic()` and `ScreenProfileLoad overlay.lua` to identify the actual branch return while PMOD is bouncing back.

12. `ScreenSelectMusicCustom underlay/assets/notefield.lua:49: NoteField is not a registered actor class`
   - Cause: Ultimate's music-select preview uses SM5.2's `Def.NoteField` actor class, but PMOD does not register that actor class.
   - Local fix: replaced that engine actor dependency with a PMOD-compatible preview actor in `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/notefield.lua`.
   - Local fix: the replacement renders receptors and moving Pump notes from the active noteskin into the same `notefield_overlay` texture, preserving Ultimate's Select Steps/options preview behavior without bypassing the screen.
   - Follow-up: refine the preview so it mirrors the selected chart data more closely if PMOD exposes a chart-note Lua API or a usable lower-level note renderer.

13. `ScreenSelectMusicCustom underlay/assets/optionsmenu.lua:406: attempt to call method 'create_actors'`
   - Cause: Ultimate's custom option menus use SM5.2 fallback's `item_scroller_mt`, but PMOD fallback does not include that helper.
   - Local fix: added `ultimate-master/Scripts/04 item_scroller.lua` with the SM5.2 item scroller helper so Ultimate's menu scrollers keep their original structure.
   - Follow-up: if later scroller behavior is visually wrong, compare against `_sm5.2themes/_fallback/Scripts/04 item_scroller.lua` and the original Ultimate Select Music screen.

14. `Scripts/SSM.lua:388: attempt to call method 'get_preferred_noteskin'`
   - Cause: Ultimate uses SM5.2 profile noteskin methods (`get_preferred_noteskin` and `set_preferred_noteskin`), while PMOD profiles expose `GetNoteSkin()` and `SetNoteSkin()`.
   - Local fix: updated Ultimate's `GetPreferredNoteskin()`, `SetNoteskin()`, and `SetNoteskinByIndex()` helpers in `ultimate-master/Scripts/SSM.lua` to support both APIs.
   - Follow-up: verify noteskin changes from player options still persist correctly in PMOD profiles.

15. `Scripts/Options.lua:193: attempt to call global 'get_element_by_path'`
   - Cause: Ultimate's options system depends on SM5.2 fallback config path helpers, but PMOD fallback does not provide them.
   - Local fix: added `get_element_by_path()` and `set_element_by_path()` to `ultimate-master/Scripts/00 ConfigCompat.lua`.
   - Follow-up: if nested config fields fail later, compare behavior against `_sm5.2themes/_fallback/Scripts/02 lua_config_system.lua`.

16. `Scripts/SSM.lua:333: attempt to call method 'get_skin_names_for_stepstype'`
   - Cause: Ultimate uses SM5.2's `NOTESKIN:get_skin_names_for_stepstype()`, while PMOD exposes `NOTESKIN:GetNoteSkinNames()`.
   - Local fix: updated `GetNoteskins()` in `ultimate-master/Scripts/SSM.lua` to support both APIs.
   - Follow-up: PMOD's list may include skins that do not support every Pump style, so verify routine/double noteskin selection later.

17. Music wheel reflection renders incorrectly
   - Cause: Ultimate rendered each wheel-item reflection through `Def.ActorFrameTexture`; PMOD's render-to-texture path displayed the reflection layer incorrectly on the custom music wheel.
   - Local fix: replaced the reflection `ActorFrameTexture` in `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/bannerwheel.lua` with real reflected banner/frame actors so diffuse, fade, crop, and blend commands are applied directly.
   - Follow-up: verify reflection placement against the original SM5.2 theme and tune the proxy crop/offset if it is still visually off.
