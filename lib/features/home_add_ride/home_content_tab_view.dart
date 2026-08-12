import 'package:flutter/material.dart';

import '../financial_history/financial_history_view.dart';
import '../history/presentation/history_view.dart';
import '../search/presentation/search_view.dart';
import '../tour_in_progress/tour_in_progress_view.dart';
import '../trash/trash_view.dart';
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

	void _openTourInProgress() {
		Navigator.push(
			context,
			MaterialPageRoute<void>(
				builder: (_) => const TourInProgressView(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		final List<Widget> children = <Widget>[
			HomeAddRideView(
				onAddRidePressed: _openFinancialHistory,
				onViewInProgressRidePressed: _openTourInProgress,
			),
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
								icon: const BackButtonIcon(),
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
						icon: Icon(Icons.storage_outlined),
						selectedIcon: Icon(Icons.storage_rounded),
						label: 'Dados',
						tooltip: 'Gerenciar dados e armazenamento',
					),
				],
			),
		);
	}
}


