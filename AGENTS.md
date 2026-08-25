# ride_driver_app_1 — Agent Instructions

Flutter app for ride-share drivers, in early development. Much of the scaffolding (routing, theme, helpers) is still placeholder `todo.dart` files — expect to build things out, not just modify.

## Toolchain (FVM required)

Flutter is pinned to **3.44.7** via [.fvmrc](.fvmrc). Always prefix flutter/dart commands with `fvm`:

- **Dependencies**: keep minimal — currently `sqflite`, `path`, `get_it`. Add to [pubspec.yaml](pubspec.yaml) and run `fvm flutter pub get`.
## Database (SQLite, SQL cru)

This project uses **sqflite** with **raw SQL** (SQL cru) for local SQLite persistence.
**Não há** ORM/Floor nem geração de código (`@dao`, `@Database`, `build_runner`). O schema
é definido manualmente em `lib/app/database/app_database.dart` (`createSchema`), e não há
migrações (POC: bancos locais são recriados).
### Current schema

Tables defined in `lib/app/database/app_database.dart` (`createSchema`):

- `financial_history` (registro diário)
- `financial_history_platform` (tabela associativa com FKs)
- `platform` (catálogo de plataformas: UBER, BOLT, …)
Relationships:
- `financial_history` 1 ──< `financial_history_platform` >── 1 `platform`

### Regenerating code

- [lib/main.dart](lib/main.dart) is still the default counter app; [test/widget_test.dart](test/widget_test.dart) is the default smoke test tied to it. Replacing `main.dart` will break that test — update it together.
- `lib/app/{helper,routing,theme}/todo.dart` are empty placeholders awaiting implementation.
- State management and routing approaches are not yet chosen — ask before introducing a new package (e.g. provider/riverpod/go_router).
- **Naming convention**: feature folders, classes, and files are in **English**. Table names in SQLite are in `snake_case`.

