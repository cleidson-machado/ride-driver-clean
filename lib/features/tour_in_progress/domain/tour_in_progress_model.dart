/// Modelo de domínio de um passeio/tour no contexto de `tour_in_progress`.
///
/// Representa um registro em "curso" (ou finalizado) conforme persistido na
/// tabela `financial_history`. É um modelo de leitura específico deste
/// bounded context: carrega apenas os campos necessários para a tela de
/// passeio em curso (resumo do topo + histórico recente de finalizados),
/// sem a complexidade dos vínculos de plataforma do contexto financeiro.
class TourInProgressModel {
  final String id;
  final String sku;
  final DateTime date;

  /// Instante real de criação do passeio no aparelho (coluna `created_at`).
  ///
  /// Diferente de [date] (data do passeio, inserida/alterável pelo utilizador,
  /// podendo ser anos no passado). Usado como âncora do cronômetro de "em
  /// curso" — o timer conta a partir do verdadeiro momento de criação.
  final DateTime createdAt;

  /// Odômetro registrado na abertura do passeio.
  final int kmIn;

  /// Odômetro de fechamento — `null` enquanto o passeio estiver em curso
  /// (ainda não encerrado). Preenchido e >= [kmIn] ao encerrar.
  final int? kmOut;

  /// Hodômetro do trajeto (`km_odometer`), exibido como "HOD" nos cards.
  final int kmOdometer;

  /// Gasto total em combustível/energia no passeio. Sempre >= 0.
  final double cashSpent;

  /// `true` quando o passeio foi finalizado; `false` quando está "em curso".
  final bool isFinished;

  const TourInProgressModel({
    required this.id,
    required this.sku,
    required this.date,
    required this.createdAt,
    required this.kmIn,
    required this.kmOut,
    required this.kmOdometer,
    required this.cashSpent,
    required this.isFinished,
  });

  /// Constrói um modelo a partir de uma linha da tabela `financial_history`.
  ///
  /// Assim como em `FinancialHistoryModel.fromMap`, o `km_end == 0` é
  /// interpretado como "ainda não preenchido" (`kmOut = null`).
  factory TourInProgressModel.fromMap(Map<String, dynamic> map) {
    final int kmEnd = map['km_end'] as int;
    return TourInProgressModel(
      id: map['id'] as String,
      sku: map['trip_number'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['work_date'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      kmIn: map['km_start'] as int,
      kmOut: kmEnd == 0 ? null : kmEnd,
      kmOdometer: map['km_odometer'] as int? ?? 0,
      cashSpent: (map['fuel_cost'] as num).toDouble(),
      isFinished: ((map['is_finished'] as int?) ?? 0) == 1,
    );
  }

  TourInProgressModel copyWith({
    String? sku,
    DateTime? date,
    int? kmIn,
    int? Function()? kmOut,
    int? kmOdometer,
    double? cashSpent,
    bool? isFinished,
  }) {
    return TourInProgressModel(
      id: id,
      sku: sku ?? this.sku,
      date: date ?? this.date,
      // createdAt é imutável: preserva o instante real de criação do passeio.
      createdAt: createdAt,
      kmIn: kmIn ?? this.kmIn,
      kmOut: kmOut != null ? kmOut() : this.kmOut,
      kmOdometer: kmOdometer ?? this.kmOdometer,
      cashSpent: cashSpent ?? this.cashSpent,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is TourInProgressModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TourInProgressModel('
        'id: $id, sku: $sku, date: $date, createdAt: $createdAt, '
        'kmIn: $kmIn, kmOut: $kmOut, kmOdometer: $kmOdometer, '
        'cashSpent: $cashSpent, isFinished: $isFinished)';
  }
}

