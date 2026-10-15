import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/l10n/generated/app_localizations.dart';
import 'package:receipt_trail/src/app/receipt_trail_app.dart';
import 'package:receipt_trail/src/core/localization/app_locale_controller.dart';
import 'package:receipt_trail/src/features/purchases/home_screen.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';

import 'support/test_app_dependencies.dart';

void main() {
  testWidgets('shows dashboard and primary navigation', (tester) async {
    final bundle = createTestAppDependencies();
    await bundle.dependencies.sessionCoordinator.initialize();
    await bundle.dependencies.sessionCoordinator.continueAsGuest();
    await tester.pumpWidget(
      ReceiptTrailApp(dependencies: bundle.dependencies),
    );
    await tester.pump();

    expect(find.text('你好，訪客'), findsOneWidget);
    expect(find.text('本月累積消費'), findsOneWidget);
    expect(find.text('NT\$0'), findsWidgets);
    expect(find.text('掃描發票'), findsOneWidget);
    expect(find.text('查看地圖'), findsOneWidget);
    expect(find.text('兌獎提醒'), findsOneWidget);
    expect(find.text('一般發票對獎已啟用'), findsOneWidget);
    expect(find.text('準備中'), findsNothing);
    expect(find.text('總覽'), findsOneWidget);
    expect(find.text('發票'), findsOneWidget);
    expect(find.text('掃描'), findsOneWidget);
    expect(find.text('地圖'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });

  testWidgets('home hero counts only the current month', (tester) async {
    final receipts = [
      _receipt('current', DateTime(2026, 10, 1), 100),
      _receipt('older', DateTime(2026, 9, 30), 900),
    ];

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('zh', 'TW'),
      supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomeScreen(
        receipts: receipts,
        onOpenRecords: () {},
        onOpenMap: () {},
        clock: () => DateTime(2026, 10, 14),
      ),
    ));

    expect(find.text('NT\$100'), findsWidgets);
    expect(find.text('NT\$1,000'), findsNothing);
    expect(find.text('2 張'), findsNothing);
    expect(find.text('綠日咖啡', skipOffstage: false), findsNWidgets(2));
  });

  testWidgets('primary navigation labels switch to English', (tester) async {
    final bundle = createTestAppDependencies(
      localeController: AppLocaleController(
        _LocaleStore(),
        initialOption: AppLocaleOption.english,
      ),
    );
    await bundle.dependencies.sessionCoordinator.initialize();
    await bundle.dependencies.sessionCoordinator.continueAsGuest();

    await tester.pumpWidget(ReceiptTrailApp(dependencies: bundle.dependencies));
    await tester.pump();

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Receipts'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
  });
}

class _LocaleStore implements LocalePreferenceStore {
  @override
  Future<String?> readLocaleTag() async => null;

  @override
  Future<void> writeLocaleTag(String value) async {}
}

Receipt _receipt(String id, DateTime date, int total) => Receipt(
      id: id,
      storeName: '綠日咖啡',
      address: '測試地址',
      date: date,
      total: total,
      category: SpendingCategory.food,
      items: [ReceiptItem(name: '品項', price: total)],
      receiptNumber: 'AB12345678',
    );
