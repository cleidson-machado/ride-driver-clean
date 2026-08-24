// =============================================================================
// FinancialHistoryPlatformSummaryModel
// -----------------------------------------------------------------------------
// VISÃO DE DOMÍNIO (imutável) já "resolvida" para consumo da UI/controller.
//
// Diferente de FinancialHistoryPlatformModel (entidade SQLite crua, com FK,
// dailyEarnings e dailyRides), ESTE modelo já combina o catálogo de plataformas
// (PlatformModel) com os valores do dia e entrega pronto para a camada de
// apresentação: `name` (ex.: UBER/BOLT/FREENOW), `totalValue` (faturamento em €)
// e `totalRides` (nº de corridas).
//
// NÃO É 1:1 com a tabela `financial_history_platform`. Quem monta o objeto é o
// FINANCIAL_HISTORY_SERVICE (camada de dados), que lê os links (associativos),
// resolve o nome real do catálogo `platform` e agrupa os totais por plataforma.
//
// ⚠️ LEMBRETE DE USO:
//   - Controller (financial_history_controller.dart) é quem MANIPULA essas
//     instâncias (addPlatform/updatePlatform/removePlatform) e o que a UI exibe.
//   - Sempre imutável: altere via `copyWith`, nunca mude os campos in-place.
//   - Viva apenas em memória (report do controller). NÃO persista diretamente —
//     a persistência passa por PlatformModel + FinancialHistoryPlatformModel.
// =============================================================================
class FinancialHistoryPlatformSummaryModel {
  const FinancialHistoryPlatformSummaryModel({
    required this.name,
    required this.totalValue,
    required this.totalRides,
  });

  /// Nome da plataforma (Uber, Bolt, FREENOW, PARTICULAR...).
  final String name;

  /// Faturamento total (€) registrado nessa plataforma no dia.
  final double totalValue;

  /// Número total de corridas realizadas nessa plataforma no dia.
  final int totalRides;

  /// Retorna uma cópia imutável, com os campos informados substituídos.
  FinancialHistoryPlatformSummaryModel copyWith({
    String? name,
    double? totalValue,
    int? totalRides,
  }) {
    return FinancialHistoryPlatformSummaryModel(
      name: name ?? this.name,
      totalValue: totalValue ?? this.totalValue,
      totalRides: totalRides ?? this.totalRides,
    );
  }
}

