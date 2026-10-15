import 'package:flutter/material.dart';

import 'invoice_period.dart';
import 'receipt_amounts.dart';

enum SpendingCategory { food, shopping, transport, other }

extension SpendingCategoryUi on SpendingCategory {
  String get label => switch (this) {
    SpendingCategory.food => '餐飲',
    SpendingCategory.shopping => '購物',
    SpendingCategory.transport => '交通',
    SpendingCategory.other => '其他',
  };

  IconData get icon => switch (this) {
    SpendingCategory.food => Icons.restaurant_rounded,
    SpendingCategory.shopping => Icons.shopping_bag_rounded,
    SpendingCategory.transport => Icons.directions_bus_rounded,
    SpendingCategory.other => Icons.more_horiz_rounded,
  };
}

class ReceiptItem {
  const ReceiptItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  final String name;
  final int quantity;
  final int price;

  Map<String, Object> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': price,
  };

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
    name: json['name'] as String,
    quantity: json['quantity'] as int? ?? 1,
    price: json['price'] as int,
  );
}

class Receipt {
  factory Receipt({
    required String id,
    required String storeName,
    required String address,
    required DateTime date,
    required int total,
    required SpendingCategory category,
    required List<ReceiptItem> items,
    required String receiptNumber,
    bool isSynced = true,
    String? rawText,
    double? latitude,
    double? longitude,
    int? subtotal,
    int discount = 0,
    String? sellerTaxId,
  }) {
    final amounts = subtotal == null && discount == 0
        ? ReceiptAmounts.legacy(total)
        : ReceiptAmounts(
            subtotal: subtotal ?? total + discount,
            discount: discount,
            total: total,
          );
    return Receipt._(
      id: id,
      storeName: storeName,
      address: address,
      date: date,
      amounts: amounts,
      category: category,
      items: items,
      receiptNumber: receiptNumber,
      isSynced: isSynced,
      rawText: rawText,
      latitude: latitude,
      longitude: longitude,
      sellerTaxId: sellerTaxId?.trim().isEmpty == true
          ? null
          : sellerTaxId?.trim(),
    );
  }

  Receipt._({
    required this.id,
    required this.storeName,
    required this.address,
    required this.date,
    required ReceiptAmounts amounts,
    required this.category,
    required this.items,
    required this.receiptNumber,
    required this.isSynced,
    required this.rawText,
    required this.latitude,
    required this.longitude,
    required this.sellerTaxId,
  }) : subtotal = amounts.subtotal,
       discount = amounts.discount,
       total = amounts.total;

  final String id;
  final String storeName;
  final String address;
  final DateTime date;
  final int total;
  final int subtotal;
  final int discount;
  final String? sellerTaxId;
  final SpendingCategory category;
  final List<ReceiptItem> items;
  final String receiptNumber;
  final bool isSynced;
  final String? rawText;
  final double? latitude;
  final double? longitude;

  InvoicePeriod get period => InvoicePeriod.fromPurchaseDate(date);

  Receipt copyWith({
    bool? isSynced,
    String? rawText,
    double? latitude,
    double? longitude,
    int? subtotal,
    int? discount,
    int? total,
    String? sellerTaxId,
  }) => Receipt(
    id: id,
    storeName: storeName,
    address: address,
    date: date,
    subtotal: subtotal ?? this.subtotal,
    discount: discount ?? this.discount,
    total: total ?? this.total,
    category: category,
    items: items,
    receiptNumber: receiptNumber,
    isSynced: isSynced ?? this.isSynced,
    rawText: rawText ?? this.rawText,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    sellerTaxId: sellerTaxId ?? this.sellerTaxId,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'storeName': storeName,
    'address': address,
    'date': date.toIso8601String(),
    'total': total,
    'subtotal': subtotal,
    'discount': discount,
    'category': category.name,
    'items': items.map((item) => item.toJson()).toList(),
    'receiptNumber': receiptNumber,
    if (sellerTaxId != null) 'sellerTaxId': sellerTaxId!,
    'isSynced': isSynced,
    if (rawText != null) 'rawText': rawText!,
    if (latitude != null) 'latitude': latitude!,
    if (longitude != null) 'longitude': longitude!,
  };

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id: json['id'] as String,
    storeName: json['storeName'] as String,
    address: _emptyWhenLegacyPlaceholder(json['address'] as String?, '未填寫地址'),
    date: DateTime.parse(json['date'] as String),
    total: json['total'] as int,
    subtotal: json['subtotal'] as int?,
    discount: json['discount'] as int? ?? 0,
    category: SpendingCategory.values.firstWhere(
      (value) => value.name == json['category'],
      orElse: () => SpendingCategory.other,
    ),
    items: (json['items'] as List<dynamic>? ?? const [])
        .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    receiptNumber: _emptyWhenLegacyPlaceholder(
      json['receiptNumber'] as String?,
      '未填寫',
    ),
    sellerTaxId: json['sellerTaxId'] as String?,
    isSynced: json['isSynced'] as bool? ?? false,
    rawText: json['rawText'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}

String _emptyWhenLegacyPlaceholder(String? value, String legacyPlaceholder) {
  final normalized = value?.trim() ?? '';
  return normalized == legacyPlaceholder ? '' : normalized;
}

class StoreSummary {
  const StoreSummary({
    required this.name,
    required this.address,
    required this.visits,
    required this.total,
    required this.lastVisit,
    required this.category,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String address;
  final int visits;
  final int total;
  final DateTime lastVisit;
  final SpendingCategory category;
  final double? latitude;
  final double? longitude;

  int get average => (total / visits).round();
}
