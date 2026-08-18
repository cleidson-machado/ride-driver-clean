import 'package:flutter/material.dart';

import 'controller/financial_history_controller.dart';
import 'data/local_ride_report_repository.dart';

/// Tela de cadastro/edicao de passeio — skeleton M3 responsivo.
class FinancialHistoryView extends StatefulWidget {
	const FinancialHistoryView({super.key});

	@override
	State<FinancialHistoryView> createState() => _FinancialHistoryViewState();
}

class _FinancialHistoryViewState extends State<FinancialHistoryView> {
	static const List<String> _monthNames = [
		'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
		'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
	];

	// Controller (application layer): dono do RideReport e da persistência.
	late final FinancialHistoryController _controller;

	DateTime _rideDate = DateTime(2016, 7, 16);
	int _kmIn = 44762;
	int? _kmOut;
	double? _cashSpent;
	bool _hodo2IsZero = true;
	int? _hodo2Number;
	bool _hasImages = true;
	bool _isFinished = false;
	final TextEditingController _notesController = TextEditingController(
		text: 'USANDO ABASTECIMENTO DO DIA / PASSEIO ANTERIOR NESSE MOMENTO',
	);

	@override
	void initState() {
		super.initState();
		_controller = FinancialHistoryController(
			repository: LocalRideReportRepository(),
		);
	}

	@override
	void dispose() {
		_notesController.dispose();
		_controller.dispose();
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

	Future<double?> _promptNumber(String title, double? current) {
		final TextEditingController controller = TextEditingController(
			text: current == null
					? ''
					: current == current.roundToDouble()
							? current.round().toString()
							: current.toStringAsFixed(2),
		);
		return showDialog<double>(
			context: context,
			builder: (BuildContext dialogContext) => AlertDialog(
				title: Text(title),
				content: TextField(
					controller: controller,
					autofocus: true,
					keyboardType: const TextInputType.numberWithOptions(decimal: true),
					decoration: const InputDecoration(hintText: 'Digite o valor'),
					onSubmitted: (String text) => Navigator.of(dialogContext)
							.pop(double.tryParse(text.trim().replaceAll(',', '.'))),
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(dialogContext).pop(),
						child: const Text('CANCELAR'),
					),
					FilledButton(
						style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
						onPressed: () => Navigator.of(dialogContext).pop(
							double.tryParse(controller.text.trim().replaceAll(',', '.')),
						),
						child: const Text('CONFIRMAR'),
					),
				],
			),
		);
	}

	Future<void> _editKmIn() async {
		final double? typed = await _promptNumber('KM - IN', _kmIn.toDouble());
		if (typed != null && mounted) setState(() => _kmIn = _nonNegative(typed.round()));
	}

	Future<void> _editKmOut() async {
		final double? typed = await _promptNumber('KM - OUT', _kmOut?.toDouble());
		if (typed != null && mounted) setState(() => _kmOut = _nonNegative(typed.round()));
	}

	Future<void> _editCash() async {
		final double? typed = await _promptNumber('CASH - Gas / Energia', _cashSpent);
		if (typed != null && mounted) setState(() => _cashSpent = typed < 0 ? 0 : typed);
	}

	Future<void> _editHodo2() async {
		final double? typed =
				await _promptNumber('Hodo-2 - NUMBER', _hodo2Number?.toDouble());
		if (typed != null && mounted) {
			setState(() => _hodo2Number = _nonNegative(typed.round()));
		}
	}

	void _saveRide() {
		FocusScope.of(context).unfocus();
		if (_controller.busy) return;
		_syncControllerFromState();
		debugPrint(
			'[SAVE][view] formulário → data=$_rideDate, kmIn=$_kmIn, '
			'kmOut=$_kmOut, cash=$_cashSpent, hodo2IsZero=$_hodo2IsZero, '
			'hodo2=$_hodo2Number, hasImages=$_hasImages, isFinished=$_isFinished',
		);
		_controller.save().then((_) {
			if (!mounted) return;
			// Reflete o SKU gerado para reports novos no header.
			setState(() {});
			_showSnack('Passeio salvo com sucesso (${_controller.report.sku}).');
		}).catchError((Object error) {
			if (!mounted) return;
			final String message = error is RideReportValidationException
					? error.message
					: _controller.lastError ?? 'Erro ao salvar o passeio.';
			_showSnack(message);
		});
	}

