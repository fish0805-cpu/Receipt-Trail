import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/scanning/taiwan_invoice_qr.dart';

void main() {
  test('parses Taiwan electronic invoice QR header', () {
    const value = 'AB1234567811410121234000000EE000000FA';

    final result = parseTaiwanInvoiceQr(value);

    expect(result, isNotNull);
    expect(result!.receiptNumber, 'AB12345678');
    expect(result.date, DateTime(2025, 10, 12));
    expect(result.total, 250);
  });

  test('returns null for unrelated QR content', () {
    expect(parseTaiwanInvoiceQr('https://example.com'), isNull);
    expect(parseTaiwanInvoiceQr('AB12345678'), isNull);
  });

  test('reads seller tax id and complete UTF-8 items from the official layout',
      () {
    const left = 'AB123456781151012123400000000000000FA0000000012345678'
        'abcdefghijklmnopqrstuvwx:**********:2:2:1:咖啡:2:100:麵包:1:50';

    final result = parseTaiwanInvoiceQr(left);

    expect(result?.sellerTaxId, '12345678');
    expect(result?.total, 250);
    expect(result?.itemsComplete, isTrue);
    expect(result?.items.map((item) => item.name), ['咖啡', '麵包']);
    expect(result?.items.first.quantity, 2);
    expect(result?.items.first.price, 100);
  });

  test('combines a matching right QR and flags missing items', () {
    const left = 'AB123456781151012123400000000000000FA0000000012345678'
        'abcdefghijklmnopqrstuvwx:**********:2:2:1:咖啡:2:100:';

    final partial = parseTaiwanInvoiceQr(left);
    final combined = parseTaiwanInvoiceQr(left, rightValue: '**麵包:1:50');

    expect(partial?.items, hasLength(1));
    expect(partial?.itemsComplete, isFalse);
    expect(combined?.items, hasLength(2));
    expect(combined?.itemsComplete, isTrue);
  });

  test('decodes Base64 item details split across the two QR codes', () {
    const left = 'AB123456781151012123400000000000000FA0000000012345678'
        'abcdefghijklmnopqrstuvwx:**********:3:3:2:5Lm+6Zu75rGg';
    const right = '**OjE6MTA1OuWPo+e9qToxOjIxMDrniZvlpbY6MToyNQ==';

    final result = parseTaiwanInvoiceQr(left, rightValue: right);

    expect(result?.items.map((item) => item.name), ['乾電池', '口罩', '牛奶']);
    expect(result?.itemsComplete, isTrue);
  });
}
