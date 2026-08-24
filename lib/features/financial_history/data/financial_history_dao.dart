import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_model.dart';

@dao
abstract class FinancialHistoryDao {
  @Query('SELECT * FROM financial_history ORDER BY work_date DESC')
  Future<List<FinancialHistoryModel>> getAllFinancialHistories();

  @Query('SELECT * FROM financial_history WHERE id = :id')
  Future<FinancialHistoryModel?> getFinancialHistoryById(String id);

  @insert
  Future<void> insertFinancialHistory(FinancialHistoryModel financialHistory);

  @update
  Future<void> updateFinancialHistory(FinancialHistoryModel financialHistory);

  @delete
  Future<void> deleteFinancialHistory(FinancialHistoryModel financialHistory);
}
