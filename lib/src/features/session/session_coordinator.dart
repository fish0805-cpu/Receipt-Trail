import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';
import '../purchases/data/legacy_receipt_importer.dart';
import '../purchases/purchase_repository.dart';
import '../purchases/purchase_scope.dart';

enum SessionStage { loading, welcome, guest, account, migrationFailure }

enum SessionFailureCode { initialMigration, guestClaim, repair }

typedef ExclusiveOperationRunner = Future<T> Function<T>(
  Future<T> Function() operation,
);

Future<T> _runImmediately<T>(Future<T> Function() operation) => operation();

abstract interface class SessionPreferenceStore {
  Future<bool> isGuestSelected();
  Future<void> selectGuest();
  Future<void> clearGuestSelection();
}

class MemorySessionPreferenceStore implements SessionPreferenceStore {
  bool guestSelected = false;

  @override
  Future<bool> isGuestSelected() async => guestSelected;

  @override
  Future<void> selectGuest() async => guestSelected = true;

  @override
  Future<void> clearGuestSelection() async => guestSelected = false;
}

class SessionCoordinator extends ChangeNotifier {
  SessionCoordinator({
    required AuthController authController,
    required PurchaseRepository purchases,
    required LegacyMigration migration,
    required SessionPreferenceStore preferences,
    Future<void> Function()? onAccountReady,
    ExclusiveOperationRunner? runExclusiveOperation,
  }) : _authController = authController,
       _purchases = purchases,
       _migration = migration,
       _preferences = preferences,
       _onAccountReady = onAccountReady,
       _runExclusiveOperation = runExclusiveOperation ?? _runImmediately;

  final AuthController _authController;
  final PurchaseRepository _purchases;
  final LegacyMigration _migration;
  final SessionPreferenceStore _preferences;
  final Future<void> Function()? _onAccountReady;
  final ExclusiveOperationRunner _runExclusiveOperation;

  SessionStage _stage = SessionStage.loading;
  SessionFailureCode? _failureCode;

  SessionStage get stage => _stage;
  SessionFailureCode? get failureCode => _failureCode;
  AuthUser? get user => _authController.user;
  AuthController get authController => _authController;

  Future<void> initialize() async {
    _setLoading();
    try {
      await _migration.importIfNeeded();
      await _authController.initialize();
      final user = _authController.user;
      if (user != null) {
        await _activateAccount(user.id);
        return;
      }
      if (await _preferences.isGuestSelected()) {
        await _purchases.setScope(const PurchaseScope.guest());
        _setStage(SessionStage.guest);
      } else {
        _setStage(SessionStage.welcome);
      }
    } catch (_) {
      _setFailure(SessionFailureCode.initialMigration);
    }
  }

  Future<void> continueAsGuest() async {
    _setLoading();
    await _preferences.selectGuest();
    await _purchases.setScope(const PurchaseScope.guest());
    _setStage(SessionStage.guest);
  }

  Future<bool> login({required String email, required String password}) async {
    return _runExclusiveOperation(() async {
      final authenticated = await _authController.login(
        email: email,
        password: password,
      );
      if (!authenticated) return false;
      return _finishAuthentication();
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runExclusiveOperation(() async {
      final authenticated = await _authController.register(
        name: name,
        email: email,
        password: password,
      );
      if (!authenticated) return false;
      return _finishAuthentication();
    });
  }

  Future<bool> _finishAuthentication() async {
    final user = _authController.user;
    if (user == null) return false;
    _setLoading();
    try {
      await _activateAccount(user.id);
      return true;
    } catch (_) {
      _setFailure(SessionFailureCode.guestClaim);
      return false;
    }
  }

  Future<void> retryMigration() async {
    _setLoading();
    try {
      await _migration.importIfNeeded();
      final user = _authController.user;
      if (user != null) {
        await _activateAccount(user.id);
      } else if (await _preferences.isGuestSelected()) {
        await _purchases.setScope(const PurchaseScope.guest());
        _setStage(SessionStage.guest);
      } else {
        _setStage(SessionStage.welcome);
      }
    } catch (_) {
      _setFailure(SessionFailureCode.repair);
    }
  }

  Future<void> logout({Future<void> Function()? beforeLogout}) async {
    await _runExclusiveOperation(() async {
      if (beforeLogout != null) await beforeLogout();
      _setLoading();
      await _authController.logout();
      await _preferences.clearGuestSelection();
      await _purchases.setScope(const PurchaseScope.guest());
      _setStage(SessionStage.welcome);
    });
  }

  Future<void> _activateAccount(int userId) async {
    await _purchases.claimGuestReceipts(userId);
    await _purchases.setScope(PurchaseScope.account(userId));
    await _preferences.clearGuestSelection();
    _setStage(SessionStage.account);
    final onAccountReady = _onAccountReady;
    if (onAccountReady != null) unawaited(onAccountReady());
  }

  void _setLoading() {
    _failureCode = null;
    _setStage(SessionStage.loading);
  }

  void _setFailure(SessionFailureCode code) {
    _failureCode = code;
    _setStage(SessionStage.migrationFailure);
  }

  void _setStage(SessionStage value) {
    _stage = value;
    notifyListeners();
  }
}
