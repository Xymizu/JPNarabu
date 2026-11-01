"""Import the supplied Markdown study lists into the offline card asset.

The supplied files are development sources only. Their licensing status is not
declared, so generated data must not be shipped publicly until provenance is
confirmed.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path


def pipe_rows(path: Path) -> list[tuple[str, str]]:
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        match = re.match(
            r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*(?:\|\s*([^|]+?)\s*)?\|",
            line,
        )
        if not match or set(match.group(1).strip()) <= {"-"}:
            continue
        left, right = (part.strip() for part in match.groups())
        if left.lower() in {"kanji", "kosakata"}:
            continue
        rows.append((left, right, (match.group(3) or "").strip()))
    return rows


def n3_kanji(path: Path) -> list[tuple[str, str, str]]:
    cards = []
    for line in path.read_text(encoding="utf-8").splitlines():
        match = re.match(r"^###\s+(.+?)\s+—\s+(.+?)\s+—\s+(.+?)(?:\s+_.*)?$", line)
        if match:
            front, reading, meaning = (part.strip() for part in match.groups())
            if len(front) <= 4 and front:
                cards.append((front, reading, meaning))
    return cards


def n3_words(path: Path) -> list[tuple[str, str, str]]:
    cards = []
    for line in path.read_text(encoding="utf-8").splitlines():
        match = re.match(r"^\s*-\s+(.+?)\s+---\s+(.+?)\s+---\s+(.+?)\s*$", line)
        if match:
            front, reading, meaning = (part.strip() for part in match.groups())
            cards.append((front, reading, meaning))
    return cards


def card(card_id: str, category: str, level: str, front: str,
         reading: str, meaning: str, order: int) -> dict[str, object]:
    return {
        "id": card_id,
        "category": category,
        "level": level,
        "front": front,
        "reading": reading,
        "romaji": "",
        "meaning": meaning,
        "example": "",
        "order": order,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kanji-n4", type=Path, required=True)
    parser.add_argument("--kotoba-n4", type=Path, required=True)
    parser.add_argument("--n3", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    cards = json.loads(
        (args.output).read_text(encoding="utf-8")
    ) if args.output.exists() else []
    imported_prefixes = (
        "source-",
        "kanji-n4-source-",
        "kotoba-n4-source-",
        "kanji-n3-source-",
        "kotoba-n3-source-",
    )
    cards = [
        item for item in cards
        if not item["id"].startswith(imported_prefixes)
    ]
    seen = {item["id"] for item in cards}

    def add(item: dict[str, object]) -> None:
        if item["id"] not in seen:
            seen.add(item["id"])
            cards.append(item)

    def stable_id(category: str, level: str, front: str, reading: str) -> str:
        key = f"{category}|{level}|{front}|{reading}".encode("utf-8")
        return f"source-{hashlib.sha1(key).hexdigest()[:12]}"

    for order, (front, reading, meaning) in enumerate(pipe_rows(args.kanji_n4), 1):
        add(card(stable_id("kanji", "n4", front, reading), "kanji", "n4",
                 front, reading, meaning, order))

    for order, (front, meaning, _) in enumerate(pipe_rows(args.kotoba_n4), 1):
        reading = front
        reading_match = re.search(r"\(([^)]+)\)", front)
        if reading_match:
            reading = reading_match.group(1)
        add(card(stable_id("kotoba", "n4", front, reading), "kotoba", "n4",
                 front, reading, meaning, order))

    for order, (front, reading, meaning) in enumerate(n3_kanji(args.n3), 1):
        add(card(stable_id("kanji", "n3", front, reading), "kanji", "n3",
                 front, reading, meaning, order))

    for order, (front, reading, meaning) in enumerate(n3_words(args.n3), 1):
        add(card(stable_id("kotoba", "n3", front, reading), "kotoba", "n3",
                 front, reading, meaning, order))

    args.output.write_text(
        json.dumps(cards, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"wrote {len(cards)} cards to {args.output}")


if __name__ == "__main__":
    main()
