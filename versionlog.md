# Version Log

## 0.0.1 — Compatibility Foundation

Implemented:

- Set `ultimate-master` to use `pmod` as its fallback theme.
- Added PMOD/SM5.2 compatibility helpers in `ultimate-master/Scripts/00 ConfigCompat.lua`.
- Reimplemented missing SM5.2-style config helpers used by Ultimate:
  - `create_lua_config`
  - `notefield_prefs_config`
  - `add_standard_lua_config_save_load_hooks`
  - `set_notefield_default_yoffset`
  - `get_element_by_path`
  - `set_element_by_path`
  - `reset_needs_defective_field_for_all_players`
- Kept Ultimate's own config path active instead of letting PMOD replace the screen flow entirely.

Solved:

- Fixed the Lua runtime error in `ultimate-master/Scripts/Config.lua` caused by PMOD not exposing `create_lua_config`.

## 0.0.2 — Screen Ownership And Layout

Implemented:

- Forced `ScreenTitleMenu` to use Ultimate's own class/metrics path instead of falling through to PMOD's title menu implementation.
- Added local blank screen actor files to block unwanted PMOD fallback overlays:
  - `ultimate-master/BGAnimations/ScreenTitleMenu overlay.lua`
  - `ultimate-master/BGAnimations/ScreenTitleMenu out.lua`
  - `ultimate-master/BGAnimations/ScreenOptionsService overlay.lua`
- Updated Ultimate's logical screen size to a PMOD-compatible `854x480`.
- Adjusted common background handling to cover the full screen correctly under PMOD.
- Restored Ultimate's header and footer border scaling to better match the original SM5.2 presentation.
- Preserved Ultimate's footer behavior on title so the join prompt appears correctly instead of PMOD profile/fallback text.

Solved:

- Title menu was loading PMOD's `ScreenTitleMenu` instead of Ultimate's.
- Options screen was showing PMOD branding instead of staying visually consistent with Ultimate.
- Title/menu layout was rendering too small.
- Full-screen background and frame elements were not covering the screen properly.

## 0.0.3 — Header, Select Music, And Profile Flow

Implemented:

- Reworked the date/time actor in `ultimate-master/BGAnimations/ScreenWithMenuElements decorations.lua` so it refreshes locally on a timer.
- Updated `ultimate-master/Scripts/Master.lua` and `ultimate-master/Scripts/SSM.lua` for PMOD runtime expectations.
- Adjusted select music underlay behavior in:
  - `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/default.lua`
  - `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/bannerwheel.lua`
  - `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/notefield.lua`
- Updated profile-related overlays:
  - `ultimate-master/BGAnimations/ScreenProfileLoad overlay.lua`
  - `ultimate-master/BGAnimations/ScreenProfileSave overlay.lua`

Solved:

- Restored the top-right date and time after fallback visual cleanup.
- Kept Ultimate's own select music/profile flow active while aligning transitions and player state with PMOD.

## 0.0.4 — Player Options And PMOD Mod Persistence

Implemented:

- Restored the missing local scroller helper in `ultimate-master/Scripts/04 item_scroller.lua`.
- Updated `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/optionsmenu.lua` to work through the restored scroller implementation.
- Reworked player option saving in `ultimate-master/Scripts/Config.lua` so preferred player mods are written through PMOD-compatible paths.
- Updated `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/optionslist.lua` so option changes save immediately from the select music player options flow.
- Added compatibility fallbacks for PMOD runtime API differences around:
  - preferred player option accessors
  - noteskin profile accessors
  - noteskin runtime setters
- Reworked speed handling to PMOD-valid modes only:
  - `XMod`
  - `AV`
- Updated local formatting/text resources for the revised speed option display in:
  - `ultimate-master/Scripts/Format.lua`
  - `ultimate-master/Languages/en.ini`

Solved:

