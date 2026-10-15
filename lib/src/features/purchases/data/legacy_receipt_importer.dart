import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../purchase_models.dart';

const legacyReceiptStorageKey = 'receipt_trail.receipts.v1';

abstract interface class LegacyReceiptStore {
  Future<String?> readLegacyJson();
  Future<void> clearLegacyJson();
}

abstract interface class LegacyImportTarget {
  Future<LegacyImportResult> importGuestReceiptsOnce(List<Receipt> receipts);
}

class LegacyImportResult {
  const LegacyImportResult({
    required this.importedCount,
    required this.wasAlreadyComplete,
  });

  final int importedCount;
  final bool wasAlreadyComplete;
}

class LegacyMigrationFailure implements Exception {
  const LegacyMigrationFailure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'LegacyMigrationFailure: $message';
}

class SharedPreferencesLegacyReceiptStore implements LegacyReceiptStore {
  const SharedPreferencesLegacyReceiptStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<String?> readLegacyJson() async =>
      _preferences.getString(legacyReceiptStorageKey);

  @override
  Future<void> clearLegacyJson() async {
    final removed = await _preferences.remove(legacyReceiptStorageKey);
    if (!removed && _preferences.containsKey(legacyReceiptStorageKey)) {
      throw StateError('Unable to clear legacy receipt storage.');
    }
  }
}

abstract interface class LegacyMigration {
  Future<LegacyImportResult> importIfNeeded();
}

class LegacyReceiptImporter implements LegacyMigration {
  const LegacyReceiptImporter(this._store, this._target);

  final LegacyReceiptStore _store;
  final LegacyImportTarget _target;

  @override
  Future<LegacyImportResult> importIfNeeded() async {
    final encoded = await _store.readLegacyJson();
    if (encoded == null) {
      return _target.importGuestReceiptsOnce(const <Receipt>[]);
    }

    final receipts = _decode(encoded);
    final result = await _target.importGuestReceiptsOnce(receipts);
    await _store.clearLegacyJson();
    return result;
  }

  List<Receipt> _decode(String encoded) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Legacy receipt root must be a list.');
      }
      final receipts = decoded
          .map(
            (value) => Receipt.fromJson(
              Map<String, dynamic>.from(value as Map<dynamic, dynamic>),
            ),
          )
          .toList(growable: false);
      if (receipts.map((receipt) => receipt.id).toSet().length !=
          receipts.length) {
        throw const FormatException('Legacy receipt IDs must be unique.');
      }
      return receipts;
    } catch (error) {
      throw LegacyMigrationFailure('舊消費資料格式損壞，資料尚未刪除。', error);
    }
  }
}
