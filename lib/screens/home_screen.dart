import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme_extension.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final burdahColors = theme.extension<BurdahColors>()!;
    final onGold = theme.colorScheme.onSecondary;

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/burdahs/khadija-ra/reveal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: burdahColors.gold,
            foregroundColor: onGold,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'بردة أم المؤمنين سيدتنا خديجة',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: onGold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Burdah of Sayyida Khadija RA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onGold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
