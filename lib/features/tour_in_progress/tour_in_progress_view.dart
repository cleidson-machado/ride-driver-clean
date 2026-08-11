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
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 14),
							child: SizedBox(
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
										Padding(
											padding: const EdgeInsets.symmetric(horizontal: 48),
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
						Divider(color: colorScheme.outline, height: 1),
						Expanded(
							child: Padding(
								padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [
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
					],
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
				gradient: LinearGradient(
					begin: Alignment.topCenter,
					end: Alignment.bottomCenter,
					stops: const [0.0, 0.35, 1.0],
					colors: [
						colorScheme.tertiary.withValues(alpha: 0.22),
						colorScheme.tertiaryContainer.withValues(alpha: 0.16),
						colorScheme.surface,
					],
				),
				borderRadius: BorderRadius.circular(22),
				border: Border.all(color: colorScheme.outlineVariant),
				boxShadow: [
					BoxShadow(
						color: colorScheme.shadow.withValues(alpha: 0.18),
						blurRadius: 5,
						spreadRadius: 0,
						offset: const Offset(0, 2),
					),
				],
			),
			padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
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
							_StatusIndicator(isInProgress: isInProgress),
						],
					),
					const SizedBox(height: 14),
					Row(
						children: [
							Expanded(
								child: _MetricPanel(
									alignment: Alignment.centerLeft,
									child: _TopMetric(label: 'COMBUSTIVEL', value: fuelValue),
								),
							),
							const SizedBox(width: 12),
							Expanded(
								child: _MetricPanel(
									alignment: Alignment.centerRight,
									child: _TopMetric(label: 'FATURAMENTO', value: revenueValue),
								),
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
								elevation: 4,
								shadowColor: colorScheme.shadow.withValues(alpha: 0.22),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(14),
									side: BorderSide(color: colorScheme.errorContainer, width: 1.5),
								),
							),
							onPressed: () {
								// TODO: encerrar passeio em curso
							},
							child: Text(
								'ENCERRAR - PASSEIO?',
								style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onError),
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
			mainAxisSize: MainAxisSize.min,
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				Text(
					label,
					textAlign: TextAlign.center,
					style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
				),
				const SizedBox(height: 2),
				FittedBox(
					fit: BoxFit.scaleDown,
					alignment: Alignment.center,
					child: Text(
						value,
						textAlign: TextAlign.center,
						style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
					),
				),
			],
		);
	}
}

class _MetricPanel extends StatelessWidget {
	const _MetricPanel({required this.alignment, required this.child});

	final Alignment alignment;
	final Widget child;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Container(
			padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
			decoration: BoxDecoration(
				color: colorScheme.surfaceContainerLowest,
				borderRadius: BorderRadius.circular(12),
			),
			child: Align(
				alignment: alignment,
				child: child,
			),
		);
	}
}

class _StatusIndicator extends StatelessWidget {
	const _StatusIndicator({required this.isInProgress});

	final bool isInProgress;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final Color baseColor = isInProgress ? colorScheme.primary : colorScheme.secondary;

		return Container(
			width: 34,
			height: 34,
			decoration: BoxDecoration(
				shape: BoxShape.circle,
				boxShadow: [
					BoxShadow(
						color: baseColor.withValues(alpha: 0.18),
						blurRadius: 4,
						spreadRadius: 0,
						offset: const Offset(0, 1),
					),
				],
				gradient: RadialGradient(
					colors: [
						colorScheme.primaryContainer,
						baseColor,
					],
				),
				border: Border.all(color: colorScheme.outlineVariant),
			),
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
			constraints: const BoxConstraints(minHeight: 88),
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
			decoration: BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topCenter,
					end: Alignment.bottomCenter,
					colors: [
						colorScheme.surface,
						colorScheme.surfaceContainerLowest,
					],
				),
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: colorScheme.outlineVariant),
				boxShadow: [
					BoxShadow(
						color: colorScheme.shadow.withValues(alpha: 0.08),
						blurRadius: 4,
						offset: const Offset(0, 1),
					),
				],
			),
			child: Row(
				children: [
					SizedBox(
						width: 112,
						child: Column(
							mainAxisSize: MainAxisSize.min,
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									mainAxisSize: MainAxisSize.min,
									children: [
										Icon(
											Icons.directions_car_rounded,
											size: 18,
											color: colorScheme.onSurfaceVariant,
										),
										const SizedBox(width: 8),
										Text(
											item.sku,
											style: textTheme.titleMedium?.copyWith(
												fontWeight: FontWeight.w700,
											),
										),
									],
								),
								const SizedBox(height: 8),
								Text(
									item.date,
									style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
								),
							],
						),
					),
					VerticalDivider(width: 16, thickness: 1, color: colorScheme.outlineVariant),
					Expanded(
						child: Column(
							mainAxisSize: MainAxisSize.min,
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									item.amount,
									style: textTheme.titleLarge?.copyWith(
										fontWeight: FontWeight.w700,
										color: colorScheme.primary,
									),
								),
								const SizedBox(height: 4),
								Text(
									'KM IN: ${item.kmIn}   OUT: ${item.kmOut}',
									style: textTheme.bodyMedium?.copyWith(
										color: colorScheme.onSurfaceVariant,
									),
								),
							],
						),
					),
					VerticalDivider(width: 16, thickness: 1, color: colorScheme.outlineVariant),
					SizedBox(
						width: 74,
						child: Column(
							mainAxisSize: MainAxisSize.min,
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.end,
							children: [
								Text(
									'Trip Stats',
									style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
								),
								const SizedBox(height: 4),
								Text(
									'HOD ${item.hodo2}',
									style: textTheme.bodyMedium,
									textAlign: TextAlign.end,
								),
							],
						),
					),
				],
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
