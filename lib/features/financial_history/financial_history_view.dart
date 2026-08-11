import 'package:flutter/material.dart';

/// Tela de cadastro/edicao de passeio — skeleton M3 responsivo.
class FinancialHistoryView extends StatefulWidget {
	const FinancialHistoryView({super.key});

	@override
	State<FinancialHistoryView> createState() => _FinancialHistoryViewState();
}

class _FinancialHistoryViewState extends State<FinancialHistoryView> {
	static const String _mockDate = '( PASSEIO 011 )';
	static const String _mockRideDate = '16 Julho 2016';
	static const String _mockStartMileage = '44.762';
	static const String _mockEmptyValue = 'NONE';

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
						_Header(date: _mockDate),
						Divider(color: colorScheme.outline, height: 1),
						// Scrollable body
						Expanded(
							child: SingleChildScrollView(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [
										// 2. Grelha de 3 colunas superiores
										_TopDataGrid(
											rideDate: _mockRideDate,
											startMileage: _mockStartMileage,
											emptyValue: _mockEmptyValue,
										),
										const SizedBox(height: 26),
										// 3. Secção plataformas base
										const _PlatformsSection(),
										const SizedBox(height: 26),
										// 4. Linha de opções rápidas
										const _QuickOptionsRow(),
										const SizedBox(height: 26),
										// 5. Campo de notas
										const _NotesField(),
										const SizedBox(height: 26 ),
										// 6. Footer — botão salvar
										const _SaveButton(),
										const SizedBox(height: 20),
										// 7. Footer — botão combustível (forma de pagamento)
										const _FuelPaymentButton(),
										const SizedBox(height: 20),
										// 8. Footer — botão para adicionar imagens
										const _AddImagesButton(),
										const SizedBox(height: 20),
										// 9. Legenda de termos abreviados/ingles
										const _TermsLegendSection(),
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
	const _Header({required this.date});

	final String date;

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
					Text(
						date,
						textAlign: TextAlign.center,
						style: textTheme.titleSmall?.copyWith(
							fontStyle: FontStyle.italic,
							fontWeight: FontWeight.w700,
							color: colorScheme.onSurface,
						),
					),
				],
			),
		);
	}
}

// ─── Bloco superior — grelha 3 colunas ───────────────────────────────────────

class _TopDataGrid extends StatelessWidget {
	const _TopDataGrid({
		required this.rideDate,
		required this.startMileage,
		required this.emptyValue,
	});

	final String rideDate;
	final String startMileage;
	final String emptyValue;

	@override
	Widget build(BuildContext context) {
		return IntrinsicHeight(
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [

					// Coluna esquerda (flex 4)
					Expanded(
						flex: 4,
						child: _LeftColumn(rideDate: rideDate, startMileage: startMileage),
					),

					const SizedBox(width: 8),
					// Coluna central (flex 1) — LUCRO

					const Expanded(flex: 1, child: _ProfitColumn()),

					const SizedBox(width: 8),
					// Coluna direita (flex 4)
          
					Expanded(
						flex: 4,
						child: _RightColumn(emptyValue: emptyValue),
					),
				],
			),
		);
	}
}

// ─── Coluna esquerda ──────────────────────────────────────────────────────────

class _LeftColumn extends StatelessWidget {
	const _LeftColumn({required this.rideDate, required this.startMileage});

	final String rideDate;
	final String startMileage;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				_FieldSlot(label: 'DIA do PASSEIO', child: _DateRowMock(value: rideDate)),
				const SizedBox(height: 12),
				_FieldSlot(label: 'KM - IN', child: _StepperRowMock(value: startMileage)),
				const SizedBox(height:12),
				const _FieldSlot(label: 'Hodo-2 - is ZERO?', child: _BinaryRowMock()),
			],
		);
	}
}

// ─── Coluna direita ───────────────────────────────────────────────────────────

class _RightColumn extends StatelessWidget {
	const _RightColumn({required this.emptyValue});

	final String emptyValue;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				_FieldSlot(label: 'CASH - Gas / Energia', child: _StepperRowMock(value: emptyValue)),
				const SizedBox(height: 12),
				_FieldSlot(label: 'KM - OUT', child: _StepperRowMock(value: emptyValue)),
				const SizedBox(height: 12),
				_FieldSlot(label: 'Hodo-2 - NUMBER', child: _StepperRowMock(value: emptyValue)),
			],
		);
	}
}

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
							borderRadius: BorderRadius.circular(2),
							border: Border.all(color: colorScheme.outline),
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
											bottomLeft: Radius.circular(2),
											bottomRight: Radius.circular(2),
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

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					label,
					style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
					overflow: TextOverflow.ellipsis,
				),
				const SizedBox(height: 4),
				child,
			],
		);
	}
}

// ─── Date row ─────────────────────────────────────────────────────────────────

class _DateRowMock extends StatelessWidget {
	const _DateRowMock({required this.value});

	final String value;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 44,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(2),
				border: Border.all(color: colorScheme.outline),
			),
			child: Row(
				children: [
					Expanded(
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 6),
							child: Text(
								value,
								style: textTheme.bodySmall,
								overflow: TextOverflow.ellipsis,
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					SizedBox(
						width: 38,
						child: Tooltip(
							message: 'Selecionar data',
							child: Icon(
								Icons.calendar_month_outlined,
								size: 18,
								color: colorScheme.onSurfaceVariant,
							),
						),
					),
				],
			),
		);
	}
}

