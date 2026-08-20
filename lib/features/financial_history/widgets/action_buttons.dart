import 'package:flutter/material.dart';

// ─── Botões de rodapé ─────────────────────────────────────────────────────────
// Cinco botões de ação do report (salvar, forma de pagamento, imagens, gastos
// extras e excluir) eram quase idênticos — mesmo container de 52px com ícone,
// borda e raio iguais — diferenciando-se apenas por cores, ícone e rótulo.
//
// Para evitar duplicação, todos delegam para o widget privado _FooterActionButton,
// que concentra o layout comum. Cada classe pública mantém um nome descritivo no
// call-site (leitura clara) e apenas parametriza as cores/ícone/rótulo do caso.

// ─── Base com layout comum (privada) ─────────────────────────────────────────
class _FooterActionButton extends StatelessWidget {
  const _FooterActionButton({
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
class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButton(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      icon: const Icon(Icons.save_rounded),
      label: 'SALVAR / ATUALIZAR esse PASSEIO?',
      onPressed: onPressed,
    );
  }
}

// ─── Footer — botão combustível (forma de pagamento) ─────────────────────────
class FuelPaymentButton extends StatelessWidget {
  const FuelPaymentButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButton(
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      icon: const Icon(Icons.credit_card_rounded),
      label: 'ADD FORMA PAGAMENTO - Gas / Energia?',
      onPressed: onPressed,
    );
  }
}

// ─── Footer — botão para adicionar imagens ───────────────────────────────────
class AddImagesButton extends StatelessWidget {
  const AddImagesButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButton(
      backgroundColor: colorScheme.tertiaryContainer,
      foregroundColor: colorScheme.onTertiaryContainer,
      icon: const Icon(Icons.image_outlined),
      label: 'ADD IMAGENS / ANEXOS? ',
      onPressed: onPressed,
    );
  }
}

// ─── Footer — botão para gastos extras/alimentação ───────────────────────────
class ExtraExpensesButton extends StatelessWidget {
  const ExtraExpensesButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButton(
      backgroundColor: colorScheme.surfaceContainerHigh,
      foregroundColor: colorScheme.onSurface,
      icon: const Icon(Icons.receipt_long_outlined),
      label: 'ADD GASTOS EXTRAS / ALIMENTACAO?',
      onPressed: onPressed,
    );
  }
}

// ─── Footer — botão de exclusão do report/passeio ────────────────────────────
class DeleteRideReportButton extends StatelessWidget {
  const DeleteRideReportButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _FooterActionButton(
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
      icon: const Icon(Icons.delete_forever_rounded),
      label: 'EXCLUIR REPORT / PASSEIO?',
      onPressed: onPressed,
    );
  }
}
