import 'package:flutter/material.dart';

/// Tela de cadastro/edicao de passeio com dados mockados para POC.
class FinancialHistoryView extends StatefulWidget {
	const FinancialHistoryView({super.key});

	@override
	State<FinancialHistoryView> createState() => _FinancialHistoryViewState();
}

class _FinancialHistoryViewState extends State<FinancialHistoryView> {
	static const String _mockDate = '16-07-2026 - SEGUNDA-FEIRA';
	static const String _mockRideDate = '16 Julho 2026';
	static const String _mockProfit = '€ 55,89';

	final TextEditingController _noteController = TextEditingController(
		text: 'USANDO ABASTECIMENTO DO DIA / PASSEIO ANTERIOR NESSE MOMENTO',
	);

	bool _zeroedOdometer = true;
	bool _withImages = true;
	bool _isCompleted = true;

	int _departureMileage = 44762;
	int _fuelValue = 0;
	int _arrivalMileage = 0;
	int _tripDistance = 0;

	@override
	void dispose() {
		_noteController.dispose();
		super.dispose();
	}

	void _incrementDepartureMileage() {
		setState(() => _departureMileage += 1);
	}

	void _decrementDepartureMileage() {
		setState(() => _departureMileage = (_departureMileage - 1).clamp(0, 9999999));
	}

	void _incrementFuelValue() {
		setState(() => _fuelValue += 1);
	}

	void _decrementFuelValue() {
		setState(() => _fuelValue = (_fuelValue - 1).clamp(0, 9999999));
	}

	void _incrementArrivalMileage() {
		setState(() => _arrivalMileage += 1);
	}

	void _decrementArrivalMileage() {
		setState(() => _arrivalMileage = (_arrivalMileage - 1).clamp(0, 9999999));
	}

	void _incrementTripDistance() {
		setState(() => _tripDistance += 1);
	}

	void _decrementTripDistance() {
		setState(() => _tripDistance = (_tripDistance - 1).clamp(0, 9999999));
	}

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			backgroundColor: colorScheme.surface,
			body: SafeArea(
				child: LayoutBuilder(
					builder: (BuildContext context, BoxConstraints constraints) {
						final bool compact = constraints.maxWidth < 600;
						final bool medium = constraints.maxWidth >= 600 && constraints.maxWidth < 840;
						final double maxContentWidth = compact ? 560 : (medium ? 760 : 1040);

						return Align(
							alignment: Alignment.topCenter,
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: maxContentWidth),
								child: SingleChildScrollView(
									padding: EdgeInsets.fromLTRB(
										compact ? 16 : 24,
										20,
										compact ? 16 : 24,
										28,
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: [
											_HeaderDate(dateLabel: _mockDate),
											const SizedBox(height: 20),
											_TopFormSection(
												compact: compact,
												leftChild: _buildLeftColumn(),
												centerChild: const _ProfitMeter(value: _mockProfit),
												rightChild: _buildRightColumn(),
											),
											const SizedBox(height: 20),
											_PlatformsSection(
												compact: compact,
												platforms: const [
													_PlatformSummary(
														name: 'UBER',
														dailyValue: '€ 55,89',
														dailyRides: '06',
													),
													_PlatformSummary(
														name: 'BOLT',
														dailyValue: '€ 10,09',
														dailyRides: '06',
													),
												],
											),
											const SizedBox(height: 20),
											_BottomControlSection(
												compact: compact,
												withImages: _withImages,
												isCompleted: _isCompleted,
												onImagesChanged: (bool? value) {
													setState(() => _withImages = value ?? false);
												},
												onCompletedChanged: (bool? value) {
													setState(() => _isCompleted = value ?? false);
												},
											),
											const SizedBox(height: 20),
											_NotesSection(controller: _noteController),
											const SizedBox(height: 20),
											FilledButton(
												onPressed: () {},
												style: FilledButton.styleFrom(
													minimumSize: const Size.fromHeight(58),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(18),
													),
												),
												child: const Text('SALVAR / ATUALIZAR - ( PASSEIO 011 )'),
											),
										],
									),
								),
							),
						);
					},
				),
			),
		);
	}

	Widget _buildLeftColumn() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				_FieldSection(
					label: 'Data - Passeio',
					child: _DateFieldButton(dateLabel: _mockRideDate),
				),
				const SizedBox(height: 18),
				_FieldSection(
					label: 'Kilometragem - Saida',
					child: _StepperField(
						value: _departureMileage.toString(),
						onIncrement: _incrementDepartureMileage,
						onDecrement: _decrementDepartureMileage,
					),
				),
				const SizedBox(height: 18),
				_FieldSection(
					label: 'Hodometro 2 - Zerado?',
					child: _BinaryChoiceField(
						selectedValue: _zeroedOdometer,
						onSelected: (bool value) => setState(() => _zeroedOdometer = value),
					),
				),
			],
		);
	}

	Widget _buildRightColumn() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				_FieldSection(
					label: 'Valor - Abastecimento',
					child: _StepperField(
						value: _fuelValue == 0 ? 'NONE' : '€ $_fuelValue',
						onIncrement: _incrementFuelValue,
						onDecrement: _decrementFuelValue,
					),
				),
				const SizedBox(height: 18),
				_FieldSection(
					label: 'Kilometragem - Chegada',
					child: _StepperField(
						value: _arrivalMileage == 0 ? 'NONE' : _arrivalMileage.toString(),
						onIncrement: _incrementArrivalMileage,
						onDecrement: _decrementArrivalMileage,
					),
				),
				const SizedBox(height: 18),
				_FieldSection(
					label: 'Hodometro 2 - Trajeto',
					child: _StepperField(
						value: _tripDistance == 0 ? 'NONE' : _tripDistance.toString(),
						onIncrement: _incrementTripDistance,
						onDecrement: _decrementTripDistance,
					),
				),
			],
		);
	}
}

