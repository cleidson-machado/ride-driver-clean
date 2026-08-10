import 'package:flutter/material.dart';

/// Tela de cadastro/edicao de passeio com dados mockados para POC.
class FinancialHistoryView extends StatefulWidget {
	const FinancialHistoryView({super.key});

	@override
	State<FinancialHistoryView> createState() => _FinancialHistoryViewState();
}

class _FinancialHistoryViewState extends State<FinancialHistoryView> {
	static const String _mockDate = '16-07-2026 - SEGUNDA-FEIRA';

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			backgroundColor: colorScheme.surface,
			body: SafeArea(
				child: Padding(
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
											style: textTheme.titleLarge?.copyWith(
												fontStyle: FontStyle.italic,
												fontWeight: FontWeight.w500,
												fontSize: 14,
												color: colorScheme.onSurface,
											),
										),
									],
								),
							),
							const SizedBox(height: 12),
							Divider(color: colorScheme.outline),
							const SizedBox(height: 16),
							Expanded(
								child: DecoratedBox(
									decoration: BoxDecoration(
										color: colorScheme.surfaceContainerLowest,
										borderRadius: BorderRadius.circular(24),
										border: Border.all(color: colorScheme.outlineVariant),
									),
									child: const SizedBox.expand(),
								),
							),
						],
					),
				),
			),
		);
	}
}
