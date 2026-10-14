# Data sources and provenance

All generated data comes from this installed ForeverRepack. No retail web dataset was substituted.

| Dataset | Authoritative local source | Generated file | Rows at generation |
|---|---|---|---:|
| Commands/help | ForeverCore `src/server/scripts/Commands/cs_*.cpp` and `world.command` | `Data/Commands.lua` | 680 |
| Permissions/default roles | ForeverCore `RBAC.h`, `auth.rbac_permissions`, `auth.rbac_linked_permissions` | command metadata | merged per command |
| Spells | client-extracted SpellName and SpellMisc + local SkillLineAbility.db2 | `Data/Spells.lua` | 32,337 |
| Skills/languages | `world.forever_armory_source_skill_line`; languages are CategoryID 10 | `Data/Skills.lua`, `Data/Languages.lua` | 154 / 13 |
| Mount learning spells | client Mount.db2 SourceSpellID, validated against SpellName; server faction pairs | `Data/Mounts.lua` | 136 |
| Items | `world.armory_item` plus NightVibes names/aliases validated against local IDs | `Data/Items.lua` | 24,288 |
| Equipment sets | NightVibes labels; full members from local ItemSet.db2 | `Data/ItemSets.lua` | 198 |
| Teleports | `world.game_tele` | `Data/Teleports.lua` | 2,313 |
| Quests | `world.quest_template` | `Data/Quests.lua` | 48,793 |
| Creatures | `world.creature_template` | `Data/Creatures.lua` | 69,220 |
| GameObjects | `world.gameobject_template` | `Data/GameObjects.lua` | 83,993 |
| Achievements | populated rows in `hotfixes.achievement` | `Data/Achievements.lua` | 104 |

The data was generated on 2026-10-14 with `Tools/generate_data.py`. Run that tool while the bundled MySQL server is available to refresh the package after a repack update.

## Known data constraints

- The client extraction tables currently contain localized French names for many records. At runtime, item/spell tooltips use the client API and therefore follow the active client locale when the record is cached.
- Mounts are now extracted from the installed client Mount.db2 rather than limited to the server's faction-conversion table. PlayerConditionID is retained; bulk mount learning is not inferred from that opaque condition.
- Only 104 achievement metadata rows are populated in `hotfixes.achievement`; ForeverGM exposes exactly those rows and does not invent titles for the remaining IDs in `achievement_dbc`.
- No reviewed, phase-specific WoWForever BiS source exists in the workspace. The BiS framework is disabled rather than shipping fabricated recommendations.

## Ecosystem references reviewed

### Vanilla and Forever investigation, 0.10.0

The installed core's README explicitly describes TrinityCore master adapted to Classic beta **with a Vanilla world converted from VMaNGOS**, plus Skyborne/Zephras Isle content. Its Git remote is `https://github.com/advocaite/TrinityCore.git`. VMaNGOS is relevant to world data lineage; the packaged ForeverCore handlers define the actual command grammar.

- VMaNGOS primary repository: <https://github.com/vmangos/core>
- Local fork's public remote: <https://github.com/advocaite/TrinityCore>
- DB2 definitions across builds: <https://github.com/wowdev/WoWDBDefs/blob/master/definitions/SkillLineAbility.dbd>
- Classic client spell API source: <https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpellDocumentation.lua>
- Forever-specific community research: <https://github.com/ClassicWoWCommunity/forever-bugs>

The installed `data/dbc/frFR/SkillLineAbility.db2` layout hash `224F7EA0` is decoded by `Tools/db2_reader.py`, checked against the fork's DB2Metadata.h. The unencrypted and known extracted sections yield 7,834 ability rows. Encrypted sections with unknown TACT keys are skipped. `Mount.db2` layout `E4B71B79` yields 141 mount rows, of which 136 reference a populated local SpellName record. These exact client tables provide build-specific IDs and class/category mappings, including the Forever additions already present in the extraction.

SkillRaceClassInfo rules are copied from the local client-extraction SQL table. In this fork, Availability=1 means a starting skill (`ObjectMgr.cpp`), not an incompatible skill. Bulk eligibility uses matching class/race masks and minimum level, excludes class/pet/internal/test lines, and deduplicates profession names. Weapon/armor learn spells must have SkillLineAbility links and passive/hidden proficiency attributes `0xC0`; this selects Defense 204 rather than Dodge 81 for the Defense skill. Internal SkillLine 183 spells are labeled Internal, while GM/debug spells are taken from `HandleLearnDebugSpellsCommand` and retained only when their ID exists in this client.

Both 32-bit halves of the race mask are retained. ForeverCore's `RaceMask.h` maps High Order Skyborne (race 95) to bit 32 and Windshaper Skyborne (race 96) to bit 33; the bulk skill planner uses these verified mappings rather than assuming race ID minus one for the custom races.

### NightVibesGMPanel reference supplied by the user

Reference folder: `<WoW client>/_classic_beta_/Interface/AddOns/NightVibesGMPanel`, version 5.13.0, interface 16001, authored by NightVibesGM Tools. Its README identifies AnoCore as its target. Its commands therefore require independent verification against this ForeverCore fork.

`Tools/inspect_reference.js` parses Lua literal tables without executing reference code. `Tools/ReferenceData.json` preserves the extracted factual snapshot for reproducible offline generation. No NightVibes UI code, branding or image assets are included in ForeverGM.

- 1,388 trainer spell IDs pass local SpellName existence and available class-mask validation. Required levels are reference annotations, not guaranteed live-server trainer availability.
- 51 quest spell IDs exist locally. Quest associations are reference annotations and have not been independently verified as current server prerequisites.
- 5 distinct racial spell IDs from the Forever races exist in the local client; their reference race associations are retained as annotations.
- 4,479 otherwise unnamed local armory records receive reference names. 23,705 locally existing items receive English search aliases.
- 198 equipment sets pass local ItemSet.db2 identity and complete member-ID checks. Every item the set command can add is taken from the local client member list and appears in the preview. References failing full member validation are excluded.

To refresh the reference snapshot, set `FGM_LUAPARSE` to an installed luaparse module and run `generate_data.py --reference <NightVibesGMPanel directory>`. Normal regeneration reuses the snapshot and revalidates its IDs against the current client/database.

These were used for design comparison only; none of their 3.3.5/4.3.4 command tables or IDs were copied into ForeverGM.

- TrinityCore upstream command registration and chat parsing: <https://github.com/TrinityCore/TrinityCore/tree/master/src/server/scripts/Commands>
- GMGenie (TrinityCore 3.3.5/4.3.4): <https://github.com/chocochaos/GMGenie>
- TrinityAdmin (archived, 3.x/4.x): <https://github.com/superstyro/TrinityAdmin>
- GMPanel (3.3.5a): <https://github.com/Veronica-Vasilieva/GMPanel>

The review reinforced the value of searchable commands, recent/favorite actions, target-aware tools, and confirmation prompts. Their advertised client targets are incompatible with interface 16001, so ForeverGM retains a dependency-free implementation based on the installed client and fork.

## Original artwork

`Assets/ForeverGM-Emblem-source.png` was generated for this project with OpenAI's built-in image generation tool from a dark-iron, antique-gold arcane eye/key/crown crest specification. `Tools/prepare_assets.py` converts it without third-party packages into 128px and 64px uncompressed, alpha-enabled TGA files for WoW. The UI falls back to a verified built-in icon path if the custom texture cannot load.
