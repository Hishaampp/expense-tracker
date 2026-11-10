import 'package:expense_tracker/core/failure.dart';

/// The outcome of a fallible operation: [Ok] with a value or [Err] with a
/// typed [Failure]. Switch on it exhaustively; never add a `default`.
sealed class Result<T, F extends Failure> {
  const new();
}

/// A successful [Result] carrying [value].
final class Ok<T, F extends Failure> extends Result<T, F> {
  /// Creates a success.
  const new(this.value);

  /// The produced value.
  final T value;
}

/// A failed [Result] carrying [failure].
final class Err<T, F extends Failure> extends Result<T, F> {
  /// Creates a failure.
  const new(this.failure);

  /// Why the operation failed.
  final F failure;
}
