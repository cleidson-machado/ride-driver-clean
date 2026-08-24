import 'package:flutter/material.dart';

// ─── Secção de legenda de termos ──────────────────────────────────────────────
// Conjunto de "verbetes" com os termos abreviados/em inglês usados na tela e
// seu significado. Ajuda o condutor a entender rótulos como KM - IN, L1 etc.
class TermsLegendSectionWidget extends StatelessWidget {
  const TermsLegendSectionWidget({super.key});

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
              _DictionaryRowWidget(
                term: 'L1',
                description: 'LUCRO simples, sem VALOR Gas/Energia do DIA!',
              ),
              const SizedBox(height: 6),
              _DictionaryRowWidget(
                term: 'KM - IN',
                description: 'Quilometragem inicial no comeco da jornada.',
              ),
              const SizedBox(height: 6),
              _DictionaryRowWidget(
                term: 'KM - OUT',
                description: 'Quilometragem final ao encerrar o dia.',
              ),
              const SizedBox(height: 6),
              _DictionaryRowWidget(
                term: 'PLUS - PL',
                description: 'Adiciona novas plataformas e afins.',
              ),
              const SizedBox(height: 6),
              _DictionaryRowWidget(
                term: 'HAS IMAGES?',
                description:
                    'Indica no relatorio se existem imagens anexadas para apoiar os registros do dia.',
              ),
              const SizedBox(height: 6),
              _DictionaryRowWidget(
                term: 'IS FINISHED?',
                description:
                    'Indica no relatorio se o dia de trabalho foi concluido e fechado corretamente.',
              ),
              const SizedBox(height: 6),
              _DictionaryRowWidget(
                term: 'Hodo-2 - is ZERO?',
                description:
                    'Lembrete para o usuario zerar o hodometro 2 antes de iniciar as corridas.',
              ),
              const SizedBox(height: 6),
              _DictionaryRowWidget(
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

// ─── Linha do dicionário (termo + descrição) ─────────────────────────────────
// Renderiza "TERMO: descrição" com o termo em negrito para leitura rápida.
class _DictionaryRowWidget extends StatelessWidget {
  const _DictionaryRowWidget({required this.term, required this.description});

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
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          TextSpan(text: description),
        ],
      ),
    );
  }
}
