// =============================================================================
// FinancialHistoryPlatformSummaryModel
// -----------------------------------------------------------------------------
// É UM DTO DE VISÃO (DTO de domínio / ViewModel). - É, SIM, um DTO.
//
// O próprio projeto o trata como "DTO de visão" (ver README.md, FASE 2/3 e
// CONSOLIDACAO_ARQUITETURAL_FINAL.md — todos o chamam de "DTO/visão de domínio,
// não persistido").
//
// ▶ POR QUE É UM DTO?
//   - Não tem anotação @Entity → NÃO é persistido em nenhuma tabela SQLite.
//   - Sua ÚNICA função é TRANSFERIR dados prontos entre camadas:
//     camada de dados (service) → controller → UI.
//   - Carrega apenas o que a tela precisa (nome + totais), sem FK, sem campos crus.
//
// ▶ MAS TAMBÉM É UMA "VISÃO DE DOMÍNIO"?
//   Sim — são a MESMA coisa aqui. Um DTO cuja finalidade é apresentar uma visão
//   já "resolvida" da entidade para a UI. Não é nem a entidade de banco nem um
//   DTO de request/response de API genérico: é o formato de leitura/exibição.
//
// ▶ A REGRA DE OURO PARA NÃO CONFUNDIR:
//   | Modelo                                  | É @Entity? | Persistido?  | Papel                    |
//   | FinancialHistoryPlatformModel           | SIM        | SIM (SQLite) | Entidade associativa crua |
//   | FinancialHistoryPlatformSummaryModel    | NÃO        | NÃO          | DTO de visão p/ UI      |
//   Se tiver que SALVAR → use o *_PlatformModel e PlatformModel.
//   Se for só EXIBIR na tela  → use ESTE DTO aqui.
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