- Fixed the missing `create_actors` method crash caused by the absent local scroller helper.
- Fixed invalid speed mode values being written from Ultimate's player options.
- Fixed PMOD runtime errors caused by missing SM5.2-only methods such as:
  - `get_player_options_no_defect`
  - `get_preferred_noteskin`
  - `set_preferred_noteskin`
  - `get_skin_names_for_stepstype`
  - `PlayerOptions:NoteSkin`

## 0.0.5 — Banner Reflection Rework

Implemented:

- Reworked `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/bannerwheel.lua`.
- Removed dependence on reflection rendering through a generic sprite texture path.
- Changed the reflection banner to use a real `Def.Banner` actor.
- Reused Ultimate's existing `LoadBanner(self, item)` path for both the main wheel banner and its reflection.
- Kept the reflection as a separately transformed actor with local flip, crop, fade, and blend settings.

Addressed:

- The reflection had been rendering as a white faded quad or behaving inconsistently when driven through the wrong actor-loading path.

## 0.0.6 — Cleanup And Documentation Split

Implemented:

- Removed old local reference/planning documents from the repository root where they were obsolete.
- Removed obsolete Ultimate assets/scripts that were no longer used in the PMOD-compatible setup.
- Replaced missing/fallback-driven screen pieces with explicit local Lua actors where needed.
- Moved project history responsibility to `versionlog.md`.
- Reduced `AI.md` to project-context and workflow guidance.

## 0.0.7 — Notefield Preview Rollback

Implemented:

- Removed the experimental notefield preview implementation entirely.
- Replaced `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/notefield.lua` with an empty `Def.ActorFrame{}` stub.

Reason:

- The PMOD runtime constraints around noteskin metadata access and fallback resolution were not stable enough to justify keeping a half-working preview path.

## 0.0.8 — Gameplay And Evaluation PMOD-Native Rework

Implemented:

- Reworked gameplay/evaluation compatibility away from SM5.2-only assumptions.
- Rewrote `ultimate-master/BGAnimations/ScreenGameplay overlay/assets/newfield.lua` to use PMOD/native gameplay actor access directly.
- Fixed `ultimate-master/BGAnimations/ScreenGameplay underlay/assets/filter.lua` to use PMOD/native actor methods and safer width fallback logic.
- Reworked `ultimate-master/BGAnimations/ScreenGameplay overlay/assets/offset.lua` to stop using `TimingWindowScale` and `TimingWindowSecondsW1..W5`, and instead derive timing display from PMOD-style judge difficulty.
- Patched `ultimate-master/BGAnimations/ScreenEvaluationCustom underlay/assets/information.lua` to use local compat getters instead of undefined timing/life helpers.
- Restored Ultimate gameplay/evaluation actor stacks after isolating the crash source.

Solved:

- Fixed PMOD crashes around `TimingWindowScale`.
- Fixed gameplay entry/runtime issues caused by SM5.2-only notefield helper expectations.
- Restored Ultimate evaluation loading under PMOD.

## 0.0.9 — PMOD Command Window Option Mapping

Implemented:

- Reviewed PMOD's command window behavior and mapped its options into Ultimate's player-options menu while keeping Ultimate's menu style.
- Expanded `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/optionslist.lua` with PMOD-style categories and direct options.
- Extended `ultimate-master/Scripts/Options.lua`, `ultimate-master/Scripts/Config.lua`, `ultimate-master/Scripts/Format.lua`, and `ultimate-master/Languages/en.ini` to support PMOD-backed getters, setters, formatting, and persistence.
- Removed categories later deemed unnecessary from the player menu:
  - `Gameplay UI`
  - `Judgment Skin`
  - `Lifebar Skin`
  - `Transform`
  - `Sort`
- Flattened direct entries on the main menu:
  - `Noteskin`
  - `Rush`
  - `Reset All`

## 0.0.10 - Main Player Options Preview And Persistence Cleanup

Implemented:

