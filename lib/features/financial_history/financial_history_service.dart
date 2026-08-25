import 'package:flutter/foundation.dart';
import 'package:ride_driver_app_1/features/financial_history/data/financial_history_repository_interface.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_summary_dto.dart';

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

  // INICIO getById ###############################################################
  Future<FinancialHistoryModel?> getById(String id) async {
    final FinancialHistoryModel? entity = await _storage.getById(id);
    if (entity == null) return null;

    final List<FinancialHistoryPlatformModel> links = await _storage
        .getPlatformLinksByFinancialHistoryId(id);

    final List<FinancialHistoryPlatformSummaryDTO> platforms =
        <FinancialHistoryPlatformSummaryDTO>[];
    for (final FinancialHistoryPlatformModel link in links) {
      final PlatformModel? platform = await _storage.getPlatformById(
        link.platformId,
      );
      platforms.add(
        FinancialHistoryPlatformSummaryDTO(
          name: platform?.name ?? 'DESCONHECIDA',
          totalValue: link.dailyEarnings,
          totalRides: link.dailyTripCount,
        ),
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

    for (final FinancialHistoryPlatformSummaryDTO platform
        in report.platforms) {
      final String platformId = await _ensurePlatform(platform.name);
      await _storage.insertPlatformLink(
        FinancialHistoryPlatformModel(
          id: _newId(),
          financialHistoryId: report.id,
          platformId: platformId,
          dailyEarnings: platform.totalValue,
          dailyTripCount: platform.totalRides,
        ),
      );
    }
  }

  Future<String> _ensurePlatform(String name) async {
    final String normalized = name.trim().toUpperCase();
    final List<PlatformModel> all = await _storage.getAllPlatforms();
    for (final PlatformModel platform in all) {
      if (platform.name.trim().toUpperCase() == normalized) {
        return platform.id;
      }
    }
    final PlatformModel created = PlatformModel(id: _newId(), name: normalized);
    await _storage.insertPlatform(created);
    return created.id;
  }

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
