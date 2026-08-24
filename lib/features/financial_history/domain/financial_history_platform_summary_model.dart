
class FinancialHistoryPlatformSummaryModel {
  const FinancialHistoryPlatformSummaryModel({
    required this.name,
    required this.totalValue,
    required this.totalRides,
  });

  final String name;

  final double totalValue;

  final int totalRides;

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
