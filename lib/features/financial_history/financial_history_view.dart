import 'package:flutter/material.dart';

import 'controller/financial_history_controller.dart';
import 'data/financial_history_repository.dart';
import 'widgets/action_buttons.dart';
import 'widgets/form_fields.dart';
import 'widgets/notes_field.dart';
import 'widgets/platforms_section.dart';
import 'widgets/quick_options_row.dart';
import 'widgets/ride_dialogs.dart';
import 'widgets/ride_header.dart';
import 'widgets/terms_legend.dart';
import 'widgets/top_data_grid.dart';

/// Tela de cadastro/edicao de passeio — skeleton M3 responsivo.
class FinancialHistoryView extends StatefulWidget {
  const FinancialHistoryView({super.key});

  @override
  State<FinancialHistoryView> createState() => _FinancialHistoryViewState();
}

// Inicio da classe _FinancialHistoryViewState ########################################
// Essa é a view principal da tela de histórico financeiro.
// Ela é um StatefulWidget que mantém o estado do formulário e interage
// com o FinancialHistoryController para gerenciar os dados do passeio.
// A view é composta por várias seções, incluindo campos de entrada para data,
// quilometragem, gastos em dinheiro, hodômetro, imagens e notas,
// além de botões para salvar, adicionar plataformas e excluir o passeio.
//
// Os widgets de UI foram extraídos para `widgets/` (header, campos, grelha,
// plataformas, opções rápidas, notas, botões, legenda e diálogos) — este arquivo
// concentra somente estado, handlers, diálogos invocados e a composição do layout.
class _FinancialHistoryViewState extends State<FinancialHistoryView> {
  static const List<String> _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  // Controller (application layer): dono do FinancialHistoryModel e da persistência.
  late final FinancialHistoryController _financialHistoryController;

  // INÍCIO das variáveis de estado local da view. #######################################
  // Aqui começa o estado local da view (formulário) — será sincronizado com o controller.
  // Essas variáveis representam os campos do formulário e são atualizadas pelo usuário.
  /// Data do passeio (inicia numa data mock de dia de trabalho).
  DateTime _rideDate = DateTime(2016, 7, 16);
  int? _kmIn;
  int? _kmOut;
  double? _cashSpent;
  bool _hodo2IsZero = true;
  int? _hodo2Number;
  bool _hasImages = true;
  bool _isFinished = false;
  // FIM das variáveis de estado local da view. ##########################################

  final TextEditingController _notesController = TextEditingController(
    text: 'USANDO ABASTECIMENTO DO DIA / PASSEIO ANTERIOR NESSE MOMENTO',
  );

  @override
  void initState() {
    super.initState();
    _financialHistoryController = FinancialHistoryController(
      repository: FinancialHistoryRepository(),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _financialHistoryController.dispose();
    super.dispose();
  }

  String get _rideDateLabel =>
      '${_rideDate.day} ${_monthNames[_rideDate.month - 1]} ${_rideDate.year}';

  String _formatKm(int? value) {
    if (value == null) return 'NONE';
    final String digits = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final int remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
    }
    return buffer.toString();
  }

  String get _cashLabel => _cashSpent == null
      ? 'NONE'
      : '€ ${_cashSpent!.toStringAsFixed(2).replaceAll('.', ',')}';

