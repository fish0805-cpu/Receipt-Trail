import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_gateway.dart';
import 'auth_models.dart';

class HttpAuthGateway implements AuthGateway {
  HttpAuthGateway({required this.baseUri, http.Client? client})
      : _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return AuthSession.fromJson(json);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthSession.fromJson(json);
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    final json = await _post('/auth/refresh', {'refresh_token': refreshToken});
    return AuthSession.fromJson(json);
  }

  @override
  Future<AuthUser> me(String accessToken) async {
    try {
      final response = await _client.get(
        baseUri.resolve('/auth/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      ).timeout(const Duration(seconds: 10));
      return AuthUser.fromJson(_decode(response));
    } on TimeoutException {
      throw const AuthFailure(
        AuthFailureCode.networkUnavailable,
        isRetryable: true,
      );
    } on http.ClientException {
      throw const AuthFailure(
        AuthFailureCode.networkUnavailable,
        isRetryable: true,
      );
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _post(
      '/auth/logout',
      {'refresh_token': refreshToken},
      acceptedStatuses: const {204},
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Set<int> acceptedStatuses = const {200, 201},
  }) async {
    try {
      final response = await _client
          .post(
            baseUri.resolve(path),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      if (acceptedStatuses.contains(response.statusCode) &&
          response.body.isEmpty) {
        return const {};
      }
      return _decode(response, acceptedStatuses: acceptedStatuses);
    } on TimeoutException {
      throw const AuthFailure(
        AuthFailureCode.networkUnavailable,
        isRetryable: true,
      );
    } on http.ClientException {
      throw const AuthFailure(
        AuthFailureCode.networkUnavailable,
        isRetryable: true,
      );
    }
  }

  Map<String, dynamic> _decode(
    http.Response response, {
    Set<int> acceptedStatuses = const {200},
  }) {
    if (const {502, 503, 504}.contains(response.statusCode)) {
      throw AuthFailure(
        AuthFailureCode.serviceUnavailable,
        statusCode: response.statusCode,
        isRetryable: true,
      );
    }
    Map<String, dynamic> json = const {};
    if (response.body.isNotEmpty) {
      try {
        json =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } on FormatException {
        throw AuthFailure(
          AuthFailureCode.malformedResponse,
          statusCode: response.statusCode,
        );
      }
    }
    if (!acceptedStatuses.contains(response.statusCode)) {
      throw AuthFailure(
        switch (response.statusCode) {
          401 => AuthFailureCode.invalidCredentials,
          409 => AuthFailureCode.emailAlreadyRegistered,
          _ => AuthFailureCode.unknown,
        },
        statusCode: response.statusCode,
      );
    }
    return json;
  }
}
