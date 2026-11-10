/// Makes unique ids for new records. Injected so tests can be deterministic.
abstract interface class IdGenerator {
  /// A new unique id (a UUID v4 in the app).
  String newId();
}
