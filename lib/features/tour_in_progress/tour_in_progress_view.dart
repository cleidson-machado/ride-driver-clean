import 'package:flutter/material.dart';

/// Tela de passeio em curso com resumo superior e historico recente em lista vertical.
class TourInProgressView extends StatefulWidget {
	const TourInProgressView({super.key});

	@override
	State<TourInProgressView> createState() => _TourInProgressViewState();
}

class _TourInProgressViewState extends State<TourInProgressView> {
	static const String _mockHeaderDate = '16-07-2026 - SEGUNDA-FEIRA';
	static const String _mockRideSku = '011';
	static const bool _mockIsInProgress = true;
	static const String _mockFuelValue = '€40.78';
	static const String _mockRevenueValue = '€??.??';

	static const List<_RecentRideItem> _recentRides = [
		_RecentRideItem(
			sku: '029',
			date: '25/07',
			amount: '€ 110.80',
			kmIn: '50.70',
			hodo2: '50.230',
			kmOut: '50.555',
		),
		_RecentRideItem(
			sku: '030',
			date: '26/07',
			amount: '€ 98.20',
			kmIn: '45.10',
			hodo2: '45.980',
			kmOut: '46.420',
		),
		_RecentRideItem(
			sku: '031',
			date: '27/07',
			amount: '€ 126.45',
			kmIn: '63.00',
			hodo2: '63.700',
			kmOut: '64.200',
		),
	];

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			backgroundColor: colorScheme.surface,
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							SizedBox(
								height: 48,
								child: Center(
									child: Row(
										mainAxisSize: MainAxisSize.min,
										children: [
											IconButton(
												tooltip: 'Voltar',
												onPressed: () => Navigator.of(context).maybePop(),
												icon: const BackButtonIcon(),
											),
											Flexible(
												child: Text(
													_mockHeaderDate,
													textAlign: TextAlign.center,
													style: textTheme.titleSmall?.copyWith(
														fontStyle: FontStyle.italic,
														fontWeight: FontWeight.w500,
														color: colorScheme.onSurfaceVariant,
													),
												),
											),
										],
									),
								),
							),
							const SizedBox(height: 8),
							Divider(color: colorScheme.outline, height: 1),
							const SizedBox(height: 14),
							_CurrentRideCard(
								rideSku: _mockRideSku,
								isInProgress: _mockIsInProgress,
								fuelValue: _mockFuelValue,
								revenueValue: _mockRevenueValue,
							),
							const SizedBox(height: 16),
							_RecentRidesSection(items: _recentRides),
						],
					),
				),
			),
		);
	}
}

class _CurrentRideCard extends StatelessWidget {
	const _CurrentRideCard({
		required this.rideSku,
		required this.isInProgress,
		required this.fuelValue,
		required this.revenueValue,
	});

	final String rideSku;
	final bool isInProgress;
	final String fuelValue;
	final String revenueValue;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Container(
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(14),
				border: Border.all(color: colorScheme.outline),
			),
			padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					Row(
						children: [
							Text(
								'PASSEIO:',
								style: textTheme.titleMedium?.copyWith(
									fontWeight: FontWeight.w700,
									fontStyle: FontStyle.italic,
								),
							),
							const SizedBox(width: 12),
							Text(
								rideSku,
								style: textTheme.titleMedium?.copyWith(
									fontWeight: FontWeight.w700,
									color: colorScheme.error,
									fontStyle: FontStyle.italic,
								),
							),
							const Spacer(),
							Text(
								isInProgress ? 'EM CURSO' : 'CONCLUIDO',
								style: textTheme.titleSmall?.copyWith(
									fontWeight: FontWeight.w700,
								),
							),
							const SizedBox(width: 8),
							Container(
								width: 34,
								height: 34,
								decoration: BoxDecoration(
									color: isInProgress ? colorScheme.primary : colorScheme.secondary,
									shape: BoxShape.circle,
								),
							),
						],
					),
					const SizedBox(height: 14),
					Row(
						children: [
							Expanded(
								child: _TopMetric(label: 'COMBUSTIVEL', value: fuelValue),
							),
							const SizedBox(width: 12),
							Expanded(
								child: _TopMetric(label: 'FATURAMENTO', value: revenueValue),
							),
						],
					),
					const SizedBox(height: 18),
					Center(
						child: FilledButton(
							style: FilledButton.styleFrom(
								minimumSize: const Size(154, 52),
								backgroundColor: colorScheme.error,
								foregroundColor: colorScheme.onError,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(10),
									side: BorderSide(color: colorScheme.onSurface, width: 2),
								),
							),
							onPressed: () {
								// TODO: encerrar passeio em curso
							},
							child: Text(
								'ENCERRAR',
								style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
							),
						),
					),
				],
			),
		);
	}
}

