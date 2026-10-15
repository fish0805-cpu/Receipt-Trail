import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/receipt_amounts.dart';

void main() {
  test('accepts subtotal minus discount equal to paid total', () {
    final amounts = ReceiptAmounts(subtotal: 250, discount: 50, total: 200);

    expect(amounts.subtotal, 250);
    expect(amounts.discount, 50);
    expect(amounts.total, 200);
  });

  test('rejects negative and inconsistent amounts', () {
    expect(
      () => ReceiptAmounts(subtotal: -1, discount: 0, total: -1),
      throwsArgumentError,
    );
    expect(
      () => ReceiptAmounts(subtotal: 250, discount: -1, total: 251),
      throwsArgumentError,
    );
    expect(
      () => ReceiptAmounts(subtotal: 250, discount: 40, total: 200),
      throwsArgumentError,
    );
  });

  test('legacy total becomes an undiscounted amount', () {
    final amounts = ReceiptAmounts.legacy(208);

    expect(amounts.subtotal, 208);
    expect(amounts.discount, 0);
    expect(amounts.total, 208);
  });
}
