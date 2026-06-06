#!/usr/bin/env python3
"""
build_tags.py - Genera los verse_tags automáticamente a partir del lexicon.

Pipeline:
  1. Lee tools/lexicon_seed.json
  2. Lee assets/bible/rv1909.json
  3. Para cada versículo, busca matches de keywords (palabra completa, sin acentos)
  4. Genera assets/bible/verse_tags_auto.csv
  5. Aplica overrides y extensiones desde tools/verse_tags_manual.csv
  6. Genera el CSV final assets/bible/verse_tags_final.csv

Salida:
  - assets/bible/verse_tags_auto.csv   (auto, se regenera siempre)
  - assets/bible/verse_tags_final.csv  (auto + manual con overrides aplicados)

Uso:
    python tools/build_tags.py
"""

from __future__ import annotations

import csv
import io
import json
import re
import sys
import unicodedata
from pathlib import Path

if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent
TOOLS_DIR = ROOT / "tools"
ASSETS_DIR = ROOT / "assets" / "bible"

LEXICON_PATH = TOOLS_DIR / "lexicon_seed.json"
VERSES_PATH = ASSETS_DIR / "rv1909.json"
AUTO_OUT_PATH = ASSETS_DIR / "verse_tags_auto.csv"
MANUAL_PATH = TOOLS_DIR / "verse_tags_manual.csv"
FINAL_OUT_PATH = ASSETS_DIR / "verse_tags_final.csv"


# =============================================================================
# NORMALIZACIÓN
# =============================================================================


def strip_accents(s: str) -> str:
    """Quita acentos/diéresis y baja a minúsculas. 'María' -> 'maria'."""
    nfkd = unicodedata.normalize("NFKD", s)
    return "".join(c for c in nfkd if not unicodedata.combining(c)).lower()


# =============================================================================
# MATCHING
# =============================================================================


def compile_keyword(kw: str) -> re.Pattern[str]:
    """Compila un keyword como patrón regex de palabra completa, sin acentos."""
    norm = strip_accents(kw)
    parts = [re.escape(p) for p in norm.split()]
    pattern = r"\b" + r"\s+".join(parts) + r"\b"
    return re.compile(pattern, flags=re.UNICODE)


def compile_tag_pattern(keywords: list[str]) -> re.Pattern[str]:
    """Compila todos los keywords de un tag en una sola alternación con word boundaries.

    Mucho más rápido que iterar patterns individuales: Python hace un solo
    recorrido del texto por tag.
    """
    alts: list[str] = []
    for kw in keywords:
        norm = strip_accents(kw)
        parts = [re.escape(p) for p in norm.split()]
        alts.append(r"\s+".join(parts))
    # Patrón unificado: \b(alt1|alt2|alt3|...)\b
    pattern = r"\b(?:" + "|".join(alts) + r")\b"
    return re.compile(pattern, flags=re.UNICODE | re.IGNORECASE)


def find_tags_for_verse(text: str, compiled: dict[str, re.Pattern[str]], tag_meta: list[tuple[str, str]]) -> list[tuple[str, str]]:
    """Devuelve [(tag_id, category), ...] para un versículo."""
    norm = strip_accents(text)
    found: list[tuple[str, str]] = []
    for tag_id, category, pat in tag_meta:
        if pat.search(norm):
            found.append((tag_id, category))
    return found


# =============================================================================
# OVERRIDES MANUALES
# =============================================================================


