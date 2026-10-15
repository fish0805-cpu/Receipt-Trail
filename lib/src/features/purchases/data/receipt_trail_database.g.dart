// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_trail_database.dart';

// ignore_for_file: type=lint
class $PurchaseRecordsTable extends PurchaseRecords
    with TableInfo<$PurchaseRecordsTable, PurchaseRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiptIdMeta =
      const VerificationMeta('receiptId');
  @override
  late final GeneratedColumn<String> receiptId = GeneratedColumn<String>(
      'receipt_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerTypeMeta =
      const VerificationMeta('ownerType');
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
      'owner_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<int> ownerId = GeneratedColumn<int>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _storeNameMeta =
      const VerificationMeta('storeName');
  @override
  late final GeneratedColumn<String> storeName = GeneratedColumn<String>(
      'store_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
      'purchase_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<int> subtotal = GeneratedColumn<int>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant<int>(0));
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<int> discount = GeneratedColumn<int>(
      'discount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant<int>(0));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        receiptId,
        ownerType,
        ownerId,
        storeName,
        purchaseDate,
        total,
        subtotal,
        discount,
        category,
        updatedAt,
        deletedAt,
        rawText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_records';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('receipt_id')) {
      context.handle(_receiptIdMeta,
          receiptId.isAcceptableOrUnknown(data['receipt_id']!, _receiptIdMeta));
    }
    if (data.containsKey('owner_type')) {
      context.handle(_ownerTypeMeta,
          ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta));
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('store_name')) {
      context.handle(_storeNameMeta,
          storeName.isAcceptableOrUnknown(data['store_name']!, _storeNameMeta));
    } else if (isInserting) {
      context.missing(_storeNameMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      receiptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receipt_id']),
      ownerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_type'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}owner_id']),
      storeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_name'])!,
      purchaseDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}purchase_date'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtotal'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text']),
    );
  }

  @override
  $PurchaseRecordsTable createAlias(String alias) {
    return $PurchaseRecordsTable(attachedDatabase, alias);
  }
}

