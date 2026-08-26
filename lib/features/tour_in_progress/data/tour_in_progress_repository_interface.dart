import '../domain/tour_in_progress_model.dart';

/// Contrato de persistência do contexto `tour_in_progress`.
///
/// Decisão de design (avaliação solicitada na tarefa): **criar um contrato
/// próprio** em vez de reutilizar [FinancialHistoryRepositoryInterface]. Motivos:
///
///  - **Coesão**: o contrato financeiro expõe uma superfície ampla (catálogo de
///    plataformas, vínculos, soft delete etc.) irrelevante para a tela de passeio
///    em curso. Um contrato enxuto e dedicado comunica com clareza as operações
///    deste bounded context: ler o passeio em curso, listar finalizados
///    paginados e atualizar um passeio ao encerrá-lo.
///
///  - **Baixo acoplamento**: `tour_in_progress` não importa tipos nem regras do
///    contexto financeiro (ex.: `FinancialHistoryModel` e seus vínculos de
///    plataforma). Os dois permanecem independentes, podendo evoluir e ser
///    substituídos sem se afetar.
///
/// O uso em POC justifica o custo de duplicar um mapeamento pequeno
/// (`TourInProgressModel.fromMap`): o ganho em isolamento paga esse overhead.
///
/// A implementação SQLite atual lê/grava a **mesma tabela** `financial_history`
/// (fonte de dados compartilhada com o contexto financeiro).
abstract class TourInProgressRepositoryInterface {
  /// Retorna o passeio "em curso" mais recente (`isFinished = false`), ou
  /// `null` quando não há nenhum aberto.
  Future<TourInProgressModel?> findInProgress();

  /// Lista os passeios finalizados paginados, em **ordem de criação no banco**
  /// (rowid crescente). [offset] é base 0.
  Future<List<TourInProgressModel>> getFinishedPage({
    required int limit,
    required int offset,
  });

  /// Total de passeios finalizados no banco (para cálculo de `hasMore`).
  Future<int> countFinished();

  /// Persiste as alterações de um passeio (ex.: campos de encerramento e o
  /// flag `isFinished`).
  Future<void> update(TourInProgressModel model);
}
