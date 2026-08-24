import 'package:flutter/foundation.dart';

import 'domain/financial_history_model.dart';
import 'domain/financial_history_platform_summary_model.dart';
import 'financial_history_service.dart';

/// Controller (ChangeNotifier) da tela de cadastro/edição de passeio.
///
/// Centraliza o estado da `FinancialHistoryView` que hoje vive solto no
/// `State` do widget. A view observa este notifier (via `AnimatedBuilder` /
/// `ListenableBuilder`) e chama os métodos de ação — ela nunca decide por si
/// qual é a "fonte da verdade".
///
/// Padrão adotado: **ChangeNotifier puro da Flutter**, injetado na view,
/// alinhado ao restante do projeto (que não usa packages de estado/DI).
///
/// To-do central desta etapa:
///  - `load()`, `save()` e `delete()` delegam para [FinancialHistoryService];
///  - todos os setters atualizam [_report] e notificam listeners;
///  - as validações antes de salvar ficam em [_validate].
class FinancialHistoryController extends ChangeNotifier {
  FinancialHistoryController({
    required FinancialHistoryService service,
    FinancialHistoryModel? initialReport,
  }) : _service = service,
       _report = initialReport ?? _buildBlankReport();

  final FinancialHistoryService _service;
  FinancialHistoryModel _report;

  // ── Estado exposto à view ────────────────────────────────────────────────

  FinancialHistoryModel get report => _report;

  /// Indica se há uma operação assíncrona (load/save/delete) em andamento.
  bool _busy = false;
  bool get busy => _busy;

  String? _lastError;
  String? get lastError => _lastError;

  /// Se o report ainda não foi persistido (modo cadastro).
  bool get isNew => _report.id.isEmpty;

  // ── Factory ───────────────────────────────────────────────────────────────

  static FinancialHistoryModel _buildBlankReport() {
    return FinancialHistoryModel.blank(id: _newId(), date: DateTime.now());
  }

  /// Gera um id único simples (timestamp + contador) sem dependências.
  static String _newId() {
    return '${DateTime.now().microsecondsSinceEpoch}';
  }

  // ── Ações síncronas (mutação do estado) ─────────────────────────────────

  void setDate(DateTime date) {
    _report = _report.copyWith(date: date);
    notifyListeners();
  }

  void setKmIn(int value) {
    _report = _report.copyWith(kmIn: _nonNegative(value));
    notifyListeners();
  }

  void incrementKmIn([int step = 1]) {
    setKmIn(_report.kmIn + step);
  }

  void decrementKmIn([int step = 1]) {
    setKmIn(_report.kmIn - step);
  }

  void setKmOut(int value) {
    _report = _report.copyWith(kmOut: () => _nonNegative(value));
    notifyListeners();
  }

  void incrementKmOut([int step = 1]) {
    final int current = _report.kmOut ?? _report.kmIn;
    setKmOut(current + step);
  }

  void decrementKmOut([int step = 1]) {
    final int current = _report.kmOut ?? _report.kmIn;
    setKmOut(current - step);
  }

  void setCashSpent(double value) {
    _report = _report.copyWith(cashSpent: value < 0 ? 0 : value);
    notifyListeners();
  }

  void incrementCashSpent([double step = 1]) {
    setCashSpent((_report.cashSpent) + step);
  }

  void decrementCashSpent([double step = 1]) {
    setCashSpent((_report.cashSpent) - step);
  }

  void setHodo2IsZero(bool value) {
    _report = _report.copyWith(hodo2IsZero: value);
    notifyListeners();
  }

  void setHodo2Number(int value) {
    _report = _report.copyWith(hodo2Number: () => _nonNegative(value));
    notifyListeners();
  }

  void incrementHodo2Number([int step = 1]) {
    final int current = _report.hodo2Number ?? 0;
    setHodo2Number(current + step);
  }

  void decrementHodo2Number([int step = 1]) {
    final int current = _report.hodo2Number ?? 0;
    setHodo2Number(current - step);
  }

  void setHasImages(bool value) {
    _report = _report.copyWith(hasImages: value);
    notifyListeners();
  }

  void setIsFinished(bool value) {
    _report = _report.copyWith(isFinished: value);
    notifyListeners();
  }

  void setNotes(String value) {
    _report = _report.copyWith(notes: value);
    notifyListeners();
  }

  // ── Plataformas ──────────────────────────────────────────────────────────

