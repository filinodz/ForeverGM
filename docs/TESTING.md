# Testing and QA

## Automated checks completed

Run:

```sh
python Tests/validate_addon.py
node Tests/syntax.js
node --max-old-space-size=4096 Tests/runtime.js
```

The validator checks the interface number, all TOC paths, command-count/identity integrity, command provenance and permission fields, minimum source-dataset counts, localization key parity, and the generated command-reference artifact.

Latest result on 2026-10-14: **PASS — 53 TOC files, 680 commands, all dataset and locale checks passed.** The validator also checks runtime/TOC version parity and the transparent 128px minimap TGA format.

All addon Lua files were parsed successfully in Lua 5.1 mode with `luaparse` 0.3.1. The parser is a test dependency only.

## Runtime regression suite, 0.11.0

`Tests/runtime.js` runs the actual TOC modules in Fengari with the WoW API mock in `Tests/runtime.lua`. It does not send real chat messages or alter a character.

Latest result: **2,229 assertions passed**. Coverage includes the dashboard landing page; all 12 exact count cards and navigation destinations; restored collection viewport/inspector anchors; all 16 shortcuts; absence of dashboard pagination/search; card bounds and scroll extents at widths 820, 1000, 1160, 1600 and 1920; confirmation/default arguments for every GM shortcut; workflow previews; minimap icon, hover/press feedback, left/right click and drag persistence; collections on opening; all data pages; icon binding (including Quest navigation, cards and detail); Mage and GM/internal/trainer/quest/racial spell filters; command-category predicates; set membership; default GM shortcut parameters; staff versus two-handed-sword compatibility; Skyborne race masks; invalid/test skill exclusion; proficiency spell selection; locale parity; dangerous-action confirmation; and immediate cancellation when the target changes.

Fengari supplies a Lua VM, not the game renderer. These tests verify runtime control flow with mocked APIs; visual rendering and live command acceptance are separate in-game checks.

## Client installation completed

A test copy was installed at:

`<WoW client>/_classic_beta_/Interface/AddOns/ForeverGM`

The character addon list was updated to enable ForeverGM. The client executable launches, but the hardware-rendered WoW window was not capturable by the available UI automation channel. No unseen clicks or keystrokes were attempted, and this document does not claim an in-game pass.

## Manual in-game checklist

1. Log in on a GM character and confirm no Lua error appears.
2. Run `/fgm` after loading; verify the illustrated dashboard opens, shows 12 catalog cards and 16 tools, has no pager/search/empty inspector, and reflects the current target. Click statistics cards to browse populated collections, then return to the dashboard.
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
