# Diagnóstico — FASE 1: ANÁLISE DA PERSISTÊNCIA SQLite

> POC **ride_driver_app_1** · Data do diagnóstico: análise estrutural do código
> (nenhuma alteração de código foi feita nesta fase).

## Contexto / Objetivo da fase

Unificar a persistência SQLite num único paradigma (o da feature modelo
`lib/features/financial_history/`), eliminando redundâncias e over-engineering,
e reorganizar entidades/arquivos que estão em locais inapropriados. Esta fase
é **puramente diagnóstica**: entender o padrão modelo, avaliar `lib/app/database/`
e varrer todas as features.

---

## 1. Padrão adotado na feature modelo (`lib/features/financial_history/`)

É a referência arquitetural, seguindo **camadas em DDD Tático** dentro da própria feature:

| Camada | Arquivo(s) | Papel |
|---|---|---|
| `domain/` | `financial_history_model.dart` | `FinancialHistoryModel` — entidade `@Entity` (tabela `financial_history`) |
| `domain/` | `financial_history_platform_model.dart` | `FinancialHistoryPlatformModel` — entidade `@Entity` (tabela associativa) |
| `domain/` | `financial_history_platform_summary_model.dart` | DTO de visão (nome + totais), `@ignore` (não persistido) |
| `data/` | `financial_history_repository_interface.dart` | **Contrato** de persistência (abstração) |
| `data/` | `financial_history_repository_sqlite_impl.dart` | Implementação SQLite com **SQL cru** (`rawQuery` + `db.database`) |
| raiz | `financial_history_service.dart` | **Service/Use-Case**: regras de negócio, orquestração, validação, SKU, `_ensurePlatform` |
| raiz | `financial_history_controller.dart` | **ChangeNotifier** — estado da tela (application layer) |
| raiz | `financial_history_injection.dart` | **DI via `get_it`** — registra interface → impl, service, factory do controller |
| raiz | `financial_history_view.dart` + `widgets/` | Camada de apresentação |

**Princípio-chave:** a **infraestrutura concreta é conhecida apenas no ponto de
composição** (`financial_history_injection.dart`).
- Service conhece a **interface** (`FinancialHistoryRepositoryInterface`);
- Controller conhece a **service**;
- View conhece só o **controller**.

DI unificada via `get_it` (`setupServiceLocator()` chamado em `main()`).

---

## 2. Avaliação de `lib/app/database/` — redundâncias e conflitos

| Arquivo | Achado |
|---|---|
| `app_database.dart` | **Conflito central**: mistura **FLOOR** (`@Entity`/`@primaryKey` nas models) com **builder manual sqflite** (`AppDatabaseBuilder` executando `CREATE TABLE` na mão). Duas fontes de verdade do schema. `openAppDatabase()` é singleton global (não injetado). Expõe `platformDao` e `extraExpensesDao` — pontos de acesso à persistência **fora** do padrão de repositório. |
| `daos_impl.dart` | **Over-engineering/redundância**: duplica o que a `financial_history` já faz por SQL cru via repositório. `PlatformDaoImpl`/`ExtraExpensesDaoImpl` reimplementam querys que o padrão modelo faz direto com `rawQuery`. Camada "DAO" fantasma que o padrão modelo já eliminou. |
| `migrations.dart` | Migrações legítimas (v1→v3), porém aplicadas pelo builder manual; redundam com a criação de tabelas via annotation Floor. |

**Diagnóstico chave do conflito:** a feature financeira criou *entidades Floor*
mas **abandonou os DAOs do Floor** em favor de SQL cru via repositório. Já
`platform` e `extra_expenses` ainda usam **DAOs Floor** → **dois paradigmas
coexistindo**, exatamente o problema descrito.

---

## 3. Varredura completa de `lib/features/`

Foram percorridas **todas as 8 features**: `financial_history`, `platform`,
`extra_expenses`, `history`, `search`, `tour_in_progress`, `home_add_ride`,
`data_storage`.

### (a) Arquivos `.dart` com "DAO" no nome

- `lib/features/platform/platform_dao.dart` → `@dao abstract class PlatformDao`
- `lib/features/extra_expenses/extra_expenses_dao.dart` → `@dao abstract class ExtraExpensesDao`
- (relacionado) `lib/app/database/daos_impl.dart` → implementações `PlatformDaoImpl` e `ExtraExpensesDaoImpl`

