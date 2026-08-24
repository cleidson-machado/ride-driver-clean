/// ## `FinancialHistoryPlatform` — visão de domínio (NÃO é entidade)
///
/// Representa o faturamento e o nº de corridas de **UMA plataforma em UM dia
/// de trabalho**, na forma **resolvida para a UI/controller**: já traz o `name`
/// da plataforma e os totais prontos para uso.
///
/// ⚠️ **PAPEL IMPORTANTE — NÃO confundir com `FinancialHistoryPlatformModel`.**
/// As duas classes parecem semelhantes, mas ocupam **camadas distintas e
/// complementares** do projeto (padrão repositório: entidade × visão de domínio):
///
/// - **`FinancialHistoryPlatformModel`** é a **ENTIDADE** persistida (tabela
///   `financial_history_platform`). Contém só FKs e valores crus: `id`,
///   `financialHistoryId`, `platformId`, `dailyEarnings`, `dailyTripCount`.
///   Não carrega o nome da plataforma (o nome vive no catálogo `platform`).
///   É usada apenas por DAO / camada de dados.
///
/// - **`FinancialHistoryPlatform`** (esta classe) é o **modelo de domínio**,
///   sem vínculo nenhum com SQLite (`@Entity`/Floor/`BaseModel`). Guarda o
///   `name` resolvido + totais. É o que a UI, o controller e a view enxergam.
///
/// ### Onde esta classe é usada
/// - **`FinancialHistoryModel.platforms`** — a lista `List<FinancialHistoryPlatform>`
///   que alimenta o getter `totalEarnings` (somatório dos `totalValue`).
/// - **`FinancialHistoryController`** — `addPlatform`, `updatePlatform` e
///   `removePlatform` manipulam objetos desta classe para o estado da tela.
/// - **`FinancialHistoryRepository`** — faz a **conversão entre as duas classes**:
///   no `load`, lê linhas `FinancialHistoryPlatformModel` do banco, faz join com
///   `platform` e monta objetos desta classe (visão com nome); no `save`, converte
///   de volta para `FinancialHistoryPlatformModel` ao persistir.
///
/// Ou seja: **a UI/controller nunca dependem desta classe para persistir**;
/// quem faz a ponte com o banco é o repositório. Por isso **remover esta classe
/// quebraria a arquitetura** — ela não é duplicação de `FinancialHistoryPlatformModel`.
class FinancialHistoryPlatform {
  const FinancialHistoryPlatform({
    required this.name,
    required this.totalValue,
    required this.totalRides,
  });

  /// Nome da plataforma (ex.: UBER, BOLT, FREENOW, PARTICULAR).
  /// *(Resolvido a partir do catálogo `platform` pelo repositório no `load`.)*
  final String name;

  /// Faturamento total do dia nessa plataforma, em euros.
  /// *(Mapeado para `daily_earnings` em `FinancialHistoryPlatformModel`.)*
  final double totalValue;

  /// Quantidade total de corridas do dia nessa plataforma.
  /// *(Mapeado para `daily_trip_count` em `FinancialHistoryPlatformModel`.)*
  final int totalRides;

  /// Cópia com novos valores (imutável). Campos omitidos mantêm o atual.
  /// *(Usado pelo `FinancialHistoryController.updatePlatform`.)*
  FinancialHistoryPlatform copyWith({
    String? name,
    double? totalValue,
    int? totalRides,
  }) {
    return FinancialHistoryPlatform(
      name: name ?? this.name,
      totalValue: totalValue ?? this.totalValue,
      totalRides: totalRides ?? this.totalRides,
    );
  }
}
