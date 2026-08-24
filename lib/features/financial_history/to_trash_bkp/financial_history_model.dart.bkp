import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/app/generic/base_model.dart';

import 'financial_history_platform.dart';

/// ENTIDADE-PAI da feature — tabela `financial_history` (1 linha por dia).
///
/// Representa um "passeio": um dia de trabalho do motorista. É a Única
/// classe da feature que reúne domínio + persistência (unificou o antigo
/// `RideReport` e o antigo `FinancialHistoryModel`): getters de negócio
/// ([totalEarnings], [profit]), `copyWith`/`blank` e `toMap`/`fromMap`.
/// As anotações Floor são só contrato/documentação — a persistência real
/// é sqflite manual.
///
/// Não confundir com as classes "platform" da feature:
///  - [FinancialHistoryPlatform] (domain/): NÃO é entidade — é o item já
///    resolvido (nome + totais) da lista [platforms] desta classe;
///  - `FinancialHistoryPlatformModel`: entidade da tabela associativa
///    `financial_history_platform`, onde a lista [platforms] é de fato
///    persistida (via repositório).
///
/// Tese de lucratividade: um passeio é considerado lucrativo quando o valor
/// do combustível é reposto no mesmo dia, acrescido do dobro do seu valor
/// + 100 € de giro extra. Exemplo: combustível = 50 € → giro necessário
/// = 200 €, descontando os 50 € de combustível.
///
/// Convenções de mapeamento (colunas NOT NULL no schema atual):
///  - `work_date` guarda a data em epoch millis;
///  - `km_end == 0` e `km_odometer == 0` representam "não informado"
///    ([kmOut]/[hodo2Number] nulos no domínio).
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

  /// Identificador único interno do report/passeio.
  @override
  @primaryKey
  final String id;

  /// Número legível do passeio (SKU), complementar ao ID interno.
  /// Ex.: "PASSEIO 011".
  @ColumnInfo(name: 'trip_number')
  final String sku;

  /// Data do dia trabalhado (persistida como epoch millis em `work_date`).
  @ColumnInfo(name: 'work_date')
  final DateTime date;

  /// Quilometragem de saída (hodômetro no início do dia).
  @ColumnInfo(name: 'km_start')
  final int kmIn;

  /// Quilometragem de entrada (hodômetro no fim do dia).
  ///
  /// Anulável: o usuário pode ainda não ter preenchido o KM - OUT.
  @ColumnInfo(name: 'km_end')
  final int? kmOut;

  /// Valor do combustível/energia gasto no dia (em euros).
  @ColumnInfo(name: 'fuel_cost')
  final double cashSpent;

  /// Indica se o hodômetro 2 foi zerado antes do início das corridas.
  @ColumnInfo(name: 'hodo2_is_zero')
  final bool hodo2IsZero;

  /// Valor final marcado no hodômetro 2 ao fim do dia, se preenchido.
  /// Auxilia na confirmação dos cálculos e fornece redundância.
  @ColumnInfo(name: 'km_odometer')
  final int? hodo2Number;

  /// Indica se há imagens anexadas apoiando os registros do dia.
  @ColumnInfo(name: 'has_images')
  final bool hasImages;

  /// Indica se o dia de trabalho foi concluído e fechado corretamente.
  @ColumnInfo(name: 'is_finished')
  final bool isFinished;

  /// Anotação livre sobre o dia.
  final String notes;

  /// Lista de plataformas usadas no dia (valor total + nº de corridas).
  ///
  /// Não é coluna desta tabela: vive na associativa
  /// `financial_history_platform` e é montada pelo repositório.
  @ignore
  final List<FinancialHistoryPlatform> platforms;

  /// Cria um report em branco (modo cadastro) com um novo id e SKU ainda
  /// vazio ("PASSEIO —"), data de hoje e valores neutros.
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
      platforms: const <FinancialHistoryPlatform>[],
    );
  }

  /// Soma do faturamento de todas as plataformas do passeio.
  double get totalEarnings => platforms.fold(
    0,
    (double sum, FinancialHistoryPlatform platform) =>
        sum + platform.totalValue,
  );

  /// Lucro simples, sem considerar o valor de Gas/Energia do dia
  /// (conforme a legenda "LUCRO simples, sem VALOR Gas/Energia do DIA!").
  ///
  /// Fórmula: (soma dos valores das plataformas) − cashSpent.
  double get profit => totalEarnings - cashSpent;

  /// Reconstrói a entidade a partir de uma linha da tabela
  /// `financial_history`. [platforms] inicia vazia — o repositório a
  /// preenche via `copyWith` após resolver a tabela associativa.
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
      platforms: const <FinancialHistoryPlatform>[],
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

  /// Cópia imutável com novos valores. Campos omitidos mantêm o atual.
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
    List<FinancialHistoryPlatform>? platforms,
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
