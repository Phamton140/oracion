#!/usr/bin/env python3
"""
build_db.py - Procesa el SQL fuente y genera los assets de la Biblia.

Fuentes:
  - tools/output/tables.sql  (schema)
  - tools/output/data.sql    (datos RV1909)

Salida:
  - assets/bible/rv1909.json     (texto canónico, lista plana)
  - assets/bible/manifest.json   (metadatos: sha256, conteo, fecha)

Uso:
    python tools/build_db.py
"""

from __future__ import annotations

import hashlib
import io
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

# Asegurar salida UTF-8 en Windows (cp1252 no maneja check marks)
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")


ROOT = Path(__file__).resolve().parent.parent
SQL_DIR = ROOT / "tools" / "output"
ASSETS_DIR = ROOT / "assets" / "bible"


def parse_sql_value(raw: str) -> str:
    """Convierte un valor SQL a su forma canónica (sin comillas externas)."""
    raw = raw.strip()
    # Quitar comillas externas si las hay
    if raw.startswith("'") and raw.endswith("'"):
        return raw[1:-1].replace("''", "'").replace("\\'", "'")
    return raw


def parse_insert_values(stmt: str) -> list[list[str]]:
    """Extrae los VALUES de una sentencia INSERT en una lista de filas.

    Soporta tuplas como:
       (1, 'Génesis', 'Génesis', 0),
       (1, 1, 1, 'En el principio...'),
    """
    # Capturar todo entre el primer '(' y el último ')'
    inner = stmt[stmt.index("(") : stmt.rindex(")") + 1]

    rows: list[list[str]] = []
    current_row: list[str] = []
    current_value = []
    in_string = False
    paren_depth = 0

    i = 0
    while i < len(inner):
        ch = inner[i]
        if in_string:
            if ch == "'" and (i + 1 >= len(inner) or inner[i + 1] != "'"):
                in_string = False
                current_value.append(ch)
            elif ch == "'" and inner[i + 1] == "'":
                current_value.append("'")
                i += 1
            else:
                current_value.append(ch)
        else:
            if ch == "'":
                in_string = True
                current_value.append(ch)
            elif ch == "(":
                paren_depth += 1
                if paren_depth == 1:
                    current_row = []
                    current_value = []
            elif ch == ")":
                paren_depth -= 1
                if paren_depth == 0:
                    current_row.append("".join(current_value).strip())
                    rows.append(current_row)
            elif ch == "," and paren_depth == 1:
                current_row.append("".join(current_value).strip())
                current_value = []
            else:
                current_value.append(ch)
        i += 1

    return rows


def _find_insert_blocks(sql_text: str, table: str) -> list[str]:
    """Devuelve cada bloque `INSERT INTO <table> VALUES ... ;` por separado.

    No usamos regex con `;` como delimitador porque el texto de los versículos
    contiene `;` (puntuación española). En su lugar recorremos línea a línea y
    acumulamos contenido desde cada `INSERT INTO <tabla> VALUES` hasta el `;`
    que aparece fuera de cualquier literal de texto.
    """
    pattern = re.compile(
        rf"INSERT\s+INTO\s+{re.escape(table)}\s+VALUES\b",
        flags=re.IGNORECASE,
    )
    blocks: list[str] = []
    pos = 0
    while True:
        m = pattern.search(sql_text, pos)
        if not m:
            break
        # Avanzamos hasta justo después de "VALUES"
        i = m.end()
        in_string = False
        n = len(sql_text)
        while i < n:
            ch = sql_text[i]
            if in_string:
                if ch == "'":
                    if i + 1 < n and sql_text[i + 1] == "'":
                        i += 2
                        continue
                    in_string = False
            else:
                if ch == "'":
                    in_string = True
                elif ch == ";":
                    break
            i += 1
        if i >= n:
            break
        blocks.append(sql_text[m.end() : i])
        pos = i + 1
    return blocks


def parse_books(sql_text: str) -> list[dict[str, str]]:
    """Extrae la lista de libros del SQL."""
    blocks = _find_insert_blocks(sql_text, "books")
    out: list[dict[str, str]] = []
    for block in blocks:
        for r in parse_insert_values(block):
            if len(r) < 4:
                continue
            out.append(
                {
                    "id": int(r[0]),
                    "name": parse_sql_value(r[1]),
                    "modern_name": parse_sql_value(r[2]),
                    "new_testament": int(r[3]),
                }
            )
    return out


def parse_verses(sql_text: str) -> list[dict[str, object]]:
    """Extrae la lista de versículos del SQL."""
    blocks = _find_insert_blocks(sql_text, "verses")
    out: list[dict[str, object]] = []
    for block in blocks:
        for r in parse_insert_values(block):
            if len(r) < 4:
                continue
            out.append(
                {
                    "book_id": int(r[0]),
                    "chapter": int(r[1]),
                    "verse": int(r[2]),
                    "text": parse_sql_value(r[3]),
                }
            )
    return out


def main() -> int:
    tables_path = SQL_DIR / "tables.sql"
    data_path = SQL_DIR / "data.sql"

    if not tables_path.exists() or not data_path.exists():
        print(
            f"ERROR: faltan {tables_path} o {data_path}.",
            file=sys.stderr,
        )
        print("Ejecuta antes: python tools/fetch_bible.py (offline: descarga manual).",
              file=sys.stderr)
        return 1

    sql_text = tables_path.read_text(encoding="utf-8") + "\n" + data_path.read_text(
        encoding="utf-8"
    )

    print("Parseando libros...")
    books = parse_books(sql_text)
    print(f"  {len(books)} libros.")

    print("Parseando versículos...")
    verses_raw = parse_verses(sql_text)
    print(f"  {len(verses_raw)} versículos crudos.")

    # Enriquecer con el nombre del libro y reindexar como 0..N-1
    book_by_id = {b["id"]: b for b in books}
    verses: list[dict[str, object]] = []
    for v in verses_raw:
        book = book_by_id.get(v["book_id"])
        if not book:
            continue
        verses.append(
            {
                "book": book["name"],
                "book_number": int(book["id"]),
                "chapter": v["chapter"],
                "verse": v["verse"],
                "text": v["text"],
            }
        )

    # Ordenar: book_number, chapter, verse
    verses.sort(key=lambda v: (v["book_number"], v["chapter"], v["verse"]))

    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    out_json = ASSETS_DIR / "rv1909.json"
    out_manifest = ASSETS_DIR / "manifest.json"

    raw_bytes = json.dumps(verses, ensure_ascii=False, indent=1).encode("utf-8")
    out_json.write_bytes(raw_bytes)

    manifest = {
        "translation": "RV1909",
        "version": 1,
        "verse_count": len(verses),
        "book_count": len(books),
        "testaments": {
            "old_testament_books": sum(
                1 for b in books if b["new_testament"] == 0
            ),
            "new_testament_books": sum(
                1 for b in books if b["new_testament"] == 1
            ),
        },
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "sha256": hashlib.sha256(raw_bytes).hexdigest(),
        "size_bytes": len(raw_bytes),
        "source": "iglesianazaret/biblia-reina-valera-1909-base-datos-sql (GitHub, public domain)",
    }
    out_manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    print(f"\n✓ {len(verses)} versículos guardados en {out_json}")
    print(f"  Tamaño: {len(raw_bytes) / 1024:.1f} KB")
    print(f"  SHA-256: {manifest['sha256']}")
    print(f"  Manifest: {out_manifest}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
