import 'package:flutter/material.dart';

import '../domain/financial_history_platform_model.dart';
import '../domain/platform_model.dart';

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
Future<double?> showNumberPromptDialog(
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
Future<bool?> showDeleteReportDialog(BuildContext context) {
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

// ─── Resultado do diálogo de edição de plataforma ────────────────────────────
// [FinancialHistoryPlatformModel] carregado no momento da abertura. A função
// retorna um [PlatformEditResult]: `remove: true` indica exclusão do vínculo;
// caso contrário traz os novos `dailyEarnings`/`dailyTripCount`. `null` = cancelar.
class PlatformEditResult {
  const PlatformEditResult({
    required this.dailyEarnings,
    required this.dailyTripCount,
    this.remove = false,
  });

  final double dailyEarnings;
  final int dailyTripCount;
  final bool remove;
}

/// Abre o diálogo para editar uma plataforma existente: permite alterar o
/// faturamento diário e a quantidade de corridas, ou remover o vínculo.
Future<PlatformEditResult?> showPlatformEditDialog(
  BuildContext context,
  FinancialHistoryPlatformModel platform,
) {
  final TextEditingController earningsController = TextEditingController(
    text: platform.dailyEarnings == platform.dailyEarnings.roundToDouble()
        ? platform.dailyEarnings.round().toString()
        : platform.dailyEarnings.toStringAsFixed(2),
  );
  final TextEditingController tripsController = TextEditingController(
    text: platform.dailyTripCount.toString(),
  );

  return showDialog<PlatformEditResult>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text('Plataforma — ${platform.name.toUpperCase()}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: earningsController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Faturamento do dia (€)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tripsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Corridas do dia',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          // Remove o vínculo — sinalizado via `remove: true`.
          onPressed: () => Navigator.of(dialogContext).pop(
            PlatformEditResult(
              dailyEarnings: platform.dailyEarnings,
              dailyTripCount: platform.dailyTripCount,
              remove: true,
            ),
          ),
          child: const Text('REMOVER'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('CANCELAR'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: () {
            final double? earnings = double.tryParse(
              earningsController.text.trim().replaceAll(',', '.'),
            );
            final int? trips = int.tryParse(tripsController.text.trim());
            if (earnings == null || trips == null) {
              return; // entradas inválidas: mantém o diálogo aberto.
            }
            Navigator.of(dialogContext).pop(
              PlatformEditResult(
                dailyEarnings: earnings,
                dailyTripCount: trips,
              ),
            );
          },
          child: const Text('SALVAR'),
        ),
      ],
    ),
  );
}

/// Abre o diálogo para vincular uma plataforma do catálogo ao report: o
/// usuário escolhe uma [PlatformModel] entre as disponíveis e informa o
/// faturamento e as corridas do dia. Retorna `null` se cancelado.
Future<({PlatformModel platform, double dailyEarnings, int dailyTripCount})?>
showPlatformPickerDialog(BuildContext context, List<PlatformModel> options) {
  PlatformModel? selected = options.isNotEmpty ? options.first : null;
  final TextEditingController earningsController = TextEditingController();
  final TextEditingController tripsController = TextEditingController();

  return showDialog<
    ({
      PlatformModel platform,
      double dailyEarnings,
      int dailyTripCount,
    })
  >(
    context: context,
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext innerContext, StateSetter setDialogState) {
        return AlertDialog(
          title: const Text('ADD - PLATAFORMA'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (options.isEmpty)
                const Text('Nenhuma plataforma disponível no catálogo.')
              else
                DropdownButtonFormField<PlatformModel>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Plataforma',
                    border: OutlineInputBorder(),
                  ),
                  items: options
                      .map(
                        (PlatformModel platform) => DropdownMenuItem<
                          PlatformModel
                        >(value: platform, child: Text(platform.name)),
                      )
                      .toList(),
                      onChanged: (PlatformModel? value) => setDialogState(
                        () => selected = value,
                      ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: earningsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Faturamento do dia (€)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tripsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Corridas do dia',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
              onPressed: selected == null
                  ? null
                  : () {
                      final double? earnings = double.tryParse(
                        earningsController.text.trim().replaceAll(',', '.'),
                      );
                      final int? trips = int.tryParse(
                        tripsController.text.trim(),
                      );
                      if (earnings == null || trips == null) return;
                      Navigator.of(dialogContext).pop((
                        platform: selected!,
                        dailyEarnings: earnings,
                        dailyTripCount: trips,
                      ));
                    },
              child: const Text('CONFIRMAR'),
            ),
          ],
        );
      },
    ),
  );
}
