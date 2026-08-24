# `FinancialHistoryPlatform`

> Documentação da classe de domínio `FinancialHistoryPlatform` — visão resolvida de uma plataforma em um dia de trabalho.

**Arquivo:** `lib/features/financial_history/domain/financial_history_platform.dart`

---

## 1. Visão Geral

`FinancialHistoryPlatform` é um **modelo de domínio** (imutável) que representa o **faturamento e o número de corridas** de **uma única plataforma** (UBER, BOLT, FREENOW, PARTICULAR, etc.) em **um dia de trabalho**.

Diferente da entidade persistida `FinancialHistoryPlatformModel`, esta classe **já vem resolvida para consumo da UI/controller**: carrega o `name` da plataforma (obtido do catálogo `platform` via *join* no repositório) e os totais prontos para exibição.

### Definição

```dart
class FinancialHistoryPlatform {
  const FinancialHistoryPlatform({
    required this.name,
    required this.totalValue,
    required this.totalRides,
  });

  final String name;        // Ex.: UBER, BOLT, FREENOW, PARTICULAR
  final double totalValue;  // Faturamento do dia nessa plataforma (€)
  final int totalRides;     // Nº de corridas do dia nessa plataforma

  FinancialHistoryPlatform copyWith({...});
}
```

---

## 2. Papel na Arquitetura

Este projeto segue o **padrão repositório**, onde existe uma separação clara entre **entidade de persistência** e **visão de domínio**. A classe `FinancialHistoryPlatform` ocupa o papel de **visão de domínio**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CAMADA DE APRESENTAÇÃO (UI / Controller)              │
│                              FinancialHistoryView                          │
│                        FinancialHistoryController                           │
│                                 │                                           │
│                    usa / manipula `FinancialHistoryPlatform`                │
│                                 │                                           │
├─────────────────────────────────┼───────────────────────────────────────────┤
│                      CAMADA DE DADOS (Repository / DAO)                    │
│                       FinancialHistoryRepository                            │
│            ┌────────────────────┼────────────────────────────┐              │
│            │                    │                            │              │
│   FinancialHistoryPlatformModel (entidade SQLite)    PlatformModel (catálogo)│
│                         │                                │                  │
│                       (faz o JOIN / conversão)                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.1 Não confundir com `FinancialHistoryPlatformModel`

Existem **duas classes com nomes semelhantes** que desempenham papéis **diferentes e complementares**:

| | `FinancialHistoryPlatform` | `FinancialHistoryPlatformModel` |
|---|---|---|
| **Camada** | Domínio (visão resolvida) | Persistência (entidade) |
| **Tabela SQLite** | Nenhuma (não é `@Entity`) | `financial_history_platform` |
| **Vínculo com Floor** | Não | Sim (`@Entity`, FKs, índices) |
| **Contém** | `name`, `totalValue`, `totalRides` | `id`, `financialHistoryId`, `platformId`, `dailyEarnings`, `dailyTripCount` |
| **Nome da plataforma** | Sim (já resolvido) | Não (vive no catálogo `platform`) |
| **Quem consome** | UI, Controller | DAO / camada de dados |
| **Como se relacionam** | O repositório converte entre as duas ao carregar/salvar | — |

---

## 3. Quem Usa Esta Classe e com Qual Finalidade

### 3.1 `FinancialHistoryModel.platforms` — lista alimentadora do total

**Arquivo:** `lib/features/financial_history/domain/financial_history_model.dart`

A entidade diária `FinancialHistoryModel` expõe a propriedade:

```dart
@ignore
final List<FinancialHistoryPlatform> platforms;
```

O campo é anotado com `@ignore` porque **não é persistido diretamente na tabela `financial_history`** — é populado em memória pelo repositório após resolver os vínculos relacionais.

A lista alimenta o getter calculado **`totalEarnings`**, que soma os `totalValue` de todas as plataformas do dia:

```dart
double get totalEarnings => platforms.fold(
  0,
  (double sum, FinancialHistoryPlatform platform) =>
      sum + platform.totalValue,
);
```

