import 'package:flutter/foundation.dart';

import 'domain/financial_history_model.dart';
import 'domain/financial_history_platform_model.dart';
import 'domain/platform_model.dart';
import 'financial_history_service.dart';

export 'financial_history_service.dart' show FinancialHistoryValidationException;

/// Controller (ChangeNotifier) da tela de cadastro/edição de passeio.
///
/// Centraliza o estado da `FinancialHistoryView` que hoje vive solto no
/// `State` do widget. A view observa este notifier (via `AnimatedBuilder` /
/// `ListenableBuilder`) e chama os métodos de ação — ela nunca decide por si
/// qual é a "fonte da verdade". A view só conhece esta controller: nunca a
/// service, a interface de persistência ou a implementação concreta.
///
/// Padrão adotado: **ChangeNotifier puro da Flutter**, injetado na view,
/// alinhado ao restante do projeto (que não usa packages de estado/DI).
///
/// To-do central desta etapa:
///  - `load()`, `save()` e `delete()` delegam para [FinancialHistoryService];
///  - todos os setters atualizam [_report] e notificam listeners;
///  - as validações de negócio antes de salvar ficam na [FinancialHistoryService].
class FinancialHistoryController extends ChangeNotifier {
  FinancialHistoryController({
    required FinancialHistoryService service,
    FinancialHistoryModel? initialReport,
  }) : _service = service,
       _report = initialReport ?? _buildBlankReport();

  /// A controller conhece apenas a [FinancialHistoryService] (injeção no
  /// construtor). A implementação concreta de infraestrutura (SQLite etc.) é
  /// montada num ponto de composição dedicado — nunca nesta camada.
  final FinancialHistoryService _service;
  FinancialHistoryModel _report;

  /// Indica se o report já existe no banco (false em cadastro). Plataformas de
  /// um report não persistido só serão gravadas no `save()` (FK exige o pai).
  bool _persisted = false;

  // ── Estado exposto à view ────────────────────────────────────────────────

  FinancialHistoryModel get report => _report;

  /// Indica se há uma operação assíncrona (load/save/delete) em andamento.
  bool _busy = false;
  bool get busy => _busy;

  String? _lastError;
  String? get lastError => _lastError;

  /// Se o report ainda não foi persistido (modo cadastro).
  bool get isNew => _report.id.isEmpty;

  /// Nº máximo de cartões de plataforma exibidos por report no carrossel.
  static const int maxPlatforms = 10;

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

  /// `true` se já existe um vínculo no report com o mesmo [name]
  /// (case-insensitive, ignorando espaços), excetuando [excludeLinkId].
  bool _hasPlatformNamed(String name, {String? excludeLinkId}) {
    final String normalized = name.trim().toUpperCase();
    return _report.platforms.any(
      (FinancialHistoryPlatformModel p) =>
          p.id != excludeLinkId && p.name.trim().toUpperCase() == normalized,
    );
  }