	/// Copia o estado atual do formulário para o RideReport do controller.
	///
	/// Ponte temporária: nas próximas etapas a view passará a observar o
	/// controller diretamente e este sync deixa de existir.
	void _syncControllerFromState() {
		_controller
			..setDate(_rideDate)
			..setKmIn(_kmIn)
			..setCashSpent(_cashSpent ?? 0)
			..setHodo2IsZero(_hodo2IsZero)
			..setHasImages(_hasImages)
			..setIsFinished(_isFinished)
			..setNotes(_notesController.text);
		final int? kmOut = _kmOut;
		if (kmOut != null) _controller.setKmOut(kmOut);
		final int? hodo2Number = _hodo2Number;
		if (hodo2Number != null) _controller.setHodo2Number(hodo2Number);
	}

	Future<void> _confirmDeleteReport() async {
		final bool? confirmed = await showDialog<bool>(
			context: context,
			builder: (BuildContext dialogContext) => AlertDialog(
				title: const Text('Excluir report?'),
				content: const Text(
					'Essa ação remove o report/passeio atual. Deseja continuar?',
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(dialogContext).pop(false),
						child: const Text('CANCELAR'),
					),
					FilledButton(
						style: FilledButton.styleFrom(
							minimumSize: const Size(64, 40),
							backgroundColor: Theme.of(dialogContext).colorScheme.error,
							foregroundColor: Theme.of(dialogContext).colorScheme.onError,
						),
						onPressed: () => Navigator.of(dialogContext).pop(true),
						child: const Text('EXCLUIR'),
					),
				],
			),
		);
		if (confirmed == true && mounted) _showSnack('Report excluído (mock).');
	}

	Widget _buildLeftColumn() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				_FieldSlot(
					label: 'DIA do PASSEIO',
					child: _DateField(value: _rideDateLabel, onPick: _pickRideDate),
				),
				const SizedBox(height: 12),
				_FieldSlot(
					label: 'KM - IN',
					child: _StepperField(
						value: _formatKm(_kmIn),
						semanticLabel: 'quilometragem inicial',
						onDecrement: () => setState(() => _kmIn = _nonNegative(_kmIn - 1)),
						onIncrement: () => setState(() => _kmIn = _kmIn + 1),
						onEdit: _editKmIn,
					),
				),
				const SizedBox(height: 12),
				_FieldSlot(
					label: 'Hodo-2 - is ZERO?',
					child: _BinaryField(
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
				_FieldSlot(
					label: 'CASH - Gas / Energia',
					child: _StepperField(
						value: _cashLabel,
						semanticLabel: 'valor de combustível/energia',
						onDecrement: () => setState(() {
							final double next = (_cashSpent ?? 0) - 1;
							_cashSpent = next < 0 ? 0 : next;
						}),
						onIncrement: () => setState(() => _cashSpent = (_cashSpent ?? 0) + 1),
						onEdit: _editCash,
					),
				),
				const SizedBox(height: 12),
				_FieldSlot(
					label: 'KM - OUT',
					child: _StepperField(
						value: _formatKm(_kmOut),
						semanticLabel: 'quilometragem final',
						onDecrement: () =>
								setState(() => _kmOut = _nonNegative((_kmOut ?? _kmIn) - 1)),
						onIncrement: () => setState(() => _kmOut = (_kmOut ?? _kmIn) + 1),
						onEdit: _editKmOut,
					),
				),
				const SizedBox(height: 12),
				_FieldSlot(
					label: 'Hodo-2 - NUMBER',
					child: _StepperField(
						value: _formatKm(_hodo2Number),
						semanticLabel: 'hodômetro 2',
						onDecrement: () =>
								setState(() => _hodo2Number = _nonNegative((_hodo2Number ?? 0) - 1)),
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
						_Header(
							rideSku: _controller.report.sku,
							isRideInProgress: !_isFinished,
						),
						Divider(color: colorScheme.outlineVariant, height: 1),
						// Scrollable body
						Expanded(
							child: SingleChildScrollView(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [
										// 2. Grelha de 3 colunas superiores
										_TopDataGrid(
											leftColumn: _buildLeftColumn(),
											rightColumn: _buildRightColumn(),
										),
										const SizedBox(height: 26),
										// 3. Secção plataformas base
										_PlatformsSection(
											onAddPlatform: () =>
													_showSnack('Adicionar plataforma — em breve (mock).'),
										),
										const SizedBox(height: 26),
										// 4. Linha de opções rápidas
										_QuickOptionsRow(
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
										_NotesField(controller: _notesController),
										const SizedBox(height: 26 ),
										// 6. Footer — botão salvar
										_SaveButton(onPressed: _saveRide),
										const SizedBox(height: 20),
										// 7. Footer — botão combustível (forma de pagamento)
										_FuelPaymentButton(
											onPressed: () =>
													_showSnack('Forma de pagamento — em breve (mock).'),
										),
										const SizedBox(height: 20),
										// 8. Footer — botão para adicionar imagens
										_AddImagesButton(
											onPressed: () =>
													_showSnack('Imagens/anexos — em breve (mock).'),
										),
										const SizedBox(height: 20),
										// 9. Footer — botão para gastos extras/alimentacao
										_ExtraExpensesButton(
											onPressed: () =>
													_showSnack('Gastos extras — em breve (mock).'),
										),
										const SizedBox(height: 20),
										// 10. Legenda de termos abreviados/ingles
										const _TermsLegendSection(),
										const SizedBox(height: 20),
										// 11. Footer — botao de exclusao do report/passeio
										_DeleteRideReportButton(onPressed: _confirmDeleteReport),
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

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
	const _Header({required this.rideSku, required this.isRideInProgress});

	final String rideSku;
	final bool isRideInProgress;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
									'Report: $rideSku',
									textAlign: TextAlign.center,
									style: textTheme.titleSmall?.copyWith(
										fontWeight: FontWeight.w800,
										color: colorScheme.onSurface,
									),
								),
								const SizedBox(width: 8),
								_RideStatusPill(isInProgress: isRideInProgress),
							],
						),
					),
				],
			),
		);
	}
}

