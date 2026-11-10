import 'package:meta/meta.dart';

/// Currencies the app stores. INR only in v1 (spec §3); the enum exists so
/// the scale never becomes a hardcoded `100`.
enum Currency {
  /// Indian rupee: 100 paise to the rupee.
  inr('INR', 100);

  new(this.code, this.minorPerMajor);

  /// ISO-4217 code, as stored in the database.
  final String code;

  /// Minor units (paise) per major unit (rupee).
  final int minorPerMajor;

  /// The currency with [code], or null if the app does not support it.
  static Currency? tryParse(String code) {
    for (final currency in Currency.values) {
      if (currency.code == code) return currency;
    }
    return null;
  }
}

/// An amount of money as whole paise. Never a `double`.
@immutable
final class Money implements Comparable<Money> {
  /// Creates an amount of [paise] in [currency].
  const new(this.paise, [this.currency = Currency.inr]);

  /// Zero rupees.
  static const Money zero = Money(0);

  /// Amount in minor units (paise). May be negative for a net total.
  final int paise;

  /// The currency of [paise].
  final Currency currency;

  /// Whole rupees, truncated toward zero.
  int get wholeRupees => paise ~/ currency.minorPerMajor;

  /// Paise left over after [wholeRupees], always 0–99.
  int get paisePart => paise.abs() % currency.minorPerMajor;

  /// Whether the amount is above zero.
  bool get isPositive => paise > 0;

  /// Whether the amount is below zero.
  bool get isNegative => paise < 0;

  /// This amount split into [parts] equal shares, rounded to the nearest
  /// paisa (halves away from zero). Zero when [parts] is not positive.
  Money dividedRounded(int parts) {
    if (parts <= 0) return Money(0, currency);
    final sign = paise < 0 ? -1 : 1;
    final share = (paise.abs() * 2 + parts) ~/ (parts * 2);
    return Money(sign * share, currency);
  }

  /// The sum of this and [other].
  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(paise + other.paise, currency);
  }

  /// This minus [other].
  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(paise - other.paise, currency);
  }

  void _requireSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('currency mismatch: $currency vs ${other.currency}');
    }
  }

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return paise.compareTo(other.paise);
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.paise == paise && other.currency == currency;

  @override
  int get hashCode => Object.hash(paise, currency);

  @override
  String toString() => 'Money($paise ${currency.code})';
}
