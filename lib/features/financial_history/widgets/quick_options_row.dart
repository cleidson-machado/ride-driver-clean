import 'package:flutter/material.dart';

// ─── Linha de opções rápidas ──────────────────────────────────────────────────
// Linha com três controles atalho do report: "HAS IMAGES?", botão central de
// adicionar plataforma e "IS FINISHED?". Os extremos atuam como checkboxes
// visuais (tocar alterna o valor); o botão central abre o fluxo de plataforma.
class QuickOptionsRowWidget extends StatelessWidget {
  const QuickOptionsRowWidget({
    super.key,
    required this.hasImages,
    required this.isFinished,
    required this.onHasImagesChanged,
    required this.onIsFinishedChanged,
    required this.onAddPlatform,
  });

  final bool hasImages;
  final bool isFinished;
  final ValueChanged<bool> onHasImagesChanged;
  final ValueChanged<bool> onIsFinishedChanged;
  final VoidCallback onAddPlatform;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // COM IMAGENS?
        Expanded(
          child: InkWell(
            onTap: () => onHasImagesChanged(!hasImages),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Tooltip(
                    message: 'Com imagens',
                    child: Icon(
                      hasImages
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: hasImages
                          ? colorScheme.primary
                          : colorScheme.outline,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'HAS IMAGES?',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Botão + PLATAFORMA (central)
        Column(
          children: [
            Text(
              'ADD - PLAT',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            IconButton.filled(
              tooltip: 'Adicionar plataforma',
              onPressed: onAddPlatform,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                minimumSize: const Size(48, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        // CONCLUÍDO?
        Expanded(
          child: InkWell(
            onTap: () => onIsFinishedChanged(!isFinished),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      'IS FINISHED?',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Concluído',
                    child: Icon(
                      isFinished
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isFinished
                          ? colorScheme.primary
                          : colorScheme.outline,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
