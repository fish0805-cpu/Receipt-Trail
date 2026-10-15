import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/auth_controller.dart';
import '../purchases/purchase_repository.dart';
import 'receipt_cloud_gateway.dart';
import 'sync_service.dart';

class SyncController extends ChangeNotifier {
  SyncController({
    required SyncService service,
    required PurchaseRepository repository,
    required AuthController authController,
    bool autoSyncOnAuth = true,
  })  : _service = service,
        _repository = repository,
        _authController = authController,
        _autoSyncOnAuth = autoSyncOnAuth {
    if (_autoSyncOnAuth) {
      _authController.addListener(_handleAuthChanged);
      _handleAuthChanged();
    }
  }

  final SyncService _service;
  final PurchaseRepository _repository;
  final AuthController _authController;
  final bool _autoSyncOnAuth;
  bool _isSyncing = false;
  SyncFailureCode? _failureCode;
  int? _uploadedCount;
  bool _hasCompletedSync = false;
  int? _syncedUserId;
  Future<void> _operationTail = Future<void>.value();
  Future<void>? _scheduledSync;

  bool get isSyncing => _isSyncing;
  SyncFailureCode? get failureCode => _failureCode;
  int? get uploadedCount => _uploadedCount;
  bool get hasCompletedSync => _hasCompletedSync;

  void _handleAuthChanged() {
    final userId = _authController.user?.id;
    if (userId == null) {
      _syncedUserId = null;
      return;
    }
    if (_syncedUserId != userId) {
      _syncedUserId = userId;
      unawaited(sync());
    }
  }

  Future<void> sync() {
    final scheduled = _scheduledSync;
    if (scheduled != null) return scheduled;
    final next = runExclusiveOperation(_performSync);
    _scheduledSync = next;
    unawaited(next.whenComplete(() {
      if (identical(_scheduledSync, next)) _scheduledSync = null;
    }));
    return next;
  }

  Future<void> _performSync() async {
    final userId = _authController.user?.id;
    if (userId == null) return;
    _isSyncing = true;
    _failureCode = null;
    _uploadedCount = null;
    notifyListeners();
    try {
      final result = await _service.synchronize(userId);
      _uploadedCount = result.uploadedCount;
      _hasCompletedSync = true;
    } on SyncFailure catch (error) {
      _failureCode = error.code;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<T> runExclusiveOperation<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    final previous = _operationTail;
    _operationTail = () async {
      try {
        await previous;
      } catch (_) {
        // A failed operation must not permanently block later queued work.
      }
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    }();
    return completer.future;
  }

  Future<void> deleteReceipt(String id) async {
    await _repository.deleteReceipt(id);
    if (!_authController.isAuthenticated) return;
    await sync();
  }

  @override
  void dispose() {
    if (_autoSyncOnAuth) {
      _authController.removeListener(_handleAuthChanged);
    }
    super.dispose();
  }
}
