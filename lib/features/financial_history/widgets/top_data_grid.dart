import 'package:flutter/material.dart';

// ─── Bloco superior — grelha 3 colunas ───────────────────────────────────────
// Grelha de 3 colunas (proporção 4:1:4): recebe as colunas esquerda e direita
// já montadas pela view (campos do formulário) e insere, ao centro, o indicador
// de lucro (_ProfitColumn). O `IntrinsicHeight` faz todas as colunas terem a
// altura da maior delas.
class TopDataGridWidget extends StatelessWidget {
  const TopDataGridWidget({
    super.key,
    required this.leftColumn,
    required this.rightColumn,
  });

  final Widget leftColumn;
  final Widget rightColumn;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Coluna esquerda (flex 4)
          Expanded(flex: 4, child: leftColumn),

          // Coluna central (flex 1) — LUCRO
          const SizedBox(width: 8),

          // Local no qual o widget ProfitColumnWidget é renderizado.
          // Ele exibe um indicador visual de lucro, com uma barra de progresso
          // preenchida inferiormente e um rótulo "L1".
          const Expanded(flex: 1, child: ProfitColumnWidget()),

          // Coluna direita (flex 4)
          const SizedBox(width: 8),

          // Expanded criado para a coluna direita, criando espaço entre a
          // coluna central e a coluna direita.
          Expanded(flex: 4, child: rightColumn),
        ],
      ),
    );
  }
}

// ─── Coluna central — indicador LUCRO ────────────────────────────────────────
// Indicador visual de lucro ("L1") com um recipiente cuja parte inferior é
// preenchida por uma barra (placeholder de progresso). A altura acompanha a
// grelha via flex da coluna central.
class ProfitColumnWidget extends StatelessWidget {
  const ProfitColumnWidget({super.key});

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
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
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
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
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
