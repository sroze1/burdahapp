import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/burdah.dart';
import '../data/repositories/burdah_repository.dart';
import '../widgets/transitional_reveal_image.dart';

/// Entry-only transitional reveal shown before the reader opens (D-05,
/// D-06, D-07, D-09).
///
/// Resolves [burdahId] via [BurdahRepository.getById] — never trusts the
/// raw route parameter directly (RESEARCH.md Pattern 2). Once the 2-second
/// glow animation completes, `pushReplacement` swaps this screen out of the
/// navigator stack for the reader, so back-navigation from the reader
/// returns to the list without replaying the reveal (D-07).
class BurdahRevealScreen extends StatelessWidget {
  const BurdahRevealScreen({super.key, required this.burdahId});

  final String burdahId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final repo = context.read<BurdahRepository>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Burdah?>(
        future: repo.getById(burdahId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final burdah = snapshot.data;
          if (burdah == null || burdah.transitionImageAsset == null) {
            // UI-SPEC Copywriting Contract — error state (established
            // Phase 1).
            return Center(
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
            );
          }
          return TransitionalRevealImage(
            assetPath: burdah.transitionImageAsset!,
            onComplete: () {
              if (!context.mounted) return;
              context.pushReplacement('/burdahs/${burdah.id}');
            },
          );
        },
      ),
    );
  }
}
