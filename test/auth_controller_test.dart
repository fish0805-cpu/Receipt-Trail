import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/auth/auth_controller.dart';
import 'package:receipt_trail/src/features/auth/auth_gateway.dart';
import 'package:receipt_trail/src/features/auth/auth_models.dart';
import 'package:receipt_trail/src/features/auth/token_store.dart';

void main() {
  test('已登入裝置在後端逾時時仍可啟動且保留登入憑證', () async {
    final tokenStore = MemoryTokenStore()
      ..tokens = const StoredTokens(
        accessToken: 'saved-access-token',
        refreshToken: 'saved-refresh-token',
      );
    final controller = AuthController(_TimeoutAuthGateway(), tokenStore);

    await controller.initialize();

    expect(controller.accessToken, 'saved-access-token');
    expect(tokenStore.tokens?.refreshToken, 'saved-refresh-token');
  });

  test('已登入裝置無法連線時仍可啟動且保留登入憑證', () async {
    final tokenStore = MemoryTokenStore()
      ..tokens = const StoredTokens(
        accessToken: 'saved-access-token',
        refreshToken: 'saved-refresh-token',
      );
    final controller = AuthController(_DisconnectedAuthGateway(), tokenStore);

    await controller.initialize();

    expect(controller.accessToken, 'saved-access-token');
    expect(tokenStore.tokens?.refreshToken, 'saved-refresh-token');
  });

  test('更新登入憑證暫時離線時不會清除既有登入憑證', () async {
    final tokenStore = MemoryTokenStore()
      ..tokens = const StoredTokens(
        accessToken: 'saved-access-token',
        refreshToken: 'saved-refresh-token',
      );
    final controller = AuthController(_OfflineRefreshAuthGateway(), tokenStore);
    await controller.initialize();

    final refreshed = await controller.refreshSession();

    expect(refreshed, isFalse);
    expect(controller.accessToken, 'saved-access-token');
    expect(tokenStore.tokens?.refreshToken, 'saved-refresh-token');
  });

  test('已有快取使用者的裝置離線啟動後仍維持登入狀態', () async {
    final tokenStore = MemoryTokenStore()
      ..tokens = const StoredTokens(
        accessToken: 'saved-access-token',
        refreshToken: 'saved-refresh-token',
        user: AuthUser(id: 7, name: '離線使用者', email: 'offline@example.com'),
      );
    final controller = AuthController(_TimeoutAuthGateway(), tokenStore);

    await controller.initialize();

    expect(controller.isAuthenticated, isTrue);
    expect(controller.user?.name, '離線使用者');
  });

  test('登入服務暫時故障時不會登出已快取的使用者', () async {
    final tokenStore = MemoryTokenStore()
      ..tokens = const StoredTokens(
        accessToken: 'saved-access-token',
        refreshToken: 'saved-refresh-token',
        user: AuthUser(id: 7, name: '離線使用者', email: 'offline@example.com'),
      );
    final controller = AuthController(_UnavailableAuthGateway(), tokenStore);

    await controller.initialize();

    expect(controller.isAuthenticated, isTrue);
    expect(controller.accessToken, 'saved-access-token');
    expect(controller.errorCode, AuthFailureCode.serviceUnavailable);
  });

  test('Access Token 過期但更新服務離線時保留快取登入狀態', () async {
    final tokenStore = MemoryTokenStore()
      ..tokens = const StoredTokens(
        accessToken: 'expired-access-token',
        refreshToken: 'saved-refresh-token',
        user: AuthUser(id: 7, name: '離線使用者', email: 'offline@example.com'),
      );
    final controller =
        AuthController(_ExpiredThenOfflineAuthGateway(), tokenStore);

    await controller.initialize();

    expect(controller.isAuthenticated, isTrue);
    expect(tokenStore.tokens?.refreshToken, 'saved-refresh-token');
  });

  test('伺服器確認 Access 與 Refresh Token 都失效時清除登入狀態', () async {
    final tokenStore = MemoryTokenStore()
      ..tokens = const StoredTokens(
        accessToken: 'expired-access-token',
        refreshToken: 'expired-refresh-token',
        user: AuthUser(id: 7, name: '舊使用者', email: 'old@example.com'),
      );
    final controller = AuthController(_InvalidSessionAuthGateway(), tokenStore);

    await controller.initialize();

    expect(controller.isAuthenticated, isFalse);
    expect(controller.accessToken, isNull);
    expect(tokenStore.tokens, isNull);
  });
}

class _TimeoutAuthGateway implements AuthGateway {
  @override
  Future<AuthUser> me(String accessToken) => Future<AuthUser>.error(
        const AuthFailure(AuthFailureCode.networkUnavailable),
      );

  Never _unexpected() => throw StateError('這個測試不應呼叫其他認證 API');

  @override
  Future<AuthSession> login(
          {required String email, required String password}) =>
      Future<AuthSession>.error(_unexpected());

  @override
  Future<void> logout(String refreshToken) => Future<void>.error(_unexpected());

  @override
  Future<AuthSession> refresh(String refreshToken) =>
      Future<AuthSession>.error(_unexpected());

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) =>
      Future<AuthSession>.error(_unexpected());
}

class _DisconnectedAuthGateway extends _TimeoutAuthGateway {
  @override
  Future<AuthUser> me(String accessToken) => Future<AuthUser>.error(
        const AuthFailure(AuthFailureCode.networkUnavailable),
      );
}

class _OfflineRefreshAuthGateway extends _TimeoutAuthGateway {
  @override
  Future<AuthSession> refresh(String refreshToken) => Future<AuthSession>.error(
        const AuthFailure(AuthFailureCode.networkUnavailable),
      );
}

class _UnavailableAuthGateway extends _TimeoutAuthGateway {
  @override
  Future<AuthUser> me(String accessToken) => Future<AuthUser>.error(
        const AuthFailure(
          AuthFailureCode.serviceUnavailable,
          statusCode: 503,
          isRetryable: true,
        ),
      );
}

class _ExpiredThenOfflineAuthGateway extends _TimeoutAuthGateway {
  @override
  Future<AuthUser> me(String accessToken) => Future<AuthUser>.error(
        const AuthFailure(AuthFailureCode.sessionExpired, statusCode: 401),
      );

  @override
  Future<AuthSession> refresh(String refreshToken) => Future<AuthSession>.error(
        const AuthFailure(AuthFailureCode.networkUnavailable),
      );
}

class _InvalidSessionAuthGateway extends _ExpiredThenOfflineAuthGateway {
  @override
  Future<AuthSession> refresh(String refreshToken) => Future<AuthSession>.error(
        const AuthFailure(AuthFailureCode.sessionExpired, statusCode: 401),
      );
}
