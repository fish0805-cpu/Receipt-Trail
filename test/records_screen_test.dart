import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/l10n/generated/app_localizations.dart';
import 'package:receipt_trail/src/features/map/navigation_gateway.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/records_screen.dart';
import 'package:receipt_trail/src/features/prizes/prize_models.dart';
import 'package:receipt_trail/src/features/prizes/prize_number_repository.dart';

void main() {
  testWidgets('records are grouped and totaled by their actual month',
      (tester) async {
    final october = Receipt(
      id: 'october',
      storeName: '十月商店',
      address: '台北市',
      date: DateTime(2026, 10, 12),
      total: 500,
      category: SpendingCategory.shopping,
      items: const [],
      receiptNumber: 'AA12345678',
    );
    final august = Receipt(
      id: 'august',
      storeName: '八月商店',
      address: '台北市',
      date: DateTime(2026, 8, 8),
      total: 600,
      category: SpendingCategory.food,
      items: const [],
      receiptNumber: 'BB12345678',
    );

    await tester.pumpWidget(_localizedApp(
      home: Scaffold(
        body: RecordsScreen(
          receipts: [october, august],
          onOpenMap: () {},
          onDeleteReceipt: (_) {},
          navigation: _NavigationStub(),
        ),
      ),
    ));

    expect(find.text('2026 年 10 月'), findsOneWidget);
    expect(find.text('2026 年 8 月'), findsOneWidget);
    expect(find.text('NT\$500'), findsNWidgets(2));
    expect(find.text('NT\$600'), findsNWidgets(2));
    expect(find.text('NT\$1,100'), findsNothing);
  });

  testWidgets('receipt detail clearly labels prize status and record fields',
      (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        home: Scaffold(
          body: RecordsScreen(
            receipts: [_receipt],
            onOpenMap: () {},
            onDeleteReceipt: (_) {},
            navigation: _NavigationStub(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('綠日咖啡'));
    await tester.pumpAndSettle();

    expect(find.text('發票詳細紀錄'), findsOneWidget);
    expect(find.text('尚未取得對獎資料'), findsOneWidget);
    expect(find.text('消費明細'), findsOneWidget);
    expect(find.text('折扣'), findsNothing);
  });

  testWidgets('receipt detail shows period seller and amount breakdown',
      (tester) async {
    final detailed = Receipt(
      id: 'detailed',
      storeName: '金額商店',
      address: '台北市',
      date: DateTime(2026, 10, 13),
      subtotal: 250,
      discount: 50,
      total: 200,
      sellerTaxId: '12345678',
      category: SpendingCategory.shopping,
      items: const [ReceiptItem(name: '商品', price: 250)],
      receiptNumber: 'CD12345678',
    );
    await tester.pumpWidget(_localizedApp(
      home: Scaffold(
        body: RecordsScreen(
          receipts: [detailed],
          onOpenMap: () {},
          onDeleteReceipt: (_) {},
          navigation: _NavigationStub(),
        ),
      ),
    ));

    await tester.tap(find.text('金額商店'));
    await tester.pumpAndSettle();

    expect(find.text('115 年 9–10 月'), findsOneWidget);
    expect(find.text('賣方統編'), findsOneWidget);
    expect(find.text('12345678'), findsOneWidget);
    expect(find.text('商品小計'), findsOneWidget);
    expect(find.text('折扣'), findsOneWidget);
    expect(find.text('實付金額'), findsOneWidget);
  });

  testWidgets('receipt detail shows verified claimable prize and disclaimer',
      (tester) async {
    final winning = Receipt(
      id: 'winning',
      storeName: '中獎商店',
      address: '台北市',
      date: DateTime(2026, 10, 13),
      total: 200,
      category: SpendingCategory.shopping,
      items: const [],
      receiptNumber: 'CD12345678',
    );
    await tester.pumpWidget(_localizedApp(
      home: Scaffold(
        body: RecordsScreen(
          receipts: [winning],
          onOpenMap: () {},
          onDeleteReceipt: (_) {},
          navigation: _NavigationStub(),
          prizeNumbers: _PrizeSource(_prizeSnapshot),
          clock: () => DateTime(2026, 12, 20),
        ),
      ),
    ));

    await tester.tap(find.text('中獎商店'));
    await tester.pumpAndSettle();

    expect(find.text('恭喜中獎 · 頭獎'), findsOneWidget);
    expect(find.textContaining('獎金 NT\$ 200,000'), findsOneWidget);
    expect(find.textContaining('非財政部即時查詢，實際資格以財政部為準'), findsOneWidget);
    expect(find.textContaining('目前使用離線快取'), findsOneWidget);
    expect(find.textContaining('更新：2026/11/25'), findsOneWidget);
    expect(find.text('前往官方來源確認'), findsOneWidget);
  });

  testWidgets('English receipt UI preserves merchant and receipt data',
      (tester) async {
    await tester.pumpWidget(_localizedApp(
      locale: const Locale('en'),
      home: Scaffold(
        body: RecordsScreen(
          receipts: [_receipt],
          onOpenMap: () {},
          onDeleteReceipt: (_) {},
          navigation: _NavigationStub(),
        ),
      ),
    ));

    expect(find.text('Purchase records'), findsOneWidget);
    expect(find.text('綠日咖啡'), findsOneWidget);
    await tester.tap(find.text('綠日咖啡'));
    await tester.pumpAndSettle();
    expect(find.text('Receipt details'), findsOneWidget);
    expect(find.text('Purchase items'), findsOneWidget);
    expect(find.text('拿鐵'), findsOneWidget);
    expect(find.text('Awaiting official prize numbers'), findsOneWidget);
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

final _prizeSnapshot = PrizeNumberSnapshot(
  term: '11510',
  specialPrize: '11112222',
  grandPrize: '33334444',
  firstPrizes: const ['12345678'],
  additionalSixthPrizes: const ['999'],
  prizeAmounts: const {
    PrizeTier.special: 10000000,
    PrizeTier.grand: 2000000,
    PrizeTier.first: 200000,
    PrizeTier.second: 40000,
    PrizeTier.third: 10000,
    PrizeTier.fourth: 4000,
    PrizeTier.fifth: 1000,
    PrizeTier.sixth: 200,
    PrizeTier.additionalSixth: 200,
  },
  drawDate: DateTime(2026, 11, 25),
  claimStartDate: DateTime(2026, 12, 6),
  claimEndDate: DateTime(2027, 3, 5),
  sourceUrl: 'https://example.test/official',
  publishedAt: DateTime.utc(2026, 11, 25),
  updatedAt: DateTime.utc(2026, 11, 25),
  checksum: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
);

final _receipt = Receipt(
  id: 'receipt-1',
  storeName: '綠日咖啡',
  address: '台北市信義區',
  date: DateTime(2026, 5, 13, 10, 30),
  total: 120,
  category: SpendingCategory.food,
  items: const [ReceiptItem(name: '拿鐵', price: 120)],
  receiptNumber: 'AB12345678',
);

class _NavigationStub implements NavigationGateway {
  @override
  Future<bool> openAttribution(Uri uri) async => true;

  @override
  Future<bool> openDirections(StoreSummary store) async => true;

  @override
  Future<bool> openPlace(StoreSummary store) async => true;
}

class _PrizeSource implements PrizeNumberSource {
  const _PrizeSource(this.snapshot);
  final PrizeNumberSnapshot? snapshot;

  @override
  Future<PrizeNumberLookup> get(String term) async => PrizeNumberLookup(
        origin: PrizeNumberOrigin.cache,
        snapshot: snapshot,
        failureCode: PrizeNumberFailureCode.networkUnavailable,
      );
}