def load_manual_overrides(path: Path) -> dict[tuple[int, int, int], list[tuple[str, str, float]]]:
    """Lee el CSV de overrides manuales.

    Formato CSV:
        book_number,chapter,verse,tag,category,weight,action
    donde action ∈ {add, remove, set}

    Returns:
        dict[(book, chapter, verse)] -> list[(tag, category, weight, action)]
    """
    overrides: dict[tuple[int, int, int], list[tuple[str, str, float, str]]] = {}
    if not path.exists():
        return overrides

    with path.open(encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                key = (int(row["book_number"]), int(row["chapter"]), int(row["verse"]))
                entry = (row["tag"], row["category"], float(row.get("weight", 1.0)), row.get("action", "add"))
                overrides.setdefault(key, []).append(entry)
            except (KeyError, ValueError) as e:
                print(f"WARNING: fila inválida en {path.name}: {row} ({e})", file=sys.stderr)
    return overrides


def apply_overrides(
    auto_tags: dict[tuple[int, int, int], list[tuple[str, str, float]]],
    overrides: dict[tuple[int, int, int], list[tuple[str, str, float, str]]],
) -> dict[tuple[int, int, int], list[tuple[str, str, float]]]:
    """Aplica los overrides manuales sobre los tags automáticos."""
    final: dict[tuple[int, int, int], list[tuple[str, str, float]]] = {}
    for key, tags in auto_tags.items():
        final[key] = list(tags)

    for key, ops in overrides.items():
        for tag, category, weight, action in ops:
            current = final.setdefault(key, [])
            # Filtrar por tag
            current_filtered = [t for t in current if t[0] != tag]
            if action in ("add", "set"):
                current_filtered.append((tag, category, weight))
            # 'remove' = no añadimos
            final[key] = current_filtered

    return final


# =============================================================================
# MAIN
# =============================================================================


def main() -> int:
    if not LEXICON_PATH.exists():
        print(f"ERROR: falta {LEXICON_PATH}", file=sys.stderr)
        return 1
    if not VERSES_PATH.exists():
        print(f"ERROR: falta {VERSES_PATH}. Ejecuta tools/build_db.py primero.", file=sys.stderr)
        return 1

    print("Cargando lexicon...")
    lexicon = json.loads(LEXICON_PATH.read_text(encoding="utf-8"))
    print(f"  {len(lexicon['tags'])} tags.")

    print("Compilando patrones regex...")
    compiled: dict[str, re.Pattern[str]] = {}
    tag_meta: list[tuple[str, str, re.Pattern[str]]] = []
    for tag in lexicon["tags"]:
        pat = compile_tag_pattern(tag["keywords"])
        compiled[tag["id"]] = pat
        tag_meta.append((tag["id"], tag["category"], pat))
    print(f"  {len(compiled)} patterns (uno por tag).")

    print("Cargando versículos...")
    verses = json.loads(VERSES_PATH.read_text(encoding="utf-8"))
    print(f"  {len(verses)} versículos.")

    print("Auto-tagging...")
    auto: dict[tuple[int, int, int], list[tuple[str, str, float]]] = {}
    tagged_count = 0
    for v in verses:
        key = (int(v["book_number"]), int(v["chapter"]), int(v["verse"]))
        tags = find_tags_for_verse(v["text"], compiled, tag_meta)
        if tags:
            tagged_count += 1
            auto[key] = [(t, c, 1.0) for t, c in tags]

    total_auto = sum(len(t) for t in auto.values())
    print(f"  {tagged_count} versículos taggeados, {total_auto} assignments.")

    # Escribir verse_tags_auto.csv
    print(f"Escribiendo {AUTO_OUT_PATH}...")
    AUTO_OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with AUTO_OUT_PATH.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["book_number", "chapter", "verse", "tag", "category", "weight"])
        for (book, chapter, verse), tags in sorted(auto.items()):
            for tag, category, weight in tags:
                w.writerow([book, chapter, verse, tag, category, weight])

    # Aplicar overrides manuales
    print(f"Aplicando overrides desde {MANUAL_PATH}...")
    overrides = load_manual_overrides(MANUAL_PATH)
    print(f"  {len(overrides)} versículos con override manual.")
    final = apply_overrides(auto, overrides)
    total_final = sum(len(t) for t in final.values())

    # Escribir verse_tags_final.csv
    print(f"Escribiendo {FINAL_OUT_PATH}...")
    with FINAL_OUT_PATH.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["book_number", "chapter", "verse", "tag", "category", "weight"])
        for (book, chapter, verse), tags in sorted(final.items()):
            for tag, category, weight in tags:
                w.writerow([book, chapter, verse, tag, category, weight])

    print(f"\n=== RESUMEN ===")
    print(f"  Versículos taggeados: {tagged_count}/{len(verses)} ({100*tagged_count/len(verses):.1f}%)")
    print(f"  Tags automáticos:    {total_auto}")
    print(f"  Overrides manuales:  {len(overrides)}")
    print(f"  Tags finales:        {total_final}")
    print(f"  Output: {FINAL_OUT_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
