# Plataforma no Histórico Financeiro — Documentação da Arquitetura Real

> Documento atualizado (FASE 3) da persistência de **plataformas** dentro da feature
> `financial_history`. Reflete o **padrão real consolidado**: `domain/` + contrato de
> repositório + implementação SQLite com SQL cru + service + controller + injection + view.
>
> ⚠️ Substituiu a versão antiga (que citava o arquivo inexistente
> `financial_history_platform_dao.dart` e a pasta `controller/`). Não há mais DAOs do Floor.

---

## 1. Visão Geral

A feature trata do catálogo de plataformas e do vínculo **plataforma ↔ dia de trabalho**:

- **`PlatformModel`** → catálogo persistido (UBER, BOLT, PARTICULAR, …).
- **`FinancialHistoryPlatformModel`** → entidade associativa (N plataformas por dia), com
  faturamento e nº de corridas de cada plataforma num dia.
- **`FinancialHistoryPlatformSummaryModel`** → **visão de domínio** (imutável) já resolvida
  para consumo da UI/controller: `name` + `totalValue` + `totalRides`.

A persistência NÃO usa DAO do Floor. Tudo é feito por **SQL cru** em
`FinancialHistoryRepositorySqliteImpl`, cujo contrato é `FinancialHistoryRepositoryInterface`.

---

## 2. Arquitetura em Camadas (padrão real)

```
FinancialHistoryView
        │  (conhece apenas o controller)
        ▼
FinancialHistoryController (ChangeNotifier)
        │   (conhece apenas a service)
        ▼
FinancialHistoryService  ──── orquestração de negócio
        │   (_ensurePlatform, _replacePlatformLinks, validação, SKU)
        │   (conhece apenas o contrato de repositório)
        ▼
FinancialHistoryRepositoryInterface  (contrato — `data/`)
        ▲   (implementação concreta tida apenas no ponto de composição)
        │
FinancialHistoryRepositorySqliteImpl  (`data/`) — SQL cru via `AppDatabase.database`
        │
        ▼
AppDatabaseBuilder (fonte de verdade do schema — `app/database/app_database.dart`)
```

Entidades (todas em `domain/`):

| Entidade | Arquivo | Papel |
|---|---|---|
| `FinancialHistoryPlatformSummaryModel` | `domain/financial_history_platform_summary_model.dart` | Visão de domínio (UI/controller) — `name`, `totalValue`, `totalRides`, `copyWith` |
| `FinancialHistoryPlatformModel` | `domain/financial_history_platform_model.dart` | Entidade SQLite `financial_history_platform` (FKs + valores crus) |
| `PlatformModel` | `domain/platform_model.dart` | Catálogo `platform` (id, name, isActive) |
| `FinancialHistoryModel` | `domain/financial_history_model.dart` | Registro diário (pai) — lista `platforms` + getters `totalEarnings`/`profit` |

### Fluxo de dados (sem DAO — só repositório + SQL cru)

```
┌────────────────────────── UI / Controller ───────────────────────────┐
│  FinancialHistoryView ↔ FinancialHistoryController                   │
│        trabalha com FinancialHistoryPlatformSummaryModel (nome+totais)│
└────────────────────────────────┬─────────────────────────────────────┘
                                 │
                                 ▼
   FinancialHistoryService  (_ensurePlatform + _replacePlatformLinks)
                                 │
                                 ▼
   FinancialHistoryRepositorySqliteImpl  (SQL cru)
      ├── lê/escreve `financial_history_platform` (associativo)
      ├── resolve catálogo `platform` via rawQuery
      └── monta FinancialHistoryPlatformSummaryModel (nome + totais)
```

---

## 3. A Ponte Repository ⇄ Domínio

### 3.1 Entidade de persistência (`FinancialHistoryPlatformModel`)

Arquivo: `lib/features/financial_history/domain/financial_history_platform_model.dart`

Contém só FKs e valores crus: `id`, `financialHistoryId`, `platformId`, `dailyEarnings`, `dailyTripCount`.

### 3.2 Contrato (`FinancialHistoryRepositoryInterface`)

Arquivo: `lib/features/financial_history/data/financial_history_repository_interface.dart`

Expõe, entre outros:
- `getPlatformLinksByFinancialHistoryId(id)` → `List<FinancialHistoryPlatformModel>`
- `insertPlatformLink(...)`, `deletePlatformLinksByFinancialHistoryId(id)`
- `getPlatformById(id)`, `getAllPlatforms()`, `insertPlatform(...)` — acesso ao catálogo `platform`

### 3.3 Implementação SQLite (`FinancialHistoryRepositorySqliteImpl`)

Arquivo: `lib/features/financial_history/data/financial_history_repository_sqlite_impl.dart`

Todas as operações usam **SQL cru** sobre `AppDatabase.database` (sem DAO):

```dart
// Buscar plataforma por id
final rows = await db.database.rawQuery(
  'SELECT * FROM platform WHERE id = ?',
  [id],
);

// Listar catálogo ordenado por nome
final rows = await db.database.rawQuery(
  'SELECT * FROM platform ORDER BY name ASC',
);

// Persistir catálogo
await db.database.insert('platform', model.toMap(),
    conflictAlgorithm: sqflite.ConflictAlgorithm.abort);
```

### 3.4 Service — `_ensurePlatform` (orquestração do catálogo)

Arquivo: `lib/features/financial_history/financial_history_service.dart`

