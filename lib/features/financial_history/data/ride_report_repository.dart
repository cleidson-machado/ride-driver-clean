import '../domain/ride_report.dart';

/// Contrato de persistência de [RideReport].
///
/// A view e o controller dependem apenas desta interface — nunca da fonte
/// concreta de dados. A implementação atual (local, SQLite) fica em
/// `LocalRideReportRepository`; futuramente pode-se trocar por uma impl em
/// memória ou remota sem tocar na UI.
abstract class RideReportRepository {
  /// Carrega um report existente pelo id. Retorna `null` se não existir.
  Future<RideReport?> getById(String id);

  /// Persiste (cria ou atualiza) um report. Retorna o report salvo.
  Future<RideReport> save(RideReport report);

  /// Exclui um report pelo id.
  Future<void> delete(String id);
}
