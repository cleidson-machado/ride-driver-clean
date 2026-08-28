import 'package:flutter/material.dart';

// ─── Botões de rodapé ─────────────────────────────────────────────────────────
// Cinco botões de ação do report (salvar, forma de pagamento, imagens, gastos
// extras e excluir) eram quase idênticos — mesmo container de 52px com ícone,
// borda e raio iguais — diferenciando-se apenas por cores, ícone e rótulo.
//
// Para evitar duplicação, todos delegam para o widget privado _FooterActionButtonWidget,
// que concentra o layout comum. Cada classe pública mantém um nome descritivo no
// call-site (leitura clara) e apenas parametriza as cores/ícone/rótulo do caso.

// ─── Base com layout comum (privada) ─────────────────────────────────────────
class _FooterActionButtonWidget extends StatelessWidget {

  const _FooterActionButtonWidget({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          alignment: Alignment.center,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        onPressed: onPressed,
        icon: icon,
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

// ─── Footer — botão salvar ────────────────────────────────────────────────────
class SaveButtonWidget extends StatelessWidget {

  const SaveButtonWidget({
    super.key,
    required this.isEditing,
    required this.onPressed,
  });

  final bool isEditing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool editing = isEditing;
    return _FooterActionButtonWidget(
      backgroundColor: editing
          ? colorScheme.tertiaryContainer
          : colorScheme.primaryContainer,
      foregroundColor: editing
          ? colorScheme.onTertiaryContainer
          : colorScheme.onPrimaryContainer,
      icon: editing
          ? const Icon(Icons.update_rounded)
          : const Icon(Icons.save_rounded),
      label: editing ? 'ATUALIZAR esse PASSEIO!' : 'SALVAR esse PASSEIO!',
      onPressed: onPressed,
    );
  }
}

// ─── Footer — botão combustível (forma de pagamento) ─────────────────────────
class FuelPaymentButtonWidget extends StatelessWidget {

  const FuelPaymentButtonWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButtonWidget(
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      icon: const Icon(Icons.credit_card_rounded),
      label: 'ADD FORMA PAGAMENTO - Gas / Energia?',
      onPressed: onPressed,
    );
  }
}

// ─── Footer — botão para adicionar imagens ───────────────────────────────────
class AddImagesButtonWidget extends StatelessWidget {

  const AddImagesButtonWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButtonWidget(
      backgroundColor: colorScheme.tertiaryContainer,
      foregroundColor: colorScheme.onTertiaryContainer,
      icon: const Icon(Icons.image_outlined),
      label: 'ADD IMAGENS / ANEXOS? ',
      onPressed: onPressed,
    );
  }
}

// ─── Footer — botão para gastos extras/alimentação ───────────────────────────
class ExtraExpensesButtonWidget extends StatelessWidget {

  const ExtraExpensesButtonWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButtonWidget(
      backgroundColor: colorScheme.surfaceContainerHigh,
      foregroundColor: colorScheme.onSurface,
      icon: const Icon(Icons.receipt_long_outlined),
      label: 'ADD GASTOS EXTRAS / ALIMENTACAO?',
      onPressed: onPressed,
    );
  }
}

// ─── Footer — botão de exclusão do report/passeio ────────────────────────────
class DeleteRideReportButtonWidget extends StatelessWidget {
  
  const DeleteRideReportButtonWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButtonWidget(
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
      icon: const Icon(Icons.delete_forever_rounded),
      label: 'EXCLUIR REPORT / PASSEIO?',
      onPressed: onPressed,
    );
  }
}
