# CONSIDERAÇÃO ARQUITETURAL — FASE 4 (FINAL)

> **Documento executivo de encerramento** do ciclo de reorganização da persistência
> SQLite do POC **ride_driver_app_1** (Fases 1–4).
>
> Resumo do ciclo:
> - **FASE 1** — Diagnóstico → `DIAGNOSTICO_FASE_1.md`
> - **FASE 2** — Reorganização → `REORGANIZACAO_FASE_2.md`
> - **FASE 3** — Limpeza e Validação → `LIMPEZA_VALIDACAO_FASE_3.md`
> - **FASE 4** — Consolidação Final → este documento

---

## 1. Resumo Executivo — Antes vs. Depois

### Persistência

| Aspecto | Antes | Depois (atual) |
|---|---|---|
| Paradigmas de persistência | **Dois coexistentes**: DAOs Floor (`platform`, `extra_expenses`) **e** repositório com SQL cru (`financial_history`) | **Um só**: SQL cru no repositório + `AppDatabaseBuilder` manual (fonte de verdade do schema) |
| Fonte de verdade do schema | Duplicada (annotations `@Entity` + `CREATE TABLE` manual) | Única: DDL manual em `app_database.dart` (`_createTables`) |
| Bibliotecas de estado/REST | `dio` (CRUD genérico não usado), `gen_crud_repository*` | Removidos (código morto) |
| Geração de código | `floor_generator` + `build_runner` + `@dao` | Removidos (sem `@Database`/`@dao`) |

### Estrutura / Entidades

| Entidade | Antes | Depois |
|---|---|---|
| `PlatformModel` | `lib/features/platform/platform_model.dart` | `lib/features/financial_history/domain/platform_model.dart` |
| `ExtraExpensesModel` | `lib/features/extra_expenses/extra_expenses_model.dart` | `lib/features/financial_history/domain/extra_expenses_model.dart` |
| DAOs | `platform_dao.dart`, `extra_expenses_dao.dart`, `daos_impl.dart` | **Removidos** |

### Padrão de implementação (consolidado)
`domain/` (entidades) + `data/` (contrato + implementação SQL cru) + `service` (regras) +
`controller` (ChangeNotifier) + `injection` (DI via get_it) + `view`/`widgets`.

---

## 2. Mapa Final da Árvore de Arquivos (relevante)

### `lib/app/`
```
lib/app/
├── database/
│   ├── app_database.dart     # AppDatabaseBuilder — única fonte de verdade do schema + openAppDatabase()
│   └── migrations.dart       # migration1to2 (extra_expenses), migration2to3 (flags do formulário)
├── di/
│   └── service_locator.dart  # getIt + setupServiceLocator() (chamado em main())
├── generic/
│   └── base_model.dart      # contrato mínimo (id, toMap) usado pelas entidades
├── helper/
│   └── ride_formatters.dart # formatação de km/moeda (utilidade; ainda sem uso efetivo)
├── theme/
│   └── app_theme.dart       # Material 3 (light/dark) — única fonte de cores
└── (routing/ e todo.dart removidos — placeholders vazios não utilizados)
```

### `lib/features/financial_history/` (feature modelo)
```
lib/features/financial_history/
├── data/
│   ├── financial_history_repository_interface.dart       # contrato
│   └── financial_history_repository_sqlite_impl.dart      # SQL cru (platform, vínculos, etc.)
├── domain/
│   ├── financial_history_model.dart                        # entidade diária (@Entity)
│   ├── financial_history_platform_model.dart               # entidade associativa (@Entity)
│   ├── platform_model.dart                                 # catálogo @Entity (movido FASE 2)
│   ├── extra_expenses_model.dart                           # despesas @Entity (movido FASE 2)
│   └── financial_history_platform_summary_model.dart       # DTO/visão (nome+totais)
├── financial_history_service.dart     # regras de negócio (save, _ensurePlatform, _replacePlatformLinks, SKU, validação)
├── financial_history_controller.dart  # ChangeNotifier (estado da tela)
├── financial_history_injection.dart  # DI get_it (interface→impl, service, factory de controller)
├── financial_history_view.dart       # view
└── widgets/                          # action_buttons, form_fields, notes_field, platforms_section,
                                      # quick_options_row, ride_dialogs, ride_header, terms_legend, top_data_grid
```

### Demais features (mock — pendentes)
```
lib/features/
├── history/            → history_view.dart                 (mock)
├── search/             → search_view.dart                  (mock)
├── home_add_ride/      → home_add_ride_view.dart, home_content_tab_view.dart (mock; raiz atual do app)
├── tour_in_progress/   → tour_in_progress_view.dart        (mock)
└── data_storage/       → data_storage_view.dart            (mock)
```

---

## 3. Guia Rápido — Implementar as Próximas Features

Siga o padrão da feature modelo (`financial_history`) para criar qualquer feature nova
(ex.: `extra_expenses`, `history`, `search`).

