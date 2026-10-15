import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/l10n/generated/app_localizations.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/scanning/receipt_scan_models.dart';
import 'package:receipt_trail/src/features/scanning/receipt_scanner.dart';
import 'package:receipt_trail/src/features/scanning/scan_screen.dart';

import 'support/test_app_dependencies.dart';

void main() {
  testWidgets('scan entry presents the iOS-style guided choices',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _localizedApp(
        home: ScanScreen(
          scanner: TestReceiptScanner(),
          onSaveReceipt: (_) async {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('步驟 1 / 3'), findsOneWidget);
    expect(find.text('掃描你的發票'), findsOneWidget);
    expect(find.text('電子發票'), findsOneWidget);
    expect(find.text('傳統發票'), findsOneWidget);
    expect(find.text('改用手動輸入'), findsOneWidget);
  });

  testWidgets(
      'failed local save stays editable and retry shows success after write',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var attempts = 0;
    final saved = <Receipt>[];
    await tester.pumpWidget(_localizedApp(
      home: ScanScreen(
        scanner: TestReceiptScanner(),
        onSaveReceipt: (receipt) async {
          attempts++;
          if (attempts == 1) throw StateError('disk unavailable');
          saved.add(receipt);
        },
      ),
    ));

    await tester.tap(find.text('改用手動輸入'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, '店家名稱 *'), '測試商店');
    await tester.enterText(find.widgetWithText(TextFormField, '總金額 *'), '100');
    await tester.ensureVisible(find.text('確認並儲存'));
    await tester.tap(find.text('確認並儲存'));
    await tester.pumpAndSettle();

    expect(find.text('發票已加入'), findsNothing);
    expect(find.text('測試商店'), findsOneWidget);
    expect(saved, isEmpty);

    await tester.tap(find.text('確認並儲存'));
    await tester.pumpAndSettle();

    expect(saved, hasLength(1));
    expect(saved.single.storeName, '測試商店');
    expect(find.text('發票已加入'), findsOneWidget);
  });

  testWidgets('reviewed seller amounts and item rows are saved as entered',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Receipt? saved;
    await tester.pumpWidget(_localizedApp(
      home: ScanScreen(
        scanner: TestReceiptScanner(),
        onSaveReceipt: (receipt) async => saved = receipt,
      ),
    ));
    await tester.tap(find.text('改用手動輸入'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, '店家名稱 *'), '測試商店');
    await tester.enterText(find.widgetWithText(TextFormField, '總金額 *'), '220');
    await tester.enterText(
        find.widgetWithText(TextFormField, '賣方統編'), '12345678');
    await tester.enterText(find.widgetWithText(TextFormField, '商品小計'), '250');
    await tester.enterText(find.widgetWithText(TextFormField, '折扣'), '30');
    await tester.ensureVisible(find.text('新增品項'));
    await tester.tap(find.text('新增品項'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '品名'), '咖啡');
    await tester.enterText(find.widgetWithText(TextFormField, '數量'), '2');
    await tester.enterText(find.widgetWithText(TextFormField, '單價'), '125');
    await tester.scrollUntilVisible(
      find.text('確認並儲存'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('確認並儲存'));
    await tester.pumpAndSettle();

    expect(saved?.sellerTaxId, '12345678');
    expect(saved?.subtotal, 250);
    expect(saved?.discount, 30);
    expect(saved?.total, 220);
    expect(saved?.items, hasLength(1));
    expect(saved?.items.single.name, '咖啡');
    expect(saved?.items.single.quantity, 2);
    expect(saved?.items.single.price, 125);
  });

  testWidgets('saved merchant is offered but not applied until selected',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final known = Receipt(
      id: 'known',
      storeName: '已確認店家',
      address: '台北市民生路 8 號',
      date: DateTime(2026, 10, 1),
      total: 100,
      category: SpendingCategory.food,
      items: const [],
      receiptNumber: '',
      sellerTaxId: '12345678',
    );
    await tester.pumpWidget(_localizedApp(
      home: ScanScreen(
        scanner: _DraftScanner(),
        existingReceipts: [known],
        onSaveReceipt: (_) async {},
      ),
    ));

    await tester.tap(find.text('拍攝傳統發票'));
    await tester.pumpAndSettle();
    expect(find.text('可能是已儲存的店家'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '店家名稱 *'), findsOneWidget);
    expect(find.text('掃描店名'), findsOneWidget);
    await tester.ensureVisible(find.text('已確認店家'));
    await tester.tap(find.text('已確認店家'));
    await tester.pumpAndSettle();

    expect(find.text('掃描店名'), findsNothing);
    expect(find.text('台北市民生路 8 號'), findsOneWidget);
  });

  testWidgets('future OCR date does not crash the date picker', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_localizedApp(
      home: ScanScreen(
        scanner: _FutureDateScanner(),
        onSaveReceipt: (_) async {},
      ),
    ));

    await tester.tap(find.text('拍攝傳統發票'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('消費日期 2100/1/1'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('English scan UI preserves recognized merchant data',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_localizedApp(
      locale: const Locale('en'),
      home: ScanScreen(
        scanner: _DraftScanner(),
        onSaveReceipt: (_) async {},
      ),
    ));
    expect(find.text('Step 1 of 3'), findsOneWidget);
    await tester.tap(find.text('Photograph traditional receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Enter receipt details'), findsOneWidget);
    expect(find.text('掃描店名'), findsOneWidget);
  });
}

Widget _localizedApp({
  required Widget home,
  Locale locale = const Locale('zh', 'TW'),
}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );

class _DraftScanner extends TestReceiptScanner {
  @override
  Future<ReceiptScanDraft?> capture(ScanSource source) async =>
      const ReceiptScanDraft(
        storeName: '掃描店名',
        sellerTaxId: '12345678',
        total: 100,
      );
}

class _FutureDateScanner extends TestReceiptScanner {
  @override
  Future<ReceiptScanDraft?> capture(ScanSource source) async =>
      ReceiptScanDraft(date: DateTime(2100, 1, 1), total: 100);
}
