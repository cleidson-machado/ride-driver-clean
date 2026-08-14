# Análise — Modelagem de Dados, Persistência e Propósito do App

Documento de apoio técnico do app **Ride Driver** (`ride_driver_app_1`).
Resumo do contexto e propósito da aplicação, da modelagem de dados (models) e
do sistema de persistência local (SQLite).

---

## 1. Contexto e Propósito do App

### 1.1 O que é

O **Ride Driver** é um app Flutter (Android / iOS / web) voltado para
**motoristas de plataformas de corrida** (Uber, Bolt, FreeNow, corridas
particulares avulsas etc.). Ele substitui uma **planilha de controle manual**
por uma ferramenta digital focada em **registro diário, métricas de
lucratividade e histórico financeiro**.

### 1.2 Premissa de negócio

A tela de registro carrega uma **tese de lucratividade** documentada na model
`FinancialHistoryModel`: um passeio é considerado lucrativo quando o valor do
combustível é "reposto" no mesmo dia, acrescido do dobro do seu valor **+ 100 €
de giro extra**.

> Exemplo: combustível de 50 € → giro necessário = **200 €**, descontando os
> próprios 50 € de combustível gastos no dia.

Ou seja, o app não só armazena dados: ele orienta o motorista sobre **quanto
precisa faturar cada dia** para que o dia seja financeiramente viável.

### 1.3 O que as views revelam do fluxo do motorista

As telas (views) definem claramente o fluxo de uso:

| View | Arquivo | Função |
|---|---|---|
| **Home** | `home_add_ride_view.dart` | Dashboard com médias (lucro, km rodado, consumo €/km, horas, ticket médio) do último passeio e da semana, e acesso rápido a "Add Passeio" / "Ver em curso". |
| **Hub de abas** | `home_content_tab_view.dart` | Navegação principal (Home, Buscar, Histórico, Dados) via `NavigationBar`. |
| **Passeio em curso** | `tour_in_progress_view.dart` | Resumo do passeio ativo (combustível × faturamento), indicador EM CURSO, botão "Encerrar passeio" e lista de passeios recentes. |
| **Cadastro/edição** | `financial_history_view.dart` | Formulário completo do dia: data, km IN/OUT, hodômetro 2, valor de combustível, plataformas utilizadas (valor + nº de corridas por plataforma), notas, imagens, gastos extras, exclusão do report. |
| **Histórico** | `history_view.dart` | Dashboard agregado: taxa de atividade, distribuição por plataforma, faturamento total, km percorrido, gasto com combustível, dias ativos e métricas mensais. |
| **Busca** | `search_view.dart` | Busca e filtro de registros (receitas, despesas, bônus) por período e plataforma. |
| **Dados & Armazenamento** | `data_storage_view.dart` | Gerenciamento do banco local: tamanho, nº de registros, exportação CSV e reset seletivo/parcial. |

> **Observação:** a maioria das views ainda é **mock/POC** (dados estáticos em
> `const`). A modelagem de dados e o esquema do banco já estão definidos, mas a
> **camada de UI ainda não está totalmente integrada ao banco** — vários botões
> possuem apenas `// TODO`. O estado atual reflete um *esqueletão Material 3*
> antes da integração definitiva.

---

## 2. Modelagem de Dados (Models)

Todas as entidades implementam a interface base **`BaseModel`**
(`lib/app/generic/base_model.dart`), que exige:

```dart
abstract class BaseModel {
  String get id;              // PK em formato TEXT (UUID)
  Map<String, dynamic> toMap(); // usado para persistência
}
```

### 2.1 `FinancialHistoryModel` → tabela `financial_history`

Registro **diário** de trabalho do motorista. Cada linha = um dia trabalhado.

| Campo (Dart) | Coluna SQL | Tipo | Descrição |
|---|---|---|---|
| `id` | `id` | TEXT (PK) | Identificador único (UUID). |
| `dateMillis` | `work_date` | INTEGER | Data como timestamp (epoch millis). Getter `date` converte para `DateTime`. |
| `tripNumber` | `trip_number` | TEXT | Nº do passeio/viagem — SKU legível (ex.: "PASSEIO 011"). |
| `fuelCost` | `fuel_cost` | REAL | Valor do combustível gasto no dia (€). |
| `kmStart` | `km_start` | INTEGER | Quilometragem de saída (hodômetro no início). |
| `kmEnd` | `km_end` | INTEGER | Quilometragem de entrada (hodômetro no fim). |
| `kmOdometer` | `km_odometer` | INTEGER | Km rodado lido manualmente (redundância/validação). |
| `notes` | `notes` | TEXT | Anotação livre sobre o dia. |

