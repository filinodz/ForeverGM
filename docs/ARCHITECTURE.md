# Architecture

ForeverGM is split between an offline generation layer and a restricted in-game layer.

```text
ForeverCore source + local MySQL
             |
    Tools/generate_data.py
             |
      generated Lua tables
             |
Core -> Database/search -> UI/modules -> CommandExecutor -> WoW chat -> ForeverCore RBAC
```

## Runtime layers

- `Core/Init.lua`: namespace, localization lookup, module registration, guarded calls.
- `Core/Compatibility.lua`: build and optional-API detection.
- `Core/SavedVariables.lua`: schema defaults, migration, favorites, recent local history.
- `Core/CommandRegistry.lua`: verified metadata lookup and safe command construction.
- `Core/CommandExecutor.lua`: validation, destructive-action confirmations, synchronous isolated sends through self-whisper chat, burst/bulk pacing, cancellation, and optional expiring response observation. No server response gates dispatch. Commands are echoed locally only after the chat API call returns without throwing.
- `Core/Database.lua`: incremental search over 500 source rows per update, with accent normalization and predicates applied before pagination. An empty query browses the full collection; there is no discarded-results cap.
- `Core/Catalog.lua`: name/icon API adapters, DB2-backed categories, class/race matching and skill values.
- `UI/`: theme, reusable controls, tooltips, confirmation dialogs, main window, and minimap button. The window lays out a responsive card grid and switches its detail inspector between side and bottom positions. Pages reuse 60 cards.
- `UI/Dashboard.lua`: separate full-width, vertically scrolling landing page with 12 count cards and 16 shortcuts. It has no collection pager or search job; real collection views retain those controls. GM shortcuts use the existing confirmation/executor path.
- `Modules/`: feature metadata that binds navigation areas to verified command/data capabilities.
- `Core/LocalizedData.lua`: selected-locale data resolution and translated summaries; never mixes a French base name into an English selection. Matching-client item cache events refresh visible labels.
- `Data/`: generated immutable tables. `LocalizedNames.lua` / `SkillNames.lua` supply locale-tagged names. `BiS.lua` appends 9 sourced Phase-6 candidate collections to the set browser, with explicit incomplete-coverage metadata.
- `Modules/SpellBulk.lua`: selectable mount/GM-spell previews and item-by-item BiS candidate grants; confirmations, captured target GUIDs and the existing executor enforce safeguards.

## Security boundaries

ForeverGM sends the same dot commands a GM could type manually. It cannot grant itself RBAC permissions, query SQL, contact HTTP services, or claim success merely because a message was sent. Input rejects newlines, semicolons, and hyperlink control sequences. Risky actions receive explicit confirmation.

## Search and memory

Data is represented as compact positional arrays except command metadata. Search is incremental to avoid a long UI frame. The initial version packages datasets in one addon for predictable installation. A future packaging optimization can split the largest tables into load-on-demand companion addons without changing the query API.

## Adding BiS profiles

Profiles must identify expansion/build, content phase, PvE/PvP context, class/role, item IDs, alternatives, source citations and missing coverage. Candidate collections are not complete optimized loadouts. Only locally validated, unambiguous matches can enter the grant queue; never turn a synthetic profile ID into `.additem set`. Original client sets with missing members remain inspectable but unavailable.
