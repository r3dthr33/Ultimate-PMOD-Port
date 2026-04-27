# AI Working Context

This file explains how to work with an AI coding assistant in this project.

## Main Context

Project objective: port a StepMania 5.2 theme called Ultimate to PMOD, a Pump It Up focused StepMania fork.

## Folder Rules

- `ultimate-master` is the working theme folder. Make code, metric, asset, and compatibility changes here.
- `_sm5.2themes` is reference only. It contains the original StepMania 5.2 environment where Ultimate works correctly. Do not modify it.
- `_fallback` is reference only. It contains PMOD fallback behavior shared by themes. Do not modify it.
- `pmod` is reference only. It contains PMOD's default theme and should be used to understand PMOD behavior. Do not modify it.

## Debugging Workflow

When a PMOD runtime error or visual mismatch appears:

1. First identify what the error or visual issue means.
2. Then check how PMOD handles the same screen, helper, metric, or asset.
3. Implement the needed compatibility behavior in `ultimate-master`.
4. Keep Ultimate's own visuals and screen implementations whenever possible.

Do not copy PMOD screens wholesale unless Ultimate has no equivalent implementation. The goal is PMOD compatibility with Ultimate presentation.

## Current Compatibility Direction

- Ultimate now uses `pmod` as its fallback theme.
- Ultimate should still load its own `ScreenTitleMenu`, title menu assets, common decorations, and footer.
- PMOD fallback elements should only appear when Ultimate is genuinely missing that behavior.
- If PMOD fallback art appears over an Ultimate screen, add or repair the local Ultimate actor/overlay instead of changing PMOD.
- The theme is using a PMOD-compatible 854x480 logical layout.

## Version Log

All change history belongs in `versionlog.md`.
