import 'package:flutter/material.dart';

/// Mini dashboard de histórico: visão geral da atividade do motorista.
class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  static const String _mockPeriod = '17 set 2025 - 7 set 2026';

  _HistoryTab _selectedTab = _HistoryTab.rides;

  // Distribuição mock da atividade por plataforma.
  static const List<_ActivitySlice> _activitySlices = [
    _ActivitySlice(label: 'Uber', count: 513, percent: '48,2%'),
    _ActivitySlice(label: 'Bolt', count: 192, percent: '18,0%'),
    _ActivitySlice(label: 'FreeNow', count: 64, percent: '6,0%'),
    _ActivitySlice(label: 'Particular', count: 57, percent: '5,4%'),
    _ActivitySlice(label: 'Outros', count: 238, percent: '22,4%'),
  ];

  static const List<_MetricItem> _positionMetrics = [
    _MetricItem(icon: Icons.directions_car_rounded, value: '1.064', label: 'Passeios no período'),
    _MetricItem(icon: Icons.euro_rounded, value: '€ 18.582,58', label: 'Faturamento total'),
    _MetricItem(icon: Icons.route_rounded, value: '42.331 km', label: 'Distância percorrida'),
    _MetricItem(icon: Icons.local_gas_station_rounded, value: '€ 3.204,10', label: 'Gasto com combustível'),
    _MetricItem(icon: Icons.timelapse_rounded, value: '65 dias', label: 'Dias ativos'),
  ];

  static const List<_MetricItem> _monthlyMetrics = [
    _MetricItem(icon: Icons.trending_up_rounded, value: '62,2', label: 'Passeios por mês', positive: true),
    _MetricItem(icon: Icons.trending_down_rounded, value: '€ 267,00', label: 'Despesas por mês', positive: false),
    _MetricItem(icon: Icons.account_balance_wallet_rounded, value: '€ 1.548,50', label: 'Receita líquida por mês', positive: true),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(
                period: _mockPeriod,
                selectedTab: _selectedTab,
                onTabChanged: (tab) => setState(() => _selectedTab = tab),
              ),
              const SizedBox(height: 16),
              Text(
                'Posição da atividade em 07/09/2026',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (compact) ...[
                const _ActivationGaugeCard(rate: 0.56),
                const SizedBox(height: 12),
                _ActivityDistributionCard(slices: _activitySlices),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: _ActivationGaugeCard(rate: 0.56)),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _ActivityDistributionCard(slices: _activitySlices)),
                  ],
                ),
              const SizedBox(height: 12),
              _MetricGrid(items: _positionMetrics, compact: compact),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 16),
              Text(
                'Histórico do período',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                _mockPeriod,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              if (compact) ...[
                const _ActivationGaugeCard(
                  rate: 0.023,
                  title: 'Custo operacional',
                  subtitle: 'Percentual médio do faturamento perdido em custos por mês',
                  compactLabel: '2,3%',
                ),
                const SizedBox(height: 12),
                _MetricGrid(items: _monthlyMetrics, compact: true),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(
                      child: _ActivationGaugeCard(
                        rate: 0.023,
                        title: 'Custo operacional',
                        subtitle: 'Percentual médio do faturamento perdido em custos por mês',
                        compactLabel: '2,3%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _MetricGrid(items: _monthlyMetrics, compact: false)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

enum _HistoryTab { rides, finance }

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.period,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final String period;
  final _HistoryTab selectedTab;
  final ValueChanged<_HistoryTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Visão geral da Atividade',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'Configurar atividade',
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        Text(
          'Atividade categorizada pela data do último passeio',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<_HistoryTab>(
              segments: const [
                ButtonSegment(value: _HistoryTab.rides, label: Text('Passeios')),
                ButtonSegment(value: _HistoryTab.finance, label: Text('Financeiro')),
              ],
              selected: {selectedTab},
              onSelectionChanged: (selection) => onTabChanged(selection.first),
              showSelectedIcon: false,
            ),
            ActionChip(
              avatar: Icon(Icons.calendar_month_rounded, size: 18, color: colorScheme.primary),
              label: Text('Todo o período  ·  $period'),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivationGaugeCard extends StatelessWidget {
  const _ActivationGaugeCard({
    required this.rate,
    this.title = 'Taxa de atividade',
    this.subtitle = 'Percentual dos dias do período com passeios registrados',
    this.compactLabel,
  });

  final double rate;
  final String title;
  final String subtitle;
  final String? compactLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String label = compactLabel ?? '${(rate * 100).round()}%';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: rate,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                    ),
                    Center(
                      child: Text(
                        label,
                        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right_rounded),
                iconAlignment: IconAlignment.end,
                label: const Text('Visualizar detalhes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityDistributionCard extends StatelessWidget {
  const _ActivityDistributionCard({required this.slices});

  final List<_ActivitySlice> slices;

  // Paleta derivada do tema, um tom por fatia.
  List<Color> _sliceColors(ColorScheme scheme) => [
        scheme.primary,
        scheme.tertiary,
        scheme.secondary,
        scheme.tertiaryContainer,
        scheme.error,
      ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<Color> colors = _sliceColors(colorScheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atividade por plataforma',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Distribuição atual dos passeios registrados',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: [
                    for (int i = 0; i < slices.length; i++)
                      Expanded(
                        flex: slices[i].count,
                        child: ColoredBox(color: colors[i % colors.length]),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                for (int i = 0; i < slices.length; i++)
                  _LegendEntry(
                    color: colors[i % colors.length],
                    text: '${slices[i].count} ${slices[i].label} (${slices[i].percent})',
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right_rounded),
                iconAlignment: IconAlignment.end,
                label: const Text('Visualizar passeios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.items, required this.compact});

  final List<_MetricItem> items;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final _MetricItem item in items)
          SizedBox(
            width: compact ? double.infinity : 210,
            child: _MetricCard(item: item),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color iconBg;
    final Color iconFg;
    final Color valueColor;
    switch (item.positive) {
      case true:
        iconBg = colorScheme.primaryContainer;
        iconFg = colorScheme.onPrimaryContainer;
        valueColor = colorScheme.primary;
      case false:
        iconBg = colorScheme.errorContainer;
        iconFg = colorScheme.onErrorContainer;
        valueColor = colorScheme.error;
      case null:
        iconBg = colorScheme.secondaryContainer;
        iconFg = colorScheme.onSecondaryContainer;
        valueColor = colorScheme.onSurface;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 22, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.value,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: valueColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivitySlice {
  const _ActivitySlice({
    required this.label,
    required this.count,
    required this.percent,
  });

  final String label;
  final int count;
  final String percent;
}

class _MetricItem {
  const _MetricItem({
    required this.icon,
    required this.value,
    required this.label,
    this.positive,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool? positive;
}
