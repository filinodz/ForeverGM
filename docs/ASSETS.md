# Asset notes

## Minimap medallion, 0.11.0

`Assets/ForeverGM-Minimap-source-v2.png` is the original transparent raster redesign made with the built-in image generation tool. It uses the original ForeverGM emblem as a reference/edit target while simplifying its silhouette for a small minimap button. No Blizzard or reference-addon texture is redistributed.

The in-game texture is `Assets/ForeverGM-Minimap-v2.tga`: 128 × 128, uncompressed 32-bit BGRA, top-left origin with 8-bit alpha. The main launcher displays it at 34px inside a 38px clickable button (36px on hover, 30px when pressed). The dashboard reuses it at 76px. The old header emblem remains unchanged.

To reproduce the texture conversion without regenerating artwork:

```sh
python Tools/prepare_assets.py Assets/ForeverGM-Minimap-source-v2.png --minimap-only
```

### Final generation prompt

> Use case: stylized-concept. Asset type: original fantasy game minimap UI icon, single square transparent PNG. Input image is the existing ForeverGM emblem to redesign for readability, not a logo to copy unchanged. Create a simplified circular gold and deep teal medallion with one large luminous amber all-seeing eye and a bold short gold key below it. Preserve the original gold/teal, eye/key identity but remove the tall crown, spikes, tiny filigree and runic dots. Very strong silhouette, thick polished gold rim, dark navy inner disc, restrained teal accents. Face-on, centered, fills 90% of the square, no perspective, crisp bold shapes recognizable at 32 pixels. Genuine transparent background outside the circle, no ambient shadow outside the rim. No text, no letters, no watermark, no grid, no extra variants. This is the actual game icon asset, not a screenshot or mockup.

The source image was visually inspected. Static checks verify the TGA dimensions, format and transparent/nontransparent pixels. Actual rendering on the WoW client remains an in-game QA step.

## Dashboard icons

Collection cards resolve the existing client icons through `Catalog.sectionIcons`; Quest uses the client-verified FileDataID 134939. GM shortcuts use the same verified command/icon definitions as the GM tools collection. No online-player, current spawn or live GM-state count is fabricated.
