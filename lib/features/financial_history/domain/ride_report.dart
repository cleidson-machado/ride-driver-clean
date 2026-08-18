import 'ride_report_platform.dart';

/// Modelo de domínio que representa um "passeio" — um dia de trabalho do
/// motorista de aplicativo.
///
/// Centraliza todos os campos hoje espalhados como variáveis soltas no
/// `State` da [FinancialHistoryView] (ver `lib/features/financial_history/`).
///
/// É um modelo de domínio **puro**, desacoplado da persistência: a view e o
/// controller trabalham apenas com esta estrutura. O mapeamento para as
/// entidades locais (`FinancialHistoryModel`, `FinancialHistoryPlatformModel`
/// e `PlatformModel`) fica na camada de repositório.
class RideReport {
  const RideReport({
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
  final String id;

  /// Número legível do passeio (SKU). Ex.: "PASSEIO 011".
  final String sku;

  /// Data do dia trabalhado.
  final DateTime date;

  /// Quilometragem de saída (hodômetro no início do dia).
  final int kmIn;

  /// Quilometragem de entrada (hodômetro no fim do dia).
  ///
  /// Anulável: o usuário pode ainda não ter preenchido o KM - OUT.
  final int? kmOut;

  /// Valor do combustível/energia gasto no dia (em euros).
  final double cashSpent;

  /// Indica se o hodômetro 2 foi zerado antes do início das corridas.
  final bool hodo2IsZero;

  /// Valor final marcado no hodômetro 2 ao fim do dia, se preenchido.
  final int? hodo2Number;

  /// Indica se há imagens anexadas apoiando os registros do dia.
  final bool hasImages;

  /// Indica se o dia de trabalho foi concluído e fechado corretamente.
  final bool isFinished;

  /// Anotação livre sobre o dia.
  final String notes;

  /// Lista de plataformas usadas no dia (valor total + nº de corridas).
  final List<RideReportPlatform> platforms;

  /// Cria um report em branco (modo cadastro) com um novo id e SKU ainda
  /// vazio ("PASSEIO —"), data de hoje e valores neutros.
  factory RideReport.blank({required String id, required DateTime date}) {
    return RideReport(
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
      platforms: const <RideReportPlatform>[],
    );
  }

  /// Soma do faturamento de todas as plataformas do passeio.
  double get totalEarnings => platforms.fold(
        0,
        (double sum, RideReportPlatform platform) =>
            sum + platform.totalValue,
      );

  /// Lucro simples, sem considerar o valor de Gas/Energia do dia
  /// (conforme a legenda "LUCRO simples, sem VALOR Gas/Energia do DIA!").
  ///
  /// Fórmula: (soma dos valores das plataformas) − cashSpent.
  double get profit => totalEarnings - cashSpent;

  /// Cópia imutável com novos valores. Campos omitidos mantêm o atual.
  RideReport copyWith({
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
    List<RideReportPlatform>? platforms,
  }) {
    return RideReport(
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
