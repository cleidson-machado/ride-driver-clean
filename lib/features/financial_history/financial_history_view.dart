import 'package:flutter/material.dart';

/// Tela de cadastro/edição de passeio com dados mockados para POC.
class FinancialHistoryView extends StatefulWidget {
	const FinancialHistoryView({super.key});

	@override
	State<FinancialHistoryView> createState() => _FinancialHistoryViewState();
}

class _FinancialHistoryViewState extends State<FinancialHistoryView> {
	static const String _mockDate = '16-07-2026 - SEGUNDA-FEIRA';
	static const String _mockRideDate = '16 Julho 2026';

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

	void _incDepartureMileage() => setState(() => _departureMileage += 1);
	void _decDepartureMileage() {
		setState(() => _departureMileage = (_departureMileage - 1).clamp(0, 9999999));
	}

	void _incFuelValue() => setState(() => _fuelValue += 1);
	void _decFuelValue() {
		setState(() => _fuelValue = (_fuelValue - 1).clamp(0, 9999999));
	}

	void _incArrivalMileage() => setState(() => _arrivalMileage += 1);
	void _decArrivalMileage() {
		setState(() => _arrivalMileage = (_arrivalMileage - 1).clamp(0, 9999999));
	}

	void _incTripDistance() => setState(() => _tripDistance += 1);
	void _decTripDistance() {
		setState(() => _tripDistance = (_tripDistance - 1).clamp(0, 9999999));
	}

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			body: SafeArea(
				child: LayoutBuilder(
					builder: (BuildContext context, BoxConstraints constraints) {
						final bool compact = constraints.maxWidth < 600;
						final bool medium = constraints.maxWidth >= 600 && constraints.maxWidth < 840;
						final double contentMaxWidth = medium ? 720 : 920;

						return Align(
							alignment: Alignment.topCenter,
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: contentMaxWidth),
								child: SingleChildScrollView(
									padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: [
											Text(
												_mockDate,
												textAlign: TextAlign.center,
												style: textTheme.titleMedium?.copyWith(
													fontStyle: FontStyle.italic,
													color: colorScheme.onSurfaceVariant,
												),
											),
											const SizedBox(height: 12),
											Divider(color: colorScheme.outlineVariant),
											const SizedBox(height: 14),
											Row(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Expanded(
														child: Column(
															children: [
																_LabeledField(
																	label: 'Data - Passeio',
																	child: OutlinedButton.icon(
																		onPressed: () {},
																		icon: const Icon(Icons.calendar_month_outlined),
																		label: Text(_mockRideDate),
																	),
																),
																const SizedBox(height: 12),
																_LabeledField(
																	label: 'Kilometragem - Saida',
																	child: _StepperField(
																		value: _departureMileage.toString(),
																		onIncrement: _incDepartureMileage,
																		onDecrement: _decDepartureMileage,
																	),
																),
																const SizedBox(height: 12),
																_LabeledField(
																	label: 'Hodometro 2 - Zerado?',
																	child: SegmentedButton<bool>(
																		segments: const [
																			ButtonSegment<bool>(
																				value: true,
																				label: Text('YES'),
																				icon: Icon(Icons.radio_button_checked),
																			),
																			ButtonSegment<bool>(
																				value: false,
																				label: Text('NO'),
																				icon: Icon(Icons.stop_rounded),
																			),
																		],
																		selected: <bool>{_zeroedOdometer},
																		onSelectionChanged: (Set<bool> selection) {
																			setState(() => _zeroedOdometer = selection.first);
																		},
																	),
																),
															],
														),
													),
													const SizedBox(width: 12),
													SizedBox(
														width: compact ? 76 : 84,
														child: _ProfitColumn(value: '€ 55,89'),
													),
													const SizedBox(width: 12),
													Expanded(
														child: Column(
															children: [
																_LabeledField(
																	label: 'Valor - Abastecimento',
																	child: _StepperField(
																		value: _fuelValue == 0 ? 'NONE' : '€ $_fuelValue',
																		onIncrement: _incFuelValue,
																		onDecrement: _decFuelValue,
																	),
																),
																const SizedBox(height: 12),
																_LabeledField(
																	label: 'Kilometragem - Chegada',
																	child: _StepperField(
																		value: _arrivalMileage == 0
																				? 'NONE'
																				: _arrivalMileage.toString(),
																		onIncrement: _incArrivalMileage,
																		onDecrement: _decArrivalMileage,
																	),
																),
																const SizedBox(height: 12),
																_LabeledField(
																	label: 'Hodometro 2 - Trajeto',
																	child: _StepperField(
																		value: _tripDistance == 0 ? 'NONE' : _tripDistance.toString(),
																		onIncrement: _incTripDistance,
																		onDecrement: _decTripDistance,
																	),
																),
															],
														),
													),
												],
											),
											const SizedBox(height: 20),
											_PlatformsBaseCard(
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
											const SizedBox(height: 14),
											Row(
												children: [
													Expanded(
														child: CheckboxListTile(
															contentPadding: EdgeInsets.zero,
															controlAffinity: ListTileControlAffinity.leading,
															title: const Text('Com imagens?'),
															value: _withImages,
															onChanged: (bool? value) {
																setState(() => _withImages = value ?? false);
															},
														),
													),
													const SizedBox(width: 12),
													Expanded(
														child: CheckboxListTile(
															contentPadding: EdgeInsets.zero,
															controlAffinity: ListTileControlAffinity.leading,
															title: const Text('Concluido?'),
															value: _isCompleted,
															onChanged: (bool? value) {
																setState(() => _isCompleted = value ?? false);
															},
														),
													),
												],
											),
											const SizedBox(height: 10),
											Column(
												children: [
													Text(
														'Plataforma',
														style: textTheme.titleSmall?.copyWith(
															fontWeight: FontWeight.w700,
														),
													),
													const SizedBox(height: 8),
													FloatingActionButton.small(
														tooltip: 'Adicionar plataforma',
														onPressed: () {},
														child: const Icon(Icons.add_rounded),
													),
												],
											),
											const SizedBox(height: 16),
											_LabeledField(
												label: 'Anotacoes / Observacoes',
												child: TextField(
													controller: _noteController,
													minLines: 4,
													maxLines: 5,
													decoration: const InputDecoration(
														border: OutlineInputBorder(),
													),
												),
											),
											const SizedBox(height: 16),
											FilledButton(
												onPressed: () {},
												style: FilledButton.styleFrom(
													backgroundColor: colorScheme.error,
													foregroundColor: colorScheme.onError,
													minimumSize: const Size.fromHeight(54),
												),
												child: Text(
													'SALVAR / ATUALIZAR - ( PASSEIO 011 )',
													style: textTheme.titleMedium?.copyWith(
														fontWeight: FontWeight.w800,
													),
												),
											),
											const SizedBox(height: 16),
											Divider(color: colorScheme.outlineVariant),
											const SizedBox(height: 8),
											_SecondaryActionBar(compact: compact),
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
}

class _LabeledField extends StatelessWidget {
	const _LabeledField({required this.label, required this.child});

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
					style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
				),
				const SizedBox(height: 6),
				child,
			],
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
		return Row(
			children: [
				Expanded(
					child: OutlinedButton(
						onPressed: onDecrement,
						child: const Icon(Icons.remove),
					),
				),
				Expanded(
					flex: 2,
					child: OutlinedButton(
						onPressed: () {},
						child: Text(
							value,
							overflow: TextOverflow.ellipsis,
						),
					),
				),
				Expanded(
					child: OutlinedButton(
						onPressed: onIncrement,
						child: const Icon(Icons.add),
					),
				),
			],
		);
	}
}

class _ProfitColumn extends StatelessWidget {
	const _ProfitColumn({required this.value});

	final String value;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			children: [
				Text(
					'LUCRO',
					style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
				),
				const SizedBox(height: 6),
				Container(
					height: 280,
					decoration: BoxDecoration(
						border: Border.all(color: colorScheme.outline),
						borderRadius: BorderRadius.circular(12),
					),
					child: Column(
						children: [
							const Spacer(),
							Container(
								padding: const EdgeInsets.symmetric(vertical: 8),
								width: double.infinity,
								decoration: BoxDecoration(
									color: colorScheme.secondaryContainer,
									borderRadius: const BorderRadius.only(
										bottomLeft: Radius.circular(11),
										bottomRight: Radius.circular(11),
									),
								),
								child: Text(
									value,
									textAlign: TextAlign.center,
									style: textTheme.titleMedium?.copyWith(
										color: colorScheme.onSecondaryContainer,
										fontWeight: FontWeight.w700,
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

class _PlatformsBaseCard extends StatelessWidget {
	const _PlatformsBaseCard({required this.compact, required this.platforms});

	final bool compact;
	final List<_PlatformSummary> platforms;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				border: Border.all(color: colorScheme.outline, style: BorderStyle.solid),
				borderRadius: BorderRadius.circular(12),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					Text(
						'PLATAFORMAS BASE',
						textAlign: TextAlign.center,
						style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 12,
						runSpacing: 12,
						children: [
							for (final _PlatformSummary platform in platforms)
								SizedBox(
									width: compact ? double.infinity : 280,
									child: _PlatformSummaryCard(platform: platform),
								),
						],
					),
				],
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
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Card(
			margin: EdgeInsets.zero,
			child: Padding(
				padding: const EdgeInsets.all(12),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						OutlinedButton(
							onPressed: () {},
							child: Text(
								platform.name,
								style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
							),
						),
						const SizedBox(height: 8),
						Text(
							'Valor total dia:',
							textAlign: TextAlign.center,
							style: textTheme.bodyLarge,
						),
						const SizedBox(height: 4),
						Container(
							padding: const EdgeInsets.symmetric(vertical: 8),
							decoration: BoxDecoration(
								border: Border.all(color: colorScheme.outline),
								borderRadius: BorderRadius.circular(8),
							),
							child: Text(
								platform.dailyValue,
								textAlign: TextAlign.center,
								style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
							),
						),
						const SizedBox(height: 10),
						Text(
							'Corridas total dia:',
							textAlign: TextAlign.center,
							style: textTheme.bodyLarge,
						),
						const SizedBox(height: 4),
						Container(
							padding: const EdgeInsets.symmetric(vertical: 8),
							decoration: BoxDecoration(
								border: Border.all(color: colorScheme.outline),
								borderRadius: BorderRadius.circular(8),
							),
							child: Text(
								platform.dailyRides,
								textAlign: TextAlign.center,
								style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
							),
						),
					],
				),
			),
		);
	}
}

class _SecondaryActionBar extends StatelessWidget {
	const _SecondaryActionBar({required this.compact});

	final bool compact;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Wrap(
			alignment: WrapAlignment.spaceAround,
			runSpacing: 8,
			spacing: compact ? 8 : 20,
			children: [
				_ActionItem(
					icon: Icons.add_circle_outline_rounded,
					label: 'Button 1',
					onPressed: () {},
					foregroundColor: colorScheme.outline,
					textTheme: textTheme,
				),
				_ActionItem(
					icon: Icons.search_rounded,
					label: 'Button 2',
					onPressed: () {},
					foregroundColor: colorScheme.onSurfaceVariant,
					textTheme: textTheme,
				),
				_ActionItem(
					icon: Icons.copy_all_outlined,
					label: 'Button 3',
					onPressed: () {},
					foregroundColor: colorScheme.onSurfaceVariant,
					textTheme: textTheme,
				),
				_ActionItem(
					icon: Icons.delete_outline_rounded,
					label: 'Button 4',
					onPressed: () {},
					foregroundColor: colorScheme.onSurfaceVariant,
					textTheme: textTheme,
				),
			],
		);
	}
}

class _ActionItem extends StatelessWidget {
	const _ActionItem({
		required this.icon,
		required this.label,
		required this.onPressed,
		required this.foregroundColor,
		required this.textTheme,
	});

	final IconData icon;
	final String label;
	final VoidCallback onPressed;
	final Color foregroundColor;
	final TextTheme textTheme;

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: 78,
			child: Column(
				children: [
					IconButton(
						tooltip: label,
						onPressed: onPressed,
						icon: Icon(icon, color: foregroundColor),
					),
					Text(
						label,
						textAlign: TextAlign.center,
						style: textTheme.labelLarge?.copyWith(color: foregroundColor),
					),
				],
			),
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
