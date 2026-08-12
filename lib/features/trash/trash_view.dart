import 'package:flutter/material.dart';

/// Painel de gerenciamento de dados: armazenamento, reset seletivo e exportação.
class TrashView extends StatefulWidget {
  const TrashView({super.key});

  @override
  State<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  // Mock de uso do banco local.
  static const String _mockDbSize = '804 KB';
  static const String _mockTotalRecords = '1.064 registros';
  static const String _mockLastBackup = '09/07/2026 às 14:32';
  static const String _mockAppVersion = '0.1.0-poc';

  _ResetScope _selectedResetScope = _ResetScope.day;
  DateTime _selectedDate = DateTime(2026, 7, 16);

  void _onResetScopeChanged(Set<_ResetScope> value) =>
      setState(() => _selectedResetScope = value.first);

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _formattedDate {
    final d = _selectedDate;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _confirmReset(BuildContext context, String description) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        final ColorScheme cs = Theme.of(ctx).colorScheme;
        final TextTheme tt = Theme.of(ctx).textTheme;
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 32),
          title: const Text('Confirmar reset'),
          content: Text(description, style: tt.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                // TODO: executar reset
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmFullReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        final ColorScheme cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.dangerous_rounded, color: cs.error, size: 36),
          title: const Text('Reset completo'),
          content: const Text(
            'Todos os registros, passeios e configurações serão apagados '
            'permanentemente. Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                // TODO: executar reset completo
              },
              child: const Text('Apagar tudo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cabeçalho ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.storage_rounded, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados & Armazenamento',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Versão $_mockAppVersion  ·  SQLite local',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Seção: Armazenamento ────────────────────────────────────────
          _SectionLabel(label: 'ARMAZENAMENTO'),
          Card(
            child: Column(
              children: [
                _InfoRow(label: 'Banco de dados', value: _mockDbSize),
                Divider(height: 1, color: colorScheme.outlineVariant),
                _InfoRow(label: 'Total de registros', value: _mockTotalRecords),
                Divider(height: 1, color: colorScheme.outlineVariant),
                _InfoRow(label: 'Último backup', value: _mockLastBackup),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ── Seção: Exportação ───────────────────────────────────────────
          _SectionLabel(label: 'EXPORTAR DADOS'),
          Card(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.table_chart_outlined,
                  iconColor: colorScheme.primary,
                  iconBg: colorScheme.primaryContainer,
                  title: 'Exportar todos os dados (CSV)',
                  subtitle: 'Gera arquivo com todos os passeios registrados',
                  onTap: () {
                    // TODO: exportar CSV completo
                  },
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                _ActionTile(
                  icon: Icons.calendar_today_rounded,
                  iconColor: colorScheme.tertiary,
                  iconBg: colorScheme.tertiaryContainer,
                  title: 'Exportar por período',
                  subtitle: 'Selecione intervalo e exporte em CSV',
                  onTap: () {
                    // TODO: exportar CSV por período
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ── Seção: Reset seletivo ───────────────────────────────────────
          _SectionLabel(label: 'LIMPAR DADOS'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escopo do reset',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Define quais registros serão removidos',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<_ResetScope>(
                    segments: const [
                      ButtonSegment(value: _ResetScope.day, label: Text('Dia')),
                      ButtonSegment(value: _ResetScope.month, label: Text('Mês')),
                      ButtonSegment(value: _ResetScope.year, label: Text('Ano')),
                    ],
                    selected: {_selectedResetScope},
                    onSelectionChanged: _onResetScopeChanged,
                    showSelectedIcon: false,
                  ),
                  const SizedBox(height: 12),
                  // Seletor de data — filtra o que é exibido conforme escopo.
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_rounded, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _scopeDescription,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down_rounded, color: colorScheme.outline),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: Text('Limpar registros — $_scopeShortLabel'),
                    onPressed: () => _confirmReset(
                      context,
                      'Todos os registros de $_scopeDescription serão '
                      'removidos permanentemente do banco local.',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Seção: Reset completo ───────────────────────────────────────
          _SectionLabel(label: 'ZONA DE PERIGO'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.errorContainer),
            ),
            color: colorScheme.errorContainer.withValues(alpha: 0.18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Reset completo do app',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remove todos os passeios, plataformas e configurações. '
                    'O app voltará ao estado inicial. Faça um backup antes.',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('Apagar todos os dados'),
                    onPressed: () => _confirmFullReset(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _scopeDescription => switch (_selectedResetScope) {
        _ResetScope.day => _formattedDate,
        _ResetScope.month =>
          '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
        _ResetScope.year => '${_selectedDate.year}',
      };

  String get _scopeShortLabel => switch (_selectedResetScope) {
        _ResetScope.day => 'dia $_formattedDate',
        _ResetScope.month =>
          'mês ${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
        _ResetScope.year => 'ano ${_selectedDate.year}',
      };
}

enum _ResetScope { day, month, year }

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: textTheme.bodyMedium),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
