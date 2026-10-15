import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/data/drift_purchase_repository.dart';
import 'package:receipt_trail/src/features/purchases/data/receipt_trail_database.dart'
    as data;
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/purchase_scope.dart';

void main() {
  late data.ReceiptTrailDatabase database;
  late DriftPurchaseRepository repository;

  setUp(() {
    database = data.ReceiptTrailDatabase.forTesting(NativeDatabase.memory());
    repository = DriftPurchaseRepository(database);
  });

  tearDown(() => repository.close());

  test('guest receipt round trips all fields without creating outbox',
      () async {
    final receipt = _receipt('guest-1');

    await repository.saveReceipt(receipt);

    final restored = (await repository.watchReceipts().first).single;
    expect(restored.id, 'guest-1');
    expect(restored.storeName, receipt.storeName);
    expect(restored.address, receipt.address);
    expect(restored.date.toUtc(), receipt.date.toUtc());
    expect(restored.total, receipt.total);
    expect(restored.subtotal, 250);
    expect(restored.discount, 50);
    expect(restored.sellerTaxId, '12345678');
    expect(restored.period.rocTerm, '11510');
    expect(restored.category, receipt.category);
    expect(restored.receiptNumber, receipt.receiptNumber);
    expect(restored.rawText, receipt.rawText);
    expect(restored.latitude, receipt.latitude);
    expect(restored.longitude, receipt.longitude);
    expect(restored.items.single.name, '拿鐵');
    expect(restored.items.single.quantity, 2);
    expect(await repository.pendingOperations(9), isEmpty);
  });

  test('account save and outbox insert roll back together on item failure',
      () async {
    await repository.setScope(const PurchaseScope.account(9));
    final invalid = _receipt(
      'invalid',
      items: const <ReceiptItem>[
        ReceiptItem(name: '無效品項', quantity: 0, price: 80),
      ],
    );

    await expectLater(
        repository.saveReceipt(invalid), throwsA(isA<SqliteException>()));

    final purchaseCount = await database
        .customSelect('SELECT COUNT(*) AS count FROM purchase_records')
        .getSingle();
    final outboxCount = await database
        .customSelect('SELECT COUNT(*) AS count FROM sync_outbox')
        .getSingle();
    expect(purchaseCount.read<int>('count'), 0);
    expect(outboxCount.read<int>('count'), 0);
  });

  test('account save creates one stable upsert operation', () async {
    await repository.setScope(const PurchaseScope.account(9));

    await repository.saveReceipt(_receipt('account-1'));
    await repository.saveReceipt(_receipt('account-1', total: 200));

    final operations = await repository.pendingOperations(9);
    expect(operations, hasLength(1));
    expect(operations.single.operationId, startsWith('upsert:9:'));
    expect(operations.single.kind, SyncOperationKind.upsert);
    expect(operations.single.receipt?.total, 200);
  });

  test('a new save after sync uses a fresh operation id', () async {
    await repository.setScope(const PurchaseScope.account(9));
    await repository.saveReceipt(_receipt('edited', total: 100));
    final original = (await repository.pendingOperations(9)).single;
    await repository.applySyncSuccess(original.operationId);

    await repository.saveReceipt(_receipt('edited', total: 200));
    final updated = (await repository.pendingOperations(9)).single;

    expect(updated.operationId, isNot(original.operationId));
    expect(updated.receipt?.total, 200);
    expect((await repository.pendingOperations(9)).single.operationId,
        updated.operationId,
        reason: 'Retrying the same pending change must keep its ID.');
  });

  test('scope switching and soft delete never leak account data', () async {
    await repository.saveReceipt(_receipt('guest-1'));
    await repository.setScope(const PurchaseScope.account(9));
    await repository.saveReceipt(_receipt('account-9'));
    await repository.setScope(const PurchaseScope.account(10));
    await repository.saveReceipt(_receipt('account-10'));

    await repository.setScope(const PurchaseScope.account(9));
    expect(
      (await repository.watchReceipts().first).map((value) => value.id),
      <String>['account-9'],
    );
    await repository.deleteReceipt('account-9');
    expect(await repository.watchReceipts().first, isEmpty);
    expect(
      (await repository.pendingOperations(9)).single.kind,
      SyncOperationKind.delete,
    );

    final tombstone = await database.customSelect(
      'SELECT deleted_at FROM purchase_records WHERE receipt_id = ?',
      variables: <Variable<Object>>[const Variable<String>('account-9')],
    ).getSingle();
    expect(tombstone.data['deleted_at'], isNotNull);

    await repository.setScope(const PurchaseScope.guest());
    expect(
      (await repository.watchReceipts().first).map((value) => value.id),
      <String>['guest-1'],
    );
  });

  test('claim moves every guest receipt and queues each only once', () async {
    await repository.saveReceipt(_receipt('guest-1'));
    await repository.saveReceipt(_receipt('guest-2'));

    expect(await repository.claimGuestReceipts(9), 2);
    expect(await repository.claimGuestReceipts(9), 0);

    await repository.setScope(const PurchaseScope.guest());
    expect(await repository.watchReceipts().first, isEmpty);
    await repository.setScope(const PurchaseScope.account(9));
    expect(await repository.watchReceipts().first, hasLength(2));
    expect(await repository.pendingOperations(9), hasLength(2));
  });

  test('guest delete permanently removes its related rows', () async {
    await repository.saveReceipt(_receipt('guest-1'));

    await repository.deleteReceipt('guest-1');

    final tables = <String>[
      'purchase_records',
      'uniform_invoices',
      'purchase_places',
      'receipt_items',
    ];
    for (final table in tables) {
      final row = await database
          .customSelect('SELECT COUNT(*) AS count FROM $table')
          .getSingle();
      expect(row.read<int>('count'), 0, reason: table);
    }
  });

  test('clearing guest data does not touch account data', () async {
    await repository.saveReceipt(_receipt('guest-1'));
    await repository.setScope(const PurchaseScope.account(9));
    await repository.saveReceipt(_receipt('account-1'));

    await repository.clearLocalScope(const PurchaseScope.guest());

    expect(
      (await repository.watchReceipts().first).map((receipt) => receipt.id),
      <String>['account-1'],
    );
    expect(await repository.pendingOperations(9), hasLength(1));
    await repository.setScope(const PurchaseScope.guest());
    expect(await repository.watchReceipts().first, isEmpty);
  });

  test('clearing an account locally also removes its pending outbox', () async {
    await repository.setScope(const PurchaseScope.account(9));
    await repository.saveReceipt(_receipt('account-1'));

    await repository.clearLocalScope(const PurchaseScope.account(9));

    expect(await repository.watchReceipts().first, isEmpty);
    expect(await repository.pendingOperations(9), isEmpty);
  });

  test('remote merge replaces only the requested accounts synced snapshot',
      () async {
    await repository.setScope(const PurchaseScope.account(9));
    await repository.saveReceipt(_receipt('removed-remotely'));
    await repository.applySyncSuccess(
        (await repository.pendingOperations(9)).single.operationId);
    await repository.setScope(const PurchaseScope.account(10));
    await repository.saveReceipt(_receipt('other-account'));
    await repository.applySyncSuccess(
        (await repository.pendingOperations(10)).single.operationId);

    await repository.mergeRemoteReceipts(9, const <Receipt>[]);

    await repository.setScope(const PurchaseScope.account(9));
    expect(await repository.watchReceipts().first, isEmpty);
    await repository.setScope(const PurchaseScope.account(10));
    expect(
      (await repository.watchReceipts().first).map((receipt) => receipt.id),
      <String>['other-account'],
    );
  });

  test('remote snapshot cannot overwrite an unsynced local edit', () async {
    await repository.setScope(const PurchaseScope.account(9));
    await repository.saveReceipt(_receipt('edited', total: 100));
    final firstOperation = (await repository.pendingOperations(9)).single;
    await repository.applySyncSuccess(firstOperation.operationId);
    await repository.saveReceipt(_receipt('edited', total: 200));

    await repository.mergeRemoteReceipts(9, <Receipt>[
      _receipt('edited', total: 100).copyWith(isSynced: true),
    ]);

    expect((await repository.watchReceipts().first).single.total, 200);
    expect((await repository.pendingOperations(9)).single.receipt?.total, 200);
  });

  test('different accounts can keep receipts with the same public id',
      () async {
    await repository.setScope(const PurchaseScope.account(9));
    await repository.saveReceipt(_receipt('shared-id', total: 90));
    await repository.setScope(const PurchaseScope.account(10));
    await repository.saveReceipt(_receipt('shared-id', total: 100));

    await repository.setScope(const PurchaseScope.account(9));
    expect((await repository.watchReceipts().first).single.total, 90);
    await repository.setScope(const PurchaseScope.account(10));
    expect((await repository.watchReceipts().first).single.total, 100);
  });
}

Receipt _receipt(
  String id, {
  int total = 200,
  List<ReceiptItem> items = const <ReceiptItem>[
    ReceiptItem(name: '拿鐵', quantity: 2, price: 80),
  ],
}) =>
    Receipt(
      id: id,
      storeName: '綠日咖啡',
      address: '台北市測試路 1 號',
      date: DateTime.utc(2026, 10, 13, 8, 30),
      total: total,
      subtotal: total == 200 ? 250 : total,
      discount: total == 200 ? 50 : 0,
      sellerTaxId: '12345678',
      category: SpendingCategory.food,
      items: items,
      receiptNumber: 'AB12345678',
      isSynced: false,
      rawText: '只留在本機的 OCR 原文',
      latitude: 25.033,
      longitude: 121.565,
    );
