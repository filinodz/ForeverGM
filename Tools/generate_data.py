#!/usr/bin/env python3
"""Generate ForeverGM Lua datasets and command documentation from ForeverRepack.

This tool is intentionally offline. The addon never connects to MySQL or reads files.
"""

from __future__ import annotations

import csv
import re
import subprocess
from collections import defaultdict, deque
from pathlib import Path
import sys
import json
import os
sys.path.insert(0, str(Path(__file__).resolve().parent))
from db2_reader import WDC5


ADDON = Path(__file__).resolve().parents[1]
REPACK = ADDON.parent
CORE = REPACK / "packaging" / "ForeverCore-source-1.5.0-20261014-000613"
MYSQL = REPACK / "mysql" / "bin" / "mysql.exe"
COMMAND_SOURCE = CORE / "src" / "server" / "scripts" / "Commands"
RBAC_HEADER = CORE / "src" / "server" / "game" / "Accounts" / "RBAC.h"
REFERENCE = {}

def load_reference() -> None:
    global REFERENCE
    if "--reference" not in sys.argv:
        snapshot = ADDON / "Tools" / "ReferenceData.json"
        if snapshot.exists():
            REFERENCE = json.loads(snapshot.read_text(encoding="utf-8"))
        return
    reference_root = sys.argv[sys.argv.index("--reference") + 1]
    result = subprocess.run(["node", str(ADDON / "Tools" / "inspect_reference.js"), reference_root], capture_output=True, check=True)
    REFERENCE = json.loads(result.stdout.decode("utf-8"))
    (ADDON / "Tools" / "ReferenceData.json").write_text(json.dumps(REFERENCE, ensure_ascii=False, separators=(",",":")), encoding="utf-8")


def query(sql: str) -> list[list[str]]:
    command = [
        str(MYSQL),
        "--protocol=tcp",
        "--host=127.0.0.1",
        "--port=3317",
        "--user=root",
        "--default-character-set=utf8mb4",
        "--batch",
        "--raw",
        "--skip-column-names",
        f"--execute={sql}",
    ]
    result = subprocess.run(command, check=True, capture_output=True)
    text = result.stdout.decode("utf-8", errors="replace")
    return list(csv.reader(text.splitlines(), delimiter="\t"))


def lua_string(value: object) -> str:
    text = "" if value is None else str(value)
    text = text.replace("\\", "\\\\").replace('"', '\\"')
    text = text.replace("\r", "\\r").replace("\n", "\\n")
    return f'"{text}"'


def write_lua(name: str, variable: str, rows: list[str], provenance: str) -> None:
    path = ADDON / "Data" / name
    path.parent.mkdir(parents=True, exist_ok=True)
    content = [
        "-- Generated file. Do not edit by hand.",
        f"-- Source: {provenance}",
        "local ADDON_NAME, FGM = ...",
        "FGM.Data = FGM.Data or {}",
        f"FGM.Data.{variable} = {{",
        *[f"  {row}," for row in rows],
        "}",
        "",
    ]
    path.write_text("\n".join(content), encoding="utf-8", newline="\n")


def matching_brace(text: str, start: int) -> int:
    depth = 0
    in_string = False
    escape = False
    for pos in range(start, len(text)):
        ch = text[pos]
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            continue
        if ch == '"':
            in_string = True
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return pos
    return -1


def split_entries(body: str) -> list[str]:
    entries: list[str] = []
    depth = 0
    start = None
    in_string = False
    escape = False
    for pos, ch in enumerate(body):
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            continue
        if ch == '"':
            in_string = True
        elif ch == "{":
            if depth == 0:
                start = pos
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0 and start is not None:
                entries.append(body[start + 1 : pos])
                start = None
    return entries


