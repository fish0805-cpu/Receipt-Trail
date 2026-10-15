import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/core/localization/app_locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('missing locale defaults to zh_TW even when platform locale is English',
      () async {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.localeTestValue = const Locale('en', 'US');
    addTearDown(binding.platformDispatcher.clearLocaleTestValue);

    final controller = await AppLocaleController.load(_MemoryLocaleStore());

    expect(controller.locale, const Locale('zh', 'TW'));
    expect(controller.option, AppLocaleOption.traditionalChinese);
  });

  test('stored en restores English', () async {
    final controller = await AppLocaleController.load(
      _MemoryLocaleStore(initialLocaleTag: 'en'),
    );

    expect(controller.locale, const Locale('en'));
    expect(controller.option, AppLocaleOption.english);
  });

  test('unsupported stored tag falls back to zh_TW', () async {
    final controller = await AppLocaleController.load(
      _MemoryLocaleStore(initialLocaleTag: 'ja'),
    );

    expect(controller.locale, const Locale('zh', 'TW'));
    expect(controller.option, AppLocaleOption.traditionalChinese);
  });

  test('select persists before notifying listeners', () async {
    final store = _MemoryLocaleStore();
    final controller = await AppLocaleController.load(store);
    String? valueSeenByListener;
    controller.addListener(() {
      valueSeenByListener = store.storedLocaleTag;
    });

    await controller.select(AppLocaleOption.english);

    expect(store.storedLocaleTag, 'en');
    expect(valueSeenByListener, 'en');
    expect(controller.locale, const Locale('en'));
  });

  test('failed persistence keeps the previous locale and does not notify',
      () async {
    final controller = await AppLocaleController.load(_FailingLocaleStore());
    var notifications = 0;
    controller.addListener(() => notifications += 1);

    await expectLater(
      controller.select(AppLocaleOption.english),
      throwsA(isA<StateError>()),
    );

    expect(controller.locale, const Locale('zh', 'TW'));
    expect(controller.option, AppLocaleOption.traditionalChinese);
    expect(notifications, 0);
  });
}

class _FailingLocaleStore implements LocalePreferenceStore {
  @override
  Future<String?> readLocaleTag() async => null;

  @override
  Future<void> writeLocaleTag(String value) async {
    throw StateError('write failed');
  }
}

class _MemoryLocaleStore implements LocalePreferenceStore {
  _MemoryLocaleStore({String? initialLocaleTag})
      : storedLocaleTag = initialLocaleTag;

  String? storedLocaleTag;

  @override
  Future<String?> readLocaleTag() async => storedLocaleTag;

  @override
  Future<void> writeLocaleTag(String value) async {
    storedLocaleTag = value;
  }
}
