#!/usr/bin/env python3
"""
sort_wallpapers_by_colour.py

Sorts wallpapers into subfolders based on their dominant colour.
Uses pixel counting — resizes image to 100x100 and counts pixels per category.
Requires: pip install Pillow

Usage:
    python sort_wallpapers_by_colour.py /path/to/wallpapers
    python sort_wallpapers_by_colour.py /path/to/wallpapers --copy    # copy instead of move
    python sort_wallpapers_by_colour.py /path/to/wallpapers --dry-run # preview only
"""

import argparse
import colorsys
import shutil
from pathlib import Path
from multiprocessing import Pool, cpu_count
from collections import Counter

from PIL import Image

SUPPORTED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".gif", ".tiff"}

# Resize to this before counting — bigger = more accurate but slower
SAMPLE_SIZE = 300


def rgb_to_colour_name(r: int, g: int, b: int) -> str:
    """Map an RGB value to a colour category."""
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    hue = h * 360

    if v < 0.10:
        return "black"
    if s < 0.12 and v > 0.80:
        return "white"
    if s < 0.18:
        return "grey"

    chromatic_buckets = [
        ("red",    [(345, 360), (0, 15)],  0.25, 0.15),
        ("orange", [(15,  45)],            0.25, 0.15),
        ("yellow", [(45,  70)],            0.25, 0.15),
        ("green",  [(70,  165)],           0.20, 0.10),
        ("cyan",   [(165, 200)],           0.20, 0.10),
        ("blue",   [(200, 265)],           0.20, 0.10),
        ("purple", [(265, 310)],           0.20, 0.10),
        ("pink",   [(310, 345)],           0.20, 0.10),
    ]

    for name, hue_ranges, min_s, min_v in chromatic_buckets:
        for h_min, h_max in hue_ranges:
            if h_min <= hue < h_max and s >= min_s and v >= min_v:
                return name

    return "other"


def classify_image(img_path: Path) -> tuple[Path, str, str | None]:
    """Classify image by counting pixels per color category."""
    try:
        with Image.open(img_path) as img:
            img = img.convert("RGB")
            img = img.resize((SAMPLE_SIZE, SAMPLE_SIZE), Image.LANCZOS)
            pixels = list(img.getdata())

        votes = Counter()
        for r, g, b in pixels:
            colour = rgb_to_colour_name(r, g, b)
            votes[colour] += 1

        # Remove "other" from voting — let the second most common win instead
        votes.pop("other", None)

        if not votes:
            return img_path, "other", None

        winner = votes.most_common(1)[0][0]
        return img_path, winner, None

    except Exception as e:
        return img_path, "skip", str(e)


def sort_wallpapers(folder: Path, copy: bool = False, dry_run: bool = False, workers: int = cpu_count()) -> None:
    images = [
        f for f in folder.iterdir()
        if f.is_file() and f.suffix.lower() in SUPPORTED_EXTENSIONS
    ]

    if not images:
        print("No supported image files found in the specified folder.")
        return

    print(f"Found {len(images)} image(s) — using {workers} workers. {'DRY RUN — ' if dry_run else ''}{'Copying' if copy else 'Moving'} into colour subfolders...\n")

    with Pool(processes=workers) as pool:
        results = pool.map(classify_image, sorted(images))

    counts: dict[str, int] = {}

    for img_path, colour, error in results:
        if colour == "skip":
            print(f"  [SKIP] {img_path.name} — {error}")
            continue

        dest_dir = folder / colour
        dest_path = dest_dir / img_path.name

        print(f"  {img_path.name:50s}  →  {colour}/")

        if not dry_run:
            dest_dir.mkdir(exist_ok=True)
            if copy:
                shutil.copy2(img_path, dest_path)
            else:
                shutil.move(str(img_path), dest_path)

        counts[colour] = counts.get(colour, 0) + 1

    print("\n── Summary ──────────────────────────────────────────")
    for colour, count in sorted(counts.items()):
        marker = " ⚠️" if colour == "other" else ""
        print(f"  {colour:<12} {count} file(s){marker}")
    print(f"\nTotal: {sum(counts.values())} file(s) processed.")
    if dry_run:
        print("(Dry run — no files were moved or copied.)")
    if "other" in counts:
        print(f"\n⚠️  {counts['other']} file(s) landed in 'other'.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Sort wallpapers into colour-named subfolders."
    )
    parser.add_argument("folder", type=Path, help="Path to your wallpapers folder")
    parser.add_argument("--copy", action="store_true", help="Copy instead of move")
    parser.add_argument("--dry-run", action="store_true", help="Preview only")
    parser.add_argument("--workers", type=int, default=cpu_count(), help=f"Parallel workers (default: {cpu_count()})")
    args = parser.parse_args()

    if not args.folder.is_dir():
        print(f"Error: '{args.folder}' is not a valid directory.")
        raise SystemExit(1)

    sort_wallpapers(args.folder, copy=args.copy, dry_run=args.dry_run, workers=args.workers)


if __name__ == "__main__":
    main()
