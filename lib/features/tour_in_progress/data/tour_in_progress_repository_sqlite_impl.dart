import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:ride_driver_app_1/app/database/app_database.dart';
import '../domain/tour_in_progress_model.dart';
import 'tour_in_progress_repository_interface.dart';

/// Implementação SQLite de [TourInProgressRepositoryInterface].
///
/// Cuida exclusivamente da persistência sobre a tabela `financial_history`
/// (fonte compartilhada com o contexto financeiro — aqui lida num ângulo de
/// leitura de "passeio em curso / finalizados"). Para trocar a tecnologia de
/// armazenamento (ex.: REST), basta fornecer outra implementação do contrato.
class TourInProgressRepositorySqliteImpl
    implements TourInProgressRepositoryInterface {
  // INICIO PASSEIO EM CURSO ##################################################

  /// O passeio em curso é o registro `is_finished = 0` mais recente (maior
  /// `rowid`, equivalente à criação mais tardia no banco).
  @override
  Future<TourInProgressModel?> findInProgress() async {
    final sqflite.Database db = await openAppDatabase();
    final rows = await db.rawQuery(
      'SELECT * FROM financial_history '
      'WHERE is_finished = 0 ORDER BY rowid DESC LIMIT 1',
    );
    if (rows.isEmpty) return null;
    return TourInProgressModel.fromMap(rows.first);
  }

  /// Passeios finalizados paginados em ordem de criação no banco (rowid ASC).
  @override
  Future<List<TourInProgressModel>> getFinishedPage({
    required int limit,
    required int offset,
  }) async {
    final sqflite.Database db = await openAppDatabase();
    final rows = await db.rawQuery(
      'SELECT * FROM financial_history '
      'WHERE is_finished = 1 ORDER BY rowid ASC LIMIT ? OFFSET ?',
      [limit, offset],
    );
    return rows.map((r) => TourInProgressModel.fromMap(r)).toList();
  }

  /// Total de passeios finalizados.
  @override
  Future<int> countFinished() async {
    final sqflite.Database db = await openAppDatabase();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM financial_history WHERE is_finished = 1',
    );
    return sqflite.Sqflite.firstIntValue(rows) ?? 0;
  }

  // FIM PASSEIO EM CURSO #######################################################

  /// Atualiza somente os campos persistíveis de um passeio na tabela
  /// `financial_history`. Preserva e reutiliza o layout da linha compartilhada.
  @override
  Future<void> update(TourInProgressModel model) async {
    final sqflite.Database db = await openAppDatabase();
    await db.update(
      'financial_history',
      {
        'work_date': model.date.millisecondsSinceEpoch,
        'trip_number': model.sku,
        'fuel_cost': model.cashSpent,
        'km_start': model.kmIn,
        'km_end': model.kmOut ?? 0,
        'is_finished': model.isFinished ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }
}