- Added live value summaries for top-level player option categories in `ultimate-master/Scripts/Options.lua`.
- Added cycling value previews for multi-state categories in the main options list.
- Styled `Exit` in red and `Reset All` in green inside `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/optionslist.lua`.
- Persisted PMOD category selections into `PLAYERCONFIG` instead of relying only on live `ModsLevel_Preferred` state:
  - `Display`
  - `Path`
  - `Alternate`
  - `Judge`
  - PMOD `BGA`
  - PMOD `Rise`
- Reapplied those saved PMOD categories when rebuilding SSM after returning from gameplay.
- Updated PMOD reset helpers so they also clear the new stored PMOD fields.

Solved:

- Returning from gameplay via Back now restores previously selected PMOD-style mods in SSM instead of partially dropping them.

## 0.0.11 - PMOD Noteskin Reset And Theme Self-Hosting

Implemented:

- Reset Ultimate's noteskin handling to follow PMOD's live behavior more closely:
  - noteskin selection now saves through `PROFILE:SetNoteSkin(...)`
  - removed Ultimate-specific noteskin mirroring into preferred/current player options
  - removed SM5.2-style `set_preferred_noteskin(...)` fallback writes from the active PMOD path
- Cleaned noteskin-related leftovers from:
  - `ultimate-master/Scripts/SSM.lua`
  - `ultimate-master/Scripts/Config.lua`
  - `ultimate-master/BGAnimations/ScreenSelectMusicCustom underlay/assets/mainmenu.lua`
- Added a local `ScreenSystemLayer` debug overlay path for runtime inspection.
- Switched Ultimate's fallback theme to `_fallback` instead of `pmod`.
- Added local PMOD-dependent theme resources so Ultimate can provide them itself:
  - `ultimate-master/Other/option.json`
  - `ultimate-master/Graphics/Common nobanner.png`
  - `ultimate-master/Graphics/Common nopreview.jpg`
- Added local metrics definitions needed after reducing direct PMOD fallback dependence, including:
  - `CodeDetector`
  - `ScoreKeeperPrime`
  - local `ScreenStageInformation` behavior
  - local noteskin defaults

Addressed:

- Removed the old hybrid noteskin-saving experiments so Ultimate has a clean PMOD-style starting point again.
- Reduced direct dependence on PMOD theme assets/metrics for common runtime paths.

## 0.0.12 - PMOD6 Self-Hosting Fixes

Implemented:

- Added local PMOD net room strings used by PMOD6.
- Added missing PMOD6 Common noteskin metrics:
  - `NSWhiteList`
  - `DefaultNoteSkinPlayer5`
- Cleared Ultimate's legacy `StepsTypesToHide` list so PMOD6 no longer validates unsupported SM5 stepstypes.
- Added a local `Graphics/GenericPreview.mpg` asset for PMOD6's generic preview lookup.

Solved:

- Fixed startup/runtime missing string errors for `PModNet`.
- Fixed invalid stepstype errors for hidden SM5-only stepstypes.
- Fixed missing `Graphics/GenericPreview`.
- Fixed missing PMOD6 noteskin metrics.

## 0.0.13 - Guard Options Menu Player Summaries

Implemented:

- Passed the active/master player into Ultimate's theme options menu summary refresh.
- Added internal player resolution and nil-player guards to PMOD option summary reads.

Solved:

- Fixed `Expected PlayerNumber; got nil` when opening or refreshing the options menu in select music.

## 0.0.14 - Remove Coin Mode Branching

Implemented:

- Removed coin-mode checks from Ultimate's branch helpers.
- Made title/init/operator routing return static Ultimate screens instead of coin-mode-dependent screens.
- Removed Ultimate's local `CoinModeChangeScreen` override.
- Removed the pay-mode pause guard from gameplay.

Addressed:

- Keeps Ultimate's screen flow independent from PMOD6 coin mode state.

## 0.0.15 - Add PMOD Noteskin Alpha Helper

Implemented:

- Added a local guarded `GetCurNSAlpha(player)` compatibility helper for PMOD6 pump noteskins.

Solved:

- Fixed PMOD6 noteskin receptor crashes when noteskins call `GetCurNSAlpha` under Ultimate's `_fallback`-based runtime.