class _RideStatusPill extends StatelessWidget {
	const _RideStatusPill({required this.isInProgress});

	final bool isInProgress;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		final Color backgroundColor = isInProgress ? colorScheme.tertiaryContainer : colorScheme.primaryContainer;
		final Color foregroundColor = isInProgress ? colorScheme.onTertiaryContainer : colorScheme.onPrimaryContainer;
		final String label = isInProgress ? 'EM CURSO' : 'CONCLUIDO';

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

// ─── Bloco superior — grelha 3 colunas ───────────────────────────────────────

class _TopDataGrid extends StatelessWidget {
	const _TopDataGrid({required this.leftColumn, required this.rightColumn});

	final Widget leftColumn;
	final Widget rightColumn;

	@override
	Widget build(BuildContext context) {
		return IntrinsicHeight(
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [

					// Coluna esquerda (flex 4)
					Expanded(flex: 4, child: leftColumn),

					const SizedBox(width: 8),
					// Coluna central (flex 1) — LUCRO

					const Expanded(flex: 1, child: _ProfitColumn()),

					const SizedBox(width: 8),
					// Coluna direita (flex 4)
          
					Expanded(flex: 4, child: rightColumn),
				],
			),
		);
	}
}

// ─── Coluna esquerda ──────────────────────────────────────────────────────────

// (coluna esquerda agora é montada em _buildLeftColumn na própria view)

// ─── Coluna direita ───────────────────────────────────────────────────────────

// (coluna direita agora é montada em _buildRightColumn na própria view)

// ─── Coluna central — indicador LUCRO ────────────────────────────────────────

class _ProfitColumn extends StatelessWidget {
	const _ProfitColumn();

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				FittedBox(
					fit: BoxFit.scaleDown,
					child: Text(
						'L1',
						textAlign: TextAlign.center,
						style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 16),
					),
				),
				const SizedBox(height: 4),
				Expanded(
					child: Container(
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(12),
							border: Border.all(color: colorScheme.outlineVariant),
						),
						child: Column(
							children: [
								const Spacer(),
								// placeholder: barra de progresso (preenchimento inferior)
								Container(
									height: 28,
									width: double.infinity,
									decoration: BoxDecoration(
										color: colorScheme.onSurface,
										borderRadius: const BorderRadius.only(
											bottomLeft: Radius.circular(11),
											bottomRight: Radius.circular(11),
										),
									),
								),
							],
						),
					),
				),
			],
		);
	}
}

