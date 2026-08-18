import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/app/generic/base_model.dart';

/// Entidade que representa um registro financeiro diário de trabalho.
///
/// Derivada da planilha de controle original. Cada instância equivale a
/// um dia de trabalho do motorista, contendo os dados de quilometragem,
/// custo de combustível e observações gerais.
@Entity(tableName: 'financial_history')
class FinancialHistoryModel implements BaseModel {
  @override
  @primaryKey
  final String id;

  /// Data do dia trabalhado, armazenada como timestamp (epoch millis)
  /// para compatibilidade com Floor — converta com [date] para [DateTime].
  @ColumnInfo(name: 'work_date')
  final int dateMillis;

  /// Número do passeio / viagem — um identificador de fácil leitura humana
  /// (espécie de SKU), complementar ao ID interno do banco.
  @ColumnInfo(name: 'trip_number')
  final String tripNumber;

  /// Valor do combustível gasto no dia (em euros).
  ///
  /// Tese de lucratividade: um passeio é considerado lucrativo quando o
  /// valor do combustível é reposto no mesmo dia, acrescido do dobro do
  /// seu valor + 100 € de giro extra. Exemplo: combustível = 50 € →
  /// giro necessário = 200 €, descontando os 50 € de combustível.
  @ColumnInfo(name: 'fuel_cost')
  final double fuelCost;

  /// Quilometragem de saída (hodômetro no início do dia).
  @ColumnInfo(name: 'km_start')
  final int kmStart;

  /// Quilometragem de entrada (hodômetro no fim do dia).
  @ColumnInfo(name: 'km_end')
  final int kmEnd;

  /// Quilometragem rodada registrada manualmente pelo hodômetro do carro.
  /// Auxilia na confirmação dos cálculos e fornece redundância.
  @ColumnInfo(name: 'km_odometer')
  final int kmOdometer;

  /// Anotação livre sobre o dia.
  final String notes;

  /// Hodômetro 2 zerado antes das corridas? (0/1 no SQLite).
  @ColumnInfo(name: 'hodo2_is_zero')
  final bool hodo2IsZero;

  /// Há imagens anexadas ao dia? (0/1 no SQLite).
  @ColumnInfo(name: 'has_images')
  final bool hasImages;

  /// Dia de trabalho concluído/fechado? (0/1 no SQLite).
  @ColumnInfo(name: 'is_finished')
  final bool isFinished;

  const FinancialHistoryModel({
    required this.id,
    required this.dateMillis,
    required this.tripNumber,
    required this.fuelCost,
    required this.kmStart,
    required this.kmEnd,
    required this.kmOdometer,
    required this.notes,
    this.hodo2IsZero = true,
    this.hasImages = false,
    this.isFinished = false,
  });

  /// Getter de conveniência: retorna a data como [DateTime].
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dateMillis);

  factory FinancialHistoryModel.fromMap(Map<String, dynamic> map) {
    return FinancialHistoryModel(
      id: map['id'] as String,
      dateMillis: map['work_date'] as int,
      tripNumber: map['trip_number'] as String,
      fuelCost: (map['fuel_cost'] as num).toDouble(),
      kmStart: map['km_start'] as int,
      kmEnd: map['km_end'] as int,
      kmOdometer: map['km_odometer'] as int,
      notes: map['notes'] as String,
      hodo2IsZero: ((map['hodo2_is_zero'] as int?) ?? 1) == 1,
      hasImages: ((map['has_images'] as int?) ?? 0) == 1,
      isFinished: ((map['is_finished'] as int?) ?? 0) == 1,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'work_date': dateMillis,
      'trip_number': tripNumber,
      'fuel_cost': fuelCost,
      'km_start': kmStart,
      'km_end': kmEnd,
      'km_odometer': kmOdometer,
      'notes': notes,
      'hodo2_is_zero': hodo2IsZero ? 1 : 0,
      'has_images': hasImages ? 1 : 0,
      'is_finished': isFinished ? 1 : 0,
    };
  }
}
