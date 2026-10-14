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
- `Core/CommandExecutor.lua`: validation, destructive-action confirmations, pacing, cancellation, and response-state tracking.
- `Core/Database.lua`: incremental search over 500 source rows per update, with accent normalization and predicates applied before pagination. An empty query browses the full collection; there is no discarded-results cap.
- `Core/Catalog.lua`: name/icon API adapters, DB2-backed categories, class/race matching and skill values.
- `UI/`: theme, reusable controls, tooltips, confirmation dialogs, main window, and minimap button. The window lays out a responsive card grid and switches its detail inspector between side and bottom positions. Pages reuse 60 cards.
- `UI/Dashboard.lua`: separate full-width, vertically scrolling landing page with 12 count cards and 16 shortcuts. It has no collection pager or search job; real collection views retain those controls. GM shortcuts use the existing confirmation/executor path.
- `Modules/`: feature metadata that binds navigation areas to verified command/data capabilities.
- `Data/`: generated immutable tables. `BiS.lua` is intentionally empty until reviewed profiles exist.

## Security boundaries

ForeverGM sends the same dot commands a GM could type manually. It cannot grant itself RBAC permissions, query SQL, contact HTTP services, or claim success merely because a message was sent. Input rejects newlines, semicolons, and hyperlink control sequences. Risky actions receive explicit confirmation.

## Search and memory

Data is represented as compact positional arrays except command metadata. Search is incremental to avoid a long UI frame. The initial version packages datasets in one addon for predictable installation. A future packaging optimization can split the largest tables into load-on-demand companion addons without changing the query API.

## Adding BiS profiles

Profiles must identify expansion/build, content phase, PvE/PvP context, class/spec, item IDs, alternatives, and source citations. The module should remain disabled unless every referenced item exists in the generated item set and the profile has been reviewed for this build.
