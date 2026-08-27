import 'package:flutter/material.dart';

// ─── Header ───────────────────────────────────────────────────────────────────
// Barra superior da tela: botão de voltar à esquerda e, ao centro, o SKU do
// report atual seguido do pill de status do passeio (EM CRIAÇÃO / EM CURSO /
// CONCLUÍDO). Em modo edição ([showEditBadge] true) o SKU é seguido do rótulo
// "(EM EDIÇÃO)".
class RideHeaderWidget extends StatelessWidget {
  const RideHeaderWidget({
    super.key,
    required this.rideSku,
    required this.isRideInProgress,
    this.isNewReport = false,
    this.showEditBadge = false,
  });

  final String rideSku;
  final bool isRideInProgress;

  /// Exibe o rótulo "EM CRIAÇÃO" no pill quando a view está aberta para criar
  /// um report novo (reportId nulo na FinancialHistoryView).
  final bool isNewReport;

  /// Exibe o rótulo "(EM EDIÇÃO)" após o SKU (modo edição da FinancialHistoryView).
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String title = showEditBadge
        ? 'Report: $rideSku (EM EDIÇÃO)'
        : 'Report: $rideSku';

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Voltar',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const BackButtonIcon(),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                _RideStatusPillWidget(
                  isInProgress: isRideInProgress,
                  isNewReport: isNewReport,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ride status pill (EM CRIAÇÃO / EM CURSO / CONCLUIDO) ───────────────────
// Pequeno chip colorido que sinaliza o estado do report, com par de cores M3
// próprio para cada estado: EM CRIAÇÃO (secondary), EM CURSO (tertiary) e
// CONCLUIDO (primary).
class _RideStatusPillWidget extends StatelessWidget {
  const _RideStatusPillWidget({
    required this.isInProgress,
    required this.isNewReport,
  });

  final bool isInProgress;
  final bool isNewReport;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Cada estado tem par próprio de cores M3 (container + onContainer):
    //  - EM CRIAÇÃO  → secondary (tom neutro/rascunho)
    //  - EM CURSO    → tertiary (tom azulado/ativa)
    //  - CONCLUIDO   → primary  (verde forte/concluído)
    final (Color backgroundColor, Color foregroundColor, String label) =
        switch ((isNewReport, isInProgress)) {
      (true, _) => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          'EM CRIAÇÃO',
        ),
      (_, true) => (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
          'EM CURSO',
        ),
      _ => (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
          'CONCLUIDO',
        ),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: foregroundColor,
        ),
      ),
    );
  }
}

