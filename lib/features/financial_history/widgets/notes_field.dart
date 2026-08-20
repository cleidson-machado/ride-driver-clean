import 'package:flutter/material.dart';

// ─── Campo de notas ───────────────────────────────────────────────────────────
// Field multilinear de anotações/observações do passeio. Recebe o controller
// de texto da view (que o mantém/vive), cuidando apenas da apresentação e do
// decimal de entrada.
class NotesField extends StatelessWidget {
  const NotesField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anotações / Observações',
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          style: textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: 'Escreva observações do passeio…',
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.all(10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }
}
