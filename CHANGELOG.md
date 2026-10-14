# Changelog

## 0.10.1 — 2026-10-14

- Fixed the missing Quest icon in navigation, collection cards and the detail inspector by using client-verified FileDataID 134939.
- Added a detailed English public README with installation, feature descriptions, practical workflows and development instructions.
- Added reproducible release packaging and GitHub Actions validation.
- Made the static validator portable across Windows and Linux.

## 0.10.0 — 2026-10-14

- Collections populate immediately on opening; every entry has an icon card.
- Added full-result pagination, accent-insensitive search, category filters and favorites filtering.
- Added DB2-derived class masks, categories, passive flags and icons for 32,337 spells.
- Added 26 internal spells, 2 client-present core debug spells, and 136 client-defined mount spells.
- Inspected user-supplied NightVibesGMPanel 5.13.0; recovered 4,479 item names, 23,705 English aliases, 1,388 trainer spell tags, 51 quest-spell tags and 5 Forever racial spells, all checked against local IDs.
- Added 198 equipment sets with complete client-verified member previews and a Give Set action.
- Added a dedicated GM tools collection with 12 icon shortcuts.
- Added distinct proficiency icons for one-handed/two-handed weapons, staves, armor and professions.
- Added a selectable preview to grant all compatible skills, weapon skills or professions; learning and maximizing are separate choices.
- Bulk queues learn verified proficiency spells, then set the selected skill lines; they cancel on target changes.
- Rebuilt the main layout as a responsive icon grid with a side inspector on wide windows and a lower inspector on compact windows.
- Added runtime regression coverage for browsing, class filters, paging, resizing, bulk rules, confirmations and target cancellation.

## 0.9.0 — 2026-10-14

- Added interface-16001 compatibility layer and SavedVariables migration.
- Added dark fantasy window, navigation, detail/actions panel, settings, status bar, and minimap launcher.
- Added incremental search across commands, spells, skills, languages, mounts, items, teleports, quests, achievements, NPCs, and GameObjects.
- Added generated ForeverCore command/RBAC registry and full command reference.
- Added safe dispatch states, rate limiting, confirmations, bulk cancellation, favorites, and local recent history.
- Added English, French, and Spanish localization.
- Explicitly disabled unsourced BiS recommendations.
