import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/purchases/data/receipt_trail_database.dart';

void main() {
  late ReceiptTrailDatabase database;

  setUp(() {
    database = ReceiptTrailDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('creates every table needed for purchases and reliable sync', () async {
    final rows = await database.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
      readsFrom: const {},
    ).get();

    final names = rows.map((row) => row.read<String>('name')).toSet();

    expect(
      names,
      containsAll(<String>{
        'purchase_records',
        'uniform_invoices',
        'purchase_places',
        'receipt_items',
        'sync_outbox',
        'app_metadata',
      }),
    );
  });

  test('deleting a purchase cascades to its invoice place and items', () async {
    await _insertPurchase(database);
    await database.customStatement(
      'INSERT INTO uniform_invoices '
      '(purchase_id, receipt_number) VALUES (?, ?)',
      <Object?>['receipt-1', 'AB12345678'],
    );
    await database.customStatement(
      'INSERT INTO purchase_places (purchase_id, address) VALUES (?, ?)',
      <Object?>['receipt-1', '台北市測試路 1 號'],
    );
    await database.customStatement(
      'INSERT INTO receipt_items '
      '(purchase_id, name, quantity, price, line_index) '
      'VALUES (?, ?, ?, ?, ?)',
      <Object?>['receipt-1', '咖啡', 1, 80, 0],
    );

    await database.customStatement(
      'DELETE FROM purchase_records WHERE id = ?',
      <Object?>['receipt-1'],
    );

    for (final table in <String>[
      'uniform_invoices',
      'purchase_places',
      'receipt_items',
    ]) {
      final count = await database
          .customSelect('SELECT COUNT(*) AS count FROM $table')
          .getSingle();
      expect(count.read<int>('count'), 0, reason: '$table should cascade');
    }
  });

  test('metadata keys are unique and can be updated without adding rows',
      () async {
    await database.customStatement(
      'INSERT INTO app_metadata (key, value) VALUES (?, ?)',
      <Object?>['legacy_migration_version', '0'],
    );
    await database.customStatement(
      'INSERT INTO app_metadata (key, value) VALUES (?, ?) '
      'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
      <Object?>['legacy_migration_version', '1'],
    );

    final row = await database.customSelect(
      'SELECT COUNT(*) AS count, MAX(value) AS value '
      'FROM app_metadata WHERE key = ?',
      variables: <Variable<Object>>[
        const Variable<String>('legacy_migration_version'),
      ],
    ).getSingle();

    expect(row.read<int>('count'), 1);
    expect(row.read<String>('value'), '1');
  });

  test('schema v1 upgrades without losing an existing public receipt id',
      () async {
    await database.close();
    final executor = NativeDatabase.memory(
      setup: (sqlite) {
        sqlite
          ..execute('''
            CREATE TABLE purchase_records (
              id TEXT NOT NULL PRIMARY KEY,
              owner_type TEXT NOT NULL,
              owner_id INTEGER NULL,
              store_name TEXT NOT NULL,
              purchase_date INTEGER NOT NULL,
              total INTEGER NOT NULL,
              category TEXT NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL,
              raw_text TEXT NULL
            )
          ''')
          ..execute('''
            INSERT INTO purchase_records (
              id, owner_type, owner_id, store_name, purchase_date, total,
              category, updated_at
            ) VALUES ('legacy-id', 'guest', NULL, '舊商店', 0, 80, 'food', 0)
          ''')
          ..execute('''
            CREATE TABLE uniform_invoices (
              purchase_id TEXT NOT NULL PRIMARY KEY,
              receipt_number TEXT NOT NULL,
              period TEXT NULL,
              prize_status TEXT NULL
            )
          ''')
          ..execute('PRAGMA user_version = 1');
      },
    );
    database = ReceiptTrailDatabase.forTesting(executor);

    final row = await database.customSelect(
      'SELECT id, receipt_id FROM purchase_records WHERE id = ?',
      variables: const <Variable<Object>>[
        Variable<String>('legacy-id'),
      ],
    ).getSingle();

    expect(row.read<String>('id'), 'legacy-id');
    expect(row.read<String>('receipt_id'), 'legacy-id');
  });

  test('schema v2 adds invoice amounts without losing existing rows', () async {
    await database.close();
    final purchasedAt =
        DateTime.utc(2026, 10, 13, 8, 30).millisecondsSinceEpoch ~/ 1000;
    final executor = NativeDatabase.memory(
      setup: (sqlite) {
        sqlite
          ..execute('''
            CREATE TABLE purchase_records (
              id TEXT NOT NULL PRIMARY KEY,
              receipt_id TEXT NULL,
              owner_type TEXT NOT NULL,
              owner_id INTEGER NULL,
              store_name TEXT NOT NULL,
              purchase_date INTEGER NOT NULL,
              total INTEGER NOT NULL,
              category TEXT NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL,
              raw_text TEXT NULL
            )
          ''')
          ..execute('''
            CREATE TABLE uniform_invoices (
              purchase_id TEXT NOT NULL PRIMARY KEY,
              receipt_number TEXT NOT NULL,
              period TEXT NULL,
              prize_status TEXT NULL
            )
          ''')
          ..execute('''
            INSERT INTO purchase_records (
              id, receipt_id, owner_type, owner_id, store_name, purchase_date,
              total, category, updated_at
            ) VALUES ('guest:legacy', 'legacy', 'guest', NULL, '舊商店',
              $purchasedAt, 208, 'food', $purchasedAt)
          ''')
          ..execute('''
            INSERT INTO uniform_invoices (
              purchase_id, receipt_number, period, prize_status
            ) VALUES ('guest:legacy', 'AB12345678', NULL, NULL)
          ''')
          ..execute('PRAGMA user_version = 2');
      },
    );
    database = ReceiptTrailDatabase.forTesting(executor);

    final purchase = await database
        .customSelect(
          'SELECT total, subtotal, discount FROM purchase_records '
          "WHERE id = 'guest:legacy'",
        )
        .getSingle();
    final invoice = await database
        .customSelect(
          'SELECT receipt_number, period, seller_tax_id FROM uniform_invoices '
          "WHERE purchase_id = 'guest:legacy'",
        )
        .getSingle();

    expect(purchase.read<int>('total'), 208);
    expect(purchase.read<int>('subtotal'), 208);
    expect(purchase.read<int>('discount'), 0);
    expect(invoice.read<String>('receipt_number'), 'AB12345678');
    expect(invoice.read<String>('period'), '11510');
    expect(invoice.data['seller_tax_id'], equals(null));
  });

  test('schema v2 migration rolls back every column when a later step fails',
      () async {
    await database.close();
    dynamic rawDatabase;
    final executor = NativeDatabase.memory(
      setup: (sqlite) {
        rawDatabase = sqlite;
        sqlite
          ..execute('''
            CREATE TABLE purchase_records (
              id TEXT NOT NULL PRIMARY KEY,
              total INTEGER NOT NULL
            )
          ''')
          ..execute('''
            CREATE TABLE uniform_invoices (
              purchase_id TEXT NOT NULL PRIMARY KEY,
              receipt_number TEXT NOT NULL,
              period TEXT NULL,
              prize_status TEXT NULL
            )
          ''')
          ..execute('PRAGMA user_version = 2');
      },
    );
    database = ReceiptTrailDatabase.forTesting(executor);

    await expectLater(
      database.customSelect('SELECT 1').get(),
      throwsA(anything),
    );
    final columns = (rawDatabase.select('PRAGMA table_info(purchase_records)')
            as Iterable<dynamic>)
        .map((row) => row['name'])
        .toSet();

    expect(columns, isNot(contains('subtotal')));
    expect(columns, isNot(contains('discount')));
  });

  test('schema v2 migration resumes safely after a partial prior upgrade',
      () async {
    await database.close();
    final purchasedAt =
        DateTime.utc(2026, 10, 13, 8, 30).millisecondsSinceEpoch ~/ 1000;
    final executor = NativeDatabase.memory(
      setup: (sqlite) {
        sqlite
          ..execute('''
            CREATE TABLE purchase_records (
              id TEXT NOT NULL PRIMARY KEY,
              receipt_id TEXT NULL,
              owner_type TEXT NOT NULL,
              owner_id INTEGER NULL,
              store_name TEXT NOT NULL,
              purchase_date INTEGER NOT NULL,
              total INTEGER NOT NULL,
              subtotal INTEGER NULL,
              category TEXT NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL,
              raw_text TEXT NULL
            )
          ''')
          ..execute('''
            CREATE TABLE uniform_invoices (
              purchase_id TEXT NOT NULL PRIMARY KEY,
              receipt_number TEXT NOT NULL,
              period TEXT NULL,
              prize_status TEXT NULL
            )
          ''')
          ..execute('''
            INSERT INTO purchase_records (
              id, receipt_id, owner_type, owner_id, store_name, purchase_date,
              total, subtotal, category, updated_at
            ) VALUES ('guest:partial', 'partial', 'guest', NULL, '保留商店',
              $purchasedAt, 208, 208, 'food', $purchasedAt)
          ''')
          ..execute('''
            INSERT INTO uniform_invoices (
              purchase_id, receipt_number, period, prize_status
            ) VALUES ('guest:partial', 'AB12345678', NULL, NULL)
          ''')
          ..execute('PRAGMA user_version = 2');
      },
    );
    database = ReceiptTrailDatabase.forTesting(executor);

    final purchase = await database
        .customSelect(
          "SELECT subtotal, discount FROM purchase_records WHERE id = 'guest:partial'",
        )
        .getSingle();
    final invoice = await database
        .customSelect(
          "SELECT seller_tax_id FROM uniform_invoices WHERE purchase_id = 'guest:partial'",
        )
        .getSingle();

    expect(purchase.read<int>('subtotal'), 208);
    expect(purchase.read<int>('discount'), 0);
    expect(invoice.data['seller_tax_id'], equals(null));
  });
}

Future<void> _insertPurchase(ReceiptTrailDatabase database) {
  return database.customStatement(
    'INSERT INTO purchase_records '
    '(id, owner_type, owner_id, store_name, purchase_date, total, category, '
    'updated_at, deleted_at, raw_text) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      'receipt-1',
      'guest',
      null,
      '測試商店',
      DateTime.utc(2026, 10, 13).millisecondsSinceEpoch ~/ 1000,
      80,
      'food',
      DateTime.utc(2026, 10, 13).millisecondsSinceEpoch ~/ 1000,
      null,
      null,
    ],
  );
}
