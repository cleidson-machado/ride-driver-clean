import 'package:flutter/foundation.dart';

import 'domain/tour_in_progress_model.dart';
import 'domain/tour_in_progress_page.dart';
import 'tour_in_progress_service.dart';

export 'tour_in_progress_service.dart' show TourInProgressValidationException;

/// Resultado de [TourInProgressController.finish].
enum FinishOutcome {
  /// Passeio encerrado com sucesso e já persistido.
  success,

  /// O passeio não atendeu às regras de negócio da service (nada persistido).
  validationError,

  /// Ocorreu uma falha inesperada ao tentar encerrar.
  failure,
}

/// Controller (ChangeNotifier) da tela de passeio em curso.
///
/// Centraliza o estado da `TourInProgressView`: o report ativo (em curso) no
/// topo e o histórico recente de finalizados em um ListView infinito (carga
/// paginada). A view observa este notifier (via `AnimatedBuilder` /
/// `ListenableBuilder`) e chama os métodos de ação — ela nunca decide por si
/// qual é a "fonte da verdade".
///
/// A controller **não conhece a view**: apenas expõe estado e ações. Quando um
/// passeio é encerrado com sucesso, a controller guarda o report finalizado em
/// [lastFinishedReport] (e retorna [FinishOutcome.success]); a view observa
/// esse estado e decide navegar para a tela de consolidação.
///
/// A controller conhece apenas a [TourInProgressService] (injeção no
/// construtor). A implementação concreta de infraestrutura (SQLite etc.) é
/// montada num ponto de composição dedicado — nunca nesta camada.
class TourInProgressController extends ChangeNotifier {
  TourInProgressController({required TourInProgressService service})
    : _service = service;

  final TourInProgressService _service;

  // ── Estado exposto à view ────────────────────────────────────────────────

  /// Report ativo ("em curso", `isFinished = false`). `null` quando não há
  /// nenhum passeio aberto.
  TourInProgressModel? _activeReport;
  TourInProgressModel? get activeReport => _activeReport;

  /// Passeios finalizados já carregados, em ordem de criação no banco
  /// (alimenta o ListView infinito).
  final List<TourInProgressModel> _finishedReports = <TourInProgressModel>[];
  List<TourInProgressModel> get finishedReports =>
      List<TourInProgressModel>.unmodifiable(_finishedReports);

  /// `true` se ainda há páginas seguintes de finalizados a carregar.
  bool _hasMoreFinished = false;
  bool get hasMoreFinished => _hasMoreFinished;

  /// Indica se há uma carga adicional de finalizados em andamento
  /// (última página do ListView infinito — não levanta [busy] global).
  bool _loadingMoreFinished = false;
  bool get loadingMoreFinished => _loadingMoreFinished;

  /// Primeira carga (report ativo + 1ª página) concluída com sucesso.
  bool _initialized = false;
  bool get initialized => _initialized;

  /// Indica se há uma operação assíncrona principal em andamento
  /// (primeira carga / encerramento).
  bool _busy = false;
  bool get busy => _busy;

  String? _lastError;
  String? get lastError => _lastError;

  /// Representa o passeio recém-encerrado — sinal único para a view navegar
  /// para a tela de consolidação.
  ///
  /// É limpo após a view consumi-lo via [consumeLastFinishedReport].
  TourInProgressModel? _lastFinishedReport;
  TourInProgressModel? get lastFinishedReport => _lastFinishedReport;

  /// Página (base 0) da próxima consulta de finalizados no ListView infinito.
  int _nextPage = 0;

  // ── Carregamento inicial ─────────────────────────────────────────────────

