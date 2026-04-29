# AI Working Context

This file defines how an AI coding assistant should work in this project.

## Main Objective

Port `ultimate-master` so it runs correctly under PMOD while preserving Ultimate's own visual identity, screen flow, and menu structure where possible.

## Working Target

- `ultimate-master` is the only implementation target.

All code, metric, asset, and compatibility edits must happen there unless the user explicitly says otherwise.

## Reference Folders

These folders are reference only and must not be modified:

- `_sm5.2themes`
- `_fallback`
- `pmod`

Use them to inspect:

- original SM5.2 Ultimate behavior
- PMOD runtime behavior
- fallback helper availability
- metric/layout differences

Do not patch them, even if they contain a version of the code that would be easier to change.

## Required Workflow

When debugging or implementing compatibility:

1. First identify what the error, missing behavior, or visual mismatch actually means.
2. Then inspect how PMOD handles that same concept in its own runtime or theme code.
3. Then implement the behavior inside `ultimate-master`.
4. Keep Ultimate's own screens and presentation whenever possible.

This project should be approached as:

- PMOD runtime first
- Ultimate presentation second
- compatibility implemented locally in `ultimate-master`

## Preferred Engineering Direction

Prefer direct rewrites against PMOD-native runtime behavior over shim-heavy compatibility work.

Good examples:

- read PMOD player options directly
- read PMOD song options directly
- use PMOD profile/custom option storage when PMOD already uses it
- rewrite a feature to use PMOD-native data instead of depending on SM5.2-only helper APIs

Avoid:

- assuming SM5.2 helper functions exist in PMOD
- copying large PMOD screens wholesale when Ultimate already has its own screen
- patching reference folders to make Ultimate work
- relying on workaround layers when the real PMOD runtime source can be used directly

If a helper exists only in `_sm5.2themes` and not in PMOD, treat it as unavailable and redesign around PMOD's real runtime state.

## Gameplay / Notefield Rule

Do not assume SM5.2 newfield helpers exist in PMOD.

Examples of helpers that should be treated as unavailable unless proven otherwise in the active runtime:

- `notefield_mods_actor`
- `notefield_prefs_actor`
- `find_pactor_in_gameplay`
- similar SM5.2 helper-layer functions

If Ultimate needs equivalent behavior:

- inspect what PMOD actually uses
- read PMOD-native player/song/profile state directly
- reimplement only the needed behavior inside `ultimate-master`

## Preferences And Metrics Rule

Do not assume PMOD exposes the same `PREFSMAN` preferences as SM5.2.

Before using `GetPreference` or `SetPreference`:

1. Verify PMOD actually uses that preference.
2. If PMOD does not use it, keep the value theme-local or remap it to PMOD-native data.

Examples already encountered:

- `BGBrightness` should not be written to `PREFSMAN`
- `TimingWindowScale` should not be read or written directly
- `LifeDifficultyScale` should not be written directly

When PMOD uses an equivalent concept through mods instead of prefs, remap to the PMOD concept instead of recreating the SM5.2 preference path.

## Screen Ownership Rule

Ultimate should keep using its own screens, overlays, and assets whenever they exist.

PMOD fallback should only cover genuinely missing pieces.

If PMOD art or behavior appears over an Ultimate screen:

- fix or add the needed local Ultimate actor
- do not change PMOD

## Documentation Rule

- `AI.md` is for working rules and current context only.
- `versionlog.md` is for change history.

Do not put implementation history in `AI.md`.

## Current Direction

- `ultimate-master` uses PMOD as fallback.
- The port should continue moving toward PMOD-native data sources.
- Compatibility should be implemented locally in `ultimate-master`.
- Reference folders remain read-only.

## Verification Status

Verified visually during porting:

- Ultimate title screen opens under PMOD.
- Ultimate title screen uses its own screen implementation instead of PMOD's.
- Screen scale and layout are much closer to the original SM5.2 presentation.
- Header/footer placement is corrected relative to earlier PMOD fallback behavior.
- Header date/time display was restored.
- PMOD logo bleed-through on the options screen was removed.
- Evaluation can load under PMOD after the gameplay/evaluation compatibility rework.

Verified by code inspection:

- `ultimate-master` no longer contains live `TimingWindowScale` references.
- Select music/player-options notefield preview is intentionally removed and stubbed for stability.
- PMOD-style player mod categories now persist through `PLAYERCONFIG` and are reapplied when SSM is rebuilt.

Remaining note:

- No standalone Lua runner or automated PMOD runtime harness is available in this workspace, so final verification still depends on launching the theme in PMOD.

# Version Log

This file records changes to the `ultimate-master` PMOD port using the version format `0.0.0`.

## Versioning Rule

- Branch `wip` iteration/commits changes increment the patch version:
  - `0.0.1`
  - `0.0.2`
  - `0.0.3`
- Merging the branch work into `main` increments the minor version:
  - `0.0.2` -> `0.1.0`
  - `0.1.4` -> `0.2.0`