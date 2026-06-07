# Oración

> Experiencia de conversación con las Escrituras. Funciona 100% offline.

## Principio Fundamental

> **Oración no responde al usuario.**
> **Oración encuentra y presenta pasajes bíblicos relevantes.**
> **Toda respuesta visible para el usuario proviene de la Biblia.**

## Regla de Oro sobre la IA

- La IA **nunca** genera respuestas.
- La IA **nunca** actúa como Dios.
- La IA **nunca** produce texto libre para responder al usuario.
- La IA **solo** ayuda a encontrar pasajes relevantes.
- La respuesta final **siempre** proviene de la Biblia.

## Stack

| Capa | Tecnología |
|------|------------|
| Framework | Flutter 3.41+ / Dart 3.11+ |
| Estado / DI | Riverpod 2 |
| Navegación | GoRouter 14 |
| Base de datos | Drift (SQLite) + sqlite3_flutter_libs |
| Compartir | share_plus |
| File picker | file_picker |
| Path / FS | path_provider, path |
| Tipografía | Google Fonts (Lora + Inter, fallback sistema offline) |
| Logs | logger |
| Build pipeline | Python 3.11+ |

## Arquitectura

Clean Architecture + Feature First.

```
lib/
├── core/         Configuración, constantes, DB, DI, routing, servicios, errores
├── features/     chat, history, favorites, reader, settings, shell
├── shared/       theme, widgets
└── main.dart
```

## Estructura de Features

Cada feature sigue:

```
features/<feature>/
├── data/         (repos, datasources, models)
├── domain/       (entities, repositories, usecases)
└── presentation/ (providers, screens, widgets)
```

## Esquema de Base de Datos

| Tabla | Propósito | Mutabilidad |
|-------|-----------|-------------|
| `verses` | Catálogo bíblico (RV1909, 66 libros, 31,102 versículos) | Seed desde asset |
| `verse_tags` | Etiquetas semánticas (46 tags: emociones + necesidades + temas) | Seed desde asset |
| `conversations` | Conversaciones del usuario | Mutable |
| `messages` | Mensajes user/biblia | Mutable |
| `conversation_contexts` | Estado conversacional (centroid, tags, anti-repetición) | Mutable |
| `favorites` | Versículos guardados | Mutable |
| `settings` | Preferencias key-value (theme, font_scale, assets_version, …) | Mutable |
| `usage_stats` | Contadores locales (nunca se envían a servidores) | Mutable |

## Pipeline de Build del Corpus (offline, reproducible)

El corpus bíblico se genera **fuera de la app** en una DB SQLite pre-poblada
(`assets/bible/bible_assets.db`). La app solo lo extrae al primer arranque
(vía `AssetLoader`) y lo inserta en la base de drift `oracion_db`.

```
[Fuente externa: SQL con versículos RV1909]
        ↓
[tools/build_db.py]
        ↓
assets/bible/rv1909.json  (intermedio, regenerable)
        ↓
[tools/build_tags.py]
   ├─ tools/lexicon_seed.json  (46 tags: emociones + necesidades + temas)
   ├─ tools/verse_tags_manual.csv  (overrides del usuario)
        ↓
assets/bible/verse_tags_auto.csv / verse_tags_final.csv
        ↓
[tools/build_bible_db.py]
        ↓
assets/bible/bible_assets.db  (ASSET SHIPPED, ~9.5 MB)
assets/bible/bible_assets.manifest.json
```

**Estrategia de tags (oficial MVP):**

1. **Tags automáticos**: `lexicon_seed.json` define 46 tags (10 emociones,
   15 necesidades humanas, 21 temas bíblicos) con ~50 keywords cada uno
   (~2,300 keywords totales). `build_tags.py` escanea cada versículo y
   asigna los tags que matchean. Cobertura actual: **74.7%** de versículos
   tienen al menos 1 tag.

2. **Correcciones manuales**: `verse_tags_manual.csv` permite añadir
   (`add`), quitar (`remove`) o reemplazar (`set`) tags en versículos
   específicos. Las manuales tienen prioridad sobre las automáticas.

3. **Mejora gradual**: añadir keywords a `lexicon_seed.json` o filas a
   `verse_tags_manual.csv` y re-ejecutar `build_tags.py` +
   `build_bible_db.py`. No requiere cambios de arquitectura.

**Alias de display**: el corpus fuente nombra "Revelación" al último libro;
la UI lo muestra como "**Apocalipsis**" con subtítulo "Revelación"
(configurado en `bible_metadata_service.dart`).

## Requisitos

- Flutter 3.41+
- Dart 3.11+
- Python 3.11+ (solo para regenerar el corpus)
- Android 8.0+ (API 24+)
- Conexión a Internet: **NO requerida** (es offline-first)

## Setup

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Generar código Drift (app_database.g.dart y DAOs)
dart run build_runner build

# 3. (Solo desarrollo) Regenerar el corpus bíblico:
#    - herramientas en tools/ (build_db.py, build_tags.py, build_bible_db.py)
#    - ejecuta solo si cambias el lexicon o las correcciones manuales.
python tools/build_db.py
python tools/build_tags.py
python tools/build_bible_db.py

# 4. Ejecutar
flutter run
```

## Comandos Útiles

```bash
# Regenerar código Drift tras cambios en tablas
dart run build_runner build

# Modo release
flutter run --release

# Análisis estático
flutter analyze

# Tests
flutter test

# Build release APK
flutter build apk --release
```

## Roadmap

| Sprint | Entregable |
|--------|------------|
| 0 | Decisiones técnicas (cerrado) |
| 1 | Cimientos, navegación, DB vacía, tema (cerrado) |
| 2 | Corpus bíblico completo, Lector, Favoritos, Historial, Configuración, export/import (cerrado) |
| 3 | Bible Engine v1 (lexicon + tags + Top-K + MMR + feedback) (cerrado) |
| **4** | **Bible Engine v2 (BM25 + embeddings subword + MMR, sin fallback aleatorio)** ← aquí |
| 5 | Contexto conversacional (centroid, anti-repetición robusto) |
| 6 | Optimización y pulido Android |
| 7 | Publicación en Google Play |

## Estado del Proyecto

**Sprint 4 de 7** — En construcción.

Bible Engine v2: el usuario escribe una intención en español; la app
la expande con sinónimos curados, recupera candidatos con BM25, los
rerankea con embeddings subword (estilo fastText, OOV via subword
averaging), los diversifica con MMR y devuelve los 3 más relevantes
sin repetir los ya mostrados en la conversación. No hay fallback
aleatorio: si BM25 no encuentra coincidencias, la app lo dice
abiertamente al usuario.

Pipeline (Sprint 4, reencuadre):

```
  userInput
     │
     ▼
  tokenizer  ──►  meta_intent?  ──►  override curado
     │
     ▼
  query_expander (sinónimos curados ~60)
     │
     ▼
  BM25 top-K (k=100, k1=1.5, b=0.75)
     │
     ▼
  embedding rerank (subword average + cosine)
     │
     ▼
  score = 0.55·bm25 + 0.45·emb
     │
     ▼
  filter shown  ──►  MMR (diversifica por libro)  ──►  top-N
```

Corpus bíblico cargado: **31,102 versículos**.

## Licencia

- Aplicación: código propietario.
- Texto bíblico: **Reina-Valera 1909** (dominio público).
- Lexicon y tags: **MIT** (este repositorio).
- Fuente del corpus: `iglesianazaret/biblia-reina-valera-1909-base-datos-sql` (GitHub, public domain).
