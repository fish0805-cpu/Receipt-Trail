import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_controller.dart';
import '../purchases/purchase_models.dart';
import 'receipt_cloud_gateway.dart';

class HttpReceiptCloudGateway implements ReceiptCloudGateway {
  HttpReceiptCloudGateway({
    required this.authController,
    required this.baseUri,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final AuthController authController;
  final Uri baseUri;
  final http.Client _client;

  @override
  Future<List<Receipt>> fetchReceipts() async {
    final response = await _authorizedRequest(
      (token) => _client.get(
        baseUri.resolve('/receipts'),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    try {
      final values =
          jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return values
          .map((value) => _fromApiJson(value as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const SyncFailure(SyncFailureCode.invalidResponse);
    } on TypeError {
      throw const SyncFailure(SyncFailureCode.invalidResponse);
    }
  }

  @override
  Future<void> upsertReceipt(String operationId, Receipt receipt) async {
    await _authorizedRequest(
      (token) => _client.post(
        baseUri.resolve('/receipts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Idempotency-Key': operationId,
        },
        body: jsonEncode(_toApiJson(receipt)),
      ),
      acceptedStatuses: const {200, 201},
    );
  }

  @override
  Future<void> deleteReceipt(String operationId, String receiptId) async {
    await _authorizedRequest(
      (token) => _client.delete(
        baseUri.resolve('/receipts/${Uri.encodeComponent(receiptId)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Idempotency-Key': operationId,
        },
      ),
      acceptedStatuses: const {204},
    );
  }

  @override
  Future<void> deleteAllReceipts(String operationId) async {
    await _authorizedRequest(
      (token) => _client.delete(
        baseUri.resolve('/receipts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Idempotency-Key': operationId,
        },
      ),
      acceptedStatuses: const {204},
    );
  }

  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function(String token) request, {
    Set<int> acceptedStatuses = const {200},
  }) async {
    var token = authController.accessToken;
    if (token == null) {
      throw const SyncFailure(SyncFailureCode.authenticationRequired);
    }
    try {
      var response = await request(token).timeout(const Duration(seconds: 15));
      if (response.statusCode == 401 && await authController.refreshSession()) {
        token = authController.accessToken;
        if (token != null) {
          response = await request(token).timeout(const Duration(seconds: 15));
        }
      }
      if (response.statusCode == 401 && authController.lastFailureRetryable) {
        throw const SyncFailure(
          SyncFailureCode.serviceUnavailable,
          isRetryable: true,
        );
      }
      if (const {502, 503, 504}.contains(response.statusCode)) {
        throw const SyncFailure(
          SyncFailureCode.serviceUnavailable,
          isRetryable: true,
        );
      }
      if (!acceptedStatuses.contains(response.statusCode)) {
        throw SyncFailure(
          SyncFailureCode.unknown,
          statusCode: response.statusCode,
        );
      }
      return response;
    } on TimeoutException {
      throw const SyncFailure(
        SyncFailureCode.networkUnavailable,
        isRetryable: true,
      );
    } on http.ClientException {
      throw const SyncFailure(
        SyncFailureCode.networkUnavailable,
        isRetryable: true,
      );
    }
  }

  Map<String, Object?> _toApiJson(Receipt receipt) => {
    'id': receipt.id,
    'store_name': receipt.storeName,
    'address': receipt.address,
    'purchased_at': receipt.date.toUtc().toIso8601String(),
    'subtotal': receipt.subtotal,
    'discount': receipt.discount,
    'total': receipt.total,
    'category': receipt.category.name,
    'items': receipt.items.map((item) => item.toJson()).toList(),
    'receipt_number': receipt.receiptNumber,
    'seller_tax_id': receipt.sellerTaxId,
    'period': receipt.period.rocTerm,
    'latitude': receipt.latitude,
    'longitude': receipt.longitude,
  };

  Receipt _fromApiJson(Map<String, dynamic> json) => Receipt(
    id: json['id'] as String,
    storeName: json['store_name'] as String,
    address: json['address'] as String? ?? '',
    date: DateTime.parse(json['purchased_at'] as String).toLocal(),
    subtotal: json['subtotal'] as int?,
    discount: json['discount'] as int? ?? 0,
    total: json['total'] as int,
    sellerTaxId: json['seller_tax_id'] as String?,
    category: SpendingCategory.values.firstWhere(
      (value) => value.name == json['category'],
      orElse: () => SpendingCategory.other,
    ),
    items: (json['items'] as List<dynamic>? ?? const [])
        .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    receiptNumber: json['receipt_number'] as String? ?? '',
    isSynced: true,
    rawText: json['raw_text'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}
