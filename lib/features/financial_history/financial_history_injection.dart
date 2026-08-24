import 'package:get_it/get_it.dart';

import 'data/financial_history_repository_interface.dart';
import 'data/financial_history_repository_sqlite_impl.dart';
import 'financial_history_controller.dart';
import 'financial_history_service.dart';

/// Ponto único de registro de DI da feature de histórico financeiro.
///
/// É o **único** local desta feature que conhece e instancia a implementação
/// concreta de infraestrutura ([FinancialHistoryRepositorySqliteImpl]).
/// Camadas superiores (view/controller) dependem apenas das abstrações
/// ([FinancialHistoryRepositoryInterface], [FinancialHistoryService]) e resolvem tudo
/// via [GetIt] — nunca importam tipos concretos de persistência.
void registerFinancialHistoryDependencies(GetIt getIt) {
  getIt.registerLazySingleton<FinancialHistoryRepositoryInterface>(
    () => FinancialHistoryRepositorySqliteImpl(),
  );

  getIt.registerLazySingleton<FinancialHistoryService>(
    () => FinancialHistoryService(
      repository: getIt<FinancialHistoryRepositoryInterface>(),
    ),
  );

  // Factory: cada tela precisa de uma instância própria do controller
  // (estado de formulário não deve ser compartilhado entre telas).
  getIt.registerFactory<FinancialHistoryController>(
    () => FinancialHistoryController(service: getIt<FinancialHistoryService>()),
  );
}
