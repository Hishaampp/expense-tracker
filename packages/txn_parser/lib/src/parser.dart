import 'package:txn_parser/src/amount.dart';
import 'package:txn_parser/src/bank_hints.dart';
import 'package:txn_parser/src/classifier.dart';
import 'package:txn_parser/src/extractors.dart';
import 'package:txn_parser/src/message_class.dart';
import 'package:txn_parser/src/normalise.dart';
import 'package:txn_parser/src/parse_result.dart';
import 'package:txn_parser/src/parsed_fields.dart';
import 'package:txn_parser/src/template.dart';

/// Reads one message: normalise → classify → extract → validate (spec §7.1).
/// Total: never throws, whatever the input.
final class TxnParser {
  /// Creates a parser that tries [templates] before the generic rules.
  const new({this.templates = bundledTemplates});

  /// Known formats, tried first.
  final List<MessageTemplate> templates;

  /// Id recorded when no template matched.
  static const String genericTemplateId = 'generic';

  /// Parses [text], sent by [origin] (an SMS sender ID or app package).
  ParseResult parse(String text, {String? origin}) {
    final normalised = normalise(text);
    final messageClass = classify(normalised);
    final anyAmount = hasAnyAmount(normalised);
    if (!messageClass.createsTransaction) {
      if (messageClass == MessageClass.unknown && anyAmount) {
        return UnparsedMessage(
          messageClass,
          amountPaise: extractAmount(normalised),
        );
      }
      return anyAmount || messageClass != MessageClass.unknown
          ? DroppedMessage(messageClass)
          : NoAmount(messageClass);
    }
    final bank = bankHintFor(origin, normalised);
    final lower = normalised.toLowerCase();
    for (final template in templates) {
      if (template.messageClass != messageClass) continue;
      if (!template.appliesTo(bank, lower)) continue;
      final result = _fromTemplate(template, normalised, bank);
      if (result != null) return result;
    }
    return _generic(messageClass, normalised, bank);
  }

  ParseResult _generic(MessageClass cls, String text, String? bank) {
    final amount = extractAmount(text);
    // A debit or credit whose amount cannot be read is never dropped: the
    // user fills it in from the Unparsed list.
    if (amount == null) return UnparsedMessage(cls);
    final direction = cls == MessageClass.debit
        ? Direction.debit
        : Direction.credit;
    final vpa = extractVpa(text);
    final payee = extractPayeeName(text, direction);
    final account = extractAccountHint(text);
    final ref = extractRefNo(text);
    final fields = ParsedFields(
      amountPaise: amount,
      direction: direction,
      instrument: extractInstrument(text),
      bankHint: bank,
      accountHint: account,
      isCreditCard: mentionsCreditCard(text),
      payeeVpa: vpa,
      payeeName: payee,
      refNo: ref,
      occurredAt: extractDateTime(text),
      availableBalancePaise: extractBalance(text),
    );
    var confidence = 0.5;
    if (account != null) confidence += 0.15;
    if (ref != null) confidence += 0.15;
    if (vpa != null || payee != null) confidence += 0.1;
    if (bank != null) confidence += 0.05;
    return ParsedTransaction(
      messageClass: cls,
      fields: fields,
      templateId: genericTemplateId,
      confidence: confidence,
    );
  }

  ParseResult? _fromTemplate(
    MessageTemplate template,
    String text,
    String? bank,
  ) {
    final match = template.pattern.firstMatch(text);
    if (match == null) return null;
    String? group(String name) =>
        match.groupNames.contains(name) ? match.namedGroup(name) : null;
    final amount = parsePaise(group('amount') ?? '');
    if (amount == null) return null;
    final direction = template.messageClass == MessageClass.debit
        ? Direction.debit
        : Direction.credit;
    final account = group('account');
    return ParsedTransaction(
      messageClass: template.messageClass,
      templateId: template.id,
      confidence: 0.95,
      fields: ParsedFields(
        amountPaise: amount,
        direction: direction,
        instrument: extractInstrument(text),
        bankHint: bank,
        accountHint: account == null || account.length <= 4
            ? account ?? extractAccountHint(text)
            : account.substring(account.length - 4),
        isCreditCard: mentionsCreditCard(text),
        payeeVpa: group('vpa')?.toLowerCase() ?? extractVpa(text),
        payeeName: group('payee')?.trim() ?? extractPayeeName(text, direction),
        refNo: group('ref')?.toUpperCase() ?? extractRefNo(text),
        occurredAt: extractDateTime(text),
        availableBalancePaise: extractBalance(text),
      ),
    );
  }
}
