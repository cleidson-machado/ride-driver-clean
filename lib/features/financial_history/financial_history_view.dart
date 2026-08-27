import 'package:flutter/material.dart';

import '../../app/di/service_locator.dart';
import '../../app/helper/ride_formatters.dart';
import '../tour_in_progress/tour_in_progress_view.dart';
import 'financial_history_controller.dart';
import 'domain/financial_history_platform_model.dart';
import 'domain/platform_model.dart';
import 'widgets/action_buttons.dart';
import 'widgets/form_fields.dart';
import 'widgets/notes_field.dart';
import 'widgets/platforms_section.dart';
import 'widgets/quick_options_row.dart';
import 'widgets/ride_dialogs.dart';
import 'widgets/ride_header.dart';
import 'widgets/terms_legend.dart';
import 'widgets/top_data_grid.dart';

class FinancialHistoryView extends StatefulWidget {
  const FinancialHistoryView({super.key, this.reportId});

  final String? reportId;

  @override
  State<FinancialHistoryView> createState() => _FinancialHistoryViewState();
}

// Inicio da classe _FinancialHistoryViewState ########################################
class _FinancialHistoryViewState extends State<FinancialHistoryView> {

  late final FinancialHistoryController _controller;

  // INÍCIO das variáveis de estado local da view. #######################################
  DateTime _rideDate = DateTime.now();
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
    _controller = getIt<FinancialHistoryController>();
    _controller.ensureDefaultPlatforms();
    final String? reportId = widget.reportId;
    
