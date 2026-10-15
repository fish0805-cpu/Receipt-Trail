import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:receipt_trail/l10n/generated/app_localizations.dart';
import 'package:receipt_trail/src/core/localization/app_locale_controller.dart';
import 'package:receipt_trail/src/features/auth/account_screen.dart';
import 'package:receipt_trail/src/features/auth/auth_controller.dart';
import 'package:receipt_trail/src/features/data_management/data_reset_service.dart';
import 'package:receipt_trail/src/features/data_management/export_share_gateway.dart';
import 'package:receipt_trail/src/features/purchases/data/legacy_receipt_importer.dart';
import 'package:receipt_trail/src/features/purchases/purchase_repository.dart';
import 'package:receipt_trail/src/features/session/session_coordinator.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('export defaults to excluding OCR text and clearly warns user',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    bool? includeOcr;
    await tester.pumpWidget(_app(
      onExport: (value) async {
        includeOcr = value;
        return ExportShareResult.completed;
      },
      onReset: (_) async {},
    ));

    await tester.scrollUntilVisible(find.text('匯出資料'), 300);
    await tester.tap(find.text('匯出資料'));
    await tester.pumpAndSettle();

    expect(find.textContaining('地址與經緯度等個人資料'), findsOneWidget);
    await tester.tap(find.text('匯出（不含 OCR）'));
    await tester.pumpAndSettle();
    expect(includeOcr, isFalse);
  });

  testWidgets('reset requires the exact confirmation phrase', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    DataResetTarget? target;
    await tester.pumpWidget(_app(
      onExport: (_) async => ExportShareResult.completed,
      onReset: (value) async => target = value,
    ));

    await tester.scrollUntilVisible(find.text('全部重置'), 300);
    await tester.tap(find.text('全部重置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('繼續'));
    await tester.pumpAndSettle();

    final destructiveButton = find.widgetWithText(FilledButton, '永久刪除');
    expect(tester.widget<FilledButton>(destructiveButton).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '刪除我的資料');
    await tester.pump();
    expect(tester.widget<FilledButton>(destructiveButton).onPressed, isNotNull);
    await tester.tap(destructiveButton);
    await tester.pumpAndSettle();
    expect(target, DataResetTarget.guestDevice);
  });

  testWidgets('account and export copy are available in English',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(
      locale: const Locale('en'),
      localeOption: AppLocaleOption.english,
      onExport: (_) async => ExportShareResult.completed,
      onReset: (_) async {},
    ));

    expect(find.text('My account'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Export data'), 300);
    await tester.tap(find.text('Export data'));
    await tester.pumpAndSettle();
    expect(find.textContaining('personal data'), findsOneWidget);
    expect(find.text('Export without OCR'), findsOneWidget);
  });
}

Widget _app({
  Locale locale = const Locale('zh', 'TW'),
  AppLocaleOption localeOption = AppLocaleOption.traditionalChinese,
  required Future<ExportShareResult> Function(bool includeOcrText) onExport,
  required Future<void> Function(DataResetTarget target) onReset,
}) {
  final auth = AuthController.guest();
  final repository = MemoryPurchaseRepository();
  final coordinator = SessionCoordinator(
    authController: auth,
    purchases: repository,
    migration: const _Migration(),
    preferences: MemorySessionPreferenceStore(),
  );
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: AccountScreen(
        localeController: AppLocaleController(
          _LocaleStore(),
          initialOption: localeOption,
        ),
        sessionCoordinator: coordinator,
        receiptCount: 1,
        storeCount: 1,
        waitingForSyncCount: 0,
        isSyncing: false,
        syncFailureCode: null,
        syncedUploadCount: null,
        hasCompletedSync: false,
        onSync: () async {},
        onExport: onExport,
        onReset: onReset,
      ),
    ),
  );
}

class _LocaleStore implements LocalePreferenceStore {
  @override
  Future<String?> readLocaleTag() async => null;

  @override
  Future<void> writeLocaleTag(String value) async {}
}

class _Migration implements LegacyMigration {
  const _Migration();

  @override
  Future<LegacyImportResult> importIfNeeded() async =>
      const LegacyImportResult(importedCount: 0, wasAlreadyComplete: true);
}
