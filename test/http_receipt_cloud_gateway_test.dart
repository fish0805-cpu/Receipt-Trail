import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:receipt_trail/src/features/auth/auth_controller.dart';
import 'package:receipt_trail/src/features/auth/auth_gateway.dart';
import 'package:receipt_trail/src/features/auth/auth_models.dart';
import 'package:receipt_trail/src/features/auth/token_store.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/sync/http_receipt_cloud_gateway.dart';
import 'package:receipt_trail/src/features/sync/receipt_cloud_gateway.dart';

void main() {
  test(
    'cloud upsert sends idempotency key but never sends OCR raw text',
    () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response('{}', 201);
      });
      final auth = AuthController(_LoginGateway(), MemoryTokenStore());
      await auth.login(email: 'user@example.com', password: 'password123');
      final gateway = HttpReceiptCloudGateway(
        authController: auth,
        baseUri: Uri.parse('https://api.example.com'),
        client: client,
      );

      await gateway.upsertReceipt('upsert:7:receipt-1', _receipt());

      final payload = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(captured.headers['idempotency-key'], 'upsert:7:receipt-1');
      expect(payload, isNot(contains('raw_text')));
      expect(payload, isNot(contains('image_path')));
      expect(payload['subtotal'], 250);
      expect(payload['discount'], 50);
      expect(payload['seller_tax_id'], '12345678');
      expect(payload['period'], '11510');
    },
  );

  test(
    'cloud fetch applies legacy defaults and preserves new fields',
    () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode([
            {
              'id': 'legacy',
              'store_name': '舊商店',
              'address': '台北市',
              'purchased_at': '2026-05-18T12:00:00+08:00',
              'total': 208,
              'category': 'shopping',
              'items': <Object>[],
              'receipt_number': 'AB12345678',
            },
            {
              'id': 'new',
              'store_name': '新商店',
              'address': '台北市',
              'purchased_at': '2026-10-14T08:30:00+08:00',
              'subtotal': 250,
              'discount': 50,
              'total': 200,
              'seller_tax_id': '12345678',
              'period': '11510',
              'category': 'food',
              'items': <Object>[],
              'receipt_number': 'CD12345678',
            },
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
      final auth = AuthController(_LoginGateway(), MemoryTokenStore());
      await auth.login(email: 'user@example.com', password: 'password123');
      final gateway = HttpReceiptCloudGateway(
        authController: auth,
        baseUri: Uri.parse('https://api.example.com'),
        client: client,
      );

      final values = await gateway.fetchReceipts();

      expect(values.first.subtotal, 208);
      expect(values.first.discount, 0);
      expect(values.last.subtotal, 250);
      expect(values.last.discount, 50);
      expect(values.last.sellerTaxId, '12345678');
    },
  );

  test(
    'cloud upsert keeps the local invoice term at a UTC month boundary',
    () async {
      late Map<String, dynamic> payload;
      final client = MockClient((request) async {
        payload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{}', 201);
      });
      final auth = AuthController(_LoginGateway(), MemoryTokenStore());
      await auth.login(email: 'user@example.com', password: 'password123');
      final gateway = HttpReceiptCloudGateway(
        authController: auth,
        baseUri: Uri.parse('https://api.example.com'),
        client: client,
      );

      await gateway.upsertReceipt(
        'upsert:boundary',
        Receipt(
          id: 'boundary',
          storeName: '跨期商店',
          address: '台北市',
          date: DateTime.utc(2026, 10, 31, 16, 30),
          total: 100,
          category: SpendingCategory.food,
          items: const <ReceiptItem>[],
          receiptNumber: 'AB12345678',
          isSynced: false,
        ),
      );

      expect(payload['purchased_at'], '2026-10-31T16:30:00.000Z');
      expect(payload['period'], '11512');
    },
  );

  test(
    'cloud reset uses the account-wide idempotent delete endpoint',
    () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response('', 204);
      });
      final auth = AuthController(_LoginGateway(), MemoryTokenStore());
      await auth.login(email: 'user@example.com', password: 'password123');
      final gateway = HttpReceiptCloudGateway(
        authController: auth,
        baseUri: Uri.parse('https://api.example.com'),
        client: client,
      );

      await gateway.deleteAllReceipts('delete-all:7:abc');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/receipts');
      expect(captured.headers['idempotency-key'], 'delete-all:7:abc');
    },
  );

  test(
    'gateway and timeout responses are retryable without server text',
    () async {
      final failures = <Object>[502, 503, 504, TimeoutException('timeout')];
      for (final failure in failures) {
        final client = MockClient((_) {
          if (failure is int) {
            return Future.value(
              http.Response('private upstream text', failure),
            );
          }
          return Future<http.Response>.error(failure);
        });
        final auth = AuthController(_LoginGateway(), MemoryTokenStore());
        await auth.login(email: 'user@example.com', password: 'password123');
        final gateway = HttpReceiptCloudGateway(
          authController: auth,
          baseUri: Uri.parse('https://api.example.com'),
          client: client,
        );

        await expectLater(
          gateway.fetchReceipts(),
          throwsA(
            isA<SyncFailure>()
                .having((error) => error.isRetryable, 'isRetryable', isTrue)
                .having(
                  (error) => error.code,
                  'code',
                  anyOf(
                    SyncFailureCode.serviceUnavailable,
                    SyncFailureCode.networkUnavailable,
                  ),
                )
                .having(
                  (error) => error.toString(),
                  'safe diagnostic',
                  isNot(contains('private upstream text')),
                ),
          ),
        );
      }
    },
  );

  test(
    'malformed cloud payload becomes a safe invalid-response failure',
    () async {
      final client = MockClient((_) async => http.Response('{not-json', 200));
      final auth = AuthController(_LoginGateway(), MemoryTokenStore());
      await auth.login(email: 'user@example.com', password: 'password123');
      final gateway = HttpReceiptCloudGateway(
        authController: auth,
        baseUri: Uri.parse('https://api.example.com'),
        client: client,
      );

      await expectLater(
        gateway.fetchReceipts(),
        throwsA(
          isA<SyncFailure>().having(
            (error) => error.code,
            'code',
            SyncFailureCode.invalidResponse,
          ),
        ),
      );
    },
  );
}

Receipt _receipt() => Receipt(
  id: 'receipt-1',
  storeName: '測試商店',
  address: '台北市',
  date: DateTime.utc(2026, 10, 14),
  subtotal: 250,
  discount: 50,
  total: 200,
  sellerTaxId: '12345678',
  category: SpendingCategory.food,
  items: const <ReceiptItem>[ReceiptItem(name: '商品', price: 250)],
  receiptNumber: 'AB12345678',
  isSynced: false,
  rawText: '不得上傳的 OCR 原文',
);

class _LoginGateway implements AuthGateway {
  static const session = AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    user: AuthUser(id: 7, name: '測試', email: 'user@example.com'),
  );

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async => session;

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<AuthUser> me(String accessToken) async => session.user;

  @override
  Future<AuthSession> refresh(String refreshToken) async => session;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async => session;
}
