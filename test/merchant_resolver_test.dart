import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/scanning/merchant_resolver.dart';

Receipt _receipt(String id, String name, String address, String? taxId) =>
    Receipt(
      id: id,
      storeName: name,
      address: address,
      date: DateTime(2026, 10, 1),
      total: 100,
      category: SpendingCategory.food,
      items: const [],
      receiptNumber: '',
      sellerTaxId: taxId,
    );

void main() {
  test('tax ID match ranks first and deduplicates saved merchant', () {
    final candidates = MerchantResolver.resolve(
      receipts: [
        _receipt('a', '甲店', '台北市中正路 1 號', '12345678'),
        _receipt('b', '甲店', '台北市中正路 1 號', '12345678'),
        _receipt('c', '乙店', '台北市中正路 2 號', null),
      ],
      sellerTaxId: '12345678',
      storeName: '乙店',
      address: '台北市中正路2號',
    );

    expect(candidates, hasLength(2));
    expect(candidates.first.storeName, '甲店');
    expect(candidates.first.reason, MerchantMatchReason.taxId);
    expect(candidates.last.storeName, '乙店');
  });

  test('normalized name and address match; unrelated merchants do not', () {
    final candidates = MerchantResolver.resolve(
      receipts: [
        _receipt('a', '好 店', '臺北市民生路 8 號', null),
        _receipt('b', '別家', '高雄市中山路 3 號', null),
      ],
      storeName: '好店',
      address: '台北市民生路8號',
    );

    expect(candidates, hasLength(1));
    expect(candidates.single.storeName, '好 店');
    expect(candidates.single.reason, MerchantMatchReason.nameAndAddress);
  });
}
