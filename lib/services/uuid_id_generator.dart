import 'package:expense_tracker/core/id_generator.dart';
import 'package:uuid/uuid.dart';

/// Makes random UUID v4 ids.
final class UuidIdGenerator implements IdGenerator {
  /// Creates the generator.
  const new();

  static const Uuid _uuid = Uuid();

  @override
  String newId() => _uuid.v4();
}
