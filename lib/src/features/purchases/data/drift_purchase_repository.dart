import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';

import '../purchase_models.dart';
import '../purchase_repository.dart';
import '../purchase_scope.dart';
import 'legacy_receipt_importer.dart';
import 'receipt_trail_database.dart' as db;

class DriftPurchaseRepository
    implements PurchaseRepository, LegacyImportTarget {
  DriftPurchaseRepository(this._database);

  final db.ReceiptTrailDatabase _database;
  final StreamController<List<Receipt>> _changes =
      StreamController<List<Receipt>>.broadcast();
  PurchaseScope _scope = const PurchaseScope.guest();
  bool _closed = false;

  @override
  Stream<List<Receipt>> watchReceipts() async* {
    yield await _loadVisibleReceipts();
    yield* _changes.stream;
  }

  @override
  Future<void> setScope(PurchaseScope scope) async {
    _scope = scope;
    await _emit();
  }

  @override
  Future<void> saveReceipt(Receipt receipt) async {
    final scope = _scope;
    await _database.transaction(() async {
      await _writeReceipt(receipt, scope: scope, queueOperation: true);
    });
    await _emit();
  }

  @override
  Future<LegacyImportResult> importGuestReceiptsOnce(
    List<Receipt> receipts,
  ) async {
    final result = await _database.transaction(() async {
      final marker = await (_database.select(_database.appMetadata)
            ..where(
              (table) => table.key.equals('legacy_receipts_migration_version'),
            ))
          .getSingleOrNull();
      if (marker?.value == '1') {
        return const LegacyImportResult(
          importedCount: 0,
          wasAlreadyComplete: true,
        );
      }

      for (final receipt in receipts) {
        await _writeReceipt(
          receipt,
          scope: const PurchaseScope.guest(),
          queueOperation: false,
        );
      }

      if (receipts.isNotEmpty) {
        final ids = receipts.map((receipt) => receipt.id).toList();
        final countExpression = _database.purchaseRecords.id.count();
        final countQuery = _database.selectOnly(_database.purchaseRecords)
          ..addColumns(<Expression<Object>>[countExpression])
          ..where(
            _database.purchaseRecords.ownerType.equals('guest') &
                _database.purchaseRecords.receiptId.isIn(ids),
          );
        final importedCount =
            (await countQuery.getSingle()).read(countExpression) ?? 0;
        if (importedCount != receipts.length) {
          throw StateError('Legacy receipt count verification failed.');
        }
      }

      await _database.into(_database.appMetadata).insertOnConflictUpdate(
            db.AppMetadataCompanion.insert(
              key: 'legacy_receipts_migration_version',
              value: '1',
            ),
          );
      return LegacyImportResult(
        importedCount: receipts.length,
        wasAlreadyComplete: false,
      );
    });
    await _emit();
    return result;
  }

  @override
  Future<void> deleteReceipt(String id) async {
    final scope = _scope;
    await _database.transaction(() async {
      final record = await _findRecord(scope, id);
      if (record == null) return;
      final storageKey = record.id;

      if (scope is GuestPurchaseScope) {
        await (_database.delete(_database.purchaseRecords)
              ..where((table) => table.id.equals(storageKey)))
            .go();
        return;
      }

      final userId = (scope as AccountPurchaseScope).userId;
      await (_database.update(_database.purchaseRecords)
            ..where((table) => table.id.equals(storageKey)))
          .write(
        db.PurchaseRecordsCompanion(
          deletedAt: Value<DateTime?>(DateTime.now().toUtc()),
          updatedAt: Value<DateTime>(DateTime.now().toUtc()),
        ),
      );
      await _replaceOperation(
        storageKey: storageKey,
        userId: userId,
        kind: SyncOperationKind.delete,
      );
    });
    await _emit();
  }

  @override
  Future<void> clearLocalScope(PurchaseScope scope) async {
    await _database.transaction(() async {
      await (_database.delete(_database.purchaseRecords)
            ..where((table) => switch (scope) {
                  GuestPurchaseScope() => table.ownerType.equals('guest'),
                  AccountPurchaseScope(:final userId) =>
                    table.ownerType.equals('account') &
                        table.ownerId.equals(userId),
                }))
          .go();
    });
    if (_scope == scope) await _emit();
  }

  @override
  Future<int> claimGuestReceipts(int userId) async {
    final claimed = await _database.transaction(() async {
      final guests = await (_database.select(_database.purchaseRecords)
            ..where((table) => table.ownerType.equals('guest')))
          .get();
      for (final record in guests) {
        await (_database.update(_database.purchaseRecords)
              ..where((table) => table.id.equals(record.id)))
            .write(
          db.PurchaseRecordsCompanion(
            ownerType: const Value<String>('account'),
            ownerId: Value<int?>(userId),
            updatedAt: Value<DateTime>(DateTime.now().toUtc()),
          ),
        );
        await _replaceOperation(
          storageKey: record.id,
          userId: userId,
          kind: SyncOperationKind.upsert,
        );
      }
      return guests.length;
    });
    if (claimed > 0) await _emit();
    return claimed;
  }

  @override
  Future<List<PendingSyncOperation>> pendingOperations(int userId) async {
    final rows = await (_database.select(_database.syncOutbox)
          ..where((table) => table.userId.equals(userId))
          ..orderBy(<OrderClauseGenerator<db.$SyncOutboxTable>>[
            (table) => OrderingTerm.asc(table.createdAt),
          ]))
        .get();
    final operations = <PendingSyncOperation>[];
    for (final row in rows) {
      final kind = row.operation == 'delete'
          ? SyncOperationKind.delete
          : SyncOperationKind.upsert;
      final receipt = await _loadByStorageKey(row.purchaseId);
      operations.add(
        PendingSyncOperation(
          operationId: row.operationId,
          receiptId: receipt?.id ?? row.purchaseId,
          userId: row.userId,
          kind: kind,
          receipt: kind == SyncOperationKind.upsert ? receipt : null,
          retryCount: row.retryCount,
          lastError: row.lastError,
        ),
      );
    }
    return operations;
  }

  @override
  Future<void> applySyncSuccess(String operationId) async {
    await _database.transaction(() async {
      final operation = await (_database.select(_database.syncOutbox)
            ..where((table) => table.operationId.equals(operationId)))
          .getSingleOrNull();
      if (operation == null) return;
      if (operation.operation == SyncOperationKind.delete.name) {
        await (_database.delete(_database.purchaseRecords)
              ..where((table) => table.id.equals(operation.purchaseId)))
            .go();
      } else {
        await (_database.delete(_database.syncOutbox)
              ..where((table) => table.operationId.equals(operationId)))
            .go();
      }
    });
    await _emit();
  }

  @override
  Future<void> applySyncFailure(String operationId, String message) async {
    final operation = await (_database.select(_database.syncOutbox)
          ..where((table) => table.operationId.equals(operationId)))
        .getSingleOrNull();
    if (operation == null) return;
    await (_database.update(_database.syncOutbox)
          ..where((table) => table.operationId.equals(operationId)))
        .write(
      db.SyncOutboxCompanion(
        retryCount: Value<int>(operation.retryCount + 1),
        lastError: Value<String?>(message),
      ),
    );
  }

  @override
  Future<void> mergeRemoteReceipts(int userId, List<Receipt> receipts) async {
    await _database.transaction(() async {
      final remoteIds = receipts.map((receipt) => receipt.id).toSet();
      final localRows = await (_database.select(_database.purchaseRecords)
            ..where(
              (table) =>
                  table.ownerType.equals('account') &
                  table.ownerId.equals(userId),
            ))
          .get();
      for (final local in localRows) {
        if (remoteIds.contains(_publicId(local))) continue;
        final pending = await (_database.select(_database.syncOutbox)
              ..where(
                (table) =>
                    table.userId.equals(userId) &
                    table.purchaseId.equals(local.id),
              ))
            .getSingleOrNull();
        if (pending == null) {
          await (_database.delete(_database.purchaseRecords)
                ..where((table) => table.id.equals(local.id)))
              .go();
        }
      }
      for (final receipt in receipts) {
        final local =
            await _findRecord(PurchaseScope.account(userId), receipt.id);
        if (local != null) {
          final pending = await (_database.select(_database.syncOutbox)
                ..where(
                  (table) =>
                      table.userId.equals(userId) &
                      table.purchaseId.equals(local.id),
                ))
              .getSingleOrNull();
          if (pending != null) continue;
        }
        await _writeReceipt(
          receipt.copyWith(isSynced: true),
          scope: PurchaseScope.account(userId),
          queueOperation: false,
        );
      }
    });
    await _emit();
  }

  Future<void> _writeReceipt(
    Receipt receipt, {
    required PurchaseScope scope,
    required bool queueOperation,
  }) async {
    final existing = await _findRecord(scope, receipt.id);
    final storageKey = existing?.id ?? _newStorageKey(scope, receipt.id);
    await _database.into(_database.purchaseRecords).insertOnConflictUpdate(
          db.PurchaseRecordsCompanion.insert(
            id: storageKey,
            receiptId: Value<String?>(receipt.id),
            ownerType: scope is AccountPurchaseScope ? 'account' : 'guest',
            ownerId: Value<int?>(
              scope is AccountPurchaseScope ? scope.userId : null,
            ),
            storeName: receipt.storeName,
            purchaseDate: receipt.date.toUtc(),
            total: receipt.total,
            subtotal: Value<int>(receipt.subtotal),
            discount: Value<int>(receipt.discount),
            category: receipt.category.name,
            updatedAt: DateTime.now().toUtc(),
            deletedAt: const Value<DateTime?>.absent(),
            rawText: Value<String?>(receipt.rawText),
          ),
        );

    await (_database.delete(_database.uniformInvoices)
          ..where((table) => table.purchaseId.equals(storageKey)))
        .go();
    await (_database.delete(_database.purchasePlaces)
          ..where((table) => table.purchaseId.equals(storageKey)))
        .go();
    await (_database.delete(_database.receiptItems)
          ..where((table) => table.purchaseId.equals(storageKey)))
        .go();

    await _database.into(_database.uniformInvoices).insert(
          db.UniformInvoicesCompanion.insert(
            purchaseId: storageKey,
            receiptNumber: receipt.receiptNumber,
            period: Value<String?>(receipt.period.rocTerm),
            sellerTaxId: Value<String?>(receipt.sellerTaxId),
          ),
        );
    await _database.into(_database.purchasePlaces).insert(
          db.PurchasePlacesCompanion.insert(
            purchaseId: storageKey,
            address: receipt.address,
            latitude: Value<double?>(receipt.latitude),
            longitude: Value<double?>(receipt.longitude),
          ),
        );
    for (var index = 0; index < receipt.items.length; index++) {
      final item = receipt.items[index];
      await _database.into(_database.receiptItems).insert(
            db.ReceiptItemsCompanion.insert(
              purchaseId: storageKey,
              name: item.name,
              quantity: Value<int>(item.quantity),
              price: item.price,
              lineIndex: index,
            ),
          );
    }

    if (queueOperation && scope is AccountPurchaseScope) {
      final userId = scope.userId;
      await _replaceOperation(
        storageKey: storageKey,
        userId: userId,
        kind: SyncOperationKind.upsert,
      );
    }
  }

  Future<void> _replaceOperation({
    required String storageKey,
    required int userId,
    required SyncOperationKind kind,
  }) async {
    final random = Random.secure();
    final nonce = List<int>.generate(16, (_) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    final operationId = '${kind.name}:$userId:$nonce';
    await (_database.delete(_database.syncOutbox)
          ..where((table) => table.purchaseId.equals(storageKey)))
        .go();
    await _database.into(_database.syncOutbox).insert(
          db.SyncOutboxCompanion.insert(
            operationId: operationId,
            purchaseId: storageKey,
            userId: userId,
            operation: kind.name,
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<List<Receipt>> _loadVisibleReceipts() async {
    final scope = _scope;
    final query = _database.select(_database.purchaseRecords)
      ..where((table) {
        final owner = switch (scope) {
          GuestPurchaseScope() => table.ownerType.equals('guest'),
          AccountPurchaseScope(:final userId) =>
            table.ownerType.equals('account') & table.ownerId.equals(userId),
        };
        return owner & table.deletedAt.isNull();
      })
      ..orderBy(<OrderClauseGenerator<db.$PurchaseRecordsTable>>[
        (table) => OrderingTerm.desc(table.purchaseDate),
      ]);
    final records = await query.get();
    return Future.wait(records.map(_toReceipt));
  }

  Future<Receipt?> _loadByStorageKey(String id) async {
    final record = await (_database.select(_database.purchaseRecords)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return record == null ? null : _toReceipt(record);
  }

  Future<Receipt> _toReceipt(db.PurchaseRecord record) async {
    final invoice = await (_database.select(_database.uniformInvoices)
          ..where((table) => table.purchaseId.equals(record.id)))
        .getSingle();
    final place = await (_database.select(_database.purchasePlaces)
          ..where((table) => table.purchaseId.equals(record.id)))
        .getSingle();
    final itemRows = await (_database.select(_database.receiptItems)
          ..where((table) => table.purchaseId.equals(record.id))
          ..orderBy(<OrderClauseGenerator<db.$ReceiptItemsTable>>[
            (table) => OrderingTerm.asc(table.lineIndex),
          ]))
        .get();
    final hasPending = await (_database.select(_database.syncOutbox)
          ..where((table) => table.purchaseId.equals(record.id)))
        .getSingleOrNull();
    return Receipt(
      id: _publicId(record),
      storeName: record.storeName,
      address: place.address,
      date: record.purchaseDate.toLocal(),
      total: record.total,
      subtotal: record.subtotal,
      discount: record.discount,
      sellerTaxId: invoice.sellerTaxId,
      category: SpendingCategory.values.firstWhere(
        (category) => category.name == record.category,
        orElse: () => SpendingCategory.other,
      ),
      items: itemRows
          .map(
            (item) => ReceiptItem(
              name: item.name,
              quantity: item.quantity,
              price: item.price,
            ),
          )
          .toList(),
      receiptNumber: invoice.receiptNumber,
      isSynced: record.ownerType == 'account' && hasPending == null,
      rawText: record.rawText,
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }

  Future<db.PurchaseRecord?> _findRecord(
    PurchaseScope scope,
    String receiptId,
  ) =>
      (_database.select(_database.purchaseRecords)
            ..where(
              (table) =>
                  _ownerExpression(table, scope) &
                  (table.receiptId.equals(receiptId) |
                      (table.receiptId.isNull() & table.id.equals(receiptId))),
            ))
          .getSingleOrNull();

  Expression<bool> _ownerExpression(
    db.$PurchaseRecordsTable table,
    PurchaseScope scope,
  ) =>
      switch (scope) {
        GuestPurchaseScope() => table.ownerType.equals('guest'),
        AccountPurchaseScope(:final userId) =>
          table.ownerType.equals('account') & table.ownerId.equals(userId),
      };

  String _publicId(db.PurchaseRecord record) => record.receiptId ?? record.id;

  String _newStorageKey(PurchaseScope scope, String receiptId) =>
      switch (scope) {
        GuestPurchaseScope() => 'guest:$receiptId',
        AccountPurchaseScope(:final userId) => 'account:$userId:$receiptId',
      };

  Future<void> _emit() async {
    if (_closed) return;
    _changes.add(List<Receipt>.unmodifiable(await _loadVisibleReceipts()));
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _changes.close();
    await _database.close();
  }
}
