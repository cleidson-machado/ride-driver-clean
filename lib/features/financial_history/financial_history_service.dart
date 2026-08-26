import 'package:flutter/foundation.dart';
import 'package:ride_driver_app_1/features/financial_history/data/financial_history_repository_interface.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';

import 'package:ride_driver_app_1/features/financial_history/domain/platform_model.dart';

/// Regras de negócio da feature de histórico financeiro.
///
/// Depende apenas do contrato [FinancialHistoryRepositoryInterface] abstraído na camada
/// de domínio — nunca de uma implementação concreta. Isso permite injetar
/// hoje uma implementação SQLite e, futuramente, uma REST, sem alterar esta
/// classe (princípio da inversão de dependência).
class FinancialHistoryService {
  const FinancialHistoryService({
    required FinancialHistoryRepositoryInterface repository,
  }) : _storage = repository;

  final FinancialHistoryRepositoryInterface _storage;

  /// Nomes das plataformas base criadas automaticamente para todo report
  /// novo/vazio: UBER e BOLT (apps) + PARTICULAR (corridas avulsas e
  /// pagamentos diretos em dinheiro, independentes de plataforma).
  static const List<String> basePlatformNames = [
    'UBER',
    'BOLT',
    'PARTICULAR',
  ];

  // INICIO getById ###############################################################
  Future<FinancialHistoryModel?> getById(String id) async {
    final FinancialHistoryModel? entity = await _storage.getById(id);
    if (entity == null) return null;

    final List<FinancialHistoryPlatformModel> links = await _storage
        .getPlatformLinksByFinancialHistoryId(id);

    final List<FinancialHistoryPlatformModel> platforms =
        <FinancialHistoryPlatformModel>[];
    for (final FinancialHistoryPlatformModel link in links) {
      final PlatformModel? platform = await _storage.getPlatformById(
        link.platformId,
      );
      platforms.add(
        link.copyWith(name: platform?.name ?? 'DESCONHECIDA'),
      );
    }

    return entity.copyWith(platforms: platforms);
  }
  // FIM getById ##################################################################

  // INICIO ORQUESTRAÇÃO DE GRAVAÇÃO #############################################

  /// Persiste [report], aplicando as regras de negócio mínimas antes de
  /// gravar. Lança [FinancialHistoryValidationException] se o report não
  /// atender às regras.
  Future<FinancialHistoryModel> save(FinancialHistoryModel report) async {
    _validate(report);

    final bool exists = await _storage.getById(report.id) != null;

    FinancialHistoryModel toSave = report;
    if (!exists && _isPlaceholderSku(report.sku)) {
      toSave = report.copyWith(sku: await _nextSku());
    }

    if (exists) {
      await _storage.update(toSave);
    } else {
      await _storage.insert(toSave);
    }
    debugPrint(
      '[SAVE][service] ${exists ? 'UPDATE' : 'INSERT'} '
      '${toSave.id} (SKU ${toSave.sku})',
    );

    await _replacePlatformLinks(toSave);

    return toSave;
  }

  Future<void> delete(String id) async {
    final FinancialHistoryModel? entity = await _storage.getById(id);
    if (entity == null) return;
    // FKs com ON DELETE CASCADE removem os vínculos de plataforma.
    await _storage.deleteById(entity.id);
  }
  // FIM ORQUESTRAÇÃO DE GRAVAÇÃO ################################################

  Future<void> _replacePlatformLinks(FinancialHistoryModel report) async {
    await _storage.deletePlatformLinksByFinancialHistoryId(report.id);

    for (final FinancialHistoryPlatformModel platform in report.platforms) {
      final String platformId = await _ensurePlatform(platform.name);
      await _storage.insertPlatformLink(
        // Reusa o id do vínculo em memória para manter a consistência entre o
        // estado exibido e o banco após o save.
        FinancialHistoryPlatformModel(
          id: platform.id,
          financialHistoryId: report.id,
          platformId: platformId,
          dailyEarnings: platform.dailyEarnings,
          dailyTripCount: platform.dailyTripCount,
        ),
      );
    }
  }

  Future<String> _ensurePlatform(String name) async {
    final PlatformModel resolved = await resolvePlatform(name);
    return resolved.id;
  }

