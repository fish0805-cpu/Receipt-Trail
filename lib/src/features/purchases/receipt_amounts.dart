class ReceiptAmounts {
  factory ReceiptAmounts({
    required int subtotal,
    required int discount,
    required int total,
  }) {
    if (subtotal < 0 || discount < 0 || total < 0) {
      throw ArgumentError('發票金額不得為負數');
    }
    if (subtotal - discount != total) {
      throw ArgumentError('商品小計扣除折扣後必須等於實付金額');
    }
    return ReceiptAmounts._(subtotal, discount, total);
  }

  factory ReceiptAmounts.legacy(int total) =>
      ReceiptAmounts(subtotal: total, discount: 0, total: total);

  const ReceiptAmounts._(this.subtotal, this.discount, this.total);

  final int subtotal;
  final int discount;
  final int total;
}
