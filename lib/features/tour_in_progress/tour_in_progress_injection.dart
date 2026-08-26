import 'package:get_it/get_it.dart';

import 'data/tour_in_progress_repository_interface.dart';
import 'data/tour_in_progress_repository_sqlite_impl.dart';
import 'tour_in_progress_controller.dart';
import 'tour_in_progress_service.dart';

/// Ponto único de registro de DI da feature de passeio em curso.
///
/// É o **único** local desta feature que conhece e instancia a implementação
/// concreta de infraestrutura ([TourInProgressRepositorySqliteImpl]). Camadas
/// superiores (view/controller) dependem apenas das abstrações
/// ([TourInProgressRepositoryInterface], [TourInProgressService]) e resolvem
/// tudo via [GetIt] — nunca importam tipos concretos de persistência.
void registerTourInProgressDependencies(GetIt getIt) {
  getIt.registerLazySingleton<TourInProgressRepositoryInterface>(
    () => TourInProgressRepositorySqliteImpl(),
  );

  getIt.registerLazySingleton<TourInProgressService>(
    () => TourInProgressService(
      repository: getIt<TourInProgressRepositoryInterface>(),
    ),
  );

  // Factory: cada tela precisa de uma instância própria do controller
  // (estado da tela não deve ser compartilhado entre telas).
  getIt.registerFactory<TourInProgressController>(
    () => TourInProgressController(service: getIt<TourInProgressService>()),
  );
}

