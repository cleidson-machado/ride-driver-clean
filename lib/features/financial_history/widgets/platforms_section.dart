import 'package:flutter/material.dart';

// ─── Secção plataformas ├──────────────────────────────────────────────────────
// Bloco que lista as plataformas usadas no dia em um carrossel paginado. Cada
// página exibe 2 cartões (plataforma OU slot de "adicionar", quando sobra
// posição) e um indicador de dots para navegar entre as páginas.
class PlatformsSection extends StatefulWidget {
  const PlatformsSection({super.key, required this.onAddPlatform});

  final VoidCallback onAddPlatform;

  @override
  State<PlatformsSection> createState() => _PlatformsSectionState();
}

// ─── Secção plataformas base — estado ─────────────────────────────────────────
class _PlatformsSectionState extends State<PlatformsSection> {
  // Dados mock — uma plataforma por página do carrossel (máx. 3).
  static const List<({String name, String totalValue, String totalRides})>
  _platforms = [
    (name: 'UBER', totalValue: '€ 55,89', totalRides: '06'),
    (name: 'BOLT', totalValue: '€ 10,09', totalRides: '06'),
    (name: 'FREENOW', totalValue: '€ 0,00', totalRides: '00'),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 2 plataformas por página do carrossel.
  int get _pageCount => (_platforms.length + 1) ~/ 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCardSlot(int platformIndex) {
    if (platformIndex >= _platforms.length) {
      return AddPlatformCard(onTap: widget.onAddPlatform);
    }
    final platform = _platforms[platformIndex];
    return PlatformCard(
      name: platform.name,
      totalValue: platform.totalValue,
      totalRides: platform.totalRides,
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
              _PageDotsIndicator(
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
class AddPlatformCard extends StatelessWidget {
  const AddPlatformCard({super.key, required this.onTap});

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
                'Sem plataforma\nneste slot',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ADD - PLAT',
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
class _PageDotsIndicator extends StatelessWidget {
  const _PageDotsIndicator({
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
// cada um dentro de um mini-container com borda arredondada.
class PlatformCard extends StatelessWidget {
  const PlatformCard({
    super.key,
    required this.name,
    required this.totalValue,
    required this.totalRides,
  });

  final String name;
  final String totalValue;
  final String totalRides;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
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
              name,
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
          // placeholder valor
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              totalValue,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Corridas total dia:',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          // placeholder corridas
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              totalRides,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
