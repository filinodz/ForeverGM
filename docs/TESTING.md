# Testing and QA

## Automated checks completed

Run:

```sh
python Tests/validate_addon.py
node Tests/syntax.js
node --max-old-space-size=4096 Tests/runtime.js
```

The validator checks the interface number, all TOC paths, command-count/identity integrity, command provenance and permission fields, minimum source-dataset counts, localization key parity, and the generated command-reference artifact.

Latest result on 2026-10-14: **PASS — 51 TOC files, 680 commands, all dataset and locale checks passed.**

All addon Lua files were parsed successfully in Lua 5.1 mode with `luaparse` 0.3.1. The parser is a test dependency only.

## Runtime regression suite, 0.10.1

`Tests/runtime.js` runs the actual TOC modules in Fengari with the WoW API mock in `Tests/runtime.lua`. It does not send real chat messages or alter a character.

Latest result: **1,693 assertions passed**. Coverage includes collections on opening; all data pages; icon binding (including Quest navigation, cards and detail); Mage and GM/internal/trainer/quest/racial spell filters; command-category predicates; set membership; default GM shortcut parameters; layout at widths 820, 1160 and 1600; staff versus two-handed-sword compatibility; Skyborne race masks; invalid/test skill exclusion; proficiency spell selection; locale parity; dangerous-action confirmation; and immediate cancellation when the target changes.

Fengari supplies a Lua VM, not the game renderer. These tests verify runtime control flow with mocked APIs; visual rendering and live command acceptance are separate in-game checks.

## Client installation completed

A test copy was installed at:

`<WoW client>/_classic_beta_/Interface/AddOns/ForeverGM`

The character addon list was updated to enable ForeverGM. The client executable launches, but the hardware-rendered WoW window was not capturable by the available UI automation channel. No unseen clicks or keystrokes were attempted, and this document does not claim an in-game pass.

## Manual in-game checklist

1. Log in on a GM character and confirm no Lua error appears.
2. Run `/fgm`; verify that Skills opens populated with icon cards and the current target is displayed.
3. Drag and resize the window; `/reload`; verify geometry persists.
4. Drag the minimap button, left-click to toggle, right-click for settings.
5. Search a known command such as `modify money`; inspect syntax, RBAC, source, and execute only against a safe test character.
6. Confirm the status says dispatched, then response received—not success inferred.
7. Browse without a search, change category/class filters, visit the last page, then search exact IDs. Test one-handed/two-handed weapons and staves; trainer, quest and Forever racial spell filters; and equipment-set previews.
8. Test a dangerous command and verify the confirmation dialog appears; cancel it.
9. Queue multiple safe operations, verify pacing, and cancel the remaining queue.
10. Switch among English, French, and Spanish, reload, and inspect every navigation and dialog label.
11. Test at several UI scales and resolutions; verify the frame remains clamped and readable.
12. Record `GetAddOnMemoryUsage("ForeverGM")` after searches and watch for FPS spikes.

## Deliberately unclaimed

- Successful visual QA in the running client
- Successful command execution on every realm/ruleset
- Correctness of an unsourced BiS profile (none is packaged)
- Complete achievement names beyond the 104 populated local hotfix records
