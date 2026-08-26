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

/// Comprimento máximo (em caracteres) para o nome de uma plataforma.
const int _maxPlatformNameLength = 15;

/// Constrói um [InputDecoration] reutilizável para o nome da plataforma.
InputDecoration _platformNameDecoration() => const InputDecoration(
  labelText: 'Nome da plataforma',
  hintText: 'Ex.: UBER, BOLT, 99, PARTICULAR…',
  border: OutlineInputBorder(),
  counterText: '',
);

// ─── Escopo de remoção de plataforma ─────────────────────────────────────────
// Deixa explícito ao usuário a intenção da ação de remoção:
//  - `fromReport`: apenas desvincula do report atual (catálogo permanece ativo);
//  - `fromCatalog`: desvincula e inativa a plataforma no catálogo (não será
//    oferecida em novos reports).
enum PlatformRemovalScope { none, fromReport, fromCatalog }

// ─── Resultado do diálogo de edição de plataforma ────────────────────────────
// [FinancialHistoryPlatformModel] carregado no momento da abertura. A função
// retorna um [PlatformEditResult]. Quando o usuário remove, o [scope] indica o
// alcance da remoção ([PlatformRemovalScope.fromReport] ou ...fromCatalog);
// caso contrário (salvar) o `scope` é `none` e traz os novos
// `name`/`dailyEarnings`/`dailyTripCount`. `null` = cancelar.
class PlatformEditResult {
  const PlatformEditResult({
    required this.name,
    required this.dailyEarnings,
    required this.dailyTripCount,
    this.scope = PlatformRemovalScope.none,
  });

  final String name;
  final double dailyEarnings;
  final int dailyTripCount;
  final PlatformRemovalScope scope;
}

/// Abre o diálogo para editar uma plataforma existente: permite renomear a
/// plataforma (qualquer combinação de maiúsculas/minúsculas, até 15
/// caracteres), alterar o faturamento diário e a quantidade de corridas, ou
/// remover o vínculo.
Future<PlatformEditResult?> showPlatformEditDialog(
  BuildContext context,
  FinancialHistoryPlatformModel platform,
) {
  final TextEditingController nameController = TextEditingController(
    text: platform.name,
  );
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
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext innerContext, StateSetter setDialogState) {
        return AlertDialog(
          title: Text('Plataforma — ${platform.name.toUpperCase()}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  maxLength: _maxPlatformNameLength,
                  decoration: _platformNameDecoration(),
                  textCapitalization: TextCapitalization.characters,
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
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              // Abre o sub-diálogo de confirmação de remoção com escopo claro.
              onPressed: () async {
                final PlatformRemovalScope? scope =
                    await showPlatformRemovalDialog(
                      dialogContext,
                      platform.name,
                    );
                if (scope == null || scope == PlatformRemovalScope.none) {
                  return; // cancelou: mantém o diálogo de edição aberto.
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(
                    PlatformEditResult(
                      name: platform.name,
                      dailyEarnings: platform.dailyEarnings,
                      dailyTripCount: platform.dailyTripCount,
                      scope: scope,
                    ),
                  );
                }
              },
              child: const Text('REMOVER'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
              onPressed: () {
                final String name = nameController.text.trim();
                final double? earnings = double.tryParse(
                  earningsController.text.trim().replaceAll(',', '.'),
                );
                final int? trips = int.tryParse(tripsController.text.trim());
                if (name.isEmpty ||
                    earnings == null ||
                    trips == null ||
                    name.length > _maxPlatformNameLength) {
                  return; // entradas inválidas: mantém o diálogo aberto.
                }
                Navigator.of(dialogContext).pop(
                  PlatformEditResult(
                    name: name,
                    dailyEarnings: earnings,
                    dailyTripCount: trips,
                  ),
                );
              },
              child: const Text('SALVAR'),
            ),
          ],
        );
      },
    ),
  );
}