// ─── Field slot (label + input) ───────────────────────────────────────────────
// This widget is used to wrap each field with a label and the corresponding input widget.

class _FieldSlot extends StatelessWidget {
	const _FieldSlot({required this.label, required this.child});

	final String label;
	final Widget child;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					label,
					style: textTheme.labelSmall?.copyWith(
						fontWeight: FontWeight.w700,
						letterSpacing: 1.0,
						color: colorScheme.onSurfaceVariant,
					),
					overflow: TextOverflow.ellipsis,
				),
				const SizedBox(height: 4),
				child,
			],
		);
	}
}

// ─── Date row ─────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
	const _DateField({required this.value, required this.onPick});

	final String value;
	final VoidCallback onPick;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 48,
			decoration: BoxDecoration(
				color: colorScheme.surface,
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: colorScheme.outlineVariant),
			),
			child: Row(
				children: [
					Expanded(
						child: InkWell(
							onTap: onPick,
							borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
							child: Padding(
								padding: const EdgeInsets.symmetric(horizontal: 6),
								child: Align(
									alignment: Alignment.centerLeft,
									child: Text(
										value,
										style: textTheme.bodySmall,
										overflow: TextOverflow.ellipsis,
									),
								),
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outlineVariant),
					SizedBox(
						width: 46,
						child: Center(
							child: IconButton(
								tooltip: 'Selecionar data',
								onPressed: onPick,
								visualDensity: VisualDensity.compact,
								style: IconButton.styleFrom(
									backgroundColor: colorScheme.primaryContainer,
									foregroundColor: colorScheme.onPrimaryContainer,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(10),
									),
								),
								icon: const Icon(Icons.calendar_month_outlined, size: 16),
							),
						),
					),
				],
			),
		);
	}
}

// ─── Stepper row ──────────────────────────────────────────────────────────────

class _StepperField extends StatelessWidget {
	const _StepperField({
		required this.value,
		required this.semanticLabel,
		required this.onDecrement,
		required this.onIncrement,
		required this.onEdit,
	});

	final String value;
	final String semanticLabel;
	final VoidCallback onDecrement;
	final VoidCallback onIncrement;
	final VoidCallback onEdit;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 48,
			decoration: BoxDecoration(
				color: colorScheme.surface,
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: colorScheme.outlineVariant),
			),
			child: Row(
				children: [
					Expanded(
						child: Semantics(
							button: true,
							label: 'Diminuir $semanticLabel',
							child: InkWell(
								onTap: onDecrement,
								borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
								child: Center(child: Text('-', style: textTheme.titleSmall)),
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outlineVariant),
					Expanded(
						flex: 3,
						child: Semantics(
							button: true,
							label: 'Editar $semanticLabel',
							child: InkWell(
								onTap: onEdit,
								child: Center(
									child: Text(
										value,
										style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
										overflow: TextOverflow.ellipsis,
									),
								),
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outlineVariant),
					Expanded(
						child: Semantics(
							button: true,
							label: 'Aumentar $semanticLabel',
							child: InkWell(
								onTap: onIncrement,
								borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
								child: Center(child: Text('+', style: textTheme.titleSmall)),
							),
						),
					),
				],
			),
		);
	}
}

// ─── Binary row ───────────────────────────────────────────────────────────────

class _BinaryField extends StatelessWidget {
	const _BinaryField({required this.value, required this.onChanged});

	final bool value;
	final ValueChanged<bool> onChanged;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 48,
			decoration: BoxDecoration(
				color: colorScheme.surface,
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: colorScheme.outlineVariant),
			),
			child: Semantics(
				toggled: value,
				label: 'Hodômetro 2 zerado',
				child: InkWell(
					onTap: () => onChanged(!value),
					borderRadius: BorderRadius.circular(12),
					child: Row(
						children: [
							Expanded(
								child: Tooltip(
									message: 'Alternar status zerado',
									child: Icon(
										value ? Icons.radio_button_checked : Icons.circle_outlined,
										size: 18,
										color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
									),
								),
							),
							VerticalDivider(width: 1, thickness: 1, color: colorScheme.outlineVariant),
							Expanded(
								flex: 3,
								child: Center(
									child: Text(
										value ? 'YES' : 'NO',
										style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
									),
								),
							),
							VerticalDivider(width: 1, thickness: 1, color: colorScheme.outlineVariant),
							Expanded(
								child: Tooltip(
									message: 'Status alternativo',
									child: Icon(
										value ? Icons.square : Icons.square_outlined,
										size: 18,
										color: colorScheme.onSurface,
									),
								),
							),
						],
					),
				),
			),
		);
	}
}

