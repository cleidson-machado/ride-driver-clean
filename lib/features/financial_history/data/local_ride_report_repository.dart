import 'package:ride_driver_app_1/app/database/app_database.dart';
import 'package:ride_driver_app_1/features/financial_history/financial_history_model.dart';
import 'package:ride_driver_app_1/features/financial_history/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

import '../domain/ride_report.dart';
import '../domain/ride_report_platform.dart';
import 'ride_report_repository.dart';

/// Implementação local (SQLite/sqflite) de [RideReportRepository].
///
/// Faz o mapeamento entre o modelo de domínio [RideReport] e as entidades
/// de persistência (`financial_history`, `platform` e
/// `financial_history_platform`). A view e o controller nunca enxergam
/// DAOs nem SQL — apenas esta camada.
///
/// Convenções de mapeamento (colunas NOT NULL no schema atual):
///  - `km_end == 0` e `km_odometer == 0` representam "não informado"
///    (kmOut/hodo2Number nulos no domínio).
class LocalRideReportRepository implements RideReportRepository {
  @override
  Future<RideReport?> getById(String id) async {
    final AppDatabase db = await openAppDatabase();
    final FinancialHistoryModel? entity = await db.financialHistoryDao
        .getFinancialHistoryById(id);
    if (entity == null) return null;

    final List<FinancialHistoryPlatformModel> links = await db
        .financialHistoryPlatformDao
        .getPlatformsByFinancialHistoryId(id);

    final List<RideReportPlatform> platforms = <RideReportPlatform>[];
    for (final FinancialHistoryPlatformModel link in links) {
      final PlatformModel? platform = await db.platformDao.getPlatformById(
        link.platformId,
      );
      platforms.add(
        RideReportPlatform(
          name: platform?.name ?? 'DESCONHECIDA',
          totalValue: link.dailyEarnings,
          totalRides: link.dailyTripCount,
        ),
      );
    }

    return RideReport(
      id: entity.id,
      sku: entity.tripNumber,
      date: entity.date,
      kmIn: entity.kmStart,
      kmOut: entity.kmEnd == 0 ? null : entity.kmEnd,
      cashSpent: entity.fuelCost,
      hodo2IsZero: entity.hodo2IsZero,
      hodo2Number: entity.kmOdometer == 0 ? null : entity.kmOdometer,
      hasImages: entity.hasImages,
      isFinished: entity.isFinished,
      notes: entity.notes,
      platforms: platforms,
    );
  }

  @override
  Future<RideReport> save(RideReport report) async {
    final AppDatabase db = await openAppDatabase();

    final bool exists =
        await db.financialHistoryDao.getFinancialHistoryById(report.id) != null;

    RideReport toSave = report;
    if (!exists && _isPlaceholderSku(report.sku)) {
      toSave = report.copyWith(sku: await _nextSku(db));
    }

    final FinancialHistoryModel entity = FinancialHistoryModel(
      id: toSave.id,
      dateMillis: toSave.date.millisecondsSinceEpoch,
      tripNumber: toSave.sku,
      fuelCost: toSave.cashSpent,
      kmStart: toSave.kmIn,
      kmEnd: toSave.kmOut ?? 0,
      kmOdometer: toSave.hodo2Number ?? 0,
      notes: toSave.notes,
      hodo2IsZero: toSave.hodo2IsZero,
      hasImages: toSave.hasImages,
      isFinished: toSave.isFinished,
    );

    if (exists) {
      await db.financialHistoryDao.updateFinancialHistory(entity);
    } else {
      await db.financialHistoryDao.insertFinancialHistory(entity);
    }

    await _replacePlatformLinks(db, toSave);

    return toSave;
  }

  @override
  Future<void> delete(String id) async {
    final AppDatabase db = await openAppDatabase();
    final FinancialHistoryModel? entity = await db.financialHistoryDao
        .getFinancialHistoryById(id);
    if (entity == null) return;
    // FKs com ON DELETE CASCADE removem os vínculos de plataforma.
    await db.financialHistoryDao.deleteFinancialHistory(entity);
  }

  // ── Auxiliares ─────────────────────────────────────────────────────────

  /// Substitui os vínculos `financial_history_platform` do report pelos
  /// atuais, garantindo cada plataforma no catálogo (upsert por nome).
  Future<void> _replacePlatformLinks(AppDatabase db, RideReport report) async {
    final List<FinancialHistoryPlatformModel> existing = await db
        .financialHistoryPlatformDao
        .getPlatformsByFinancialHistoryId(report.id);
    for (final FinancialHistoryPlatformModel link in existing) {
      await db.financialHistoryPlatformDao.deleteFinancialHistoryPlatform(link);
    }

    for (final RideReportPlatform platform in report.platforms) {
      final String platformId = await _ensurePlatform(db, platform.name);
      await db.financialHistoryPlatformDao.insertFinancialHistoryPlatform(
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

  /// Retorna o id da plataforma com [name] (case-insensitive),
  /// criando-a no catálogo caso ainda não exista.
  Future<String> _ensurePlatform(AppDatabase db, String name) async {
    final String normalized = name.trim().toUpperCase();
    final List<PlatformModel> all = await db.platformDao.getAllPlatforms();
    for (final PlatformModel platform in all) {
      if (platform.name.trim().toUpperCase() == normalized) {
        return platform.id;
      }
    }
    final PlatformModel created = PlatformModel(id: _newId(), name: normalized);
    await db.platformDao.insertPlatform(created);
    return created.id;
  }

  /// Gera o próximo SKU legível ("PASSEIO 001", "PASSEIO 002", ...).
  Future<String> _nextSku(AppDatabase db) async {
    final int count =
        (await db.financialHistoryDao.getAllFinancialHistories()).length;
    return 'PASSEIO ${(count + 1).toString().padLeft(3, '0')}';
  }

  bool _isPlaceholderSku(String sku) {
    final String trimmed = sku.trim();
    return trimmed.isEmpty || trimmed == 'PASSEIO —';
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}';
}
