import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../invoice_period.dart';

part 'receipt_trail_database.g.dart';

class PurchaseRecords extends Table {
  /// Internal key. The public receipt ID can be identical in two owner scopes.
  TextColumn get id => text()();
  TextColumn get receiptId => text().nullable()();
  TextColumn get ownerType => text()();
  IntColumn get ownerId => integer().nullable()();
  TextColumn get storeName => text()();
  DateTimeColumn get purchaseDate => dateTime()();
  IntColumn get total => integer()();
  IntColumn get subtotal => integer().withDefault(const Constant<int>(0))();
  IntColumn get discount => integer().withDefault(const Constant<int>(0))();
  TextColumn get category => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get rawText => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
        "CHECK (owner_type IN ('guest', 'account'))",
        "CHECK ((owner_type = 'guest' AND owner_id IS NULL) OR "
            "(owner_type = 'account' AND owner_id IS NOT NULL))",
        'CHECK (total >= 0)',
      ];

  @override
  String get tableName => 'purchase_records';
}

class UniformInvoices extends Table {
  TextColumn get purchaseId => text().references(
        PurchaseRecords,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get receiptNumber => text()();
  TextColumn get period => text().nullable()();
  TextColumn get prizeStatus => text().nullable()();
  TextColumn get sellerTaxId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{purchaseId};

  @override
  String get tableName => 'uniform_invoices';
}

class PurchasePlaces extends Table {
  TextColumn get purchaseId => text().references(
        PurchaseRecords,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get address => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{purchaseId};

  @override
  String get tableName => 'purchase_places';
}

class ReceiptItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get purchaseId => text().references(
        PurchaseRecords,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant<int>(1))();
  IntColumn get price => integer()();
  IntColumn get lineIndex => integer()();

  @override
  List<String> get customConstraints => <String>[
        'CHECK (quantity > 0)',
        'CHECK (price >= 0)',
        'UNIQUE (purchase_id, line_index)',
      ];

  @override
  String get tableName => 'receipt_items';
}

class SyncOutbox extends Table {
  TextColumn get operationId => text()();
  TextColumn get purchaseId => text().references(
        PurchaseRecords,
        #id,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get userId => integer()();
  TextColumn get operation => text()();
  IntColumn get retryCount => integer().withDefault(const Constant<int>(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{operationId};

  @override
  List<String> get customConstraints => <String>[
        "CHECK (operation IN ('upsert', 'delete'))",
        'CHECK (retry_count >= 0)',
      ];

  @override
  String get tableName => 'sync_outbox';
}

class AppMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};

  @override
  String get tableName => 'app_metadata';
}

@DriftDatabase(
  tables: <Type>[
    PurchaseRecords,
    UniformInvoices,
    PurchasePlaces,
    ReceiptItems,
    SyncOutbox,
    AppMetadata,
  ],
)
class ReceiptTrailDatabase extends _$ReceiptTrailDatabase {
  ReceiptTrailDatabase()
      : super(driftDatabase(
            name: 'receipt_trail', native: const DriftNativeOptions()));

  ReceiptTrailDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          await transaction(() async {
            if (from < 2) {
              if (!await _hasColumn('purchase_records', 'receipt_id')) {
                await migrator.addColumn(
                  purchaseRecords,
                  purchaseRecords.receiptId,
                );
              }
              await customStatement(
                'UPDATE purchase_records SET receipt_id = id '
                'WHERE receipt_id IS NULL',
              );
            }
            if (from < 3) {
              if (!await _hasColumn('purchase_records', 'subtotal')) {
                await migrator.addColumn(
                  purchaseRecords,
                  purchaseRecords.subtotal,
                );
              }
              if (!await _hasColumn('purchase_records', 'discount')) {
                await migrator.addColumn(
                  purchaseRecords,
                  purchaseRecords.discount,
                );
              }
              if (!await _hasColumn('uniform_invoices', 'seller_tax_id')) {
                await migrator.addColumn(
                  uniformInvoices,
                  uniformInvoices.sellerTaxId,
                );
              }
              await customStatement(
                'UPDATE purchase_records SET subtotal = total, discount = 0',
              );
              final rows = await customSelect(
                'SELECT pr.id, pr.purchase_date '
                'FROM purchase_records pr '
                'INNER JOIN uniform_invoices ui ON ui.purchase_id = pr.id '
                'WHERE ui.period IS NULL',
              ).get();
              for (final row in rows) {
                final utcDate = DateTime.fromMillisecondsSinceEpoch(
                  row.read<int>('purchase_date') * 1000,
                  isUtc: true,
                );
                final period = InvoicePeriod.fromPurchaseDate(utcDate).rocTerm;
                await customStatement(
                  'UPDATE uniform_invoices SET period = ? WHERE purchase_id = ?',
                  <Object?>[period, row.read<String>('id')],
                );
              }
            }
          });
        },
        beforeOpen: (_) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((row) => row.read<String>('name') == column);
  }
}
