import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/purchase_repository.dart';
import 'package:receipt_trail/src/features/purchases/purchase_scope.dart';
import 'package:receipt_trail/src/features/sync/receipt_cloud_gateway.dart';
import 'package:receipt_trail/src/features/sync/sync_service.dart';

void main() {
  test('processes account outbox in order and acknowledges every success',
      () async {
    final repository = MemoryPurchaseRepository();
    await repository.setScope(const PurchaseScope.account(7));
    await repository.saveReceipt(_receipt('first'));
    await repository.saveReceipt(_receipt('second'));
    final gateway = _FakeReceiptCloudGateway();

    final result = await SyncEngine(repository, gateway).synchronize(7);

    expect(result.uploadedCount, 2);
    expect(gateway.calls, <String>[
      'upsert:upsert:7:first:first',
      'upsert:upsert:7:second:second',
      'fetch',
    ]);
    expect(await repository.pendingOperations(7), isEmpty);
  });

  test('first failure records retry and prevents later operations and pull',
      () async {
    final repository = MemoryPurchaseRepository();
    await repository.setScope(const PurchaseScope.account(7));
    await repository.saveReceipt(_receipt('first'));
    await repository.saveReceipt(_receipt('second'));
    await repository.saveReceipt(_receipt('third'));
    final gateway = _FakeReceiptCloudGateway()..failOnReceiptId = 'second';

    await expectLater(
      SyncEngine(repository, gateway).synchronize(7),
      throwsA(isA<SyncFailure>()),
    );

    expect(gateway.calls, <String>[
      'upsert:upsert:7:first:first',
      'upsert:upsert:7:second:second',
    ]);
    final remaining = await repository.pendingOperations(7);
    expect(remaining.map((operation) => operation.receiptId), <String>[
      'second',
      'third',
    ]);
    expect(remaining.first.retryCount, 1);
    expect(remaining.first.lastError, SyncFailureCode.unknown.name);
  });

  test('delete tombstone is purged only after cloud confirmation', () async {
    final repository = MemoryPurchaseRepository();
    await repository.setScope(const PurchaseScope.account(7));
    await repository.saveReceipt(_receipt('delete-me'));
    await repository.applySyncSuccess('upsert:7:delete-me');
    await repository.deleteReceipt('delete-me');
    final gateway = _FakeReceiptCloudGateway();

    await SyncEngine(repository, gateway).synchronize(7);

    expect(gateway.calls.first, 'delete:delete:7:delete-me:delete-me');
    expect(await repository.pendingOperations(7), isEmpty);
    expect(await repository.watchReceipts().first, isEmpty);
  });

  test('remote receipts merge only into requested account without new outbox',
      () async {
    final repository = MemoryPurchaseRepository();
    final gateway = _FakeReceiptCloudGateway()
      ..cloudReceipts = <Receipt>[_receipt('cloud')];

    await SyncEngine(repository, gateway).synchronize(7);

    await repository.setScope(const PurchaseScope.account(7));
    expect(
      (await repository.watchReceipts().first).map((receipt) => receipt.id),
      <String>['cloud'],
    );
    expect(await repository.pendingOperations(7), isEmpty);
    await repository.setScope(const PurchaseScope.account(8));
    expect(await repository.watchReceipts().first, isEmpty);
  });
}

Receipt _receipt(String id) => Receipt(
      id: id,
      storeName: '測試商店',
      address: '台北市',
      date: DateTime(2026, 10, 13),
      total: 100,
      category: SpendingCategory.shopping,
      items: const <ReceiptItem>[ReceiptItem(name: '商品', price: 100)],
      receiptNumber: 'AB12345678',
      isSynced: false,
      rawText: '不得上傳的 OCR 原文',
    );

class _FakeReceiptCloudGateway implements ReceiptCloudGateway {
  final List<String> calls = <String>[];
  List<Receipt> cloudReceipts = <Receipt>[];
  String? failOnReceiptId;

  @override
  Future<void> deleteAllReceipts(String operationId) async {
    calls.add('delete-all:$operationId');
  }

  @override
  Future<void> deleteReceipt(String operationId, String receiptId) async {
    calls.add('delete:$operationId:$receiptId');
  }

  @override
  Future<List<Receipt>> fetchReceipts() async {
    calls.add('fetch');
    return cloudReceipts;
  }

  @override
  Future<void> upsertReceipt(String operationId, Receipt receipt) async {
    calls.add('upsert:$operationId:${receipt.id}');
    if (receipt.id == failOnReceiptId) {
      throw const SyncFailure(SyncFailureCode.unknown);
    }
  }
}