**Finalidade:** a UI consulta `totalEarnings` para exibir o faturamento consolidado do dia, e o getter `profit` (ofertas menos gastos) também depende indiretamente dessa soma.

---

### 3.2 `FinancialHistoryController` — mutação do estado da tela

**Arquivo:** `lib/features/financial_history/controller/financial_history_controller.dart`

O `FinancialHistoryController` (um `ChangeNotifier`) gerencia o estado da `FinancialHistoryView`. Ele manipula **diretamente** objetos `FinancialHistoryPlatform` nas seguintes operações:

| Método | Finalidade |
|---|---|
| `addPlatform({name, totalValue, totalRides})` | Adiciona uma nova plataforma com valores **normalizados** (valores negativos são convertidos para 0) à lista `_report.platforms`. |
| `updatePlatform(index, {name, totalValue, totalRides})` | Atualiza a plataforma no índice informado, usando `copyWith` (imutabilidade preservada, campos omitidos mantêm o valor atual). |
| `removePlatform(index)` | Remove a plataforma no índice informado, se existir (bounds check). |

Em todos esses métodos o controller:

1. Cria uma **nova lista** (usando `List.of(...)`) para preservar a imutabilidade do estado;
2. Reatribui `_report` via `copyWith(platforms: updated)`;
3. Chama `notifyListeners()` para acionar o rebuild da view.

**Finalidade:** centralizar a mutação que hoje viveria solta no `State` do widget, mantendo o `ChangeNotifier` como **fonte da verdade** para a tela.

---

### 3.3 `FinancialHistoryRepository` — ponte entre as duas classes

**Arquivo:** `lib/features/financial_history/data/financial_history_repository.dart`

O repositório é quem faz a **conversão bidirecional** entre `FinancialHistoryPlatform` e `FinancialHistoryPlatformModel`. É o único responsável por traduzir o mundo da UI (nome + totais) para o mundo do banco (FKs + valores crus) e vice-versa.

#### No `getById` (load — banco → domínio):

```dart
// 1. Lê as linhas associativas do banco
final List<FinancialHistoryPlatformModel> links = await db
    .financialHistoryPlatformDao
    .getPlatformsByFinancialHistoryId(id);

// 2. Para cada linha, resolve o nome da plataforma via catálogo `platform`
for (final FinancialHistoryPlatformModel link in links) {
  final PlatformModel? platform = await db.platformDao.getPlatformById(
    link.platformId,
  );
  // 3. Monta a visão de domínio com o nome resolvido + totais
  platforms.add(
    FinancialHistoryPlatform(
      name: platform?.name ?? 'DESCONHECIDA',
      totalValue: link.dailyEarnings,
      totalRides: link.dailyTripCount,
    ),
  );
}
```

#### No `save` (domínio → banco), via `_replacePlatformLinks`:

```dart
for (final FinancialHistoryPlatform platform in report.platforms) {
  final String platformId = await _ensurePlatform(db, platform.name);
  await db.financialHistoryPlatformDao.insertFinancialHistoryPlatform(
    FinancialHistoryPlatformModel(
      id: _newId(),
      financialHistoryId: report.id,
      platformId: platformId,
      dailyEarnings: platform.totalValue,
      dailyTripCount: platform.totalRides,
    ),
  );
}
```

Auxiliares importantes:

- **`_ensurePlatform(db, name)`** — garante que a plataforma exista no catálogo `platform` (busca case-insensitive; se não encontrar, insere e reutiliza o novo id).
- **`_replacePlatformLinks`** — substitui todos os vínculos da `financial_history_platform` do report pelos atuais (deleta os antigos e insere os novos).

**Finalidade:** isolar a complexidade relacional (JOINs, upsert de catálogo, FKs) da UI. **A view/controller NUNCA dependem desta classe para persistir** — tudo passa por este repositório.

---

### 3.4 `PlatformsSection` (widget de exibição) — uso indireto

