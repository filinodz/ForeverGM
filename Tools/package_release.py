#!/usr/bin/env python3
"""Create a clean installable archive without git metadata or machine files."""
import hashlib
import re
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSION = re.search(r"^## Version:\s*(.+)$", (ROOT / "ForeverGM.toc").read_text(encoding="utf-8"), re.MULTILINE).group(1).strip()
destination = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT / "dist"
destination.mkdir(parents=True, exist_ok=True)
archive = destination / f"ForeverGM-{VERSION}.zip"
if archive.exists():
    raise SystemExit(f"Archive already exists: {archive}")

directories = ("Core", "UI", "Modules", "Locales", "Data", "Assets", "docs", "Tools", "Tests")
root_files = ("ForeverGM.toc", "README.md", "CHANGELOG.md", "LICENSE", "CREDITS.md")
files = [ROOT / name for name in root_files]
for name in directories:
    files.extend(path for path in (ROOT / name).rglob("*") if path.is_file() and "__pycache__" not in path.parts and path.suffix not in (".pyc", ".pyo", ".log"))
with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as package:
    for file in sorted(set(files)):
        # Stable timestamps/permissions make the archive independent of checkout mtimes.
        entry = zipfile.ZipInfo("ForeverGM/" + file.relative_to(ROOT).as_posix(), date_time=(2026, 1, 1, 0, 0, 0))
        entry.create_system = 3
        entry.external_attr = 0o100644 << 16
        entry.compress_type = zipfile.ZIP_DEFLATED
        package.writestr(entry, file.read_bytes(), compresslevel=9)
checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
(destination / f"ForeverGM-{VERSION}.sha256.txt").write_text(f"{checksum} *{archive.name}\n", encoding="ascii")
print(f"Packaged {len(files)} files: {archive.name} ({archive.stat().st_size:,} bytes)")
print(f"SHA256 {checksum}")
