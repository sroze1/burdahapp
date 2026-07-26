import 'package:flutter/material.dart';

import '../data/models/burdah.dart';

/// A single row in the burdah list — a plain [ListTile], not a card (D-04).
///
/// Shows the Arabic title (RTL) when available, falling back to the
/// English title; the English title is always shown as the subtitle.
class BurdahListRow extends StatelessWidget {
  const BurdahListRow({super.key, required this.burdah, required this.onTap});

  final Burdah burdah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      title: burdah.titleArabic != null
          ? Directionality(
              textDirection: TextDirection.rtl,
              child: Text(burdah.titleArabic!, style: textTheme.titleLarge),
            )
          : Text(burdah.title, style: textTheme.titleLarge),
      subtitle: Text(burdah.title, style: textTheme.bodyMedium),
    );
  }
}
