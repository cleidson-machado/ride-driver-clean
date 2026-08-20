import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:ride_driver_app_1/features/extra_expenses/extra_expenses_dao.dart';
import 'package:ride_driver_app_1/features/extra_expenses/extra_expenses_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history.dart';
import 'package:ride_driver_app_1/features/financial_history/financial_history_dao.dart';
import 'package:ride_driver_app_1/features/financial_history/financial_history_platform_dao.dart';
import 'package:ride_driver_app_1/features/financial_history/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_dao.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

/// Implementação concreta de [FinancialHistoryDao].
class FinancialHistoryDaoImpl extends FinancialHistoryDao {
  final sqflite.Database _db;
  FinancialHistoryDaoImpl(this._db);

  @override
  Future<List<FinancialHistory>> getAllFinancialHistories() async {
    final rows = await _db.rawQuery(
      'SELECT * FROM financial_history ORDER BY work_date DESC',
    );
    return rows.map((r) => FinancialHistory.fromMap(r)).toList();
  }

  @override
  Future<FinancialHistory?> getFinancialHistoryById(String id) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM financial_history WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return FinancialHistory.fromMap(rows.first);
  }

  @override
  Future<void> insertFinancialHistory(FinancialHistory model) async {
    await _db.insert(
      'financial_history',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateFinancialHistory(FinancialHistory model) async {
    await _db.update(
      'financial_history',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> deleteFinancialHistory(FinancialHistory model) async {
    await _db.delete(
      'financial_history',
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }
}

/// Implementação concreta de [FinancialHistoryPlatformDao].
class FinancialHistoryPlatformDaoImpl extends FinancialHistoryPlatformDao {
  final sqflite.Database _db;
  FinancialHistoryPlatformDaoImpl(this._db);

  @override
  Future<List<FinancialHistoryPlatformModel>> getPlatformsByFinancialHistoryId(
    String financialHistoryId,
  ) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM financial_history_platform WHERE financial_history_id = ?',
      [financialHistoryId],
    );
    return rows.map((r) => FinancialHistoryPlatformModel.fromMap(r)).toList();
  }

  @override
  Future<FinancialHistoryPlatformModel?> getFinancialHistoryPlatformById(
    String id,
  ) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM financial_history_platform WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return FinancialHistoryPlatformModel.fromMap(rows.first);
  }

  @override
  Future<void> insertFinancialHistoryPlatform(
    FinancialHistoryPlatformModel model,
  ) async {
    await _db.insert(
      'financial_history_platform',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateFinancialHistoryPlatform(
    FinancialHistoryPlatformModel model,
  ) async {
    await _db.update(
      'financial_history_platform',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> deleteFinancialHistoryPlatform(
    FinancialHistoryPlatformModel model,
  ) async {
    await _db.delete(
      'financial_history_platform',
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }
}

/// Implementação concreta de [PlatformDao].
class PlatformDaoImpl extends PlatformDao {
  final sqflite.Database _db;
  PlatformDaoImpl(this._db);

  @override
  Future<List<PlatformModel>> getAllPlatforms() async {
    final rows = await _db.rawQuery('SELECT * FROM platform ORDER BY name ASC');
    return rows.map((r) => PlatformModel.fromMap(r)).toList();
  }

  @override
  Future<PlatformModel?> getPlatformById(String id) async {
    final rows = await _db.rawQuery('SELECT * FROM platform WHERE id = ?', [
      id,
    ]);
    if (rows.isEmpty) return null;
    return PlatformModel.fromMap(rows.first);
  }

  @override
  Future<void> insertPlatform(PlatformModel model) async {
    await _db.insert(
      'platform',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updatePlatform(PlatformModel model) async {
    await _db.update(
      'platform',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> deletePlatform(PlatformModel model) async {
    await _db.delete('platform', where: 'id = ?', whereArgs: [model.id]);
  }
}

/// Implementação concreta de [ExtraExpensesDao].
class ExtraExpensesDaoImpl extends ExtraExpensesDao {
  final sqflite.Database _db;
  ExtraExpensesDaoImpl(this._db);

  @override
  Future<List<ExtraExpensesModel>> getAllExtraExpenses() async {
    final rows = await _db.rawQuery(
      'SELECT * FROM extra_expenses ORDER BY created_at DESC',
    );
    return rows.map((r) => ExtraExpensesModel.fromMap(r)).toList();
  }

  @override
  Future<ExtraExpensesModel?> getExtraExpenseById(String id) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM extra_expenses WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return ExtraExpensesModel.fromMap(rows.first);
  }

  @override
  Future<List<ExtraExpensesModel>> getExpensesByFinancialHistoryId(
    String financialHistoryId,
  ) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM extra_expenses WHERE financial_history_id = ? ORDER BY created_at ASC',
      [financialHistoryId],
    );
    return rows.map((r) => ExtraExpensesModel.fromMap(r)).toList();
  }

  @override
  Future<List<ExtraExpensesModel>> getUnlinkedExpenses() async {
    final rows = await _db.rawQuery(
      'SELECT * FROM extra_expenses WHERE financial_history_id IS NULL ORDER BY created_at DESC',
    );
    return rows.map((r) => ExtraExpensesModel.fromMap(r)).toList();
  }

  @override
  Future<double?> getTotalExpensesByFinancialHistoryId(
    String financialHistoryId,
  ) async {
    final result = await _db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM extra_expenses WHERE financial_history_id = ?',
      [financialHistoryId],
    );
    return (result.first['total'] as num).toDouble();
  }

  @override
  Future<void> insertExtraExpense(ExtraExpensesModel model) async {
    await _db.insert(
      'extra_expenses',
      model.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateExtraExpense(ExtraExpensesModel model) async {
    await _db.update(
      'extra_expenses',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> deleteExtraExpense(ExtraExpensesModel model) async {
    await _db.delete('extra_expenses', where: 'id = ?', whereArgs: [model.id]);
  }
}
