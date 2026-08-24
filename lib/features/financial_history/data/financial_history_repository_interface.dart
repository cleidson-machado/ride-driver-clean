import '../domain/financial_history_model.dart';

abstract class FinancialHistoryRepositoryInterface {

  Future<FinancialHistoryModel?> getById(String id);

  Future<FinancialHistoryModel> save(FinancialHistoryModel report);

  Future<void> delete(String id);
}
