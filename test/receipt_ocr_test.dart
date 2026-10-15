import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/scanning/receipt_ocr.dart';

void main() {
  test('extracts common Taiwan receipt fields from OCR text', () {
    final result = parseReceiptText('''
綠日咖啡股份有限公司
台北市信義區市府路1號
電子發票證明聯
AB-12345678
日期 115/10/12
總計：NT\$ 1,280
''');

    expect(result.storeName, '綠日咖啡股份有限公司');
    expect(result.address, '台北市信義區市府路1號');
    expect(result.receiptNumber, 'AB12345678');
    expect(result.total, 1280);
    expect(result.date, DateTime(2026, 10, 12));
    expect(result.rawText, contains('電子發票證明聯'));
  });

  test('extracts explicit seller, amounts and verified item rows', () {
    final result = parseReceiptText('''
測試咖啡
賣方統編：12345678
消費明細
咖啡 2 100 200
麵包 1 50 50
小計 250
折扣 30
實付 220
''');

    expect(result.sellerTaxId, '12345678');
    expect(result.subtotal, 250);
    expect(result.discount, 30);
    expect(result.total, 220);
    expect(result.items.map((item) => item.name), ['咖啡', '麵包']);
    expect(result.items.first.quantity, 2);
    expect(result.items.first.price, 100);
  });

  test('ignores an OCR item row whose printed line total disagrees', () {
    final result = parseReceiptText('咖啡 2 100 180\n實付 180');

    expect(result.items, isEmpty);
  });
}
