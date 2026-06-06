#!/usr/bin/env python3
"""
build_bible_db.py - Construye el asset SQLite pre-poblado (bible_assets.db).

El DB generado debe tener el MISMO schema que el drift AppDatabase espera,
de forma que la app solo copie el archivo y abra la conexión sin migraciones.

Tablas (espejo del Drift schema):
  - verses:        (id PK auto, book, book_number, chapter, verse, body, translation)
  - verse_tags:    (id PK auto, verse_id FK, tag, weight)
  - schema_meta:   (key PK, value)  -- versiones y conteos

NO poblamos aquí: conversations, messages, conversation_contexts, favorites,
settings, usage_stats. Esas se crean vacías en runtime por Drift (m.createAll).

Uso:
    python tools/build_bible_db.py
"""

from __future__ import annotations

import csv
import hashlib
import io
import json
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path

if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent
ASSETS_DIR = ROOT / "assets" / "bible"
VERSES_JSON = ASSETS_DIR / "rv1909.json"
TAGS_CSV = ASSETS_DIR / "verse_tags_final.csv"
OUT_DB = ASSETS_DIR / "bible_assets.db"
OLD_MANIFEST = ASSETS_DIR / "manifest.json"
OUT_MANIFEST = ASSETS_DIR / "bible_assets.manifest.json"


SCHEMA_SQL = """
-- ============================================================================
-- TABLAS DEL CORPUS BÍBLICO (pre-pobladas, read-only en runtime)
-- ============================================================================
-- Esta base de datos se SHIPPEA como asset y se copia a documents en
-- el primer arranque. Las tablas de user data (conversations, messages,
-- favorites, settings, usage_stats) viven en la DB de drift (oracion_db),
-- NO aquí. Esto permite reemplazar el corpus bíblico sin perder datos
-- del usuario.
-- ============================================================================
CREATE TABLE IF NOT EXISTS verses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book TEXT NOT NULL,
    book_number INTEGER NOT NULL,
    chapter INTEGER NOT NULL,
    verse INTEGER NOT NULL,
    body TEXT NOT NULL,
    translation TEXT NOT NULL DEFAULT 'RV1909'
);

CREATE INDEX IF NOT EXISTS idx_verses_book_chapter
    ON verses (book_number, chapter);
CREATE INDEX IF NOT EXISTS idx_verses_book
    ON verses (book_number);
CREATE INDEX IF NOT EXISTS idx_verses_translation
    ON verses (translation);

CREATE TABLE IF NOT EXISTS verse_tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    verse_id INTEGER NOT NULL REFERENCES verses(id) ON DELETE CASCADE,
    tag TEXT NOT NULL,
    weight REAL NOT NULL DEFAULT 1.0
);

CREATE INDEX IF NOT EXISTS idx_verse_tags_verse ON verse_tags (verse_id);
CREATE INDEX IF NOT EXISTS idx_verse_tags_tag ON verse_tags (tag);
CREATE INDEX IF NOT EXISTS idx_verse_tags_tag_verse ON verse_tags (tag, verse_id);

-- ============================================================================
-- METADATA DEL ASSET (versión, conteos, fecha de generación)
-- ============================================================================
CREATE TABLE IF NOT EXISTS schema_meta (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
"""


# Aliases de nombres de libros para UI en español moderno
BOOK_ALIASES = {
    "Revelación": {"display_name": "Apocalipsis", "subtitle": "Revelación"},
}


def insert_verses(conn: sqlite3.Connection, verses: list[dict]) -> dict[int, int]:
    """Inserta versículos y devuelve un mapa (book, chapter, verse) -> id."""
    print(f"  Insertando {len(verses)} versículos...")
    cur = conn.cursor()
    cur.execute("BEGIN")
    verse_id_map: dict[tuple[int, int, int], int] = {}
    for v in verses:
        cur.execute(
            "INSERT INTO verses (book, book_number, chapter, verse, body, translation) "
            "VALUES (?, ?, ?, ?, ?, 'RV1909')",
            (
                v["book"],
                int(v["book_number"]),
                int(v["chapter"]),
                int(v["verse"]),
                v["text"],
            ),
        )
        key = (int(v["book_number"]), int(v["chapter"]), int(v["verse"]))
        verse_id_map[key] = cur.lastrowid
    cur.execute("COMMIT")
    return verse_id_map


