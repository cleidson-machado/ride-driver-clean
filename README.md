# ride_driver_app_1

Aplicativo Flutter (POC) para **motoristas de aplicativo de corrida**, com gestão
local de histórico financeiro diário (quilotaves, gastos de combustível, plataformas
e despesas extras), persistido em SQLite.

> Documento de contexto da arquitetura (revisado na **FASE 4** — Consolidação Final).

---

## Padrão Arquitetural

O projeto adota **DDD Tático em camadas**, com a feature `financial_history` como
**feature modelo** e referência para as demais:

```
feature/
├── domain/                  → Entidades puras (models) — anotação Floor/persistência ou DTOs
│   ├── <entidades>_model.dart        (@Entity para schema; SQL cru na persistência)
│   └── <...>_summary_model.dart      (DTO/visão de domínio, não persistido)
├── data/                    → Contrato + implementação SQLite (SQL cru)
│   ├── <feature>_repository_interface.dart
│   └── <feature>_repository_sqlite_impl.dart
├── <feature>_service.dart   → Service (Use-Case / regras de negócio)
├── <feature>_controller.dart→ Controller (ChangeNotifier — estado da tela)
├── <feature>_injection.dart → DI via get_it (registra interface → impl, service, factory do controller)
├── <feature>_view.dart      → View (Flutter)
└── widgets/                 → Widgets de UI específicos da feature
```

### Regras-chave
- **Infraestrutura concreta só no ponto de composição** (`<feature>_injection.dart`).
  A service conhece apenas o contrato (`..._repository_interface.dart`); o controller
  conhece apenas a service; a view conhece apenas o controller.
- **Persistência = SQL cru** no repositório (`rawQuery`/`insert`/`update`/`delete` sobre
  `AppDatabase.database`). **Não** há DAOs do Floor em produção.
- **Entidades anotadas com `@Entity` do Floor** apenas para documentar o schema; não há
  geração de código nem `@Database`/`@dao`.
- **DI unificada** via `get_it` (service locator global em `lib/app/di/service_locator.dart`).

---

## `lib/app/database/` — papel restrito

`lib/app/database/` é responsável **somente** pela **inicialização do banco e pela
definição de migrações/schema (DDL)**, servindo de infraestrutura comum às features:

| Arquivo | Papel |
|---|---|
| `app_database.dart` | `AppDatabaseBuilder` — **fonte de verdade do schema** (builder manual sqflite + `_createTables`). Expõe `AppDatabase.database` (conexão bruta) e `close()`. *Não* expõe DAOs. |
| `migrations.dart` | Migrações DDL v1→v2 (tabela `extra_expenses`) e v2→v3 (colunas do formulário). |

As queries de negócio ficam **nos repositórios de cada feature**, não aqui.

---

## Entidades compartilhadas

Entidades consumidas transversalmente pela feature modelo ficam no domínio de
`lib/features/financial_history/domain/`:

- `PlatformModel` → catálogo de plataformas (UBER, BOLT, PARTICULAR, …)
- `ExtraExpensesModel` → despesas extras (alimentação, bebidas, …)

Ambas foram movidas para esse domínio na **FASE 2** de reorganização (unificação da
persistência), junto às demais entidades da feature (`FinancialHistoryModel`,
`FinancialHistoryPlatformModel`, `FinancialHistoryPlatformSummaryDTO`).

---

## Estrutura resumida de `lib/`

```
lib/
├── main.dart
├── app/
│   ├── database/         → inicialização + schema/migrações (AppDatabaseBuilder)
│   ├── di/service_locator.dart  → setupServiceLocator() (get_it)
│   ├── generic/base_model.dart  → contrato mínimo (id, toMap) usado pelas entidades
│   ├── helper/ride_formatters.dart
│   └── theme/app_theme.dart
├── features/
│   ├── financial_history/       → FEATURE MODELO (camadas completas)
│   └── history/ · search/ · tour_in_progress/ · home_add_ride/ · data_storage/
│                                   → telas mock (aguardando implementação)
└── to_trash_bkp/                → backups/histórico (não fazem parte do código produtivo)
```

---

## Ferramentas / Toolchain

- **FVM** com Flutter fixado via `.fvmrc`. Use sempre `fvm flutter ...`.
- Dependências principais: `floor` (entidades/migrações), `sqflite`, `path`, `get_it`.
- Sem dependências de estado/REST ociosas (`dio`, geração de DAO removidas).

---

## Próximos passos (resumo)

Ver `CONSOLIDACAO_ARQUITETURAL_FINAL.md` para o detalhamento executivo. Resumidamente:

- Implementar telas reais para as features hoje **mock** (`history`, `search`,
  `home_add_ride`, `tour_in_progress`, `data_storage`), seguindo o padrão da feature
  modelo.
- Criar a pilha `domain/data/service/controller/injection/view` para `extra_expenses`
  (e `platform`, se houver gestão na UI).
- Criar testes automatizados em `test/`.
