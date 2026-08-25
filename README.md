# ride_driver_app_1

Aplicativo Flutter (POC) para **motoristas de aplicativo de corrida**, com gestão
local de histórico financeiro diário (quilotaves, gastos de combustível, plataformas
e despesas extras), persistido em SQLite.

> Documento de contexto da arquitetura.

---

## O que é esta POC

Aplicativo **em desenvolvimento inicial** (POC) voltado ao fluxo de trabalho diário de um
motorista de aplicativo: registrar um dia de trabalho — quilotaves rodados, gastos com
combustível/energia, valores e corridas por plataforma (UBER, BOLT, PARTICULAR…) — e, a
partir disso, visualizar totais/resultado por dia.

É uma **POC**: a persistência é **local e temporária** (SQLite no dispositivo), sem
backend/API. O objetivo é validar o fluxo e a arquitetura antes de qualquer decisão de
dados definitiva. Nenhum dado real de usuário em produção — o banco local pode ser
recriado sempre que necessário, sem migrações.

---

## Padrão Arquitetural

O projeto adota **DDD Tático em camadas**, com a feature `financial_history` como
**feature modelo** e referência para as demais:

```
feature/
├── domain/                  → Entidades puras (models) — sem ORM; SQL cru via toMap/fromMap, ou DTOs de visão
│   ├── <entidades>_model.dart        (persistidas via SQL cru no repositório)
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
- **Persistência = SQL cru** no repositório (`rawQuery`/`insert`/`update`/`delete` sobre a
  conexão `sqflite.Database` devolvida por `openAppDatabase()`). **Não** há ORM/DAO/Floor.
- **Entidades puras** (sem annotations ORM): o mapeamento para as tabelas é feito por
  `toMap`/`fromMap` no SQL cru. Não há geração de código nem `@Database`/`@dao`.
- **DI unificada** via `get_it` (service locator global em `lib/app/di/service_locator.dart`).

---

## `lib/app/database/` — papel restrito

`lib/app/database/app_database.dart` é responsável pela **inicialização do banco e pela
definição do schema (DDL)**, servindo de infraestrutura comum às features:

| Símbolo | Papel |
|---|---|
| `openAppDatabase()` | Singleton lazy que abre e devolve a conexão **`sqflite.Database` bruta** (versão 1). |
| `createSchema(db)` | **Fonte de verdade do schema** — cria `financial_history`, `financial_history_platform` e `platform` com FKs/índices/`ON DELETE CASCADE`. |

**Não há migrações** nem `migrations.dart`: por ser POC sem dados reais a preservar, o
banco é criado a partir do DDL inicial (e pode ser recriado localmente). As queries de
negócio ficam **nos repositórios de cada feature**, não aqui.

---

## Entidades compartilhadas

Entidades consumidas transversalmente pela feature modelo ficam no domínio de
`lib/features/financial_history/domain/`:

- `PlatformModel` → catálogo de plataformas (UBER, BOLT, PARTICULAR, …)
- `ExtraExpensesModel` → despesas extras (alimentação, bebidas, …) — modelo puro no
  domínio; **ainda não persistido** (a feature/UI não está implementada)

Junto às demais entidades da feature (`FinancialHistoryModel`,
`FinancialHistoryPlatformModel`, `FinancialHistoryPlatformSummaryDTO`).

---

## Estrutura resumida de `lib/`

```
lib/
├── main.dart
├── app/
│   ├── database/app_database.dart  → inicialização + schema (openAppDatabase + createSchema)
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
- Dependências principais: `sqflite`, `path`, `get_it`.
- Sem dependências de estado/REST/ORM ociosas (`dio`, `floor`, geração de DAO removidas).

---

## Próximos passos (resumo)

- Implementar telas reais para as features hoje **mock** (`history`, `search`,
  `home_add_ride`, `tour_in_progress`, `data_storage`), seguindo o padrão da feature
  modelo.
- Criar a pilha `domain/data/service/controller/injection/view` para `extra_expenses`
  (e `platform`, se houver gestão na UI).
- Criar testes automatizados em `test/`.

> Detalhamento executivo e histórico do ciclo de reorganização em
> `CONSOLIDACAO_ARQUITETURAL_FINAL.md` e `PERSISTENCIA_SQLITE.md`.