def parse_source_commands() -> dict[str, dict[str, object]]:
    commands: dict[str, dict[str, object]] = {}
    table_re = re.compile(r"static\s+ChatCommandTable\s+(\w+)\s*=\s*\{")
    for path in sorted(COMMAND_SOURCE.glob("cs_*.cpp")):
        text = path.read_text(encoding="utf-8", errors="replace")
        tables: dict[str, list[dict[str, str | None]]] = {}
        for match in table_re.finditer(text):
            opening = text.find("{", match.start())
            closing = matching_brace(text, opening)
            if closing < 0:
                continue
            parsed = []
            for entry in split_entries(text[opening + 1 : closing]):
                label_match = re.match(r'\s*"([^"]*)"', entry)
                if not label_match:
                    continue
                permission_match = re.search(r"rbac::(RBAC_PERM_[A-Z0-9_]+)", entry)
                parsed.append({
                    "label": label_match.group(1),
                    "permission": permission_match.group(1) if permission_match else None,
                    "raw": entry,
                })
            tables[match.group(1)] = parsed

        table_names = set(tables)

        def visit(table_name: str, prefix: str, inherited: str | None, seen: set[str]) -> None:
            if table_name in seen:
                return
            for entry in tables.get(table_name, []):
                label = str(entry["label"])
                full = " ".join(part for part in (prefix, label) if part).strip().lower()
                permission = entry["permission"] or inherited
                child = None
                for candidate in table_names:
                    if candidate != table_name and re.search(rf"\b{re.escape(candidate)}\b", str(entry["raw"])):
                        child = candidate
                        break
                if full and (permission or "Handle" in str(entry["raw"])):
                    commands[full] = {
                        "permission_symbol": permission,
                        "source": str(path.relative_to(REPACK)).replace("\\", "/"),
                    }
                if child:
                    visit(child, full, permission, seen | {table_name})

        if "commandTable" in tables:
            visit("commandTable", "", None, set())
    return commands


def parse_rbac_enum() -> dict[str, int]:
    text = RBAC_HEADER.read_text(encoding="utf-8", errors="replace")
    return {
        symbol: int(value)
        for symbol, value in re.findall(r"\b(RBAC_PERM_[A-Z0-9_]+)\s*=\s*(\d+)", text)
    }


def command_category(name: str) -> str:
    first = name.split()[0]
    mapping = {
        "account": "account", "bnetaccount": "account", "battlenetaccount": "account",
        "ban": "moderation", "baninfo": "moderation", "banlist": "moderation",
        "unban": "moderation", "kick": "moderation", "mute": "moderation",
        "unmute": "moderation", "mutehistory": "moderation", "pinfo": "moderation",
        "character": "character", "modify": "character", "reset": "character",
        "levelup": "character", "maxskill": "skills", "setskill": "skills",
        "learn": "spells", "unlearn": "spells", "cast": "spells", "aura": "spells",
        "additem": "items", "additemset": "items", "itemmove": "items",
        "npc": "npc", "creature": "npc", "gobject": "gameobject", "go": "teleport",
        "tele": "teleport", "appear": "teleport", "summon": "teleport",
        "quest": "quests", "achievement": "achievements", "titles": "achievements",
        "server": "server", "reload": "server", "announce": "server", "notify": "server",
        "gm": "gm", "debug": "debug", "cheat": "debug", "lookup": "lookup",
    }
    return mapping.get(first, "other")


def extract_syntax(help_text: str, command_name: str) -> tuple[str, str]:
    clean = help_text.replace("\r", "").strip()
    match = re.search(r"Syntax:\s*([^\n]+)", clean, flags=re.IGNORECASE)
    syntax = match.group(1).strip() if match else f".{command_name}"
    if not syntax.startswith(".") and syntax.lower().startswith(command_name.split()[0]):
        syntax = "." + syntax
    description = re.sub(r"Syntax:\s*[^\n]+", "", clean, count=1, flags=re.IGNORECASE).strip()
    description = re.sub(r"\s+", " ", description)
    return syntax, description


