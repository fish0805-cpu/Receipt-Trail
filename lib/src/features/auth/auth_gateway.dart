import 'auth_models.dart';

enum AuthFailureCode {
  networkUnavailable,
  serviceUnavailable,
  invalidCredentials,
  emailAlreadyRegistered,
  sessionExpired,
  malformedResponse,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(
    this.code, {
    this.statusCode,
    this.isRetryable = false,
  });

  final AuthFailureCode code;
  final int? statusCode;
  final bool isRetryable;

  @override
  String toString() => 'AuthFailure($code, statusCode: $statusCode)';
}

abstract interface class AuthGateway {
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> refresh(String refreshToken);
  Future<AuthUser> me(String accessToken);
  Future<void> logout(String refreshToken);
}

class UnavailableAuthGateway implements AuthGateway {
  const UnavailableAuthGateway();

  Never _unavailable() =>
      throw const AuthFailure(AuthFailureCode.serviceUnavailable);

  @override
  Future<AuthSession> login(
          {required String email, required String password}) =>
      Future.error(_unavailable());

  @override
  Future<void> logout(String refreshToken) => Future.error(_unavailable());

  @override
  Future<AuthUser> me(String accessToken) => Future.error(_unavailable());

  @override
  Future<AuthSession> refresh(String refreshToken) =>
      Future.error(_unavailable());

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) =>
      Future.error(_unavailable());
}
