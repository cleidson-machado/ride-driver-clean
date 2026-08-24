import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:ride_driver_app_1/app/database/app_database.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/platform_model.dart';

import 'financial_history_repository_interface.dart';
import '../domain/financial_history_model.dart';

/// Implementação SQLite do [FinancialHistoryRepositoryInterface].
///
/// Cuida exclusivamente da persistência. Para trocar a tecnologia de
/// armazenamento (ex.: REST API), basta fornecer outra implementação do
/// contrato — a [FinancialHistoryService] não é alterada.
class FinancialHistoryRepositorySqliteImpl
    implements FinancialHistoryRepositoryInterface {
  // INICIO PERSISTÊNCIA DIRETA (financial_history + vínculos) ###############################
  @override
  Future<List<FinancialHistoryModel>> getAll() async {
    final AppDatabase db = await openAppDatabase();
    final rows = await db.database.rawQuery(
      'SELECT * FROM financial_history ORDER BY work_date DESC',
    );
    return rows.map((r) => FinancialHistoryModel.fromMap(r)).toList();
  }

  @override
  Future<FinancialHistoryModel?> getById(String id) async {
    final AppDatabase db = await openAppDatabase();
    final rows = await db.database.rawQuery(
      'SELECT * FROM financial_history WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return FinancialHistoryModel.fromMap(rows.first);
  }

  @override
  Future<void> insert(FinancialHistoryModel model) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.insert(
      'financial_history',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
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

  @override
  Future<void> deleteById(String id) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.delete(
      'financial_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
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

  @override
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

  @override
  Future<void> insertPlatformLink(FinancialHistoryPlatformModel model) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.insert(
      'financial_history_platform',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<PlatformModel?> getPlatformById(String id) async {
    final AppDatabase db = await openAppDatabase();
    final rows = await db.database.rawQuery(
      'SELECT * FROM platform WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return PlatformModel.fromMap(rows.first);
  }

  @override
  Future<List<PlatformModel>> getAllPlatforms() async {
    final AppDatabase db = await openAppDatabase();
    final rows = await db.database.rawQuery(
      'SELECT * FROM platform ORDER BY name ASC',
    );
    return rows.map((r) => PlatformModel.fromMap(r)).toList();
  }

  @override
  Future<void> insertPlatform(PlatformModel model) async {
    final AppDatabase db = await openAppDatabase();
    await db.database.insert(
      'platform',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  // FIM PERSISTÊNCIA DIRETA #################################################################
}
