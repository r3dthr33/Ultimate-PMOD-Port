# Version Log

## Ultimate PMOD compatibility pass

This update ports the Ultimate theme closer to PMOD behavior while keeping Ultimate's own title/menu presentation.

### Fallback and config compatibility

- Set the Ultimate theme to use `pmod` as its fallback theme.
- Added a PMOD compatibility layer for SM5.2-style Lua config helpers used by Ultimate.
- Restored missing helpers such as `create_lua_config`, config save/load hooks, nested option path helpers, and notefield preference defaults.
- Kept Ultimate-specific config scripts loading locally instead of relying on PMOD's screen implementations.

### Screen and layout behavior

- Updated Ultimate's logical screen size to the PMOD-compatible 854x480 layout.
- Forced `ScreenTitleMenu` to use Ultimate's own select screen class instead of inheriting PMOD's title screen behavior.
- Adjusted common menu background scaling so the theme covers the full screen correctly in PMOD.
- Restored the Ultimate header/footer border scale to match the original visual layout.
- Fixed the top header date/time actor so it refreshes and displays correctly after replacing fallback overlays.
- Kept the Ultimate title screen's local footer behavior so the title menu shows the expected join prompt.

### Fallback visual cleanup

- Added blank local title overlay/out actors so PMOD overlay elements do not render over Ultimate's title menu.
- Added a blank local service options overlay to prevent the PMOD logo from appearing in Ultimate's options screen.
- Removed dependency on PMOD visual placeholders where Ultimate provides its own screen art.

### Selection and gameplay compatibility

- Updated Ultimate's master scripts and select music support code for PMOD runtime expectations.
- Adjusted select music custom underlay pieces, including banner wheel and notefield handling, for PMOD compatibility.
- Updated profile load/save overlays to cooperate with the PMOD fallback flow.
- Kept Ultimate-specific assets and behavior active where the theme has its own implementation.

### Cleanup

- Removed obsolete local reference/planning documents from the theme working tree.
- Removed older Ultimate assets and scripts that were no longer used after shifting to PMOD-compatible fallback behavior.
- Added this `versionlog.md` summary for the compatibility pass.

### Verification

- Confirmed visually that the Ultimate title screen opens under PMOD.
- Confirmed title screen scale, header/footer placement, date/time display, and options screen logo cleanup through in-game screenshots.
- No standalone Lua runtime test was available in this workspace.
