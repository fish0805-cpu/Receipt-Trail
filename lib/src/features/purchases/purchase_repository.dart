import 'dart:async';

import 'purchase_models.dart';
import 'purchase_scope.dart';

/// UI 與儲存技術之間的界面。正式版可用 Drift 實作，測試則可用記憶體版本。
abstract interface class PurchaseRepository {
  Stream<List<Receipt>> watchReceipts();
  Future<void> setScope(PurchaseScope scope);
  Future<void> saveReceipt(Receipt receipt);
  Future<void> deleteReceipt(String id);
  Future<void> clearLocalScope(PurchaseScope scope);
  Future<int> claimGuestReceipts(int userId);
  Future<List<PendingSyncOperation>> pendingOperations(int userId);
  Future<void> applySyncSuccess(String operationId);
  Future<void> applySyncFailure(String operationId, String message);
  Future<void> mergeRemoteReceipts(int userId, List<Receipt> receipts);
  Future<void> close();
}

class MemoryPurchaseRepository implements PurchaseRepository {
  MemoryPurchaseRepository([Iterable<Receipt> initial = const []])
      : _receiptsByScope = <PurchaseScope, List<Receipt>>{
          const PurchaseScope.guest(): List<Receipt>.of(initial),
        };

  final Map<PurchaseScope, List<Receipt>> _receiptsByScope;
  final Map<int, List<PendingSyncOperation>> _operationsByUser =
      <int, List<PendingSyncOperation>>{};
  final StreamController<List<Receipt>> _changes =
      StreamController<List<Receipt>>.broadcast();
  PurchaseScope _scope = const PurchaseScope.guest();

  List<Receipt> get _receipts =>
      _receiptsByScope.putIfAbsent(_scope, () => <Receipt>[]);

  @override
  Stream<List<Receipt>> watchReceipts() async* {
    yield List.unmodifiable(_receipts);
    yield* _changes.stream;
  }

  @override
  Future<void> setScope(PurchaseScope scope) async {
    _scope = scope;
    _notify();
  }

  @override
  Future<void> saveReceipt(Receipt receipt) async {
    _receipts.removeWhere((existing) => existing.id == receipt.id);
    _receipts.insert(0, receipt);
    final scope = _scope;
    if (scope is AccountPurchaseScope) {
      _putOperation(
        PendingSyncOperation(
          operationId: 'upsert:${scope.userId}:${receipt.id}',
          receiptId: receipt.id,
          userId: scope.userId,
          kind: SyncOperationKind.upsert,
          receipt: receipt,
        ),
      );
    }
    _notify();
  }

  @override
  Future<void> deleteReceipt(String id) async {
    _receipts.removeWhere((receipt) => receipt.id == id);
    final scope = _scope;
    if (scope is AccountPurchaseScope) {
      _putOperation(
        PendingSyncOperation(
          operationId: 'delete:${scope.userId}:$id',
          receiptId: id,
          userId: scope.userId,
          kind: SyncOperationKind.delete,
        ),
      );
    }
    _notify();
  }

  @override
  Future<void> clearLocalScope(PurchaseScope scope) async {
    _receiptsByScope.remove(scope);
    if (scope case AccountPurchaseScope(:final userId)) {
      _operationsByUser.remove(userId);
    }
    if (_scope == scope) _notify();
  }

  @override
  Future<int> claimGuestReceipts(int userId) async {
    final guest = _receiptsByScope[const PurchaseScope.guest()] ?? <Receipt>[];
    if (guest.isEmpty) return 0;
    final account = _receiptsByScope.putIfAbsent(
      PurchaseScope.account(userId),
      () => <Receipt>[],
    );
    for (final receipt in List<Receipt>.of(guest)) {
      account.removeWhere((existing) => existing.id == receipt.id);
      account.add(receipt);
      _putOperation(
        PendingSyncOperation(
          operationId: 'upsert:$userId:${receipt.id}',
          receiptId: receipt.id,
          userId: userId,
          kind: SyncOperationKind.upsert,
          receipt: receipt,
        ),
      );
    }
    final count = guest.length;
    guest.clear();
    _notify();
    return count;
  }

  @override
  Future<List<PendingSyncOperation>> pendingOperations(int userId) async =>
      List<PendingSyncOperation>.unmodifiable(
        _operationsByUser[userId] ?? const <PendingSyncOperation>[],
      );

  @override
  Future<void> applySyncSuccess(String operationId) async {
    for (final entry in _operationsByUser.entries) {
      final index = entry.value.indexWhere(
        (operation) => operation.operationId == operationId,
      );
      if (index == -1) continue;
      final operation = entry.value.removeAt(index);
      if (operation.kind == SyncOperationKind.upsert) {
        final account = _receiptsByScope[PurchaseScope.account(entry.key)];
        final receiptIndex = account?.indexWhere(
              (receipt) => receipt.id == operation.receiptId,
            ) ??
            -1;
        if (receiptIndex >= 0) {
          account![receiptIndex] =
              account[receiptIndex].copyWith(isSynced: true);
        }
      }
      _notify();
      return;
    }
  }

  @override
  Future<void> applySyncFailure(String operationId, String message) async {
    for (final entry in _operationsByUser.entries) {
      final index = entry.value.indexWhere(
        (operation) => operation.operationId == operationId,
      );
      if (index == -1) continue;
      final operation = entry.value[index];
      entry.value[index] = PendingSyncOperation(
        operationId: operation.operationId,
        receiptId: operation.receiptId,
        userId: operation.userId,
        kind: operation.kind,
        receipt: operation.receipt,
        retryCount: operation.retryCount + 1,
        lastError: message,
      );
      return;
    }
  }

  @override
  Future<void> mergeRemoteReceipts(int userId, List<Receipt> receipts) async {
    final target = _receiptsByScope.putIfAbsent(
      PurchaseScope.account(userId),
      () => <Receipt>[],
    );
    for (final receipt in receipts) {
      target.removeWhere((existing) => existing.id == receipt.id);
      target.add(receipt.copyWith(isSynced: true));
    }
    target.sort((a, b) => b.date.compareTo(a.date));
    _notify();
  }

  void _putOperation(PendingSyncOperation operation) {
    final operations = _operationsByUser.putIfAbsent(
      operation.userId,
      () => <PendingSyncOperation>[],
    );
    operations.removeWhere(
      (existing) => existing.receiptId == operation.receiptId,
    );
    operations.add(operation);
  }

  void _notify() => _changes.add(List.unmodifiable(_receipts));

  @override
  Future<void> close() => _changes.close();
}
