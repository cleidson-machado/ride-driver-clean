import 'package:ride_driver_app_1/app/generic/base_model.dart';
import 'financial_history_platform_model.dart';

class FinancialHistoryModel implements BaseModel {

  @override
  final String id;
  final String sku;
  final DateTime date;
  final int kmIn;
  final int? kmOut;
  final double cashSpent;
  final bool hodo2IsZero;
  final int? hodo2Number;
  final bool hasImages;
  final bool isFinished;
  final String notes;
  final List<FinancialHistoryPlatformModel> platforms;

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
      platforms: const <FinancialHistoryPlatformModel>[],
    );
  }

  double get totalEarnings => platforms.fold(
    0,
    (double sum, FinancialHistoryPlatformModel platform) =>
        sum + platform.dailyEarnings,
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
      platforms: const <FinancialHistoryPlatformModel>[],
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
    List<FinancialHistoryPlatformModel>? platforms,
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