    // START do Modo edição: carrega o report existente e preenche o formulário.
    if (reportId != null) {
      _loadReportForEdit(reportId); 
    }
    //END do Modo edição: carrega o report existente e preenche o formulário.
  }

  Future<void> _loadReportForEdit(String id) async {
    final bool loaded = await _controller.load(id);
    if (!mounted) return;
    if (!loaded) {
      _showSnack(_controller.lastError ?? 'Não foi possível carregar o passeio.');
      return;
    }
    final report = _controller.report;
    setState(() {
      _rideDate = report.date;
      _kmIn = report.kmIn;
      _kmOut = report.kmOut;
      _cashSpent = report.cashSpent;
      _hodo2IsZero = report.hodo2IsZero;
      _hodo2Number = report.hodo2Number;
      _hasImages = report.hasImages;
      _isFinished = report.isFinished;
      _notesController.text = report.notes;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _controller.dispose();
    super.dispose();
  }

  String get _rideDateLabel => RideFormatters.formatDateLabel(_rideDate);

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
    final double? typed = await showNumberPromptDialog(
      context,
      'KM - IN',
      _kmIn?.toDouble(),
    );
    if (typed != null && mounted) {
      setState(() => _kmIn = _nonNegative(typed.round()));
    }
  }

  Future<void> _editKmOut() async {
    final double? typed = await showNumberPromptDialog(
      context,
      'KM - OUT',
      _kmOut?.toDouble(),
    );
    if (typed != null && mounted) {
      setState(() => _kmOut = _nonNegative(typed.round()));
    }
  }

  Future<void> _editCash() async {
    final double? typed = await showNumberPromptDialog(
      context,
      'CASH - Gas / Energia',
      _cashSpent,
    );
    if (typed != null && mounted) {
      setState(() => _cashSpent = typed < 0 ? 0 : typed);
    }
  }

  Future<void> _editHodo2() async {
    final double? typed = await showNumberPromptDialog(
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
    if (_controller.busy) return;
    _syncTempControllerFromState();
    debugPrint(
      '[SAVE][view] formulário → data=$_rideDate, kmIn=$_kmIn, '
      'kmOut=$_kmOut, cash=$_cashSpent, hodo2IsZero=$_hodo2IsZero, '
      'hodo2=$_hodo2Number, hasImages=$_hasImages, isFinished=$_isFinished',
    );
    _controller
        .save()
        .then((_) {
          if (!mounted) return;
          // Reflete o SKU gerado para reports novos no header.
          setState(() {});
          _showSnack('Passeio salvo com sucesso (${_controller.report.sku}).');
          // Parte 4: report recém-criado (novo cadastro) → redireciona para a
          // TourInProgressView passando o id, para o card de "em curso".
          if (widget.reportId == null) {
            _redirectToTourInProgress(_controller.report.id);
          } else {
            // Em modo edição, volta para a tela anterior.
            Navigator.of(context).maybePop();
          }
        })
        .catchError((Object error) {
          if (!mounted) return;
          final String message = error is FinancialHistoryValidationException
              ? error.message
              : _controller.lastError ?? 'Erro ao salvar o passeio.';
          _showSnack(message);
        });
  }

  /// Navega para a tela de passeio em curso, exibindo o report ([reportId])
  /// recém-criado no card de "em curso" (trocando a rota atual pelo
  /// TourInProgressView — a volta vai para a Home).
  void _redirectToTourInProgress(String reportId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TourInProgressView(reportId: reportId),
      ),
    );
  }

  /// Copia o estado atual do formulário para o FinancialHistoryModel do controller.
  /// Ponte temporária: nas próximas etapas a view passará a observar o
  /// controller diretamente e este sync deixa de existir.
  void _syncTempControllerFromState() {
    _controller
      ..setDate(_rideDate)
      ..setCashSpent(_cashSpent ?? 0)
      ..setHodo2IsZero(_hodo2IsZero)
      ..setHasImages(_hasImages)
      ..setIsFinished(_isFinished)
      ..setNotes(_notesController.text);
    final int? kmIn = _kmIn;
    if (kmIn != null) _controller.setKmIn(kmIn);
    final int? kmOut = _kmOut;
    if (kmOut != null) _controller.setKmOut(kmOut);
    final int? hodo2Number = _hodo2Number;
    if (hodo2Number != null) {
      _controller.setHodo2Number(hodo2Number);
    }
  }

  Future<void> _handleDeleteReportRequest() async {
    final bool? confirmed = await showDeleteReportDialog(context);
    if (confirmed == true && mounted) _showSnack('Report excluído (mock).');
  }

  // ─── Fluxo de plataformas ────────────────────────────────────────────────

  /// Abre o seletor de plataformas (digitação livre + sugestões do catálogo) e
  /// cria o vínculo no report. Nunca bloqueia quando o catálogo está esgotado.
  Future<void> _handleAddPlatform() async {
    // Limite de exibição do carrossel: não permite vincular além de 10.
    if (_controller.report.platforms.length >= FinancialHistoryController.maxPlatforms) {
      if (mounted) {
        _showSnack(
          'Limite de ${FinancialHistoryController.maxPlatforms} plataformas '
          'por report atingido.',
        );
      }
      return;
    }
    final List<PlatformModel> available = await _controller
        .getAvailablePlatforms();
    if (!mounted) return;
    final result = await showPlatformPickerDialog(
      context,
      available,
    );
    if (!mounted) return;
    if (result == null) return;
    final AddPlatformOutcome outcome = await _controller.addPlatform(
      name: result.name,
      dailyEarnings: result.dailyEarnings,
      dailyTripCount: result.dailyTripCount,
    );
    if (!mounted) return;
    final String message = switch (outcome) {
      AddPlatformOutcome.success => 'Plataforma "${result.name.trim()}" '
          'adicionada.',
      AddPlatformOutcome.duplicate =>
        'A plataforma "${result.name.trim()}" já está neste report.',
      AddPlatformOutcome.maxReached =>
        'Limite de ${FinancialHistoryController.maxPlatforms} plataformas '
            'por report atingido.',
      AddPlatformOutcome.emptyName => 'Informe o nome da plataforma.',
    };
    _showSnack(message);
  }

  /// Abre o diálogo de edição/remoção de uma plataforma existente.
  Future<void> _handleEditPlatform(
    FinancialHistoryPlatformModel platform,
  ) async {
    final PlatformEditResult? result = await showPlatformEditDialog(
      context,
      platform,
    );
    if (result == null || !mounted) return;

    if (result.scope != PlatformRemovalScope.none) {
      // Remoção com escopo explícito: apenas do report ou também do catálogo.
      final RemovePlatformOutcome outcome = await _controller.removePlatform(
        platform.id,
        fromCatalog: result.scope == PlatformRemovalScope.fromCatalog,
      );
      if (!mounted) return;
      final String message = switch (outcome) {
        RemovePlatformOutcome.removedFromReport =>
          'Plataforma ${platform.name} removida deste report.',
        RemovePlatformOutcome.removedFromReportAndCatalog =>
          'Plataforma ${platform.name} removida deste report e '
              'excluída do catálogo.',
        RemovePlatformOutcome.notFound => 'Plataforma não encontrada.',
      };
      _showSnack(message);
      return;
    }

    final UpdatePlatformOutcome outcome = await _controller.updatePlatform(
      platform.id,
      name: result.name,
      dailyEarnings: result.dailyEarnings,
      dailyTripCount: result.dailyTripCount,
    );
    if (!mounted) return;
    final String message = switch (outcome) {
      UpdatePlatformOutcome.success => 'Plataforma "${result.name.trim()}" '
          'atualizada.',
      UpdatePlatformOutcome.duplicate =>
        'A plataforma "${result.name.trim()}" já existe neste report.',
      UpdatePlatformOutcome.notFound => 'Plataforma não encontrada.',
      UpdatePlatformOutcome.emptyName => 'Informe o nome da plataforma.',
    };
    _showSnack(message);
  }

  // ─── Colunas da grelha superior ──────────────────────────────────────────
  // Montam as colunas esquerda e direita dos próximos campos extraídos
  // (FieldSlotWidget/DateFieldWidget/StepperFieldWidget/BinaryFieldWidget). Como leem estado local e
  // formatadores da view, permanecem aqui em vez de virar widgets avulsos.
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldSlotWidget(
          label: 'DIA do PASSEIO',
          child: DateFieldWidget(value: _rideDateLabel, onPick: _pickRideDate),
        ),
        const SizedBox(height: 12),
        FieldSlotWidget(
          label: 'KM - IN',
          child: StepperFieldWidget(
            value: RideFormatters.formatKm(_kmIn),
            semanticLabel: 'quilometragem inicial',
            onDecrement: () =>
                setState(() => _kmIn = _nonNegative((_kmIn ?? 0) - 1)),
            onIncrement: () => setState(() => _kmIn = (_kmIn ?? 0) + 1),
            onEdit: _editKmIn,
          ),
        ),
        const SizedBox(height: 12),
        FieldSlotWidget(
          label: 'Hodo-2 - is ZERO?',
          child: BinaryFieldWidget(
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
        FieldSlotWidget(
          label: 'CASH - Gas / Energia',
          child: StepperFieldWidget(
            value: RideFormatters.formatCurrency(_cashSpent),
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
        FieldSlotWidget(
          label: 'KM - OUT',
          child: StepperFieldWidget(
            value: RideFormatters.formatKm(_kmOut),
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
        FieldSlotWidget(
          label: 'Hodo-2 - NUMBER',
          child: StepperFieldWidget(
            value: RideFormatters.formatKm(_hodo2Number),
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
            RideHeaderWidget( // ######################################################################## 1. Header
              rideSku: _controller.report.sku,
              isRideInProgress: !_isFinished,
              isNewReport: widget.reportId == null,
              showEditBadge: widget.reportId != null,
            ),
            Divider(color: colorScheme.outlineVariant, height: 1),
            Expanded( // ############################################################################### Scrollable body
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TopDataGridWidget( // ############################################################### 2. Grelha de 3 colunas superiores
                      leftColumn: _buildLeftColumn(),
                      rightColumn: _buildRightColumn(),
                    ),
                    const SizedBox(height: 26),

                    ListenableBuilder(
                      listenable: _controller,
                      builder: (BuildContext context, Widget? child) {
                        return PlatformsSectionWidget(
                          platforms: _controller.report.platforms,
                          onEditPlatform: _handleEditPlatform,
                          onAddPlatform: _handleAddPlatform,
                        );
                      },
                    ),
                    const SizedBox(height: 26),

                    QuickOptionsRowWidget( // ########################################################### 4. Linha de opções rápidas
                      hasImages: _hasImages,
                      isFinished: _isFinished,
                      onHasImagesChanged: (bool value) =>
                          setState(() => _hasImages = value),
                      onIsFinishedChanged: (bool value) =>
                          setState(() => _isFinished = value),
                      onAddPlatform: _handleAddPlatform,
                    ),
                    const SizedBox(height: 26),

                    NotesFieldWidget( // ############################################################### 5. Campo de notas
                      controller: _notesController,
                    ),
                    const SizedBox(height: 26),

                    SaveButtonWidget( // ############################################################## 6. Footer — botão salvar
                      onPressed: _actionSaveRide,
                    ),
                    const SizedBox(height: 20),

                    FuelPaymentButtonWidget( // ####################################################### 7. Footer — botão combustível (forma de pagamento)
                      onPressed: () =>
                          _showSnack('Forma de pagamento — em breve (mock).'),
                    ),
                    const SizedBox(height: 20),

                    AddImagesButtonWidget( // ########################################################## 8. Footer — botão para adicionar imagens/anexos
                      onPressed: () =>
                          _showSnack('Imagens/anexos — em breve (mock).'),
                    ),
                    const SizedBox(height: 20),

                    ExtraExpensesButtonWidget( // ###################################################### 9. Footer — botão para gastos extras/alimentacao
                      onPressed: () =>
                          _showSnack('Gastos extras — em breve (mock).'),
                    ),
                    const SizedBox(height: 20),

                    const TermsLegendSectionWidget(), // ############################################### 10. Legenda de termos abreviados/ingles
                    const SizedBox(height: 20),

                    DeleteRideReportButtonWidget(
                      onPressed: _handleDeleteReportRequest,
                    ), // ################ 11. Footer — botao de exclusao do report/passeio
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
