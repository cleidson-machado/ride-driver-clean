# FASE 3 — LIMPEZA E VALIDAÇÃO

> POC **ride_driver_app_1** · Limpeza final do legado + validação da reorganização
> (concluída nas FASES 1 e 2). Base: `DIAGNOSTICO_FASE_1.md` e `REORGANIZACAO_FASE_2.md`.

---

## 1. Varredura de referências residuais a DAOs removidos

Busca em todo `lib/` (`grep -rn --include='*.dart' -E 'platform_dao|extra_expenses_dao|daos_impl|PlatformDaoImpl|ExtraExpensesDaoImpl|PlatformDao\b|ExtraExpensesDao\b|platformDao|extraExpensesDao'` excluído `to_trash_bkp`):

- **Resultado:** nenhuma ocorrência em código de produção `.dart`. ✅
- As únicas ocorrências de DAO restantes vivem em **documentação `.md`** (desatualizada — tratada no item 4) e em **`lib/to_trash_bkp/`** (backups `.bkp`, fora de escopo por regra).

**Conclusão:** não foi encontrada nenhuma referência produtiva aos arquivos/DAOs removidos.

---

## 2. Reavaliação de `lib/app/generic/`

| Arquivo | Status | Justificativa |
|---|---|---|
| `gen_crud_repository.dart` | **REMOVIDO** | CRUD genérico REST via `dio`, nunca usado no app (persistência é 100% SQLite local). Código morto. |
| `gen_crud_repository_interface.dart` | **REMOVIDO** | Contrato genérico sem nenhuma implementação/uso depois da remoção acima. |
| `base_model.dart` | **MANTIDO** | Ainda usado por todas as entidades de `domain/` (`FinancialHistoryModel`, `FinancialHistoryPlatformModel`, `PlatformModel`, `ExtraExpensesModel`), que implementam `String get id` + `Map<dynamic> toMap()`. É o mínimo necessário e está sendo utilizado. |

---

## 3. Dependência `dio`

- `dio` era usado **somente** em `lib/app/generic/gen_crud_repository.dart` (removido no item 2).
- **Dependência `dio` removida** de `pubspec.yaml` e, consequentemente, do `pubspec.lock`. ✅
- Dependentes dev adicionais **removidos** por não haver mais geração de código (nada que ver com persistência): `floor_generator` e `build_runner`.
- `floor` **mantido** — fornece as annotations de entidade (`@Entity`, `@primaryKey`, `@ColumnInfo`, `ForeignKey`, `Index`) e os tipos de migração (`Migration`, `Callback`, `MigrationAdapter`) usados ativamente nas models e no `app_database.dart`.

---

## 4. Documentação desatualizada — `DOCUMENTACAO_FINANCIAL_HISTORY_PLATFORM.md`

**Reescrita por completo** para refletir o padrão real atual (`domain/` + contrato de
repositório + implementação SQLite com SQL cru + service + controller + injection + view),
removendo:
- referência ao arquivo inexistente `financial_history_platform_dao.dart`;
- a classe antiga `FinancialHistoryPlatform` (renomeada para `FinancialHistoryPlatformSummaryModel`);
- a pasta `controller/` inexistente (o controller real fica em `financial_history_controller.dart`);
- referências ao repositório antigo `financial_history_repository.dart` (agora `..._sqlite_impl.dart`);
- uso de `db.platformDao.*` / métodos DAO (substituídos por descrição de SQL cru no repositório).

O documento agora descreve as camadas reais, o método `_ensurePlatform` (movido no service),
a ponte repositório⇄domínio e a tabela de referências cruzadas com os caminhos corretos.

---

## 5. Placeholders vazios

| Arquivo | Status | Justificativa |
|---|---|---|
| `lib/app/helper/todo.dart` | **REMOVIDO** | Arquivo vazio (só espaço/quebra), sem nenhum import/uso em `lib/` nem `test/`. |
| `lib/app/routing/todo.dart` | **REMOVIDO** | Idem — vazio e sem nenhuma referência. A pasta `lib/app/routing/` foi removida (ficou vazia). |

*(`lib/app/helper/ride_formatters.dart` foi **mantido**: é uma utilidade real de formatação,
fora do escopo de remoção dos placeholders; não é código legado de persistência.)*

---

