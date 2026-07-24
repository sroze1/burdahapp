import 'package:flutter/material.dart';

import 'screens/design_system_test_screen.dart';
import 'theme/app_theme.dart';

/// Root application widget.
///
/// Wires the light and dark [ThemeData] built in `theme/app_theme.dart`,
/// switching between them via the system's `themeMode` (D-03). The home
/// route is this phase's throwaway verification screen — real navigation
/// (go_router) is configured starting Phase 3.
class BurdahApp extends StatelessWidget {
  const BurdahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BurdahApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const DesignSystemTestScreen(),
    );
  }
}
