import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:receipt_trail/src/app/receipt_trail_app.dart';
import 'package:receipt_trail/src/core/localization/app_locale_controller.dart';

import 'support/test_app_dependencies.dart';

void main() {
  testWidgets('welcome page requires login registration or explicit guest use',
      (tester) async {
    final bundle = createTestAppDependencies();
    await bundle.dependencies.sessionCoordinator.initialize();

    await tester.pumpWidget(
      ReceiptTrailApp(dependencies: bundle.dependencies),
    );
    await tester.pump();

    expect(find.text('歡迎使用 Receipt Trail'), findsOneWidget);
    expect(find.text('登入或註冊'), findsOneWidget);
    expect(find.text('以訪客身分使用'), findsOneWidget);
    expect(find.text('本月累積消費'), findsNothing);

    await tester.tap(find.text('以訪客身分使用'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('本月累積消費'), findsOneWidget);
    expect(find.text('你好，訪客'), findsOneWidget);
  });

  testWidgets('welcome page is fully available in English', (tester) async {
    final bundle = createTestAppDependencies(
      localeController: AppLocaleController(
        _LocaleStore(),
        initialOption: AppLocaleOption.english,
      ),
    );
    await bundle.dependencies.sessionCoordinator.initialize();

    await tester.pumpWidget(
      ReceiptTrailApp(dependencies: bundle.dependencies),
    );
    await tester.pump();

    expect(find.text('Welcome to Receipt Trail'), findsOneWidget);
    expect(find.text('Sign in or register'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.textContaining('Guest data stays only on this device'),
        findsOneWidget);
  });

  testWidgets('English auth form localizes validation and safe failures',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final bundle = createTestAppDependencies(
      localeController: AppLocaleController(
        _LocaleStore(),
        initialOption: AppLocaleOption.english,
      ),
    );
    await bundle.dependencies.sessionCoordinator.initialize();
    await tester.pumpWidget(ReceiptTrailApp(dependencies: bundle.dependencies));
    await tester.pump();

    await tester.tap(find.text('Sign in or register'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(
      find.widgetWithText(FilledButton, 'Sign in or register').last,
    );
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password must contain at least 8 characters'),
        findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Sign in or register').last,
    );
    await tester.pump();
    expect(
        find.textContaining('cloud service may be waking up'), findsOneWidget);
    expect(find.textContaining('登入服務未設定'), findsNothing);
  });
}

class _LocaleStore implements LocalePreferenceStore {
  @override
  Future<String?> readLocaleTag() async => null;

  @override
  Future<void> writeLocaleTag(String value) async {}
}
