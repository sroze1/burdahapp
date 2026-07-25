import 'package:flutter/material.dart';

import '../data/models/burdah.dart';
import '../data/repositories/asset_burdah_repository.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/geometric_border_frame.dart';
import '../widgets/geometric_card_frame.dart';
import '../widgets/gold_cta_button.dart';
import 'burdah_reader_screen.dart';

/// Throwaway verification screen for Phase 1 (walking skeleton).
///
/// Not a shipping app screen — it exists solely to prove, end-to-end, that
/// the data layer (JSON catalog → repository → typed model), the theme
/// system (light/dark, gold/green/cream tokens), and the bundled Arabic
/// fonts (Scheherazade New display, Amiri body) all work together before
/// any real screen is built on top of this foundation.
class DesignSystemTestScreen extends StatefulWidget {
  const DesignSystemTestScreen({super.key});

  @override
  State<DesignSystemTestScreen> createState() =>
      _DesignSystemTestScreenState();
}

class _DesignSystemTestScreenState extends State<DesignSystemTestScreen> {
  late final Future<List<Burdah>> _burdahsFuture;

  /// Holds the loaded catalog once the [FutureBuilder] below resolves, so
  /// the `GoldCtaButton` (rendered outside that `FutureBuilder`) can read
  /// the first burdah without re-fetching from the repository.
  List<Burdah> _loadedBurdahs = const <Burdah>[];

  @override
  void initState() {
    super.initState();
    _burdahsFuture = AssetBurdahRepository().getAll();
  }

  void _handleReadBurdahPressed() {
    if (_loadedBurdahs.isEmpty) {
      // Fallback if burdahs haven't loaded yet (e.g. FutureBuilder still
      // waiting or errored) — Phase 1 design-verification no-op.
      // ignore: avoid_print
      print(
        'GoldCtaButton tapped before burdahs loaded (Phase 1 design '
        'verification — no-op)',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BurdahReaderScreen(burdah: _loadedBurdahs.first),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final burdahColors = Theme.of(context).extension<BurdahColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Design System Test')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeading('Catalog Data (ARCH-03)', textTheme),
              const SizedBox(height: 8),
              FutureBuilder<List<Burdah>>(
                future: _burdahsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsetsDirectional.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    debugPrint(
                      'Burdah catalog load failed: ${snapshot.error}',
                    );
                    // UI-SPEC Copywriting Contract — error state.
                    return Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 16,
                      ),
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
                  // Store for the GoldCtaButton below, which lives outside
                  // this FutureBuilder. Plain field assignment (no
                  // setState) — this FutureBuilder already rebuilds when
                  // the future resolves, so no extra rebuild is needed.
                  _loadedBurdahs = burdahs;
                  if (burdahs.isEmpty) {
                    // UI-SPEC Copywriting Contract — empty state.
                    return Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 16,
                      ),
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
                  final first = burdahs.first;
                  return Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(first.title, style: textTheme.titleLarge),
                        if (first.titleArabic != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            first.titleArabic!,
                            style: textTheme.bodyLarge,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const Divider(height: 32),

              _sectionHeading('Scheherazade New — Display (DSGN-02)', textTheme),
              const SizedBox(height: 8),
              // Critical shaping test case (Flutter issue #143975): must
              // include the Alef-Madda ("آ") combination — real words
              // "الآن" (now) and "القرآن" (the Quran, "رآن") — plus
              // diacritic-heavy (tashkīl) text. If letters appear
              // disconnected here, the known Scheherazade New/Lateef
              // ligature-joining bug is present on this Flutter version.
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'الآنَ نَقْرَأُ الْقُرْآنَ الْكَريمَ بِخُشُوعٍ وَإِجْلَال',
                  style: textTheme.displaySmall,
                ),
              ),

              const Divider(height: 32),

              _sectionHeading('Amiri — Body/Label (DSGN-02)', textTheme),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ، الْحَمْدُ لِلَّهِ '
                  'رَبِّ الْعَالَمِينَ',
                  style: textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'بردة أم المؤمنين سيدتنا خديجة',
                  style: textTheme.labelLarge,
                ),
              ),

              const Divider(height: 32),

              _sectionHeading('Color Palette (DSGN-03)', textTheme),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _swatch(
                    'Primary green',
                    Theme.of(context).colorScheme.primary,
                    textTheme,
                  ),
                  _swatch('Gold accent', burdahColors.gold, textTheme),
                  _swatch('Cream', burdahColors.cream, textTheme),
                  _swatch(
                    'Text primary',
                    Theme.of(context).colorScheme.onSurface,
                    textTheme,
                  ),
                  _swatch(
                    'Error',
                    Theme.of(context).colorScheme.error,
                    textTheme,
                  ),
                ],
              ),

              const Divider(height: 32),

              _sectionHeading(
                'Geometric Border Frame (DSGN-01, D-05, D-06, D-07)',
                textTheme,
              ),
              const SizedBox(height: 8),
              // Constrained to the full-screen SVG's own aspect ratio
              // (viewBox 400x600, 2:3) so BoxFit.contain fills the box
              // cleanly with no letterboxed gap — a mismatched demo
              // container aspect ratio would otherwise letterbox the
              // pattern and let the centered content text overlap its
              // edge.
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: AspectRatio(
                    aspectRatio: 400 / 600,
                    child: GeometricBorderFrame(
                      child: Center(
                        child: Text(
                          'Content stays clean inside the border (D-05)',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Divider(height: 32),

              _sectionHeading(
                'Geometric Card Frame (DSGN-01, D-08)',
                textTheme,
              ),
              const SizedBox(height: 8),
              // Constrained to the card SVG's own aspect ratio (viewBox
              // 240x160, 3:2) for the same letterboxing reason as above.
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: AspectRatio(
                    aspectRatio: 240 / 160,
                    child: GeometricCardFrame(
                      child: FutureBuilder<List<Burdah>>(
                        future: _burdahsFuture,
                        builder: (context, snapshot) {
                          final burdahs = snapshot.data ?? const <Burdah>[];
                          final label = burdahs.isNotEmpty
                              ? burdahs.first.title
                              : 'Burdah of Sayyida Khadija RA';
                          return Center(
                            child: Text(
                              label,
                              style: textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const Divider(height: 32),

              _sectionHeading('Gold CTA Button (D-02)', textTheme),
              const SizedBox(height: 8),
              Center(
                child: GoldCtaButton(
                  label: 'Read Burdah',
                  onPressed: _handleReadBurdahPressed,
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String label, TextTheme textTheme) {
    return Text(label, style: textTheme.headlineSmall);
  }

  Widget _swatch(String label, Color color, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: textTheme.labelSmall,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
