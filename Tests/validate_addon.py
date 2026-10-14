#!/usr/bin/env python3
"""Static integrity checks for the generated ForeverGM package."""

from __future__ import annotations

import re
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

reference = ROOT / "docs" / "COMMAND_REFERENCE.md"
if not reference.exists() or reference.stat().st_size < 100_000:
    fail("full generated command reference is missing")

print(f"PASS: {len(listed_files)} TOC files, {len(command_names)} commands, all dataset and locale checks passed")
sys.exit(0)
