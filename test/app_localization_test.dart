import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/app/receipt_trail_app.dart';
import 'package:receipt_trail/src/core/localization/app_locale_controller.dart';

import 'support/test_app_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app defaults to zh_TW on an English platform', (tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    final bundle = createTestAppDependencies();
    await bundle.dependencies.sessionCoordinator.initialize();

    await tester.pumpWidget(ReceiptTrailApp(dependencies: bundle.dependencies));
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('zh', 'TW'));
    expect(find.text('歡迎使用 Receipt Trail'), findsOneWidget);
  });

  testWidgets('stored English applies before the first rendered frame',
      (tester) async {
    final store = _MemoryLocaleStore(initialLocaleTag: 'en');
    final localeController = await AppLocaleController.load(store);
    final bundle = createTestAppDependencies(
      localeController: localeController,
    );
    await bundle.dependencies.sessionCoordinator.initialize();

    await tester.pumpWidget(ReceiptTrailApp(dependencies: bundle.dependencies));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('en'));
  });

  testWidgets('language picker shows both choices and marks current language',
      (tester) async {
    final bundle = createTestAppDependencies();
    await _pumpGuestApp(tester, bundle);
    await _openLanguagePicker(tester);

    expect(find.text('繁體中文'), findsWidgets);
    expect(find.text('English'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('choosing English updates and persists the app locale',
      (tester) async {
    final store = _MemoryLocaleStore();
    final localeController = await AppLocaleController.load(store);
    final bundle = createTestAppDependencies(
      localeController: localeController,
    );
    await _pumpGuestApp(tester, bundle);
    await _openLanguagePicker(tester);

    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(store.storedLocaleTag, 'en');
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('en'));
    expect(find.text('Language'), findsOneWidget);

    final restored = await AppLocaleController.load(store);
    expect(restored.locale, const Locale('en'));
  });

  testWidgets('failed write keeps Chinese and shows a localized error',
      (tester) async {
    final localeController = await AppLocaleController.load(
      _MemoryLocaleStore(failWrites: true),
    );
    final bundle = createTestAppDependencies(
      localeController: localeController,
    );
    await _pumpGuestApp(tester, bundle);
    await _openLanguagePicker(tester);

    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(localeController.locale, const Locale('zh', 'TW'));
    expect(find.text('無法儲存語言設定，請再試一次'), findsOneWidget);
  });
}

Future<void> _openLanguagePicker(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.person_outline_rounded));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.scrollUntilVisible(
    find.text('語言'),
    300,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.drag(
    find.byType(Scrollable).last,
    const Offset(0, -160),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('語言'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _pumpGuestApp(
  WidgetTester tester,
  TestAppDependencies bundle,
) async {
  await bundle.dependencies.sessionCoordinator.initialize();
  await bundle.dependencies.sessionCoordinator.continueAsGuest();
  await tester.pumpWidget(ReceiptTrailApp(dependencies: bundle.dependencies));
  await tester.pump(const Duration(milliseconds: 500));
}

class _MemoryLocaleStore implements LocalePreferenceStore {
  _MemoryLocaleStore({this.initialLocaleTag, this.failWrites = false})
      : storedLocaleTag = initialLocaleTag;

  final String? initialLocaleTag;
  final bool failWrites;
  String? storedLocaleTag;

  @override
  Future<String?> readLocaleTag() async => storedLocaleTag;

  @override
  Future<void> writeLocaleTag(String value) async {
    if (failWrites) throw StateError('write failed');
    storedLocaleTag = value;
  }
}
