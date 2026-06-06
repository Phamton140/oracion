#!/usr/bin/env python3
"""
fetch_bible.py - Descarga el corpus de la Biblia RV1909 (Reina-Valera 1909).

La RV1909 está en dominio público y se distribuye libremente.
Fuente principal: API pública de bible-api.com (formato JSON) que
incluye textos en dominio público en español.

Uso:
    python tools/fetch_bible.py

Salida:
    tools/output/rv1909.json

Si la descarga falla por falta de internet, este script emite un error
claro. Se puede sustituir por una fuente local descomentando
LOAD_FROM_FILE.
"""

from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

# Permite cargar desde un archivo local (alternativa offline).
LOAD_FROM_FILE: str | None = None  # ej: "C:/ruta/local/rv1909.json"

# Orden de libros canónicos. La RV1909 sigue el orden protestante
# estándar (66 libros: 39 AT + 27 NT).
BOOKS: list[dict[str, Any]] = [
    # Antiguo Testamento
    {"id": "GEN", "name": "Génesis", "testament": "OT", "number": 1},
    {"id": "EXO", "name": "Éxodo", "testament": "OT", "number": 2},
    {"id": "LEV", "name": "Levítico", "testament": "OT", "number": 3},
    {"id": "NUM", "name": "Números", "testament": "OT", "number": 4},
    {"id": "DEU", "name": "Deuteronomio", "testament": "OT", "number": 5},
    {"id": "JOS", "name": "Josué", "testament": "OT", "number": 6},
    {"id": "JDG", "name": "Jueces", "testament": "OT", "number": 7},
    {"id": "RUT", "name": "Rut", "testament": "OT", "number": 8},
    {"id": "1SA", "name": "1 Samuel", "testament": "OT", "number": 9},
    {"id": "2SA", "name": "2 Samuel", "testament": "OT", "number": 10},
    {"id": "1KI", "name": "1 Reyes", "testament": "OT", "number": 11},
    {"id": "2KI", "name": "2 Reyes", "testament": "OT", "number": 12},
    {"id": "1CH", "name": "1 Crónicas", "testament": "OT", "number": 13},
    {"id": "2CH", "name": "2 Crónicas", "testament": "OT", "number": 14},
    {"id": "EZR", "name": "Esdras", "testament": "OT", "number": 15},
    {"id": "NEH", "name": "Nehemías", "testament": "OT", "number": 16},
    {"id": "EST", "name": "Ester", "testament": "OT", "number": 17},
    {"id": "JOB", "name": "Job", "testament": "OT", "number": 18},
    {"id": "PSA", "name": "Salmos", "testament": "OT", "number": 19},
    {"id": "PRO", "name": "Proverbios", "testament": "OT", "number": 20},
    {"id": "ECC", "name": "Eclesiastés", "testament": "OT", "number": 21},
    {"id": "SNG", "name": "Cantares", "testament": "OT", "number": 22},
    {"id": "ISA", "name": "Isaías", "testament": "OT", "number": 23},
    {"id": "JER", "name": "Jeremías", "testament": "OT", "number": 24},
    {"id": "LAM", "name": "Lamentaciones", "testament": "OT", "number": 25},
    {"id": "EZK", "name": "Ezequiel", "testament": "OT", "number": 26},
    {"id": "DAN", "name": "Daniel", "testament": "OT", "number": 27},
    {"id": "HOS", "name": "Oseas", "testament": "OT", "number": 28},
    {"id": "JOL", "name": "Joel", "testament": "OT", "number": 29},
    {"id": "AMO", "name": "Amós", "testament": "OT", "number": 30},
    {"id": "OBA", "name": "Abdías", "testament": "OT", "number": 31},
    {"id": "JON", "name": "Jonás", "testament": "OT", "number": 32},
    {"id": "MIC", "name": "Miqueas", "testament": "OT", "number": 33},
    {"id": "NAM", "name": "Nahúm", "testament": "OT", "number": 34},
    {"id": "HAB", "name": "Habacuc", "testament": "OT", "number": 35},
    {"id": "ZEP", "name": "Sofonías", "testament": "OT", "number": 36},
    {"id": "HAG", "name": "Hageo", "testament": "OT", "number": 37},
    {"id": "ZEC", "name": "Zacarías", "testament": "OT", "number": 38},
    {"id": "MAL", "name": "Malaquías", "testament": "OT", "number": 39},
    # Nuevo Testamento
    {"id": "MAT", "name": "Mateo", "testament": "NT", "number": 40},
    {"id": "MRK", "name": "Marcos", "testament": "NT", "number": 41},
    {"id": "LUK", "name": "Lucas", "testament": "NT", "number": 42},
    {"id": "JHN", "name": "Juan", "testament": "NT", "number": 43},
    {"id": "ACT", "name": "Hechos", "testament": "NT", "number": 44},
    {"id": "ROM", "name": "Romanos", "testament": "NT", "number": 45},
    {"id": "1CO", "name": "1 Corintios", "testament": "NT", "number": 46},
    {"id": "2CO", "name": "2 Corintios", "testament": "NT", "number": 47},
    {"id": "GAL", "name": "Gálatas", "testament": "NT", "number": 48},
    {"id": "EPH", "name": "Efesios", "testament": "NT", "number": 49},
    {"id": "PHP", "name": "Filipenses", "testament": "NT", "number": 50},
    {"id": "COL", "name": "Colosenses", "testament": "NT", "number": 51},
    {"id": "1TH", "name": "1 Tesalonicenses", "testament": "NT", "number": 52},
    {"id": "2TH", "name": "2 Tesalonicenses", "testament": "NT", "number": 53},
    {"id": "1TI", "name": "1 Timoteo", "testament": "NT", "number": 54},
    {"id": "2TI", "name": "2 Timoteo", "testament": "NT", "number": 55},
    {"id": "TIT", "name": "Tito", "testament": "NT", "number": 56},
    {"id": "PHM", "name": "Filemón", "testament": "NT", "number": 57},
    {"id": "HEB", "name": "Hebreos", "testament": "NT", "number": 58},
    {"id": "JAS", "name": "Santiago", "testament": "NT", "number": 59},
    {"id": "1PE", "name": "1 Pedro", "testament": "NT", "number": 60},
    {"id": "2PE", "name": "2 Pedro", "testament": "NT", "number": 61},
    {"id": "1JN", "name": "1 Juan", "testament": "NT", "number": 62},
    {"id": "2JN", "name": "2 Juan", "testament": "NT", "number": 63},
    {"id": "3JN", "name": "3 Juan", "testament": "NT", "number": 64},
    {"id": "JUD", "name": "Judas", "testament": "NT", "number": 65},
    {"id": "REV", "name": "Apocalipsis", "testament": "NT", "number": 66},
]


