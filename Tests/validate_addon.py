#!/usr/bin/env python3
"""Static integrity checks for the generated ForeverGM package."""

from __future__ import annotations

import re
import json
import struct
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


toc = ROOT / "ForeverGM.toc"
if not toc.exists():
    fail("ForeverGM.toc is missing")

toc_text = toc.read_text(encoding="utf-8")
interface = re.search(r"^## Interface:\s*(\d+)", toc_text, re.MULTILINE)
if not interface or interface.group(1) != "16001":
    fail("TOC interface is not the verified 16001")
version = re.search(r"^## Version:\s*(\S+)", toc_text, re.MULTILINE)
init_text = (ROOT / "Core" / "Init.lua").read_text(encoding="utf-8")
if not version or f'FGM.version = "{version.group(1)}"' not in init_text:
    fail("TOC and runtime versions differ")
asset = ROOT / "Assets" / "ForeverGM-Minimap-v2.tga"
if not asset.exists():
    fail("Minimap medallion asset is missing")
asset_bytes = asset.read_bytes()
header = struct.unpack("<BBBHHBHHHHBB", asset_bytes[:18])
if header[2] != 2 or header[8:12] != (128, 128, 32, 0x28) or len(asset_bytes) != 18 + 128 * 128 * 4:
    fail("Minimap asset is not the expected alpha-enabled 128px TGA")
if not any(alpha == 0 for alpha in asset_bytes[21::4]) or not any(alpha > 0 for alpha in asset_bytes[21::4]):
    fail("Minimap asset lacks transparent/visible pixels")

listed_files: list[str] = []
for line in toc_text.splitlines():
    line = line.strip()
    if line and not line.startswith("##"):
        listed_files.append(line)
        if not (ROOT / Path(line.replace("\\", "/"))).exists():
            fail(f"TOC references missing file: {line}")

commands = (ROOT / "Data" / "Commands.lua").read_text(encoding="utf-8")
command_names = re.findall(r'\bname="((?:\\.|[^"])*)"', commands)
command_ids = re.findall(r'\bid="((?:\\.|[^"])*)"', commands)
if len(command_names) < 600:
    fail(f"only {len(command_names)} commands generated")
if len(command_ids) != len(set(command_ids)):
    fail("duplicate generated command IDs")
if "verification=" not in commands or "permissionId=" not in commands:
    fail("command provenance or permissions are missing")

expected_data = {
    "Spells.lua": 30000,
    "Items.lua": 15000,
    "Teleports.lua": 2000,
    "Quests.lua": 40000,
    "Creatures.lua": 60000,
    "GameObjects.lua": 70000,
}
for filename, minimum in expected_data.items():
    text = (ROOT / "Data" / filename).read_text(encoding="utf-8")
    rows = sum(1 for line in text.splitlines() if line.startswith("  {"))
    if rows < minimum:
        fail(f"{filename} contains only {rows} rows; expected at least {minimum}")

locale_files = [ROOT / "Locales" / name for name in ("enUS.lua", "frFR.lua", "esES.lua")]
key_sets = []
for path in locale_files:
    text = path.read_text(encoding="utf-8")
    key_sets.append(set(re.findall(r"\b([A-Z][A-Z0-9_]+)\s*=", text)))
missing_fr = key_sets[0] - key_sets[1]
missing_es = key_sets[0] - key_sets[2]
if missing_fr or missing_es:
    fail(f"locale keys missing; fr={sorted(missing_fr)}, es={sorted(missing_es)}")

coverage = json.loads((ROOT / 'docs' / 'LOCALE_COVERAGE.json').read_text(encoding='utf-8'))
item_text = (ROOT / 'Data' / 'Items.lua').read_text(encoding='utf-8')
item_ids = re.findall(r'^  \{(\d+),', item_text, re.MULTILINE)
if len(item_ids) != len(set(item_ids)) or len(item_ids) != coverage['items']:
    fail('item identity/count mismatch with coverage report')
mount_text = (ROOT / 'Data' / 'Mounts.lua').read_text(encoding='utf-8')
mount_ids = re.findall(r'^  \{(\d+),', mount_text, re.MULTILINE)
if len(mount_ids) != len(set(mount_ids)) or len(mount_ids) != coverage['mounts']:
    fail('mount identity/count mismatch with coverage report')
skill_ids = set(re.findall(r'^  \{(\d+),', (ROOT/'Data'/'Skills.lua').read_text(encoding='utf-8'), re.MULTILINE))
skills = json.loads((ROOT/'Tools'/'SkillTranslations.json').read_text(encoding='utf-8'))
if skill_ids-set(skills) or any(len(skills[i]) != 2 or not all(skills[i]) for i in skill_ids):
    fail('English/Spanish skill translations are incomplete')
bis = json.loads((ROOT/'docs'/'BIS_COVERAGE.json').read_text(encoding='utf-8'))
if len(bis) != 9 or len({profile['classID'] for profile in bis}) != 9:
    fail('Phase-6 candidate class coverage mismatch')
for profile in bis:
    if not profile['source'].startswith('https://www.icy-veins.com/wow-classic/') or not profile['availableIDs']:
        fail('missing BiS source or validated candidates')
    if any(str(i) not in set(item_ids) for i in profile['availableIDs']):
        fail('BiS candidate references an unavailable item')

reference = ROOT / "docs" / "COMMAND_REFERENCE.md"
if not reference.exists() or reference.stat().st_size < 100_000:
    fail("full generated command reference is missing")

print(f"PASS: {len(listed_files)} TOC files, {len(command_names)} commands, all dataset and locale checks passed")
sys.exit(0)
