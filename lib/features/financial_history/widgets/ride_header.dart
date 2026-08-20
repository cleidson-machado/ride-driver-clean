import 'package:flutter/material.dart';

// ─── Header ───────────────────────────────────────────────────────────────────
// Barra superior da tela: botão de voltar à esquerda e, ao centro, o SKU do
// report atual seguido do pill de status do passeio (EM CURSO / CONCLUÍDO).
class RideHeader extends StatelessWidget {
	const RideHeader({
		super.key,
		required this.rideSku,
		required this.isRideInProgress,
	});

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

// ─── Ride status pill (EM CURSO / CONCLUIDO) ─────────────────────────────────
// Pequeno chip colorido que sinaliza o estado do report: verde/tertiary para
// passeio em andamento e primary quando já concluído.
class _RideStatusPill extends StatelessWidget {
	const _RideStatusPill({required this.isInProgress});

	final bool isInProgress;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		final Color backgroundColor = isInProgress
				? colorScheme.tertiaryContainer
				: colorScheme.primaryContainer;
		final Color foregroundColor = isInProgress
				? colorScheme.onTertiaryContainer
				: colorScheme.onPrimaryContainer;
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
