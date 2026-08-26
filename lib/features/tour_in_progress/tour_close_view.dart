import 'package:flutter/material.dart';

import '../../app/helper/ride_formatters.dart';
import 'domain/tour_in_progress_model.dart';
import 'tour_in_progress_controller.dart';

/// Tela de encerramento/consolidação do passeio em curso.
///
/// Permite ao usuário **revisar/completar** os campos obrigatórios
/// (KM OUT, CASH Gas/Energia e Data) e **confirmar o fechamento**
/// (`isFinished = true`). A confirmação delega para
/// [TourInProgressController.finish], que aplica as validações de negócio da
/// service (kmOut preenchido e `>= kmIn`, data não futura, cashSpent `>= 0`).
///
/// Se as validações falharem, exibe feedback e **não** fecha (fica na tela,
/// sem alterar o report). Em sucesso, retorna `true` ao navegar de volta para
/// que a TourInProgressView recarregue — o report sai do card "em curso" e
/// passa a aparecer no histórico de recentes.
///
/// Decisão (Parte 4): optei por uma **TourCloseView dedicada** em vez de
/// reutilizar a FinancialHistoryView em "modo consolidação": o fluxo de
/// fechamento (`finish` + validações) pertence a este bounded context, e a
/// tela é mais simples e coesa para o POC. A FinancialHistoryView segue
/// destinada ao cadastro/edição.
class TourCloseView extends StatefulWidget {
  const TourCloseView({
    super.key,
    required this.controller,
    required this.report,
  });

  /// Controller compartilhado com a tela de origem (mesmo estado do report).
  final TourInProgressController controller;

  /// Report em curso a ser encerrado.
  final TourInProgressModel report;

  @override
  State<TourCloseView> createState() => _TourCloseViewState();
}

class _TourCloseViewState extends State<TourCloseView> {
  late bool _busy;

  late int _kmOut;
  late double _cashSpent;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _busy = false;
    // Valores iniciais trazidos do report em curso (revisão/completção).
    _kmOut = widget.report.kmOut ?? widget.report.kmIn;
    _cashSpent = widget.report.cashSpent;
    _date = widget.report.date;
  }

  int _nonNegative(int value) => value < 0 ? 0 : value;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _editKmOut() async {
    final double? typed = await _showNumberPrompt(
      'KM - OUT',
      _kmOut.toDouble(),
    );
    if (typed != null && mounted) {
      setState(() => _kmOut = _nonNegative(typed.round()));
    }
  }

  Future<void> _editCash() async {
    final double? typed = await _showNumberPrompt('CASH - Gas / Energia', _cashSpent);
    if (typed != null && mounted) {
      setState(() => _cashSpent = typed < 0 ? 0 : typed);
    }
  }

  Future<double?> _showNumberPrompt(String title, double initial) {
    final TextEditingController field = TextEditingController(
      text: initial.toStringAsFixed(initial % 1 == 0 ? 0 : 2),
    );
    return showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: field,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(double.tryParse(field.text));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Confirma o fechamento: aguarda o resultado do [TourInProgressController.finish]
  /// e, em sucesso, volta com `true` para a tela de origem recarregar.
  Future<void> _confirmClose() async {
    FocusScope.of(context).unfocus();
    if (_busy) return;

    setState(() => _busy = true);
    final FinishOutcome outcome = await widget.controller.finish(
      kmOut: _kmOut,
      date: _date,
      cashSpent: _cashSpent,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (outcome == FinishOutcome.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passeio encerrado com sucesso.')),
      );
      Navigator.of(context).pop(true);
      return;
    }

    // validationError ou failure: feedback, sem navegar.
    final String message = widget.controller.lastError?.isNotEmpty == true
        ? widget.controller.lastError!
        : 'Não foi possível encerrar o passeio.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(context),
            Divider(color: colorScheme.outlineVariant, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _InfoCard(report: widget.report),
                    const SizedBox(height: 24),
                    Text(
                      'Revisar / Completar',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      label: 'KM - OUT (fechamento)',
                      value: RideFormatters.formatKm(_kmOut),
                      onDecrement: () =>
                          setState(() => _kmOut = _nonNegative(_kmOut - 1)),
                      onIncrement: () => setState(() => _kmOut = (_kmOut) + 1),
                      onEdit: _editKmOut,
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      label: 'CASH - Gas / Energia',
                      value: RideFormatters.formatCurrency(_cashSpent),
                      onDecrement: () => setState(() {
                        final double next = _cashSpent - 1;
                        _cashSpent = next < 0 ? 0 : next;
                      }),
                      onIncrement: () => setState(() => _cashSpent = (() => _cashSpent + 1)()),
                      onEdit: _editCash,
                    ),
                    const SizedBox(height: 12),
                    _DateFieldCard(
                      label: 'Dia do Passeio',
                      value: RideFormatters.formatDateLabel(_date),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      onPressed: _busy ? null : _confirmClose,
                      child: Text(
                        _busy ? 'Encerrando...' : 'CONFIRMAR FECHAMENTO',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Voltar',
              onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
              icon: const BackButtonIcon(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Encerrar ${widget.report.sku}',
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resumo do report em curso (somente leitura) exibido no topo da tela.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.report});

  final TourInProgressModel report;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Passeio ${report.sku}',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _row(context, 'Data', RideFormatters.formatDateLabel(report.date)),
          _row(context, 'KM IN', RideFormatters.formatKm(report.kmIn)),
          _row(context, 'KM OUT (atual)', RideFormatters.formatKm(report.kmOut)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão de campo editável com stepper (+/-) e edição por prompt.
class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Diminuir',
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                value,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Aumentar',
            onPressed: onIncrement,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

/// Cartão de campo de data (toque abre o date picker).
class _DateFieldCard extends StatelessWidget {
  const _DateFieldCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
