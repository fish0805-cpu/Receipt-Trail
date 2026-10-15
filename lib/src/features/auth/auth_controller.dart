import 'package:flutter/foundation.dart';

import 'auth_gateway.dart';
import 'auth_models.dart';
import 'token_store.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._gateway, this._tokenStore);

  factory AuthController.guest() => AuthController(
        const UnavailableAuthGateway(),
        MemoryTokenStore(),
      );

  final AuthGateway _gateway;
  final TokenStore _tokenStore;
  AuthUser? _user;
  StoredTokens? _tokens;
  bool _isLoading = false;
  AuthFailureCode? _errorCode;
  bool _lastFailureRetryable = false;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  AuthFailureCode? get errorCode => _errorCode;
  String? get accessToken => _tokens?.accessToken;
  bool get lastFailureRetryable => _lastFailureRetryable;

  Future<bool> refreshSession() async {
    final refreshToken = _tokens?.refreshToken;
    if (refreshToken == null) return false;
    try {
      await _acceptSession(await _gateway.refresh(refreshToken));
      _errorCode = null;
      _lastFailureRetryable = false;
      notifyListeners();
      return true;
    } on AuthFailure catch (error) {
      _lastFailureRetryable = error.isRetryable;
      _errorCode = error.code;
      if (error.statusCode == 401) await _clearSession();
      notifyListeners();
      return false;
    }
  }

  Future<void> initialize() async {
    _errorCode = null;
    _lastFailureRetryable = false;
    _tokens = await _tokenStore.read();
    if (_tokens == null) return;
    _user = _tokens!.user;
    try {
      _user = await _gateway.me(_tokens!.accessToken);
      _tokens = StoredTokens(
        accessToken: _tokens!.accessToken,
        refreshToken: _tokens!.refreshToken,
        user: _user,
      );
      await _tokenStore.write(_tokens!);
    } on AuthFailure catch (error) {
      if (error.statusCode != 401) {
        _lastFailureRetryable = error.isRetryable;
        _errorCode = error.code;
        notifyListeners();
        return;
      }
      try {
        await _acceptSession(await _gateway.refresh(_tokens!.refreshToken));
        return;
      } on AuthFailure catch (refreshError) {
        if (refreshError.statusCode != 401) {
          _lastFailureRetryable = refreshError.isRetryable;
          _errorCode = refreshError.code;
          notifyListeners();
          return;
        }
      }
      await _clearSession();
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) =>
      _run(() => _gateway.login(email: email, password: password));

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _run(() => _gateway.register(
            name: name,
            email: email,
            password: password,
          ));

  Future<void> logout() async {
    final refreshToken = _tokens?.refreshToken;
    await _clearSession();
    notifyListeners();
    if (refreshToken != null) {
      try {
        await _gateway.logout(refreshToken);
      } on AuthFailure {
        // Local logout must still succeed when the API is unavailable.
      }
    }
  }

  Future<bool> _run(Future<AuthSession> Function() request) async {
    _isLoading = true;
    _errorCode = null;
    notifyListeners();
    try {
      await _acceptSession(await request());
      return true;
    } on AuthFailure catch (error) {
      _lastFailureRetryable = error.isRetryable;
      _errorCode = error.code;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _acceptSession(AuthSession session) async {
    _tokens = StoredTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      user: session.user,
    );
    _user = session.user;
    _lastFailureRetryable = false;
    _errorCode = null;
    await _tokenStore.write(_tokens!);
  }

  Future<void> _clearSession() async {
    _tokens = null;
    _user = null;
    _errorCode = null;
    _lastFailureRetryable = false;
    await _tokenStore.clear();
  }
}
