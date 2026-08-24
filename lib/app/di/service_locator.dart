import 'package:get_it/get_it.dart';

import '../../features/financial_history/financial_history_injection.dart';

/// Container de DI global do app (padrão service locator via `get_it`).
///
/// Cada feature expõe sua própria função `registerXxxDependencies(getIt)`
/// (ex.: [registerFinancialHistoryDependencies]) que conhece as implementações
/// concretas de infraestrutura daquela feature. Views/controllers resolvem
/// tudo através deste [getIt] e nunca importam tipos concretos diretamente.
final GetIt getIt = GetIt.instance;

/// Registra as dependências de todas as features. Chamado uma única vez em
/// `main()`, antes de `runApp`.
void setupServiceLocator() {
  registerFinancialHistoryDependencies(getIt);
}
