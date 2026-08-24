import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:ride_driver_app_1/app/database/app_database.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

import '../domain/financial_history_model.dart';
import '../domain/financial_history_platform_summary_model.dart';
import 'financial_history_repository_interface.dart';

class FinancialHistoryRepository implements FinancialHistoryRepositoryInterface {

  // INICIO getById ###############################################################
  @override
  Future<FinancialHistoryModel?> getById(String id) async {
    final AppDatabase db = await openAppDatabase();
    final FinancialHistoryModel? entity = await _getFinancialHistoryById(
      db,
      id,
    );
    if (entity == null) return null;

    final List<FinancialHistoryPlatformModel> links =
        await _getPlatformsByFinancialHistoryId(db, id);

    final List<FinancialHistoryPlatformSummaryModel> platforms =
        <FinancialHistoryPlatformSummaryModel>[];
    for (final FinancialHistoryPlatformModel link in links) {
      final PlatformModel? platform = await db.platformDao.getPlatformById(
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

  // INICIO CRUD SIMPLES 2 FUNÇÕES ###############################################################
  @override
  Future<FinancialHistoryModel> save(FinancialHistoryModel report) async {
    final AppDatabase db = await openAppDatabase();

    final bool exists = await _getFinancialHistoryById(db, report.id) != null;

    FinancialHistoryModel toSave = report;
    if (!exists && _isPlaceholderSku(report.sku)) {
      toSave = report.copyWith(sku: await _nextSku(db));
    }

    if (exists) {
      await _updateFinancialHistory(db, toSave);
    } else {
      await _insertFinancialHistory(db, toSave);
    }
    debugPrint(
      '[SAVE][repo] ${exists ? 'UPDATE' : 'INSERT'} financial_history → '
      '${toSave.toMap()}',
    );

    await _replacePlatformLinks(db, toSave);

    // Releitura do SQLite: comprova que o registro foi de fato persistido.
    final FinancialHistoryModel? persisted = await _getFinancialHistoryById(
      db,
      toSave.id,
    );
    debugPrint('[SAVE][repo] releitura do banco → ${persisted?.toMap()}');

    return toSave;
  }

  @override
  Future<void> delete(String id) async {
    final AppDatabase db = await openAppDatabase();
    final FinancialHistoryModel? entity = await _getFinancialHistoryById(db, id);
    if (entity == null) return;
    // FKs com ON DELETE CASCADE removem os vínculos de plataforma.
    await _deleteFinancialHistory(db, entity);
  }
  // FIM CRUD SIMPLES 2 FUNÇÕES ###############################################################

  // INICIO PERSISTÊNCIA DIRETA (financial_history + vínculos) ###############################
  Future<List<FinancialHistoryModel>> _getAllFinancialHistories(
    AppDatabase db,
  ) async {
    final rows = await db.database.rawQuery(
      'SELECT * FROM financial_history ORDER BY work_date DESC',
    );
    return rows.map((r) => FinancialHistoryModel.fromMap(r)).toList();
  }

  Future<FinancialHistoryModel?> _getFinancialHistoryById(
    AppDatabase db,
    String id,
  ) async {
    final rows = await db.database.rawQuery(
      'SELECT * FROM financial_history WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return FinancialHistoryModel.fromMap(rows.first);
  }

  Future<void> _insertFinancialHistory(
    AppDatabase db,
    FinancialHistoryModel model,
  ) async {
    await db.database.insert(
      'financial_history',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  Future<void> _updateFinancialHistory(
    AppDatabase db,
    FinancialHistoryModel model,
  ) async {
    await db.database.update(
      'financial_history',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  Future<void> _deleteFinancialHistory(
    AppDatabase db,
    FinancialHistoryModel model,
  ) async {
    await db.database.delete(
      'financial_history',
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<List<FinancialHistoryPlatformModel>>
      _getPlatformsByFinancialHistoryId(AppDatabase db, String financialHistoryId)
  async {
    final rows = await db.database.rawQuery(
      'SELECT * FROM financial_history_platform '
      'WHERE financial_history_id = ?',
      [financialHistoryId],
    );
    return rows.map((r) => FinancialHistoryPlatformModel.fromMap(r)).toList();
  }

  Future<void> _insertFinancialHistoryPlatform(
    AppDatabase db,
    FinancialHistoryPlatformModel model,
  ) async {
    await db.database.insert(
      'financial_history_platform',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }
  // FIM PERSISTÊNCIA DIRETA #################################################################

  // INICIO MÉTODOS AUXILIARES ###############################################################
  Future<void> _replacePlatformLinks(
    AppDatabase db,
    FinancialHistoryModel report,
  ) async {
    final List<FinancialHistoryPlatformModel> existing =
        await _getPlatformsByFinancialHistoryId(db, report.id);
    for (final FinancialHistoryPlatformModel link in existing) {
      await db.database.delete(
        'financial_history_platform',
        where: 'id = ?',
        whereArgs: [link.id],
      );
    }

    for (final FinancialHistoryPlatformSummaryModel platform
        in report.platforms) {
      final String platformId = await _ensurePlatform(db, platform.name);
      await _insertFinancialHistoryPlatform(
        db,
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
    final int count = (await _getAllFinancialHistories(db)).length;
    return 'PASSEIO ${(count + 1).toString().padLeft(3, '0')}';
  }

  bool _isPlaceholderSku(String sku) {
    final String trimmed = sku.trim();
    return trimmed.isEmpty || trimmed == 'PASSEIO —';
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}';
  // FIM MÉTODOS AUXILIARES #################################################################
}
