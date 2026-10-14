# Feature matrix

| Area | Status | Verification / limitation |
|---|---|---|
| Addon load target | Implemented; static verified | Interface 16001; in-game confirmation still required |
| Main window | Implemented | Responsive icon grid; side/lower inspector switches at 860px content width; movable, resizable, persistent |
| Minimap launcher | Implemented | Click, right-click settings, drag, persistence, hide option |
| Command explorer | Implemented | 680 source/database command records with RBAC metadata |
| Dynamic command execution | Implemented | Validated free-form arguments, confirmations, rate-limited queue |
| Response tracking | Implemented | Prepared/dispatched/response/failure distinction; no fake success |
| English/French/Spanish | Implemented | English fallback; manual and automatic locale selection |
| Spell browser | Implemented | 32,337 icon records; DB2 class/category filters; 1,388 validated trainer tags, 51 quest tags, 5 Forever racials, 26 internal spells and 2 client-present core debug spells |
| GM tools | Implemented | 12 icon shortcuts for GM mode, fly, god mode, visibility, GM chat, movement speed and server information; requested state is not reported as confirmed state |
| Skills/languages | Implemented | All 154 client SkillLine rows visible; weapon/armor proficiency icons; selectable all-compatible/weapon/profession bulk preview |
| Mount browser | Implemented | 136 SourceSpellID records extracted from Mount.db2 and validated against local SpellName |
| Browsing | Implemented | Collections open populated; 60 results per page, every matching result remains accessible |
| Item browser | Implemented | 24,288 records; 4,479 recovered names and 23,705 English aliases verified against local IDs; add item and native tooltip preview |
| Teleport browser | Implemented | 2,313 `game_tele` destinations |
| Quest browser | Implemented | Add, complete, remove with confirmation on removal |
| Achievement browser | Implemented for populated metadata | 104 named records; grant command |
| NPC browser | Implemented | 69,220 templates; spawn confirmation; full command set in explorer |
| GameObject browser | Implemented | 83,993 templates; spawn confirmation; full command set in explorer |
| Account/character/moderation/server tools | Implemented through registry | Category views use exact ForeverCore command metadata |
| Favorites/recent actions | Implemented | SavedVariables; local convenience history only |
| Bulk cancellation | Implemented | Queue can be cancelled; actions are rate limited |
| Equipment sets | Implemented | 198 client-validated sets; complete local DB2 member list shown before giving the set through the verified command |
| BiS rankings | Not supplied | Equipment collections do not assert optimal class/spec gearing |
| Automatic permission discovery | Not possible in base addon | RBAC labels are build-time metadata; server remains authoritative |
| In-game QA | Not yet claimed | Requires loading the test copy in WowB and exercising controls |