class _TopMetric extends StatelessWidget {
	const _TopMetric({required this.label, required this.value});

	final String label;
	final String value;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					label,
					style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
				),
				const SizedBox(height: 2),
				FittedBox(
					fit: BoxFit.scaleDown,
					alignment: Alignment.centerLeft,
					child: Text(
						value,
						style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
					),
				),
			],
		);
	}
}

class _RecentRidesSection extends StatelessWidget {
	const _RecentRidesSection({required this.items});

	final List<_RecentRideItem> items;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Expanded(
			child: Container(
				decoration: BoxDecoration(
					color: colorScheme.surfaceContainerLowest,
					borderRadius: BorderRadius.circular(10),
					border: Border.all(color: colorScheme.primaryContainer),
				),
				padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(
							'Passeios Recentes:',
							style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
						),
						const SizedBox(height: 8),
						Expanded(
							// Sem itemCount para permitir scroll vertical continuo com dados mockados.
							child: ListView.builder(
								itemBuilder: (BuildContext context, int index) {
									final _RecentRideItem item = items[index % items.length];
									return Padding(
										padding: const EdgeInsets.only(bottom: 10),
										child: _RecentRideDataTableCard(item: item),
									);
								},
							),
						),
					],
				),
			),
		);
	}
}

class _RecentRideDataTableCard extends StatelessWidget {
	const _RecentRideDataTableCard({required this.item});

	final _RecentRideItem item;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Container(
			decoration: BoxDecoration(
				color: colorScheme.surface,
				borderRadius: BorderRadius.circular(10),
				border: Border.all(color: colorScheme.outlineVariant),
			),
			child: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				child: DataTable(
					headingRowHeight: 0,
					dataRowMinHeight: 54,
					dataRowMaxHeight: 54,
					horizontalMargin: 10,
					columnSpacing: 12,
					columns: const [
						DataColumn(label: SizedBox.shrink()),
						DataColumn(label: SizedBox.shrink()),
						DataColumn(label: SizedBox.shrink()),
						DataColumn(label: SizedBox.shrink()),
						DataColumn(label: SizedBox.shrink()),
						DataColumn(label: SizedBox.shrink()),
					],
					rows: [
						DataRow(
							cells: [
								DataCell(
									Row(
										mainAxisSize: MainAxisSize.min,
										children: [
											Icon(Icons.directions_car_rounded, size: 18, color: colorScheme.onSurfaceVariant),
											const SizedBox(width: 8),
											Text(
												item.sku,
												style: textTheme.titleMedium?.copyWith(
													fontWeight: FontWeight.w700,
													color: colorScheme.onSurfaceVariant,
												),
											),
										],
									),
								),
								DataCell(
									Text(
										item.date,
										style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
									),
								),
								DataCell(
									Text(
										item.amount,
										style: textTheme.titleMedium?.copyWith(
											color: colorScheme.primary,
											fontWeight: FontWeight.w700,
										),
									),
								),
								DataCell(
									Text(
										'KM IN: ${item.kmIn}',
										style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
									),
								),
								DataCell(
									Text(
										'HODO2: ${item.hodo2}',
										style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
									),
								),
								DataCell(
									Text(
										'KM OUT: ${item.kmOut}',
										style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
									),
								),
							],
						),
					],
				),
			),
		);
	}
}

class _RecentRideItem {
	const _RecentRideItem({
		required this.sku,
		required this.date,
		required this.amount,
		required this.kmIn,
		required this.hodo2,
		required this.kmOut,
	});

	final String sku;
	final String date;
	final String amount;
	final String kmIn;
	final String hodo2;
	final String kmOut;
}
