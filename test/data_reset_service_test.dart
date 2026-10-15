import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/data_management/data_reset_service.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/purchase_repository.dart';
import 'package:receipt_trail/src/features/purchases/purchase_scope.dart';
import 'package:receipt_trail/src/features/sync/receipt_cloud_gateway.dart';
import 'package:receipt_trail/src/features/sync/sync_service.dart';

void main() {
  test('guest reset removes only guest records', () async {
    final repository = MemoryPurchaseRepository(<Receipt>[_receipt('guest')]);
    await repository.setScope(const PurchaseScope.account(7));
    await repository.saveReceipt(_receipt('account'));
    final service = DataResetService(
      repository: repository,
      syncService: SyncService(repository, _CloudGateway()),
      operationStore: MemoryAccountResetOperationStore(),
    );

    await service.clearGuestData();

    expect(
      (await repository.watchReceipts().first).map((receipt) => receipt.id),
      <String>['account'],
    );
    await repository.setScope(const PurchaseScope.guest());
    expect(await repository.watchReceipts().first, isEmpty);
  });

  test('cloud reset is confirmed only after deletes are acknowledged',
      () async {
    final repository = MemoryPurchaseRepository();
    await repository.setScope(const PurchaseScope.account(7));
    await repository.saveReceipt(_receipt('one'));
    await repository.saveReceipt(_receipt('two'));
    final gateway = _CloudGateway();
    final service = DataResetService(
      repository: repository,
      syncService: SyncService(repository, gateway),
      operationStore: MemoryAccountResetOperationStore(),
    );

    await service.clearAccountEverywhere(
      userId: 7,
    );

    expect(gateway.deleteAllCalls, 1);
    expect(await repository.pendingOperations(7), isEmpty);
    expect(await repository.watchReceipts().first, isEmpty);
  });

  test('failed cloud reset keeps local data so the user can retry', () async {
    final repository = MemoryPurchaseRepository();
    await repository.setScope(const PurchaseScope.account(7));
    await repository.saveReceipt(_receipt('one'));
    final gateway = _CloudGateway()..failDeletes = true;
    final service = DataResetService(
      repository: repository,
      syncService: SyncService(repository, gateway),
      operationStore: MemoryAccountResetOperationStore(),
    );

    await expectLater(
      service.clearAccountEverywhere(
        userId: 7,
      ),
      throwsA(isA<DataResetFailure>()),
    );

    expect((await repository.watchReceipts().first).single.id, 'one');
    expect(gateway.deleteAllCalls, 1);
  });

  test('cloud reset retries with the same persisted idempotency key', () async {
    final repository = MemoryPurchaseRepository();
    await repository.setScope(const PurchaseScope.account(7));
    await repository.saveReceipt(_receipt('one'));
    final gateway = _CloudGateway()..failDeletes = true;
    final store = MemoryAccountResetOperationStore();
    final service = DataResetService(
      repository: repository,
      syncService: SyncService(repository, gateway),
      operationStore: store,
    );

    await expectLater(
      service.clearAccountEverywhere(userId: 7),
      throwsA(isA<DataResetFailure>()),
    );
    gateway.failDeletes = false;
    await service.clearAccountEverywhere(userId: 7);

    expect(gateway.operationIds, hasLength(2));
    expect(gateway.operationIds.toSet(), hasLength(1));
    expect(await store.read(7), isNull);
  });
}

Receipt _receipt(String id) => Receipt(
      id: id,
      storeName: '測試店家',
      address: '台北市',
      date: DateTime(2026, 10, 15),
      total: 100,
      category: SpendingCategory.food,
      items: const <ReceiptItem>[ReceiptItem(name: '商品', price: 100)],
      receiptNumber: 'AB12345678',
      isSynced: false,
    );

class _CloudGateway implements ReceiptCloudGateway {
  bool failDeletes = false;
  int deleteAllCalls = 0;
  final List<String> operationIds = <String>[];

  @override
  Future<void> deleteAllReceipts(String operationId) async {
    deleteAllCalls++;
    operationIds.add(operationId);
    if (failDeletes) {
      throw const SyncFailure(SyncFailureCode.networkUnavailable);
    }
  }

  @override
  Future<void> deleteReceipt(String operationId, String receiptId) async {
    throw StateError('account reset must not depend on a local receipt list');
  }

  @override
  Future<List<Receipt>> fetchReceipts() async => const <Receipt>[];

  @override
  Future<void> upsertReceipt(String operationId, Receipt receipt) async {}
}
