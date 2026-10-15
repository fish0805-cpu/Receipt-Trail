import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/purchase_repository.dart';
import 'package:receipt_trail/src/features/purchases/purchase_scope.dart';

void main() {
  final receipt = Receipt(
    id: 'test-1',
    storeName: '測試商店',
    address: '台北市',
    date: DateTime(2026, 10, 12, 12, 30),
    total: 250,
    category: SpendingCategory.shopping,
    items: const [ReceiptItem(name: '商品', price: 250)],
    receiptNumber: 'AB12345678',
    isSynced: false,
  );

  test('receipt JSON round trip keeps all data', () {
    final restored = Receipt.fromJson(receipt.toJson());

    expect(restored.id, receipt.id);
    expect(restored.storeName, receipt.storeName);
    expect(restored.date, receipt.date);
    expect(restored.total, receipt.total);
    expect(restored.category, receipt.category);
    expect(restored.items.single.name, '商品');
    expect(restored.isSynced, isFalse);
  });

  test('legacy receipt JSON preserves paid total with safe defaults', () {
    final restored = Receipt.fromJson({
      'id': 'legacy',
      'storeName': '舊商店',
      'address': '台北市',
      'date': '2026-05-18T12:00:00.000',
      'total': 208,
      'category': 'shopping',
      'items': const <Object>[],
      'receiptNumber': 'AB12345678',
    });

    expect(restored.subtotal, 208);
    expect(restored.discount, 0);
    expect(restored.sellerTaxId, isNull);
    expect(restored.period.rocTerm, '11506');
  });

  test(
    'legacy localized missing-value placeholders normalize to empty data',
    () {
      final restored = Receipt.fromJson({
        'id': 'legacy-placeholders',
        'storeName': '舊商店',
        'address': '未填寫地址',
        'date': '2026-05-18T12:00:00.000',
        'total': 208,
        'category': 'shopping',
        'items': const <Object>[],
        'receiptNumber': '未填寫',
      });

      expect(restored.address, isEmpty);
      expect(restored.receiptNumber, isEmpty);
    },
  );

  test('new receipt JSON round trip keeps invoice amount fields', () {
    final value = Receipt(
      id: 'new',
      storeName: '新商店',
      address: '台北市',
      date: DateTime(2026, 10, 13),
      subtotal: 250,
      discount: 50,
      total: 200,
      sellerTaxId: '12345678',
      category: SpendingCategory.shopping,
      items: const [ReceiptItem(name: '商品', price: 250)],
      receiptNumber: 'CD12345678',
    );

    final restored = Receipt.fromJson(value.toJson());

    expect(restored.subtotal, 250);
    expect(restored.discount, 50);
    expect(restored.total, 200);
    expect(restored.sellerTaxId, '12345678');
    expect(restored.period.rocTerm, '11510');
  });

  test('memory guest repository saves and deletes receipts locally', () async {
    final repository = MemoryPurchaseRepository();

    await repository.saveReceipt(receipt);
    expect(await repository.watchReceipts().first, hasLength(1));

    await repository.deleteReceipt(receipt.id);
    expect(await repository.watchReceipts().first, isEmpty);
  });

  test('switching scope never exposes another owners receipts', () async {
    final repository = MemoryPurchaseRepository();

    await repository.setScope(const PurchaseScope.guest());
    await repository.saveReceipt(receipt);

    await repository.setScope(const PurchaseScope.account(7));
    expect(await repository.watchReceipts().first, isEmpty);
    await repository.saveReceipt(_receiptFor('account-7'));

    await repository.setScope(const PurchaseScope.account(8));
    expect(await repository.watchReceipts().first, isEmpty);
    await repository.saveReceipt(_receiptFor('account-8'));

    await repository.setScope(const PurchaseScope.account(7));
    expect(
      (await repository.watchReceipts().first).map((value) => value.id),
      <String>['account-7'],
    );

    await repository.setScope(const PurchaseScope.guest());
    expect(
      (await repository.watchReceipts().first).map((value) => value.id),
      <String>['test-1'],
    );
  });

  test('guest saves never enter outbox while account saves do', () async {
    final repository = MemoryPurchaseRepository();

    await repository.saveReceipt(receipt);
    expect(await repository.pendingOperations(7), isEmpty);

    await repository.setScope(const PurchaseScope.account(7));
    await repository.saveReceipt(_receiptFor('account-receipt'));

    final operations = await repository.pendingOperations(7);
    expect(operations, hasLength(1));
    expect(operations.single.kind, SyncOperationKind.upsert);
    expect(operations.single.receiptId, 'account-receipt');
    expect(operations.single.receipt?.id, 'account-receipt');
  });

  test(
    'claiming guest receipts moves them and queues one operation each',
    () async {
      final repository = MemoryPurchaseRepository(<Receipt>[
        receipt,
        _receiptFor('guest-2'),
      ]);

      expect(await repository.claimGuestReceipts(7), 2);
      expect(await repository.claimGuestReceipts(7), 0);

      await repository.setScope(const PurchaseScope.guest());
      expect(await repository.watchReceipts().first, isEmpty);
      await repository.setScope(const PurchaseScope.account(7));
      expect(await repository.watchReceipts().first, hasLength(2));
      expect(await repository.pendingOperations(7), hasLength(2));
    },
  );
}

Receipt _receiptFor(String id) => Receipt(
  id: id,
  storeName: '測試商店',
  address: '台北市',
  date: DateTime(2026, 10, 13),
  total: 100,
  category: SpendingCategory.other,
  items: const <ReceiptItem>[ReceiptItem(name: '測試品項', price: 100)],
  receiptNumber: 'EF12345678',
  isSynced: false,
);
