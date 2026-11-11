/// A device-local calendar day, stored as whole days since 1970-01-01.
///
/// Rooms keep their dates this way (spec §9.1), so a trip from 10 to 12
/// November stays those days whatever time zone the phone is in later.
extension type const LocalDay(int value) implements Object {
  /// The local day that [instant] falls on.
  factory of(DateTime instant) {
    final local = instant.toLocal();
    final utcDate = DateTime.utc(local.year, local.month, local.day);
    return LocalDay(
      utcDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay,
    );
  }

  /// Local midnight at the start of this day.
  DateTime get date {
    final utc = DateTime.fromMillisecondsSinceEpoch(
      value * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return DateTime(utc.year, utc.month, utc.day);
  }

  /// The day [days] later (earlier when negative).
  LocalDay plus(int days) => LocalDay(value + days);

  /// Whole days from [other] to this day.
  int since(LocalDay other) => value - other.value;

  /// Whether this day is before [other].
  bool isBefore(LocalDay other) => value < other.value;

  /// Whether this day is after [other].
  bool isAfter(LocalDay other) => value > other.value;
}