// ─── Secção plataformas base ──────────────────────────────────────────────────

class _PlatformsSection extends StatefulWidget {
	const _PlatformsSection({required this.onAddPlatform});

	final VoidCallback onAddPlatform;

	@override
	State<_PlatformsSection> createState() => _PlatformsSectionState();
}

class _PlatformsSectionState extends State<_PlatformsSection> {
	// Dados mock — uma plataforma por página do carrossel (máx. 3).
	static const List<({String name, String totalValue, String totalRides})>
			_platforms = [
		(name: 'UBER', totalValue: '€ 55,89', totalRides: '06'),
		(name: 'BOLT', totalValue: '€ 10,09', totalRides: '06'),
		(name: 'FREENOW', totalValue: '€ 0,00', totalRides: '00'),
	];

	final PageController _pageController = PageController();
	int _currentPage = 0;

	// 2 plataformas por página do carrossel.
	int get _pageCount => (_platforms.length + 1) ~/ 2;

	@override
	void dispose() {
		_pageController.dispose();
		super.dispose();
	}

	Widget _buildCardSlot(int platformIndex) {
		if (platformIndex >= _platforms.length) {
			return _AddPlatformCard(onTap: widget.onAddPlatform);
		}
		final platform = _platforms[platformIndex];
		return _PlatformCard(
			name: platform.name,
			totalValue: platform.totalValue,
			totalRides: platform.totalRides,
		);
	}

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				Text(
					'PLATAFORMAS - UTILIZADAS',
					textAlign: TextAlign.left,
					style: textTheme.labelSmall?.copyWith(
						fontWeight: FontWeight.w700,
						letterSpacing: 1.2,
						color: colorScheme.onSurfaceVariant,
					),
				),
				const SizedBox(height: 6),
				Container(
					decoration: BoxDecoration(
						color: colorScheme.surfaceContainerHighest,
						borderRadius: BorderRadius.circular(16),
						border: Border.all(color: colorScheme.outlineVariant),
					),
					padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
					child: Column(
						children: [
							SizedBox(
								height: 190,
								child: Semantics(
									label:
											'Carrossel de plataformas, página ${_currentPage + 1} de $_pageCount',
									child: PageView.builder(
										controller: _pageController,
										itemCount: _pageCount,
										onPageChanged: (int index) =>
												setState(() => _currentPage = index),
										itemBuilder: (BuildContext context, int pageIndex) {
											final int firstIndex = pageIndex * 2;
											return Padding(
												padding: const EdgeInsets.symmetric(horizontal: 2),
												child: Row(
													crossAxisAlignment: CrossAxisAlignment.stretch,
													children: [
														Expanded(child: _buildCardSlot(firstIndex)),
														const SizedBox(width: 8),
														Expanded(child: _buildCardSlot(firstIndex + 1)),
													],
												),
											);
										},
									),
								),
							),
							const SizedBox(height: 10),
							_PageDotsIndicator(
								count: _pageCount,
								currentIndex: _currentPage,
								onDotTap: (int index) => _pageController.animateToPage(
									index,
									duration: const Duration(milliseconds: 300),
									curve: Curves.easeOutCubic,
								),
							),
						],
					),
				),
			],
		);
	}
}

// ─── Card filler — adicionar plataforma (slot vazio em página ímpar) ────────

class _AddPlatformCard extends StatelessWidget {
	const _AddPlatformCard({required this.onTap});

	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Material(
			color: colorScheme.surface,
			borderRadius: BorderRadius.circular(14),
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(14),
				child: Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(14),
						border: Border.all(color: colorScheme.outlineVariant),
					),
					padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(
								Icons.add_circle_outline,
								size: 32,
								color: colorScheme.primary,
								semanticLabel: 'Adicionar plataforma',
							),
							const SizedBox(height: 8),
							Text(
								'Sem plataforma\nneste slot',
								textAlign: TextAlign.center,
								style: textTheme.labelSmall?.copyWith(
									color: colorScheme.onSurfaceVariant,
								),
							),
							const SizedBox(height: 8),
							Text(
								'ADD - PLAT',
								textAlign: TextAlign.center,
								style: textTheme.labelMedium?.copyWith(
									fontWeight: FontWeight.w800,
									color: colorScheme.primary,
								),
							),
						],
					),
				),
			),
		);
	}
}

