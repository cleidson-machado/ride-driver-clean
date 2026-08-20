import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history.dart';

@dao
abstract class FinancialHistoryDao {
  @Query('SELECT * FROM financial_history ORDER BY work_date DESC')
  Future<List<FinancialHistory>> getAllFinancialHistories();

  @Query('SELECT * FROM financial_history WHERE id = :id')
  Future<FinancialHistory?> getFinancialHistoryById(String id);

  @insert
  Future<void> insertFinancialHistory(FinancialHistory financialHistory);

  @update
  Future<void> updateFinancialHistory(FinancialHistory financialHistory);

  @delete
  Future<void> deleteFinancialHistory(FinancialHistory financialHistory);
}