/// Abre o sub-diálogo de confirmação de remoção de plataforma, com escopo
/// explícito e efeito de cada opção bem definido:
///
///  - "Remover deste report": remove apenas o vínculo do report atual;
///  - "Excluir do catálogo": remove do report **e** inativa a plataforma no
///    catálogo (ação destrutiva, destacada com as cores de erro do tema).
///
/// Retorna o [PlatformRemovalScope] escolhido, ou `null`/`none` se o usuário
/// cancelar. O carrossel volta a oferecer a plataforma apenas se ela
/// permanecer ativa no catálogo.
Future<PlatformRemovalScope?> showPlatformRemovalDialog(
  BuildContext context,
  String platformName,
) {
  return showDialog<PlatformRemovalScope>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text('Remover ${platformName.toUpperCase()}?'),
      content: const Text(
        'Escolha como deseja remover esta plataforma:',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('CANCELAR'),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.tonal(
              // Remoção não destrutiva: somente o vínculo do report atual.
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(PlatformRemovalScope.fromReport),
              child: const Text(
                'Remover deste report',
                // Explica que a plataforma continua no catálogo.
                semanticsLabel:
                    'Remover apenas deste report, mantendo no catálogo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Permanece no catálogo — volta a aparecer em novos reports.',
              style: Theme.of(dialogContext).textTheme.labelSmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              // Ação destrutiva: inativa a plataforma no catálogo.
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(PlatformRemovalScope.fromCatalog),
              child: const Text('Excluir do catálogo'),
            ),
            const SizedBox(height: 4),
            Text(
              'Deixa de ser oferecida em novos reports (reports antigos '
              'permanecem intactos).',
              style: Theme.of(dialogContext).textTheme.labelSmall,
            ),
          ],
        ),
      ],
    ),
  );
}

/// Abre o diálogo para adicionar uma plataforma ao report: o usuário digita o
/// nome livremente (qualquer combinação de maiúsculas/minúsculas, até 15
/// caracteres) e informa o faturamento e as corridas do dia. As plataformas do
/// catálogo ainda não vinculadas são oferecidas como sugestões. O catálogo
/// nunca bloqueia — nomes novos são criados/persistidos pelo controller.
///
/// Retorna o nome digitado e os valores, ou `null` se cancelado.
Future<({String name, double dailyEarnings, int dailyTripCount})?>
showPlatformPickerDialog(BuildContext context, List<PlatformModel> options) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController earningsController = TextEditingController();
  final TextEditingController tripsController = TextEditingController();

  return showDialog<
    ({
      String name,
      double dailyEarnings,
      int dailyTripCount,
    })
  >(
    context: context,
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext innerContext, StateSetter setDialogState) {
        return AlertDialog(
          title: const Text('ADD - PLATAFORMA'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  maxLength: _maxPlatformNameLength,
                  decoration: _platformNameDecoration(),
                  textCapitalization: TextCapitalization.characters,
                ),
                if (options.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Sugestões: plataformas do catálogo ainda não vinculadas.
                  Text(
                    'Sugestões do catálogo (toque para preencher):',
                    style: Theme.of(
                      innerContext,
                    ).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options
                        .map(
                          (PlatformModel platform) => ActionChip(
                            label: Text(platform.name.toUpperCase()),
                            onPressed: () => setDialogState(() {
                              nameController.text = platform.name;
                              nameController.selection =
                                  TextSelection.collapsed(
                                    offset: nameController.text.length,
                                  );
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ],
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
              onPressed: () {
                final String name = nameController.text.trim();
                final double? earnings = double.tryParse(
                  earningsController.text.trim().replaceAll(',', '.'),
                );
                final int? trips = int.tryParse(tripsController.text.trim());
                if (name.isEmpty ||
                    earnings == null ||
                    trips == null ||
                    name.length > _maxPlatformNameLength) {
                  return; // entradas inválidas: mantém o diálogo aberto.
                }
                Navigator.of(dialogContext).pop((
                  name: name,
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
