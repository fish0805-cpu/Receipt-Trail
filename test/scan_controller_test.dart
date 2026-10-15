import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/scanning/receipt_scan_models.dart';
import 'package:receipt_trail/src/features/scanning/receipt_scanner.dart';
import 'package:receipt_trail/src/features/scanning/scan_controller.dart';
import 'package:receipt_trail/src/features/scanning/taiwan_invoice_qr.dart';

void main() {
  test('cancelled image selection does not create a draft or receipt',
      () async {
    final controller = ScanController(_FakeScanner());

    await controller.capture(ScanSource.gallery);

    expect(controller.draft, isNull);
    expect(
        controller.confirm(
          storeName: '測試',
          address: '',
          receiptNumber: '',
          total: 100,
          date: DateTime(2026, 10, 13),
          category: SpendingCategory.other,
        ),
        completion(isNull));
  });

  test('scanner failure becomes presentable controller state', () async {
    final controller = ScanController(
      _FakeScanner()
        ..failure = const ScanFailure(ScanFailureCode.recognitionFailed),
    );

    await controller.capture(ScanSource.camera);

    expect(controller.failure?.code, ScanFailureCode.recognitionFailed);
    expect(controller.isProcessing, isFalse);
  });

  test('confirmation creates one unsynced receipt only once', () async {
    final scanner = _FakeScanner()
      ..draft = ReceiptScanDraft(
        storeName: '綠日咖啡',
        address: '台北市信義區',
        receiptNumber: 'AB12345678',
        total: 180,
        date: DateTime(2026, 10, 13),
        rawText: 'OCR',
      );
    final controller = ScanController(scanner);
    await controller.capture(ScanSource.camera);

    final first = await controller.confirm(
      storeName: '綠日咖啡',
      address: '台北市信義區',
      receiptNumber: 'AB12345678',
      total: 180,
      date: DateTime(2026, 10, 13),
      category: SpendingCategory.food,
    );
    final second = await controller.confirm(
      storeName: '綠日咖啡',
      address: '台北市信義區',
      receiptNumber: 'AB12345678',
      total: 180,
      date: DateTime(2026, 10, 13),
      category: SpendingCategory.food,
    );

    expect(first?.storeName, '綠日咖啡');
    expect(first?.rawText, 'OCR');
    expect(first?.isSynced, isFalse);
    expect(first?.latitude, 25.03);
    expect(first?.subtotal, 180);
    expect(first?.discount, 0);
    expect(first?.sellerTaxId, isNull);
    expect(second, isNull);
  });

  test('confirmation preserves reviewed seller, amounts and real item rows',
      () async {
    final scanner = _FakeScanner()
      ..draft = const ReceiptScanDraft(
        total: 220,
        subtotal: 250,
        discount: 30,
        sellerTaxId: '12345678',
        items: <ReceiptItem>[
          ReceiptItem(name: '咖啡', quantity: 2, price: 100),
          ReceiptItem(name: '麵包', quantity: 1, price: 50),
        ],
      );
    final controller = ScanController(scanner);
    await controller.capture(ScanSource.camera);

    final receipt = await controller.confirm(
      storeName: '測試商店',
      address: '',
      receiptNumber: 'AB12345678',
      total: 220,
      date: DateTime(2026, 10, 13),
      category: SpendingCategory.food,
    );

    expect(receipt?.sellerTaxId, '12345678');
    expect(receipt?.subtotal, 250);
    expect(receipt?.discount, 30);
    expect(receipt?.items.map((item) => item.name), ['咖啡', '麵包']);
  });

  test('left and right QR captured together keep both item rows', () async {
    const left = 'AB123456781151012123400000000000000FA0000000012345678'
        'abcdefghijklmnopqrstuvwx:**********:2:2:1:咖啡:2:100:';
    final controller = ScanController(_QrScanner());

    await controller.acceptBarcode(left, rightValue: '**麵包:1:50');

    expect(controller.draft?.items.map((item) => item.name), ['咖啡', '麵包']);
    expect(controller.draft?.itemsComplete, isTrue);
  });
}

class _QrScanner implements ReceiptScanner {
  @override
  Future<ReceiptScanDraft?> analyzeBarcode(
    String rawValue, {
    String? rightValue,
  }) async {
    final parsed = parseTaiwanInvoiceQr(rawValue, rightValue: rightValue);
    if (parsed == null) return null;
    return ReceiptScanDraft(
      items: parsed.items,
      itemsComplete: parsed.itemsComplete,
    );
  }

  @override
  Future<ReceiptScanDraft?> capture(ScanSource source) async => null;

  @override
  Future<GeoPoint?> locateAddress(String address) async => null;

  @override
  Future<void> dispose() async {}
}

class _FakeScanner implements ReceiptScanner {
  ReceiptScanDraft? draft;
  ScanFailure? failure;

  @override
  Future<ReceiptScanDraft?> analyzeBarcode(
    String rawValue, {
    String? rightValue,
  }) async =>
      draft;

  @override
  Future<ReceiptScanDraft?> capture(ScanSource source) async {
    if (failure case final value?) throw value;
    return draft;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<GeoPoint?> locateAddress(String address) async =>
      const GeoPoint(latitude: 25.03, longitude: 121.53);
}
