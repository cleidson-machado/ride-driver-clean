import 'package:flutter/foundation.dart';
import 'package:ride_driver_app_1/features/financial_history/data/financial_history_repository.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_summary_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

class FinancialHistoryService {
  const FinancialHistoryService({
    required FinancialHistoryRepository repository,
  }) : _repository = repository;

  final FinancialHistoryRepository _repository;

  // INICIO getById ###############################################################
  Future<FinancialHistoryModel?> getById(String id) async {
    final FinancialHistoryModel? entity = await _repository.getById(id);
    if (entity == null) return null;

    final List<FinancialHistoryPlatformModel> links = await _repository
        .getPlatformLinksByFinancialHistoryId(id);

    final List<FinancialHistoryPlatformSummaryModel> platforms =
        <FinancialHistoryPlatformSummaryModel>[];
    for (final FinancialHistoryPlatformModel link in links) {
      final PlatformModel? platform = await _repository.getPlatformById(
        link.platformId,
      );
      platforms.add(
        FinancialHistoryPlatformSummaryModel(
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
  Future<FinancialHistoryModel> save(FinancialHistoryModel report) async {
    final bool exists = await _repository.getById(report.id) != null;

    FinancialHistoryModel toSave = report;
    if (!exists && _isPlaceholderSku(report.sku)) {
      toSave = report.copyWith(sku: await _nextSku());
    }

    if (exists) {
      await _repository.update(toSave);
    } else {
      await _repository.insert(toSave);
    }
    debugPrint(
      '[SAVE][service] ${exists ? 'UPDATE' : 'INSERT'} financial_history -> '
      '${toSave.toMap()}',
    );

    await _replacePlatformLinks(toSave);

    // Releitura do SQLite: comprova que o registro foi de fato persistido.
    final FinancialHistoryModel? persisted = await _repository.getById(
      toSave.id,
    );
    debugPrint('[SAVE][service] releitura do banco -> ${persisted?.toMap()}');

    return toSave;
  }

  Future<void> delete(String id) async {
    final FinancialHistoryModel? entity = await _repository.getById(id);
    if (entity == null) return;
    // FKs com ON DELETE CASCADE removem os vínculos de plataforma.
    await _repository.deleteById(entity.id);
  }
  // FIM ORQUESTRAÇÃO DE GRAVAÇÃO ################################################

  Future<void> _replacePlatformLinks(FinancialHistoryModel report) async {
    await _repository.deletePlatformLinksByFinancialHistoryId(report.id);

    for (final FinancialHistoryPlatformSummaryModel platform
        in report.platforms) {
      final String platformId = await _ensurePlatform(platform.name);
      await _repository.insertPlatformLink(
        FinancialHistoryPlatformModel(
          id: _newId(),
          financialHistoryId: report.id,
          platformId: platformId,
          dailyEarnings: platform.totalValue,
          dailyTripCount: platform.totalRides,
        ),
      );
      debugPrint(
        '[SAVE][service] vínculo plataforma -> ${platform.name}: '
        '€${platform.totalValue} / ${platform.totalRides} corridas',
      );
    }
  }

  Future<String> _ensurePlatform(String name) async {
    final String normalized = name.trim().toUpperCase();
    final List<PlatformModel> all = await _repository.getAllPlatforms();
    for (final PlatformModel platform in all) {
      if (platform.name.trim().toUpperCase() == normalized) {
        return platform.id;
      }
    }
    final PlatformModel created = PlatformModel(id: _newId(), name: normalized);
    await _repository.insertPlatform(created);
    return created.id;
  }

  /// Gera o próximo SKU legível ("PASSEIO 001", "PASSEIO 002", ...).
  Future<String> _nextSku() async {
    final int count = (await _repository.getAll()).length;
    return 'PASSEIO ${(count + 1).toString().padLeft(3, '0')}';
  }

  bool _isPlaceholderSku(String sku) {
    final String trimmed = sku.trim();
    return trimmed.isEmpty || trimmed == 'PASSEIO —';
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}';
}