// ─── Stepper row ──────────────────────────────────────────────────────────────

class _StepperRowMock extends StatelessWidget {
	const _StepperRowMock({required this.value});

	final String value;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 44,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(2),
				border: Border.all(color: colorScheme.outline),
			),
			child: Row(
				children: [
					Expanded(
						child: Center(child: Text('-', style: textTheme.titleSmall)),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					Expanded(
						flex: 3,
						child: Center(
							child: Text(
								value,
								style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
								overflow: TextOverflow.ellipsis,
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					Expanded(
						child: Center(child: Text('+', style: textTheme.titleSmall)),
					),
				],
			),
		);
	}
}

// ─── Binary row ───────────────────────────────────────────────────────────────

class _BinaryRowMock extends StatelessWidget {
	const _BinaryRowMock();

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;
		final TextTheme textTheme = Theme.of(context).textTheme;

		return Container(
			height: 44,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(2),
				border: Border.all(color: colorScheme.outline),
			),
			child: Row(
				children: [
					Expanded(
						child: Tooltip(
							message: 'Alternar status zerado',
							child: Icon(Icons.circle_outlined, size: 18, color: colorScheme.onSurfaceVariant),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					Expanded(
						flex: 3,
						child: Center(
							child: Text(
								'YES',
								style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
							),
						),
					),
					VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
					Expanded(
						child: Tooltip(
							message: 'Status alternativo',
							child: Icon(Icons.square, size: 18, color: colorScheme.onSurface),
						),
					),
				],
			),
		);
	}
}

// ─── Secção plataformas base ──────────────────────────────────────────────────

class _PlatformsSection extends StatelessWidget {
	const _PlatformsSection();

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				Text(
					'PLATAFORMAS - UTILIZADAS',
					textAlign: TextAlign.center,
					style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
				),
				const SizedBox(height: 6),
				Container(
					decoration: BoxDecoration(
						color: colorScheme.surfaceContainerHighest,
						borderRadius: BorderRadius.circular(4),
						border: Border.all(color: colorScheme.outline),
					),
					padding: const EdgeInsets.all(8),
					child: Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// Card UBER
							const Expanded(child: _PlatformCard(name: 'UBER', totalValue: '€ 55,89', totalRides: '06')),
							const SizedBox(width: 8),
							// Card BOLT
							const Expanded(child: _PlatformCard(name: 'BOLT', totalValue: '€ 10,09', totalRides: '06')),
						],
					),
				),
			],
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
				borderRadius: BorderRadius.circular(4),
				border: Border.all(color: colorScheme.outline),
				color: colorScheme.surface,
			),
			padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
							border: Border.all(color: colorScheme.outline),
							borderRadius: BorderRadius.circular(2),
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
							border: Border.all(color: colorScheme.outline),
							borderRadius: BorderRadius.circular(2),
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
	const _QuickOptionsRow();

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Row(
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				// COM IMAGENS?
				Expanded(
					child: Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							Tooltip(
								message: 'Com imagens',
								child: Icon(Icons.check_circle, color: colorScheme.primary, size: 22),
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
				// Botão + PLATAFORMA (central)
				Column(
					children: [
						Text(
							'PLUS - PL',
							style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
						),
						const SizedBox(height: 4),
						Tooltip(
							message: 'Adicionar plataforma',
							child: Container(
								width: 44,
								height: 44,
								decoration: BoxDecoration(
									shape: BoxShape.circle,
									border: Border.all(color: colorScheme.outline, width: 4),
								),
								child: Icon(Icons.add, color: colorScheme.onSurface),
							),
						),
					],
				),
				// CONCLUÍDO?
				Expanded(
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
								child: Icon(Icons.check_circle, color: colorScheme.primary, size: 22),
							),
						],
					),
				),
			],
		);
	}
}

// ─── Campo de notas ───────────────────────────────────────────────────────────

class _NotesField extends StatelessWidget {
	const _NotesField();

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					'Anotações / Observações',
					style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
				),
				const SizedBox(height: 6),
				Container(
					height: 90,
					width: double.infinity,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(4),
						border: Border.all(color: colorScheme.outline),
					),
					padding: const EdgeInsets.all(10),
					// placeholder: área de texto livre
					child: Text(
						'USANDO ABASTECIMENTO DO DIA / PASSEIO ANTERIOR NESSE MOMENTO',
						style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
					),
				),
			],
		);
	}
}

// ─── Footer — botão salvar ────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
	const _SaveButton();

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
				),
				onPressed: () {
					// TODO: salvar/atualizar passeio
				},
				icon: const Icon(Icons.save_rounded),
				label: const Text('SALVAR / ATUALIZAR esse PASSEIO?'),
			),
		);
	}
}

class _FuelPaymentButton extends StatelessWidget {
	const _FuelPaymentButton();

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
				),
				onPressed: () {
					// TODO: adicionar forma de pagamento do combustivel
				},
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
	const _AddImagesButton();

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
				),
				onPressed: () {
					// TODO: adicionar imagens e anexos da jornada
				},
				icon: const Icon(Icons.image_outlined),
				label: const Text(
					'ADD IMAGENS / ANEXOS? ',
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
					textAlign: TextAlign.center,
					style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
				),
				const SizedBox(height: 8),
				Container(
					decoration: BoxDecoration(
						color: colorScheme.tertiaryContainer,
						borderRadius: BorderRadius.circular(6),
						border: Border.all(color: colorScheme.outline),
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
