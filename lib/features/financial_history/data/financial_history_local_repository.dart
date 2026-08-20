import 'package:flutter/foundation.dart';
import 'package:ride_driver_app_1/app/database/app_database.dart';
import 'package:ride_driver_app_1/features/financial_history/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

import '../domain/financial_history.dart';
import '../domain/financial_history_platform.dart';
import 'financial_history_repository.dart';

/// Implementação local (SQLite/sqflite) de [FinancialHistoryRepository].
///
/// A entidade [FinancialHistory] já sabe se mapear para a tabela
/// `financial_history`; este repositório cuida do que é relacional:
/// resolver os vínculos de plataforma (`financial_history_platform` +
/// catálogo `platform`) e gerar o SKU sequencial. A view e o controller
/// nunca enxergam DAOs nem SQL — apenas esta camada.
class FinancialHistoryLocalRepository implements FinancialHistoryRepository {
  @override
  Future<FinancialHistory?> getById(String id) async {
    final AppDatabase db = await openAppDatabase();
    final FinancialHistory? entity = await db.financialHistoryDao
        .getFinancialHistoryById(id);
    if (entity == null) return null;

    final List<FinancialHistoryPlatformModel> links = await db
        .financialHistoryPlatformDao
        .getPlatformsByFinancialHistoryId(id);

    final List<FinancialHistoryPlatform> platforms =
        <FinancialHistoryPlatform>[];
    for (final FinancialHistoryPlatformModel link in links) {
      final PlatformModel? platform = await db.platformDao.getPlatformById(
        link.platformId,
      );
      platforms.add(
        FinancialHistoryPlatform(
          name: platform?.name ?? 'DESCONHECIDA',
          totalValue: link.dailyEarnings,
          totalRides: link.dailyTripCount,
        ),
      );
    }

    return entity.copyWith(platforms: platforms);
  }

  @override
  Future<FinancialHistory> save(FinancialHistory report) async {
    final AppDatabase db = await openAppDatabase();

    final bool exists =
        await db.financialHistoryDao.getFinancialHistoryById(report.id) != null;

    FinancialHistory toSave = report;
    if (!exists && _isPlaceholderSku(report.sku)) {
      toSave = report.copyWith(sku: await _nextSku(db));
    }

    if (exists) {
      await db.financialHistoryDao.updateFinancialHistory(toSave);
    } else {
      await db.financialHistoryDao.insertFinancialHistory(toSave);
    }
    debugPrint(
      '[SAVE][repo] ${exists ? 'UPDATE' : 'INSERT'} financial_history → '
      '${toSave.toMap()}',
    );

    await _replacePlatformLinks(db, toSave);

    // Releitura do SQLite: comprova que o registro foi de fato persistido.
    final FinancialHistory? persisted = await db.financialHistoryDao
        .getFinancialHistoryById(toSave.id);
    debugPrint('[SAVE][repo] releitura do banco → ${persisted?.toMap()}');

    return toSave;
  }

  @override
  Future<void> delete(String id) async {
    final AppDatabase db = await openAppDatabase();
    final FinancialHistory? entity = await db.financialHistoryDao
        .getFinancialHistoryById(id);
    if (entity == null) return;
    // FKs com ON DELETE CASCADE removem os vínculos de plataforma.
    await db.financialHistoryDao.deleteFinancialHistory(entity);
  }

  // ── Auxiliares ─────────────────────────────────────────────────────────

  /// Substitui os vínculos `financial_history_platform` do report pelos
  /// atuais, garantindo cada plataforma no catálogo (upsert por nome).
  Future<void> _replacePlatformLinks(
    AppDatabase db,
    FinancialHistory report,
  ) async {
    final List<FinancialHistoryPlatformModel> existing = await db
        .financialHistoryPlatformDao
        .getPlatformsByFinancialHistoryId(report.id);
    for (final FinancialHistoryPlatformModel link in existing) {
      await db.financialHistoryPlatformDao.deleteFinancialHistoryPlatform(link);
    }

    for (final FinancialHistoryPlatform platform in report.platforms) {
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
      debugPrint(
        '[SAVE][repo] vínculo plataforma → ${platform.name}: '
        '€${platform.totalValue} / ${platform.totalRides} corridas',
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
