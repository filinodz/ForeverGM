<p align="center">
  <img src="Assets/ForeverGM-Emblem-source.png" alt="ForeverGM emblem" width="160">
</p>

<h1 align="center">ForeverGM</h1>
<p align="center">An icon-driven Game Master toolkit for WoWForever.</p>
<p align="center">
  <a href="https://github.com/filinodz/ForeverGM/releases/latest"><img src="https://img.shields.io/github/v/release/filinodz/ForeverGM" alt="Latest release"></a>
  <a href="https://github.com/filinodz/ForeverGM/actions/workflows/validate.yml"><img src="https://github.com/filinodz/ForeverGM/actions/workflows/validate.yml/badge.svg" alt="Validation"></a>
  <img src="https://img.shields.io/badge/interface-16001-gold" alt="Interface 16001">
  <a href="LICENSE"><img src="https://img.shields.io/badge/code_license-MIT-blue" alt="Code license MIT"></a>
</p>

ForeverGM brings searchable game data, illustrated collections, skill management and server commands into one resizable in-game panel. Browse immediately, inspect an entry, then choose the action you need. No external application or database connection is required while playing.

**[Download the latest release](https://github.com/filinodz/ForeverGM/releases/latest)** · [Changelog](CHANGELOG.md) · [Command reference](docs/COMMAND_REFERENCE.md) · [Report an issue](https://github.com/filinodz/ForeverGM/issues)

## Compatibility

Built for the locally verified **WoWForever Classic beta 1.60.1.70338**, with **Interface 16001**, and its **ForeverCore / TrinityCore-derived server using Vanilla world data converted from VMaNGOS**.

This is not a generic addon for every VMaNGOS server, the original 1.12 client, or official retail WoW. Command syntax, permissions and available IDs may differ on another server. See [compatibility notes](docs/COMPATIBILITY.md).

An authorized GM account is required for privileged actions. ForeverGM does not grant permissions or bypass server-side RBAC.

## Installation

1. Download the versioned `ForeverGM-<version>.zip` asset from the [latest release](https://github.com/filinodz/ForeverGM/releases/latest).
2. Extract the archive into your client's `_classic_beta_/Interface/AddOns/` directory.
3. Check that the final structure is `Interface/AddOns/ForeverGM/ForeverGM.toc` — not a nested `ForeverGM/ForeverGM/` folder.
4. Enable **ForeverGM** on the character-selection AddOns screen.
5. Log in and enter `/fgm`, or click the minimap emblem.

For an update, replace the addon files with the new release, then use `/reload`. Preferences live in the client's SavedVariables, outside the addon folder; replacing addon files does not intentionally reset them. Back up your SavedVariables before major updates.

If you download GitHub's automatic **Source code** archive instead, rename its extracted `ForeverGM-*` folder to `ForeverGM` before installing. The release asset is already packaged with the correct folder name.

## What's inside

Counts below describe the bundled data snapshot, not a guarantee that every record is usable by every character.

| Collection | Entries | Main actions and features |
| --- | ---: | --- |
| Skills | 154 | Proficiency icons; learn verified proficiency spells; set current and maximum values; preview bulk grants |
| Spells | 32,337 | Class/category filters, learn, unlearn and cast; trainer and quest annotations |
| Items | 24,288 | Item icons, quality colors, item levels, slot filters, tooltips and quantity-based grants |
| Equipment sets | 198 | Full verified member lists, class filtering and confirmed set grants |
| NPCs | 69,220 | Name/ID search and confirmed spawning |
| GameObjects | 83,993 | Name/ID search and confirmed spawning |
| Quests | 48,793 | Quest icons, add, complete and remove |
| Teleports | 2,313 | Named destinations with map/coordinates and teleport actions |
| Mounts | 136 | Client-defined mount spells with learn, unlearn and cast actions |
| Languages | 13 | Individual learning and a confirmed learn-all action |
| Achievements | 104 | Named available records and grant actions |
| Commands | 680 | Searchable syntax, help, permission metadata and source provenance |
| GM tools | 12 | Illustrated shortcuts for common GM, flight, visibility, chat, god-mode, speed and server-info commands |

### A responsive, icon-first interface

- Movable, resizable window with saved position, dimensions and scale.
- Responsive collection grid: a side inspector on wide windows and a lower inspector on compact windows.
- The new landing dashboard has 12 illustrated catalog-count cards and 16 essential shortcuts, without search filters, an empty inspector or pagination.
- Click a statistics card to browse its collection. Counts come from the bundled data snapshot, not live realm activity.
- Collections populate on opening; no initial search is required.
- Name/ID search, accent-insensitive matching, category filters and favorites filtering.
- Paginated results: 60 cards per page, with all matching entries accessible.
- Native item/spell tooltips where supported by the client.
- Redesigned circular gold/teal minimap medallion, with a larger readable eye/key symbol, hover and pressed feedback. Left-click opens the panel; right-click opens settings; dragging saves its position.
- English, French and Spanish interface localization, with automatic locale selection and an `esMX` alias.

### Skills: weapons, armor, professions and more

Browse one-handed and two-handed swords, axes and maces; staves, daggers, bows, guns, crossbows, wands; armor proficiencies, professions, secondary skills, languages and riding. The catalog also exposes class/internal skill records for inspection.

The Skills toolbar offers **Give all skills**, **Give weapon skills** and **Give professions**. Each opens a selectable preview for the current player target, or your own character when no player is selected. The preview applies known race, class and level rules and excludes internal, pet, test and inappropriate class lines. Learning and maximizing are separate choices.

Bulk grants learn verified proficiency spells where needed, then set the selected skill lines. A captured player GUID protects the queue: changing targets cancels it. An NPC target is rejected. This does **not** teach every profession recipe or indiscriminately grant incompatible skills.

### Spells by class and purpose

Filter the nine supported classes and categories including class spells, professions, passive spells, mounts, companions, languages, internal records, GM/debug spells and Forever racial spells.

The snapshot contains **1,388 trainer annotations**, **51 quest-spell annotations**, **5 distinct Forever racial spells**, **26 internal spells** and **2 client-present core debug spells**. Trainer/quest labels provide context; they do not independently prove that every live NPC or prerequisite matches that annotation.

**Learn my class spells** confirms and sends `.learn my trainer`. This is a **self** action: the server chooses the compatible spells for your own class, regardless of your selected target.

### Items and equipment sets

Inspect an item, enter a positive quantity, then grant it through the server command. Sets show the complete client-verified membership before sending `.additem set <ID>` with confirmation. Items are placed in bags; sets are not automatically equipped.

The “Equipment sets” section is a catalog of verified sets, not a best-in-slot ranking or automated gear optimizer.

### Commands and operational safeguards

The command explorer includes account, character, moderation, server and debug categories. Its records combine command registrations, available database help and RBAC metadata from the matching core. Review the syntax and arguments before executing.

Isolated commands are sent immediately from their button or confirmation click through the normal WoW chat API, as a whisper to your own character. The matching ForeverCore parser handles dot commands before ordinary chat routing. The addon echoes `Sent to chat: .command` locally; it does not wait for a server acknowledgement before sending another operation. Only rapid clicks and bulk operations need the rate-limited queue (default 0.45 seconds between commands). Confirmation dialogs, queue cancellation and target-change protection remain in place. These protections do not replace server permissions, backups or careful GM judgment.

The status display distinguishes preparation, sending, observed server responses and detected failures. **Sending a command does not prove server-side success.** Response observation is optional, expires after eight seconds and never leaves a command waiting or triggers an automatic retry. Unstructured system messages are correlated heuristically; always check the actual result, especially for destructive or administrative actions.

## Quick start

### Use the dashboard

Enter `/fgm` after loading the addon to see the dashboard. Its 12 icon cards show the exact bundled counts for items, spells, quests, NPCs, GameObjects, skills, equipment sets, mounts, teleports, languages, achievements and commands. Click any card to enter that collection; collection pagination remains available there, not on the dashboard.

The essential-tools grid contains 12 explicit GM commands (enable/disable GM mode, flight, god mode, visibility and GM chat, plus normal speed and server information), each with a review/confirmation step. Four additional shortcuts open weapon-skill and profession previews, the self-only class-learning confirmation, and settings. No action tile claims to know the current server-side on/off state.

At narrower widths the cards form fewer columns; the dashboard scrolls vertically to keep every tile accessible. The top banner shows the current player target and client compatibility information.

### Give compatible weapon skills

1. Select the player who should receive the skills, or clear your target to work on yourself.
2. Open `/fgm` → **Skills** → **Give weapon skills**.
3. Review the target name and checked entries. Choose whether to maximize values.
4. Confirm the grant and keep the same target until the queue finishes.
5. Use **Cancel queue** or `/fgm cancel` to stop pending commands.

### Find and learn a spell

Open **Spells**, choose a class or category, then search by name or numeric ID. Select a card, inspect its details and choose **Learn**, **Unlearn** or **Cast** as appropriate. For the self-only trainer workflow, use **Learn my class spells**.

### Give an item or set

Open **Items**, search by name or ID, select the item and enter the quantity requested by the action. For sets, open **Equipment sets**, review every member in the inspector, then confirm **Give Set**.

### Manage a quest

Open **Quests**, search by name or ID, select its illustrated card and choose the needed action. Complete/remove actions ask for confirmation. Server eligibility and command rules still apply.

### Run a server command

Open **Commands**, search for the operation, review its permission and syntax, fill the argument field and execute. Prefer documented, matching-core commands; unsupported arguments or insufficient permissions are reported by the server.

## Slash commands and settings

| Command | Result |
| --- | --- |
| `/fgm` or `/forevergm` | Toggle the main window |
| `/fgm config` | Open settings |
| `/fgm cancel` | Cancel pending queued commands |
| `/fgm <search text>` | Open the command explorer with that search |

Settings let you select the interface language, toggle the minimap launcher, reset the window and choose a UI scale. Use `/reload` after changing the language.

Favorites, preferences and local recent-action records are saved in `ForeverGMDB`. Local history is not an authoritative server audit log. Do not submit SavedVariables or command histories publicly without reviewing them for sensitive information.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Addon is absent from the list | Verify the exact folder structure and that `ForeverGM.toc` exists directly inside `ForeverGM` |
| “Out of date” warning | Confirm you are using the supported WoWForever client; do not assume another client is compatible |
| A command fails or does nothing | Check target, arguments, server RBAC and the server response; the panel cannot bypass these |
| An icon is missing | Confirm the client build and reload; many icons use client-specific numeric FileDataIDs |
| Window is misplaced or too large | Open `/fgm config`, reset the window and adjust scale |
| Language did not change | Use `/reload` after selecting it in settings |
| A catalog record is unavailable in-game | Internal/test records and server-specific conditions may prevent using otherwise valid IDs |

For a bug report, include addon version, client build, the affected section/ID, reproducible steps and a sanitized Lua error if available. Do not post passwords, account details or private server configuration.

## Data provenance and scope

Data is generated offline from the local matching ForeverCore sources, world/armory tables and client DB2 files. The user-supplied **NightVibes GM Panel 5.13.0** contributed factual reference IDs/names and labels, which were checked against local records. Its interface code, artwork and server modifications were not copied.

WoWForever-specific racial references are included where locally verified. This is a substantial matched snapshot, **not a claim that every custom WoWForever record or every database on the internet has been incorporated**.

The addon itself makes no HTTP or SQL requests and reads no external files at runtime. Blizzard icons are resolved by the installed client, not shipped as extracted texture packs.

See [data sources](docs/DATA_SOURCES.md), [credits](CREDITS.md), [feature matrix](docs/FEATURE_MATRIX.md) and [architecture](docs/ARCHITECTURE.md).

## Development

```sh
git clone https://github.com/filinodz/ForeverGM.git
cd ForeverGM
python Tests/validate_addon.py
npm install --no-save --package-lock=false luaparse@0.3.1 fengari@0.1.4
node Tests/syntax.js
node --max-old-space-size=4096 Tests/runtime.js
python Tools/package_release.py
```

Python 3.10+ and Node.js are development tools only; players do not need them. The Lua syntax check targets Lua 5.1. Runtime tests execute the actual addon modules against a mocked WoW API using Fengari. They cover browsing, icons, class filters, pagination, resizing, bulk compatibility, confirmations and cancellation. Mocked tests are **not** a substitute for testing the real client renderer and server responses. GitHub Actions runs the same validation stages.

`Tools/package_release.py` produces `dist/ForeverGM-<version>.zip` and a SHA-256 sidecar. Archives contain a single installable `ForeverGM/` root, without Git metadata, SavedVariables or server configuration. Existing archives are not overwritten.

`Tools/generate_data.py` is an offline maintainer tool tied to the documented local repack layout and read-only database queries. It is **not** needed to install the addon and is not a generic database importer. Review and adapt its source paths/connection settings before regenerating another environment. `Tools/inspect_reference.js` parses reference Lua table literals without executing the reference addon.

More verification details: [testing notes](docs/TESTING.md). Asset generation and the minimap design brief are documented in [asset notes](docs/ASSETS.md). Changes should preserve target protections, permission boundaries, locale key coverage and data provenance.

## License and credits

Original ForeverGM runtime code is provided under the [MIT license](LICENSE). Game metadata, trademarks and icon identifiers retain their respective source ownership; the code license does not relicense third-party game assets. See [CREDITS.md](CREDITS.md).

ForeverGM is an independent community project, not affiliated with or endorsed by Blizzard Entertainment.
