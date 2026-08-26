import 'package:flutter/foundation.dart';

import 'data/tour_in_progress_repository_interface.dart';
import 'domain/tour_in_progress_model.dart';
import 'domain/tour_in_progress_page.dart';

/// Regras de negócio do contexto de passeio em curso.
///
/// Depende apenas do contrato [TourInProgressRepositoryInterface] (camada de
/// domínio) — nunca de uma implementação concreta. Isso permite injetar hoje
/// uma implementação SQLite e, futuramente, uma REST sem alterar esta classe
/// (princípio da inversão de dependência).
///
/// Leitura apenas: esta feature é um "painel" por cima da mesma tabela
/// `financial_history` que guarda os reports do contexto financeiro. Um report
/// em curso (`isFinished = false`) é exibido no topo; os finalizados alimentam
/// o histórico recente paginado.
class TourInProgressService {
  const TourInProgressService({
    required TourInProgressRepositoryInterface repository,
  }) : _storage = repository;

  final TourInProgressRepositoryInterface _storage;

  /// Tamanho padrão da página do histórico de passeios finalizados.
  static const int defaultPageSize = 10;

  // INICIO LEITURAS ############################################################

  /// Busca o report "em curso": `isFinished = false` mais recente.
  ///
  /// Retorna `null` quando não há nenhum passeio aberto (estado inicial vazio).
  Future<TourInProgressModel?> findInProgress() {
    return _storage.findInProgress();
  }

  /// Lista os reports finalizados paginados em ordem de criação no banco.
  ///
  /// [page] é base 0. A paginação é resolvida na service (via repositório)
  /// para que a view receba já o [TourInProgressPage] com os metadados de
  /// `hasMore`/`totalCount`.
  Future<TourInProgressPage> listFinished({int page = 0}) async {
    assert(page >= 0, 'page não pode ser negativo.');
    final int offset = page * defaultPageSize;
    final int totalCount = await _storage.countFinished();
    final List<TourInProgressModel> items = await _storage.getFinishedPage(
      limit: defaultPageSize,
      offset: offset,
    );
    return TourInProgressPage(
      items: items,
      page: page,
      pageSize: defaultPageSize,
      totalCount: totalCount,
    );
  }
  // FIM LEITURAS ###############################################################

  // INICIO ENCERRAMENTO ########################################################

  /// Encerra um passeio em curso, aplicando as validações de negócio antes de
  /// persistir.
  ///
  /// Regras validadas (fase atual desta parte):
  ///  - `kmOut` deve estar preenchido e ser `>= kmIn`;
  ///  - a data não pode ser futura;
  ///  - `cashSpent >= 0`.
  ///
  /// Obs.: a regra `hodo2IsZero` fica **fora** desta validação por ora (não
  /// carregamos nem validamos o odômetro neste contexto).
  ///
  /// Lança [TourInProgressValidationException] quando o passeio não atende às
  /// regras (nada é persistido).
  Future<TourInProgressModel> finish({
    required TourInProgressModel current,
    required int kmOut,
    required DateTime date,
    required double cashSpent,
  }) async {
    _validateFinish(kmOut: kmOut, kmIn: current.kmIn, date: date, cashSpent: cashSpent);

    final TourInProgressModel finished = current.copyWith(
      kmOut: () => kmOut,
      date: date,
      cashSpent: cashSpent,
      isFinished: true,
    );
    await _storage.update(finished);
    debugPrint('[FINISH][service] passeio ${finished.id} encerrado '
        '(kmOut=$kmOut, data=$date)');
    return finished;
  }
  // FIM ENCERRAMENTO ###########################################################

  /// Validações de negócio para encerrar um passeio.
  void _validateFinish({
    required int kmOut,
    required int kmIn,
    required DateTime date,
    required double cashSpent,
  }) {
    if (kmOut < kmIn) {
      throw const TourInProgressValidationException(
        'KM - OUT deve ser preenchido e maior ou igual a KM - IN.',
      );
    }
    if (date.isAfter(DateTime.now())) {
      throw const TourInProgressValidationException(
        'A data não pode ser futura.',
      );
    }
    if (cashSpent < 0) {
      throw const TourInProgressValidationException(
        'CASH (Gas/Energia) não pode ser negativo.',
      );
    }
  }
}

/// Erro de validação de negócio ao encerrar um passeio em curso.
class TourInProgressValidationException implements Exception {
  const TourInProgressValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
