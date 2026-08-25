import 'package:flutter/material.dart';

import '../../../app/helper/ride_formatters.dart';
import '../domain/financial_history_platform_model.dart';

// ─── Secção plataformas ├──────────────────────────────────────────────────────
// Bloco que lista as plataformas usadas no dia em um carrossel paginado. Cada
// página exibe 2 cartões (plataforma OU slot de "adicionar", quando sobra
// posição) e um indicador de dots para navegar entre as páginas. Os dados vêm
// do report ativo (in-memory, via controller) — não há mock aqui.
class PlatformsSectionWidget extends StatefulWidget {
  const PlatformsSectionWidget({
    super.key,
    required this.platforms,
    required this.onEditPlatform,
    required this.onAddPlatform,
  });

  /// Vínculos de plataforma do report ativo.
  final List<FinancialHistoryPlatformModel> platforms;

  /// Abre o fluxo de edição/remoção de uma plataforma existente.
  final ValueChanged<FinancialHistoryPlatformModel> onEditPlatform;

  /// Abre o fluxo de adicionar uma nova plataforma.
  final VoidCallback onAddPlatform;

  @override
  State<PlatformsSectionWidget> createState() => _PlatformsSectionWidgetState();
}

// ─── Secção plataformas base — estado ─────────────────────────────────────────
class _PlatformsSectionWidgetState extends State<PlatformsSectionWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Nº total de slots ocupados: cada plataforma + 1 slot do card "ADD".
  /// O card ADD ocupa o próximo slot livre e, se necessário, abre nova página.
  int get _totalSlots => widget.platforms.length + 1;

  // 2 slots por página do carrossel (mín. 1 página com o card ADD).
  int get _pageCount => (_totalSlots + 1) ~/ 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCardSlot(int slotIndex) {
    // Slot fora do total ocupado: preenche com vazio (evita cartões extras).
    if (slotIndex >= _totalSlots) {
      return const SizedBox.shrink();
    }
    // Slot reservado ao card "ADD - PLATAFORMA" (sempre o último).
    if (slotIndex >= widget.platforms.length) {
      return AddPlatformCardWidget(onTap: widget.onAddPlatform);
    }
    final FinancialHistoryPlatformModel platform = widget.platforms[slotIndex];
    return PlatformCardWidget(
      platform: platform,
      onTap: () => widget.onEditPlatform(platform),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PLATAFORMAS - UTILIZADAS',
          textAlign: TextAlign.left,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              SizedBox(
                height: 190,
                child: Semantics(
                  label:
                      'Carrossel de plataformas, página ${_currentPage + 1} de $_pageCount',
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pageCount,
                    onPageChanged: (int index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (BuildContext context, int pageIndex) {
                      final int firstIndex = pageIndex * 2;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildCardSlot(firstIndex)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildCardSlot(firstIndex + 1)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _PageDotsIndicatorWidget(
                count: _pageCount,
                currentIndex: _currentPage,
                onDotTap: (int index) => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Card filler — adicionar plataforma (slot vazio em página ímpar) ────────
// Cartão exibido quando sobra uma posição no carrossel (última página ímpar).
// Oferece o atalho visual "/ adicionar plataforma".
class AddPlatformCardWidget extends StatelessWidget {
  const AddPlatformCardWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 32,
                color: colorScheme.primary,
                semanticLabel: 'Adicionar plataforma',
              ),
              const SizedBox(height: 8),
              Text(
                'ADD - PLATAFORMA',
                textAlign: TextAlign.center,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Indicador de páginas (dots) ─────────────────────────────────────────────
// Dots de paginação do carrossel. O dot ativo se expande horizontalmente e os
// demais permanecem compactos, mantendo área de toque confortável via padding.
class _PageDotsIndicatorWidget extends StatelessWidget {
  const _PageDotsIndicatorWidget({
    required this.count,
    required this.currentIndex,
    required this.onDotTap,
  });

  final int count;
  final int currentIndex;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool isActive = index == currentIndex;
        return Semantics(
          button: true,
          selected: isActive,
          label: 'Ir para página ${index + 1}',
          child: InkWell(
            onTap: () => onDotTap(index),
            customBorder: const StadiumBorder(),
            child: Padding(
              // Área de toque confortável mantendo o dot pequeno.
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: isActive ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Cartão de plataforma ─────────────────────────────────────────────────────
// Apresenta o nome da plataforma, o valor total do dia e o total de corridas,
// cada um dentro de um mini-container com borda arredondada. Ao tocar, dispara
// o callback de edição/remoção fornecido pela view.
class PlatformCardWidget extends StatelessWidget {
  const PlatformCardWidget({
    super.key,
    required this.platform,
    required this.onTap,
  });

  final FinancialHistoryPlatformModel platform;
  final VoidCallback onTap;

  String get _formattedEarnings =>
      RideFormatters.formatCurrency(platform.dailyEarnings);

  String get _formattedTrips =>
      platform.dailyTripCount.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
            color: colorScheme.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome da plataforma
              Center(
                child: Text(
                  platform.name.toUpperCase(),
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Valor total dia:',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              // valor do dia
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formattedEarnings,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Corridas total dia:',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              // total de corridas
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formattedTrips,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
