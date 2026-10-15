import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/invoice_period.dart';

void main() {
  test('groups purchase dates into ROC bi-monthly terms', () {
    expect(
        InvoicePeriod.fromPurchaseDate(DateTime(2026, 1, 1)).rocTerm, '11502');
    expect(
        InvoicePeriod.fromPurchaseDate(DateTime(2026, 2, 28)).rocTerm, '11502');
    expect(
        InvoicePeriod.fromPurchaseDate(DateTime(2026, 5, 18)).rocTerm, '11506');

    final december = InvoicePeriod.fromPurchaseDate(DateTime(2026, 12, 31));
    expect(december.rocTerm, '11512');
    expect(december.drawDate, DateTime(2027, 1, 25));
  });

  test('rejects malformed or odd-month ROC terms', () {
    expect(() => InvoicePeriod.fromRocTerm('11505'), throwsFormatException);
    expect(() => InvoicePeriod.fromRocTerm('abc'), throwsFormatException);
    expect(() => InvoicePeriod.fromRocTerm('11514'), throwsFormatException);
  });

  test('uses the device local calendar for UTC dates at a term boundary', () {
    final utcBoundary = DateTime.utc(2026, 10, 31, 16, 30);

    expect(
      InvoicePeriod.fromPurchaseDate(utcBoundary).rocTerm,
      InvoicePeriod.fromPurchaseDate(utcBoundary.toLocal()).rocTerm,
    );
  });
}
