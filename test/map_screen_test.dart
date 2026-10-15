import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/l10n/generated/app_localizations.dart';
import 'package:receipt_trail/src/core/theme/app_theme.dart';
import 'package:receipt_trail/src/features/map/map_screen.dart';
import 'package:receipt_trail/src/features/map/navigation_gateway.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';

void main() {
  testWidgets('selected store panel has a visible fixed height',
      (tester) async {
    await tester.pumpWidget(_localizedApp(
      theme: buildTheme(),
      home: Scaffold(
        body: StoreNavigationPanel(
          store: _store,
          onOpenRecords: () {},
          onClose: () {},
          navigation: _UnavailableNavigation(),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);

    expect(find.text('消費次數'), findsOneWidget);
    expect(find.text('Google 地圖'), findsOneWidget);
    expect(find.text('開始導航'), findsOneWidget);
    expect(tester.getSize(find.byType(StoreNavigationCard)).height, 330);
    expect(tester.widget<Card>(find.byType(Card)).elevation, 12);
  });

  testWidgets('failed external navigation shows a user-visible message',
      (tester) async {
    await tester.pumpWidget(_localizedApp(
      home: Scaffold(
        body: StoreNavigationCard(
          store: _store,
          onOpenRecords: () {},
          onClose: () {},
          navigation: _UnavailableNavigation(),
        ),
      ),
    ));

    await tester.tap(find.text('開始導航'));
    await tester.pump();

    expect(find.text('找不到可開啟的地圖 App'), findsOneWidget);
  });

  testWidgets('store panel is English while merchant data is unchanged',
      (tester) async {
    await tester.pumpWidget(_localizedApp(
      locale: const Locale('en'),
      home: Scaffold(
        body: StoreNavigationCard(
          store: _store,
          onOpenRecords: () {},
          onClose: () {},
          navigation: _UnavailableNavigation(),
        ),
      ),
    ));
    expect(find.text('Visits'), findsOneWidget);
    expect(find.text('Start navigation'), findsOneWidget);
    expect(find.text('綠日咖啡'), findsOneWidget);
  });
}

Widget _localizedApp({
  required Widget home,
  Locale locale = const Locale('zh', 'TW'),
  ThemeData? theme,
}) =>
    MaterialApp(
      locale: locale,
      theme: theme,
      supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );

final _store = StoreSummary(
  name: '綠日咖啡',
  address: '台北市信義區',
  visits: 1,
  total: 100,
  lastVisit: DateTime(2026, 10, 13),
  category: SpendingCategory.food,
  latitude: 25.03,
  longitude: 121.53,
);

class _UnavailableNavigation implements NavigationGateway {
  @override
  Future<bool> openAttribution(Uri uri) async => false;

  @override
  Future<bool> openDirections(StoreSummary store) async =>
      throw StateError('plugin unavailable');

  @override
  Future<bool> openPlace(StoreSummary store) async => false;
}
