import 'package:flutter/material.dart';

// ─── Campos de formulário reutilizáveis ──────────────────────────────────────
// Conjunto de inputs usados na grelha superior da tela: um slot (label + input),
// o campo de data, o stepper numérico (±) e o campo binário (sim/não).

// ─── Field slot (label + input) ───────────────────────────────────────────────
// This widget is used to wrap each field with a label and the corresponding
// input widget. Mantém a label acima do input com espaçamento e tipografia fixos.
class FieldSlot extends StatelessWidget {
  const FieldSlot({super.key, required this.label, required this.child});

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
// Campo de data exibido como container de 48px: painel clicável com o valor e
// um botão de calendário à direita. Ao tocar em qualquer parte o `onPick` é
// acionado (a view abre o seletor de data).
class DateField extends StatelessWidget {
  const DateField({super.key, required this.value, required this.onPick});

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
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
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
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
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
// Campo numérico trissegmentado (48px): botões − / + nas pontas e o valor
// central (flex 3) que é editável via `onEdit`. Cada segmento expõe rótulo
// semântico para acessibilidade.
class StepperField extends StatelessWidget {
  const StepperField({
    super.key,
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
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: Center(child: Text('-', style: textTheme.titleSmall)),
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
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
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: 'Aumentar $semanticLabel',
              child: InkWell(
                onTap: onIncrement,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
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
// Campo de resposta binária (YES/NO) usado pelo "Hodo-2 - is ZERO?" — tocar
// alterna o valor e os dois indicadores visuais (radio + quadrado) refletem o
// estado atual.
class BinaryField extends StatelessWidget {
  const BinaryField({super.key, required this.value, required this.onChanged});

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
                    color: value
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    value ? 'YES' : 'NO',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
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