class _HeaderDate extends StatelessWidget {
	const _HeaderDate({required this.dateLabel});

	final String dateLabel;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			children: [
				Text(
					dateLabel,
					textAlign: TextAlign.center,
					style: textTheme.titleLarge?.copyWith(
						fontStyle: FontStyle.italic,
						fontWeight: FontWeight.w500,
					),
				),
				const SizedBox(height: 12),
				Divider(color: colorScheme.outline),
			],
		);
	}
}

class _TopFormSection extends StatelessWidget {
	const _TopFormSection({
		required this.compact,
		required this.leftChild,
		required this.centerChild,
		required this.rightChild,
	});

	final bool compact;
	final Widget leftChild;
	final Widget centerChild;
	final Widget rightChild;

	@override
	Widget build(BuildContext context) {
		if (compact) {
			return Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					leftChild,
					const SizedBox(height: 18),
					centerChild,
					const SizedBox(height: 18),
					rightChild,
				],
			);
		}

		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Expanded(flex: 10, child: leftChild),
				const SizedBox(width: 20),
				Expanded(flex: 3, child: centerChild),
				const SizedBox(width: 20),
				Expanded(flex: 10, child: rightChild),
			],
		);
	}
}

class _FieldSection extends StatelessWidget {
	const _FieldSection({required this.label, required this.child});

	final String label;
	final Widget child;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					label,
					style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
				),
				const SizedBox(height: 8),
				child,
			],
		);
	}
}

class _DateFieldButton extends StatelessWidget {
	const _DateFieldButton({required this.dateLabel});

	final String dateLabel;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return OutlinedButton(
			onPressed: () {},
			style: OutlinedButton.styleFrom(
				padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
				side: BorderSide(color: colorScheme.outline),
			),
			child: Row(
				children: [
					Expanded(
						child: Text(
							dateLabel,
							maxLines: 1,
							overflow: TextOverflow.ellipsis,
						),
					),
					const SizedBox(width: 12),
					const Icon(Icons.calendar_month_outlined),
				],
			),
		);
	}
}

class _StepperField extends StatelessWidget {
	const _StepperField({
		required this.value,
		required this.onIncrement,
		required this.onDecrement,
	});

