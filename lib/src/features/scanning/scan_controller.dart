import 'package:flutter/foundation.dart';

import '../purchases/purchase_models.dart';
import 'receipt_scan_models.dart';
import 'receipt_scanner.dart';

class ScanController extends ChangeNotifier {
  ScanController(this._scanner, {this.disposeScanner = true});

  final ReceiptScanner _scanner;
  final bool disposeScanner;
  ReceiptScanDraft? _draft;
  ScanFailure? _failure;
  bool _isProcessing = false;
  bool _confirmed = false;

  ReceiptScanDraft? get draft => _draft;
  ScanFailure? get failure => _failure;
  bool get isProcessing => _isProcessing;

  void startManualEntry() {
    _draft ??= const ReceiptScanDraft();
    _failure = null;
    notifyListeners();
  }

  Future<void> capture(ScanSource source) =>
      _run(() => _scanner.capture(source));

  Future<void> acceptBarcode(String rawValue, {String? rightValue}) =>
      _run(() => _scanner.analyzeBarcode(rawValue, rightValue: rightValue));

  Future<void> _run(Future<ReceiptScanDraft?> Function() operation) async {
    _isProcessing = true;
    _failure = null;
    notifyListeners();
    try {
      _draft = await operation();
    } on ScanFailure catch (error) {
      _failure = error;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Receipt?> confirm({
    required String storeName,
    required String address,
    required String receiptNumber,
    required int total,
    required DateTime date,
    required SpendingCategory category,
    int? subtotal,
    int? discount,
    String? sellerTaxId,
    List<ReceiptItem>? items,
  }) async {
    if (_draft == null || _confirmed) return null;
    _confirmed = true;
    GeoPoint? point;
    if (address.trim().isNotEmpty) {
      try {
        point = await _scanner.locateAddress(address.trim());
      } on ScanFailure {
        // A receipt remains valid when geocoding is unavailable.
      }
    }
    final now = DateTime.now();
    return Receipt(
      id: now.microsecondsSinceEpoch.toString(),
      storeName: storeName.trim(),
      address: address.trim(),
      date: date,
      total: total,
      subtotal: subtotal ?? _draft?.subtotal,
      discount: discount ?? _draft?.discount ?? 0,
      sellerTaxId: sellerTaxId ?? _draft?.sellerTaxId,
      category: category,
      items: items ?? _draft?.items ?? const <ReceiptItem>[],
      receiptNumber: receiptNumber.trim(),
      isSynced: false,
      rawText: _draft?.rawText,
      latitude: point?.latitude,
      longitude: point?.longitude,
    );
  }

  void allowRetryAfterSaveFailure() {
    _confirmed = false;
  }

  @override
  void dispose() {
    if (disposeScanner) _scanner.dispose();
    super.dispose();
  }
}
