import 'package:expense_tracker/services/upi_pay_service.dart';
import 'package:test/test.dart';

void main() {
  test('a success answer gives the reference number', () {
    final r = parseUpiResponse(
      'txnId=AXI123&responseCode=00&Status=SUCCESS&txnRef=TR1'
      '&ApprovalRefNo=432198765432',
    );
    expect(r.outcome, UpiOutcome.success);
    expect(r.refNo, '432198765432');
  });

  test('failure, pending and no answer', () {
    expect(parseUpiResponse('Status=FAILURE').outcome, UpiOutcome.failure);
    expect(parseUpiResponse('status=submitted').outcome, UpiOutcome.pending);
    expect(parseUpiResponse(null).outcome, UpiOutcome.unknown);
    expect(parseUpiResponse('').outcome, UpiOutcome.unknown);
    expect(parseUpiResponse('nonsense').outcome, UpiOutcome.unknown);
  });

  test('a "null" reference is ignored', () {
    final r = parseUpiResponse('Status=SUCCESS&ApprovalRefNo=null&txnId=T9');
    expect(r.refNo, 'T9');
  });
}
