# ride_driver_app_1 — Agent Instructions

Flutter app for ride-share drivers, in early development. Much of the scaffolding (routing, theme, helpers) is still placeholder `todo.dart` files — expect to build things out, not just modify.

## Toolchain (FVM required)

Flutter is pinned to **3.44.7** via [.fvmrc](.fvmrc). Always prefix flutter/dart commands with `fvm`:

- **Dependencies**: keep minimal — currently `dio`, `floor`, `sqflite`, `path`. Add to [pubspec.yaml](pubspec.yaml) and run `fvm flutter pub get`. After modifying Floor entities/DAOs, run `fvm dart run build_runner build --delete-conflicting-outputs`.
- Code comments are sometimes in Portuguese (pt-BR); the user communicates in Portuguese.

## Database (SQLite via Floor)

This project uses **Floor** ORM for local SQLite persistence. Running `build_runner` generates the database code from annotated `@Entity` classes and `@dao` abstract classes.

### Current schema

Entities defined in `lib/app/database/app_database.dart`:

- `FinancialHistoryModel` → `financial_history` (registro diário) (entidade unificada em `lib/features/financial_history/domain/financial_history_model.dart`)
- `PlatformModel` → `platform` (catálogo de plataformas: UBER, BOLT, …)
- `FinancialHistoryPlatformModel` → `financial_history_platform` (tabela associativa com FKs)

Relationships:
- `financial_history` 1 ──< `financial_history_platform` >── 1 `platform`

### Regenerating code

- [lib/main.dart](lib/main.dart) is still the default counter app; [test/widget_test.dart](test/widget_test.dart) is the default smoke test tied to it. Replacing `main.dart` will break that test — update it together.
- `lib/app/{helper,routing,theme}/todo.dart` are empty placeholders awaiting implementation.
- State management and routing approaches are not yet chosen — ask before introducing a new package (e.g. provider/riverpod/go_router).
- **Naming convention**: feature folders, classes, and files are in **English**. Table names in SQLite are in `snake_case`.

