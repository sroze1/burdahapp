import '../models/burdah.dart';

/// Abstract data-access contract for the burdah catalog.
///
/// Screens and widgets depend on this interface, never on a concrete
/// implementation directly — keeps the data source (bundled JSON today,
/// potentially something else later) swappable without touching consumers.
abstract class BurdahRepository {
  /// Returns every burdah in the catalog, sorted by `sortOrder`.
  ///
  /// Returns an empty list (never throws) when the catalog is empty — an
  /// empty list is a valid state; consumers render the "No burdahs yet"
  /// empty-state copy (per UI-SPEC Copywriting Contract).
  Future<List<Burdah>> getAll();

  /// Returns the burdah with the given [id], or `null` if not found.
  Future<Burdah?> getById(String id);
}
