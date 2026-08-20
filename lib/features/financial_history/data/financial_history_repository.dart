import '../domain/financial_history.dart';

/// Contrato de persistência de [FinancialHistory].
///
/// A view e o controller dependem apenas desta interface — nunca da fonte
/// concreta de dados. A implementação atual (local, SQLite) fica em
/// `FinancialHistoryLocalRepository`; futuramente pode-se trocar por uma impl em
/// memória ou remota sem tocar na UI.
abstract class FinancialHistoryRepository {
  /// Carrega um report existente pelo id. Retorna `null` se não existir.
  Future<FinancialHistory?> getById(String id);

  /// Persiste (cria ou atualiza) um report. Retorna o report salvo.
  Future<FinancialHistory> save(FinancialHistory report);

  /// Exclui um report pelo id.
  Future<void> delete(String id);
}