  /// Adiciona um vínculo de plataforma ao report a partir do [name] livre
  /// (nunca bloqueia quando o catálogo está esgotado — a plataforma é criada
  /// no catálogo caso não exista). Respeita o limite de [maxPlatforms] e não
  /// duplica a mesma plataforma (nome case-insensitive) no report.
  Future<AddPlatformOutcome> addPlatform({
    required String name,
    required double dailyEarnings,
    required int dailyTripCount,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return AddPlatformOutcome.emptyName;
    if (_report.platforms.length >= maxPlatforms) {
      return AddPlatformOutcome.maxReached;
    }
    if (_hasPlatformNamed(trimmed)) return AddPlatformOutcome.duplicate;

    // Resolve/cria a plataforma no catálogo (tabela `platform`).
    final PlatformModel catalog =
        await _service.resolvePlatform(trimmed);
    final FinancialHistoryPlatformModel link = FinancialHistoryPlatformModel(
      id: _newId(),
      financialHistoryId: _report.id,
      platformId: catalog.id,
      name: catalog.name,
      dailyEarnings: dailyEarnings < 0 ? 0 : dailyEarnings,
      dailyTripCount: dailyTripCount < 0 ? 0 : dailyTripCount,
    );
    _report = _report.copyWith(
      platforms: <FinancialHistoryPlatformModel>[..._report.platforms, link],
    );
    notifyListeners();
    if (_persisted) {
      await _service.addPlatformLink(
        id: link.id,
        financialHistoryId: link.financialHistoryId,
        platformId: link.platformId,
        dailyEarnings: link.dailyEarnings,
        dailyTripCount: link.dailyTripCount,
      );
    }
    return AddPlatformOutcome.success;
  }

  /// Atualiza nome e valores de um vínculo (identificado pelo [linkId]) e
  /// persiste imediatamente quando o report já está no banco. Não duplica a
  /// mesma plataforma (nome case-insensitive) no report.
  Future<UpdatePlatformOutcome> updatePlatform(
    String linkId, {
    required String name,
    required double dailyEarnings,
    required int dailyTripCount,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return UpdatePlatformOutcome.emptyName;

    final int index = _report.platforms.indexWhere(
      (FinancialHistoryPlatformModel p) => p.id == linkId,
    );
    if (index < 0) return UpdatePlatformOutcome.notFound;
    if (_hasPlatformNamed(trimmed, excludeLinkId: linkId)) {
      return UpdatePlatformOutcome.duplicate;
    }

    final List<FinancialHistoryPlatformModel> updated =
        List<FinancialHistoryPlatformModel>.of(_report.platforms);
    updated[index] = updated[index].copyWith(
      name: trimmed,
      dailyEarnings: dailyEarnings < 0 ? 0 : dailyEarnings,
      dailyTripCount: dailyTripCount < 0 ? 0 : dailyTripCount,
    );
    _report = _report.copyWith(platforms: updated);
    notifyListeners();

    if (_persisted) {
      await _service.updatePlatformLink(
        id: linkId,
        dailyEarnings: dailyEarnings < 0 ? 0 : dailyEarnings,
        dailyTripCount: dailyTripCount < 0 ? 0 : dailyTripCount,
      );
      // O novo nome é reconciliado no catálogo no próximo `save()` via
      // `_replacePlatformLinks` (resolveOrCreate).
    }
    return UpdatePlatformOutcome.success;
  }

  /// Remove a plataforma do report, com escopo explícito de remoção:
  ///
  ///  - `fromCatalog == false`: apenas desvincula do report atual (mantém a
  ///    plataforma ativa no catálogo, reaparecendo em novos reports);
  ///  - `fromCatalog == true`: desvincula do report **e** faz soft delete no
  ///    catálogo (`is_active = 0`), deixando de ser oferecida em novos reports.
  ///    Reports antigos que a referenciam permanecem intactos (FK preservada).
  Future<RemovePlatformOutcome> removePlatform(
    String linkId, {
    required bool fromCatalog,
  }) async {
    final int index = _report.platforms.indexWhere(
      (FinancialHistoryPlatformModel p) => p.id == linkId,
    );
    if (index < 0) return RemovePlatformOutcome.notFound;

    final FinancialHistoryPlatformModel link = _report.platforms[index];
    final List<FinancialHistoryPlatformModel> updated =
        List<FinancialHistoryPlatformModel>.of(_report.platforms)
          ..removeAt(index);
    _report = _report.copyWith(platforms: updated);
    notifyListeners();

    if (_persisted) {
      await _service.deletePlatformLink(linkId);
    }

    if (fromCatalog) {
      await _service.deactivatePlatform(link.platformId);
      return RemovePlatformOutcome.removedFromReportAndCatalog;
    }
    return RemovePlatformOutcome.removedFromReport;
  }

  /// Plataformas do catálogo (`platform`) ainda não vinculadas ao report atual.
  Future<List<PlatformModel>> getAvailablePlatforms() async {
    final List<PlatformModel> all = await _service.getAllPlatforms();
    final Set<String> linked = _report.platforms
        .map((FinancialHistoryPlatformModel p) => p.platformId)
        .toSet();
    return all
        .where(
          (PlatformModel platform) =>
              platform.isActive && !linked.contains(platform.id),
        )
        .toList();
  }

  /// Garante que um report vazio receba os vínculos de plataforma zerados.
  ///
  /// Preenche o report novo com **todas** as plataformas ativas do catálogo
  /// (as 3 base + qualquer uma já criada em reports anteriores), zeradas, na
  /// ordem de criação no banco, respeitando o limite de exibição de
  /// [maxPlatforms]. Requisito: ao abrir a view, as plataformas já criadas no
  /// banco reaparecem como cards de valores zerados. Se o report já tiver
  /// qualquer vínculo ou não existir, não duplica. Para reports já
  /// persistidos, grava imediata; para novos (cadastro), no `save()`.
  Future<void> ensureDefaultPlatforms() async {
    if (_report.platforms.isNotEmpty) return;

    await _service.ensureBasePlatforms();
    final List<PlatformModel> all = await _service.getAllPlatforms();
    final List<PlatformModel> targets = all
        .where((PlatformModel platform) => platform.isActive)
        .take(maxPlatforms)
        .toList();
    final List<FinancialHistoryPlatformModel> defaults = targets
        .map(
          (PlatformModel platform) => FinancialHistoryPlatformModel(
            id: '${_report.id}_default_${platform.id}',
            financialHistoryId: _report.id,
            platformId: platform.id,
            name: platform.name,
            dailyEarnings: 0,
            dailyTripCount: 0,
          ),
        )
        .toList();

    _report = _report.copyWith(platforms: defaults);
    notifyListeners();

    if (_persisted) {
      for (final FinancialHistoryPlatformModel link in defaults) {
        await _service.addPlatformLink(
          id: link.id,
          financialHistoryId: link.financialHistoryId,
          platformId: link.platformId,
          dailyEarnings: link.dailyEarnings,
          dailyTripCount: link.dailyTripCount,
        );
      }
    }
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
      _persisted = true;
      _lastError = null;
      await ensureDefaultPlatforms();
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
  /// Lança [FinancialHistoryValidationException] (validações de negócio na
  /// service) caso o report não atenda às regras mínimas.
  Future<void> save() async {
    _setBusy(true);
    debugPrint(
      '[SAVE][controller] validado; enviando ao repositório '
      '(id=${_report.id}, sku=${_report.sku}, isNew=$isNew)',
    );
    try {
      _report = await _service.save(_report);
      _persisted = true;
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
      _persisted = false;
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
}

/// Resultado de [FinancialHistoryController.addPlatform].
enum AddPlatformOutcome {
  /// Plataforma vinculada com sucesso.
  success,

  /// Nome vazio informado.
  emptyName,

  /// A mesma plataforma (nome case-insensitive) já está vinculada ao report.
  duplicate,

  /// O report já atingiu o limite de [FinancialHistoryController.maxPlatforms].
  maxReached,
}

/// Resultado de [FinancialHistoryController.updatePlatform].
enum UpdatePlatformOutcome {
  /// Vínculo atualizado com sucesso.
  success,

  /// Nome vazio informado.
  emptyName,

  /// Vínculo não encontrado no report.
  notFound,

  /// A mesma plataforma (nome case-insensitive) já está vinculada ao report.
  duplicate,
}

/// Resultado de [FinancialHistoryController.removePlatform].
enum RemovePlatformOutcome {
  /// Apenas o vínculo foi removido do report (catálogo permanece ativo).
  removedFromReport,

  /// O vínculo foi removido e a plataforma foi inativada no catálogo.
  removedFromReportAndCatalog,

  /// Vínculo não encontrado no report.
  notFound,
}
