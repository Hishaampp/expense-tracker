import 'package:meta/meta.dart';
import 'package:txn_parser/src/message_class.dart';
import 'package:txn_parser/src/parsed_fields.dart';

/// What the parser made of one message.
sealed class ParseResult {
  const new(this.messageClass);

  /// The message's class.
  final MessageClass messageClass;
}

/// A payment, refund or receipt: becomes a transaction.
@immutable
final class ParsedTransaction extends ParseResult {
  /// Creates the result.
  const new({
    required MessageClass messageClass,
    required this.fields,
    required this.templateId,
    required this.confidence,
  }) : super(messageClass);

  /// What was read.
  final ParsedFields fields;

  /// The template that matched, or `generic`.
  final String templateId;

  /// How sure the parser is, 0–1.
  final double confidence;
}

/// A message that is about money but is not a transaction: an OTP, a
/// promotion, a reminder, a failed payment. Recorded with its class as
/// the reason, never as a transaction.
@immutable
final class DroppedMessage extends ParseResult {
  /// Creates the result.
  const new(super.messageClass);
}

/// A message with an amount that could not be understood. It must go to
/// the Unparsed list, never be silently dropped (spec §7.2).
@immutable
final class UnparsedMessage extends ParseResult {
  /// Creates the result.
  const new(super.messageClass, {this.amountPaise});

  /// The first amount found, to help the user fill it in.
  final int? amountPaise;
}

/// No amount at all: nothing to record.
@immutable
final class NoAmount extends ParseResult {
  /// Creates the result.
  const new(super.messageClass);
}
