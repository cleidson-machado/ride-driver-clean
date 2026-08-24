import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:ride_driver_app_1/app/database/app_database.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

import '../domain/financial_history_model.dart';

class FinancialHistoryRepository {
  // INICIO PERSISTÊNCIA DIRETA (financial_history + vínculos) ###############################
  Future<List<FinancialHistoryModel>> getAll() async {
    final AppDatabase db = await openAppDatabase();
    final rows = await db.database.rawQuery(
      'SELECT * FROM financial_history ORDER BY work_date DESC',
    );
    return rows.map((r) => FinancialHistoryModel.fromMap(r)).toList();
  }

  Future<FinancialHistoryModel?> getById(String id) async {
    final AppDatabase db = await openAppDatabase();
    final rows = await db.database.rawQuery(
      'SELECT * FROM financial_history WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return FinancialHistoryModel.fromMap(rows.first);
  }

  Future<void> insert(FinancialHistoryModel model) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.insert(
      'financial_history',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  Future<void> update(FinancialHistoryModel model) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.update(
      'financial_history',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  Future<void> deleteById(String id) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.delete(
      'financial_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<FinancialHistoryPlatformModel>>
  getPlatformLinksByFinancialHistoryId(String financialHistoryId) async {
    final AppDatabase db = await openAppDatabase();
    final rows = await db.database.rawQuery(
      'SELECT * FROM financial_history_platform '
      'WHERE financial_history_id = ?',
      [financialHistoryId],
    );
    return rows.map((r) => FinancialHistoryPlatformModel.fromMap(r)).toList();
  }

  Future<void> deletePlatformLinksByFinancialHistoryId(
    String financialHistoryId,
  ) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.delete(
      'financial_history_platform',
      where: 'financial_history_id = ?',
      whereArgs: [financialHistoryId],
    );
  }

  Future<void> insertPlatformLink(FinancialHistoryPlatformModel model) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.insert(
      'financial_history_platform',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  Future<PlatformModel?> getPlatformById(String id) async {
    final AppDatabase db = await openAppDatabase();
    return db.platformDao.getPlatformById(id);
  }

  Future<List<PlatformModel>> getAllPlatforms() async {
    final AppDatabase db = await openAppDatabase();
    return db.platformDao.getAllPlatforms();
  }

  Future<void> insertPlatform(PlatformModel model) async {
    final AppDatabase db = await openAppDatabase();
    await db.platformDao.insertPlatform(model);
  }

  // FIM PERSISTÊNCIA DIRETA #################################################################
}
