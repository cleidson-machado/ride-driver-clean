import 'package:flutter/material.dart';

// ─── Campos de formulário reutilizáveis ──────────────────────────────────────
// Conjunto de inputs usados na grelha superior da tela: um slot (label + input),
// o campo de data, o stepper numérico (±) e o campo binário (sim/não).

// ─── Field slot (label + input) ───────────────────────────────────────────────
// This widget is used to wrap each field with a label and the corresponding
// input widget. Mantém a label acima do input com espaçamento e tipografia fixos.
class FieldSlotWidget extends StatelessWidget {
  const FieldSlotWidget({super.key, required this.label, required this.child});

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
class DateFieldWidget extends StatelessWidget {
  const DateFieldWidget({super.key, required this.value, required this.onPick});

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
class StepperFieldWidget extends StatelessWidget {
  const StepperFieldWidget({
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
// Campo de resposta binária (YES/NO) usado pelo "Hodo-2 - is ZERO?".
// Refatorado para um alternador segmentado (estilo M3 segmented button):
// dois segmentos destacam o estado ativo com a cor primária, mantendo a mesma
// altura (48px), o mesmo raio/borda e o equilíbrio visual dos demais campos da
// grelha (DateFieldWidget/StepperFieldWidget). Tocar num segmento alterna o
// valor; não dispara persistência própria, apenas atualiza o estado local.
class BinaryFieldWidget extends StatelessWidget {
  const BinaryFieldWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BinarySegment(
              label: 'NO',
              isActive: !value,
              activeColor: colorScheme.onSurfaceVariant,
              iconData: Icons.do_not_disturb_on_outlined,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: _BinarySegment(
              label: 'YES',
              isActive: value,
              activeColor: colorScheme.primary,
              iconData: Icons.event_available,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmento individual do [BinaryFieldWidget]. Utiliza `AnimatedContainer`
/// (M3) para a transição suave de cor/preenchimento em cada estado.
class _BinarySegment extends StatelessWidget {
  const _BinarySegment({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.iconData,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final IconData iconData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Color background = isActive ? activeColor : Colors.transparent;
    final Color foreground = isActive
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isActive,
      label: '$label — ${isActive ? 'ativo' : 'inativo'}',
      child: Tooltip(
        message: isActive ? '$label está marcado' : 'Marcar como $label',
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(9),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconData,
                    size: 15,
                    color: foreground,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

