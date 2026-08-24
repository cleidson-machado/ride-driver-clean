import 'data/financial_history_repository_sqlite_impl.dart';
import 'financial_history_controller.dart';
import 'financial_history_service.dart';

/// Ponto de composição (composition root) da feature de histórico financeiro.
///
/// É o **único** local desta feature que conhece e instancia a implementação
/// concreta de infraestrutura ([FinancialHistoryRepositorySqliteImpl]). A partir
/// dela monta a cadeia completa `repositório → service → controller`.
///
/// Camadas superiores (view/controller) dependem apenas das abstrações
/// ([FinancialHistoryService] e [FinancialHistoryController]); nunca importam
/// os tipos concretos de persistência. Isso mantém o princípio da inversão de
/// dependência sem introduzir um framework de DI.
abstract final class FinancialHistoryComposition {
  const FinancialHistoryComposition._();

  /// Monta a cadeia completa e devolve um [FinancialHistoryController] pronto
  /// para ser injetado/observado pela view.
  static FinancialHistoryController createController() {
    return FinancialHistoryController(
      service: FinancialHistoryService(
        repository: FinancialHistoryRepositorySqliteImpl(),
      ),
    );
  }
}
