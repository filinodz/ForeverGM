# Localization policy and coverage — 0.12.0

The selected addon language is authoritative for its interface and catalog labels. Windows language does not control these strings. Auto follows `GetLocale()`; `enUs`, `ENUS` and `enGB` resolve to `enUS`, while `esMX` uses `esES`. Reload after changing the setting to recreate labels already on screen.

## Resolution rules

1. Use an available record in the selected-language catalog. English item aliases are English records, not the French base name.
2. Use native item/spell APIs only when the client locale matches the selected addon locale. `C_Item.GetItemInfo` is supported even without the legacy global function.
3. Request missing item data once per session and refresh visible labels on `ITEM_DATA_LOAD_RESULT` / `GET_ITEM_INFO_RECEIVED`. Do not overwrite a quantity the user is typing.
4. If no matching name is available, display a translated missing-translation label with the ID. Never silently substitute another language.

The English base names of quests, NPCs, objects and achievement records remain English data. French spell/skill names remain French data. The offline import adds locale-specific names from the matching local SQL snapshot. The full client tooltip can only use the client locale; when it differs from the addon setting, show a localized summary rather than a wrong-language tooltip. Teleport destination tokens and command syntax are server identifiers and must not be translated. Server responses are controlled by the server.

## Measured offline names

| Catalog | English | French | Spanish |
| --- | ---: | ---: | ---: |
| Items | 24,312 / 24,335 | 24,243 / 24,335 | 561 / 24,335 |
| Skill lines | 154 / 154 | 154 / 154 | 154 / 154 |
| Language skill lines | 13 / 13 | 13 / 13 | 13 / 13 |

Matching-language native APIs can supply names beyond these offline counts, especially spells and uncached items. Names in locale-tagged source records are used as provided; not every proper name is linguistically different in each locale. This is not a claim that language detection can certify every custom proper noun.

The complete generated counts are in [LOCALE_COVERAGE.json](LOCALE_COVERAGE.json). **A 100% multilingual game-data translation is not yet achieved.** In particular, the local Spanish item/spell exports are incomplete. Accurate completion needs matching-build `ItemSparse`, `SpellName`, `SkillLine`, `ItemSet` and `Mount` locale exports, plus any custom server translations. Names are not guessed or automatically machine-translated into purported official item identities.

## Maintaining imports

`Tools/refresh_collections.py` accepts `--config <local worldserver.conf> --dbc <matching extracted frFR directory>`. It performs read-only queries, obtains credentials only in memory and never embeds them in generated files. Generated writes are staged until all queries/checks complete. `--cached --dbc <directory>` reuses the previously imported name tables without a running database. Review the coverage reports before publishing.

`Tools/SkillTranslations.json` contains reviewed English/Spanish interface labels for the exact 154 client skill IDs. Locale-tagged NPC/quest/object/achievement names come from the matching local core's locale tables. Custom unverified names remain explicit gaps.

## Equipment availability

The original T1/T2 sets are present in ItemSet.db2, but their member item IDs are absent from the inspected item metadata. Their 18 cards remain visible with an unavailable explanation and no grant action. T3 member previews and grants use verified catalog items. No missing item is inserted solely to make a set look complete.

The 9 Phase-6 BiS entries are **source-candidate collections**, with unresolved recommendations counted and excluded from grants. They are not complete optimized outfits. See [BIS_COVERAGE.json](BIS_COVERAGE.json) for every source URL, included item ID and unresolved recommendation.

## Client observation

The executable inspected on 2026-10-16 reports build **1.60.1.70374**. The previous verified file version was 70338. The addon still targets Interface 16001. Mocked tests are not a claim of live-client command execution or visual QA on either build. Chat transport remains the 0.11.1 implementation in this translation/collection update.
