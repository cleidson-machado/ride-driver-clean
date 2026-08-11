import 'package:flutter/material.dart';

/// Conteúdo principal da home (sem Scaffold) para uso dentro do hub de abas.
class HomeAddRideView extends StatefulWidget {
  const HomeAddRideView({
    required this.onAddRidePressed,
    super.key,
  });

  final VoidCallback onAddRidePressed;

  @override
  State<HomeAddRideView> createState() => _HomeAddRideViewState();
}

class _HomeAddRideViewState extends State<HomeAddRideView> {
  bool _lastRideExpanded = true;
  bool _weekExpanded = true;
  Set<_RideAction> _selectedRideAction = <_RideAction>{};

  static const List<_MetricItem> _mockLastRideMetrics = [
    _MetricItem(
      label: 'Lucro',
      value: '€ 22,45',
      icon: Icons.euro_rounded,
    ),
    _MetricItem(
      label: 'KM rodado total',
      value: '129.5',
      icon: Icons.directions_car_rounded,
    ),
    _MetricItem(
      label: 'Consumo médio',
      value: '€ 0,34',
      icon: Icons.water_drop_rounded,
    ),
    _MetricItem(
      label: 'Horas trabalho',
      value: '5.6',
      icon: Icons.schedule_rounded,
    ),
    _MetricItem(
      label: 'Valor ticket médio',
      value: '€ 8,10',
      icon: Icons.confirmation_number_rounded,
    ),
  ];

  static const List<_MetricItem> _mockWeekMetrics = [
    _MetricItem(
      label: 'Lucro',
      value: '€ 22,45',
      icon: Icons.euro_rounded,
    ),
    _MetricItem(
      label: 'KM rodado total',
      value: '129.5',
      icon: Icons.speed_rounded,
    ),
    _MetricItem(
      label: 'Consumo médio',
      value: '€ 0,34',
      icon: Icons.water_drop_rounded,
    ),
    _MetricItem(
      label: 'Horas trabalho',
      value: '5.6',
      icon: Icons.schedule_rounded,
    ),
    _MetricItem(
      label: 'Valor ticket médio',
      value: '€ 8,10',
      icon: Icons.confirmation_number_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionToggleButton(
            title: 'Médias do último passeio',
            expanded: _lastRideExpanded,
            onPressed: () => setState(
              () => _lastRideExpanded = !_lastRideExpanded,
            ),
          ),
          if (_lastRideExpanded)
            Expanded(
              child: _MetricsCard(metrics: _mockLastRideMetrics),
            ),
          const SizedBox(height: 8),
          _SectionToggleButton(
            title: 'Médias da semana',
            expanded: _weekExpanded,
            onPressed: () => setState(
              () => _weekExpanded = !_weekExpanded,
            ),
          ),
          if (_weekExpanded)
            Expanded(
              child: _MetricsCard(metrics: _mockWeekMetrics),
            ),
          if (!_lastRideExpanded && !_weekExpanded) const Spacer(),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: SegmentedButton<_RideAction>(
              segments: const [
                ButtonSegment<_RideAction>(
                  value: _RideAction.addRide,
                  icon: Icon(Icons.add_road_rounded),
                  label: Text('Add PASSEIO'),
                ),
                ButtonSegment<_RideAction>(
                  value: _RideAction.viewInProgressRide,
                  icon: Icon(Icons.visibility_rounded),
                  label: Text('VER em CURSO'),
                  enabled: false,
                ),
              ],
              selected: _selectedRideAction,
              emptySelectionAllowed: true,
              multiSelectionEnabled: false,
              showSelectedIcon: false,
              onSelectionChanged: (Set<_RideAction> newSelection) {
                if (newSelection.contains(_RideAction.addRide)) {
                  widget.onAddRidePressed();
                }

                // Limpa a selecao para permitir novo toque e reabrir a tela de adicionar.
                setState(() {
                  _selectedRideAction = <_RideAction>{};
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _RideAction {
  addRide,
  viewInProgressRide,
}

/// Título de seção como botão: expande/recolhe a tabela correspondente.
class _SectionToggleButton extends StatelessWidget {
  const _SectionToggleButton({
    required this.title,
    required this.expanded,
    required this.onPressed,
  });

  final String title;
  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: colorScheme.tertiary,
      ),
      icon: Icon(
        expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
        semanticLabel: expanded ? 'Ocultar tabela' : 'Mostrar tabela',
      ),
      label: Text(
        title.toUpperCase(),
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.tertiary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Card de métricas (icon + label × valor).
///
/// Flexível em altura: as linhas dividem o espaço do card igualmente
/// (Expanded), permitindo que a tela inteira caiba sem scroll.
class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.metrics});

  final List<_MetricItem> metrics;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            Expanded(child: _MetricRow(item: metrics[i])),
          ],
        ],
      ),
    );
  }
}

/// Linha de métrica: label alinhado à esquerda, valor em destaque à direita.
class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.value,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Par icon/label/valor exibido nas tabelas de métricas (mock da POC).
class _MetricItem {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}
