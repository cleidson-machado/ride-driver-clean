/// Formatação centralizada de quilometragem e moeda (€).
abstract final class RideFormatters {
  // Construtor privado: classe utilitária sem instâncias.
  RideFormatters._();

  static const List<String> _monthNames = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  /// Formata um valor inteiro de quilometragem com separadores de milhar.
  ///
  /// Ex.: `44762` → `"44.762"`. Retorna `"NONE"` quando [value] é nulo
  /// (campo ainda não preenchido), preservando o comportamento da view.
  static String formatKm(int? value) {
    if (value == null) {
      return 'NONE';
    }
    final String digits = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final int remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  /// Formata um valor monetário em euros, com vírgula decimal.
  ///
  /// Ex.: `55.89` → `"€ 55,89"`. Retorna `"NONE"` quando [value] é nulo.
  static String formatCurrency(double? value) {
    if (value == null) {
      return 'NONE';
    }
    return '€ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Retorna o rótulo de data no formato usado pelo cabeçalho.
  ///
  /// Ex.: `16 Julho 2026`.
  static String formatDateLabel(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  /// Extrai apenas o número do SKU legível para exibição compacta.
  ///
  /// Ex.: `"PASSEIO 011"` → `"011"`. Retorna o [sku] original quando não há
  /// dígitos a extrair.
  static String shortSku(String sku) {
    final Match? match = RegExp(r'\d+').firstMatch(sku);
    return match?.group(0) ?? sku;
  }
}

