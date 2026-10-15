import '../purchases/purchase_repository.dart';
import '../purchases/purchase_scope.dart';
import '../sync/receipt_cloud_gateway.dart';
import '../sync/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DataResetTarget { guestDevice, accountDevice, accountCloud }

abstract interface class AccountResetOperationStore {
  Future<String?> read(int userId);
  Future<void> write(int userId, String operationId);
  Future<void> clear(int userId);
}

class MemoryAccountResetOperationStore implements AccountResetOperationStore {
  final Map<int, String> _values = <int, String>{};

  @override
  Future<String?> read(int userId) async => _values[userId];

  @override
  Future<void> write(int userId, String operationId) async {
    _values[userId] = operationId;
  }

  @override
  Future<void> clear(int userId) async {
    _values.remove(userId);
  }
}

class SharedPreferencesAccountResetOperationStore
    implements AccountResetOperationStore {
  const SharedPreferencesAccountResetOperationStore(this._preferences);

  final SharedPreferences _preferences;

  String _key(int userId) => 'account_reset_operation_$userId';

  @override
  Future<String?> read(int userId) async =>
      _preferences.getString(_key(userId));

  @override
  Future<void> write(int userId, String operationId) =>
      _preferences.setString(_key(userId), operationId);

  @override
  Future<void> clear(int userId) => _preferences.remove(_key(userId));
}

enum DataResetFailureCode { cloudDeleteUnconfirmed, noAuthenticatedAccount }

class DataResetFailure implements Exception {
  const DataResetFailure(this.code);

  final DataResetFailureCode code;

  @override
  String toString() => 'DataResetFailure($code)';
}

/// Coordinates destructive data operations without hiding incomplete cloud work.
class DataResetService {
  const DataResetService({
    required PurchaseRepository repository,
    required SyncService syncService,
    required AccountResetOperationStore operationStore,
  })  : _repository = repository,
        _syncService = syncService,
        _operationStore = operationStore;

  final PurchaseRepository _repository;
  final SyncService _syncService;
  final AccountResetOperationStore _operationStore;

  Future<void> clearGuestData() =>
      _repository.clearLocalScope(const PurchaseScope.guest());

  Future<void> clearAccountFromDevice(int userId) =>
      _repository.clearLocalScope(PurchaseScope.account(userId));

  Future<void> clearAccountEverywhere({
    required int userId,
  }) async {
    var operationId = await _operationStore.read(userId);
    if (operationId == null) {
      operationId =
          'delete-all:$userId:${DateTime.now().microsecondsSinceEpoch}';
      await _operationStore.write(userId, operationId);
    }
    try {
      await _syncService.deleteAllReceipts(operationId);
    } on SyncFailure {
      throw const DataResetFailure(
        DataResetFailureCode.cloudDeleteUnconfirmed,
      );
    }
    await _repository.clearLocalScope(PurchaseScope.account(userId));
    await _operationStore.clear(userId);
  }
}
