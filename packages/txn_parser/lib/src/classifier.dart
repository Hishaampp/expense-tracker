import 'package:txn_parser/src/message_class.dart';

/// Decides what kind of message [normalised] text is. Rules run in a fixed
/// order; the first that matches wins, so a message that both says
/// "refund" and "credited" is a refund.
MessageClass classify(String normalised) {
  final text = normalised.toLowerCase();
  if (_otp.hasMatch(text)) return MessageClass.otp;
  if (_collect.hasMatch(text)) return MessageClass.collectRequest;
  if (_statement.hasMatch(text)) return MessageClass.statement;
  if (_cardBillDue.hasMatch(text)) return MessageClass.cardBillDue;
  if (_upcoming.hasMatch(text)) return MessageClass.upcomingOrMandate;
  if (_reversal.hasMatch(text)) return MessageClass.reversalRefund;
  if (_failed.hasMatch(text)) return MessageClass.failed;
  final debit = _debit.firstMatch(text);
  final credit = _credit.firstMatch(text);
  if (debit == null && credit == null) {
    if (_promo.hasMatch(text)) return MessageClass.promo;
    if (_balance.hasMatch(text)) return MessageClass.balanceInfo;
    return MessageClass.unknown;
  }
  // "Debited from your a/c and credited to X" is a debit: the first verb
  // describes the user's own account.
  if (credit == null) return MessageClass.debit;
  if (debit == null) return MessageClass.credit;
  return debit.start <= credit.start ? MessageClass.debit : MessageClass.credit;
}

final RegExp _otp = RegExp(
  r'\botp\b|one[- ]?time[- ]password|verification code|\bcode is \d',
);

final RegExp _collect = RegExp(
  'has requested|requested (?:money|₹|a payment)|collect request|'
  'is requesting|payment request from',
);

final RegExp _statement = RegExp(
  'statement (?:for|of|dated)?.{0,40}(?:generated|is ready|has been sent|'
  'is available)|e-?statement',
);

final RegExp _cardBillDue = RegExp(
  r'(?:total|minimum|min\.?) (?:amount |amt\.? )?due|bill (?:of|for|amount)'
  r'.{0,60}\bdue\b|payment due date',
);

final RegExp _upcoming = RegExp(
  r'will be (?:auto[- ]?)?debited|will be deducted|is due on|\bdue on\b|'
  'autopay (?:is )?(?:scheduled|set up|due)|scheduled (?:for|on)|'
  'e-?mandate|mandate .{0,40}(?:created|registered|set up)|'
  'will be charged',
);

final RegExp _reversal = RegExp(
  r'\brefund(?:ed)?\b|\breversed\b|\breversal\b|credited back|chargeback|'
  'has been returned',
);

final RegExp _failed = RegExp(
  r'\bfailed\b|unsuccessful|\bdeclined\b|could not be (?:processed|completed)'
  '|has been rejected|not processed',
);

final RegExp _debit = RegExp(
  r'\bdebited\b|\bspent\b|\bpaid\b|\bsent\b|\bwithdrawn\b|\bwithdrawal\b|'
  r'\bpurchase\b|\bdeducted\b|\bdr\b|transferred to|\btrf to\b|'
  'used (?:at|for)|txn of|transaction of|payment of',
);

final RegExp _credit = RegExp(
  r'\bcredited\b|\breceived\b|\bdeposited\b|added to your|\bcr\b|'
  'transferred from',
);

final RegExp _promo = RegExp(
  r'cashback (?:of )?up ?to|get up ?to|\bwin\b|\boffer\b|pre-?approved|'
  r'apply now|\bclick\b|t&c|valid till|eligible for|limited period|'
  r'use code|exclusive|\bloan of\b|\bdiscount\b',
);

final RegExp _balance = RegExp(
  r'(?:available|avl\.?|avbl\.?) ?bal|balance (?:is|as on|in)|'
  'bal(?:ance)? enquiry',
);
