import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/monthly_purchase_summary.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';

void main() {
  test('includes only receipts in the local calendar month', () {
    final summary = MonthlyPurchaseSummary.fromReceipts(
      [
        _receipt('before', DateTime(2026, 9, 30, 23, 59), 90, '舊店'),
        _receipt('first', DateTime(2026, 10), 100, '甲店'),
        _receipt('latest', DateTime(2026, 10, 31, 23, 59), 200, '甲店'),
        _receipt('next', DateTime(2026, 11), 300, '乙店'),
      ],
      now: DateTime(2026, 10, 14),
    );

    expect(summary.receipts.map((receipt) => receipt.id), ['latest', 'first']);
    expect(summary.total, 300);
    expect(summary.receiptCount, 2);
    expect(summary.storeCount, 1);
  });

  test('keeps January separate from the previous December', () {
    final summary = MonthlyPurchaseSummary.fromReceipts(
      [
        _receipt('december', DateTime(2025, 12, 31, 23, 59), 80, '舊店'),
        _receipt('january', DateTime(2026, 1, 1), 120, '新店'),
      ],
      now: DateTime(2026, 1, 20),
    );

    expect(summary.receipts.single.id, 'january');
    expect(summary.total, 120);
  });
}

Receipt _receipt(
  String id,
  DateTime date,
  int total,
  String storeName,
) =>
    Receipt(
      id: id,
      storeName: storeName,
      address: '測試地址',
      date: date,
      total: total,
      category: SpendingCategory.other,
      items: [ReceiptItem(name: '品項', price: total)],
      receiptNumber: 'AB12345678',
    );