def build_commands() -> list[dict[str, object]]:
    source = parse_source_commands()
    enum = parse_rbac_enum()
    permissions = {
        int(row[0]): row[1] for row in query("SELECT id,name FROM auth.rbac_permissions ORDER BY id")
    }
    links: dict[int, set[int]] = defaultdict(set)
    for parent, child in query("SELECT id,linkedId FROM auth.rbac_linked_permissions"):
        links[int(parent)].add(int(child))

    def role_contains(role_id: int) -> set[int]:
        found: set[int] = set()
        queue = deque([role_id])
        while queue:
            current = queue.popleft()
            for child in links.get(current, set()):
                if child not in found:
                    found.add(child)
                    queue.append(child)
        return found

    role_members = {role: role_contains(role) for role in (199, 198, 197, 196)}

    def role_for(permission_id: int | None) -> str:
        if permission_id is None:
            return "Unresolved"
        for role, label in ((199, "Player"), (198, "Moderator"), (197, "Gamemaster"), (196, "Administrator")):
            if permission_id in role_members[role]:
                return label
        return "Explicit RBAC grant"

    db_help = {
        row[0].lower(): bytes.fromhex(row[1]).decode("utf-8", errors="replace")
        for row in query("SELECT name,HEX(help) FROM world.command ORDER BY name")
        if len(row) >= 2
    }
    names = sorted(set(source) | set(db_help))
    records: list[dict[str, object]] = []
    for name in names:
        src = source.get(name, {})
        symbol = src.get("permission_symbol")
        permission_id = enum.get(str(symbol)) if symbol else None
        if permission_id is None:
            match = next((pid for pid, pname in permissions.items() if pname.lower() == f"command: {name}"), None)
            permission_id = match
        help_text = db_help.get(name, "")
        syntax, description = extract_syntax(help_text, name)
        availability = "available"
        if description.strip().lower() in {"todo", "nyi", "not implemented"}:
            availability = "unsupported"
            description = "ForeverCore registers this command, but the installed command metadata marks it as not implemented."
        elif "not implemented" in description.lower():
            availability = "unsupported"
        if not description:
            description = f"ForeverCore command. Use .help {name} in game for localized argument details."
        records.append({
            "id": re.sub(r"[^a-z0-9]+", "_", name).strip("_"),
            "name": name,
            "syntax": syntax,
            "description": description,
            "category": command_category(name),
            "permission_id": permission_id,
            "permission_name": permissions.get(permission_id, str(symbol or "Unresolved")),
            "role": role_for(permission_id),
            "source": src.get("source", "world.command"),
            "verification": "database+source" if name in source and name in db_help else ("source" if name in source else "database"),
            "availability": availability,
        })
    return records


def generate_commands(records: list[dict[str, object]]) -> None:
    rows = []
    for r in records:
        fields = [
            f"id={lua_string(r['id'])}", f"name={lua_string(r['name'])}",
            f"syntax={lua_string(r['syntax'])}", f"description={lua_string(r['description'])}",
            f"category={lua_string(r['category'])}",
            f"permissionId={r['permission_id'] if r['permission_id'] is not None else 'nil'}",
            f"permission={lua_string(r['permission_name'])}", f"role={lua_string(r['role'])}",
            f"source={lua_string(r['source'])}", f"verification={lua_string(r['verification'])}",
            f"availability={lua_string(r['availability'])}",
        ]
        rows.append("{" + ",".join(fields) + "}")
    write_lua("Commands.lua", "Commands", rows, "ForeverCore command source + world.command + auth RBAC")


