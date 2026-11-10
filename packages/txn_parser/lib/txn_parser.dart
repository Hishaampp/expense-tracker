/// Reads Indian bank, card and UPI messages into structured transactions.
///
/// Pure Dart: no Flutter, no I/O, no clock. `TxnParser.parse` never throws.
library;

export 'src/mask.dart' show maskSensitive;
export 'src/message_class.dart';
export 'src/normalise.dart' show normalise;
export 'src/parse_result.dart';
export 'src/parsed_fields.dart';
export 'src/parser.dart';
export 'src/template.dart';
