# Persistência SQLite no Projeto (POC · DDD Tático)

> **Documento de análise** — explica **como** e **quais** features do projeto utilizam
> a persistência local em SQLite, com base na leitura de
> [`lib/app/database/app_database.dart`](lib/app/database/app_database.dart) e das camadas
> da feature modelo.
>
> **Natureza da persistência:** o projeto é uma **POC** e o armazenamento é
> **temporário** (SQLite local, apenas no dispositivo). Não há backend/API — toda a
> escrita/leitura é local e destina-se a validar o fluxo das features antes de qualquer
> decisão de arquitetura de dados definitiva.
>
> **Estado atual e simplificação:** esta versão do documento reflete a **simplificação
> deliberada** da camada de persistência (remoção de migrações, do pacote `floor` e do
> `AppDatabaseBuilder` over-engineered). Ver seção [9. Resumo das decisões](#9-resumo-das-decisões).

---

## 1. Visão geral

O projeto adota **DDD Tático em camadas**. A feature **`financial_history`** é a
**feature modelo** — é a **única** com a pilha completa
(`domain → data → service → controller → injection → view`). Todas as demais features
(`history`, `search`, `home_add_ride`, `tour_in_progress`, `data_storage`) são **views
mock** (dados `static const`), **sem** camada de dados e **sem** persistência.

Portanto, do ponto de vista real de código, **apenas a feature `financial_history`**
consome a persistência hoje (`financial_history`, `financial_history_platform` e o
catálogo `platform`). Não há modelo/feature de despesas extras: o `ExtraExpensesModel`
foi **removido** (código morto — sem tabela, sem repositório e sem uso real).

---

## 2. Arquitetura da persistência

### 2.1 O arquivo `lib/app/database/app_database.dart`

É o **único** arquivo da camada de banco. Responsável pela **inicialização do banco** e
definição do **schema (DDL)** de forma direta:

- `openAppDatabase()` → **singleton lazy** que abre e devolve a conexão **`sqflite.Database` bruta** (única vez).
- `schemaVersion` → versão do schema (hoje **1**).
- `createSchema(db)` → define o **schema completo** (fonte de verdade única do DDL).

**Não há** `AppDatabase` interface, `AppDatabaseBuilder`, DAOs, nem migrações
incrementais — a POC abre o banco diretamente com `sqflite.openDatabase` (schema criado no
`onCreate`).

```dart
const int schemaVersion = 1;

Future<sqflite.Database> openAppDatabase() {
  return _dbFuture ??= _open();
}

// _open(...) usa sqflite.openDatabase(
//   version: schemaVersion,
//   onConfigure: /* PRAGMA foreign_keys = ON */,
//   onCreate: createSchema,      // define todas as tabelas/índices
//   onUpgrade: _recreateSchema,  // drop + create quando a versão sobe
//   onDowngrade: _recreateSchema,// drop + create quando a versão desce
// );
```

**Evolução de schema sem migrações (estratégia "recriar"):** como não há dados reais a
preservar, `onUpgrade`/`onDowngrade` **descartam o banco antigo** (`_dropAllTables`) e o
recriam de zero via `createSchema`. Assim, ao mudar o DDL basta **incrementar
`schemaVersion`** — a abertura de um banco antigo regera tudo pelo schema novo. Sem isso,
a simples mudança de versão deixaria o banco antigo intacto (schema defasado) sem retorno
de erro.

### 2.2 Fluxo de escrita/leitura (SQL cru)

A camada de dados usa `openAppDatabase()` (singleton) para obter a conexão bruta e
executa `rawQuery` / `insert` / `update` / `delete` **diretamente** sobre o
`sqflite.Database`:

```dart
final sqflite.Database db = await openAppDatabase();
final rows = await db.rawQuery('SELECT * FROM financial_history ORDER BY work_date DESC');
// ...
await db.insert('financial_history', model.toMap(), conflictAlgorithm: ...);
```

Trocar a tecnologia de armazenamento (ex.: REST API) exigiria apenas fornecer **outra
implementação do contrato** (interface), sem alterar service/controller.

---

## 3. Schema atual (3 tabelas)

Definido em `createSchema()` de `app_database.dart` (versão do banco = **1**).

| Tabela | Propósito | FK |
|---|---|---|
| `financial_history` | Registro diário de trabalho (data, km, gastos, flags do formulário). | — |
| `financial_history_platform` | Tabela **associativa** N:M entre dia e plataforma (faturamento/corridas por dia). | `financial_history.id`, `platform.id` (CASCADE) |
| `platform` | Catálogo de plataformas (UBER, BOLT, PARTICULAR, …). | — |

> ℹ️ **Removida:** a tabela `extra_expenses` (e seu índice `idx_ee_...`) **não** existe
> no schema, pois a feature não é implementada (ver decisões na seção 9). O modelo
> `ExtraExpensesModel` também foi **removido** (código morto) — será recriado junto com a
> feature, quando ela existir.

### Relacionamento
```
financial_history (1) ──< financial_history_platform >── (1) platform
```

- **`ON DELETE CASCADE`:** apagar um dia remove também seus vínculos de plataforma —
  mantém a integridade referencial local.
- **Índices:** `idx_fhp_financial_history_id`, `idx_fhp_platform_id` (sobre a tabela
  associativa, usada nas consultas da feature).

> ❗ Detalhe técnico: SQLite não tem `BOOLEAN` nativo. Flags como `is_active`,
> `hodo2_is_zero`, `has_images` e `is_finished` são persistidas como **INTEGER 0/1** e
> convertidas de/para `bool` nas models (`fromMap`/`toMap`).

---

## 4. Migrações — **removidas** (substituídas por "drop + recreate")

✅ **Não há mais migrações incrementais.** Em uma POC sem usuários em produção nem dados
reais a preservar, migrações (`v1→v2`, `v2→v3`, com `ALTER TABLE` etc.) eram
**over-engineering**: adicionavam complexidade sem nenhum benefício real. O schema completo
é definido no DDL inicial (`onCreate`) e a evolução de schema **recria o banco**:

- ao **incrementar `schemaVersion`** e abrir um banco antigo, o `onUpgrade`
  (`_recreateSchema`) **descarta as tabelas** e chama `createSchema` de novo;
- o `onDowngrade` usa a mesma estratégia (simétrico).

> `lib/app/database/migrations.dart` foi **excluído**, o `AppDatabaseBuilder.addMigrations`
> foi removido e a versão do banco voltou para **1** (`schemaVersion`).

---

## 5. Como a feature `financial_history` usa a persistência

### 5.1 Camadas e responsabilidades

```
view (FinancialHistoryView) → controller (ChangeNotifier)
        → service (FinancialHistoryService — regras de negócio)
        → data/contract (FinancialHistoryRepositoryInterface)
        → data/impl sqlite (FinancialHistoryRepositorySqliteImpl — SQL cru)
        → app_database.dart (openAppDatabase → sqflite.Database)
```

**Regra de dependência (inversão):**
- **service** conhece **apenas a interface** do repositório (nunca a implementação concreta);
- **controller** conhece **apenas a service**;
- **view** conhece **apenas o controller**;
- **injection** (`financial_history_injection.dart`) é o **único** ponto que instancia a
  implementação concreta (`FinancialHistoryRepositorySqliteImpl`) e registra tudo no
  `get_it` (service locator global em `app/di/service_locator.dart`).

### 5.2 Operações persistidas (o que a feature grava/ler no SQLite)

| Método do repositório | Tabela | Operação |
|---|---|---|
| `getAll()` | `financial_history` | `SELECT * ORDER BY work_date DESC` |
| `getById(id)` | `financial_history` | `SELECT * WHERE id = ?` |
| `insert(model)` / `update(model)` | `financial_history` | INSERT/UPDATE (CRUD, `abort` em conflito) |
| `deleteById(id)` | `financial_history` | DELETE (`ON DELETE CASCADE` remove os vínculos) |
| `getPlatformLinksByFinancialHistoryId(id)` | `financial_history_platform` | listar plataformas do dia |
| `deletePlatformLinksByFinancialHistoryId(id)` | `financial_history_platform` | reescrever os vínculos |
| `insertPlatformLink(model)` | `financial_history_platform` | INSERT vínculo |
| `getPlatformById(id)` / `getAllPlatforms()` | `platform` | leitura do catálogo |
| `insertPlatform(model)` | `platform` | upsert no catálogo |

### 5.3 Regras de negócio que orquestram a persistência (na service)

No ato de **salvar** (`FinancialHistoryService.save`):

1. **Valida** as regras mínimas (`_validate`): km não negativo, `km_out >= km_in`, gastos não negativos — lança `FinancialHistoryValidationException` se falhar.
2. **Verifica** se o registro já existe (`getById`) para decidir INSERT ou UPDATE.
3. Gera **SKU** sequencial (`PASSEIO 001`, `PASSEIO 002`, …) quando for registro novo com SKU placeholder (`_nextSku`).
4. **`_replacePlatformLinks`** — reescreve os vínculos de plataforma do dia: apaga os existentes e insere os novos.
   - Para cada plataforma do report, **`_ensurePlatform`** normaliza o nome (maiúsculas) e:
     - se já existe no catálogo, reaproveita o `id`;
     - senão **cria** via `insertPlatform` (upsert no catálogo).

Após persistir, a service **não** faz releitura de confirmação (não há mais `debugPrint`
de "releitura do banco"): a escrita/leitura já é validada nos testes da camada de dados e
o fluxo fica limpo de instrumentação de depuração.

Ao **excluir** (`delete`), remove o dia; as FKs com `ON DELETE CASCADE` limpam os vínculos
de plataforma automaticamente.

> **Modelos envolvidos** (`features/financial_history/domain/`):
> - `FinancialHistoryModel` → `financial_history`
> - `FinancialHistoryPlatformModel` → `financial_history_platform` (usado também como
>   **visão em memória** das plataformas do dia — o campo `name`, populado apenas em
>   memória para exibição/edição, **não** é coluna de `financial_history_platform`: o
>   nome vive na tabela `platform`)
> - `PlatformModel` → `platform`
>
> Todos os modelos são **puros** (sem annotations de ORM); o mapeamento para as tabelas
> é feito pelo SQL cru + `toMap`/`fromMap`. Não há **DTO de visão** separado para as
> plataformas: a entidade associativa é reutilizada como visão. (`ExtraExpensesModel`
> foi removido por ser código morto.)

---

## 6. Features do projeto que usam persistência

| Feature | Persistência? | Detalhe |
|---|---|---|
| **`financial_history`** (feature modelo) | ✅ **Sim** | Única feature com camada de dados completa e SQL cru real (CRUD de `financial_history`, vínculos `financial_history_platform`, catálogo `platform`). É a fonte de referência. |
| `extra_expenses` (feature não implementada) | ❌ Não | `ExtraExpensesModel` e a tabela foram **removidos** (código morto). Serão recriados quando a feature for implementada. |
| `history` | ❌ Não | View mock (`static const`). Próximos passos: consumir o repositório/service para listar o histórico real. |
| `search` | ❌ Não | View mock. |
| `home_add_ride` | ❌ Não | View mock (raiz atual do app via `home_content_tab_view.dart`). |
| `tour_in_progress` | ❌ Não | View mock. |
| `data_storage` | ❌ Não | View mock (nome sugere área de dados, mas sem camada de persistência). |

---

## 7. Como uma nova feature passa a persistir (padrão da feature modelo)

Para qualquer feature nova seguir o mesmo padrão:

1. **`domain/`** — entidades **puras** (sem ORM), com `fromMap`/`toMap` para o SQL cru. Para a **visão** de que a UI/controller precisam, **reuse as próprias entidades** (campos não persistidos, ex. `name` da plataforma) em vez de criar DTOs de visão avulsos.
2. **`data/`** — **contrato** (`*RepositoryInterface`) + **implementação SQL cru** (`*RepositorySqliteImpl`) usando `openAppDatabase().rawQuery/insert/update/delete`.
3. **`*_service.dart`** — regras de negócio, conhecendo **apenas a interface**.
4. **`*_controller.dart`** — `ChangeNotifier` (estado da tela).
5. **`*_injection.dart`** — registra em `get_it` (único ponto que conhece a implementação concreta).
6. **`*_view.dart`** + `widgets/` — UI resolvendo o controller via `getIt`.
7. **Schema**: edite **`createSchema`** em `app_database.dart` e **incremente `schemaVersion`**.
   Como o `onUpgrade`/`onDowngrade` faz **drop + recreate** (sem migrações), o banco antigo
   é descartado e regerado com o schema novo ao abrir.

---

## 8. Dependências

| Pacote | Status | Uso |
|---|---|---|
| `sqflite` | ✅ Mantido | Persistência real (conexão + SQL cru). |
| `path` | ✅ Mantido | Montagem do caminho do arquivo `app.db`. |
| `get_it` | ✅ Mantido | DI (service locator). |
| `floor` | ❌ **Removido** | Após a remoção das migrações, restou apenas para annotations `@Entity` puramente "documentacionais" que **não** adicionavam nenhum comportamento (a persistência já era SQL cru). Removido para simplificar as models e reduzir dependências. |

---

## 9. Resumo das decisões

**(Análise crítica da camada de persistência desta POC.)**

| # | Item analisado | Decisão | Justificativa |
|---|---|---|---|
| 1 | **Migrações (v1→v2, v2→v3)** | **Removidas — substituídas por "drop + recreate"** | POC sem usuários em produção nem dados reais a preservar. O schema completo está no DDL inicial (`schemaVersion = 1`). Ao mudar o DDL basta **incrementar `schemaVersion`**: o `onUpgrade`/`onDowngrade` (presentes) **descartam as tabelas** e recriam via `createSchema`. `migrations.dart` excluído; `addMigrations` removido. |
| 2 | **Dependência `floor`** | **Removida** | Usada apenas para annotations `@Entity`/`@primaryKey`/`@ColumnInfo` "documentacionais" e tipos de migração (`Migration`, `MigrationAdapter`). Sem `@Database`/`@dao`/geração de código, essas annotations **não** influenciavam o SQL cru. Sem as migrações, restava só custo (dependência + `import` em todas as models). As models ficaram **puras**. |
| 3 | **`AppDatabaseBuilder` + `AppDatabase` interface + `_AppDatabase`** | **Simplificados** | O builder manual (com callbacks, `addMigrations`, wrapper `AppDatabase`) era desproporcional à POC. Reduzido a um `openAppDatabase()` simples que devolve a **`sqflite.Database` bruta**; o schema virou `createSchema()`. Repositórios usam a conexão direta. |
| 4 | **`extra_expenses` no schema (tabela + índice)** | **Removidos do schema** | Funcionalidade **não implementada** (sem repo/service/controller/view). Manter a tabela/índice seria persistência "morta". |
| 5 | **`ExtraExpensesModel` no domínio** | **Removido** | **Código morto**: modelo puro sem tabela, sem repositório e sem uso real (só referenciado em docs). Pode ser recriado junto com a feature futura, sem custo. |
| 6 | **Releitura pós-save + `debugPrint` no fluxo de save** | **Removidos/reduzidos** | A releitura (`getById` de comprovação) e os `debugPrint` de `toMap`/por-vínculo eram apenas instrumentação de depuração. Removido o re-`getById` (round-trip desnecessário) e o ruído por vínculo; mantido um único log conciso do save. |
| 7 | **Índices `financial_history_platform`** | **Mantidos** | Tabela efetivamente usada pela feature nas consultas por `financial_history_id`/`platform_id`. |
| 8 | **Cadeia repository → service → controller → injection** | **Mantida** | É a arquitetura padrão (feature modelo) e está funcional. A separação interface/impl segue o padrão DDD do projeto e facilita a futura troca de tecnologia. Não alterada para não quebrar o fluxo. |
| 9 | **`lib/to_trash_bkp/` (backups `.bkp`)** | **Fora do código produtivo** | São backups/histórico, **não** importados por nenhum código de produção. Removidos de `lib/` para não poluir a árvore Dart; o histórico segue preservado (ver docs de fase). |
| 10 | **`FinancialHistoryPlatformSummaryDTO` (DTO de visão)** | **Removido** | DTO de visão (nome+totais) que duplicava os campos de `FinancialHistoryPlatformModel` (`dailyEarnings`/`dailyTripCount`). Para uma POC era **indireção sem valor prático**. A entidade associativa passou a ser também a **visão em memória**, recebendo um campo `name` (não persistido — o nome vive na tabela `platform`). Service, controller e `FinancialHistoryPlatformModel` ajustados; o fluxo de salvar/editar/excluir/exibir plataformas permanece intacto. |

**Resultado:** a camada de persistência ficou reduzida a **um único arquivo**
(`app_database.dart`) com inicialização simples + DDL completo, sem ORM, **sem migrações
incrementais** (a evolução de schema é **drop + recreate** via `onUpgrade`/`onDowngrade`)
e com apenas **3 tabelas** de fato usadas. O fluxo funcional de `financial_history`
(CRUD + vínculos de plataforma + catálogo) permanece intacto.

> Fontes principais: `lib/app/database/app_database.dart`,
> `lib/features/financial_history/**`, `lib/app/di/service_locator.dart`, `pubspec.yaml`.
