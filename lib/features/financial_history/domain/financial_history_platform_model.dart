import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/app/generic/base_model.dart';

import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

@Entity(
  tableName: 'financial_history_platform',
  foreignKeys: [
    ForeignKey(
      childColumns: ['financial_history_id'],
      parentColumns: ['id'],
      entity: FinancialHistoryModel,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['platform_id'],
      parentColumns: ['id'],
      entity: PlatformModel,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
  indices: [
    Index(value: ['financial_history_id']),
    Index(value: ['platform_id']),
  ],
)
class FinancialHistoryPlatformModel implements BaseModel {
  @override
  @primaryKey
  final String id;
  
  @ColumnInfo(name: 'financial_history_id') /// ################# FK para o registro diário (financial_history.id).
  final String financialHistoryId;
  
  @ColumnInfo(name: 'platform_id') /// ########################## FK para a plataforma (platform.id).
  final String platformId;
  
  @ColumnInfo(name: 'daily_earnings') /// ####################### Faturamento total do dia nessa plataforma, em euros.
  final double dailyEarnings;

  @ColumnInfo(name: 'daily_trip_count') /// #################### Quantidade total de corridas do dia nessa plataforma.
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
