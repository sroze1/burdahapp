import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/asset_burdah_repository.dart';
import 'data/repositories/burdah_repository.dart';

void main() {
  // Hard offline guarantee: fonts load exclusively from the bundled
  // assets/google_fonts/ files, never fetched over the network. Must be
  // set before runApp() — see RESEARCH.md Code Examples.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(
    Provider<BurdahRepository>(
      create: (_) => AssetBurdahRepository(),
      child: const BurdahApp(),
    ),
  );
}