  /// Carrega o report ativo (em curso) e a primeira página de finalizados.
  /// Retorna `true` em caso de sucesso.
  Future<bool> load() async {
    _setBusy(true);
    try {
      await Future.wait<void>(<Future<void>>[
        _loadActiveReport(),
        _loadFirstFinishedPage(),
      ]);
      _initialized = true;
      _lastError = null;
      return true;
    } catch (error) {
      _lastError = 'Erro ao carregar o passeio em curso: $error';
      debugPrint('[LOAD][controller] FALHOU → $error');
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _loadActiveReport() async {
    _activeReport = await _service.findInProgress();
  }

  Future<void> _loadFirstFinishedPage() async {
    _finishedReports.clear();
    _nextPage = 0;
    final TourInProgressPage page = await _service.listFinished(page: 0);
    _finishedReports.addAll(page.items);
    _hasMoreFinished = page.hasMore;
  }

  /// Recarrega o estado a partir do banco (puxa para atualizar).
  Future<void> refresh() => load();

  // ── ListView infinito (finalizados) ─────────────────────────────────────

  /// Carrega a próxima página de finalizados e a anexa ao histórico.
  ///
  /// Chamado pela view ao atingir o fim do ListView (somente quando
  /// [hasMoreFinished] é `true`). Retorna `true` se carregou mais itens.
  Future<bool> loadMoreFinished() async {
    if (_loadingMoreFinished || !_hasMoreFinished) return false;

    _loadingMoreFinished = true;
    notifyListeners();
    try {
      final TourInProgressPage page = await _service.listFinished(
        page: _nextPage,
      );
      _finishedReports.addAll(page.items);
      _nextPage += 1;
      _hasMoreFinished = page.hasMore;
      _lastError = null;
      return page.items.isNotEmpty;
    } catch (error) {
      _lastError = 'Erro ao carregar mais passeios: $error';
      return false;
    } finally {
      _loadingMoreFinished = false;
      notifyListeners();
    }
  }

  // ── Encerramento ─────────────────────────────────────────────────────────

  /// Encerra o report ativo aplicando as validações de negócio da service.
  ///
  /// [kmOut] e [cashSpent] são os valores de encerramento informados pela view;
  /// [date] é a data do encerramento. A data de referência atual do passeio
  /// em curso é usada como base quando [date] não for fornecida.
  ///
  /// Retorna um [FinishOutcome]:
  ///  - [FinishOutcome.success]: persistido; [lastFinishedReport] fica
  ///    preenchido para a view navegar à consolidação;
  ///  - [FinishOutcome.validationError]: não atendeu às regras do serviço
  ///    (mensagem exposta em [lastError], nada é persistido);
  ///  - [FinishOutcome.failure]: falha inesperada (mensagem em [lastError]).
  Future<FinishOutcome> finish({
    required int kmOut,
    DateTime? date,
    double cashSpent = 0,
  }) async {
    final TourInProgressModel? current = _activeReport;
    if (current == null) {
      _lastError = 'Não há passeio em curso para encerrar.';
      return FinishOutcome.failure;
    }

    _setBusy(true);
    try {
      final TourInProgressModel finished = await _service.finish(
        current: current,
        kmOut: kmOut,
        date: date ?? current.date,
        cashSpent: cashSpent,
      );
      // O passeio não está mais em curso: limpa o card ativo.
      _activeReport = null;
      _lastFinishedReport = finished;
      _lastError = null;
      debugPrint('[FINISH][controller] encerrado com sucesso → ${finished.id}');
      return FinishOutcome.success;
    } on TourInProgressValidationException catch (error) {
      _lastError = error.message;
      debugPrint('[FINISH][controller] validação falhou → $error');
      return FinishOutcome.validationError;
    } catch (error) {
      _lastError = 'Erro ao encerrar o passeio: $error';
      debugPrint('[FINISH][controller] FALHOU → $error');
      return FinishOutcome.failure;
    } finally {
      _setBusy(false);
    }
  }

  /// Consome (e limpa) o sinal de encerramento para a navegação.
  ///
  /// Chamado pela view quando ela já navegou para a tela de consolidação,
  /// evitando repetir a navegação em re-builds posteriores.
  TourInProgressModel? consumeLastFinishedReport() {
    final TourInProgressModel? signal = _lastFinishedReport;
    _lastFinishedReport = null;
    return signal;
  }

  // ── Auxiliares ────────────────────────────────────────────────────────────

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