### (b) Entidades/modelos em locais inapropriados

- **`lib/features/platform/platform_model.dart`** → `PlatformModel` (`@Entity`,
  tabela `platform`). **Criado como feature avulsa**, mas é catálogo **transversal**,
  usado pela `financial_history` (a `data/financial_history_repository_interface.dart`
  e a `service.dart` importam `features/platform/platform_model.dart`). Modelo de
  **domínio compartilhado** morando no que hoje é apenas o "resquício DAO".
- **`lib/features/extra_expenses/extra_expenses_model.dart`** → `ExtraExpensesModel`
  (`@Entity`, tabela `extra_expenses`). Entidade fora de lugar, sem feature "pai" estruturada.
- **Padrão inconsistente de dependências:** `FinancialHistoryPlatformModel` referencia
  por FK o `PlatformModel` (pasta `platform/`) e o `FinancialHistoryModel` (pasta
  `financial_history/`) — acoplamento cruzado entre features.

### (c) Features sem view no DDD Tático

- **`platform`**: só tem `platform_dao.dart` + `platform_model.dart` — **SEM
  view/controller/service**. Hoje o catálogo é alimentado como efeito colateral do
  `service.dart` da `financial_history` (`_ensurePlatform`). Não há gestão de
  plataformas na UI (o botão "+ PLATAFORMA" na view é `mock`).
- **`extra_expenses`**: só tem DAO + model — **SEM view/controller/service**. O botão
  "Gastos extras" na `financial_history_view` é `mock`.

### Observações transversais

- As demais views (`history`, `search`, `tour_in_progress`, `home_add_ride`,
  `data_storage`) são **100% mock** (dados `static const`), sem controller/service —
  ainda não tocam persistência. Não conflitam com o padrão; apenas aguardam etapa
  futura de modelagem.

---

## 4. Outros achados relevantes

- **`app/generic/`** (`BaseModel`, `GenCrudRepository`, `GenCrudRepositoryInterface`)
  → **over-engineering morto para a POC**: `GenCrudRepository` é um CRUD REST via **dio**,
  nunca usado (a persistência é toda SQLite local). Serve apenas como "assinatura"
  (`BaseModel`) às entidades. Candidato a remoção ou reavaliação.
- **`app/helper/todo.dart`** e **`app/routing/todo.dart`**: placeholders vazios.
- **`lib/to_trash_bkp/`**: backups `.bkp` com o histórico, incluindo a classe que
  fazia a conversão entre entidade e visão. A versão atual de `financial_history` já
  consolidou isso; os `.bkp` são só material de referência.
- **Dependências declaradas vs. usadas:** `dio` só é usado em
  `app/generic/gen_crud_repository.dart` (não utilizado).
- **`DOCUMENTACAO_FINANCIAL_HISTORY_PLATFORM.md`** ainda aponta para um
  `financial_history_platform_dao.dart` e uma pasta `controller/` **que já não existem**
  → documentação desatualizada em relação ao código real.

---

## 5. Síntese do diagnóstico (conflitos contra o padrão modelo)

1. **Dois paradigmas de persistência**: DAOs Floor (`platform`, `extra_expenses`)
   × repositório SQL-cru (`financial_history`) — ambos tocam SQLite via `app_database.dart`.
2. **Localização errada de entidades transversais**: `PlatformModel` e
   `ExtraExpensesModel` como features "DAO" avulsas, sem a estrutura em camadas
   (domain/data/service/controller/injection/view) da feature modelo.
3. **`BaseModel` acopla todas as entidades** a um `app/generic/` que também carrega
   um CRUD REST (dio) não utilizado → over-engineering.
4. **`app_database.dart`** centraliza duas fontes de verdade (annotations Floor +
   SQL manual) e expõe DAOs públicos (viola "infra só no ponto de composição").
5. **Features sem view em DDD Tático**: `platform` e `extra_expenses` só têm
   persistência; a UI delas é hoje mock dentro da `financial_history_view`.

---

*Fase concluída sem alterações de código. Aguardando instrução para iniciar a FASE 2.*
