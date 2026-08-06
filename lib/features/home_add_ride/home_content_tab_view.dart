import 'package:flutter/material.dart';

import '../financial_history/financial_history_view.dart';
import '../history/presentation/history_view.dart';
import '../search/presentation/search_view.dart';
import '../trash/presentation/trash_view.dart';
import 'home_add_ride_view.dart';

/// Hub principal com abas compartilhando a mesma NavigationBar.
class HomeContentTabView extends StatefulWidget {
	const HomeContentTabView({super.key});

	@override
	State<HomeContentTabView> createState() => _HomeContentTabViewState();
}

class _HomeContentTabViewState extends State<HomeContentTabView> {
	static const String _mockDate = '16-07-2026 - Segunda-feira';

	int _selectedIndex = 0;

	void _onDestinationSelected(int index) {
		setState(() => _selectedIndex = index);
	}

	void _openFinancialHistory() {
		Navigator.push(
			context,
			MaterialPageRoute<void>(
				builder: (_) => const FinancialHistoryView(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		final List<Widget> children = <Widget>[
			HomeAddRideView(onAddRidePressed: _openFinancialHistory),
			const SearchView(),
			const HistoryView(),
			const TrashView(),
		];

		return Scaffold(
			appBar: AppBar(
				leading: _selectedIndex == 0
						? null
						: IconButton(
								tooltip: 'Voltar para Home',
								onPressed: () => _onDestinationSelected(0),
								icon: const Icon(Icons.arrow_back_rounded),
							),
				centerTitle: true,
				toolbarHeight: 44,
				title: Text(
					_mockDate,
					style: textTheme.titleMedium?.copyWith(
						fontStyle: FontStyle.italic,
						color: colorScheme.onSurfaceVariant,
					),
				),
			),
			body: SafeArea(
				child: IndexedStack(
					index: _selectedIndex,
					children: children,
				),
			),
			bottomNavigationBar: NavigationBar(
				selectedIndex: _selectedIndex,
				onDestinationSelected: _onDestinationSelected,
				destinations: const <NavigationDestination>[
					NavigationDestination(
						icon: Icon(Icons.home_outlined),
						selectedIcon: Icon(Icons.home_rounded),
						label: 'Home',
						tooltip: 'Tela inicial',
					),
					NavigationDestination(
						icon: Icon(Icons.search_rounded),
						label: 'Buscar',
						tooltip: 'Buscar passeios',
					),
					NavigationDestination(
						icon: Icon(Icons.history_outlined),
						selectedIcon: Icon(Icons.history_rounded),
						label: 'Histórico',
						tooltip: 'Histórico de passeios',
					),
					NavigationDestination(
						icon: Icon(Icons.delete_outline_rounded),
						selectedIcon: Icon(Icons.delete_rounded),
						label: 'Lixeira',
						tooltip: 'Itens excluídos',
					),
				],
			),
		);
	}
}


