import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocaleOption {
  traditionalChinese('zh_TW', Locale('zh', 'TW')),
  english('en', Locale('en'));

  const AppLocaleOption(this.tag, this.locale);

  final String tag;
  final Locale locale;

  static AppLocaleOption fromStoredTag(String? tag) => switch (tag) {
        'en' => english,
        'zh_TW' => traditionalChinese,
        _ => traditionalChinese,
      };
}

abstract interface class LocalePreferenceStore {
  Future<String?> readLocaleTag();
  Future<void> writeLocaleTag(String value);
}

class SharedPreferencesLocalePreferenceStore implements LocalePreferenceStore {
  const SharedPreferencesLocalePreferenceStore(this._preferences);

  static const preferenceKey = 'receipt_trail.locale';
  final SharedPreferences _preferences;

  @override
  Future<String?> readLocaleTag() async =>
      _preferences.getString(preferenceKey);

  @override
  Future<void> writeLocaleTag(String value) async {
    final saved = await _preferences.setString(preferenceKey, value);
    if (!saved) throw StateError('Locale preference was not saved.');
  }
}

class AppLocaleController extends ChangeNotifier {
  AppLocaleController(
    this._store, {
    AppLocaleOption initialOption = AppLocaleOption.traditionalChinese,
  }) : _option = initialOption;

  final LocalePreferenceStore _store;
  AppLocaleOption _option;

  static Future<AppLocaleController> load(LocalePreferenceStore store) async {
    String? storedTag;
    try {
      storedTag = await store.readLocaleTag();
    } catch (_) {
      storedTag = null;
    }
    return AppLocaleController(
      store,
      initialOption: AppLocaleOption.fromStoredTag(storedTag),
    );
  }

  Locale get locale => _option.locale;
  AppLocaleOption get option => _option;

  Future<void> select(AppLocaleOption option) async {
    if (option == _option) return;
    await _store.writeLocaleTag(option.tag);
    _option = option;
    notifyListeners();
  }
}
