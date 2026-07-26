import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// The app's animated opening experience (D-01 through D-06).
///
/// Mirrors the animation-chain pattern established by
/// `_RevealContent` in `burdah_reveal_screen.dart`: a Madinah sunset image
/// fades in and builds saturation/glow, three lines of Bismillah text fade
/// in with a breathing golden glow, all timed to roughly match the 6.1s
/// Qari Abdul Basit recitation clip playing alongside. When the image
/// chain's animation completes, the splash crossfades into the Home screen
/// via `pushReplacement('/home')` (D-06), relying on the router's shared
/// `_fadePage` transition for the overlap.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playRecitation();
  }

  /// Plays the trimmed Bismillah recitation clip (D-05, SPLSH-02).
  ///
  /// Configures the iOS silent-switch behaviour via `respectSilence: true`
  /// (SPLSH-04 partial — RESEARCH Pattern 2) so the clip honours the
  /// device's mute switch rather than always playing. Wrapped in try-catch
  /// (threat T-04-02) so any audio failure never crashes or hangs the
  /// splash — the visual animation continues regardless.
  Future<void> _playRecitation() async {
    try {
      await _player.setAudioContext(
        AudioContextConfig(respectSilence: true).build(),
      );
      await _player.play(AssetSource('audio/bismillah_trimmed.mp3'));
    } catch (_) {
      // Audio is a reverent accompaniment, not a requirement — the
      // splash animation must always continue even if playback fails.
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _onSplashComplete() {
    if (!mounted) return;
    context.pushReplacement('/home');
  }

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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // D-01: Madinah sunset image, top 3/5 of the screen.
          Expanded(
            flex: 3,
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/madinah_sunset.png',
                fit: BoxFit.cover,
              ),
            )
                .animate(onComplete: (_) => _onSplashComplete())
                .fadeIn(duration: 900.ms, curve: Curves.easeIn)
                .then()
                .custom(
                  duration: 1200.ms,
                  builder: (context, value, child) => ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      _saturationMatrix(1.0 + 0.4 * value),
                    ),
                    child: child,
                  ),
                )
                .then()
                .custom(
                  duration: 2800.ms,
                  builder: (context, value, child) => ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      _saturationMatrix(1.4),
                    ),
                    child: child,
                  ),
                )
                .then()
                .fadeOut(duration: 1200.ms, curve: Curves.easeOut),
          ),
          // D-02: three-line Bismillah text block, bottom 2/5 of the screen.
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bismillāhir Raḥmānir Raḥīm',
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
                    'In the name of Allah, the Most Gracious, '
                    'the Most Merciful',
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
                .fadeIn(duration: 900.ms, curve: Curves.easeIn)
                .then()
                .custom(
                  duration: 1200.ms,
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
                  duration: 2800.ms,
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
                .fadeOut(duration: 1200.ms, curve: Curves.easeOut),
          ),
        ],
      ),
    );
  }
}
