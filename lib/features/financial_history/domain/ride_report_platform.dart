/// Platforma usada em um [RideReport] — o faturamento e o número de corridas
/// de UMA plataforma em UM dia de trabalho.
///
/// Corresponde à tabela associativa `financial_history_platform` (lado da
/// entidade `FinancialHistoryPlatformModel`), mas aqui como modelo de domínio
/// puro, sem vínculo com a camada de persistência.
class RideReportPlatform {
  const RideReportPlatform({
    required this.name,
    required this.totalValue,
    required this.totalRides,
  });

  /// Nome da plataforma (ex.: UBER, BOLT, FREENOW, PARTICULAR).
  final String name;

  /// Faturamento total do dia nessa plataforma, em euros.
  final double totalValue;

  /// Quantidade total de corridas do dia nessa plataforma.
  final int totalRides;

  /// Cópia com novos valores (imutável). Campos omitidos mantêm o atual.
  RideReportPlatform copyWith({
    String? name,
    double? totalValue,
    int? totalRides,
  }) {
    return RideReportPlatform(
      name: name ?? this.name,
      totalValue: totalValue ?? this.totalValue,
      totalRides: totalRides ?? this.totalRides,
    );
  }
}
