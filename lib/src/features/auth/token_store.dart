import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_models.dart';

abstract interface class TokenStore {
  Future<StoredTokens?> read();
  Future<void> write(StoredTokens tokens);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  static const _accessKey = 'receipt_trail.access_token';
  static const _refreshKey = 'receipt_trail.refresh_token';
  static const _userKey = 'receipt_trail.auth_user';
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  @override
  Future<StoredTokens?> read() async {
    final values = await Future.wait([
      _storage.read(key: _accessKey),
      _storage.read(key: _refreshKey),
      _storage.read(key: _userKey),
    ]);
    if (values[0] == null || values[1] == null) return null;
    AuthUser? user;
    if (values[2] != null) {
      try {
        user =
            AuthUser.fromJson(jsonDecode(values[2]!) as Map<String, dynamic>);
      } on FormatException {
        // An invalid optional cache must not prevent session restoration.
      } on TypeError {
        // Ignore an outdated cache shape and refresh it from the API.
      }
    }
    return StoredTokens(
      accessToken: values[0]!,
      refreshToken: values[1]!,
      user: user,
    );
  }

  @override
  Future<void> write(StoredTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: tokens.accessToken),
      _storage.write(key: _refreshKey, value: tokens.refreshToken),
      if (tokens.user case final user?)
        _storage.write(key: _userKey, value: jsonEncode(user.toJson()))
      else
        _storage.delete(key: _userKey),
    ]);
  }

  @override
  Future<void> clear() => _storage.deleteAll();
}

class MemoryTokenStore implements TokenStore {
  StoredTokens? tokens;

  @override
  Future<void> clear() async => tokens = null;

  @override
  Future<StoredTokens?> read() async => tokens;

  @override
  Future<void> write(StoredTokens tokens) async => this.tokens = tokens;
}
