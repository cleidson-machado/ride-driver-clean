import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/features/extra_expenses/extra_expenses_model.dart';

@dao
abstract class ExtraExpensesDao {
  /// Retorna todas as despesas extras, da mais recente para a mais antiga.
  @Query('SELECT * FROM extra_expenses ORDER BY created_at DESC')
  Future<List<ExtraExpensesModel>> getAllExtraExpenses();

  /// Retorna uma despesa extra pelo [id].
  @Query('SELECT * FROM extra_expenses WHERE id = :id')
  Future<ExtraExpensesModel?> getExtraExpenseById(String id);

  /// Retorna todas as despesas associadas a um determinado registro diário.
  @Query(
    'SELECT * FROM extra_expenses WHERE financial_history_id = :financialHistoryId ORDER BY created_at ASC',
  )
  Future<List<ExtraExpensesModel>> getExpensesByFinancialHistoryId(
    String financialHistoryId,
  );

  /// Retorna todas as despesas que ainda **não** estão vinculadas a nenhum
  /// registro diário (financial_history_id IS NULL).
  @Query('SELECT * FROM extra_expenses WHERE financial_history_id IS NULL ORDER BY created_at DESC')
  Future<List<ExtraExpensesModel>> getUnlinkedExpenses();

  /// Retorna o total de despesas (soma de amounts) para um determinado dia.
  @Query(
    'SELECT COALESCE(SUM(amount), 0) FROM extra_expenses WHERE financial_history_id = :financialHistoryId',
  )
  Future<double?> getTotalExpensesByFinancialHistoryId(String financialHistoryId);

  @insert
  Future<void> insertExtraExpense(ExtraExpensesModel extraExpense);

  @update
  Future<void> updateExtraExpense(ExtraExpensesModel extraExpense);

  @delete
  Future<void> deleteExtraExpense(ExtraExpensesModel extraExpense);
}

