import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:receipt_trail/src/features/auth/auth_gateway.dart';
import 'package:receipt_trail/src/features/auth/http_auth_gateway.dart';

void main() {
  test('502 503 and 504 are retryable cloud wake-up failures', () async {
    for (final status in <int>[502, 503, 504]) {
      final gateway = HttpAuthGateway(
        baseUri: Uri.parse('https://api.example.com'),
        client: MockClient((_) async => http.Response('temporary', status)),
      );

      await expectLater(
        gateway.login(email: 'user@example.com', password: 'password'),
        throwsA(
          isA<AuthFailure>()
              .having((error) => error.isRetryable, 'isRetryable', isTrue)
              .having(
                (error) => error.code,
                'code',
                AuthFailureCode.serviceUnavailable,
              ),
        ),
      );
    }
  });

  test('timeout and connection failures are retryable', () async {
    final failures = <Object>[
      TimeoutException('timeout'),
      http.ClientException('offline'),
    ];
    for (final failure in failures) {
      final gateway = HttpAuthGateway(
        baseUri: Uri.parse('https://api.example.com'),
        client: MockClient((_) => Future<http.Response>.error(failure)),
      );
      await expectLater(
        gateway.login(email: 'user@example.com', password: 'password'),
        throwsA(
          isA<AuthFailure>()
              .having((error) => error.isRetryable, 'isRetryable', isTrue)
              .having(
                (error) => error.code,
                'code',
                AuthFailureCode.networkUnavailable,
              ),
        ),
      );
    }
  });

  test('confirmed 401 is not retryable', () async {
    final gateway = HttpAuthGateway(
      baseUri: Uri.parse('https://api.example.com'),
      client: MockClient((_) async => http.Response(
            '{"detail":"登入憑證已失效"}',
            401,
            headers: {'content-type': 'application/json; charset=utf-8'},
          )),
    );

    await expectLater(
      gateway.login(email: 'user@example.com', password: 'password'),
      throwsA(
        isA<AuthFailure>()
            .having((error) => error.isRetryable, 'isRetryable', isFalse)
            .having(
              (error) => error.code,
              'code',
              AuthFailureCode.invalidCredentials,
            )
            .having(
              (error) => error.toString(),
              'safe diagnostic',
              isNot(contains('登入憑證已失效')),
            ),
      ),
    );
  });
}
