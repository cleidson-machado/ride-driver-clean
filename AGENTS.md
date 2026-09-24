# ride_driver_app_1 - Agent Instructions

Flutter app for ride-share drivers. Use the feature-based architecture described in [README.md](README.md); detailed architectural decisions are recorded in [CONSOLIDACAO_ARQUITETURAL_FINAL.md](CONSOLIDACAO_ARQUITETURAL_FINAL.md).

## Toolchain

- Flutter is pinned to `3.44.7` in [.fvmrc](.fvmrc). Prefix every Flutter or Dart command with `fvm`.
- Run `fvm flutter pub get` after editing [pubspec.yaml](pubspec.yaml), `fvm dart format <paths>` for formatting, and `fvm flutter analyze` for static analysis.
- `fvm flutter test` is valid but the project currently has no committed test files. Add focused tests for new behavior.
- Keep dependencies minimal. The current runtime packages are `sqflite`, `path`, and `get_it`; ask before introducing state-management or routing packages.

## Application Structure

- [lib/main.dart](lib/main.dart) initializes Flutter bindings and the service locator, then starts `RideDriverApp` with the M3 light/dark themes.
- Implement features under `lib/features/<feature>/`. Domain models are pure Dart and implement `BaseModel`; data repositories perform storage; services own business rules; `ChangeNotifier` controllers serve the UI.
- Register feature dependencies in `lib/features/<feature>/<feature>_injection.dart` and call the registration from [lib/app/di/service_locator.dart](lib/app/di/service_locator.dart). Repositories and services are lazy singletons; controllers are factories.
- Views resolve controllers via `getIt<Controller>()`. Do not instantiate concrete repositories or services in views.
- Use English for feature directories, files, and class names. SQLite identifiers use `snake_case`.

## Persistence

- SQLite uses `sqflite` with raw SQL. The single schema source is [lib/app/database/app_database.dart](lib/app/database/app_database.dart); do not add an ORM, Floor annotations, DAOs, or code generation.
- This POC recreates the database on schema changes rather than preserving data through incremental migrations. Keep foreign-key relationships and platform seeding consistent with the schema.
- See [PERSISTENCIA_SQLITE.md](PERSISTENCIA_SQLITE.md) for database rules and [DOCUMENTACAO_FINANCIAL_HISTORY_PLATFORM.md](DOCUMENTACAO_FINANCIAL_HISTORY_PLATFORM.md) for the financial-history model.

## Existing Guidance

- Use [.github/skills/material3-flutter-ui/SKILL.md](.github/skills/material3-flutter-ui/SKILL.md) for Flutter UI, Material 3, accessibility, and responsive-layout work.
- Use [.github/skills/ride-driver-flutter-data/SKILL.md](.github/skills/ride-driver-flutter-data/SKILL.md) for SQLite, financial history, repositories, and data-flow work.
- Consult [LIMPEZA_VALIDACAO_FASE_3.md](LIMPEZA_VALIDACAO_FASE_3.md) before restoring legacy persistence or generic CRUD abstractions that were intentionally removed.

