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

  /// Nome legível da plataforma (ex.: "UBER"). Não é uma coluna de
  /// `financial_history_platform` — o nome vive na tabela `platform`. É
  /// populado apenas em memória pela service ao montar o estado de visualização
  /// (getById) e pelo controller ao adicionar/editar plataformas no formulário.
  final String name;

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
}