  /// Adiciona uma plataforma com os valores informados.
  void addPlatform({
    required String name,
    required double totalValue,
    required int totalRides,
  }) {
    final List<FinancialHistoryPlatformSummaryModel> updated =
        List<FinancialHistoryPlatformSummaryModel>.of(_report.platforms)..add(
          FinancialHistoryPlatformSummaryModel(
            name: name,
            totalValue: totalValue < 0 ? 0 : totalValue,
            totalRides: totalRides < 0 ? 0 : totalRides,
          ),
        );
    _report = _report.copyWith(platforms: updated);
    notifyListeners();
  }

  /// Atualiza a plataforma no índice [index] com novos valores.
  void updatePlatform(
    int index, {
    String? name,
    double? totalValue,
    int? totalRides,
  }) {
    final List<FinancialHistoryPlatformSummaryModel> updated =
        List<FinancialHistoryPlatformSummaryModel>.of(_report.platforms);
    updated[index] = updated[index].copyWith(
      name: name,
      totalValue: totalValue,
      totalRides: totalRides,
    );
    _report = _report.copyWith(platforms: updated);
    notifyListeners();
  }

  /// Remove a plataforma no índice [index], se existir.
  void removePlatform(int index) {
    if (index < 0 || index >= _report.platforms.length) return;
    final List<FinancialHistoryPlatformSummaryModel> updated =
        List<FinancialHistoryPlatformSummaryModel>.of(_report.platforms)
          ..removeAt(index);
    _report = _report.copyWith(platforms: updated);
    notifyListeners();
  }

  // ── Persistência (ações assíncronas) ────────────────────────────────────

  /// Carrega um report existente pelo id — usado no modo edição.
  ///
  /// Retorna `true` se o report foi carregado; `false` se não existir.
  Future<bool> load(String id) async {
    _setBusy(true);
    try {
      final FinancialHistoryModel? loaded = await _service.getById(id);
      if (loaded == null) {
        _lastError = 'Passeio não encontrado.';
        return false;
      }
      _report = loaded;
      _lastError = null;
      return true;
    } catch (error) {
      _lastError = 'Erro ao carregar o passeio: $error';
      return false;
    } finally {
      _setBusy(false);
    }
  }

  /// Persiste o report atual via repositório.
  ///
  /// Lança [FinancialHistoryValidationException] caso as validações mínimas falhem.
  Future<void> save() async {
    _validate();
    _setBusy(true);
    debugPrint(
      '[SAVE][controller] validado; enviando ao repositório '
      '(id=${_report.id}, sku=${_report.sku}, isNew=$isNew)',
    );
    try {
      _report = await _service.save(_report);
      _lastError = null;
      debugPrint('[SAVE][controller] concluído → sku=${_report.sku}');
    } catch (error) {
      _lastError = 'Erro ao salvar o passeio: $error';
      debugPrint('[SAVE][controller] FALHOU → $error');
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  /// Exclui o report atual via repositório.
  Future<void> delete() async {
    if (isNew) return; // nada a excluir em um report ainda não salvo.
    _setBusy(true);
    try {
      await _service.delete(_report.id);
      _lastError = null;
    } catch (error) {
      _lastError = 'Erro ao excluir o passeio: $error';
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  // ── Auxiliares ────────────────────────────────────────────────────────────

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  int _nonNegative(int value) => value < 0 ? 0 : value;

  /// Validações mínimas exigidas antes de persistir:
  ///  - `kmOut >= kmIn` quando `kmOut` estiver informado;
  ///  - valores não negativos em km e valores monetários.
  void _validate() {
    if (_report.kmIn < 0) {
      throw const FinancialHistoryValidationException(
        'KM - IN não pode ser negativo.',
      );
    }
    if (_report.kmOut != null && _report.kmOut! < 0) {
      throw const FinancialHistoryValidationException(
        'KM - OUT não pode ser negativo.',
      );
    }
    if (_report.kmOut != null && _report.kmOut! < _report.kmIn) {
      throw const FinancialHistoryValidationException(
        'KM - OUT deve ser maior ou igual a KM - IN.',
      );
    }
    if (_report.cashSpent < 0) {
      throw const FinancialHistoryValidationException(
        'CASH (Gas/Energia) não pode ser negativo.',
      );
    }
  }
}

/// Erro de validação de um [FinancialHistoryModel] antes da persistência.
class FinancialHistoryValidationException implements Exception {
  const FinancialHistoryValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