	final String value;
	final VoidCallback onIncrement;
	final VoidCallback onDecrement;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Material(
			color: colorScheme.surface,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(8),
				side: BorderSide(color: colorScheme.outline),
			),
			child: SizedBox(
				height: 56,
				child: Row(
					children: [
						_InlineActionButton(
							icon: Icons.remove,
							onPressed: onDecrement,
							tooltip: 'Diminuir valor',
						),
						VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
						Expanded(
							child: Center(
								child: Text(
									value,
									style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
								),
							),
						),
						VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
						_InlineActionButton(
							icon: Icons.add,
							onPressed: onIncrement,
							tooltip: 'Aumentar valor',
						),
					],
				),
			),
		);
	}
}

class _InlineActionButton extends StatelessWidget {
	const _InlineActionButton({
		required this.icon,
		required this.onPressed,
		required this.tooltip,
	});

	final IconData icon;
	final VoidCallback onPressed;
	final String tooltip;

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: 52,
			height: 56,
			child: IconButton(
				onPressed: onPressed,
				tooltip: tooltip,
				icon: Icon(icon),
			),
		);
	}
}

class _BinaryChoiceField extends StatelessWidget {
	const _BinaryChoiceField({required this.selectedValue, required this.onSelected});

	final bool selectedValue;
	final ValueChanged<bool> onSelected;

	@override
	Widget build(BuildContext context) {
		return SegmentedButton<bool>(
			showSelectedIcon: false,
			segments: const [
				ButtonSegment<bool>(
					value: true,
					icon: Icon(Icons.circle_outlined),
					label: Text('YES'),
				),
				ButtonSegment<bool>(
					value: false,
					icon: Icon(Icons.stop_rounded),
					label: Text('NO'),
				),
			],
			selected: <bool>{selectedValue},
			onSelectionChanged: (Set<bool> selection) => onSelected(selection.first),
		);
	}
}

class _ProfitMeter extends StatelessWidget {
	const _ProfitMeter({required this.value});

	final String value;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				Text(
					'LUCRO',
					textAlign: TextAlign.center,
					style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
				),
				const SizedBox(height: 8),
				Container(
					height: 308,
					decoration: BoxDecoration(
						color: colorScheme.surface,
						borderRadius: BorderRadius.circular(8),
						border: Border.all(color: colorScheme.outline),
					),
					child: Column(
						children: [
							const Spacer(),
							Container(
								width: double.infinity,
								padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
								decoration: BoxDecoration(
									color: colorScheme.primaryContainer,
									borderRadius: const BorderRadius.only(
										bottomLeft: Radius.circular(7),
										bottomRight: Radius.circular(7),
									),
								),
								child: Text(
									value,
									textAlign: TextAlign.center,
									style: textTheme.titleMedium?.copyWith(
										fontWeight: FontWeight.w800,
										color: colorScheme.onPrimaryContainer,
									),
								),
							),
						],
					),
				),
			],
		);
	}
}

class _PlatformsSection extends StatelessWidget {
	const _PlatformsSection({required this.compact, required this.platforms});

	final bool compact;
	final List<_PlatformSummary> platforms;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Card.outlined(
			margin: EdgeInsets.zero,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(20),
				side: BorderSide(color: colorScheme.outline),
			),
			child: Padding(
				padding: const EdgeInsets.all(18),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Text(
							'PLATAFORMAS BASE',
							textAlign: TextAlign.center,
							style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
						),
						const SizedBox(height: 18),
						Wrap(
							spacing: 16,
							runSpacing: 16,
							alignment: WrapAlignment.center,
							children: [
								for (final _PlatformSummary platform in platforms)
									SizedBox(
										width: compact ? double.infinity : 300,
										child: _PlatformSummaryCard(platform: platform),
									),
							],
						),
					],
				),
			),
		);
	}
}

class _PlatformSummaryCard extends StatelessWidget {
	const _PlatformSummaryCard({required this.platform});