## 6. `lib/to_trash_bkp/` e arquivos `.bkp`

**Intocados**, conforme regra — permanecem apenas como histórico de referência, fora do código produtivo.

---

## 7. Validação da reorganização

### Análise estática
```
fvm flutter analyze --no-pub
→ No issues found! (1.1s)
```

### Testes
```
fvm flutter test --no-pub
→ Test directory "test" does not contain any test files.
```
Não há arquivos de teste no projeto (o `widget_test.dart` padrão foi movido para
`lib/to_trash_bkp/widget_test.dart.bkp`). Sem regressões de teste a registrar.

### Fluxo `financial_history` ↔ `platform` (acesso coerente)
- `FinancialHistoryRepositorySqliteImpl` acessa o catálogo `platform` via **SQL cru**
  (`getPlatformById`, `getAllPlatforms`, `insertPlatform`), sem DAO.
- `FinancialHistoryService._ensurePlatform` usa `getAllPlatforms()` → busca case-insensitive;
  se não existir, `insertPlatform` e retorna o novo id — orquestração intacta.
- Vínculos associativos (`getPlatformLinksByFinancialHistoryId`, `insertPlatformLink`,
  `deletePlatformLinksByFinancialHistoryId`) continuam via SQL cru em `financial_history_platform`.

### Schema / migrações
- `AppDatabaseBuilder` continua a **única fonte de verdade** do schema (DDL manual) e
  cria `financial_history`, `financial_history_platform`, `platform` e `extra_expenses`
  com as FKs/índices/`ON DELETE CASCADE` exigidos pelas entidades.
- Migrações v1→v3 em `migrations.dart` **preservadas** e compatíveis (não dependiam de DAO).
- Análise estática sem erros confirma compatibilidade entre entidades, repositório e schema.

---

## 8. Resumo de alterações

- **Removidos (arquivos):**
  - `lib/app/generic/gen_crud_repository.dart`
  - `lib/app/generic/gen_crud_repository_interface.dart`
  - `lib/app/helper/todo.dart`
  - `lib/app/routing/todo.dart`
- **Dependências removidas:** `dio`, `floor_generator`, `build_runner` (`pubspec.yaml` + `pubspec.lock`).
- **Documentação atualizada (reescrita):** `DOCUMENTACAO_FINANCIAL_HISTORY_PLATFORM.md`.
- **Mantido:** `lib/app/generic/base_model.dart` (em uso pelas entidades);
  `lib/app/helper/ride_formatters.dart` (utilitário real, fora de escopo);
  `lib/to_trash_bkp/` (histórico, fora de escopo).
- **Não criadas** novas funcionalidades/telas/controllers/services para `extra_expenses`,
  `platform` ou outras features (respeitado o escopo).

---

## 9. Pendências técnicas (não resolvidas nesta fase)

1. **Sem testes automatizados** — não há suíte de testes no projeto (`test/` vazio). A validação
   contou com `flutter analyze` apenas. Não é regressão desta fase, mas é uma pendência de cobertura
   relevante para o projeto.
2. **Mocks de UI das demais features** (`history`, `search`, `tour_in_progress`, `home_add_ride`,
   `data_storage`) e dos botões ainda mockados na `financial_history_view` ("+ PLATAFORMA",
   "Gastos extras", "Imagens", "Forma de pagamento") permanecem sem controller/service real —
   **fora do escopo** desta fase, conforme objetivo.
3. **Documentos `.md` internos** (`ANALISE_MODELAGEM_E_PERSISTENCIA.md`, `DIAGNOSTICO_FASE_1.md`,
   `NORMALIZACAO_ANALISE.md`) ainda citam DAOs/tecnologias antigas em caráter histórico/diagnóstico.
   Não foram tocados por serem registro de análise (apenas o `DOCUMENTACAO_...md`, que descreve a
   arquitetura *atual*, foi atualizado). Candidatos a revisão futura.
4. **`lib/app/helper/ride_formatters.dart`** está sem uso efetivo (classe utilitária pronta, ainda
   não referenciada por nenhuma view). Mantida por ser utilidade legítima e fora do escopo, mas
   candidata a integração ou remoção em fase de UI.

---

*Fase concluída. Análise estática limpa. Aguardando instrução para iniciar a FASE 4.*
