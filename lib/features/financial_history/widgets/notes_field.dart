import 'package:flutter/material.dart';

// ─── Campo de notas ───────────────────────────────────────────────────────────
// Field multilinear de anotações/observações do passeio. Recebe o controller
// de texto da view (que o mantém/vive), cuidando apenas da apresentação e do
// decimal de entrada.
//
// UX do placeholder: segue o padrão de mercado — o texto de aviso some assim
// que o campo recebe foco (ou é preenchido), e volta apenas quando o campo é
// deixado vazio e sem foco. A cor do hint é bem mais sutil que o texto digitado
// para evitar confusão visual.
class NotesFieldWidget extends StatefulWidget {
  const NotesFieldWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<NotesFieldWidget> createState() => _NotesFieldWidgetState();
}

class _NotesFieldWidgetState extends State<NotesFieldWidget> {
  static const String _hint = 'Algo que vale lembrar deste passeio / corrida…';

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
        ListenableBuilder(
          listenable: _focusNode,
          builder: (BuildContext context, Widget? child) {
            // Hint some ao focar/preencher; reaparece só quando vazio e sem foco.
            final bool showHint =
                !_focusNode.hasFocus && widget.controller.text.isEmpty;
            return TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: showHint ? _hint : null,
                hintStyle: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.38),
                  fontStyle: FontStyle.italic,
                ),
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
            );
          },
        ),
      ],
    );
  }
}