	final _PlatformSummary platform;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Card(
			margin: EdgeInsets.zero,
			child: Padding(
				padding: const EdgeInsets.all(20),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						OutlinedButton(
							onPressed: () {},
							child: Text(
								platform.name,
								style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
							),
						),
						const SizedBox(height: 18),
						Text(
							'Valor total dia:',
							textAlign: TextAlign.center,
							style: textTheme.titleMedium,
						),
						const SizedBox(height: 8),
						_InfoValueBox(value: platform.dailyValue),
						const SizedBox(height: 18),
						Text(
							'Corridas total dia:',
							textAlign: TextAlign.center,
							style: textTheme.titleMedium,
						),
						const SizedBox(height: 8),
						_InfoValueBox(value: platform.dailyRides),
					],
				),
			),
		);
	}
}

class _InfoValueBox extends StatelessWidget {
	const _InfoValueBox({required this.value});

	final String value;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Container(
			padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
			decoration: BoxDecoration(
				color: colorScheme.surface,
				borderRadius: BorderRadius.circular(8),
				border: Border.all(color: colorScheme.outline),
			),
			child: Text(
				value,
				textAlign: TextAlign.center,
				style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
			),
		);
	}
}

class _BottomControlSection extends StatelessWidget {
	const _BottomControlSection({
		required this.compact,
		required this.withImages,
		required this.isCompleted,
		required this.onImagesChanged,
		required this.onCompletedChanged,
	});

	final bool compact;
	final bool withImages;
	final bool isCompleted;
	final ValueChanged<bool?> onImagesChanged;
	final ValueChanged<bool?> onCompletedChanged;

	@override
	Widget build(BuildContext context) {
		if (compact) {
			return Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					_SelectionTile(
						label: 'Com imagens?',
						value: withImages,
						onChanged: onImagesChanged,
					),
					const SizedBox(height: 16),
					const _AddPlatformAction(),
					const SizedBox(height: 16),
					_SelectionTile(
						label: 'Concluido?',
						value: isCompleted,
						onChanged: onCompletedChanged,
					),
				],
			);
		}

		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Expanded(
					child: _SelectionTile(
						label: 'Com imagens?',
						value: withImages,
						onChanged: onImagesChanged,
					),
				),
				const SizedBox(width: 16),
				const Expanded(child: _AddPlatformAction()),
				const SizedBox(width: 16),
				Expanded(
					child: _SelectionTile(
						label: 'Concluido?',
						value: isCompleted,
						onChanged: onCompletedChanged,
					),
				),
			],
		);
	}
}

class _SelectionTile extends StatelessWidget {
	const _SelectionTile({
		required this.label,
		required this.value,
		required this.onChanged,
	});

	final String label;
	final bool value;
	final ValueChanged<bool?> onChanged;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Card.outlined(
			margin: EdgeInsets.zero,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(16),
				side: BorderSide(color: colorScheme.outline),
			),
			child: CheckboxListTile(
				value: value,
				onChanged: onChanged,
				controlAffinity: ListTileControlAffinity.leading,
				title: Text(label),
				contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
			),
		);
	}
}

class _AddPlatformAction extends StatelessWidget {
	const _AddPlatformAction();

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Column(
			children: [
				Text(
					'PLATAFORMA',
					style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
				),
				const SizedBox(height: 10),
				FloatingActionButton.large(
					onPressed: () {},
					tooltip: 'Adicionar plataforma',
					child: const Icon(Icons.add_rounded, size: 38),
				),
			],
		);
	}
}

class _NotesSection extends StatelessWidget {
	const _NotesSection({required this.controller});

	final TextEditingController controller;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					'Anotacoes / Observacoes',
					style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
				),
				const SizedBox(height: 8),
				TextField(
					controller: controller,
					minLines: 5,
					maxLines: 6,
					decoration: const InputDecoration(
						border: OutlineInputBorder(),
					),
				),
			],
		);
	}
}

class _PlatformSummary {
	const _PlatformSummary({
		required this.name,
		required this.dailyValue,
		required this.dailyRides,
	});

	final String name;
	final String dailyValue;
	final String dailyRides;
}
