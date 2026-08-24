# FASE 2 — REORGANIZAÇÃO: Unificação da Persistência SQLite

> POC **ride_driver_app_1** · Baseado no diagnóstico de `DIAGNOSTICO_FASE_1.md`.

## Objetivo
Reorganizar fisicamente as entidades e eliminar o paradigma **DAO/Floor** legado,
migrando `platform` e `extra_expenses` para a estrutura em camadas (`domain/data`)
usada pela feature modelo `financial_history`. **Não** foram criadas service/controller/view
novas para essas entidades (ficam para fase futura, se necessário).

---

## 🔍 Verificação de execução
- **`fvm flutter analyze --no-pub`** → **No issues found** ✅

---

## 1. Entidades movidas para `lib/features/financial_history/domain/`

| Antes | Depois | Observação |
|---|---|---|
| `lib/features/platform/platform_model.dart` | `lib/features/financial_history/domain/platform_model.dart` | Classe `PlatformModel`, `@Entity(tableName: 'platform')` |
| `lib/features/extra_expenses/extra_expenses_model.dart` | `lib/features/financial_history/domain/extra_expenses_model.dart` | Classe `ExtraExpensesModel`, `@Entity(tableName: 'extra_expenses')` |

Ambas mantêm as annotations Floor `@Entity`/`@primaryKey` (nas models de `financial_history`
também já eram mantidas), mas agora **topam o domínio da feature modelo**, e a doc internal
foi atualizada para deixar claro que a persistência é via **SQL cru no repositório** e não por DAO.

## 2. Paradigma Floor/DAO eliminado

Foram **removidos** (via `git rm`):
- `lib/features/platform/platform_dao.dart` → `PlatformDao`
- `lib/features/extra_expenses/extra_expenses_dao.dart` → `ExtraExpensesDao`
- `lib/app/database/daos_impl.dart` → `PlatformDaoImpl` e `ExtraExpensesDaoImpl`
- As pastas `lib/features/platform/` e `lib/features/extra_expenses/` ficaram vazias e foram removidas.

O acesso aos dados de `PlatformModel` agora é feito pelo **repositório com SQL cru**, no mesmo padrão
de `financial_history_repository_sqlite_impl.dart`:

`lib/features/financial_history/data/financial_history_repository_sqlite_impl.dart`
- `getPlatformById` → `rawQuery('SELECT * FROM platform WHERE id = ?', [id])`
- `getAllPlatforms` → `rawQuery('SELECT * FROM platform ORDER BY name ASC')`
- `insertPlatform` → `db.database.insert('platform', model.toMap(), ...)`

*(Nota: o `ExtraExpensesModel` também migra para `domain/`, mas como ainda não há controller/service
de despesas extras nem repo voltado a ele, a persistência dele continua esperando a fase futura; o
schema da tabela já está no `app_database.dart`.)*

## 3. Schema unificado em `lib/app/database/app_database.dart`

- **Removida a exposição pública de `platformDao` e `extraExpensesDao`** da interface `AppDatabase`.
- **Removidos** os imports de `daos_impl.dart`, `platform_dao.dart`, `extra_expenses_dao.dart`
  e a instanciação `PlatformDaoImpl`/`ExtraExpensesDaoImpl` em `_AppDatabase`.
- Mantida a **fonte de verdade única** compatível com o padrão modelo: `AppDatabaseBuilder`
  (builder manual sqflite + SQL DDL em `_createTables`).
- `AppDatabase` agora expõe **apenas** `sqflite.Database get database` + `close()`.

## 4. Migrações — `lib/app/database/migrations.dart`

**Nenhuma alteração necessária.** As migrações (`migration1to2`, `migration2to3`) já são
independentes da camada de DAO (usam callbacks `Migration` com SQL puro) e não referenciam
`platformDao`/`extraExpensesDao`. O histórico de migrações v1→v3 está **preservado**.

## 5. Imports/dependências corrigidos

| Arquivo | Ajuste |
|---|---|
| `lib/features/financial_history/domain/financial_history_platform_model.dart` | Import de `PlatformModel` apontando para `platform_model.dart` (mesma pasta) |
| `lib/features/financial_history/domain/extra_expenses_model.dart` | Import de `FinancialHistoryModel` via mesmo diretório (`financial_history_model.dart`) |
| `lib/features/financial_history/data/financial_history_repository_interface.dart` | Import de `PlatformModel` → `domain/platform_model.dart` |
| `lib/features/financial_history/data/financial_history_repository_sqlite_impl.dart` | Import de `PlatformModel` → `domain/platform_model.dart`; substituídas as chamadas `db.platformDao.*` por SQL cru |
| `lib/features/financial_history/financial_history_service.dart` | Import de `PlatformModel` → `domain/platform_model.dart` |

---

## Estrutura final de `lib/features/financial_history/domain/`
```
domain/
├── extra_expenses_model.dart              # (movido) Entity extra_expenses
├── financial_history_model.dart           # Entity financial_history
├── financial_history_platform_model.dart  # Entity associativa
├── financial_history_platform_summary_model.dart  # DTO de visão
└── platform_model.dart                    # (movido) Entity platform
```

## Notas
- Documentação manual (`ANALISE_*`, `DOCUMENTACAO_*`, `NORMALIZACAO_*`, `DIAGNOSTICO_FASE_1.md`)
  e backups de `lib/to_trash_bkp/` **não foram tocados** (fora do escopo dos `.dart` de produção).
- Após a FASE 2, os dois paradigmas de persistência convergiram para **um único**: SQL cru no
  repositório + builder manual sqflite como fonte de verdade do schema.

---

*Fase concluída. Aguardando instrução para iniciar a FASE 3.*
