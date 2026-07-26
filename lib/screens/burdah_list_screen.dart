import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/burdah.dart';
import '../data/repositories/burdah_repository.dart';
import '../widgets/burdah_list_row.dart';

/// Lists every burdah in the catalog (D-04, NAV-02).
///
/// Sourced from the app-root-injected [BurdahRepository] via
/// `context.read<BurdahRepository>()` — never instantiates
/// `AssetBurdahRepository` directly (RESEARCH.md Provider-DI pattern).
class BurdahListScreen extends StatefulWidget {
  const BurdahListScreen({super.key});

  @override
  State<BurdahListScreen> createState() => _BurdahListScreenState();
}

class _BurdahListScreenState extends State<BurdahListScreen> {
  late final Future<List<Burdah>> _burdahsFuture;

  @override
  void initState() {
    super.initState();
    _burdahsFuture = context.read<BurdahRepository>().getAll();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Burdah Collection')),
      body: SafeArea(
        child: FutureBuilder<List<Burdah>>(
          future: _burdahsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              debugPrint('Burdah catalog load failed: ${snapshot.error}');
              // UI-SPEC Copywriting Contract — error state.
              return Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                child: Column(
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
              );
            }
            final burdahs = snapshot.data ?? const <Burdah>[];
            if (burdahs.isEmpty) {
              // UI-SPEC Copywriting Contract — empty state.
              return Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No burdahs yet', style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'New burdah poems will appear here as more are '
                      'added to the collection.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              itemCount: burdahs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final burdah = burdahs[index];
                return BurdahListRow(
                  burdah: burdah,
                  onTap: () => context.push(
                    burdah.transitionImageAsset != null
                        ? '/burdahs/${burdah.id}/reveal'
                        : '/burdahs/${burdah.id}',
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
