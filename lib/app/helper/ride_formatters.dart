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

  /// Rótulo de data do dispositivo no formato `"26 de AGOSTO - 2026"`, com o
  /// mês em caixa alta.
  ///
  /// Ex.: `DateTime(2026, DateTime.august, 26)` → `"26 de AGOSTO - 2026"`.
  static String formatCurrentDateLabel(DateTime date) {
    final String month = _monthNames[date.month - 1].toUpperCase();
    return '${date.day} de $month - ${date.year}';
  }

  /// Retorna a data no formato compacto `DD/MM/AA`, usado nos cards de
  /// histórico. Ex.: `16/07/26`.
  static String formatDateShort(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = (date.year % 100).toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  /// Extrai apenas o número do SKU legível para exibição compacta.
  ///
  /// Ex.: `"PASSEIO 011"` → `"011"`. Retorna o [sku] original quando não há
  /// dígitos a extrair.
  static String shortSku(String sku) {
    final Match? match = RegExp(r'\d+').firstMatch(sku);
    return match?.group(0) ?? sku;
  }

  /// Formata uma duração como cronômetro de contagem `HH:MM:SS`.
  ///
  /// Ex.: `Duration(hours: 3, minutes: 5, seconds: 9)` → `"03:05:09"`.
  /// Valores negativos (relógio fora de sincronia) são tratados como `00:00:00`.
  static String formatDuration(Duration duration) {
    final int totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(hours)}:${two(minutes)}:${two(seconds)}';
  }
}

