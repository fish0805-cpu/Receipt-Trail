import '../purchases/purchase_models.dart';

enum SyncFailureCode {
  authenticationRequired,
  networkUnavailable,
  serviceUnavailable,
  missingLocalReceipt,
  invalidResponse,
  unknown,
}

class SyncFailure implements Exception {
  const SyncFailure(this.code, {this.isRetryable = false, this.statusCode});

  final SyncFailureCode code;
  final bool isRetryable;
  final int? statusCode;

  @override
  String toString() => 'SyncFailure($code, statusCode: $statusCode)';
}

abstract interface class ReceiptCloudGateway {
  Future<void> upsertReceipt(String operationId, Receipt receipt);
  Future<List<Receipt>> fetchReceipts();
  Future<void> deleteReceipt(String operationId, String receiptId);
  Future<void> deleteAllReceipts(String operationId);
}
