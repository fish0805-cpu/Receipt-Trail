import 'purchase_models.dart';

class MonthlyPurchaseSummary {
  MonthlyPurchaseSummary._(this.receipts)
      : total = receipts.fold(0, (sum, receipt) => sum + receipt.total),
        receiptCount = receipts.length,
        storeCount =
            receipts.map((receipt) => receipt.storeName).toSet().length;

  factory MonthlyPurchaseSummary.fromReceipts(
    Iterable<Receipt> receipts, {
    required DateTime now,
  }) {
    final start = DateTime(now.year, now.month);
    final end = DateTime(now.year, now.month + 1);
    final values = receipts
        .where((receipt) =>
            !receipt.date.isBefore(start) && receipt.date.isBefore(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return MonthlyPurchaseSummary._(List<Receipt>.unmodifiable(values));
  }

  final List<Receipt> receipts;
  final int total;
  final int receiptCount;
  final int storeCount;
}
