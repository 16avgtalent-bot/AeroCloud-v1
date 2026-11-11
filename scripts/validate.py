#!/usr/bin/env python3
"""Lightweight repository validation for the Windows dev environment."""

from __future__ import annotations

import json
import plistlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []


def check_json() -> None:
    for path in ROOT.rglob("*.json"):
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except Exception as error:  # noqa: BLE001 - report all
            ERRORS.append(f"JSON {path.relative_to(ROOT)}: {error}")


def check_plists() -> None:
    patterns = ("*.plist", "*.entitlements", "*.xcprivacy")
    for pattern in patterns:
        for path in ROOT.rglob(pattern):
            try:
                plistlib.loads(path.read_bytes())
            except Exception as error:  # noqa: BLE001
                ERRORS.append(f"PLIST {path.relative_to(ROOT)}: {error}")


def check_yaml() -> None:
    try:
        from ruamel.yaml import YAML
    except ImportError:
        try:
            import yaml
        except ImportError:
            print("No YAML parser installed; skipped YAML validation")
            return
        loader = yaml.safe_load
    else:
        loader = YAML(typ="safe").load

    for path in (
        ROOT / "project.yml",
        ROOT / ".github/workflows/ci.yml",
        ROOT / "codemagic.yaml",
    ):
        try:
            with path.open("r", encoding="utf-8") as handle:
                loader(handle)
        except Exception as error:  # noqa: BLE001
            ERRORS.append(f"YAML {path.relative_to(ROOT)}: {error}")


def check_swift_balance() -> None:
    """Cheap brace/paren/bracket balance check, ignoring strings/comments."""
    for path in ROOT.rglob("*.swift"):
        text = path.read_text(encoding="utf-8")
        stack: list[str] = []
        pairs = {")": "(", "]": "[", "}": "{"}
        index = 0
        state = "code"
        while index < len(text):
            char = text[index]
            nxt = text[index + 1] if index + 1 < len(text) else ""
            if state == "code":
                if char == "/" and nxt == "/":
                    state = "line"
                    index += 2
                    continue
                if char == "/" and nxt == "*":
                    state = "block"
                    index += 2
                    continue
                if char == '"':
                    state = "string"
                    index += 1
                    continue
                if char in "([{":
                    stack.append(char)
                elif char in ")]}":
                    if not stack or stack.pop() != pairs[char]:
                        ERRORS.append(
                            f"SWIFT {path.relative_to(ROOT)}: unbalanced {char} "
                            f"at offset {index}"
                        )
                        return
                index += 1
            elif state == "line":
                if char == "\n":
                    state = "code"
                index += 1
            elif state == "block":
                if char == "*" and nxt == "/":
                    state = "code"
                    index += 2
                else:
                    index += 1
            elif state == "string":
                if char == "\\":
                    index += 2
                elif char == '"':
                    state = "code"
                    index += 1
                else:
                    index += 1
        if stack:
            ERRORS.append(
                f"SWIFT {path.relative_to(ROOT)}: unclosed delimiters {stack}"
            )


def main() -> int:
    check_json()
    check_plists()
    check_yaml()
    check_swift_balance()
    if ERRORS:
        print("\n".join(ERRORS))
        return 1
    print("Assets, manifests and Swift delimiter balance: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
