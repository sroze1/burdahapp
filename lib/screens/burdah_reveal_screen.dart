import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/models/burdah.dart';
import '../data/repositories/burdah_repository.dart';

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
          return _RevealContent(
            burdah: burdah,
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

class _RevealContent extends StatelessWidget {
  const _RevealContent({required this.burdah, required this.onComplete});

  final Burdah burdah;
  final VoidCallback onComplete;

  static List<double> _saturationMatrix(double s) {
    final sr = 0.2126 * (1 - s);
    final sg = 0.7152 * (1 - s);
    final sb = 0.0722 * (1 - s);
    return [
      sr + s, sg, sb, 0, 0,
      sr, sg + s, sb, 0, 0,
      sr, sg, sb + s, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    const glowColor = Color(0xFFF5E6C8);

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox.expand(
            child: Image.asset(
              burdah.transitionImageAsset!,
              fit: BoxFit.cover,
            ),
          )
              .animate(onComplete: (_) => onComplete())
              .fadeIn(duration: 600.ms, curve: Curves.easeIn)
              .then()
              .custom(
                duration: 800.ms,
                builder: (context, value, child) => ColorFiltered(
                  colorFilter: ColorFilter.matrix(
                    _saturationMatrix(1.0 + 0.4 * value),
                  ),
                  child: child,
                ),
              )
              .then()
              .custom(
                duration: 2000.ms,
                builder: (context, value, child) => ColorFiltered(
                  colorFilter: ColorFilter.matrix(
                    _saturationMatrix(1.4),
                  ),
                  child: child,
                ),
              )
              .then()
              .fadeOut(duration: 600.ms, curve: Curves.easeOut),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'السَّلَامُ عَلَيْكِ يَا أُمَّ الْمُؤْمِنِينَ',
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'As-salāmu ʿalayki yā Umm al-Muʾminīn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Peace be upon you, O Mother of the Believers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeIn)
              .then()
              .custom(
                duration: 800.ms,
                builder: (context, value, child) => DefaultTextStyle.merge(
                  style: TextStyle(
                    shadows: [
                      Shadow(
                        color: glowColor.withValues(alpha: 0.9 * value),
                        blurRadius: 30 * value,
                      ),
                    ],
                  ),
                  child: child,
                ),
              )
              .then()
              .custom(
                duration: 2000.ms,
                builder: (context, value, child) {
                  final breath = math.sin(value * 2 * math.pi);
                  final alpha = 0.7 + 0.25 * breath;
                  final blur = 25.0 + 12.0 * breath;
                  return DefaultTextStyle.merge(
                    style: TextStyle(
                      shadows: [
                        Shadow(
                          color: glowColor.withValues(alpha: alpha),
                          blurRadius: blur,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
              )
              .then()
              .fadeOut(duration: 600.ms, curve: Curves.easeOut),
        ),
      ],
    );
  }
}