// ─── Indicador de páginas (dots) ─────────────────────────────────────────────

class _PageDotsIndicator extends StatelessWidget {
	const _PageDotsIndicator({
		required this.count,
		required this.currentIndex,
		required this.onDotTap,
	});

	final int count;
	final int currentIndex;
	final ValueChanged<int> onDotTap;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Row(
			mainAxisAlignment: MainAxisAlignment.center,
			children: List<Widget>.generate(count, (int index) {
				final bool isActive = index == currentIndex;
				return Semantics(
					button: true,
					selected: isActive,
					label: 'Ir para página ${index + 1}',
					child: InkWell(
						onTap: () => onDotTap(index),
						customBorder: const StadiumBorder(),
						child: Padding(
							// Área de toque confortável mantendo o dot pequeno.
							padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
							child: AnimatedContainer(
								duration: const Duration(milliseconds: 250),
								curve: Curves.easeOut,
								width: isActive ? 22 : 8,
								height: 8,
								decoration: BoxDecoration(
									color: isActive
											? colorScheme.primary
											: colorScheme.outlineVariant,
									borderRadius: BorderRadius.circular(999),
								),
							),
						),
					),
				);
			}),
		);
	}
}

class _PlatformCard extends StatelessWidget {
	const _PlatformCard({
		required this.name,
		required this.totalValue,
		required this.totalRides,
	});

	final String name;
	final String totalValue;
	final String totalRides;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Container(
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(14),
				border: Border.all(color: colorScheme.outlineVariant),
				color: colorScheme.surface,
			),
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					// Nome da plataforma
					Center(
						child: Text(
							name,
							style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
						),
					),
					const SizedBox(height: 8),
					Text('Valor total dia:', textAlign: TextAlign.center, style: textTheme.labelSmall),
					const SizedBox(height: 4),
					// placeholder valor
					Container(
						padding: const EdgeInsets.symmetric(vertical: 6),
						decoration: BoxDecoration(
							border: Border.all(color: colorScheme.outlineVariant),
							borderRadius: BorderRadius.circular(10),
						),
						child: Text(
							totalValue,
							textAlign: TextAlign.center,
							style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
						),
					),
					const SizedBox(height: 8),
					Text('Corridas total dia:', textAlign: TextAlign.center, style: textTheme.labelSmall),
					const SizedBox(height: 4),
					// placeholder corridas
					Container(
						padding: const EdgeInsets.symmetric(vertical: 6),
						decoration: BoxDecoration(
							border: Border.all(color: colorScheme.outlineVariant),
							borderRadius: BorderRadius.circular(10),
						),
						child: Text(
							totalRides,
							textAlign: TextAlign.center,
							style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
						),
					),
				],
			),
		);
	}
}

// ─── Linha de opções rápidas ──────────────────────────────────────────────────

class _QuickOptionsRow extends StatelessWidget {
	const _QuickOptionsRow({
		required this.hasImages,
		required this.isFinished,
		required this.onHasImagesChanged,
		required this.onIsFinishedChanged,
		required this.onAddPlatform,
	});

