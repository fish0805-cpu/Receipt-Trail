import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/data/receipt_trail_database.dart';
import 'package:receipt_trail/src/features/session/drift_session_preference_store.dart';

void main() {
  test('guest choice persists in app metadata until it is cleared', () async {
    final database = ReceiptTrailDatabase.forTesting(NativeDatabase.memory());
    final store = DriftSessionPreferenceStore(database);

    expect(await store.isGuestSelected(), isFalse);
    await store.selectGuest();
    expect(
        await DriftSessionPreferenceStore(database).isGuestSelected(), isTrue);

    await store.clearGuestSelection();
    expect(await store.isGuestSelected(), isFalse);
    await database.close();
  });
}
