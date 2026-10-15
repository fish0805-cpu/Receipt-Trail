import 'purchase_models.dart';

sealed class PurchaseScope {
  const PurchaseScope();

  const factory PurchaseScope.guest() = GuestPurchaseScope;
  const factory PurchaseScope.account(int userId) = AccountPurchaseScope;
}

final class GuestPurchaseScope extends PurchaseScope {
  const GuestPurchaseScope();

  @override
  bool operator ==(Object other) => other is GuestPurchaseScope;

  @override
  int get hashCode => Object.hash(GuestPurchaseScope, 0);
}

final class AccountPurchaseScope extends PurchaseScope {
  const AccountPurchaseScope(this.userId);

  final int userId;

  @override
  bool operator ==(Object other) =>
      other is AccountPurchaseScope && other.userId == userId;

  @override
  int get hashCode => Object.hash(AccountPurchaseScope, userId);
}

enum SyncOperationKind { upsert, delete }

class PendingSyncOperation {
  const PendingSyncOperation({
    required this.operationId,
    required this.receiptId,
    required this.userId,
    required this.kind,
    this.receipt,
    this.retryCount = 0,
    this.lastError,
  });

  final String operationId;
  final String receiptId;
  final int userId;
  final SyncOperationKind kind;
  final Receipt? receipt;
  final int retryCount;
  final String? lastError;
}