	final bool hasImages;
	final bool isFinished;
	final ValueChanged<bool> onHasImagesChanged;
	final ValueChanged<bool> onIsFinishedChanged;
	final VoidCallback onAddPlatform;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Row(
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				// COM IMAGENS?
				Expanded(
					child: InkWell(
						onTap: () => onHasImagesChanged(!hasImages),
						borderRadius: BorderRadius.circular(12),
						child: Padding(
							padding: const EdgeInsets.symmetric(vertical: 12),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.start,
								children: [
									Tooltip(
										message: 'Com imagens',
										child: Icon(
											hasImages ? Icons.check_circle : Icons.radio_button_unchecked,
											color: hasImages ? colorScheme.primary : colorScheme.outline,
											size: 22,
										),
									),
									const SizedBox(width: 4),
									Flexible(
										child: Text(
											'HAS IMAGES?',
											style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
											overflow: TextOverflow.ellipsis,
										),
									),
								],
							),
						),
					),
				),
				// Botão + PLATAFORMA (central)
				Column(
					children: [
						Text(
							'ADD - PLAT',
							style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
						),
						const SizedBox(height: 4),
						IconButton.filled(
							tooltip: 'Adicionar plataforma',
							onPressed: onAddPlatform,
							style: IconButton.styleFrom(
								backgroundColor: colorScheme.primaryContainer,
								foregroundColor: colorScheme.onPrimaryContainer,
								minimumSize: const Size(48, 48),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
							),
							icon: const Icon(Icons.add),
						),
					],
				),
				// CONCLUÍDO?
				Expanded(
					child: InkWell(
						onTap: () => onIsFinishedChanged(!isFinished),
						borderRadius: BorderRadius.circular(12),
						child: Padding(
							padding: const EdgeInsets.symmetric(vertical: 12),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.end,
								children: [
									Flexible(
										child: Text(
											'IS FINISHED?',
											style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
											overflow: TextOverflow.ellipsis,
										),
									),
									const SizedBox(width: 4),
									Tooltip(
										message: 'Concluído',
										child: Icon(
											isFinished ? Icons.check_circle : Icons.radio_button_unchecked,
											color: isFinished ? colorScheme.primary : colorScheme.outline,
											size: 22,
										),
									),
								],
							),
						),
					),
				),
			],
		);
	}
}

// ─── Campo de notas ───────────────────────────────────────────────────────────

class _NotesField extends StatelessWidget {
	const _NotesField({required this.controller});

	final TextEditingController controller;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					'Anotações / Observações',
					style: textTheme.labelMedium?.copyWith(
						fontWeight: FontWeight.w700,
						letterSpacing: 1.0,
						color: colorScheme.onSurfaceVariant,
					),
				),
				const SizedBox(height: 6),
				TextField(
					controller: controller,
					minLines: 3,
					maxLines: 5,
					textCapitalization: TextCapitalization.sentences,
					style: textTheme.bodySmall,
					decoration: InputDecoration(
						hintText: 'Escreva observações do passeio…',
						fillColor: colorScheme.surface,
						contentPadding: const EdgeInsets.all(10),
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(14),
							borderSide: BorderSide(color: colorScheme.outlineVariant),
						),
						enabledBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(14),
							borderSide: BorderSide(color: colorScheme.outlineVariant),
						),
					),
				),
			],
		);
	}
}

// ─── Footer — botão salvar ────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
	const _SaveButton({required this.onPressed});

	final VoidCallback onPressed;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return SizedBox(
			width: double.infinity,
			height: 52,
			child: FilledButton.icon(
				style: FilledButton.styleFrom(
					backgroundColor: colorScheme.primaryContainer,
					foregroundColor: colorScheme.onPrimaryContainer,
					elevation: 0,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(16),
						side: BorderSide(color: colorScheme.outlineVariant),
					),
				),
				onPressed: onPressed,
				icon: const Icon(Icons.save_rounded),
				label: const Text('SALVAR / ATUALIZAR esse PASSEIO?'),
			),
		);
	}
}

class _FuelPaymentButton extends StatelessWidget {
	const _FuelPaymentButton({required this.onPressed});

	final VoidCallback onPressed;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return SizedBox(
			width: double.infinity,
			height: 52,
			child: FilledButton.icon(
				style: FilledButton.styleFrom(
					alignment: Alignment.center,
					backgroundColor: colorScheme.secondaryContainer,
					foregroundColor: colorScheme.onSecondaryContainer,
					elevation: 0,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(16),
						side: BorderSide(color: colorScheme.outlineVariant),
					),
				),
				onPressed: onPressed,
				icon: const Icon(Icons.credit_card_rounded),
				label: const Text(
					'ADD FORMA PAGAMENTO - Gas / Energia?',
					textAlign: TextAlign.center,
				),
			),
		);
	}
}

class _AddImagesButton extends StatelessWidget {
	const _AddImagesButton({required this.onPressed});

	final VoidCallback onPressed;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return SizedBox(
			width: double.infinity,
			height: 52,
			child: FilledButton.icon(
				style: FilledButton.styleFrom(
					alignment: Alignment.center,
					backgroundColor: colorScheme.tertiaryContainer,
					foregroundColor: colorScheme.onTertiaryContainer,
					elevation: 0,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(16),
						side: BorderSide(color: colorScheme.outlineVariant),
					),
				),
				onPressed: onPressed,
				icon: const Icon(Icons.image_outlined),
				label: const Text(
					'ADD IMAGENS / ANEXOS? ',
					textAlign: TextAlign.center,
				),
			),
		);
	}
}

