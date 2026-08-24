import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/app/generic/base_model.dart';
import 'financial_history_platform_summary_dto.dart';

@Entity(tableName: 'financial_history')
class FinancialHistoryModel implements BaseModel {
  const FinancialHistoryModel({
    required this.id,
    required this.sku,
    required this.date,
    required this.kmIn,
    required this.kmOut,
    required this.cashSpent,
    required this.hodo2IsZero,
    required this.hodo2Number,
    required this.hasImages,
    required this.isFinished,
    required this.notes,
    required this.platforms,
  });

  @override
  @primaryKey
  final String id;

  @ColumnInfo(name: 'trip_number')
  final String sku;

  @ColumnInfo(name: 'work_date')
  final DateTime date;

  @ColumnInfo(name: 'km_start')
  final int kmIn;

  @ColumnInfo(name: 'km_end')
  final int? kmOut;

  @ColumnInfo(name: 'fuel_cost')
  final double cashSpent;

  @ColumnInfo(name: 'hodo2_is_zero')
  final bool hodo2IsZero;

  @ColumnInfo(name: 'km_odometer')
  final int? hodo2Number;

  @ColumnInfo(name: 'has_images')
  final bool hasImages;

  @ColumnInfo(name: 'is_finished')
  final bool isFinished;

  final String notes;

  @ignore
  final List<FinancialHistoryPlatformSummaryDTO> platforms;

  factory FinancialHistoryModel.blank({
    required String id,
    required DateTime date,
  }) {
    return FinancialHistoryModel(
      id: id,
      sku: 'PASSEIO —',
      date: date,
      kmIn: 0,
      kmOut: null,
      cashSpent: 0,
      hodo2IsZero: true,
      hodo2Number: null,
      hasImages: false,
      isFinished: false,
      notes: '',
      platforms: const <FinancialHistoryPlatformSummaryDTO>[],
    );
  }

  double get totalEarnings => platforms.fold(
    0,
    (double sum, FinancialHistoryPlatformSummaryDTO platform) =>
        sum + platform.totalValue,
  );

  double get profit => totalEarnings - cashSpent;

  factory FinancialHistoryModel.fromMap(Map<String, dynamic> map) {
    final int kmEnd = map['km_end'] as int;
    final int kmOdometer = map['km_odometer'] as int;
    return FinancialHistoryModel(
      id: map['id'] as String,
      sku: map['trip_number'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['work_date'] as int),
      kmIn: map['km_start'] as int,
      kmOut: kmEnd == 0 ? null : kmEnd,
      cashSpent: (map['fuel_cost'] as num).toDouble(),
      hodo2IsZero: ((map['hodo2_is_zero'] as int?) ?? 1) == 1,
      hodo2Number: kmOdometer == 0 ? null : kmOdometer,
      hasImages: ((map['has_images'] as int?) ?? 0) == 1,
      isFinished: ((map['is_finished'] as int?) ?? 0) == 1,
      notes: map['notes'] as String,
      platforms: const <FinancialHistoryPlatformSummaryDTO>[],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'work_date': date.millisecondsSinceEpoch,
      'trip_number': sku,
      'fuel_cost': cashSpent,
      'km_start': kmIn,
      'km_end': kmOut ?? 0,
      'km_odometer': hodo2Number ?? 0,
      'notes': notes,
      'hodo2_is_zero': hodo2IsZero ? 1 : 0,
      'has_images': hasImages ? 1 : 0,
      'is_finished': isFinished ? 1 : 0,
    };
  }

  FinancialHistoryModel copyWith({
    String? sku,
    DateTime? date,
    int? kmIn,
    int? Function()? kmOut,
    double? cashSpent,
    bool? hodo2IsZero,
    int? Function()? hodo2Number,
    bool? hasImages,
    bool? isFinished,
    String? notes,
    List<FinancialHistoryPlatformSummaryDTO>? platforms,
  }) {
    return FinancialHistoryModel(
      id: id,
      sku: sku ?? this.sku,
      date: date ?? this.date,
      kmIn: kmIn ?? this.kmIn,
      kmOut: kmOut != null ? kmOut() : this.kmOut,
      cashSpent: cashSpent ?? this.cashSpent,
      hodo2IsZero: hodo2IsZero ?? this.hodo2IsZero,
      hodo2Number: hodo2Number != null ? hodo2Number() : this.hodo2Number,
      hasImages: hasImages ?? this.hasImages,
      isFinished: isFinished ?? this.isFinished,
      notes: notes ?? this.notes,
      platforms: platforms ?? this.platforms,
    );
  }
}
