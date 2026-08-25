import 'package:ride_driver_app_1/app/generic/base_model.dart';

class FinancialHistoryPlatformModel implements BaseModel {
  @override
  final String id;
  
  /// FK para o registro diário (financial_history.id).
  final String financialHistoryId;
  
  /// FK para a plataforma (platform.id).
  final String platformId;
  
  /// Faturamento total do dia nessa plataforma, em euros.
  final double dailyEarnings;

  /// Quantidade total de corridas do dia nessa plataforma.
  final int dailyTripCount;
  const FinancialHistoryPlatformModel({
    required this.id,
    required this.financialHistoryId,
    required this.platformId,
    required this.dailyEarnings,
    required this.dailyTripCount,
  });

  factory FinancialHistoryPlatformModel.fromMap(Map<String, dynamic> map) {
    return FinancialHistoryPlatformModel(
      id: map['id'] as String,
      financialHistoryId: map['financial_history_id'] as String,
      platformId: map['platform_id'] as String,
      dailyEarnings: (map['daily_earnings'] as num).toDouble(),
      dailyTripCount: map['daily_trip_count'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'financial_history_id': financialHistoryId,
      'platform_id': platformId,
      'daily_earnings': dailyEarnings,
      'daily_trip_count': dailyTripCount,
    };
  }
}