def generate_game_data() -> dict[str, int]:
    spells = query("SELECT ID,Name FROM world.forever_armory_source_spell_name WHERE Name<>'' ORDER BY ID")
    client_tables = REPACK / "data" / "dbc" / "frFR"
    ability = list(WDC5(client_tables / "SkillLineAbility.db2", 0x224F7EA0).rows([3, 4, 6, 8]))
    skill_categories = {int(r[0]): int(r[1]) for r in query("SELECT ID,CategoryID FROM world.forever_armory_source_skill_line")}
    spell_icons = {int(r[0]): (int(r[1]), int(r[2])) for r in query("SELECT SpellID,MAX(SpellIconFileDataID),MAX(Attributes1) FROM world.forever_armory_source_spell_misc GROUP BY SpellID")}
    spell_masks, spell_skills = defaultdict(int), defaultdict(set)
    for _, fields in ability:
        skill_id, spell_id, mask = fields[3], fields[4], fields[6]
        spell_masks[spell_id] |= mask & 0x5FF if mask != 0xFFFFFFFF else 0
        spell_skills[spell_id].add(skill_id)
    mount_rows = list(WDC5(client_tables / "Mount.db2", 0xE4B71B79).rows([4, 7, 8]))
    mount_spells = {r[1][7] for r in mount_rows}
    valid_spells = {int(r[0]) for r in spells}
    trainer_masks, quest_masks, racial_ids = defaultdict(int), defaultdict(int), set()
    trainer_levels = defaultdict(dict)
    for class_id, values in REFERENCE.get("trainer", {}).items():
        for pair in values.values():
            spell_id, level = int(pair["1"]), int(pair["2"])
            if spell_id in valid_spells and (not spell_masks[spell_id] or spell_masks[spell_id] & (1 << (int(class_id)-1))):
                trainer_masks[spell_id] |= 1 << (int(class_id)-1)
                trainer_levels[spell_id][int(class_id)] = level
    for class_id, values in REFERENCE.get("quests", {}).items():
        for pair in values.values():
            spell_id = int(pair["id"])
            if spell_id in valid_spells:
                quest_masks[spell_id] |= 1 << (int(class_id)-1)
    for race_id, values in REFERENCE.get("racials", {}).items():
        for pair in values.values():
            if int(pair["id"]) in valid_spells:
                racial_ids.add(int(pair["id"]))
    debug_source = (COMMAND_SOURCE / "cs_learn.cpp").read_text(encoding="utf-8")
    debug_start = debug_source.find("static bool HandleLearnDebugSpellsCommand")
    debug_body = debug_source[debug_start:debug_source.find("static bool", debug_start+15)]
    debug_ids = set(map(int, re.findall(r"LearnSpell\((\d+)", debug_body))) & valid_spells
    enriched_spells = []
    for r in spells:
        spell_id = int(r[0])
        icon, attributes = spell_icons.get(spell_id, (0, 0))
        skills_for_spell = spell_skills[spell_id]
        categories = {skill_categories.get(i) for i in skills_for_spell}
        category = "other"
        if spell_id in debug_ids: category = "gm"
        elif 183 in skills_for_spell: category = "internal"
        elif spell_id in racial_ids: category = "racial"
        elif spell_id in mount_spells or 777 in skills_for_spell: category = "mounts"
        elif 11 in categories: category = "professions"
        elif spell_masks[spell_id]: category = "class"
        elif 10 in categories: category = "languages"
        elif 778 in skills_for_spell: category = "companions"
        elif attributes & 0x40: category = "passive"
        level_fields = ",".join(f"[{c}]={level}" for c,level in sorted(trainer_levels[spell_id].items()))
        enriched_spells.append(f"{{{spell_id},{lua_string(r[1])},{icon},{spell_masks[spell_id]},{lua_string(category)},{lua_string(','.join(map(str, sorted(skills_for_spell))))},{1 if attributes & 0x40 else 0},{trainer_masks[spell_id]},{{{level_fields}}},{quest_masks[spell_id]}}}")
    write_lua("Spells.lua", "Spells", enriched_spells, "client SpellName + SpellMisc + WDC5 SkillLineAbility (layout 224F7EA0); NightVibes class-learning tags validated by local IDs/class masks")

    skills = query("SELECT ID,DisplayName,CategoryID,SpellIconFileID,CanLink FROM world.forever_armory_source_skill_line WHERE DisplayName<>'' ORDER BY ID")
    write_lua("Skills.lua", "Skills", [f"{{{r[0]},{lua_string(r[1])},{r[2]},{r[3]},{r[4]}}}" for r in skills],
              "world.forever_armory_source_skill_line (client extraction)")
    rules = query("SELECT SkillID,ClassMask,RaceMask1,Availability,MinLevel,RaceMask2 FROM world.forever_armory_source_skill_race_class_info ORDER BY ID")
    write_lua("SkillRules.lua", "SkillRules", ["{" + ",".join(r) + "}" for r in rules], "client SkillRaceClassInfo; Availability=1 denotes default starting skill in ForeverCore ObjectMgr")
    # Weapon/armor proficiency passives mapped by client SkillLineAbility.
    spell_names = {int(r[0]): r[1] for r in spells}
    skill_names = {int(r[0]): r[1] for r in skills}
    learn_spells = {}
    for _, fields in ability:
        skill_id, spell_id = fields[3], fields[4]
        if skill_categories.get(skill_id) in (6, 8) and spell_id in spell_names and spell_icons.get(spell_id, (0,0))[1] & 0xC0 == 0xC0:
            learn_spells[skill_id] = min(spell_id, learn_spells.get(skill_id, spell_id))
    write_lua("SkillLearnSpells.lua", "SkillLearnSpells", [f"[{skill}]={spell}" for skill, spell in sorted(learn_spells.items())], "SkillLineAbility links to passive weapon/armor proficiency spells; lowest ID per skill")
    skill_rows = []
    for r in skills:
        skill_id = int(r[0])
        proficiency = learn_spells.get(skill_id)
        resolved_icon = spell_icons.get(proficiency, (int(r[3]),0))[0] if proficiency else int(r[3])
        skill_rows.append(f"{{{r[0]},{lua_string(r[1])},{r[2]},{resolved_icon},{r[4]}}}")
    priority = {6:0,8:1,11:2,9:3,10:4,7:5,12:6}
    skill_rows.sort(key=lambda text: (priority.get(int(text.split(',')[2]),7), int(text[1:text.index(',')]), text))
    write_lua("Skills.lua", "Skills", skill_rows, "client SkillLine with SpellMisc icon of linked weapon/armor proficiency where available")
    languages = [r for r in skills if r[2] == "10"]
    write_lua("Languages.lua", "Languages", [f"{{{r[0]},{lua_string(r[1])},{r[3]}}}" for r in languages],
              "client-extracted SkillLine rows with CategoryID=10")

    faction_pairs = {int(r[0]): int(r[1]) for r in query("SELECT spellId,otherFactionSpellId FROM world.mount_definitions")}
    mounts = [(fields[7], spell_names.get(fields[7], ""), faction_pairs.get(fields[7], 0), spell_icons.get(fields[7], (0,0))[0], fields[4], fields[8]) for _, fields in mount_rows if fields[7] in spell_names]
    write_lua("Mounts.lua", "Mounts", [f"{{{r[0]},{lua_string(r[1])},{r[2]},{r[3]},{r[4]},{r[5]}}}" for r in mounts], "client Mount.db2 (layout E4B71B79); SourceSpellID is the learn mechanism; server faction-pair map")

    item_rows = query("SELECT id,HEX(name),quality,itemLevel,requiredLevel,class,subclass,inventoryType,iconFileDataId FROM world.armory_item ORDER BY id")
    items = []
    alias_count, recovered_count = 0, 0
    for row in item_rows:
        row[1] = bytes.fromhex(row[1]).decode("utf-8")
        reference = REFERENCE.get("items", {}).get(row[0], {})
        alias = reference.get("1", "")
        if not row[1] and alias:
            row[1] = alias
            recovered_count += 1
        if row[1]:
            alias_count += bool(alias)
            items.append([*row, alias])
    write_lua("Items.lua", "Items", ["{" + ",".join([r[0], lua_string(r[1]), *r[2:9], lua_string(r[9])]) + "}" for r in items],
              "world.armory_item generated from the installed client data")
    valid_items = {int(r[0]): r for r in items}
    client_sets = {row_id: {v for v in fields.values() if v} for row_id,fields in WDC5(client_tables / "ItemSet.db2", 0xF79068A4).rows([(4,i) for i in range(17)])}
    sets = []
    for set_id, reference in REFERENCE.get("sets", {}).items():
        set_id = int(set_id)
        members = sorted(map(int, reference["items"].values()))
        if set_id not in client_sets or any(item not in client_sets[set_id] or item not in valid_items for item in members):
            continue
        members = sorted(client_sets[set_id])
        if any(item not in valid_items for item in members):
            continue
        first_icon = next((int(valid_items[item][8]) for item in members if int(valid_items[item][8])>0), 0)
        sets.append((set_id, reference["name"], reference["classes"], members, first_icon))
    write_lua("ItemSets.lua", "ItemSets", [f"{{{r[0]},{lua_string(r[1])},{r[2]},{{{','.join(map(str,r[3]))}}},{r[4]}}}" for r in sorted(sets)], "NightVibes set labels; set IDs/membership verified against client ItemSet.db2 F79068A4 and local item metadata")
    print(f"Reference validation: {sum(bool(v) for v in trainer_masks.values())} trainer spells; {sum(bool(v) for v in quest_masks.values())} quest spells; {len(racial_ids)} racial spells; {recovered_count} recovered item names; {alias_count} English item aliases; {len(debug_ids)} core debug spells; {len(sets)} validated item sets")

    teleports = query("SELECT id,name,map,position_x,position_y,position_z,orientation FROM world.game_tele ORDER BY name")
    write_lua("Teleports.lua", "Teleports", ["{" + ",".join([r[0], lua_string(r[1]), *r[2:]]) + "}" for r in teleports],
              "world.game_tele")

    quests = query("SELECT ID,COALESCE(LogTitle,''),QuestType,QuestSortID,SuggestedGroupNum FROM world.quest_template WHERE LogTitle IS NOT NULL AND LogTitle<>'' ORDER BY ID")
    write_lua("Quests.lua", "Quests", ["{" + ",".join([r[0], lua_string(r[1]), *r[2:]]) + "}" for r in quests],
              "world.quest_template")

    creatures = query("SELECT entry,COALESCE(name,''),COALESCE(subname,''),Classification,type,RequiredExpansion FROM world.creature_template WHERE name IS NOT NULL AND name<>'' ORDER BY entry")
    write_lua("Creatures.lua", "Creatures", ["{" + ",".join([r[0], lua_string(r[1]), lua_string(r[2]), *r[3:]]) + "}" for r in creatures],
              "world.creature_template")

    gameobjects = query("SELECT entry,name,type,displayId FROM world.gameobject_template WHERE name<>'' ORDER BY entry")
    write_lua("GameObjects.lua", "GameObjects", ["{" + ",".join([r[0], lua_string(r[1]), *r[2:]]) + "}" for r in gameobjects],
              "world.gameobject_template")

    achievements = query("SELECT ID,COALESCE(Title,''),COALESCE(Description,''),Points,IconFileID FROM hotfixes.achievement WHERE Title IS NOT NULL AND Title<>'' ORDER BY ID")
    write_lua("Achievements.lua", "Achievements", ["{" + ",".join([r[0], lua_string(r[1]), lua_string(r[2]), *r[3:]]) + "}" for r in achievements],
              "hotfixes.achievement rows present in the installed repack")
    return {
        "spells": len(spells), "skills": len(skills), "languages": len(languages),
        "mounts": len(mounts), "items": len(items), "teleports": len(teleports),
        "quests": len(quests), "creatures": len(creatures), "gameobjects": len(gameobjects),
        "achievements": len(achievements),
        "itemsets": len(sets),
    }


