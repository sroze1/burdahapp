import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/burdah.dart';
import '../data/repositories/burdah_repository.dart';
import '../screens/burdah_list_screen.dart';
import '../screens/burdah_reader_screen.dart';
import '../screens/burdah_reveal_screen.dart';
import '../screens/home_screen.dart';

/// App-wide declarative route table (RESEARCH.md Pattern 1).
///
/// Flat (non-nested) route list, `context.push()`/`pushReplacement()`
/// exclusively for forward navigation — never `context.go()` (RESEARCH.md
/// Anti-Patterns). Every route wraps its screen in a [CustomTransitionPage]
/// with a plain [FadeTransition] to satisfy D-08's "gentle fade, not the
/// default Material slide" requirement.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/burdahs',
      pageBuilder: (context, state) =>
          _fadePage(state, const BurdahListScreen()),
    ),
    GoRoute(
      path: '/burdahs/:id/reveal',
      pageBuilder: (context, state) => _fadePage(
        state,
        BurdahRevealScreen(burdahId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/burdahs/:id',
      pageBuilder: (context, state) => _fadePage(
        state,
        BurdahReaderLoader(burdahId: state.pathParameters['id']!),
      ),
    ),
  ],
);

/// Wraps [child] in a [CustomTransitionPage] with a gentle [FadeTransition]
/// (D-08) — shared by every route so no route accidentally falls back to
/// go_router's default Material slide transition.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  );
}

/// Resolves a route's raw `:id` path parameter to a [Burdah] via the
/// repository before rendering [BurdahReaderScreen] — never interpolates
/// the raw id into an asset path directly (RESEARCH.md Pattern 2, Pitfall
/// 5; threat T-03-01).
class BurdahReaderLoader extends StatelessWidget {
  const BurdahReaderLoader({super.key, required this.burdahId});

  final String burdahId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final repo = context.read<BurdahRepository>();
    return FutureBuilder<Burdah?>(
      future: repo.getById(burdahId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final burdah = snapshot.data;
        if (burdah == null) {
          // UI-SPEC Copywriting Contract — error state (established
          // Phase 1, mirrored from design_system_test_screen.dart).
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Something's not right",
                      style: textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "This couldn't be loaded. Please restart the "
                      'app, or reinstall it if the problem continues.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return BurdahReaderScreen(burdah: burdah);
      },
    );
  }
}
