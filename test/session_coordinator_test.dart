import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/auth/auth_controller.dart';
import 'package:receipt_trail/src/features/auth/auth_gateway.dart';
import 'package:receipt_trail/src/features/auth/auth_models.dart';
import 'package:receipt_trail/src/features/auth/token_store.dart';
import 'package:receipt_trail/src/features/purchases/data/legacy_receipt_importer.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/purchase_repository.dart';
import 'package:receipt_trail/src/features/session/session_coordinator.dart';

void main() {
  test(
    'first launch stays on welcome until guest is explicitly selected',
    () async {
      final preferences = MemorySessionPreferenceStore();
      final repository = MemoryPurchaseRepository();
      final coordinator = SessionCoordinator(
        authController: AuthController(
          _SuccessfulAuthGateway(),
          MemoryTokenStore(),
        ),
        purchases: repository,
        migration: const _SuccessfulMigration(),
        preferences: preferences,
      );

      await coordinator.initialize();
      expect(coordinator.stage, SessionStage.welcome);

      await coordinator.continueAsGuest();
      expect(coordinator.stage, SessionStage.guest);
      expect(preferences.guestSelected, isTrue);
    },
  );

  test('login claims guest data before exposing account stage', () async {
    final repository = MemoryPurchaseRepository(<Receipt>[_receipt('guest-1')]);
    final coordinator = SessionCoordinator(
      authController: AuthController(
        _SuccessfulAuthGateway(),
        MemoryTokenStore(),
      ),
      purchases: repository,
      migration: const _SuccessfulMigration(),
      preferences: MemorySessionPreferenceStore()..guestSelected = true,
    );
    await coordinator.initialize();

    final loggedIn = await coordinator.login(
      email: 'cloria@example.com',
      password: 'password123',
    );

    expect(loggedIn, isTrue);
    expect(coordinator.stage, SessionStage.account);
    expect(coordinator.user?.id, 7);
    expect(await repository.pendingOperations(7), hasLength(1));
    expect(await repository.watchReceipts().first, hasLength(1));
  });

  test(
    'claim failure keeps data and exposes a retryable repair state',
    () async {
      final repository = _FailingClaimRepository(<Receipt>[
        _receipt('guest-1'),
      ]);
      final coordinator = SessionCoordinator(
        authController: AuthController(
          _SuccessfulAuthGateway(),
          MemoryTokenStore(),
        ),
        purchases: repository,
        migration: const _SuccessfulMigration(),
        preferences: MemorySessionPreferenceStore()..guestSelected = true,
      );
      await coordinator.initialize();

      expect(
        await coordinator.login(
          email: 'cloria@example.com',
          password: 'password123',
        ),
        isFalse,
      );
      expect(coordinator.stage, SessionStage.migrationFailure);
      expect(coordinator.failureCode, SessionFailureCode.guestClaim);

      repository.shouldFail = false;
      await coordinator.retryMigration();
      expect(coordinator.stage, SessionStage.account);
      expect(await repository.pendingOperations(7), hasLength(1));
    },
  );

  test(
    'restored session opens account scope and logout returns to welcome',
    () async {
      final tokenStore = MemoryTokenStore()
        ..tokens = const StoredTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          user: AuthUser(id: 7, name: 'Cloria', email: 'cloria@example.com'),
        );
      final repository = MemoryPurchaseRepository();
      final coordinator = SessionCoordinator(
        authController: AuthController(_SuccessfulAuthGateway(), tokenStore),
        purchases: repository,
        migration: const _SuccessfulMigration(),
        preferences: MemorySessionPreferenceStore(),
      );

      await coordinator.initialize();
      expect(coordinator.stage, SessionStage.account);

      await coordinator.logout();
      expect(coordinator.stage, SessionStage.welcome);
      expect(tokenStore.tokens, isNull);
    },
  );

  test(
    'account-ready callback runs only after guest claim and scope switch',
    () async {
      final repository = MemoryPurchaseRepository(<Receipt>[
        _receipt('guest-1'),
      ]);
      var readyCalls = 0;
      final coordinator = SessionCoordinator(
        authController: AuthController(
          _SuccessfulAuthGateway(),
          MemoryTokenStore(),
        ),
        purchases: repository,
        migration: const _SuccessfulMigration(),
        preferences: MemorySessionPreferenceStore(),
        onAccountReady: () async {
          readyCalls++;
          expect(await repository.pendingOperations(7), hasLength(1));
          expect(await repository.watchReceipts().first, hasLength(1));
        },
      );
      await coordinator.initialize();

      await coordinator.login(
        email: 'cloria@example.com',
        password: 'password123',
      );

      expect(readyCalls, 1);
    },
  );

  test(
    'logout waits for the shared sync exclusive-operation boundary',
    () async {
      final gate = Completer<void>();
      var insideExclusiveOperation = false;
      var deviceDataCleared = false;
      final tokenStore = MemoryTokenStore()
        ..tokens = const StoredTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          user: AuthUser(id: 7, name: 'Cloria', email: 'cloria@example.com'),
        );
      final coordinator = SessionCoordinator(
        authController: AuthController(_SuccessfulAuthGateway(), tokenStore),
        purchases: MemoryPurchaseRepository(),
        migration: const _SuccessfulMigration(),
        preferences: MemorySessionPreferenceStore(),
        runExclusiveOperation: <T>(operation) async {
          await gate.future;
          insideExclusiveOperation = true;
          try {
            return await operation();
          } finally {
            insideExclusiveOperation = false;
          }
        },
      );
      await coordinator.initialize();

      final logout = coordinator.logout(
        beforeLogout: () async {
          expect(insideExclusiveOperation, isTrue);
          deviceDataCleared = true;
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(coordinator.stage, SessionStage.account);
      expect(tokenStore.tokens, isNotNull);
      gate.complete();
      await logout;
      expect(deviceDataCleared, isTrue);
      expect(coordinator.stage, SessionStage.welcome);
      expect(tokenStore.tokens, isNull);
    },
  );
}

class _SuccessfulMigration implements LegacyMigration {
  const _SuccessfulMigration();

  @override
  Future<LegacyImportResult> importIfNeeded() async =>
      const LegacyImportResult(importedCount: 0, wasAlreadyComplete: false);
}

class _SuccessfulAuthGateway implements AuthGateway {
  static const user = AuthUser(
    id: 7,
    name: 'Cloria',
    email: 'cloria@example.com',
  );

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async => const AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    user: user,
  );

  @override
  Future<AuthUser> me(String accessToken) async => user;

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<AuthSession> refresh(String refreshToken) =>
      login(email: user.email, password: 'password123');

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) => login(email: email, password: password);
}

class _FailingClaimRepository extends MemoryPurchaseRepository {
  _FailingClaimRepository(super.initial);

  bool shouldFail = true;

  @override
  Future<int> claimGuestReceipts(int userId) {
    if (shouldFail) throw StateError('simulated claim failure');
    return super.claimGuestReceipts(userId);
  }
}

Receipt _receipt(String id) => Receipt(
  id: id,
  storeName: '訪客商店',
  address: '台北市',
  date: DateTime.utc(2026, 10, 14),
  total: 100,
  category: SpendingCategory.other,
  items: const <ReceiptItem>[ReceiptItem(name: '商品', price: 100)],
  receiptNumber: 'AB12345678',
  isSynced: false,
);