def generate_command_reference(records: list[dict[str, object]]) -> None:
    (ADDON / "docs").mkdir(parents=True, exist_ok=True)
    lines = [
        "# ForeverCore command reference",
        "",
        "Generated from the packaged ForeverCore command registration source, `world.command`, and `auth` RBAC tables.",
        "The role is the lowest default RBAC role that transitively contains the permission. Server-side authorization remains authoritative.",
        "",
        "| Command | Syntax | Permission | Default role | Verification | Availability | Source |",
        "|---|---|---|---|---|---|---|",
    ]
    for r in records:
        def cell(value: object) -> str:
            return str(value).replace("|", "\\|").replace("\n", " ")
        permission = f"{r['permission_id']} — {r['permission_name']}" if r["permission_id"] is not None else str(r["permission_name"])
        lines.append(f"| `.{cell(r['name'])}` | `{cell(r['syntax'])}` | {cell(permission)} | {cell(r['role'])} | {cell(r['verification'])} | {cell(r['availability'])} | `{cell(r['source'])}` |")
    (ADDON / "docs" / "COMMAND_REFERENCE.md").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def main() -> None:
    if not MYSQL.exists() or not CORE.exists():
        raise SystemExit("Run this generator from the ForeverRepack workspace with MySQL and ForeverCore source present.")
    load_reference()
    records = build_commands()
    counts = generate_game_data()
    generate_commands(records)
    generate_command_reference(records)
    print(f"Generated {len(records)} commands; " + ", ".join(f"{v} {k}" for k, v in counts.items()))


if __name__ == "__main__":
    main()
