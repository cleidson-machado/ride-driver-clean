import 'tour_in_progress_model.dart';

/// Resultado paginado de passeios finalizados.
///
/// Encapsula os itens de uma página e os metadados necessários para a UI
/// saber se há mais conteúdo a carregar (scroll infinito).
class TourInProgressPage {
  /// Itens da página atual (em ordem de criação no banco).
  final List<TourInProgressModel> items;

  /// Índice (base 0) da página retornada.
  final int page;

  /// Quantidade de itens por página (tamanho do page size usado na consulta).
  final int pageSize;

  /// Quantidade total de passeios finalizados no banco.
  final int totalCount;

  const TourInProgressPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  /// `true` se ainda houver páginas seguintes para carregar.
  bool get hasMore => (page + 1) * pageSize < totalCount;

  /// `true` se é a primeira página e não há nenhum item (estado vazio).
  bool get isEmpty => items.isEmpty && page == 0;
}
