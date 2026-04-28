# Version Log

This file records the PMOD porting work done on the Ultimate theme in chronological order.

## Scope

Project goal: make `ultimate-master` run correctly under PMOD while preserving Ultimate's own screens, layout, and behavior wherever possible.

Reference folders used during the port:

- `_sm5.2themes`: original StepMania 5.2 behavior reference
- `_fallback`: PMOD fallback behavior reference
- `pmod`: PMOD theme behavior reference

These folders are reference only and are not part of the implementation target.

## Change Timeline

### 1. Compatibility Foundation

The first major pass established the base compatibility layer needed for Ultimate to boot and own its own screens inside PMOD.

Implemented changes:

- Set `ultimate-master` to use `pmod` as its fallback theme.
- Added PMOD/SM5.2 compatibility helpers in `ultimate-master/Scripts/00 ConfigCompat.lua`.
- Reimplemented missing SM5.2-style config helpers used by Ultimate, including:
  - `create_lua_config`
  - `notefield_prefs_config`
  - `add_standard_lua_config_save_load_hooks`
  - `set_notefield_default_yoffset`
  - `get_element_by_path`
  - `set_element_by_path`
  - `reset_needs_defective_field_for_all_players`
- Kept Ultimate's own config path active instead of letting PMOD replace the screen flow entirely.

Problem solved:

- Fixed the Lua runtime error in `ultimate-master/Scripts/Config.lua` caused by PMOD not exposing `create_lua_config`.

### 2. Screen Ownership And Fallback Control

The next pass focused on stopping PMOD from visually taking over Ultimate screens.

Implemented changes:

- Forced `ScreenTitleMenu` to use Ultimate's own class/metrics path instead of falling through to PMOD's title menu implementation.
- Added local blank screen actor files to block unwanted PMOD fallback overlays:
  - `ultimate-master/BGAnimations/ScreenTitleMenu overlay.lua`
  - `ultimate-master/BGAnimations/ScreenTitleMenu out.lua`
  - `ultimate-master/BGAnimations/ScreenOptionsService overlay.lua`
- Kept Ultimate-specific title and options screens active while still using PMOD as fallback for missing pieces.

Problems solved:

- Title menu was loading PMOD's `ScreenTitleMenu` instead of Ultimate's.
- Options screen was showing PMOD branding instead of staying visually consistent with Ultimate.

### 3. Resolution And Layout Fixes

After screen ownership was corrected, Ultimate still rendered with the wrong scale and proportions under PMOD. This pass normalized the screen layout.

Implemented changes:

- Updated Ultimate's logical screen size to a PMOD-compatible `854x480`.
- Adjusted common background handling to cover the full screen correctly under PMOD.
- Restored Ultimate's header and footer border scaling to better match the original SM5.2 presentation.
- Preserved Ultimate's footer behavior on title so the join prompt appears correctly instead of PMOD profile/fallback text.

Problems solved:

- Title/menu layout was rendering too small.
- Full-screen background and frame elements were not covering the screen properly.
- Footer behavior on title was drifting toward PMOD behavior.

### 4. Header Date And Time

The header needed a local refresh path once PMOD overlays were blocked.

Implemented changes:

- Reworked the date/time actor in `ultimate-master/BGAnimations/ScreenWithMenuElements decorations.lua` so it refreshes itself locally on a timer.
- Kept the header frame in Ultimate while restoring the missing time display logic.

Problem solved:

- The top-right date and time were not appearing after the fallback visual cleanup.

### 5. Select Music And Profile Flow

The select music flow needed several compatibility edits so Ultimate could keep its own information flow while behaving correctly inside PMOD.

Implemented changes:

- Updated `ultimate-master/Scripts/Master.lua` and `ultimate-master/Scripts/SSM.lua` for PMOD runtime expectations.
- Adjusted select music underlay behavior in:
  - `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/default.lua`
  - `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/bannerwheel.lua`
  - `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/notefield.lua`
- Updated profile-related overlays:
  - `ultimate-master/BGAnimations/ScreenProfileLoad overlay.lua`
  - `ultimate-master/BGAnimations/ScreenProfileSave overlay.lua`

Purpose:

- Keep Ultimate's own screen behavior active while aligning its data flow with PMOD's expectations for screen transitions, selected content, and player state.

### 6. Pure Lua Notefield Preview

Ultimate's select music preview used `Def.NoteField`, but PMOD does not register `NoteField` as a usable actor class in this context. This pass replaced that dependency.

Implemented changes:

- Replaced the `Def.NoteField` preview in `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/notefield.lua`.
- Rebuilt the preview entirely in Lua using:
  - `Def.ActorFrame`
  - `Def.Sprite`
  - `Def.ActorFrameTexture`