  /// Resolve um nome de plataforma para o catálogo: retorna a existente cujo
  /// nome bate (case-insensitive, ignorando espaços) ou cria uma nova no
  /// catálogo (`platform`) e a retorna. O catálogo nunca bloqueia quando chega
  /// ao fim — plataformas novas são persistidas e reutilizadas depois.
  Future<PlatformModel> resolvePlatform(String name) async {
    final String normalized = name.trim().toUpperCase();
    final List<PlatformModel> all = await _storage.getAllPlatforms();
    for (final PlatformModel platform in all) {
      if (platform.name.trim().toUpperCase() == normalized) {
        return platform;
      }
    }
    final PlatformModel created = PlatformModel(id: _newId(), name: normalized);
    await _storage.insertPlatform(created);
    return created;
  }

  // INICIO PERSISTÊNCIA DIRETA DE VÍNCULO (financial_history_platform) ########

  /// Catálogo de plataformas disponíveis (tabela `platform`).
  Future<List<PlatformModel>> getAllPlatforms() => _storage.getAllPlatforms();

  /// Garante que as plataformas base ([basePlatformNames]) existam no
  /// catálogo, criando as ausentes (uma única vez). Retorna a lista base.
  Future<List<PlatformModel>> ensureBasePlatforms() async {
    final List<PlatformModel> existing = await _storage.getAllPlatforms();
    final Set<String> existingNames = existing
        .map((PlatformModel p) => p.name.trim().toUpperCase())
        .toSet();

    final List<PlatformModel> bases = <PlatformModel>[];
    for (final String name in basePlatformNames) {
      final String normalized = name.trim().toUpperCase();
      final bool present = existingNames.contains(normalized);
      final PlatformModel platform =
          present
              ? existing.firstWhere(
                  (PlatformModel p) =>
                      p.name.trim().toUpperCase() == normalized,
                )
              : PlatformModel(
                  id: _basePlatformId(normalized),
                  name: normalized,
                );
      if (!present) {
        await _storage.insertPlatform(platform);
      }
      bases.add(platform);
    }
    return bases;
  }

  /// Id determinístico das plataformas base ("platform_uber", ...).
  String _basePlatformId(String normalizedName) =>
      'platform_${normalizedName.toLowerCase()}';

  /// Cria o vínculo de uma [platformId] existente ao report persistido.
  Future<void> addPlatformLink({
    required String financialHistoryId,
    required String platformId,
    required double dailyEarnings,
    required int dailyTripCount,
    String? id,
  }) {
    return _storage.insertPlatformLink(
      FinancialHistoryPlatformModel(
        id: id ?? _newId(),
        financialHistoryId: financialHistoryId,
        platformId: platformId,
        dailyEarnings: dailyEarnings,
        dailyTripCount: dailyTripCount,
      ),
    );
  }

  /// Atualiza os valores (earnings/trip count) de um vínculo já persistido.
  Future<void> updatePlatformLink({
    required String id,
    required double dailyEarnings,
    required int dailyTripCount,
  }) {
    return _storage.updatePlatformLink(
      FinancialHistoryPlatformModel(
        id: id,
        financialHistoryId: '',
        platformId: '',
        dailyEarnings: dailyEarnings,
        dailyTripCount: dailyTripCount,
      ),
    );
  }

  /// Remove o vínculo persistido.
  Future<void> deletePlatformLink(String id) {
    return _storage.deletePlatformLink(id);
  }
  // FIM PERSISTÊNCIA DIRETA DE VÍNCULO ########################################

  /// Gera o próximo SKU legível ("PASSEIO 001", "PASSEIO 002", ...).
  Future<String> _nextSku() async {
    final int count = (await _storage.getAll()).length;
    return 'PASSEIO ${(count + 1).toString().padLeft(3, '0')}';
  }

  bool _isPlaceholderSku(String sku) {
    final String trimmed = sku.trim();
    return trimmed.isEmpty || trimmed == 'PASSEIO —';
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}';

  /// Regras mínimas exigidas antes de persistir um report:
  ///  - `kmOut >= kmIn` quando `kmOut` estiver informado;
  ///  - valores não negativos em km e valores monetários.
  void _validate(FinancialHistoryModel report) {
    if (report.kmIn < 0) {
      throw const FinancialHistoryValidationException(
        'KM - IN não pode ser negativo.',
      );
    }
    if (report.kmOut != null && report.kmOut! < 0) {
      throw const FinancialHistoryValidationException(
        'KM - OUT não pode ser negativo.',
      );
    }
    if (report.kmOut != null && report.kmOut! < report.kmIn) {
      throw const FinancialHistoryValidationException(
        'KM - OUT deve ser maior ou igual a KM - IN.',
      );
    }
    if (report.cashSpent < 0) {
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
