import 'package:flutter/material.dart';

import '../../app/di/service_locator.dart';
import '../../app/helper/ride_formatters.dart';
import '../financial_history/financial_history_view.dart';
import 'domain/tour_in_progress_model.dart';
import 'tour_in_progress_controller.dart';
import 'tour_close_view.dart';

/// Tela de passeio em curso com resumo superior e histórico recente em lista
/// vertical infinita (dados reais via [TourInProgressController]).
///
/// [reportId] opcional: id do report recém-criado a evidenciar (após salvar um
/// novo passeio na FinancialHistoryView); a view já carrega o report ativo do
/// banco via controller.
class TourInProgressView extends StatefulWidget {
  const TourInProgressView({super.key, this.reportId});

  final String? reportId;

  @override
  State<TourInProgressView> createState() => _TourInProgressViewState();
}

class _TourInProgressViewState extends State<TourInProgressView> {
  // Controller (application layer): dono do estado e das ações da tela.
  late final TourInProgressController _controller;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = getIt<TourInProgressController>();
    // Carrega o report ativo + primeira página de finalizados.
    _controller.load();
    if (widget.reportId != null) {
      debugPrint('[VIEW] novo report focado: ${widget.reportId}');
    }
    _scrollController.addListener(_handleScroll);
  }

  /// Ao chegar perto do fim do ListView, carrega a próxima página (infinito).
  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final double position = _scrollController.position.pixels;
    final double maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent - position < 120 && !_controller.loadingMoreFinished) {
      _controller.loadMoreFinished();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Abre o modal minimalista com o resumo do report ([report]) selecionado e
  /// um botão que navega para a edição do report ([id]) na FinancialHistoryView.
  Future<void> _showReportSummaryModal(TourInProgressModel report) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Passeio ${report.sku}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Data', RideFormatters.formatDateLabel(report.date)),
              _summaryRow('KM IN', RideFormatters.formatKm(report.kmIn)),
              _summaryRow('KM OUT', RideFormatters.formatKm(report.kmOut)),
              _summaryRow(
                'CASH (Gas/Energia)',
                RideFormatters.formatCurrency(report.cashSpent),
              ),
              _summaryRow('Status', report.isFinished ? 'CONCLUÍDO' : 'EM CURSO'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fechar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navega para a FinancialHistoryView em modo edição (SKU + "(EM
                // EDIÇÃO)") abrindo o report pelo id.
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FinancialHistoryView(reportId: report.id),
                  ),
                );
              },
              child: const Text('Editar'),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Abre a tela de encerramento (consolidação) do report ativo ([report]).
  void _openCloseFlow(TourInProgressModel report) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TourCloseView(
          controller: _controller,
          report: report,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (BuildContext context, Widget? child) {
            final TourInProgressModel? active = _controller.activeReport;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, active),
                Divider(color: colorScheme.outline, height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CurrentRideZone(
                          report: active,
                          busy: _controller.busy,
                          onClose: active == null
                              ? null
                              : () => _openCloseFlow(active),
                        ),
                        const SizedBox(height: 16),
                        _RecentRidesSection(
                          controller: _controller,
                          scrollController: _scrollController,
                          onTapItem: _showReportSummaryModal,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TourInProgressModel? active,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String dateLabel = active != null
        ? RideFormatters.formatDateLabel(active.date)
        : 'PASSEIO EM CURSO';

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Voltar',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const BackButtonIcon(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              dateLabel,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Zona do card superior (gradiente + botão vermelho) sobre o report ativo.
/// Exibe o report em curso; quando não há nenhum, mostra um estado vazio.
class _CurrentRideZone extends StatelessWidget {
  const _CurrentRideZone({
    required this.report,
    required this.busy,
    required this.onClose,
  });

  final TourInProgressModel? report;
  final bool busy;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return const _EmptyStateCard();
    }
    return _CurrentRideCard(
      rideSku: report!.sku,
      dateLabel: RideFormatters.formatDateLabel(report!.date),
      fuelValue: RideFormatters.formatCurrency(report!.cashSpent),
      kmInValue: RideFormatters.formatKm(report!.kmIn),
      onClose: onClose,
      closeEnabled: !busy,
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainerLowest,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.directions_car_outlined,
            size: 44,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum passeio em curso',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // Botão discreto no padrão dos demais FilledButton da
          // FinancialHistoryView: abre o cadastro (modo criação) de um novo
          // report — mesmo fluxo do "Add PASSEIO" da Home.
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FinancialHistoryView(),
                ),
              );
            },
            icon: const Icon(Icons.add_road_rounded, size: 18),
            label: Text(
              'ADD PASSEIO',
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'O PASSEIO em CURSO será exibido AQUI!',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentRideCard extends StatelessWidget {
  const _CurrentRideCard({
    required this.rideSku,
    required this.dateLabel,
    required this.fuelValue,
    required this.kmInValue,
    required this.onClose,
    required this.closeEnabled,
  });

  final String rideSku;
  final String dateLabel;
  final String fuelValue;
  final String kmInValue;
  final VoidCallback? onClose;
  final bool closeEnabled;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.35, 1.0],
          colors: [
            colorScheme.tertiary.withValues(alpha: 0.22),
            colorScheme.tertiaryContainer.withValues(alpha: 0.16),
            colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.18),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            dateLabel,
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'PASSEIO:',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        rideSku,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.error,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const _StatusIndicator(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricPanel(
                  child: _TopMetric(label: 'COMBUSTIVEL', value: fuelValue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricPanel(
                  child: _TopMetric(label: 'KM IN', value: kmInValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(154, 52),
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                elevation: 4,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: colorScheme.errorContainer, width: 1.5),
                ),
              ),
              onPressed: closeEnabled ? onClose : null,
              child: Text(
                'ENCERRAR - PASSEIO?',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[colorScheme.primaryContainer, colorScheme.primary],
        ),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
    );
  }
}

class _TopMetric extends StatelessWidget {
  const _TopMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// Histórico recente em ListView infinita (dados reais do controller).
class _RecentRidesSection extends StatelessWidget {
  const _RecentRidesSection({
    required this.controller,
    required this.scrollController,
    required this.onTapItem,
  });

  final TourInProgressController controller;
  final ScrollController scrollController;
  final Future<void> Function(TourInProgressModel) onTapItem;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<TourInProgressModel> items = controller.finishedReports;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.primaryContainer),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Passeios Recentes:',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: items.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == items.length) {
                    // Rodapé: carregando mais / fim da lista.
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: Text(
                          controller.hasMoreFinished
                              ? 'Carregando...'
                              : (items.isEmpty ? 'Nenhum passeio finalizado.' : '— fim —'),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }
                  final TourInProgressModel item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => onTapItem(item),
                      child: _RecentRideDataTableCard(item: item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRideDataTableCard extends StatelessWidget {
  const _RecentRideDataTableCard({required this.item});

  final TourInProgressModel item;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[colorScheme.surface, colorScheme.surfaceContainerLowest],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Esquerda: ícone + número curto do passeio, data abaixo.
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.directions_car_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        RideFormatters.shortSku(item.sku),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  RideFormatters.formatDateShort(item.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Centro: valor em euros e KM IN/OUT, centralizados no bloco.
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  RideFormatters.formatCurrency(item.cashSpent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'KM IN: ${RideFormatters.formatKm(item.kmIn)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'OUT: ${RideFormatters.formatKm(item.kmOut)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Direita: "Trip Stats" + HOD, alinhados à direita.
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Trip Stats',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'HOD',
                  maxLines: 1,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  RideFormatters.formatKm(item.kmOdometer),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
