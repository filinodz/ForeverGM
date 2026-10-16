# Changelog

## 0.12.0 — 2026-10-16

- Apply the selected addon language to catalog names, name search, set-member previews, class/slot/role labels and summaries, not only navigation text.
- Normalize locale aliases, including `enUs`, `enGB` and `esMX`; Auto follows the game client's text locale.
- Localize the remaining compatibility warning and Auto setting label.
- Import available French/Spanish quest, NPC, object and achievement names; add complete English/Spanish skill and language labels alongside French.
- Use offline English item names (24,312 records), modern item APIs and cache-completion refresh; never silently display a different language for unresolved data.
- Add 47 client-metadata items (24,335 total) and expose 5 additional Mount.db2 SourceSpellID references (141 mounts total). These five references await name resolution in the matching-language client.
- Add confirmed, selectable all-mount and verified-GM-spell grants with target-GUID protection; retain the existing all-compatible-skills preview.
- Expand to 277 client set records, with direct T1/T2/T3 filters and exact class masks. All 27 original tier sets are visible; 18 legacy T1/T2 sets whose members are absent from the inspected item metadata are explicitly unavailable, not silently omitted or grantable.
- Add 9 sourced Classic Era PvE Phase-6 candidate collections. Only exact, unambiguous item matches are granted; unresolved source recommendations and alternatives are disclosed. These are not complete optimized loadouts or custom-realm BiS guarantees.
- Wrap the four-button toolbars responsively and increase the minimum window height to 700px.
- Document incomplete multilingual data coverage honestly. This release does not claim every custom record has a translation in every language.
- Command transport is unchanged from 0.11.1.

## 0.11.1 — 2026-10-15

- Send isolated commands synchronously from their button/confirmation click instead of deferring every operation to OnUpdate.
- Route commands through normal self-whisper chat, matching the verified ForeverCore command parser; do not emit delayed public SAY messages.
- Replace the misleading "awaiting server response" status with "Sent to chat" in English, French and Spanish, and echo the sent command locally in chat.
- Keep burst/bulk pacing, confirmation dialogs, target-change cancellation, command validation and server-side permissions.
- Expire optional response observation without blocking, resending commands or fabricating success. Surface transport failures without recording them as sent.
- Add regression coverage for synchronous sends, chat channel/recipient, both chat API families, no-response progress, failures and safeguards.

## 0.11.0 — 2026-10-14

- Replaced the text-only dashboard with a responsive landing page: 12 illustrated catalog-count cards and 16 essential-tools/workflow shortcuts.
- Removed dashboard pagination, search/filter controls and the empty detail inspector; retained pagination in real collections.
- Added clickable statistics, formatted counts, player-target/build banner, hover feedback and vertical scrolling at compact widths.
- Routed every dashboard GM command through explicit confirmation and the existing validated, rate-limited executor. No inferred toggle status is displayed.
- Redesigned the minimap launcher with an original circular gold/teal eye-and-key medallion, a larger clickable area and hover/pressed feedback; retained left/right click, dragging, persistence and hiding.
- Corrected minimap drag coordinates to use the minimap's effective scale.
- Added English/French/Spanish dashboard labels, asset-format/version validation and dashboard/minimap regression coverage.

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
