import 'package:meta/meta.dart';
import 'package:txn_parser/src/message_class.dart';

/// A message format known for one bank or app (spec §7.4). Templates are
/// data: adding a bank means adding a template, never changing the
/// pipeline. Named groups the [pattern] may define: `amount` (required),
/// `account`, `payee`, `vpa`, `ref`.
@immutable
final class MessageTemplate {
  /// Creates a template.
  const new({
    required this.id,
    required this.messageClass,
    required this.pattern,
    this.bank,
    this.keywords = const [],
  });

  /// Stable id recorded with each transaction it parses, such as
  /// `hdfc.upi_debit`.
  final String id;

  /// The bank code it applies to (`HDFC`), or null for any sender.
  final String? bank;

  /// Lower-case words that must all appear before the pattern is tried.
  final List<String> keywords;

  /// What a match means.
  final MessageClass messageClass;

  /// The pattern, run on the normalised text.
  final RegExp pattern;

  /// Whether this template should be tried for a message from [bankHint]
  /// whose lower-cased normalised text is [lower].
  bool appliesTo(String? bankHint, String lower) {
    if (bank != null && bank != bankHint) return false;
    return keywords.every(lower.contains);
  }
}

/// Templates shipped with the app.
///
/// Empty on purpose: the spec (§7.5) allows bank templates only where real,
/// anonymised samples exist, and none have been supplied yet. Until then
/// the generic extractors read every message; their results are marked
/// with the `generic` template id and a lower confidence.
const List<MessageTemplate> bundledTemplates = [];
