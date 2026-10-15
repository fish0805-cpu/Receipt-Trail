import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../purchases/purchase_models.dart';

class ReceiptExportArchive {
  const ReceiptExportArchive({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

class ReceiptExportService {
  const ReceiptExportService();

  ReceiptExportArchive buildArchive({
    required Iterable<Receipt> receipts,
    required DateTime exportedAt,
    required String ownerType,
    bool includeOcrText = false,
  }) {
    final records = receipts.toList(growable: false);
    final jsonRecords = records.map((receipt) {
      final value = Map<String, Object>.of(receipt.toJson());
      if (!includeOcrText) value.remove('rawText');
      return value;
    }).toList(growable: false);
    final metadata = <String, Object>{
      'formatVersion': 1,
      'app': 'Receipt Trail',
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'ownerType': ownerType,
      'recordCount': records.length,
      'includesOcrText': includeOcrText,
    };
    final encoder = const JsonEncoder.withIndent('  ');
    final archive = Archive()
      ..add(_textFile('receipts.csv', _buildCsv(records, includeOcrText)))
      ..add(_textFile('receipts.json', encoder.convert(jsonRecords)))
      ..add(_textFile('metadata.json', encoder.convert(metadata)));
    final bytes = ZipEncoder().encodeBytes(archive);
    return ReceiptExportArchive(
      fileName: 'receipt-trail-${_timestamp(exportedAt.toUtc())}.zip',
      bytes: bytes,
    );
  }

  ArchiveFile _textFile(String name, String value) {
    final bytes = utf8.encode(value);
    return ArchiveFile(name, bytes.length, bytes);
  }

  String _buildCsv(List<Receipt> receipts, bool includeOcrText) {
    final headers = <String>[
      'id',
      'storeName',
      'address',
      'date',
      'receiptNumber',
      'period',
      'sellerTaxId',
      'category',
      'subtotal',
      'discount',
      'total',
      'latitude',
      'longitude',
      'itemsJson',
      if (includeOcrText) 'rawText',
    ];
    final rows = <List<Object?>>[
      headers,
      for (final receipt in receipts)
        <Object?>[
          receipt.id,
          receipt.storeName,
          receipt.address,
          receipt.date.toIso8601String(),
          receipt.receiptNumber,
          receipt.period.rocTerm,
          receipt.sellerTaxId,
          receipt.category.name,
          receipt.subtotal,
          receipt.discount,
          receipt.total,
          receipt.latitude,
          receipt.longitude,
          jsonEncode(receipt.items.map((item) => item.toJson()).toList()),
          if (includeOcrText) receipt.rawText,
        ],
    ];
    return '\uFEFF${rows.map((row) => row.map(_csvCell).join(',')).join('\r\n')}';
  }

  String _csvCell(Object? value) {
    var text = value?.toString() ?? '';
    if (RegExp(r'^\s*[=+\-@]').hasMatch(text)) text = "'$text";
    if (!text.contains(RegExp('[,"\\r\\n]'))) return text;
    return '"${text.replaceAll('"', '""')}"';
  }

  String _timestamp(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}'
      '${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}-'
      '${value.hour.toString().padLeft(2, '0')}'
      '${value.minute.toString().padLeft(2, '0')}'
      '${value.second.toString().padLeft(2, '0')}';
}
