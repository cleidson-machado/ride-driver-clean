import 'package:get_it/get_it.dart';

import 'data/financial_history_interface.dart';
import 'data/financial_history_repository_sqlite_impl.dart';
import 'financial_history_controller.dart';
import 'financial_history_service.dart';

/// Ponto único de registro de DI da feature de histórico financeiro.
///
/// É o **único** local desta feature que conhece e instancia a implementação
/// concreta de infraestrutura ([FinancialHistoryRepositorySqliteImpl]).
/// Camadas superiores (view/controller) dependem apenas das abstrações
/// ([FinancialHistoryInterface], [FinancialHistoryService]) e resolvem tudo
/// via [GetIt] — nunca importam tipos concretos de persistência.
void registerFinancialHistoryDependencies(GetIt getIt) {
  getIt.registerLazySingleton<FinancialHistoryInterface>(
    () => FinancialHistoryRepositorySqliteImpl(),
  );

  getIt.registerLazySingleton<FinancialHistoryService>(
    () => FinancialHistoryService(repository: getIt<FinancialHistoryInterface>()),
  );

  // Factory: cada tela precisa de uma instância própria do controller
  // (estado de formulário não deve ser compartilhado entre telas).
  getIt.registerFactory<FinancialHistoryController>(
    () => FinancialHistoryController(service: getIt<FinancialHistoryService>()),
  );
}
