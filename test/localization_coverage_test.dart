import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/l10n/generated/app_localizations_en.dart';

void main() {
  test('Chinese and English ARB files expose identical keys', () {
    final chinese = _arbKeys('lib/l10n/app_zh.arb');
    final english = _arbKeys('lib/l10n/app_en.arb');

    expect(
      chinese.difference(english),
      isEmpty,
      reason: 'Keys missing from English ARB',
    );
    expect(
      english.difference(chinese),
      isEmpty,
      reason: 'Keys missing from Chinese ARB',
    );
  });

  test('presentation Dart files contain no unlocalized CJK literals', () {
    const presentationFiles = <String>[
      'lib/src/app/app_shell.dart',
      'lib/src/features/session/welcome_screen.dart',
      'lib/src/features/session/session_coordinator.dart',
      'lib/src/features/auth/account_screen.dart',
      'lib/src/features/purchases/home_screen.dart',
      'lib/src/features/purchases/records_screen.dart',
      'lib/src/features/scanning/scan_screen.dart',
      'lib/src/features/map/map_screen.dart',
      'lib/src/features/sync/http_receipt_cloud_gateway.dart',
    ];
    final cjk = RegExp(r'[\u3400-\u9fff]');
    final failures = <String>[];

    for (final path in presentationFiles) {
      final lines = File(path).readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (cjk.hasMatch(lines[index])) {
          failures.add('$path:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Move fixed presentation copy into the ARB files.',
    );
  });

  test('English count labels use correct singular and plural forms', () {
    final localizations = AppLocalizationsEn();

    expect(localizations.receiptCountUnit(1), '1 receipt');
    expect(localizations.receiptCountUnit(2), '2 receipts');
    expect(localizations.placeCountUnit(1), '1 place');
    expect(localizations.placeCountUnit(2), '2 places');
    expect(
      localizations.localDataSummary(1, 1),
      '1 receipt · 1 merchant · permanently saved',
    );
  });
}

Set<String> _arbKeys(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json.keys
      .where((key) => key != '@@locale' && !key.startsWith('@'))
      .toSet();
}