  int _nonNegative(int value) => value < 0 ? 0 : value;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickRideDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _rideDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _rideDate = picked);
  }

  Future<void> _editKmIn() async {
    final double? typed = await promptNumber(
      context,
      'KM - IN',
      _kmIn?.toDouble(),
    );
    if (typed != null && mounted)
      setState(() => _kmIn = _nonNegative(typed.round()));
  }

  Future<void> _editKmOut() async {
    final double? typed = await promptNumber(
      context,
      'KM - OUT',
      _kmOut?.toDouble(),
    );
    if (typed != null && mounted)
      setState(() => _kmOut = _nonNegative(typed.round()));
  }

  Future<void> _editCash() async {
    final double? typed = await promptNumber(
      context,
      'CASH - Gas / Energia',
      _cashSpent,
    );
    if (typed != null && mounted)
      setState(() => _cashSpent = typed < 0 ? 0 : typed);
  }

  Future<void> _editHodo2() async {
    final double? typed = await promptNumber(
      context,
      'Hodo-2 - NUMBER',
      _hodo2Number?.toDouble(),
    );
    if (typed != null && mounted) {
      setState(() => _hodo2Number = _nonNegative(typed.round()));
    }
  }

  void _actionSaveRide() {
    FocusScope.of(context).unfocus();
    if (_financialHistoryController.busy) return;
    _syncTempControllerFromState();
    debugPrint(
      '[SAVE][view] formulário → data=$_rideDate, kmIn=$_kmIn, '
      'kmOut=$_kmOut, cash=$_cashSpent, hodo2IsZero=$_hodo2IsZero, '
      'hodo2=$_hodo2Number, hasImages=$_hasImages, isFinished=$_isFinished',
    );
    _financialHistoryController
        .save()
        .then((_) {
          if (!mounted) return;
          // Reflete o SKU gerado para reports novos no header.
          setState(() {});
          _showSnack(
            'Passeio salvo com sucesso (${_financialHistoryController.report.sku}).',
          );
        })
        .catchError((Object error) {
          if (!mounted) return;
          final String message = error is FinancialHistoryValidationException
              ? error.message
              : _financialHistoryController.lastError ??
                    'Erro ao salvar o passeio.';
          _showSnack(message);
        });
  }

  /// Copia o estado atual do formulário para o FinancialHistoryModel do controller.
  /// Ponte temporária: nas próximas etapas a view passará a observar o
  /// controller diretamente e este sync deixa de existir.
  void _syncTempControllerFromState() {
    _financialHistoryController
      ..setDate(_rideDate)
      ..setCashSpent(_cashSpent ?? 0)
      ..setHodo2IsZero(_hodo2IsZero)
      ..setHasImages(_hasImages)
      ..setIsFinished(_isFinished)
      ..setNotes(_notesController.text);
    final int? kmIn = _kmIn;
    if (kmIn != null) _financialHistoryController.setKmIn(kmIn);
    final int? kmOut = _kmOut;
    if (kmOut != null) _financialHistoryController.setKmOut(kmOut);
    final int? hodo2Number = _hodo2Number;
    if (hodo2Number != null)
      _financialHistoryController.setHodo2Number(hodo2Number);
  }

  Future<void> _confirmDeleteReport() async {
    final bool? confirmed = await confirmDeleteReport(context);
    if (confirmed == true && mounted) _showSnack('Report excluído (mock).');
  }

  // ─── Colunas da grelha superior ──────────────────────────────────────────
  // Montam as colunas esquerda e direita dos próximos campos extraídos
  // (FieldSlot/DateField/StepperField/BinaryField). Como leem estado local e
  // formatadores da view, permanecem aqui em vez de virar widgets avulsos.
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldSlot(
          label: 'DIA do PASSEIO',
          child: DateField(value: _rideDateLabel, onPick: _pickRideDate),
        ),
        const SizedBox(height: 12),
        FieldSlot(
          label: 'KM - IN',
          child: StepperField(
            value: _formatKm(_kmIn),
            semanticLabel: 'quilometragem inicial',
            onDecrement: () =>
                setState(() => _kmIn = _nonNegative((_kmIn ?? 0) - 1)),
            onIncrement: () => setState(() => _kmIn = (_kmIn ?? 0) + 1),
            onEdit: _editKmIn,
          ),
        ),
        const SizedBox(height: 12),
        FieldSlot(
          label: 'Hodo-2 - is ZERO?',
          child: BinaryField(
            value: _hodo2IsZero,
            onChanged: (bool value) => setState(() => _hodo2IsZero = value),
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldSlot(
          label: 'CASH - Gas / Energia',
          child: StepperField(
            value: _cashLabel,
            semanticLabel: 'valor de combustível/energia',
            onDecrement: () => setState(() {
              final double next = (_cashSpent ?? 0) - 1;
              _cashSpent = next < 0 ? 0 : next;
            }),
            onIncrement: () =>
                setState(() => _cashSpent = (_cashSpent ?? 0) + 1),
            onEdit: _editCash,
          ),
        ),
        const SizedBox(height: 12),
        FieldSlot(
          label: 'KM - OUT',
          child: StepperField(
            value: _formatKm(_kmOut),
            semanticLabel: 'quilometragem final',
            onDecrement: () => setState(
              () => _kmOut = _nonNegative((_kmOut ?? _kmIn ?? 0) - 1),
            ),
            onIncrement: () =>
                setState(() => _kmOut = (_kmOut ?? _kmIn ?? 0) + 1),
            onEdit: _editKmOut,
          ),
        ),
        const SizedBox(height: 12),
        FieldSlot(
          label: 'Hodo-2 - NUMBER',
          child: StepperField(
            value: _formatKm(_hodo2Number),
            semanticLabel: 'hodômetro 2',
            onDecrement: () => setState(
              () => _hodo2Number = _nonNegative((_hodo2Number ?? 0) - 1),
            ),
            onIncrement: () =>
                setState(() => _hodo2Number = (_hodo2Number ?? 0) + 1),
            onEdit: _editHodo2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header
            RideHeader(
              rideSku: _financialHistoryController.report.sku,
              isRideInProgress: !_isFinished,
            ),
            Divider(color: colorScheme.outlineVariant, height: 1),
            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Grelha de 3 colunas superiores
                    TopDataGrid(
                      leftColumn: _buildLeftColumn(),
                      rightColumn: _buildRightColumn(),
                    ),
                    const SizedBox(height: 26),
                    // 3. Secção plataformas base
                    PlatformsSection(
                      onAddPlatform: () =>
                          _showSnack('Adicionar plataforma — em breve (mock).'),
                    ),
                    const SizedBox(height: 26),
                    // 4. Linha de opções rápidas
                    QuickOptionsRow(
                      hasImages: _hasImages,
                      isFinished: _isFinished,
                      onHasImagesChanged: (bool value) =>
                          setState(() => _hasImages = value),
                      onIsFinishedChanged: (bool value) =>
                          setState(() => _isFinished = value),
                      onAddPlatform: () =>
                          _showSnack('Adicionar plataforma — em breve (mock).'),
                    ),
                    const SizedBox(height: 26),
                    // 5. Campo de notas
                    NotesField(controller: _notesController),
                    const SizedBox(height: 26),
                    // 6. Footer — botão salvar
                    SaveButton(onPressed: _actionSaveRide),
                    const SizedBox(height: 20),
                    // 7. Footer — botão combustível (forma de pagamento)
                    FuelPaymentButton(
                      onPressed: () =>
                          _showSnack('Forma de pagamento — em breve (mock).'),
                    ),
                    const SizedBox(height: 20),
                    // 8. Footer — botão para adicionar imagens
                    AddImagesButton(
                      onPressed: () =>
                          _showSnack('Imagens/anexos — em breve (mock).'),
                    ),
                    const SizedBox(height: 20),
                    // 9. Footer — botão para gastos extras/alimentacao
                    ExtraExpensesButton(
                      onPressed: () =>
                          _showSnack('Gastos extras — em breve (mock).'),
                    ),
                    const SizedBox(height: 20),
                    // 10. Legenda de termos abreviados/ingles
                    const TermsLegendSection(),
                    const SizedBox(height: 20),
                    // 11. Footer — botao de exclusao do report/passeio
                    DeleteRideReportButton(onPressed: _confirmDeleteReport),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fim da classe _FinancialHistoryViewState ###########################################
