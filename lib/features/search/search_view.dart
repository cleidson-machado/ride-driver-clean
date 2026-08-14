import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  SearchScope _activeScope = SearchScope.all;
  String _selectedPeriod = 'Últimos 30d';
  String _selectedPlatform = 'Todas';

  static const List<SearchRecord> _allRecords = [
    SearchRecord(
      date: '16 Jul',
      title: 'Uber - Corrida rotina',
      platform: 'Uber',
      description: 'Faturamento do dia',
      value: '+€ 96,40',
      type: SearchType.revenue,
      status: 'Pago',
    ),
    SearchRecord(
      date: '15 Jul',
      title: 'Bolt - Viagem centro',
      platform: 'Bolt',
      description: 'Receita por corrida',
      value: '+€ 74,10',
      type: SearchType.revenue,
      status: 'Pendente',
    ),
    SearchRecord(
      date: '14 Jul',
      title: 'Combustível - Posto',
      platform: 'Estação',
      description: 'Abastecimento semanal',
      value: '-€ 42,90',
      type: SearchType.expense,
      status: 'Pago',
    ),
    SearchRecord(
      date: '12 Jul',
      title: 'Uber - Bônus por meta',
      platform: 'Uber',
      description: 'Incentivo de desempenho',
      value: '+€ 28,00',
      type: SearchType.bonus,
      status: 'Liquido',
    ),
    SearchRecord(
      date: '09 Jul',
      title: 'Receita diária - app',
      platform: 'Tudo',
      description: 'Resumo consolidado',
      value: '+€ 183,30',
      type: SearchType.revenue,
      status: 'Pago',
    ),
    SearchRecord(
      date: '08 Jul',
      title: 'Manutenção - pneus',
      platform: 'Garage',
      description: 'Troca e balanceamento',
      value: '-€ 68,50',
      type: SearchType.expense,
      status: 'Pendente',
    ),
  ];

  List<SearchRecord> get _filteredRecords {
    final String query = _searchController.text.trim().toLowerCase();

    return _allRecords.where((SearchRecord item) {
      final bool matchesScope = _activeScope == SearchScope.all ||
          item.type == _activeScope.type;
      final bool matchesPlatform = _selectedPlatform == 'Todas' ||
          item.platform == _selectedPlatform;
      final bool matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.platform.toLowerCase().contains(query);

      return matchesScope && matchesPlatform && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<SearchRecord> records = _filteredRecords;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Busca financeira',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Filtros de busca',
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SearchBar(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SearchScope.values.map((SearchScope scope) {
                  final bool selected = scope == _activeScope;
                  return ChoiceChip(
                    label: Text(scope.label),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _activeScope = scope);
                    },
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FilterField(
                      label: 'Período',
                      value: _selectedPeriod,
                      items: const ['Últimos 7d', 'Últimos 30d', 'Últimos 90d'],
                      onChanged: (value) => setState(() => _selectedPeriod = value ?? _selectedPeriod),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterField(
                      label: 'Plataforma',
                      value: _selectedPlatform,
                      items: const ['Todas', 'Uber', 'Bolt', 'Estação', 'Garage'],
                      onChanged: (value) => setState(() => _selectedPlatform = value ?? _selectedPlatform),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Resultados',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${records.length} itens',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: records.isEmpty
                    ? _EmptyState(colorScheme: colorScheme, textTheme: textTheme)
                    : LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          if (constraints.maxWidth < 760) {
                            return ListView.separated(
                              itemCount: records.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (BuildContext context, int index) {
                                final SearchRecord record = records[index];
                                return _SearchResultCard(record: record);
                              },
                            );
                          }

                          return SingleChildScrollView(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: DataTable(
                                  columnSpacing: 18,
                                  horizontalMargin: 12,
                                  dataRowMinHeight: 52,
                                  dataRowMaxHeight: 60,
                                  columns: const <DataColumn>[
                                    DataColumn(label: Text('Data')),
                                    DataColumn(label: Text('Descrição')),
                                    DataColumn(label: Text('Plataforma')),
                                    DataColumn(label: Text('Valor')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  rows: records.map((SearchRecord record) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(record.date)),
                                        DataCell(Text(record.title)),
                                        DataCell(Text(record.platform)),
                                        DataCell(
                                          Text(
                                            record.value,
                                            style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: record.type == SearchType.expense
                                                  ? colorScheme.error
                                                  : colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: record.status == 'Pendente'
                                                  ? colorScheme.tertiaryContainer
                                                  : colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              record.status,
                                              style: textTheme.labelSmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: colorScheme.onPrimaryContainer,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Buscar por nome, plataforma ou tipo',
        suffixIcon: IconButton(
          tooltip: 'Limpar busca',
          onPressed: controller.clear,
          icon: const Icon(Icons.close_rounded),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            icon: const Icon(Icons.arrow_drop_down_rounded),
            items: items
                .map(
                  (String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            hint: Text(label),
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.record});

  final SearchRecord record;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool expense = record.type == SearchType.expense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: expense ? colorScheme.errorContainer : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    expense ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                    color: expense ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              record.title,
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            record.value,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: expense ? colorScheme.error : colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Pill(label: record.platform, colorScheme: colorScheme),
                const SizedBox(width: 8),
                _Pill(label: record.date, colorScheme: colorScheme),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.status == 'Pendente'
                        ? colorScheme.tertiaryContainer
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    record.status,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.colorScheme});

  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 42,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Nenhum resultado encontrado',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tente limpar os filtros ou trocar a palavra-chave da busca.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum SearchType {
  all,
  revenue,
  expense,
  bonus;

  SearchType get fromScope => this;

  SearchType? get type => switch (this) {
        SearchType.all => null,
        SearchType.revenue => SearchType.revenue,
        SearchType.expense => SearchType.expense,
        SearchType.bonus => SearchType.bonus,
      };
}

enum SearchScope {
  all('Todos'),
  revenue('Receitas'),
  expense('Despesas'),
  bonus('Bônus');

  const SearchScope(this.label);

  final String label;

  SearchType get type => switch (this) {
    SearchScope.all => SearchType.all,
    SearchScope.revenue => SearchType.revenue,
    SearchScope.expense => SearchType.expense,
    SearchScope.bonus => SearchType.bonus,
  };
}

class SearchRecord {
  const SearchRecord({
    required this.date,
    required this.title,
    required this.platform,
    required this.description,
    required this.value,
    required this.type,
    required this.status,
  });

  final String date;
  final String title;
  final String platform;
  final String description;
  final String value;
  final SearchType type;
  final String status;
}
