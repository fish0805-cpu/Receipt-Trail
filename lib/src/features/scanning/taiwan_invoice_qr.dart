import 'dart:convert';

import '../purchases/purchase_models.dart';

class TaiwanInvoiceQrData {
  const TaiwanInvoiceQrData({
    required this.receiptNumber,
    this.date,
    this.total,
    this.sellerTaxId,
    this.items = const <ReceiptItem>[],
    this.itemsComplete = false,
  });

  final String receiptNumber;
  final DateTime? date;
  final int? total;
  final String? sellerTaxId;
  final List<ReceiptItem> items;
  final bool itemsComplete;
}

TaiwanInvoiceQrData? parseTaiwanInvoiceQr(
  String rawValue, {
  String? rightValue,
}) {
  final value = rawValue.trim();
  final invoiceMatch = RegExp(r'^[A-Z]{2}\d{8}').firstMatch(value);
  if (invoiceMatch == null || value.length < 37) return null;

  DateTime? date;
  int? total;
  if (invoiceMatch.start == 0 && value.length >= 37) {
    final rocDate = value.substring(10, 17);
    final rocYear = int.tryParse(rocDate.substring(0, 3));
    final month = int.tryParse(rocDate.substring(3, 5));
    final day = int.tryParse(rocDate.substring(5, 7));
    if (rocYear != null && month != null && day != null) {
      try {
        final candidate = DateTime(rocYear + 1911, month, day);
        if (candidate.month == month && candidate.day == day) date = candidate;
      } on ArgumentError {
        date = null;
      }
    }

    total = int.tryParse(value.substring(29, 37), radix: 16);
  }

  String? sellerTaxId;
  var items = const <ReceiptItem>[];
  var itemsComplete = false;
  if (value.length >= 77) {
    final seller = value.substring(45, 53);
    if (RegExp(r'^\d{8}$').hasMatch(seller)) sellerTaxId = seller;
    final paired = rightValue?.startsWith('**') == true
        ? '$value${rightValue!.substring(2)}'
        : value;
    if (paired.length > 77 && paired[77] == ':') {
      final parts = paired.substring(77).split(':');
      if (parts.length >= 5 &&
          const {'0', '1', '2'}.contains(parts[4]) &&
          int.tryParse(parts[2]) != null &&
          int.tryParse(parts[3]) != null) {
        final qrItemCount = int.parse(parts[2]);
        final receiptItemCount = int.parse(parts[3]);
        final parsed = <ReceiptItem>[];
        List<String> fields;
        if (parts[4] == '2') {
          try {
            fields =
                utf8.decode(base64.decode(parts.skip(5).join(':'))).split(':');
          } on FormatException {
            fields = const <String>[];
          }
        } else {
          fields = parts.skip(5).toList();
        }
        for (var index = 0; index < qrItemCount; index++) {
          final offset = index * 3;
          if (offset + 2 >= fields.length) break;
          final name = fields[offset].trim();
          final quantity = int.tryParse(fields[offset + 1]);
          final unitPrice = int.tryParse(fields[offset + 2]);
          if (name.isEmpty ||
              quantity == null ||
              quantity < 1 ||
              unitPrice == null ||
              unitPrice < 0) {
            break;
          }
          parsed.add(
            ReceiptItem(name: name, quantity: quantity, price: unitPrice),
          );
        }
        items = List<ReceiptItem>.unmodifiable(parsed);
        itemsComplete = qrItemCount == receiptItemCount &&
            parsed.length == qrItemCount &&
            qrItemCount > 0;
      }
    }
  }

  return TaiwanInvoiceQrData(
    receiptNumber: invoiceMatch.group(0)!,
    date: date,
    total: total,
    sellerTaxId: sellerTaxId,
    items: items,
    itemsComplete: itemsComplete,
  );
}
