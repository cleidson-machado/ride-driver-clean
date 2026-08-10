import 'package:flutter/material.dart';

/// Tela de cadastro/edicao de passeio com dados mockados para POC.
class FinancialHistoryView extends StatefulWidget {
	const FinancialHistoryView({super.key});

	@override
	State<FinancialHistoryView> createState() => _FinancialHistoryViewState();
}

class _FinancialHistoryViewState extends State<FinancialHistoryView> {
	static const String _mockDate = '16-07-2026 - SEGUNDA-FEIRA';
	static const String _mockRideDate = '16 Julho 2016';
	static const String _mockStartMileage = '44.762';
	static const String _mockEmptyValue = 'NONE';

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			backgroundColor: colorScheme.surface,
			body: SafeArea(
				child: LayoutBuilder(
					builder: (BuildContext context, BoxConstraints constraints) {
						final bool compact = constraints.maxWidth < 600;

						return Padding(
							padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									SizedBox(
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
												Text(
													_mockDate,
													textAlign: TextAlign.center,
													style: textTheme.titleMedium?.copyWith(
														fontStyle: FontStyle.italic,
														fontWeight: FontWeight.w700,
														color: colorScheme.onSurface,
													),
												),
											],
										),
									),
									const SizedBox(height: 1),
									Divider(color: colorScheme.outline),
									const SizedBox(height: 10),
									Expanded(
										child: _ThreeColumnSlots(
											compact: compact,
											rideDate: _mockRideDate,
											startMileage: _mockStartMileage,
											emptyValue: _mockEmptyValue,
										),
									),
								],
							),
						);
					},
				),
			),
		);
	}
}

class _ThreeColumnSlots extends StatelessWidget {
	const _ThreeColumnSlots({
		required this.compact,
		required this.rideDate,
		required this.startMileage,
		required this.emptyValue,
	});

	final bool compact;
	final String rideDate;
	final String startMileage;
	final String emptyValue;

	@override
	Widget build(BuildContext context) {
		if (compact) {
			return Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Expanded(
						flex: 10,
						child: _LeftColumnSlots(
							rideDate: rideDate,
							startMileage: startMileage,
						),
					),
					const SizedBox(width: 8),
					const Expanded(flex: 3, child: _ProfitVerticalSlot()),
					const SizedBox(width: 8),
					Expanded(
						flex: 10,
						child: _RightColumnSlots(emptyValue: emptyValue),
					),
				],
			);
		}

		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Expanded(
					flex: 10,
					child: _LeftColumnSlots(
						rideDate: rideDate,
						startMileage: startMileage,
					),
				),
				const SizedBox(width: 12),
				const Expanded(flex: 3, child: _ProfitVerticalSlot()),
				const SizedBox(width: 12),
				Expanded(
					flex: 10,
					child: _RightColumnSlots(emptyValue: emptyValue),
				),
			],
		);
	}
}

class _LeftColumnSlots extends StatelessWidget {
	const _LeftColumnSlots({required this.rideDate, required this.startMileage});

	final String rideDate;
	final String startMileage;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				_FieldSlot(
					label: 'Data - PASSEIO',
					child: _DateRowMock(value: rideDate),
				),
				const SizedBox(height: 12),
				_FieldSlot(
					label: 'Kilometragem - SAIDA',
					child: _StepperRowMock(value: startMileage),
				),
				const SizedBox(height: 12),
				const _FieldSlot(
					label: 'Hodometro 2 - ZERADO?',
					child: _BinaryRowMock(),
				),
			],
		);
	}
}

class _RightColumnSlots extends StatelessWidget {
	const _RightColumnSlots({required this.emptyValue});

	final String emptyValue;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				_FieldSlot(
					label: 'Valor - ABASTECIMENTO',
					child: _StepperRowMock(value: emptyValue),
				),
				const SizedBox(height: 12),
				_FieldSlot(
					label: 'Kilometragem - CHEGADA',
					child: _StepperRowMock(value: emptyValue),
				),
				const SizedBox(height: 12),
				_FieldSlot(
					label: 'Hodometro 2 - TRAJETO',
					child: _StepperRowMock(value: emptyValue),
				),
			],
		);
	}
}

class _FieldSlot extends StatelessWidget {
	const _FieldSlot({required this.label, required this.child});

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
					style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
				),
				const SizedBox(height: 6),
				child,
			],
		);
	}
}

class _DateRowMock extends StatelessWidget {
	const _DateRowMock({required this.value});

	final String value;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 50,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(2),
				border: Border.all(color: colorScheme.outline),
			),
			child: Row(
				children: [
					Expanded(
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 12),
							child: Align(
								alignment: Alignment.centerLeft,
								child: Text(value, style: textTheme.titleMedium),
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					SizedBox(
						width: 48,
						child: Tooltip(
							message: 'Selecionar data',
							child: Icon(Icons.calendar_month_outlined, color: colorScheme.onSurfaceVariant),
						),
					),
				],
			),
		);
	}
}

class _StepperRowMock extends StatelessWidget {
	const _StepperRowMock({required this.value});

	final String value;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 50,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(2),
				border: Border.all(color: colorScheme.outline),
			),
			child: Row(
				children: [
					Expanded(
						child: Center(
							child: Text('-', style: textTheme.headlineSmall),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					Expanded(
						flex: 3,
						child: Center(
							child: Text(
								value,
								style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					Expanded(
						child: Center(
							child: Text('+', style: textTheme.headlineSmall),
						),
					),
				],
			),
		);
	}
}

class _BinaryRowMock extends StatelessWidget {
	const _BinaryRowMock();

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 50,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(2),
				border: Border.all(color: colorScheme.outline),
			),
			child: Row(
				children: [
					Expanded(
						child: Tooltip(
							message: 'Alternar status zerado',
							child: Icon(Icons.circle_outlined, color: colorScheme.onSurfaceVariant),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					Expanded(
						flex: 3,
						child: Center(
							child: Text(
								'YES',
								style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					Expanded(
						child: Tooltip(
							message: 'Status alternativo',
							child: Icon(Icons.square, color: colorScheme.onSurface),
						),
					),
				],
			),
		);
	}
}

class _ProfitVerticalSlot extends StatelessWidget {
	const _ProfitVerticalSlot();

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
				const SizedBox(height: 6),
				Expanded(
					child: Container(
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(2),
							border: Border.all(color: colorScheme.outline),
						),
						child: Column(
							children: [
								const Spacer(),
								Container(
									height: 28,
									width: double.infinity,
									color: colorScheme.onSurface,
								),
							],
						),
					),
				),
			],
		);
	}
}