1. **`domain/`** — crie/ajuste os modelos. Use `@Entity` (Floor) apenas para documentar o
   schema quando a entidade for persistida; crie DTOs puros (`*SummaryModel`) para a visão
   de UI. Implemente `BaseModel` (`id`, `toMap()`) + `fromMap()` (SQL cru).
2. **`data/`** —
   - `*RepositoryInterface`: contrate as operações (abstração).
   - `*RepositorySqliteImpl`: implemente com **SQL cru** sobre `AppDatabase.database`
     (ex.: `db.database.rawQuery(...)`, `db.database.insert(...)`). **Não** crie DAO/`@dao`.
3. **`<feature>_service.dart`** — regras de negócio, orquestração, validações. Conheça
   apenas a interface do repositório.
4. **`<feature>_controller.dart`** — `ChangeNotifier` com o estado da tela e ações síncronas.
5. **`<feature>_injection.dart`** — registre em `get_it` (interface→impl, service,
   factory do controller). É o **único** ponto que conhece a implementação concreta.
6. **`<feature>_view.dart`** + **`widgets/`** — UI; a view resolve o controller via `getIt`
   (padrão já usado em `financial_history_view.dart`).
7. Registre a nova feature no `setupServiceLocator()` (`lib/app/di/service_locator.dart`).

### Regras transversais
- **Schema do banco**: se a feature criar/mudar tabelas, edite `_createTables` em
  `lib/app/database/app_database.dart` **e**, se houver banco anterior, adicione uma
  `Migration` em `lib/app/database/migrations.dart`. Mantenha `AppDatabaseBuilder` como
  única fonte de verdade (versão do banco via `OpenDatabaseOptions.version`).
- **Não** reintroduza `dio`, DAO de Floor, `build_runner` ou abstrações genéricas sem
  necessidade real.
- **Exemplo de referência de leitura**: siga os métodos `_ensurePlatform` e
  `_replacePlatformLinks` em `financial_history_service.dart` e o padrão de SQL cru em
  `financial_history_repository_sqlite_impl.dart`.

---

## 4. Pendências Técnicas e Próximos Passos Recomendados

### Pendências técnicas (verificadas nesta fase)
1. **Sem testes automatizados** — `test/` está vazio (o `widget_test.dart` padrão virou
   histórico em `lib/to_trash_bkp/`). Não há suíte para regressão.
2. **Features mock sem camada de dados/controller** — `history`, `search`,
   `tour_in_progress`, `home_add_ride` e `data_storage` são views com dados `static const`.
3. **Fluxos mockados dentro da feature modelo** — na `financial_history_view.dart`:
   "+ PLATAFORMA", "Gastos extras", "Imagens/anexos" e "Forma de pagamento" exibem
   apenas SnackBar ("em breve").
4. **`extra_expenses`** — a entidade `ExtraExpensesModel` já está no domínio e o schema
   existe, mas ainda não há repo/service/controller/view específicos (persistência de
   despesas aguarda a nova feature de UI).
5. **`lib/app/helper/ride_formatters.dart`** — utilidade pronta, ainda sem uso efetivo
   (a view mantém formatações locais). Candidata a integração na próxima refatoração de UI.
6. **Documentos internos históricos** — `ANALISE_MODELAGEM_E_PERSISTENCIA.md`,
   `DIAGNOSTICO_FASE_1.md` e `NORMALIZACAO_ANALISE.md` são registros históricos/diagnóstico
   e ainda citam DAOs/tecnologias antigas. Mantidos como histórico (fora do código produtivo).

### Próximos passos recomendados
1. **Criar suíte de testes** em `test/` (unitários para service/repository com
   `sqflite_common_ffi`, e testes de widget) para dar cobertura à persistência unificada.
2. **Implementar a feature `extra_expenses` completa** (domain/data/service/controller/
   injection/view), seguindo o guia da seção 3 e ligando o botão "Gastos extras" da view.
3. **Transformar telas mock em features reais** para `history` e `search`, consumindo
   `FinancialHistoryRepositorySqliteImpl`/Service.
4. **Decidir sobre gestão de plataformas na UI** (catálogo hoje é alimentado apenas por
   `_ensurePlatform` no fluxo de salvar; a gestão visual permanece mock).
5. **Adotar `RideFormatters`** na view, eliminando formatações locais duplicadas.
6. **Revisar a navegação** (não há roteador ainda; a Home usa `home_content_tab_view.dart`).

---

## 5. Resultado da Checagem Final de Integridade

`fvm flutter analyze --no-pub` → **No issues found** ✅

(As atualizações desta FASE foram apenas de documentação/metadados; nenhum código de
produção foi alterado, portanto a checagem confirma que nada quebrou.)

---

*Ciclo de 4 fases concluído. Base arquitetural pronta para o desenvolvimento das próximas features de UI.*