def insert_verse_tags(
    conn: sqlite3.Connection,
    tags_csv: Path,
    verse_id_map: dict[tuple[int, int, int], int],
) -> int:
    """Inserta los verse_tags desde el CSV. Devuelve la cantidad insertada."""
    print(f"  Insertando verse_tags desde {tags_csv.name}...")
    cur = conn.cursor()
    cur.execute("BEGIN")
    count = 0
    missing = 0
    with tags_csv.open(encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                key = (int(row["book_number"]), int(row["chapter"]), int(row["verse"]))
                verse_id = verse_id_map.get(key)
                if verse_id is None:
                    missing += 1
                    continue
                cur.execute(
                    "INSERT INTO verse_tags (verse_id, tag, weight) VALUES (?, ?, ?)",
                    (verse_id, row["tag"], float(row.get("weight", 1.0))),
                )
                count += 1
            except (KeyError, ValueError) as e:
                print(f"  WARNING: fila inválida: {row} ({e})", file=sys.stderr)
    cur.execute("COMMIT")
    if missing:
        print(f"  NOTE: {missing} tags apuntando a versículos inexistentes (omitidos).")
    return count


def write_meta(
    conn: sqlite3.Connection,
    verse_count: int,
    tag_count: int,
    book_count: int,
) -> None:
    """Escribe la metadata del schema y la manifest.json externa."""
    cur = conn.cursor()
    cur.execute("BEGIN")
    cur.execute("INSERT OR REPLACE INTO schema_meta (key, value) VALUES (?, ?)",
                ("bible_assets_version", "1"))
    cur.execute("INSERT OR REPLACE INTO schema_meta (key, value) VALUES (?, ?)",
                ("translation", "RV1909"))
    cur.execute("INSERT OR REPLACE INTO schema_meta (key, value) VALUES (?, ?)",
                ("verse_count", str(verse_count)))
    cur.execute("INSERT OR REPLACE INTO schema_meta (key, value) VALUES (?, ?)",
                ("verse_tag_count", str(tag_count)))
    cur.execute("INSERT OR REPLACE INTO schema_meta (key, value) VALUES (?, ?)",
                ("book_count", str(book_count)))
    cur.execute("INSERT OR REPLACE INTO schema_meta (key, value) VALUES (?, ?)",
                ("generated_at", datetime.now(timezone.utc).isoformat()))
    cur.execute("COMMIT")


def main() -> int:
    if not VERSES_JSON.exists():
        print(f"ERROR: falta {VERSES_JSON}. Ejecuta tools/build_db.py primero.", file=sys.stderr)
        return 1
    if not TAGS_CSV.exists():
        print(f"ERROR: falta {TAGS_CSV}. Ejecuta tools/build_tags.py primero.", file=sys.stderr)
        return 1

    # Eliminar DB previa
    if OUT_DB.exists():
        OUT_DB.unlink()
        print(f"  DB anterior eliminado.")

    print("Creando DB pre-poblado...")
    conn = sqlite3.connect(OUT_DB)
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("PRAGMA synchronous = NORMAL")
    conn.execute("PRAGMA foreign_keys = ON")

    print("Creando schema...")
    conn.executescript(SCHEMA_SQL)

    print("Cargando versículos...")
    verses = json.loads(VERSES_JSON.read_text(encoding="utf-8"))
    book_count = len({v["book"] for v in verses})
    verse_id_map = insert_verses(conn, verses)

    print("Cargando verse_tags...")
    tag_count = insert_verse_tags(conn, TAGS_CSV, verse_id_map)

    print("Escribiendo metadata...")
    write_meta(conn, len(verses), tag_count, book_count)

    # Optimizar: VACUUM para reducir tamaño
    print("Optimizando DB (VACUUM)...")
    conn.execute("VACUUM")
    conn.close()

    # SHA-256 y manifest
    raw = OUT_DB.read_bytes()
    sha = hashlib.sha256(raw).hexdigest()
    manifest = {
        "asset": "bible_assets.db",
        "version": 1,
        "translation": "RV1909",
        "verse_count": len(verses),
        "book_count": book_count,
        "verse_tag_count": tag_count,
        "size_bytes": len(raw),
        "sha256": sha,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_verses": "iglesianazaret/biblia-reina-valera-1909-base-datos-sql (GitHub, public domain)",
        "source_tags": "tools/build_tags.py + tools/lexicon_seed.json + tools/verse_tags_manual.csv",
        "book_aliases": BOOK_ALIASES,
    }
    OUT_MANIFEST.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    print(f"\n=== RESUMEN ===")
    print(f"  Versículos:     {len(verses)}")
    print(f"  Libros:         {book_count}")
    print(f"  Verse tags:     {tag_count}")
    print(f"  Tamaño:         {len(raw) / 1024:.1f} KB")
    print(f"  SHA-256:        {sha}")
    print(f"  Output:         {OUT_DB}")
    print(f"  Manifest:       {OUT_MANIFEST}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
