import '../domain/financial_history.dart';

abstract class FinancialHistoryRepositoryInterface {

  Future<FinancialHistory?> getById(String id);

  Future<FinancialHistory> save(FinancialHistory report);

  Future<void> delete(String id);
}
