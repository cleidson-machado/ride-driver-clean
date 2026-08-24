import 'package:flutter/material.dart';

import 'app/di/service_locator.dart';
import 'app/theme/app_theme.dart';
import 'features/home_add_ride/home_content_tab_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  // TODO: outras inicializações futuras (.env, etc.) entram aqui.
  runApp(const RideDriverApp());
}

/// Raiz do app: conecta tema central M3 e redireciona para a Home.
class RideDriverApp extends StatelessWidget {
  const RideDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeContentTabView(),
    );
  }
}
