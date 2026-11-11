#!/usr/bin/env python3
"""Find Swift string literals that look like localization keys but are absent."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "AeroCloud" / "Resources" / "Localizable.xcstrings"

# SF Symbols and other intentionally non-localized dotted strings used in code.
IGNORED = {
    "person.crop.circle.fill",
    "person.crop.circle",
    "books.vertical.fill",
    "books.vertical",
    "moon.stars.fill",
    "cloud.rain.fill",
    "arrow.down.circle",
    "square.and.arrow.up",
    "exclamationmark.triangle.fill",
    "antenna.radiowaves.left.and.right",
    "play.rectangle.fill",
    "music.note.list",
    "apple.logo",
    "backward.fill",
    "bolt.fill",
    "chevron.down",
    "chevron.right",
    "cloud.fill",
    "forward.fill",
    "heart.fill",
    "house.fill",
    "list.bullet",
    "moon.fill",
    "pause.fill",
    "play.fill",
    "sunrise.fill",
    # Matched-geometry identifiers are namespace keys, not UI copy.
    "player.artwork",
    "tab.selection",
}

KEY_RE = re.compile(r"^[a-z][a-zA-Z0-9]*(?:\.[a-zA-Z0-9]+)+$")
STRING_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')


def main() -> int:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    known = set(catalog["strings"])
    missing: dict[str, list[str]] = {}

    for path in ROOT.rglob("*.swift"):
        for line_number, line in enumerate(
            path.read_text(encoding="utf-8").splitlines(), start=1
        ):
            for match in STRING_RE.finditer(line):
                value = match.group(1)
                if not KEY_RE.fullmatch(value):
                    continue
                if value in known or value in IGNORED:
                    continue
                location = f"{path.relative_to(ROOT)}:{line_number}"
                missing.setdefault(value, []).append(location)

    if missing:
        print("Dotted Swift literals not found in Localizable.xcstrings:")
        for value, locations in sorted(missing.items()):
            print(f"  {value} -> {', '.join(locations[:5])}")
        return 1

    print("All localization-like literals are present in Localizable.xcstrings")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