**Arquivo:** `lib/features/financial_history/widgets/platforms_section.dart`

Atualmente o widget `PlatformsSection` usa **dados mock** (constantes) e não instancia `FinancialHistoryPlatform` diretamente — ele exibe `PlatformCard` com valores pré-definidos:

```dart
static const List<({String name, String totalValue, String totalRides})>
_platforms = [
  (name: 'UBER', totalValue: '€ 55,89', totalRides: '06'),
  (name: 'BOLT', totalValue: '€ 10,09', totalRides: '06'),
  (name: 'FREENOW', totalValue: '€ 0,00', totalRides: '00'),
];
```

**Intenção da arquitetura:** quando o "add plataforma" deixar de ser mock e passar a fazer uso do controller, a seção passará a renderizar os itens de `report.platforms` (que são objetos `FinancialHistoryPlatform`), substituindo esta lista mockada. Os dados já estão no formato correto: `name`, `totalValue` (€) e `totalRides`.

---

## 4. Imutabilidade e `copyWith`

- Os campos `name`, `totalValue` e `totalRides` são `final` → **não podem ser alterados após a instanciação**.
- O método `copyWith` permite criar uma nova instância com valores substituídos, mantendo os demais inalterados:

```dart
final atualizado = plataforma.copyWith(totalValue: 75.90); // nome e totalRides mantidos
```

- **Finalidade:** evita mutação acidental de estado e favorece o fluxo imutável do `ChangeNotifier` (nova lista + `notifyListeners()`).

---

## 5. Por Que Esta Classe Não Pode Ser Removida

Remover `FinancialHistoryPlatform` **quebraria a arquitetura** mesmo parecendo duplicação de `FinancialHistoryPlatformModel`. Motivos:

1. **Separação de responsabilidades** — a UI/controller não devem depender de FKs de banco (`financialHistoryId`, `platformId`) nem de catálogo; elas precisam do **nome resolvido** e totais semânticos.
2. **`FinancialHistoryModel.totalEarnings`** depende da lista `List<FinancialHistoryPlatform>` para somar o faturamento.
3. **Toda a conversão** load/save faz bridging entre as duas classes — sem a classe de domínio, o repositório não teria para onde converter.
4. **`FinancialHistoryController`** manipula exclusivamente `FinancialHistoryPlatform` no estado da tela.

---

## 6. Mapa Rápido de Uso

```
FinancialHistoryRepository
    ├── getById  → produz FinancialHistoryPlatform (banco → domínio)
    └── save     → consome FinancialHistoryPlatform (domínio → banco)

FinancialHistoryModel
    └── platforms: List<FinancialHistoryPlatform>  (@ignore, não persiste)
            └── getter totalEarnings  (soma totalValue)

FinancialHistoryController
    ├── addPlatform     → cria novas FinancialHistoryPlatform
    ├── updatePlatform  → usa copyWith em FinancialHistoryPlatform
    └── removePlatform  → remove da lista

FinancialHistoryView / PlatformsSection
    └── (eventualmente) renderiza FinancialHistoryPlatform do controller
```

---

## 7. Referências Cruzadas

| Artefato | Caminho |
|---|---|
| Classe de domínio | `lib/features/financial_history/domain/financial_history_platform.dart` |
| Entidade persistida | `lib/features/financial_history/domain/financial_history_platform_model.dart` |
| Entidade diária (pai) | `lib/features/financial_history/domain/financial_history_model.dart` |
| Repositório (conversão) | `lib/features/financial_history/data/financial_history_repository.dart` |
| Contrato do repositório | `lib/features/financial_history/data/financial_history_repository_interface.dart` |
| Controller (estado da tela) | `lib/features/financial_history/controller/financial_history_controller.dart` |
| DAO das plataformas | `lib/features/financial_history/data/financial_history_platform_dao.dart` |
| Visual (carrossel de plataformas) | `lib/features/financial_history/widgets/platforms_section.dart` |
| Análise de modelagem | `ANALISE_MODELAGEM_E_PERSISTENCIA.md` |