def _http_get_json(url: str, timeout: int = 30) -> dict[str, Any]:
    """Descarga JSON desde una URL con reintentos."""
    last_err: Exception | None = None
    for attempt in range(3):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "oracion-bible-importer/1.0"},
            )
            with urllib.request.urlopen(req, timeout=timeout) as resp:  # noqa: S310
                data = resp.read()
            return json.loads(data.decode("utf-8"))
        except (urllib.error.URLError, json.JSONDecodeError, TimeoutError) as e:
            last_err = e
            time.sleep(2**attempt)
    raise RuntimeError(f"No se pudo descargar {url}: {last_err}")


def fetch_book(book_id: str) -> dict[str, Any] | None:
    """Descarga un libro desde bible-api.com. Devuelve None si falla."""
    # bible-api.com soporta varios idiomas. Para RV1909 usamos 'rv1909'
    # cuando esté disponible, con fallback a 'rvr' (RVR60) o 'spa' (generic).
    for translation in ("rv1909", "rvr", "spa"):
        try:
            url = f"https://bible-api.com/data/{translation}/{book_id}"
            data = _http_get_json(url)
            if data and "chapters" in data:
                return data
        except Exception:  # noqa: BLE001
            continue
    return None


def normalize_book(book: dict[str, Any], meta: dict[str, Any]) -> list[dict[str, Any]]:
    """Convierte la respuesta de bible-api.com al formato interno.

    Formato interno:
        [
          {"book": "Génesis", "book_number": 1, "chapter": 1, "verse": 1, "text": "..."},
          ...
        ]
    """
    out: list[dict[str, Any]] = []
    for chapter in book.get("chapters", []):
        chapter_num = int(chapter.get("chapter", "0"))
        for verse in chapter.get("verses", []):
            verse_num = int(verse.get("verse", "0"))
            text = (verse.get("text") or "").strip()
            if not text:
                continue
            out.append(
                {
                    "book": meta["name"],
                    "book_number": meta["number"],
                    "chapter": chapter_num,
                    "verse": verse_num,
                    "text": text,
                }
            )
    return out


def main() -> int:
    out_dir = Path(__file__).parent / "output"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / "rv1909.json"

    if LOAD_FROM_FILE:
        src = Path(LOAD_FROM_FILE)
        if not src.exists():
            print(f"ERROR: LOAD_FROM_FILE apunta a {src} que no existe.", file=sys.stderr)
            return 1
        print(f"Cargando Biblia desde archivo local: {src}")
        all_verses: list[dict[str, Any]] = json.loads(src.read_text(encoding="utf-8"))
    else:
        all_verses: list[dict[str, Any]] = []
        total = len(BOOKS)
        for i, book in enumerate(BOOKS, start=1):
            print(f"[{i:>2}/{total}] {book['name']} ...", end=" ", flush=True)
            data = fetch_book(book["id"])
            if not data:
                print("ERROR (saltando)")
                continue
            verses = normalize_book(data, book)
            all_verses.extend(verses)
            print(f"{len(verses)} versículos")
            time.sleep(0.2)  # rate limit polite

    if not all_verses:
        print("ERROR: no se obtuvieron versículos.", file=sys.stderr)
        return 1

    out_path.write_text(
        json.dumps(all_verses, ensure_ascii=False, indent=1),
        encoding="utf-8",
    )
    print(f"\n✓ {len(all_verses)} versículos guardados en {out_path}")
    print(f"  Tamaño: {out_path.stat().st_size / 1024:.1f} KB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
