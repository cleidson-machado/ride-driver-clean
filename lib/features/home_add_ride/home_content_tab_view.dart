import 'package:flutter/material.dart';

import '../financial_history/financial_history_view.dart';
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
			const _PlaceholderTab(
				icon: Icons.history_rounded,
				title: 'Histórico',
				subtitle: 'Conteúdo em construção.',
			),
			const _PlaceholderTab(
				icon: Icons.delete_outline_rounded,
				title: 'Lixeira',
				subtitle: 'Itens excluídos aparecerão aqui.',
			),
		];

		return Scaffold(
			appBar: AppBar(
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

class _PlaceholderTab extends StatelessWidget {
	const _PlaceholderTab({
		required this.icon,
		required this.title,
		required this.subtitle,
	});

	final IconData icon;
	final String title;
	final String subtitle;

	@override
	Widget build(BuildContext context) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Center(
			child: Padding(
				padding: const EdgeInsets.all(24),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						Icon(icon, size: 36, color: colorScheme.primary),
						const SizedBox(height: 12),
						Text(
							title,
							style: textTheme.titleLarge?.copyWith(
								fontWeight: FontWeight.w700,
							),
						),
						const SizedBox(height: 6),
						Text(
							subtitle,
							textAlign: TextAlign.center,
							style: textTheme.bodyMedium?.copyWith(
								color: colorScheme.onSurfaceVariant,
							),
						),
					],
				),
			),
		);
	}
}


