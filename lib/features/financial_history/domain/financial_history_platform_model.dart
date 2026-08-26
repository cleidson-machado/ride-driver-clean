import 'package:ride_driver_app_1/app/generic/base_model.dart';

class FinancialHistoryPlatformModel implements BaseModel {

  @override
  final String id;
  final String name;
  final String financialHistoryId;
  final String platformId;
  final double dailyEarnings;
  final int dailyTripCount;

  const FinancialHistoryPlatformModel({
    required this.id,
    required this.financialHistoryId,
    required this.platformId,
    required this.dailyEarnings,
    required this.dailyTripCount,
    this.name = '',
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

  FinancialHistoryPlatformModel copyWith({
    String? financialHistoryId,
    String? platformId,
    double? dailyEarnings,
    int? dailyTripCount,
    String? name,
  }) {
    return FinancialHistoryPlatformModel(
      id: id,
      financialHistoryId: financialHistoryId ?? this.financialHistoryId,
      platformId: platformId ?? this.platformId,
      dailyEarnings: dailyEarnings ?? this.dailyEarnings,
      dailyTripCount: dailyTripCount ?? this.dailyTripCount,
      name: name ?? this.name,
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
      // 'name' não é persistido: o nome fica na tabela `platform`.
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FinancialHistoryPlatformModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

