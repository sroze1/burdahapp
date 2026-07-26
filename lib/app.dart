import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget.
///
/// Wires the light and dark [ThemeData] built in `theme/app_theme.dart`,
/// switching between them via the system's `themeMode` (D-03). Navigation
/// is driven by the declarative `go_router` config in `router/app_router.dart`
/// (Phase 3) — see RESEARCH.md Pitfall 1 for why `MaterialApp.router` must
/// be used instead of `MaterialApp(home:)`.
class BurdahApp extends StatelessWidget {
  const BurdahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BurdahApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