O service (e não o repositório) é quem garante que a plataforma exista no catálogo
(busca **case-insensitive** por nome; se não existir, cria e reutiliza o id) e depois
grava os vínculos associativos:

```dart
Future<String> _ensurePlatform(String name) async {
  final String normalized = name.trim().toUpperCase();
  final List<PlatformModel> all = await _storage.getAllPlatforms();
  for (final PlatformModel platform in all) {
    if (platform.name.trim().toUpperCase() == normalized) {
      return platform.id;
    }
  }
  final PlatformModel created = PlatformModel(id: _newId(), name: normalized);
  await _storage.insertPlatform(created);
  return created.id;
}
```

E `_replacePlatformLinks` deleta os vínculos antigos e insere os novos a cada `save`.

---

## 4. Visão de Domínio — `FinancialHistoryPlatformSummaryModel`

Arquivo: `lib/features/financial_history/domain/financial_history_platform_summary_model.dart`

Modelo imutável consumido pela UI/controller:

```dart
class FinancialHistoryPlatformSummaryModel {
  final String name;        // Ex.: UBER, BOLT, FREENOW, PARTICULAR
  final double totalValue;  // Faturamento do dia nessa plataforma (€)
  final int totalRides;     // Nº de corridas do dia nessa plataforma
  // copyWith(...)
}
```

É alimentado por `FinancialHistoryRepositorySqliteImpl.getById` (join nome do catálogo +
totais do associativo) e consumido por `FinancialHistoryService.getById` para montar o
report com `platforms` resolvido.

### Não confundir com `FinancialHistoryPlatformModel`

| | `FinancialHistoryPlatformSummaryModel` | `FinancialHistoryPlatformModel` |
|---|---|---|
| **Camada** | Domínio (visão resolvida) | Persistência (entidade SQLite) |
| **Tabela** | Nenhuma (não é `@Entity`) | `financial_history_platform` |
| **Contém** | `name`, `totalValue`, `totalRides` | `id`, `financialHistoryId`, `platformId`, `dailyEarnings`, `dailyTripCount` |
| **Nome da plataforma** | Sim (resolvido no repositório) | Não (vive no catálogo `platform`) |
| **Consumido por** | UI / Controller | Repositório (SQL cru) |

---

## 5. `FinancialHistoryController` (estado da tela)

Arquivo: `lib/features/financial_history/financial_history_controller.dart`

`ChangeNotifier` injetado na view. Manipula `FinancialHistoryPlatformSummaryModel`:

| Método | Finalidade |
|---|---|
| `addPlatform({name, totalValue, totalRides})` | Adiciona plataforma (valores negativos → 0) à lista `_report.platforms` |
| `updatePlatform(index, {...})` | Atualiza via `copyWith` (imutabilidade preservada) |
| `removePlatform(index)` | Remove do índice informado (with bounds check) |

Sempre via nova lista `List.of(...)` + `copyWith(platforms:)` + `notifyListeners()`.

---

## 6. Service — regras de negócio

Arquivo: `lib/features/financial_history/financial_history_service.dart`

- Conhece apenas `FinancialHistoryRepositoryInterface`.
- `getById` → carrega report + resolve `platforms` (nome/totais) a partir do repositório.
- `save` → valida, gera SKU, persiste e re-sincroniza os vínculos de plataforma via
  `_replacePlatformLinks` (que usa `_ensurePlatform`).
- `delete` → remove report (FKs com `ON DELETE CASCADE` removem vínculos).
- Validações de negócio (KM, valores não negativos) antes de persistir.

---

## 7. Injeção de Dependência

Arquivo: `lib/features/financial_history/financial_history_injection.dart`

Registra em `get_it`:
- `FinancialHistoryRepositoryInterface` → `FinancialHistoryRepositorySqliteImpl` (singleton);
- `FinancialHistoryService` (singleton, com o repositório injetado);
- `FinancialHistoryController` (factory — uma por tela).

É o **único** ponto da feature que conhece a implementação concreta de persistência.

---

## 8. Referências Cruzadas (caminhos reais)

| Artefato | Caminho |
|---|---|
| Visão de domínio (plataforma do dia) | `lib/features/financial_history/domain/financial_history_platform_summary_model.dart` |
| Entidade associativa | `lib/features/financial_history/domain/financial_history_platform_model.dart` |
| Catálogo | `lib/features/financial_history/domain/platform_model.dart` |
| Entidade diária (pai) | `lib/features/financial_history/domain/financial_history_model.dart` |
| Contrato do repositório | `lib/features/financial_history/data/financial_history_repository_interface.dart` |
| Implementação SQLite (SQL cru) | `lib/features/financial_history/data/financial_history_repository_sqlite_impl.dart` |
| Regras de negócio (service) | `lib/features/financial_history/financial_history_service.dart` |
| Estado da tela (controller) | `lib/features/financial_history/financial_history_controller.dart` |
| DI (composição) | `lib/features/financial_history/financial_history_injection.dart` |
| View | `lib/features/financial_history/financial_history_view.dart` + `widgets/` |
| Schema (fonte de verdade) | `lib/app/database/app_database.dart` (`AppDatabaseBuilder`) |

**Obs.:** os DAOs do Floor (`platform_dao.dart`, `extra_expenses_dao.dart`, `daos_impl.dart`)
e a pasta `lib/features/financial_history/controller/` **foram removidos** nas FASES 2 e 3.
Não existem mais no código produtivo.
