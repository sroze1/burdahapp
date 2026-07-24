import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/burdah.dart';
import 'burdah_repository.dart';

/// Thrown when the bundled burdah catalog fails to load or parse.
///
/// Consumers should catch this and render the "Something's not right"
/// error-state copy from UI-SPEC's Copywriting Contract instead of letting
/// the exception surface as an unhandled crash (RESEARCH.md Known Threat
/// Patterns — Denial of Service via malformed bundled JSON).
class CatalogLoadException implements Exception {
  final String message;
  const CatalogLoadException(this.message);

  @override
  String toString() => 'CatalogLoadException: $message';
}

/// [BurdahRepository] implementation backed by the bundled JSON manifest
/// at `assets/data/burdah_catalog.json`, loaded via `rootBundle`.
class AssetBurdahRepository implements BurdahRepository {
  static const _assetPath = 'assets/data/burdah_catalog.json';

  @override
  Future<List<Burdah>> getAll() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final entries = decoded['burdahs'] as List<dynamic>;
      final list = entries
          .map((e) => Burdah.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    } on FormatException catch (e) {
      throw CatalogLoadException(
        'Burdah catalog JSON is malformed: ${e.message}',
      );
    } catch (e) {
      throw CatalogLoadException('Failed to load burdah catalog: $e');
    }
  }

  @override
  Future<Burdah?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((b) => b.id == id);
    } on StateError {
      return null;
    }
  }
}
