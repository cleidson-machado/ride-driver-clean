import 'package:flutter/material.dart';

// ─── Diálogos da tela ─────────────────────────────────────────────────────────
// MODAL: funções puras que abrem diálogos e retornam o resultado. Não dependem de
// nenhum estado interno, apenas do BuildContext. Mantêm o arquivo principal enxuto e isolam a lógica de UI.
// Funções que abrem os diálogos (prompt numérico e confirmação de exclusão).
// Foram extraídas do State da view para manter o arquivo principal enxuto e
// porque não dependem de nenhum estado interno — recebem apenas o BuildContext.

/// Abre um diálogo que solicita a digitação de um valor numérico.
///
/// Retorna o valor digitado (como [double]) ou `null` se o usuário cancelar.
/// Aceita vírgula como separador decimal. Usado pelos campos numéricos da
/// grelha (KM, CASH, Hodo-2) quando o usuário toca no valor para editar.
Future<double?> promptNumber(
  BuildContext context,
  String title,
  double? current,
) {
  final TextEditingController controller = TextEditingController(
    text: current == null
        ? ''
        : current == current.roundToDouble()
        ? current.round().toString()
        : current.toStringAsFixed(2),
  );
  return showDialog<double>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(hintText: 'Digite o valor'),
        onSubmitted: (String text) => Navigator.of(
          dialogContext,
        ).pop(double.tryParse(text.trim().replaceAll(',', '.'))),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('CANCELAR'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: () => Navigator.of(
            dialogContext,
          ).pop(double.tryParse(controller.text.trim().replaceAll(',', '.'))),
          child: const Text('CONFIRMAR'),
        ),
      ],
    ),
  );
}

/// Abre o diálogo de confirmação para excluir o report/passeio atual.
///
/// Retorna `true` somente se o usuário confirmar a exclusão. O botão de
/// confirmação usa as cores de erro do tema para sinalizar a ação destrutiva.
Future<bool?> confirmDeleteReport(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Excluir report?'),
      content: const Text(
        'Essa ação remove o report/passeio atual. Deseja continuar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('CANCELAR'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 40),
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('EXCLUIR'),
        ),
      ],
    ),
  );
}