class PurchaseRecord extends DataClass implements Insertable<PurchaseRecord> {
  /// Internal key. The public receipt ID can be identical in two owner scopes.
  final String id;
  final String? receiptId;
  final String ownerType;
  final int? ownerId;
  final String storeName;
  final DateTime purchaseDate;
  final int total;
  final int subtotal;
  final int discount;
  final String category;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? rawText;
  const PurchaseRecord(
      {required this.id,
      this.receiptId,
      required this.ownerType,
      this.ownerId,
      required this.storeName,
      required this.purchaseDate,
      required this.total,
      required this.subtotal,
      required this.discount,
      required this.category,
      required this.updatedAt,
      this.deletedAt,
      this.rawText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || receiptId != null) {
      map['receipt_id'] = Variable<String>(receiptId);
    }
    map['owner_type'] = Variable<String>(ownerType);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<int>(ownerId);
    }
    map['store_name'] = Variable<String>(storeName);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['total'] = Variable<int>(total);
    map['subtotal'] = Variable<int>(subtotal);
    map['discount'] = Variable<int>(discount);
    map['category'] = Variable<String>(category);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    return map;
  }

  PurchaseRecordsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseRecordsCompanion(
      id: Value(id),
      receiptId: receiptId == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptId),
      ownerType: Value(ownerType),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      storeName: Value(storeName),
      purchaseDate: Value(purchaseDate),
      total: Value(total),
      subtotal: Value(subtotal),
      discount: Value(discount),
      category: Value(category),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
    );
  }

  factory PurchaseRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseRecord(
      id: serializer.fromJson<String>(json['id']),
      receiptId: serializer.fromJson<String?>(json['receiptId']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<int?>(json['ownerId']),
      storeName: serializer.fromJson<String>(json['storeName']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      total: serializer.fromJson<int>(json['total']),
      subtotal: serializer.fromJson<int>(json['subtotal']),
      discount: serializer.fromJson<int>(json['discount']),
      category: serializer.fromJson<String>(json['category']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rawText: serializer.fromJson<String?>(json['rawText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'receiptId': serializer.toJson<String?>(receiptId),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<int?>(ownerId),
      'storeName': serializer.toJson<String>(storeName),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'total': serializer.toJson<int>(total),
      'subtotal': serializer.toJson<int>(subtotal),
      'discount': serializer.toJson<int>(discount),
      'category': serializer.toJson<String>(category),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rawText': serializer.toJson<String?>(rawText),
    };
  }

  PurchaseRecord copyWith(
          {String? id,
          Value<String?> receiptId = const Value.absent(),
          String? ownerType,
          Value<int?> ownerId = const Value.absent(),
          String? storeName,
          DateTime? purchaseDate,
          int? total,
          int? subtotal,
          int? discount,
          String? category,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> rawText = const Value.absent()}) =>
      PurchaseRecord(
        id: id ?? this.id,
        receiptId: receiptId.present ? receiptId.value : this.receiptId,
        ownerType: ownerType ?? this.ownerType,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        storeName: storeName ?? this.storeName,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        total: total ?? this.total,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        category: category ?? this.category,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        rawText: rawText.present ? rawText.value : this.rawText,
      );
  PurchaseRecord copyWithCompanion(PurchaseRecordsCompanion data) {
    return PurchaseRecord(
      id: data.id.present ? data.id.value : this.id,
      receiptId: data.receiptId.present ? data.receiptId.value : this.receiptId,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      storeName: data.storeName.present ? data.storeName.value : this.storeName,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      total: data.total.present ? data.total.value : this.total,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discount: data.discount.present ? data.discount.value : this.discount,
      category: data.category.present ? data.category.value : this.category,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseRecord(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('storeName: $storeName, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('total: $total, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('category: $category, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rawText: $rawText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      receiptId,
      ownerType,
      ownerId,
      storeName,
      purchaseDate,
      total,
      subtotal,
      discount,
      category,
      updatedAt,
      deletedAt,
      rawText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseRecord &&
          other.id == this.id &&
          other.receiptId == this.receiptId &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.storeName == this.storeName &&
          other.purchaseDate == this.purchaseDate &&
          other.total == this.total &&
          other.subtotal == this.subtotal &&
          other.discount == this.discount &&
          other.category == this.category &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rawText == this.rawText);
}

class PurchaseRecordsCompanion extends UpdateCompanion<PurchaseRecord> {
  final Value<String> id;
  final Value<String?> receiptId;
  final Value<String> ownerType;
  final Value<int?> ownerId;
  final Value<String> storeName;
  final Value<DateTime> purchaseDate;
  final Value<int> total;
  final Value<int> subtotal;
  final Value<int> discount;
  final Value<String> category;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> rawText;
  final Value<int> rowid;
  const PurchaseRecordsCompanion({
    this.id = const Value.absent(),
    this.receiptId = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.storeName = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.total = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.category = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rawText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseRecordsCompanion.insert({
    required String id,
    this.receiptId = const Value.absent(),
    required String ownerType,
    this.ownerId = const Value.absent(),
    required String storeName,
    required DateTime purchaseDate,
    required int total,
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    required String category,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rawText = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownerType = Value(ownerType),
        storeName = Value(storeName),
        purchaseDate = Value(purchaseDate),
        total = Value(total),
        category = Value(category),
        updatedAt = Value(updatedAt);
  static Insertable<PurchaseRecord> custom({
    Expression<String>? id,
    Expression<String>? receiptId,
    Expression<String>? ownerType,
    Expression<int>? ownerId,
    Expression<String>? storeName,
    Expression<DateTime>? purchaseDate,
    Expression<int>? total,
    Expression<int>? subtotal,
    Expression<int>? discount,
    Expression<String>? category,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? rawText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptId != null) 'receipt_id': receiptId,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (storeName != null) 'store_name': storeName,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (total != null) 'total': total,
      if (subtotal != null) 'subtotal': subtotal,
      if (discount != null) 'discount': discount,
      if (category != null) 'category': category,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rawText != null) 'raw_text': rawText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? receiptId,
      Value<String>? ownerType,
      Value<int?>? ownerId,
      Value<String>? storeName,
      Value<DateTime>? purchaseDate,
      Value<int>? total,
      Value<int>? subtotal,
      Value<int>? discount,
      Value<String>? category,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? rawText,
      Value<int>? rowid}) {
    return PurchaseRecordsCompanion(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      storeName: storeName ?? this.storeName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      total: total ?? this.total,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      category: category ?? this.category,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rawText: rawText ?? this.rawText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (receiptId.present) {
      map['receipt_id'] = Variable<String>(receiptId.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<int>(ownerId.value);
    }
    if (storeName.present) {
      map['store_name'] = Variable<String>(storeName.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<int>(subtotal.value);
    }
    if (discount.present) {
      map['discount'] = Variable<int>(discount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseRecordsCompanion(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('storeName: $storeName, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('total: $total, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('category: $category, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rawText: $rawText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UniformInvoicesTable extends UniformInvoices
    with TableInfo<$UniformInvoicesTable, UniformInvoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UniformInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES purchase_records (id) ON DELETE CASCADE'));
  static const VerificationMeta _receiptNumberMeta =
      const VerificationMeta('receiptNumber');
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
      'receipt_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prizeStatusMeta =
      const VerificationMeta('prizeStatus');
  @override
  late final GeneratedColumn<String> prizeStatus = GeneratedColumn<String>(
      'prize_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sellerTaxIdMeta =
      const VerificationMeta('sellerTaxId');
  @override
  late final GeneratedColumn<String> sellerTaxId = GeneratedColumn<String>(
      'seller_tax_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [purchaseId, receiptNumber, period, prizeStatus, sellerTaxId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'uniform_invoices';
  @override
  VerificationContext validateIntegrity(Insertable<UniformInvoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
          _receiptNumberMeta,
          receiptNumber.isAcceptableOrUnknown(
              data['receipt_number']!, _receiptNumberMeta));
    } else if (isInserting) {
      context.missing(_receiptNumberMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    }
    if (data.containsKey('prize_status')) {
      context.handle(
          _prizeStatusMeta,
          prizeStatus.isAcceptableOrUnknown(
              data['prize_status']!, _prizeStatusMeta));
    }
    if (data.containsKey('seller_tax_id')) {
      context.handle(
          _sellerTaxIdMeta,
          sellerTaxId.isAcceptableOrUnknown(
              data['seller_tax_id']!, _sellerTaxIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {purchaseId};
  @override
  UniformInvoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UniformInvoice(
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id'])!,
      receiptNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receipt_number'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period']),
      prizeStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prize_status']),
      sellerTaxId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller_tax_id']),
    );
  }

  @override
  $UniformInvoicesTable createAlias(String alias) {
    return $UniformInvoicesTable(attachedDatabase, alias);
  }
}

class UniformInvoice extends DataClass implements Insertable<UniformInvoice> {
  final String purchaseId;
  final String receiptNumber;
  final String? period;
  final String? prizeStatus;
  final String? sellerTaxId;
  const UniformInvoice(
      {required this.purchaseId,
      required this.receiptNumber,
      this.period,
      this.prizeStatus,
      this.sellerTaxId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['purchase_id'] = Variable<String>(purchaseId);
    map['receipt_number'] = Variable<String>(receiptNumber);
    if (!nullToAbsent || period != null) {
      map['period'] = Variable<String>(period);
    }
    if (!nullToAbsent || prizeStatus != null) {
      map['prize_status'] = Variable<String>(prizeStatus);
    }
    if (!nullToAbsent || sellerTaxId != null) {
      map['seller_tax_id'] = Variable<String>(sellerTaxId);
    }
    return map;
  }

  UniformInvoicesCompanion toCompanion(bool nullToAbsent) {
    return UniformInvoicesCompanion(
      purchaseId: Value(purchaseId),
      receiptNumber: Value(receiptNumber),
      period:
          period == null && nullToAbsent ? const Value.absent() : Value(period),
      prizeStatus: prizeStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(prizeStatus),
      sellerTaxId: sellerTaxId == null && nullToAbsent
          ? const Value.absent()
          : Value(sellerTaxId),
    );
  }

  factory UniformInvoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UniformInvoice(
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      receiptNumber: serializer.fromJson<String>(json['receiptNumber']),
      period: serializer.fromJson<String?>(json['period']),
      prizeStatus: serializer.fromJson<String?>(json['prizeStatus']),
      sellerTaxId: serializer.fromJson<String?>(json['sellerTaxId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'purchaseId': serializer.toJson<String>(purchaseId),
      'receiptNumber': serializer.toJson<String>(receiptNumber),
      'period': serializer.toJson<String?>(period),
      'prizeStatus': serializer.toJson<String?>(prizeStatus),
      'sellerTaxId': serializer.toJson<String?>(sellerTaxId),
    };
  }

  UniformInvoice copyWith(
          {String? purchaseId,
          String? receiptNumber,
          Value<String?> period = const Value.absent(),
          Value<String?> prizeStatus = const Value.absent(),
          Value<String?> sellerTaxId = const Value.absent()}) =>
      UniformInvoice(
        purchaseId: purchaseId ?? this.purchaseId,
        receiptNumber: receiptNumber ?? this.receiptNumber,
        period: period.present ? period.value : this.period,
        prizeStatus: prizeStatus.present ? prizeStatus.value : this.prizeStatus,
        sellerTaxId: sellerTaxId.present ? sellerTaxId.value : this.sellerTaxId,
      );
  UniformInvoice copyWithCompanion(UniformInvoicesCompanion data) {
    return UniformInvoice(
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
      period: data.period.present ? data.period.value : this.period,
      prizeStatus:
          data.prizeStatus.present ? data.prizeStatus.value : this.prizeStatus,
      sellerTaxId:
          data.sellerTaxId.present ? data.sellerTaxId.value : this.sellerTaxId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UniformInvoice(')
          ..write('purchaseId: $purchaseId, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('period: $period, ')
          ..write('prizeStatus: $prizeStatus, ')
          ..write('sellerTaxId: $sellerTaxId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(purchaseId, receiptNumber, period, prizeStatus, sellerTaxId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UniformInvoice &&
          other.purchaseId == this.purchaseId &&
          other.receiptNumber == this.receiptNumber &&
          other.period == this.period &&
          other.prizeStatus == this.prizeStatus &&
          other.sellerTaxId == this.sellerTaxId);
}

class UniformInvoicesCompanion extends UpdateCompanion<UniformInvoice> {
  final Value<String> purchaseId;
  final Value<String> receiptNumber;
  final Value<String?> period;
  final Value<String?> prizeStatus;
  final Value<String?> sellerTaxId;
  final Value<int> rowid;
  const UniformInvoicesCompanion({
    this.purchaseId = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.period = const Value.absent(),
    this.prizeStatus = const Value.absent(),
    this.sellerTaxId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UniformInvoicesCompanion.insert({
    required String purchaseId,
    required String receiptNumber,
    this.period = const Value.absent(),
    this.prizeStatus = const Value.absent(),
    this.sellerTaxId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : purchaseId = Value(purchaseId),
        receiptNumber = Value(receiptNumber);
  static Insertable<UniformInvoice> custom({
    Expression<String>? purchaseId,
    Expression<String>? receiptNumber,
    Expression<String>? period,
    Expression<String>? prizeStatus,
    Expression<String>? sellerTaxId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (period != null) 'period': period,
      if (prizeStatus != null) 'prize_status': prizeStatus,
      if (sellerTaxId != null) 'seller_tax_id': sellerTaxId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UniformInvoicesCompanion copyWith(
      {Value<String>? purchaseId,
      Value<String>? receiptNumber,
      Value<String?>? period,
      Value<String?>? prizeStatus,
      Value<String?>? sellerTaxId,
      Value<int>? rowid}) {
    return UniformInvoicesCompanion(
      purchaseId: purchaseId ?? this.purchaseId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      period: period ?? this.period,
      prizeStatus: prizeStatus ?? this.prizeStatus,
      sellerTaxId: sellerTaxId ?? this.sellerTaxId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (prizeStatus.present) {
      map['prize_status'] = Variable<String>(prizeStatus.value);
    }
    if (sellerTaxId.present) {
      map['seller_tax_id'] = Variable<String>(sellerTaxId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UniformInvoicesCompanion(')
          ..write('purchaseId: $purchaseId, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('period: $period, ')
          ..write('prizeStatus: $prizeStatus, ')
          ..write('sellerTaxId: $sellerTaxId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasePlacesTable extends PurchasePlaces
    with TableInfo<$PurchasePlacesTable, PurchasePlace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasePlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES purchase_records (id) ON DELETE CASCADE'));
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [purchaseId, address, latitude, longitude];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_places';
  @override
  VerificationContext validateIntegrity(Insertable<PurchasePlace> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {purchaseId};
  @override
  PurchasePlace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchasePlace(
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
    );
  }

  @override
  $PurchasePlacesTable createAlias(String alias) {
    return $PurchasePlacesTable(attachedDatabase, alias);
  }
}

class PurchasePlace extends DataClass implements Insertable<PurchasePlace> {
  final String purchaseId;
  final String address;
  final double? latitude;
  final double? longitude;
  const PurchasePlace(
      {required this.purchaseId,
      required this.address,
      this.latitude,
      this.longitude});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['purchase_id'] = Variable<String>(purchaseId);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  PurchasePlacesCompanion toCompanion(bool nullToAbsent) {
    return PurchasePlacesCompanion(
      purchaseId: Value(purchaseId),
      address: Value(address),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory PurchasePlace.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchasePlace(
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      address: serializer.fromJson<String>(json['address']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'purchaseId': serializer.toJson<String>(purchaseId),
      'address': serializer.toJson<String>(address),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  PurchasePlace copyWith(
          {String? purchaseId,
          String? address,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent()}) =>
      PurchasePlace(
        purchaseId: purchaseId ?? this.purchaseId,
        address: address ?? this.address,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
      );
  PurchasePlace copyWithCompanion(PurchasePlacesCompanion data) {
    return PurchasePlace(
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchasePlace(')
          ..write('purchaseId: $purchaseId, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(purchaseId, address, latitude, longitude);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchasePlace &&
          other.purchaseId == this.purchaseId &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class PurchasePlacesCompanion extends UpdateCompanion<PurchasePlace> {
  final Value<String> purchaseId;
  final Value<String> address;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> rowid;
  const PurchasePlacesCompanion({
    this.purchaseId = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasePlacesCompanion.insert({
    required String purchaseId,
    required String address,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : purchaseId = Value(purchaseId),
        address = Value(address);
  static Insertable<PurchasePlace> custom({
    Expression<String>? purchaseId,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasePlacesCompanion copyWith(
      {Value<String>? purchaseId,
      Value<String>? address,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<int>? rowid}) {
    return PurchasePlacesCompanion(
      purchaseId: purchaseId ?? this.purchaseId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasePlacesCompanion(')
          ..write('purchaseId: $purchaseId, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptItemsTable extends ReceiptItems
    with TableInfo<$ReceiptItemsTable, ReceiptItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES purchase_records (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant<int>(1));
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
      'price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineIndexMeta =
      const VerificationMeta('lineIndex');
  @override
  late final GeneratedColumn<int> lineIndex = GeneratedColumn<int>(
      'line_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, purchaseId, name, quantity, price, lineIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_items';
  @override
  VerificationContext validateIntegrity(Insertable<ReceiptItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('line_index')) {
      context.handle(_lineIndexMeta,
          lineIndex.isAcceptableOrUnknown(data['line_index']!, _lineIndexMeta));
    } else if (isInserting) {
      context.missing(_lineIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price'])!,
      lineIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_index'])!,
    );
  }

  @override
  $ReceiptItemsTable createAlias(String alias) {
    return $ReceiptItemsTable(attachedDatabase, alias);
  }
}

class ReceiptItem extends DataClass implements Insertable<ReceiptItem> {
  final int id;
  final String purchaseId;
  final String name;
  final int quantity;
  final int price;
  final int lineIndex;
  const ReceiptItem(
      {required this.id,
      required this.purchaseId,
      required this.name,
      required this.quantity,
      required this.price,
      required this.lineIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['price'] = Variable<int>(price);
    map['line_index'] = Variable<int>(lineIndex);
    return map;
  }

  ReceiptItemsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptItemsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      name: Value(name),
      quantity: Value(quantity),
      price: Value(price),
      lineIndex: Value(lineIndex),
    );
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptItem(
      id: serializer.fromJson<int>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      price: serializer.fromJson<int>(json['price']),
      lineIndex: serializer.fromJson<int>(json['lineIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'price': serializer.toJson<int>(price),
      'lineIndex': serializer.toJson<int>(lineIndex),
    };
  }

  ReceiptItem copyWith(
          {int? id,
          String? purchaseId,
          String? name,
          int? quantity,
          int? price,
          int? lineIndex}) =>
      ReceiptItem(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        lineIndex: lineIndex ?? this.lineIndex,
      );
  ReceiptItem copyWithCompanion(ReceiptItemsCompanion data) {
    return ReceiptItem(
      id: data.id.present ? data.id.value : this.id,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      price: data.price.present ? data.price.value : this.price,
      lineIndex: data.lineIndex.present ? data.lineIndex.value : this.lineIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptItem(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('lineIndex: $lineIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, purchaseId, name, quantity, price, lineIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptItem &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.price == this.price &&
          other.lineIndex == this.lineIndex);
}

class ReceiptItemsCompanion extends UpdateCompanion<ReceiptItem> {
  final Value<int> id;
  final Value<String> purchaseId;
  final Value<String> name;
  final Value<int> quantity;
  final Value<int> price;
  final Value<int> lineIndex;
  const ReceiptItemsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.price = const Value.absent(),
    this.lineIndex = const Value.absent(),
  });
  ReceiptItemsCompanion.insert({
    this.id = const Value.absent(),
    required String purchaseId,
    required String name,
    this.quantity = const Value.absent(),
    required int price,
    required int lineIndex,
  })  : purchaseId = Value(purchaseId),
        name = Value(name),
        price = Value(price),
        lineIndex = Value(lineIndex);
  static Insertable<ReceiptItem> custom({
    Expression<int>? id,
    Expression<String>? purchaseId,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<int>? price,
    Expression<int>? lineIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (lineIndex != null) 'line_index': lineIndex,
    });
  }

  ReceiptItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? purchaseId,
      Value<String>? name,
      Value<int>? quantity,
      Value<int>? price,
      Value<int>? lineIndex}) {
    return ReceiptItemsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      lineIndex: lineIndex ?? this.lineIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (lineIndex.present) {
      map['line_index'] = Variable<int>(lineIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptItemsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('lineIndex: $lineIndex')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta =
      const VerificationMeta('operationId');
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
      'operation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES purchase_records (id) ON DELETE CASCADE'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant<int>(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        operationId,
        purchaseId,
        userId,
        operation,
        retryCount,
        lastError,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
          _operationIdMeta,
          operationId.isAcceptableOrUnknown(
              data['operation_id']!, _operationIdMeta));
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      operationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_id'])!,
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String operationId;
  final String purchaseId;
  final int userId;
  final String operation;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  const SyncOutboxData(
      {required this.operationId,
      required this.purchaseId,
      required this.userId,
      required this.operation,
      required this.retryCount,
      this.lastError,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['user_id'] = Variable<int>(userId);
    map['operation'] = Variable<String>(operation);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      operationId: Value(operationId),
      purchaseId: Value(purchaseId),
      userId: Value(userId),
      operation: Value(operation),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory SyncOutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      operationId: serializer.fromJson<String>(json['operationId']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      userId: serializer.fromJson<int>(json['userId']),
      operation: serializer.fromJson<String>(json['operation']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'userId': serializer.toJson<int>(userId),
      'operation': serializer.toJson<String>(operation),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncOutboxData copyWith(
          {String? operationId,
          String? purchaseId,
          int? userId,
          String? operation,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt}) =>
      SyncOutboxData(
        operationId: operationId ?? this.operationId,
        purchaseId: purchaseId ?? this.purchaseId,
        userId: userId ?? this.userId,
        operation: operation ?? this.operation,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      operationId:
          data.operationId.present ? data.operationId.value : this.operationId,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      userId: data.userId.present ? data.userId.value : this.userId,
      operation: data.operation.present ? data.operation.value : this.operation,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('operationId: $operationId, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('userId: $userId, ')
          ..write('operation: $operation, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(operationId, purchaseId, userId, operation,
      retryCount, lastError, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.operationId == this.operationId &&
          other.purchaseId == this.purchaseId &&
          other.userId == this.userId &&
          other.operation == this.operation &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> operationId;
  final Value<String> purchaseId;
  final Value<int> userId;
  final Value<String> operation;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.operationId = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.operation = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String operationId,
    required String purchaseId,
    required int userId,
    required String operation,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : operationId = Value(operationId),
        purchaseId = Value(purchaseId),
        userId = Value(userId),
        operation = Value(operation),
        createdAt = Value(createdAt);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? operationId,
    Expression<String>? purchaseId,
    Expression<int>? userId,
    Expression<String>? operation,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (userId != null) 'user_id': userId,
      if (operation != null) 'operation': operation,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith(
      {Value<String>? operationId,
      Value<String>? purchaseId,
      Value<int>? userId,
      Value<String>? operation,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SyncOutboxCompanion(
      operationId: operationId ?? this.operationId,
      purchaseId: purchaseId ?? this.purchaseId,
      userId: userId ?? this.userId,
      operation: operation ?? this.operation,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('operationId: $operationId, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('userId: $userId, ')
          ..write('operation: $operation, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetadataTable extends AppMetadata
    with TableInfo<$AppMetadataTable, AppMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetadataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppMetadataTable createAlias(String alias) {
    return $AppMetadataTable(attachedDatabase, alias);
  }
}

class AppMetadataData extends DataClass implements Insertable<AppMetadataData> {
  final String key;
  final String value;
  const AppMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetadataCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetadataData copyWith({String? key, String? value}) => AppMetadataData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppMetadataData copyWithCompanion(AppMetadataCompanion data) {
    return AppMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetadataCompanion extends UpdateCompanion<AppMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ReceiptTrailDatabase extends GeneratedDatabase {
  _$ReceiptTrailDatabase(QueryExecutor e) : super(e);
  $ReceiptTrailDatabaseManager get managers =>
      $ReceiptTrailDatabaseManager(this);
  late final $PurchaseRecordsTable purchaseRecords =
      $PurchaseRecordsTable(this);
  late final $UniformInvoicesTable uniformInvoices =
      $UniformInvoicesTable(this);
  late final $PurchasePlacesTable purchasePlaces = $PurchasePlacesTable(this);
  late final $ReceiptItemsTable receiptItems = $ReceiptItemsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $AppMetadataTable appMetadata = $AppMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        purchaseRecords,
        uniformInvoices,
        purchasePlaces,
        receiptItems,
        syncOutbox,
        appMetadata
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('purchase_records',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('uniform_invoices', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('purchase_records',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('purchase_places', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('purchase_records',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('receipt_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('purchase_records',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('sync_outbox', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$PurchaseRecordsTableCreateCompanionBuilder = PurchaseRecordsCompanion
    Function({
  required String id,
  Value<String?> receiptId,
  required String ownerType,
  Value<int?> ownerId,
  required String storeName,
  required DateTime purchaseDate,
  required int total,
  Value<int> subtotal,
  Value<int> discount,
  required String category,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> rawText,
  Value<int> rowid,
});
typedef $$PurchaseRecordsTableUpdateCompanionBuilder = PurchaseRecordsCompanion
    Function({
  Value<String> id,
  Value<String?> receiptId,
  Value<String> ownerType,
  Value<int?> ownerId,
  Value<String> storeName,
  Value<DateTime> purchaseDate,
  Value<int> total,
  Value<int> subtotal,
  Value<int> discount,
  Value<String> category,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> rawText,
  Value<int> rowid,
});

final class $$PurchaseRecordsTableReferences extends BaseReferences<
    _$ReceiptTrailDatabase, $PurchaseRecordsTable, PurchaseRecord> {
  $$PurchaseRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UniformInvoicesTable, List<UniformInvoice>>
      _uniformInvoicesRefsTable(_$ReceiptTrailDatabase db) =>
          MultiTypedResultKey.fromTable(db.uniformInvoices,
              aliasName: 'purchase_records__id__uniform_invoices__purchase_id');

  $$UniformInvoicesTableProcessedTableManager get uniformInvoicesRefs {
    final manager = $$UniformInvoicesTableTableManager(
            $_db, $_db.uniformInvoices)
        .filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_uniformInvoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PurchasePlacesTable, List<PurchasePlace>>
      _purchasePlacesRefsTable(_$ReceiptTrailDatabase db) =>
          MultiTypedResultKey.fromTable(db.purchasePlaces,
              aliasName: 'purchase_records__id__purchase_places__purchase_id');

  $$PurchasePlacesTableProcessedTableManager get purchasePlacesRefs {
    final manager = $$PurchasePlacesTableTableManager($_db, $_db.purchasePlaces)
        .filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchasePlacesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReceiptItemsTable, List<ReceiptItem>>
      _receiptItemsRefsTable(_$ReceiptTrailDatabase db) =>
          MultiTypedResultKey.fromTable(db.receiptItems,
              aliasName: 'purchase_records__id__receipt_items__purchase_id');

  $$ReceiptItemsTableProcessedTableManager get receiptItemsRefs {
    final manager = $$ReceiptItemsTableTableManager($_db, $_db.receiptItems)
        .filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SyncOutboxTable, List<SyncOutboxData>>
      _syncOutboxRefsTable(_$ReceiptTrailDatabase db) =>
          MultiTypedResultKey.fromTable(db.syncOutbox,
              aliasName: 'purchase_records__id__sync_outbox__purchase_id');

  $$SyncOutboxTableProcessedTableManager get syncOutboxRefs {
    final manager = $$SyncOutboxTableTableManager($_db, $_db.syncOutbox)
        .filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncOutboxRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PurchaseRecordsTableFilterComposer
    extends Composer<_$ReceiptTrailDatabase, $PurchaseRecordsTable> {
  $$PurchaseRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptId => $composableBuilder(
      column: $table.receiptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerType => $composableBuilder(
      column: $table.ownerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeName => $composableBuilder(
      column: $table.storeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  Expression<bool> uniformInvoicesRefs(
      Expression<bool> Function($$UniformInvoicesTableFilterComposer f) f) {
    final $$UniformInvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.uniformInvoices,
        getReferencedColumn: (t) => t.purchaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UniformInvoicesTableFilterComposer(
              $db: $db,
              $table: $db.uniformInvoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> purchasePlacesRefs(
      Expression<bool> Function($$PurchasePlacesTableFilterComposer f) f) {
    final $$PurchasePlacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.purchasePlaces,
        getReferencedColumn: (t) => t.purchaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchasePlacesTableFilterComposer(
              $db: $db,
              $table: $db.purchasePlaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> receiptItemsRefs(
      Expression<bool> Function($$ReceiptItemsTableFilterComposer f) f) {
    final $$ReceiptItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.receiptItems,
        getReferencedColumn: (t) => t.purchaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReceiptItemsTableFilterComposer(
              $db: $db,
              $table: $db.receiptItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> syncOutboxRefs(
      Expression<bool> Function($$SyncOutboxTableFilterComposer f) f) {
    final $$SyncOutboxTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.syncOutbox,
        getReferencedColumn: (t) => t.purchaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncOutboxTableFilterComposer(
              $db: $db,
              $table: $db.syncOutbox,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PurchaseRecordsTableOrderingComposer
    extends Composer<_$ReceiptTrailDatabase, $PurchaseRecordsTable> {
  $$PurchaseRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptId => $composableBuilder(
      column: $table.receiptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerType => $composableBuilder(
      column: $table.ownerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeName => $composableBuilder(
      column: $table.storeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));
}

class $$PurchaseRecordsTableAnnotationComposer
    extends Composer<_$ReceiptTrailDatabase, $PurchaseRecordsTable> {
  $$PurchaseRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get receiptId =>
      $composableBuilder(column: $table.receiptId, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<int> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get storeName =>
      $composableBuilder(column: $table.storeName, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<int> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  Expression<T> uniformInvoicesRefs<T extends Object>(
      Expression<T> Function($$UniformInvoicesTableAnnotationComposer a) f) {
    final $$UniformInvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.uniformInvoices,
        getReferencedColumn: (t) => t.purchaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UniformInvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.uniformInvoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> purchasePlacesRefs<T extends Object>(
      Expression<T> Function($$PurchasePlacesTableAnnotationComposer a) f) {
    final $$PurchasePlacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.purchasePlaces,
        getReferencedColumn: (t) => t.purchaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchasePlacesTableAnnotationComposer(
              $db: $db,
              $table: $db.purchasePlaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> receiptItemsRefs<T extends Object>(
      Expression<T> Function($$ReceiptItemsTableAnnotationComposer a) f) {
    final $$ReceiptItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.receiptItems,
        getReferencedColumn: (t) => t.purchaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReceiptItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.receiptItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> syncOutboxRefs<T extends Object>(
      Expression<T> Function($$SyncOutboxTableAnnotationComposer a) f) {
    final $$SyncOutboxTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.syncOutbox,
        getReferencedColumn: (t) => t.purchaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncOutboxTableAnnotationComposer(
              $db: $db,
              $table: $db.syncOutbox,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PurchaseRecordsTableTableManager extends RootTableManager<
    _$ReceiptTrailDatabase,
    $PurchaseRecordsTable,
    PurchaseRecord,
    $$PurchaseRecordsTableFilterComposer,
    $$PurchaseRecordsTableOrderingComposer,
    $$PurchaseRecordsTableAnnotationComposer,
    $$PurchaseRecordsTableCreateCompanionBuilder,
    $$PurchaseRecordsTableUpdateCompanionBuilder,
    (PurchaseRecord, $$PurchaseRecordsTableReferences),
    PurchaseRecord,
    PrefetchHooks Function(
        {bool uniformInvoicesRefs,
        bool purchasePlacesRefs,
        bool receiptItemsRefs,
        bool syncOutboxRefs})> {
  $$PurchaseRecordsTableTableManager(
      _$ReceiptTrailDatabase db, $PurchaseRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> receiptId = const Value.absent(),
            Value<String> ownerType = const Value.absent(),
            Value<int?> ownerId = const Value.absent(),
            Value<String> storeName = const Value.absent(),
            Value<DateTime> purchaseDate = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<int> subtotal = const Value.absent(),
            Value<int> discount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> rawText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseRecordsCompanion(
            id: id,
            receiptId: receiptId,
            ownerType: ownerType,
            ownerId: ownerId,
            storeName: storeName,
            purchaseDate: purchaseDate,
            total: total,
            subtotal: subtotal,
            discount: discount,
            category: category,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rawText: rawText,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> receiptId = const Value.absent(),
            required String ownerType,
            Value<int?> ownerId = const Value.absent(),
            required String storeName,
            required DateTime purchaseDate,
            required int total,
            Value<int> subtotal = const Value.absent(),
            Value<int> discount = const Value.absent(),
            required String category,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> rawText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseRecordsCompanion.insert(
            id: id,
            receiptId: receiptId,
            ownerType: ownerType,
            ownerId: ownerId,
            storeName: storeName,
            purchaseDate: purchaseDate,
            total: total,
            subtotal: subtotal,
            discount: discount,
            category: category,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rawText: rawText,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PurchaseRecordsTable, PurchaseRecord>(table),
                    $$PurchaseRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {uniformInvoicesRefs = false,
              purchasePlacesRefs = false,
              receiptItemsRefs = false,
              syncOutboxRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (uniformInvoicesRefs) db.uniformInvoices,
                if (purchasePlacesRefs) db.purchasePlaces,
                if (receiptItemsRefs) db.receiptItems,
                if (syncOutboxRefs) db.syncOutbox
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (uniformInvoicesRefs)
                    await $_getPrefetchedData<PurchaseRecord,
                            $PurchaseRecordsTable, UniformInvoice>(
                        currentTable: table,
                        referencedTable: $$PurchaseRecordsTableReferences
                            ._uniformInvoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PurchaseRecordsTableReferences(db, table, p0)
                                .uniformInvoicesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.purchaseId == item.id),
                        typedResults: items),
                  if (purchasePlacesRefs)
                    await $_getPrefetchedData<PurchaseRecord,
                            $PurchaseRecordsTable, PurchasePlace>(
                        currentTable: table,
                        referencedTable: $$PurchaseRecordsTableReferences
                            ._purchasePlacesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PurchaseRecordsTableReferences(db, table, p0)
                                .purchasePlacesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.purchaseId == item.id),
                        typedResults: items),
                  if (receiptItemsRefs)
                    await $_getPrefetchedData<PurchaseRecord,
                            $PurchaseRecordsTable, ReceiptItem>(
                        currentTable: table,
                        referencedTable: $$PurchaseRecordsTableReferences
                            ._receiptItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PurchaseRecordsTableReferences(db, table, p0)
                                .receiptItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.purchaseId == item.id),
                        typedResults: items),
                  if (syncOutboxRefs)
                    await $_getPrefetchedData<PurchaseRecord,
                            $PurchaseRecordsTable, SyncOutboxData>(
                        currentTable: table,
                        referencedTable: $$PurchaseRecordsTableReferences
                            ._syncOutboxRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PurchaseRecordsTableReferences(db, table, p0)
                                .syncOutboxRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.purchaseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PurchaseRecordsTableProcessedTableManager = ProcessedTableManager<
    _$ReceiptTrailDatabase,
    $PurchaseRecordsTable,
    PurchaseRecord,
    $$PurchaseRecordsTableFilterComposer,
    $$PurchaseRecordsTableOrderingComposer,
    $$PurchaseRecordsTableAnnotationComposer,
    $$PurchaseRecordsTableCreateCompanionBuilder,
    $$PurchaseRecordsTableUpdateCompanionBuilder,
    (PurchaseRecord, $$PurchaseRecordsTableReferences),
    PurchaseRecord,
    PrefetchHooks Function(
        {bool uniformInvoicesRefs,
        bool purchasePlacesRefs,
        bool receiptItemsRefs,
        bool syncOutboxRefs})>;
typedef $$UniformInvoicesTableCreateCompanionBuilder = UniformInvoicesCompanion
    Function({
  required String purchaseId,
  required String receiptNumber,
  Value<String?> period,
  Value<String?> prizeStatus,
  Value<String?> sellerTaxId,
  Value<int> rowid,
});
typedef $$UniformInvoicesTableUpdateCompanionBuilder = UniformInvoicesCompanion
    Function({
  Value<String> purchaseId,
  Value<String> receiptNumber,
  Value<String?> period,
  Value<String?> prizeStatus,
  Value<String?> sellerTaxId,
  Value<int> rowid,
});

final class $$UniformInvoicesTableReferences extends BaseReferences<
    _$ReceiptTrailDatabase, $UniformInvoicesTable, UniformInvoice> {
  $$UniformInvoicesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PurchaseRecordsTable _purchaseIdTable(_$ReceiptTrailDatabase db) =>
      db.purchaseRecords
          .createAlias('uniform_invoices__purchase_id__purchase_records__id');

  $$PurchaseRecordsTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager =
        $$PurchaseRecordsTableTableManager($_db, $_db.purchaseRecords)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UniformInvoicesTableFilterComposer
    extends Composer<_$ReceiptTrailDatabase, $UniformInvoicesTable> {
  $$UniformInvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prizeStatus => $composableBuilder(
      column: $table.prizeStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sellerTaxId => $composableBuilder(
      column: $table.sellerTaxId, builder: (column) => ColumnFilters(column));

  $$PurchaseRecordsTableFilterComposer get purchaseId {
    final $$PurchaseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UniformInvoicesTableOrderingComposer
    extends Composer<_$ReceiptTrailDatabase, $UniformInvoicesTable> {
  $$UniformInvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prizeStatus => $composableBuilder(
      column: $table.prizeStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sellerTaxId => $composableBuilder(
      column: $table.sellerTaxId, builder: (column) => ColumnOrderings(column));

  $$PurchaseRecordsTableOrderingComposer get purchaseId {
    final $$PurchaseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UniformInvoicesTableAnnotationComposer
    extends Composer<_$ReceiptTrailDatabase, $UniformInvoicesTable> {
  $$UniformInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get prizeStatus => $composableBuilder(
      column: $table.prizeStatus, builder: (column) => column);

  GeneratedColumn<String> get sellerTaxId => $composableBuilder(
      column: $table.sellerTaxId, builder: (column) => column);

  $$PurchaseRecordsTableAnnotationComposer get purchaseId {
    final $$PurchaseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UniformInvoicesTableTableManager extends RootTableManager<
    _$ReceiptTrailDatabase,
    $UniformInvoicesTable,
    UniformInvoice,
    $$UniformInvoicesTableFilterComposer,
    $$UniformInvoicesTableOrderingComposer,
    $$UniformInvoicesTableAnnotationComposer,
    $$UniformInvoicesTableCreateCompanionBuilder,
    $$UniformInvoicesTableUpdateCompanionBuilder,
    (UniformInvoice, $$UniformInvoicesTableReferences),
    UniformInvoice,
    PrefetchHooks Function({bool purchaseId})> {
  $$UniformInvoicesTableTableManager(
      _$ReceiptTrailDatabase db, $UniformInvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UniformInvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UniformInvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UniformInvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> purchaseId = const Value.absent(),
            Value<String> receiptNumber = const Value.absent(),
            Value<String?> period = const Value.absent(),
            Value<String?> prizeStatus = const Value.absent(),
            Value<String?> sellerTaxId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UniformInvoicesCompanion(
            purchaseId: purchaseId,
            receiptNumber: receiptNumber,
            period: period,
            prizeStatus: prizeStatus,
            sellerTaxId: sellerTaxId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String purchaseId,
            required String receiptNumber,
            Value<String?> period = const Value.absent(),
            Value<String?> prizeStatus = const Value.absent(),
            Value<String?> sellerTaxId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UniformInvoicesCompanion.insert(
            purchaseId: purchaseId,
            receiptNumber: receiptNumber,
            period: period,
            prizeStatus: prizeStatus,
            sellerTaxId: sellerTaxId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UniformInvoicesTable, UniformInvoice>(table),
                    $$UniformInvoicesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (purchaseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.purchaseId,
                    referencedTable:
                        $$UniformInvoicesTableReferences._purchaseIdTable(db),
                    referencedColumn: $$UniformInvoicesTableReferences
                        ._purchaseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UniformInvoicesTableProcessedTableManager = ProcessedTableManager<
    _$ReceiptTrailDatabase,
    $UniformInvoicesTable,
    UniformInvoice,
    $$UniformInvoicesTableFilterComposer,
    $$UniformInvoicesTableOrderingComposer,
    $$UniformInvoicesTableAnnotationComposer,
    $$UniformInvoicesTableCreateCompanionBuilder,
    $$UniformInvoicesTableUpdateCompanionBuilder,
    (UniformInvoice, $$UniformInvoicesTableReferences),
    UniformInvoice,
    PrefetchHooks Function({bool purchaseId})>;
typedef $$PurchasePlacesTableCreateCompanionBuilder = PurchasePlacesCompanion
    Function({
  required String purchaseId,
  required String address,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> rowid,
});
typedef $$PurchasePlacesTableUpdateCompanionBuilder = PurchasePlacesCompanion
    Function({
  Value<String> purchaseId,
  Value<String> address,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> rowid,
});

final class $$PurchasePlacesTableReferences extends BaseReferences<
    _$ReceiptTrailDatabase, $PurchasePlacesTable, PurchasePlace> {
  $$PurchasePlacesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PurchaseRecordsTable _purchaseIdTable(_$ReceiptTrailDatabase db) =>
      db.purchaseRecords
          .createAlias('purchase_places__purchase_id__purchase_records__id');

  $$PurchaseRecordsTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager =
        $$PurchaseRecordsTableTableManager($_db, $_db.purchaseRecords)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PurchasePlacesTableFilterComposer
    extends Composer<_$ReceiptTrailDatabase, $PurchasePlacesTable> {
  $$PurchasePlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  $$PurchaseRecordsTableFilterComposer get purchaseId {
    final $$PurchaseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PurchasePlacesTableOrderingComposer
    extends Composer<_$ReceiptTrailDatabase, $PurchasePlacesTable> {
  $$PurchasePlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  $$PurchaseRecordsTableOrderingComposer get purchaseId {
    final $$PurchaseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PurchasePlacesTableAnnotationComposer
    extends Composer<_$ReceiptTrailDatabase, $PurchasePlacesTable> {
  $$PurchasePlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  $$PurchaseRecordsTableAnnotationComposer get purchaseId {
    final $$PurchaseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PurchasePlacesTableTableManager extends RootTableManager<
    _$ReceiptTrailDatabase,
    $PurchasePlacesTable,
    PurchasePlace,
    $$PurchasePlacesTableFilterComposer,
    $$PurchasePlacesTableOrderingComposer,
    $$PurchasePlacesTableAnnotationComposer,
    $$PurchasePlacesTableCreateCompanionBuilder,
    $$PurchasePlacesTableUpdateCompanionBuilder,
    (PurchasePlace, $$PurchasePlacesTableReferences),
    PurchasePlace,
    PrefetchHooks Function({bool purchaseId})> {
  $$PurchasePlacesTableTableManager(
      _$ReceiptTrailDatabase db, $PurchasePlacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasePlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasePlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasePlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> purchaseId = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchasePlacesCompanion(
            purchaseId: purchaseId,
            address: address,
            latitude: latitude,
            longitude: longitude,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String purchaseId,
            required String address,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchasePlacesCompanion.insert(
            purchaseId: purchaseId,
            address: address,
            latitude: latitude,
            longitude: longitude,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PurchasePlacesTable, PurchasePlace>(table),
                    $$PurchasePlacesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (purchaseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.purchaseId,
                    referencedTable:
                        $$PurchasePlacesTableReferences._purchaseIdTable(db),
                    referencedColumn:
                        $$PurchasePlacesTableReferences._purchaseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PurchasePlacesTableProcessedTableManager = ProcessedTableManager<
    _$ReceiptTrailDatabase,
    $PurchasePlacesTable,
    PurchasePlace,
    $$PurchasePlacesTableFilterComposer,
    $$PurchasePlacesTableOrderingComposer,
    $$PurchasePlacesTableAnnotationComposer,
    $$PurchasePlacesTableCreateCompanionBuilder,
    $$PurchasePlacesTableUpdateCompanionBuilder,
    (PurchasePlace, $$PurchasePlacesTableReferences),
    PurchasePlace,
    PrefetchHooks Function({bool purchaseId})>;
typedef $$ReceiptItemsTableCreateCompanionBuilder = ReceiptItemsCompanion
    Function({
  Value<int> id,
  required String purchaseId,
  required String name,
  Value<int> quantity,
  required int price,
  required int lineIndex,
});
typedef $$ReceiptItemsTableUpdateCompanionBuilder = ReceiptItemsCompanion
    Function({
  Value<int> id,
  Value<String> purchaseId,
  Value<String> name,
  Value<int> quantity,
  Value<int> price,
  Value<int> lineIndex,
});

final class $$ReceiptItemsTableReferences extends BaseReferences<
    _$ReceiptTrailDatabase, $ReceiptItemsTable, ReceiptItem> {
  $$ReceiptItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PurchaseRecordsTable _purchaseIdTable(_$ReceiptTrailDatabase db) =>
      db.purchaseRecords
          .createAlias('receipt_items__purchase_id__purchase_records__id');

  $$PurchaseRecordsTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager =
        $$PurchaseRecordsTableTableManager($_db, $_db.purchaseRecords)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReceiptItemsTableFilterComposer
    extends Composer<_$ReceiptTrailDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnFilters(column));

  $$PurchaseRecordsTableFilterComposer get purchaseId {
    final $$PurchaseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReceiptItemsTableOrderingComposer
    extends Composer<_$ReceiptTrailDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnOrderings(column));

  $$PurchaseRecordsTableOrderingComposer get purchaseId {
    final $$PurchaseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReceiptItemsTableAnnotationComposer
    extends Composer<_$ReceiptTrailDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get lineIndex =>
      $composableBuilder(column: $table.lineIndex, builder: (column) => column);

  $$PurchaseRecordsTableAnnotationComposer get purchaseId {
    final $$PurchaseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReceiptItemsTableTableManager extends RootTableManager<
    _$ReceiptTrailDatabase,
    $ReceiptItemsTable,
    ReceiptItem,
    $$ReceiptItemsTableFilterComposer,
    $$ReceiptItemsTableOrderingComposer,
    $$ReceiptItemsTableAnnotationComposer,
    $$ReceiptItemsTableCreateCompanionBuilder,
    $$ReceiptItemsTableUpdateCompanionBuilder,
    (ReceiptItem, $$ReceiptItemsTableReferences),
    ReceiptItem,
    PrefetchHooks Function({bool purchaseId})> {
  $$ReceiptItemsTableTableManager(
      _$ReceiptTrailDatabase db, $ReceiptItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> purchaseId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> price = const Value.absent(),
            Value<int> lineIndex = const Value.absent(),
          }) =>
              ReceiptItemsCompanion(
            id: id,
            purchaseId: purchaseId,
            name: name,
            quantity: quantity,
            price: price,
            lineIndex: lineIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String purchaseId,
            required String name,
            Value<int> quantity = const Value.absent(),
            required int price,
            required int lineIndex,
          }) =>
              ReceiptItemsCompanion.insert(
            id: id,
            purchaseId: purchaseId,
            name: name,
            quantity: quantity,
            price: price,
            lineIndex: lineIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReceiptItemsTable, ReceiptItem>(table),
                    $$ReceiptItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (purchaseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.purchaseId,
                    referencedTable:
                        $$ReceiptItemsTableReferences._purchaseIdTable(db),
                    referencedColumn:
                        $$ReceiptItemsTableReferences._purchaseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReceiptItemsTableProcessedTableManager = ProcessedTableManager<
    _$ReceiptTrailDatabase,
    $ReceiptItemsTable,
    ReceiptItem,
    $$ReceiptItemsTableFilterComposer,
    $$ReceiptItemsTableOrderingComposer,
    $$ReceiptItemsTableAnnotationComposer,
    $$ReceiptItemsTableCreateCompanionBuilder,
    $$ReceiptItemsTableUpdateCompanionBuilder,
    (ReceiptItem, $$ReceiptItemsTableReferences),
    ReceiptItem,
    PrefetchHooks Function({bool purchaseId})>;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  required String operationId,
  required String purchaseId,
  required int userId,
  required String operation,
  Value<int> retryCount,
  Value<String?> lastError,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<String> operationId,
  Value<String> purchaseId,
  Value<int> userId,
  Value<String> operation,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SyncOutboxTableReferences extends BaseReferences<
    _$ReceiptTrailDatabase, $SyncOutboxTable, SyncOutboxData> {
  $$SyncOutboxTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PurchaseRecordsTable _purchaseIdTable(_$ReceiptTrailDatabase db) =>
      db.purchaseRecords
          .createAlias('sync_outbox__purchase_id__purchase_records__id');

  $$PurchaseRecordsTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager =
        $$PurchaseRecordsTableTableManager($_db, $_db.purchaseRecords)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SyncOutboxTableFilterComposer
    extends Composer<_$ReceiptTrailDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PurchaseRecordsTableFilterComposer get purchaseId {
    final $$PurchaseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$ReceiptTrailDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PurchaseRecordsTableOrderingComposer get purchaseId {
    final $$PurchaseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$ReceiptTrailDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PurchaseRecordsTableAnnotationComposer get purchaseId {
    final $$PurchaseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.purchaseId,
        referencedTable: $db.purchaseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchaseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.purchaseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncOutboxTableTableManager extends RootTableManager<
    _$ReceiptTrailDatabase,
    $SyncOutboxTable,
    SyncOutboxData,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (SyncOutboxData, $$SyncOutboxTableReferences),
    SyncOutboxData,
    PrefetchHooks Function({bool purchaseId})> {
  $$SyncOutboxTableTableManager(
      _$ReceiptTrailDatabase db, $SyncOutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> operationId = const Value.absent(),
            Value<String> purchaseId = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxCompanion(
            operationId: operationId,
            purchaseId: purchaseId,
            userId: userId,
            operation: operation,
            retryCount: retryCount,
            lastError: lastError,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String operationId,
            required String purchaseId,
            required int userId,
            required String operation,
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxCompanion.insert(
            operationId: operationId,
            purchaseId: purchaseId,
            userId: userId,
            operation: operation,
            retryCount: retryCount,
            lastError: lastError,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SyncOutboxTable, SyncOutboxData>(table),
                    $$SyncOutboxTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (purchaseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.purchaseId,
                    referencedTable:
                        $$SyncOutboxTableReferences._purchaseIdTable(db),
                    referencedColumn:
                        $$SyncOutboxTableReferences._purchaseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SyncOutboxTableProcessedTableManager = ProcessedTableManager<
    _$ReceiptTrailDatabase,
    $SyncOutboxTable,
    SyncOutboxData,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (SyncOutboxData, $$SyncOutboxTableReferences),
    SyncOutboxData,
    PrefetchHooks Function({bool purchaseId})>;
typedef $$AppMetadataTableCreateCompanionBuilder = AppMetadataCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetadataTableUpdateCompanionBuilder = AppMetadataCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetadataTableFilterComposer
    extends Composer<_$ReceiptTrailDatabase, $AppMetadataTable> {
  $$AppMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetadataTableOrderingComposer
    extends Composer<_$ReceiptTrailDatabase, $AppMetadataTable> {
  $$AppMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetadataTableAnnotationComposer
    extends Composer<_$ReceiptTrailDatabase, $AppMetadataTable> {
  $$AppMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetadataTableTableManager extends RootTableManager<
    _$ReceiptTrailDatabase,
    $AppMetadataTable,
    AppMetadataData,
    $$AppMetadataTableFilterComposer,
    $$AppMetadataTableOrderingComposer,
    $$AppMetadataTableAnnotationComposer,
    $$AppMetadataTableCreateCompanionBuilder,
    $$AppMetadataTableUpdateCompanionBuilder,
    (
      AppMetadataData,
      BaseReferences<_$ReceiptTrailDatabase, $AppMetadataTable, AppMetadataData>
    ),
    AppMetadataData,
    PrefetchHooks Function()> {
  $$AppMetadataTableTableManager(
      _$ReceiptTrailDatabase db, $AppMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetadataCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetadataCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppMetadataTable, AppMetadataData>(table),
                    BaseReferences<_$ReceiptTrailDatabase, $AppMetadataTable,
                        AppMetadataData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppMetadataTableProcessedTableManager = ProcessedTableManager<
    _$ReceiptTrailDatabase,
    $AppMetadataTable,
    AppMetadataData,
    $$AppMetadataTableFilterComposer,
    $$AppMetadataTableOrderingComposer,
    $$AppMetadataTableAnnotationComposer,
    $$AppMetadataTableCreateCompanionBuilder,
    $$AppMetadataTableUpdateCompanionBuilder,
    (
      AppMetadataData,
      BaseReferences<_$ReceiptTrailDatabase, $AppMetadataTable, AppMetadataData>
    ),
    AppMetadataData,
    PrefetchHooks Function()>;

class $ReceiptTrailDatabaseManager {
  final _$ReceiptTrailDatabase _db;
  $ReceiptTrailDatabaseManager(this._db);
  $$PurchaseRecordsTableTableManager get purchaseRecords =>
      $$PurchaseRecordsTableTableManager(_db, _db.purchaseRecords);
  $$UniformInvoicesTableTableManager get uniformInvoices =>
      $$UniformInvoicesTableTableManager(_db, _db.uniformInvoices);
  $$PurchasePlacesTableTableManager get purchasePlaces =>
      $$PurchasePlacesTableTableManager(_db, _db.purchasePlaces);
  $$ReceiptItemsTableTableManager get receiptItems =>
      $$ReceiptItemsTableTableManager(_db, _db.receiptItems);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$AppMetadataTableTableManager get appMetadata =>
      $$AppMetadataTableTableManager(_db, _db.appMetadata);
}
