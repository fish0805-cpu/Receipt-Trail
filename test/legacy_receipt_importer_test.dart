import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/data/drift_purchase_repository.dart';
import 'package:receipt_trail/src/features/purchases/data/legacy_receipt_importer.dart';
import 'package:receipt_trail/src/features/purchases/data/receipt_trail_database.dart'
    as data;
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';

void main() {
  late data.ReceiptTrailDatabase database;
  late DriftPurchaseRepository repository;

  setUp(() {
    database = data.ReceiptTrailDatabase.forTesting(NativeDatabase.memory());
    repository = DriftPurchaseRepository(database);
  });

  tearDown(() => repository.close());

  test('imports complete legacy JSON before clearing the old value', () async {
    final store = _MemoryLegacyStore(jsonEncode(<Object>[
      _receipt('legacy-1').toJson(),
      _receipt('legacy-2').toJson(),
    ]));
    final importer = LegacyReceiptImporter(store, repository);

    final result = await importer.importIfNeeded();

    expect(result.importedCount, 2);
    expect(result.wasAlreadyComplete, isFalse);
    expect(store.value, isNull);
    final receipts = await repository.watchReceipts().first;
    expect(receipts.map((receipt) => receipt.id).toSet(), {
      'legacy-1',
      'legacy-2',
    });
    expect(receipts.first.items.single.name, '咖啡');
    final marker = await database
        .customSelect(
          "SELECT value FROM app_metadata "
          "WHERE key = 'legacy_receipts_migration_version'",
        )
        .getSingle();
    expect(marker.read<String>('value'), '1');
  });

  test('malformed legacy JSON leaves the old value and database untouched',
      () async {
    final store = _MemoryLegacyStore('[{"id":"truncated"');
    final importer = LegacyReceiptImporter(store, repository);

    await expectLater(
      importer.importIfNeeded(),
      throwsA(isA<LegacyMigrationFailure>()),
    );

    expect(store.value, isNotNull);
    expect(await repository.watchReceipts().first, isEmpty);
  });

  test('database failure rolls back every receipt and preserves old JSON',
      () async {
    final store = _MemoryLegacyStore(jsonEncode(<Object>[
      _receipt('legacy-1').toJson(),
      _receipt(
        'legacy-invalid',
        items: const <ReceiptItem>[
          ReceiptItem(name: '無效', quantity: 0, price: 10),
        ],
      ).toJson(),
    ]));
    final importer = LegacyReceiptImporter(store, repository);

    await expectLater(importer.importIfNeeded(), throwsA(anything));

    expect(store.value, isNotNull);
    expect(await repository.watchReceipts().first, isEmpty);
    final markerCount = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM app_metadata "
          "WHERE key = 'legacy_receipts_migration_version'",
        )
        .getSingle();
    expect(markerCount.read<int>('count'), 0);
  });

  test('restart after database commit only retries clearing legacy JSON',
      () async {
    final store = _MemoryLegacyStore(
      jsonEncode(<Object>[_receipt('legacy-1').toJson()]),
      failNextClear: true,
    );
    final importer = LegacyReceiptImporter(store, repository);

    await expectLater(importer.importIfNeeded(), throwsA(isA<StateError>()));
    expect(store.value, isNotNull);
    expect(await repository.watchReceipts().first, hasLength(1));

    final retried = await importer.importIfNeeded();

    expect(retried.wasAlreadyComplete, isTrue);
    expect(retried.importedCount, 0);
    expect(store.value, isNull);
    expect(await repository.watchReceipts().first, hasLength(1));
  });
}

class _MemoryLegacyStore implements LegacyReceiptStore {
  _MemoryLegacyStore(this.value, {this.failNextClear = false});

  String? value;
  bool failNextClear;

  @override
  Future<String?> readLegacyJson() async => value;

  @override
  Future<void> clearLegacyJson() async {
    if (failNextClear) {
      failNextClear = false;
      throw StateError('simulated stop between commit and clear');
    }
    value = null;
  }
}

Receipt _receipt(
  String id, {
  List<ReceiptItem> items = const <ReceiptItem>[
    ReceiptItem(name: '咖啡', price: 80),
  ],
}) =>
    Receipt(
      id: id,
      storeName: '舊資料商店',
      address: '台北市舊資料路 1 號',
      date: DateTime.utc(2026, 10, 1),
      total: 80,
      category: SpendingCategory.food,
      items: items,
      receiptNumber: 'AB12345678',
      isSynced: false,
      rawText: 'legacy OCR',
      latitude: 25.03,
      longitude: 121.56,
    );