- Loaded preview receptors and notes directly from `NoteSkins/pump/...`.
- Added noteskin fallback resolution so the preview can recover when a selected noteskin does not expose the exact expected file name.
- Added local single and double preview layouts.
- Added a scrolling preview pattern driven by song time and BPM instead of native `NoteField` methods.
- Removed dependence on native methods such as:
  - `set_steps`
  - `set_skin`
  - `set_curr_second`
  - `set_base_values`
  - `set_vanish_type`

Problem solved:

- Fixed the crash caused by PMOD lacking the SM5.2 hardcoded `NoteField` actor class in this screen.

### 7. Player Options And Mod Persistence

The next compatibility pass focused on making Ultimate's select music option menus store player mods the way PMOD expects, so later screens can read the same state without breaking.

Implemented changes:

- Restored the missing local scroller helper in `ultimate-master/Scripts/04 item_scroller.lua`.
- Updated `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/optionsmenu.lua` to work again through the restored scroller implementation.
- Reworked player option saving in `ultimate-master/Scripts/Config.lua` so preferred player mods are written through PMOD-compatible paths.
- Updated `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/optionslist.lua` so option changes save immediately from the select music player options flow.
- Added compatibility fallbacks for PMOD runtime API differences, including:
  - preferred player option accessors
  - noteskin profile accessors
  - noteskin runtime setters
- Reworked speed handling to PMOD-valid modes only:
  - `XMod`
  - `AV`
- Updated local formatting/text resources for the revised speed option display in:
  - `ultimate-master/Scripts/Format.lua`
  - `ultimate-master/Languages/en.ini`

Problems solved:

- Fixed the missing `create_actors` method crash caused by the absent local scroller helper.
- Fixed invalid speed mode values being written from Ultimate's player options.
- Fixed PMOD runtime errors caused by missing SM5.2-only methods such as:
  - `get_player_options_no_defect`
  - `get_preferred_noteskin`
  - `set_preferred_noteskin`
  - `get_skin_names_for_stepstype`
  - `PlayerOptions:NoteSkin`

### 8. Banner Wheel Reflection Rework

The banner wheel reflection needed a PMOD-friendly rendering path. Earlier reflection attempts relied on behavior that did not render correctly in this runtime.

Implemented changes:

- Reworked `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/bannerwheel.lua`.
- Removed dependence on reflection rendering through a generic sprite texture path.
- Changed the reflection banner to use a real `Def.Banner` actor.
- Reused Ultimate's existing `LoadBanner(self, item)` path for both the main wheel banner and its reflection.
- Kept the reflection as a separately transformed actor with local flip, crop, fade, and blend settings.

Problem addressed:

- The reflection had been rendering as a white faded quad or behaving inconsistently when driven through the wrong actor-loading path.

### 9. Assets, Cleanup, And Removed Files

As the compatibility work progressed, some files were removed or replaced because they were obsolete, conflicting with PMOD fallback behavior, or no longer needed after compatibility rewrites.

Notable cleanup included:

- Removed old local reference/planning documents from the repository root.
- Removed obsolete Ultimate assets/scripts that were no longer used in the PMOD-compatible setup.
- Replaced missing/fallback-driven screen pieces with explicit local Lua actors where needed.

### 10. Documentation Changes

Documentation was reorganized so the project context and the project history live in separate files.

Implemented changes:

- `versionlog.md` now serves as the change history for the port.
- `AI.md` is being kept as a context file only.
- Change summaries previously duplicated in `AI.md` were removed so future assistants have one place for history and one place for working context.

### 11. Notefield Preview Rollback

The select music/player-options notefield preview went through several PMOD-specific rewrite attempts, including pure Lua rendering, noteskin sprite-only loading, receptor layering, and noteskin fallback experiments. The runtime constraints around noteskin metadata access and reliable fallback resolution were not stable enough to justify keeping a half-working preview path in the theme.

Implemented change:

- Removed the experimental notefield preview implementation entirely.
- Replaced `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/notefield.lua` with an empty `Def.ActorFrame{}` stub.

Reason:

- Keep the theme stable and avoid misleading or broken preview behavior until a more reliable implementation path exists.

## Verification Status

Verified visually during the port:

- Ultimate title screen opens under PMOD.
- Ultimate title screen now uses its own screen implementation instead of PMOD's.
- Screen scale and overall layout are much closer to the original SM5.2 presentation.
- Header/footer placement is corrected relative to earlier PMOD fallback behavior.
- Header date/time display was restored.
- PMOD logo bleed-through on the options screen was removed.

Verified by code inspection:

- The select music preview no longer depends on native `Def.NoteField`.
- The experimental Lua preview path was removed and replaced with an empty stub actor to keep the theme stable.

Remaining note:

- No standalone Lua runner or automated PMOD runtime harness is available in this workspace, so final verification still depends on launching the theme in PMOD.