### 2.2 `PlatformModel` → tabela `platform`

**Catálogo** de plataformas de corrida (ex.: UBER, BOLT, PARTICULAR).
Permite que o usuário cadastre novas plataformas via botão **"+ PLATAFORMA"**
sem alterar o schema.

| Campo | Coluna | Tipo | Descrição |
|---|---|---|---|
| `id` | `id` | TEXT (PK) | Identificador único. |
| `name` | `name` | TEXT | Nome exibido (ex.: "UBER"). |
| `isActive` | `is_active` | INTEGER (0/1) | Ativa/disponível para novos registros. SQLite não tem BOOLEAN nativo → 0/1. |

### 2.3 `FinancialHistoryPlatformModel` → tabela `financial_history_platform`

Tabela **associativa** (de detalhe) entre um dia e as plataformas usadas nele.
Corrige a violação de **1ª Forma Normal** presente na planilha original, que
usava colunas por plataforma (`VALOR_UBER`, `QTD_BOLT`, ...).

Cada linha = o faturamento e a quantidade de corridas de **UMA plataforma** em
**UM dia**. Permite **N plataformas por registro diário**.

| Campo | Coluna | Tipo | Descrição |
|---|---|---|---|
| `id` | `id` | TEXT (PK) | Identificador único. |
| `financialHistoryId` | `financial_history_id` | TEXT (FK) | → `financial_history.id`. `ON DELETE CASCADE`. |
| `platformId` | `platform_id` | TEXT (FK) | → `platform.id`. `ON DELETE CASCADE`. |
| `dailyEarnings` | `daily_earnings` | REAL | Faturamento total do dia nessa plataforma (€). |
| `dailyTripCount` | `daily_trip_count` | INTEGER | Nº de corridas do dia nessa plataforma. |

### 2.4 `ExtraExpensesModel` → tabela `extra_expenses`

Despesas **extras/avulsas** decorrentes do dia de trabalho (alimentação,
bebidas, medicamentos, pedágios etc.). Facultativas (0 ou N por dia).

| Campo | Coluna | Tipo | Descrição |
|---|---|---|---|
| `id` | `id` | TEXT (PK) | Identificador único. |
| `financialHistoryId` | `financial_history_id` | TEXT (FK, nullable) | Vínculo opcional com o dia (`null`) para despesas avulsas/futuras. `ON DELETE CASCADE`. |
| `description` | `description` | TEXT | Nome/descrição (ex.: "Almoço"). |
| `amount` | `amount` | REAL | Valor da despesa (€). |
| `category` | `category` | TEXT (nullable) | Agrupamento (alimentação, pedágio, outros...). |
| `createdAt` | `created_at` | INTEGER | Timestamp de criação (epoch millis). Getter `createdDate`. |

### 2.5 Diagrama do relacionamento

```
financial_history (1) ──< financial_history_platform >── (1) platform
        └──< extra_expenses   (0..N)  — vínculo opcional
```

- `financial_history` 1 ──< `financial_history_platform` >── 1 `platform`
  (muitos-para-muitos via tabela associativa, com faturamento/corridas por dia).
- `financial_history` 1 ──< `extra_expenses` (0..N, FK opcional).
- Todas as FKs usam `ON DELETE CASCADE`: apagar um dia remove também os
  detalhes de plataformas e as despesas vinculadas.

---

## 3. Sistema de Persistência Local

### 3.1 Stack

- **`sqflite`** — driver SQLite nativo (Android/iOS/web).
- **`floor`** — camada ORM que expõe anotações `@entity`, `@dao` e `@ColumnInfo`.
- **`path`** — resolução do caminho do arquivo do banco.
- **`build_runner` / `floor_generator`** (dev) — geração de código a partir das
  anotações. *(Opcionais/redundantes hoje, ver 3.3.)*

### 3.2 Arquitetura: `AppDatabase` e `AppDatabaseBuilder`

Em `lib/app/database/app_database.dart`, o banco é exposto por uma **interface
abstrata** `AppDatabase` com getters por DAO:

```dart
abstract class AppDatabase {
  FinancialHistoryDao get financialHistoryDao;
  FinancialHistoryPlatformDao get financialHistoryPlatformDao;
  PlatformDao get platformDao;
  ExtraExpensesDao get extraExpensesDao;
  Future<void> close();
}
```

O `AppDatabaseBuilder.build()`:

1. obtém o path do banco via `sqfliteDatabaseFactory.getDatabasePath('app.db')`;
2. abre o banco com **`version: 2`**;
3. habilita `PRAGMA foreign_keys = ON` (chaves estrangeiras);
4. cria as tabelas em `onCreate` (via `_createTables`);
5. roda migrações em `onUpgrade` (via `MigrationAdapter.runMigrations`).

### 3.3 Particularidade: sqflite manual em vez de `floor_generator`

Um ponto relevante documentado no código: o `floor_generator` 1.5.x **não
processa a anotação `@Database`** em projetos com `SDK >= 3.12.0`. Para
contornar isso:

- A abertura do banco usa **`sqflite` diretamente** no `AppDatabaseBuilder`;
- Os **DAOs concretos** (`*DaoImpl` em `daos_impl.dart`) usam `rawQuery`,
  `insert`, `update` e `delete` do `sqflite.Database`;
- As **models** ganharam `fromMap`/`toMap` usados nessa camada;
- As anotações `@dao`/`@entity` permanecem principalmente como *contrato de
  interface* e documentação (as classes abstratas de DAO são `@dao`).

### 3.4 DAOs

Cada entidade tem um DAO com operações CRUD e consultas específicas:

| DAO | Destaques |
|---|---|
| `FinancialHistoryDao` | Lista todos os dias (`ORDER BY work_date DESC`), busca por id, insert/update/delete. |
| `FinancialHistoryPlatformDao` | Busca plataformas de um dia (`WHERE financial_history_id = :id`), CRUD. |
| `PlatformDao` | Lista plataformas (`ORDER BY name ASC`), CRUD. |
| `ExtraExpensesDao` | **Totais por dia** (`SUM(amount)` via `COALESCE`), despesas agrupadas por dia, **despesas sem vínculo** (`financial_history_id IS NULL`), CRUD. |

Padrão de CRUD usado: `ConflictAlgorithm.abort` nos inserts e onde `id = ?`
para update/delete.

### 3.5 Migrações

```dart
final migration1to2 = Migration(1, 2, (database) async { ... });
```

A migração **v1 → v2** cria a tabela `extra_expenses` e seu índice, preservando
dados reais de quem já tem o banco v1. O `AppDatabaseBuilder` recebe as
migrações via `.addMigrations([...])` e as executa na abertura quando a versão
do disco é menor que a do código.

### 3.6 Índices

```sql
idx_fhp_financial_history_id  ON financial_history_platform (financial_history_id)
idx_fhp_platform_id           ON financial_history_platform (platform_id)
idx_ee_financial_history_id   ON extra_expenses (financial_history_id)
```

Os índices sobre as FKs aceleram as consultas por dia/plataforma.

### 3.7 Integração com rede (em planejamento)

O projeto também contém uma camada genérica de repositório HTTP
(`gen_crud_repository.dart` + `gen_crud_repository_interface.dart`) baseada em
**`dio`**. Hoje ela é **independente e não conectada** ao app/UI — indicando um
plano futuro de sincronização/servidor, mas o persistência efetiva **atual é
100% local** (SQLite).

---

## 4. Considerações Finais

- **Modelagem consolidada e bem normalizada** para a fase atual, resolvendo a
  1FN das plataformas por meio de catálogo + tabela associativa.
- **Persistência exclusivamente local** via SQLite/`sqflite`, com camada de
  migração pronta (`1→2`) e FKs com cascade para integridade.
- **UI ainda em fase de mock/POC**: as entidades e o schema estão prontos para
  receber os dados reais, mas os botões das telas (`Salvar`, `Encerrar`,
  `Adicionar plataforma`, `Exportar`, etc.) ainda não estão ligados aos DAOs.

### Próximos passos prováveis (endpoints futuros adiantados na documentação)

- Integrar views ↔ DAOs (ligar os `// TODO` dos botões ao banco).
- Persistir campos de estado hoje só na tela: "Hodômetro 2 zerado?", "Hodômetro 2
  trajeto", "Concluído?".
- Modelar abastecimentos e anexos/imagens como entidades 1:N (hoje representados
  como flags/notas).
- Avaliar uso do repositório `dio` para sincronização remota futura.
