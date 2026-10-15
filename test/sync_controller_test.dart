import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/auth/auth_controller.dart';
import 'package:receipt_trail/src/features/auth/auth_gateway.dart';
import 'package:receipt_trail/src/features/auth/auth_models.dart';
import 'package:receipt_trail/src/features/auth/token_store.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/purchase_repository.dart';
import 'package:receipt_trail/src/features/purchases/purchase_scope.dart';
import 'package:receipt_trail/src/features/sync/receipt_cloud_gateway.dart';
import 'package:receipt_trail/src/features/sync/sync_controller.dart';
import 'package:receipt_trail/src/features/sync/sync_service.dart';

void main() {
  test('successful login triggers cloud sync once', () async {
    final auth = AuthController(_LoginGateway(), MemoryTokenStore());
    final purchases = MemoryPurchaseRepository();
    final cloud = _TrackingCloudGateway();
    final controller = SyncController(
      service: SyncService(purchases, cloud),
      repository: purchases,
      authController: auth,
    );

    await auth.login(email: 'user@example.com', password: 'password');
    await _waitForSync(controller);

    expect(cloud.fetchCount, 1);
    controller.dispose();
  });

  test('sync failure is exposed as a retryable message', () async {
    final auth = AuthController(_LoginGateway(), MemoryTokenStore());
    final purchases = MemoryPurchaseRepository();
    final cloud = _TrackingCloudGateway()..failFetch = true;
    final controller = SyncController(
      service: SyncService(purchases, cloud),
      repository: purchases,
      authController: auth,
    );

    await auth.login(email: 'user@example.com', password: 'password');
    await _waitForSync(controller);

    expect(controller.failureCode, SyncFailureCode.unknown);
    expect(controller.isSyncing, isFalse);
    controller.dispose();
  });

  test('retryable upload keeps local receipt and outbox then retries once',
      () async {
    final auth = AuthController(_LoginGateway(), MemoryTokenStore());
    await auth.login(email: 'user@example.com', password: 'password');
    final purchases = MemoryPurchaseRepository();
    await purchases.setScope(const PurchaseScope.account(1));
    await purchases.saveReceipt(_receipt());
    final cloud = _TrackingCloudGateway()..failUpsert = true;
    final controller = SyncController(
      service: SyncService(purchases, cloud),
      repository: purchases,
      authController: auth,
      autoSyncOnAuth: false,
    );

    await controller.sync();

    expect((await purchases.watchReceipts().first).single.id, 'receipt-1');
    expect(await purchases.pendingOperations(1), hasLength(1));
    expect(controller.failureCode, SyncFailureCode.serviceUnavailable);

    cloud.failUpsert = false;
    await controller.sync();

    expect(await purchases.pendingOperations(1), isEmpty);
    expect(cloud.upsertAttempts, 2);
    expect(cloud.successfulUpserts, 1);
    controller.dispose();
  });

  test('guest deletion removes only the local receipt', () async {
    final auth = AuthController.guest();
    final purchases = MemoryPurchaseRepository([_receipt()]);
    final cloud = _TrackingCloudGateway();
    final controller = SyncController(
      service: SyncService(purchases, cloud),
      repository: purchases,
      authController: auth,
    );

    await controller.deleteReceipt('receipt-1');

    expect(await purchases.watchReceipts().first, isEmpty);
    expect(cloud.deleted, isEmpty);
    controller.dispose();
  });

  test('exclusive reset waits for an active sync before it starts', () async {
    final auth = AuthController(_LoginGateway(), MemoryTokenStore());
    final purchases = MemoryPurchaseRepository();
    final cloud = _TrackingCloudGateway()..fetchGate = Completer<void>();
    final controller = SyncController(
      service: SyncService(purchases, cloud),
      repository: purchases,
      authController: auth,
    );
    await auth.login(email: 'user@example.com', password: 'password');
    while (!controller.isSyncing) {
      await Future<void>.delayed(Duration.zero);
    }
    var resetStarted = false;

    final reset = controller.runExclusiveOperation(() async {
      resetStarted = true;
    });
    await Future<void>.delayed(Duration.zero);
    expect(resetStarted, isFalse);
    cloud.fetchGate!.complete();
    await reset;

    expect(resetStarted, isTrue);
    controller.dispose();
  });
}

Future<void> _waitForSync(SyncController controller) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
    if (!controller.isSyncing &&
        (controller.failureCode != null || controller.hasCompletedSync)) {
      return;
    }
  }
}

Receipt _receipt() => Receipt(
      id: 'receipt-1',
      storeName: '測試商店',
      address: '台北市',
      date: DateTime(2026, 10, 13),
      total: 100,
      category: SpendingCategory.shopping,
      items: const [ReceiptItem(name: '商品', price: 100)],
      receiptNumber: 'AB12345678',
      isSynced: false,
    );

class _TrackingCloudGateway implements ReceiptCloudGateway {
  @override
  Future<void> deleteAllReceipts(String operationId) async {}

  var fetchCount = 0;
  var failFetch = false;
  var failUpsert = false;
  var upsertAttempts = 0;
  var successfulUpserts = 0;
  final List<String> deleted = [];
  Completer<void>? fetchGate;

  @override
  Future<void> deleteReceipt(String operationId, String receiptId) async =>
      deleted.add(receiptId);

  @override
  Future<List<Receipt>> fetchReceipts() async {
    fetchCount++;
    if (failFetch) throw const SyncFailure(SyncFailureCode.unknown);
    await fetchGate?.future;
    return [];
  }

  @override
  Future<void> upsertReceipt(String operationId, Receipt receipt) async {
    upsertAttempts++;
    if (failUpsert) {
      throw const SyncFailure(
        SyncFailureCode.serviceUnavailable,
        isRetryable: true,
      );
    }
    successfulUpserts++;
  }
}

class _LoginGateway implements AuthGateway {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async =>
      _session;

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<AuthUser> me(String accessToken) async => _session.user;

  @override
  Future<AuthSession> refresh(String refreshToken) async => _session;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async =>
      _session;

  static const _session = AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    user: AuthUser(id: 1, name: '測試', email: 'user@example.com'),
  );
}
