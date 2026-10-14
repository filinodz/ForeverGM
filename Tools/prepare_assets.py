#!/usr/bin/env python3
"""Convert a generated RGBA PNG into power-of-two, WoW-compatible TGA assets."""

from __future__ import annotations

import struct
import sys
import zlib
from pathlib import Path


def paeth(a: int, b: int, c: int) -> int:
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    return a if pa <= pb and pa <= pc else (b if pb <= pc else c)


def read_png(path: Path) -> tuple[int, int, bytes]:
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("Not a PNG file")
    pos, compressed = 8, bytearray()
    width = height = color = None
    while pos < len(data):
        size = struct.unpack(">I", data[pos : pos + 4])[0]
        kind = data[pos + 4 : pos + 8]
        payload = data[pos + 8 : pos + 8 + size]
        pos += 12 + size
        if kind == b"IHDR":
            width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
            if depth != 8 or color != 6 or compression or filtering or interlace:
                raise ValueError("Expected a non-interlaced 8-bit RGBA PNG")
        elif kind == b"IDAT":
            compressed.extend(payload)
        elif kind == b"IEND":
            break
    if width is None or height is None:
        raise ValueError("PNG has no IHDR")
    raw = zlib.decompress(bytes(compressed))
    stride, bpp = width * 4, 4
    rows, offset, previous = [], 0, bytearray(stride)
    for _ in range(height):
        filter_type = raw[offset]
        source = raw[offset + 1 : offset + 1 + stride]
        offset += stride + 1
        current = bytearray(stride)
        for x, value in enumerate(source):
            left = current[x - bpp] if x >= bpp else 0
            up = previous[x]
            upper_left = previous[x - bpp] if x >= bpp else 0
            if filter_type == 0: decoded = value
            elif filter_type == 1: decoded = value + left
            elif filter_type == 2: decoded = value + up
            elif filter_type == 3: decoded = value + ((left + up) // 2)
            elif filter_type == 4: decoded = value + paeth(left, up, upper_left)
            else: raise ValueError(f"Unsupported PNG filter {filter_type}")
            current[x] = decoded & 0xFF
        rows.append(bytes(current))
        previous = current
    return width, height, b"".join(rows)


def resize_area(width: int, height: int, rgba: bytes, size: int) -> bytes:
    output = bytearray(size * size * 4)
    for oy in range(size):
        y0, y1 = oy * height // size, max((oy + 1) * height // size, oy * height // size + 1)
        for ox in range(size):
            x0, x1 = ox * width // size, max((ox + 1) * width // size, ox * width // size + 1)
            totals = [0, 0, 0, 0]
            count = (x1 - x0) * (y1 - y0)
            for sy in range(y0, y1):
                row = (sy * width + x0) * 4
                for sx in range(x0, x1):
                    index = row + (sx - x0) * 4
                    for channel in range(4): totals[channel] += rgba[index + channel]
            dest = (oy * size + ox) * 4
            for channel in range(4): output[dest + channel] = totals[channel] // count
    return bytes(output)


def write_tga(path: Path, size: int, rgba: bytes) -> None:
    # Uncompressed true-color TGA, 32-bit BGRA, top-left origin, 8-bit alpha.
    header = struct.pack("<BBBHHBHHHHBB", 0, 0, 2, 0, 0, 0, 0, 0, size, size, 32, 0x28)
    bgra = bytearray(len(rgba))
    for index in range(0, len(rgba), 4):
        bgra[index : index + 4] = bytes((rgba[index + 2], rgba[index + 1], rgba[index], rgba[index + 3]))
    path.write_bytes(header + bgra)


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: prepare_assets.py <source.png>")
    source = Path(sys.argv[1]).resolve()
    assets = Path(__file__).resolve().parents[1] / "Assets"
    assets.mkdir(parents=True, exist_ok=True)
    width, height, rgba = read_png(source)
    for size, name in ((128, "ForeverGM-Emblem.tga"), (64, "ForeverGM-Minimap.tga")):
        write_tga(assets / name, size, resize_area(width, height, rgba, size))
    print(f"Prepared 128px and 64px TGA assets from {source.name}")


if __name__ == "__main__":
    main()
