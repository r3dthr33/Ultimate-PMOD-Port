# PMOD Theme Port Guidelines

This is a living record of effective steps used while porting SM5.2 themes to PMOD. Add to it only when a step has proven useful in this project.

## Current Port Target

- Source theme: `ultimate-master`
- Known-good SM5.2 reference: `_sm5.2themes/ultimate-master`
- PMOD fallback reference: `_fallback`
- PMOD default theme reference: `pmod`

## Working Rules

- Make port changes only inside `ultimate-master` unless the user explicitly says otherwise.
- Treat `_sm5.2themes`, `_fallback`, and `pmod` as read-only references.
- Keep changes scoped to the requested task or current roadmap item.
- Preserve the source theme's design language unless the task is specifically a redesign.
- When changing UI behavior, compare against screenshots or the existing SM5.2 version whenever possible.

## Effective Steps So Far

1. Read project context first
   - Read `AI.md` before acting on broad project tasks.
   - This establishes the working folder, protected reference folders, communication style, and roadmap expectations.

2. Identify the baselines
   - Compare `ultimate-master` against `_sm5.2themes/ultimate-master` to confirm whether the working copy has diverged from the known-good SM5.2 source.
   - Compare `ultimate-master` against `pmod` and `_fallback` to identify PMOD runtime expectations.

3. Start with metrics and screen flow
   - Review `metrics.ini` first.
   - Focus on:
     - `[Common]`
     - initial screen
     - title menu choices
     - select music flow
     - stage information
     - gameplay
     - evaluation
     - profile load/save
     - fallback/class declarations
   - Screen flow mismatches are likely to cause the earliest PMOD runtime failures.

4. Review branch scripts after metrics
   - For Ultimate, review `ultimate-master/Scripts/Master.lua`.
   - For PMOD, review `pmod/Scripts/Branches.lua`.
   - For fallback behavior, review `_fallback/Scripts/02 Branches.lua`.
   - Document where the source theme branches away from PMOD's expected game loop.

5. Check noteskin assumptions early
   - Compare default noteskin metrics between source and PMOD.
   - Note any routine/player-specific noteskins used by the source theme.
   - PMOD currently expects Phoenix/Pump noteskins, so older SM5.2 defaults may fail or render incorrectly.

6. Check custom music select logic
   - If the source theme has a custom music wheel, inspect its song, group, step, and style filtering.
   - Compare that behavior to PMOD's `ScreenSelectMusic` and channel/game-mode handling.
   - Custom music select screens may bypass PMOD features even when they do not crash.

7. Check scoring and evaluation as a matched pair
   - Review source scoring helpers and custom evaluation screens together.
   - Compare them against PMOD scorekeeper settings.
   - If scoring differs, expect evaluation display, high scores, grades, and gameplay counters to disagree.

8. Write findings before changing behavior
   - Capture risk findings in `potentialissues.md`.
   - Use this as the port-risk reference before modifying screen flow, noteskins, scoring, music select, gameplay, or evaluation.

9. Update AI context when adding durable references
   - If a new project-level reference file is created, add a short mention in `AI.md`.
   - Keep the context note brief and practical.

10. Keep missing fallback APIs local to the ported theme
    - If the source theme expects a helper from SM5.2 fallback that PMOD does not provide, add a compatibility script inside the source theme.
    - Do not modify PMOD `_fallback` for source-theme-specific compatibility unless explicitly instructed.
    - Name compatibility scripts so they load before the scripts that need them, for example `00 ConfigCompat.lua` before `Config.lua`.

11. Handle unsupported actor classes locally
    - If PMOD does not register an SM5.2 actor class, replace that feature with PMOD-supported actors inside the same source-theme screen.
    - Do not bypass source-theme screens or leave visible features disabled when the goal is a faithful port.
    - When the original actor was an engine-level renderer, preserve the visible behavior first, then refine internal fidelity after the screen route is stable.
    - If an `ActorFrameTexture` effect renders incorrectly, recreate the visual with direct actors or proxies before changing the surrounding screen flow.

12. Port missing fallback Lua helpers into the theme
    - If an SM5.2 theme depends on a fallback Lua helper that PMOD does not ship, copy or recreate that helper inside the ported theme's `Scripts` folder.
    - Use a numeric filename when load order matters, for example `04 item_scroller.lua` before menu scripts call `item_scroller_mt`.
    - Keep the helper scoped to the source theme instead of editing PMOD `_fallback`.

13. Patch central compatibility helpers before local callers
    - When a PMOD API name differs from SM5.2, update the source theme's central helper function first.
    - For noteskins, support both SM5.2 profile methods and PMOD profile methods so menu previews, options, and gameplay setup share the same behavior.
    - Check both noteskin manager APIs and profile noteskin APIs; they can fail independently.
    - For config systems, port paired getter/setter helpers together so read and write paths stay consistent.

## First Files To Inspect For Future Ports

- Source theme:
  - `metrics.ini`
  - `Scripts`
  - `BGAnimations/ScreenSelectMusic*`
  - `BGAnimations/ScreenGameplay*`
  - `BGAnimations/ScreenEvaluation*`
  - `Graphics`
  - `Fonts`
  - `Sounds`

- PMOD references:
  - `pmod/metrics.ini`
  - `pmod/Scripts/Branches.lua`
  - `pmod/Scripts`
  - `_fallback/metrics.ini`
  - `_fallback/Scripts/02 Branches.lua`
  - `_fallback/Scripts/00 init.lua`

## Common PMOD Port Risk Checklist

- Does the theme declare or inherit the correct PMOD fallback?
- Does the theme use PMOD's expected initial/title/play flow?
- Does the theme bypass `ScreenSelectMusic`, `ScreenStageInformation`, `ScreenGameplay`, or `ScreenEvaluation`?
- Does it define custom screens that PMOD does not know about?
- Does it use noteskins that exist in PMOD?
- Does it force dance-oriented styles or assumptions?
- Does it filter out Pump double, halfdouble, couple, or routine charts incorrectly?
- Does it depend on SM5.2 helper functions that PMOD fallback implements differently?
- Does it use its own scorekeeper/scoring math instead of PMOD's?
- Does it assume a different screen resolution or layout scale?
- Does it depend on assets that only exist in the source theme or SM5.2 fallback?

## Documentation Habit

- Add successful port steps here after they are proven useful.
- Add discovered risks to `potentialissues.md`.
- Keep both files concise enough to be useful during later roadmap execution.
