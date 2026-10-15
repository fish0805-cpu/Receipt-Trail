import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/purchase_controller.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/purchase_repository.dart';

void main() {
  test('aggregates totals and latest store visit from purchase records',
      () async {
    final older = Receipt(
      id: 'older',
      storeName: '綠日咖啡',
      address: '台北市舊地址',
      date: DateTime(2026, 10, 10, 9),
      total: 120,
      category: SpendingCategory.food,
      items: const [ReceiptItem(name: '咖啡', price: 120)],
      receiptNumber: 'AB12345678',
      isSynced: true,
      latitude: 25.01,
      longitude: 121.51,
    );
    final latest = Receipt(
      id: 'latest',
      storeName: '綠日咖啡',
      address: '台北市新地址',
      date: DateTime(2026, 10, 12, 15),
      total: 180,
      category: SpendingCategory.food,
      items: const [ReceiptItem(name: '甜點', price: 180)],
      receiptNumber: 'CD12345678',
      isSynced: false,
      latitude: 25.03,
      longitude: 121.53,
    );
    final controller = PurchaseController(
      MemoryPurchaseRepository([older, latest]),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.total, 300);
    expect(controller.categoryTotal(SpendingCategory.food), 300);
    expect(controller.stores, hasLength(1));
    expect(controller.stores.single.visits, 2);
    expect(controller.stores.single.lastVisit, latest.date);
    expect(controller.stores.single.address, latest.address);
    expect(controller.stores.single.latitude, latest.latitude);
    expect(controller.stores.single.longitude, latest.longitude);

    controller.dispose();
  });
}
