/// Typed representation of a single burdah catalog entry.
///
/// Instances are built exclusively via [Burdah.fromJson] from the bundled
/// `assets/data/burdah_catalog.json` manifest — see
/// `AssetBurdahRepository` for the loading path. New burdahs are added by
/// appending an object to that JSON file; this class never needs to change
/// as long as new fields stay optional (ARCH-03 extensibility contract).
class Burdah {
  final String id;
  final String title;
  final String? titleArabic;
  final String pdfAsset;
  final int sortOrder;

  /// Optional path to a full-screen transitional reveal image shown before
  /// the reader opens (D-05/D-09). Stays optional per the ARCH-03
  /// extensibility contract — future burdahs may omit it, in which case the
  /// reveal step is skipped entirely (see BurdahListScreen).
  final String? transitionImageAsset;

  const Burdah({
    required this.id,
    required this.title,
    this.titleArabic,
    required this.pdfAsset,
    required this.sortOrder,
    this.transitionImageAsset,
  });

  /// Builds a [Burdah] from a decoded JSON map.
  ///
  /// Throws a [FormatException] with a descriptive message when a required
  /// field (`id`, `title`, `pdfAsset`) is missing or has the wrong type,
  /// rather than letting a raw type-cast error escape as an unhandled
  /// crash (Security Domain V5 / RESEARCH.md Known Threat Patterns).
  factory Burdah.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final pdfAsset = json['pdfAsset'];

    if (id is! String || id.isEmpty) {
      throw FormatException(
        'Burdah.fromJson: missing or invalid required field "id" in $json',
      );
    }
    if (title is! String || title.isEmpty) {
      throw FormatException(
        'Burdah.fromJson: missing or invalid required field "title" in $json',
      );
    }
    if (pdfAsset is! String || pdfAsset.isEmpty) {
      throw FormatException(
        'Burdah.fromJson: missing or invalid required field "pdfAsset" in $json',
      );
    }

    return Burdah(
      id: id,
      title: title,
      titleArabic: json['titleArabic'] as String?,
      pdfAsset: pdfAsset,
      sortOrder: json['sortOrder'] as int? ?? 0,
      transitionImageAsset: json['transitionImageAsset'] as String?,
    );
  }
}