class _ExtraExpensesButton extends StatelessWidget {
	const _ExtraExpensesButton({required this.onPressed});

	final VoidCallback onPressed;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return SizedBox(
			width: double.infinity,
			height: 52,
			child: FilledButton.icon(
				style: FilledButton.styleFrom(
					alignment: Alignment.center,
					backgroundColor: colorScheme.surfaceContainerHigh,
					foregroundColor: colorScheme.onSurface,
					elevation: 0,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(16),
						side: BorderSide(color: colorScheme.outlineVariant),
					),
				),
				onPressed: onPressed,
				icon: const Icon(Icons.receipt_long_outlined),
				label: const Text(
					'ADD GASTOS EXTRAS / ALIMENTACAO?',
					textAlign: TextAlign.center,
				),
			),
		);
	}
}

class _DeleteRideReportButton extends StatelessWidget {
	const _DeleteRideReportButton({required this.onPressed});

	final VoidCallback onPressed;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return SizedBox(
			width: double.infinity,
			height: 52,
			child: FilledButton.icon(
				style: FilledButton.styleFrom(
					alignment: Alignment.center,
					backgroundColor: colorScheme.errorContainer,
					foregroundColor: colorScheme.onErrorContainer,
					elevation: 0,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(16),
						side: BorderSide(color: colorScheme.outlineVariant),
					),
				),
				onPressed: onPressed,
				icon: const Icon(Icons.delete_forever_rounded),
				label: const Text(
					'EXCLUIR REPORT / PASSEIO?',
					textAlign: TextAlign.center,
				),
			),
		);
	}
}

class _TermsLegendSection extends StatelessWidget {
	const _TermsLegendSection();

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				Text(
					'Legenda dos termos',
					textAlign: TextAlign.left,
					style: textTheme.labelSmall?.copyWith(
						fontWeight: FontWeight.w700,
						letterSpacing: 1.2,
						color: colorScheme.onSurfaceVariant,
					),
				),
				const SizedBox(height: 8),
				Container(
					decoration: BoxDecoration(
						color: colorScheme.surfaceContainerHighest,
						borderRadius: BorderRadius.circular(16),
						border: Border.all(color: colorScheme.outlineVariant),
					),
					padding: const EdgeInsets.all(12),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							_DictionaryRow(
								term: 'L1',
								description:
									'LUCRO simples, sem VALOR Gas/Energia do DIA!',
							),
							const SizedBox(height: 6),
							_DictionaryRow(
								term: 'KM - IN',
								description: 'Quilometragem inicial no comeco da jornada.',
							),
							const SizedBox(height: 6),
							_DictionaryRow(
								term: 'KM - OUT',
								description: 'Quilometragem final ao encerrar o dia.',
							),
							const SizedBox(height: 6),
							_DictionaryRow(
								term: 'PLUS - PL',
								description: 'Adiciona novas plataformas e afins.',
							),
							const SizedBox(height: 6),
							_DictionaryRow(
								term: 'HAS IMAGES?',
								description:
									'Indica no relatorio se existem imagens anexadas para apoiar os registros do dia.',
							),
							const SizedBox(height: 6),
							_DictionaryRow(
								term: 'IS FINISHED?',
								description:
									'Indica no relatorio se o dia de trabalho foi concluido e fechado corretamente.',
							),
							const SizedBox(height: 6),
							_DictionaryRow(
								term: 'Hodo-2 - is ZERO?',
								description:
									'Lembrete para o usuario zerar o hodometro 2 antes de iniciar as corridas.',
							),
							const SizedBox(height: 6),
							_DictionaryRow(
								term: 'Hodo-2 - NUMBER',
								description:
									'Registra o valor final marcado no hodometro 2 do carro ao fim do dia.',
							),
						],
					),
				),
			],
		);
	}
}

class _DictionaryRow extends StatelessWidget {
	const _DictionaryRow({required this.term, required this.description});

	final String term;
	final String description;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return RichText(
			text: TextSpan(
				style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
				children: [
					TextSpan(
						text: '$term: ',
						style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
					),
					TextSpan(text: description),
				],
			),
		);
	}
}
