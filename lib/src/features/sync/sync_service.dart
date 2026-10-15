import '../purchases/purchase_repository.dart';
import '../purchases/purchase_scope.dart';
import 'receipt_cloud_gateway.dart';

class SyncResult {
  const SyncResult({required this.uploadedCount});

  final int uploadedCount;
}

class SyncEngine {
  const SyncEngine(this._repository, this._gateway);

  final PurchaseRepository _repository;
  final ReceiptCloudGateway _gateway;

  Future<void> deleteAllReceipts(String operationId) =>
      _gateway.deleteAllReceipts(operationId);

  Future<SyncResult> synchronize(int userId) async {
    final pending = await _repository.pendingOperations(userId);
    var uploadedCount = 0;
    for (final operation in pending) {
      try {
        switch (operation.kind) {
          case SyncOperationKind.upsert:
            final receipt = operation.receipt;
            if (receipt == null) {
              throw const SyncFailure(SyncFailureCode.missingLocalReceipt);
            }
            await _gateway.upsertReceipt(operation.operationId, receipt);
          case SyncOperationKind.delete:
            await _gateway.deleteReceipt(
              operation.operationId,
              operation.receiptId,
            );
        }
      } on SyncFailure catch (error) {
        await _repository.applySyncFailure(
          operation.operationId,
          error.code.name,
        );
        rethrow;
      }
      await _repository.applySyncSuccess(operation.operationId);
      uploadedCount++;
    }

    final remote = await _gateway.fetchReceipts();
    await _repository.mergeRemoteReceipts(userId, remote);
    return SyncResult(uploadedCount: uploadedCount);
  }
}

typedef SyncService = SyncEngine;
