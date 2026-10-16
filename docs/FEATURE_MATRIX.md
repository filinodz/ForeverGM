# Feature matrix

| Area | Status | Verification / limitation |
|---|---|---|
| Addon load target | Implemented; static verified | Interface 16001; in-game confirmation still required |
| Main window | Implemented | Responsive icon grid; side/lower inspector switches at 860px content width; movable, resizable, persistent |
| Dashboard | Implemented; mocked runtime verified | 12 illustrated catalog counts, 16 confirmed commands/workflows, responsive grid; no pagination or live-realm claims |
| Minimap launcher | Implemented; mocked runtime verified | Circular eye/key medallion, hover/press feedback, larger hit area; click, right-click settings, drag, persistence, hide option |
| Command explorer | Implemented | 680 source/database command records with RBAC metadata |
| Dynamic command execution | Implemented | Validated free-form arguments, confirmations, rate-limited queue |
| Response tracking | Implemented | Prepared/dispatched/response/failure distinction; no fake success |
| English/French/Spanish | Implemented | English fallback; manual and automatic locale selection |
| Spell browser | Implemented | 32,337 icon records; DB2 class/category filters; 1,388 validated trainer tags, 51 quest tags, 5 Forever racials, 26 internal spells and 2 client-present core debug spells |
| GM tools | Implemented | 12 icon shortcuts for GM mode, fly, god mode, visibility, GM chat, movement speed and server information; requested state is not reported as confirmed state |
| Skills/languages | Implemented | All 154 client SkillLine rows visible; weapon/armor proficiency icons; selectable all-compatible/weapon/profession bulk preview |
| Mount browser | Implemented | 141 positive SourceSpellID references from Mount.db2; 5 await name resolution; selectable confirmed bulk learning with target protection |
| Browsing | Implemented | Collections open populated; 60 results per page, every matching result remains accessible |
| Item browser | Implemented | 24,335 records; 24,312 offline English names; selected-locale resolution, modern cache loading and native tooltips only for a matching client locale |
| Teleport browser | Implemented | 2,313 `game_tele` destinations |
| Quest browser | Implemented | Add, complete, remove with confirmation on removal |
| Achievement browser | Implemented for populated metadata | 104 named records; grant command |
| NPC browser | Implemented | 69,220 templates; spawn confirmation; full command set in explorer |
| GameObject browser | Implemented | 83,993 templates; spawn confirmation; full command set in explorer |
| Account/character/moderation/server tools | Implemented through registry | Category views use exact ForeverCore command metadata |
| Favorites/recent actions | Implemented | SavedVariables; local convenience history only |
| Bulk cancellation | Implemented | Queue can be cancelled; actions are rate limited |
| Equipment sets | Implemented with explicit availability | 277 client set records; direct T1/T2/T3 and class filters; 18 legacy T1/T2 cards cannot grant missing catalog members |
| BiS candidates | Implemented, partial | 9 sourced PvE Phase-6 role collections; missing recommendations disclosed; exact verified subsets can be granted; no complete-loadout or custom-realm-optimality claim |
| Multilingual game data | Partial; policy enforced | Missing locale names are explicit, not replaced by another language; 154 skills and 13 language lines have complete EN/FR/ES labels; see locale coverage |
| Automatic permission discovery | Not possible in base addon | RBAC labels are build-time metadata; server remains authoritative |
| In-game QA | Not yet claimed | Requires loading the test copy in WowB and exercising controls |
