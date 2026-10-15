import '../purchases/data/receipt_trail_database.dart';
import 'session_coordinator.dart';

class DriftSessionPreferenceStore implements SessionPreferenceStore {
  const DriftSessionPreferenceStore(this._database);

  static const _key = 'guest_mode_selected';
  final ReceiptTrailDatabase _database;

  @override
  Future<bool> isGuestSelected() async {
    final row = await (_database.select(_database.appMetadata)
          ..where((table) => table.key.equals(_key)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  @override
  Future<void> selectGuest() =>
      _database.into(_database.appMetadata).insertOnConflictUpdate(
            AppMetadataCompanion.insert(key: _key, value: 'true'),
          );

  @override
  Future<void> clearGuestSelection() => (_database.delete(_database.appMetadata)
        ..where((table) => table.key.equals(_key)))
      .go();
}
